import { stat } from "node:fs/promises";
import path from "node:path";

const dirtySessions = new Set();

const COMMIT_MESSAGE_PREFIX = "chore(opencode): auto-commit after assistant edits";
const MAX_AUTO_COMMIT_FILE_SIZE_BYTES = 10 * 1024 * 1024;
const CHECKPOINT_EXTENSIONS = new Set([
  ".ckpt",
  ".pt",
  ".pth",
  ".safetensors",
  ".onnx",
  ".h5",
  ".npz",
]);

const isSensitiveFile = (filePath) => {
  const normalizedPath = filePath.replaceAll("\\", "/");
  const lowerPath = normalizedPath.toLowerCase();
  const baseName = path.posix.basename(lowerPath);

  if (baseName === ".env" || baseName.startsWith(".env.")) {
    return true;
  }

  if (lowerPath.endsWith(".pem") || lowerPath.endsWith(".key")) {
    return true;
  }

  if (lowerPath.includes("token")) {
    return true;
  }

  if (lowerPath.includes("credential") && lowerPath.endsWith(".json")) {
    return true;
  }

  const extension = path.posix.extname(baseName);
  return CHECKPOINT_EXTENSIONS.has(extension);
};

export const AutoGitCommitPlugin = async ({ $, worktree }) => {
  const runInWorktree = $.cwd(worktree);

  const isGitRepo = async () => {
    const result = await runInWorktree
      .nothrow()`git rev-parse --is-inside-work-tree`
      .quiet();

    return result.exitCode === 0 && result.text().trim() === "true";
  };

  const hasWorkingTreeChanges = async () => {
    const result = await runInWorktree
      .nothrow()`git status --porcelain`
      .quiet();

    return result.exitCode === 0 && result.text().trim().length > 0;
  };

  const hasStagedChanges = async () => {
    const result = await runInWorktree
      .nothrow()`git diff --cached --name-only`
      .quiet();

    return result.exitCode === 0 && result.text().trim().length > 0;
  };

  const getStagedFiles = async () => {
    const result = await runInWorktree
      .nothrow()`git diff --cached --name-only -z`
      .quiet();

    if (result.exitCode !== 0) {
      return [];
    }

    return result
      .text()
      .split("\0")
      .map((entry) => entry.trim())
      .filter((entry) => entry.length > 0);
  };

  const shouldExcludeFromAutoCommit = async (filePath) => {
    if (isSensitiveFile(filePath)) {
      return true;
    }

    try {
      const fileStats = await stat(path.resolve(worktree, filePath));
      return fileStats.isFile() && fileStats.size > MAX_AUTO_COMMIT_FILE_SIZE_BYTES;
    } catch {
      return false;
    }
  };

  const unstageDisallowedFiles = async () => {
    const stagedFiles = await getStagedFiles();

    for (const filePath of stagedFiles) {
      if (!(await shouldExcludeFromAutoCommit(filePath))) {
        continue;
      }

      await runInWorktree`git restore --staged -- ${filePath}`.quiet();
    }
  };

  const autoCommit = async () => {
    await runInWorktree`git add -A`.quiet();
    await unstageDisallowedFiles();

    if (!(await hasStagedChanges())) {
      return;
    }

    await runInWorktree`git commit -m ${`${COMMIT_MESSAGE_PREFIX} (${new Date().toISOString()})`}`.quiet();
  };

  return {
    event: async ({ event }) => {
      if (event.type === "message.part.updated") {
        const { part } = event.properties;

        if (part.type === "patch") {
          dirtySessions.add(part.sessionID);
        }
        return;
      }

      if (event.type !== "session.idle") {
        return;
      }

      const { sessionID } = event.properties;

      if (!dirtySessions.has(sessionID)) {
        return;
      }

      dirtySessions.delete(sessionID);

      if (!(await isGitRepo())) {
        return;
      }

      if (!(await hasWorkingTreeChanges())) {
        return;
      }

      try {
        await autoCommit();
      } catch (error) {
        console.error("[auto-git-commit] auto commit failed", error);
      }
    },
  };
};
