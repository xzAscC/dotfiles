return {
  backend = "kitty",
  processor = "magick_cli",
  max_width_window_percentage = 100,
  max_height_window_percentage = 80,
  hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.pdf" },
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
    },
  },
}
