# The reference LVGL panel draws to a Linux framebuffer, which LVGL's recipe leaves out unless asked.
PACKAGECONFIG:append = " fbdev"

# With its DRM driver, LVGL's library calls libdrm and is linked without it, and its pkg-config file names
# neither the library nor libdrm's headers, which LVGL's own include: a program built against it then fails
# to compile or to link. Both are said here, for whatever builds against LVGL.
LDFLAGS:append = "${@bb.utils.contains('PACKAGECONFIG', 'drm', ' -Wl,--no-as-needed -ldrm -Wl,--as-needed', '', d)}"
do_install:append() {
	if ${@bb.utils.contains('PACKAGECONFIG', 'drm', 'true', 'false', d)}; then
		sed -i '/^Libs:/i Requires.private: libdrm' ${D}${datadir}/pkgconfig/lvgl.pc
	fi
}
