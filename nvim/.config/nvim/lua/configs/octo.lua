-- =============================================================================
-- octo.nvim — GitHub PR Review Workflow & Keymaps 速查
-- =============================================================================
--
-- 前提
--   - `gh auth login`，token scope 含 `repo`（当前 repo/read:org/gist/workflow 足够）
--   - 在被 review 的 git repo 目录下启动 nvim
--   - 所有 review 相关键走 octo 默认的 <localleader>（Neovim 默认 `\`）
--
-- -----------------------------------------------------------------------------
-- #1 完整 review 一个 PR 的流程
-- -----------------------------------------------------------------------------
--
--   1. 打开 PR（三选一）
--        :Octo pr list            列当前 repo 的 PR，<CR> 选中打开
--        :Octo pr edit <编号>     直接打开指定 PR
--        :Octo <PR 的 GitHub URL> 粘贴 URL 打开
--
--   2. 进入 review（在 PR 缓冲区里执行）
--        :Octo review start       全新开始一次 review
--        :Octo review resume      继续未提交的 review
--        → 自动开新 tab：左 changed files 面板 + 右侧 diff 双窗
--
--   3. 浏览改动文件
--        ]q / [q     下一个 / 上一个改动文件
--        ]u / [u     下一个 / 上一个【未查看】文件
--        <CR>        在 file_panel 里打开某文件的 diff
--
--   4. 加行内评论（review diff 窗口里，光标移到目标行）
--        \ca         加评论（普通模式加单行；visual 选若干行加多行）
--        \sa         加 code suggestion（带 ```suggestion 代码块）
--                    → 右侧浮出评论 buffer，写完 :w 提交（pending 状态）
--
--   5. 提交 review（选 approve / comment / request changes）
--        :Octo review submit      或在 diff 里按 \vs
--        → 弹出顶层评论 float 窗口，写完正文按：
--            <C-a>   approve（批准）
--            <C-m>   comment（仅评论）
--            <C-r>   request changes（要求修改）
--            <C-c>   取消
--
--   6. 其他常用
--        :Octo review comments    查看本次 review 已写的 pending 评论
--        :Octo review commit      只 review 某个 commit 的改动
--        :Octo review discard     丢弃整个 pending review（删掉所有未提交评论）
--        :Octo review close       关闭 review tab
--
-- -----------------------------------------------------------------------------
-- #2 常用快捷键速查（<localleader> 默认为 `\`）
-- -----------------------------------------------------------------------------
--
-- review_diff（diff 窗口里，加行内评论就在这）
--   \ca          加一条新 review 评论（n / x 模式）
--   \sa          加一条 code suggestion
--   \vs          提交 review（等价 :Octo review submit）
--   \vd          丢弃 review（等价 :Octo review discard）
--   ]t / [t      下一个 / 上一个评论 thread
--   ]q / [q      下一个 / 上一个改动文件
--   ]u / [u      下一个 / 上一个未查看文件
--   [Q / ]Q      第一个 / 最后一个改动文件
--   \e           焦点切到 changed files 面板
--   \b           显示 / 隐藏 changed files 面板
--   \<space>     切换该文件"已查看"状态
--   <C-c>        关闭 review tab
--   gf           go to file
--   <C-e>        复制 commit SHA 到系统剪贴板
--   \C           review PR commits（等价 :Octo review commit）
--
-- review_thread（thread buffer 窗口里）
--   \ca          加评论
--   \cr          回复某条评论
--   \sa          加 suggestion
--   \cd          删除评论
--   \ce          查看评论编辑历史
--   \rt / \rT    resolve / unresolve thread
--   ]c / [c      下一条 / 上一条评论
--
-- submit_win（:Octo review submit 弹出的 float 窗口）
--   <C-a>        approve review
--   <C-m>        comment review（仅评论）
--   <C-r>        request changes
--   <C-c>        关闭 review tab
--
-- -----------------------------------------------------------------------------
-- #3 常用命令速查
-- -----------------------------------------------------------------------------
--
--   PR
--     :Octo pr list / edit <N> / search
--     :Octo pr checkout / diff / changes / merge / close
--   Review
--     :Octo review start / resume / submit / discard / close / comments / commit
--   Comment / Reaction
--     :Octo comment add / delete
--     :Octo reaction thumb_up / thumb_down / heart / hooray / rocket / eyes
--
-- 完整列表见 :h octo-commands ；diff 颜色覆盖见 lua/autocmds.lua（UserOctoDiff*）
-- =============================================================================

local options = {
  -- 复用 telescope 作为 picker（NvChad 默认已装）
  picker = "telescope",

  -- 多 remote 时按此顺序优先匹配 repo
  default_remote = { "upstream", "origin" },

  -- sign/status 列保持交给 NvChad 的 gitsigns/diagnostic；octo 自己只用 statuscolumn
  ui = {
    use_signcolumn = false,
    use_statuscolumn = true,
    use_foldtext = true,
  },

  -- 你的 token 没有 read:project scope，但默认就关着 Projects v2，这里顺手消音
  default_to_projects_v2 = false,
  suppress_missing_scope = { projects_v2 = true },
}

return options
