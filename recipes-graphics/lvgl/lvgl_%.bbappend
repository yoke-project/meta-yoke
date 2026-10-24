# The reference LVGL panel draws to a Linux framebuffer, which LVGL's recipe leaves out unless asked.
PACKAGECONFIG:append = " fbdev"
