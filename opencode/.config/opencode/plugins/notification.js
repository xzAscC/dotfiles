export const NotificationPlugin = async ({ client, $ }) => {
  const showToast = async ({ title, message, variant }) => {
    try {
      await client.tui.showToast({
        body: {
          title,
          message,
          variant,
          duration: 4000,
        },
      });
      return;
    } catch {
      await $`notify-send ${title} ${message}`;
    }
  };

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await showToast({
          title: "OpenCode",
          message: "本轮已完成（session idle）",
          variant: "success",
        });
      }

      if (event.type === "session.error") {
        await showToast({
          title: "OpenCode",
          message: "会话报错了",
          variant: "error",
        });
      }
    },
  };
};
