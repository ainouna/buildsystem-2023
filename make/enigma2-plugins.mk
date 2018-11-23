#
# enigma2_hotplug_e2_helper
#
HOTPLUG_E2_PATCH = hotplug-e2-helper.patch

$(D)/enigma2_hotplug_e2_helper: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/hotplug-e2-helper
	$(SET) -e; if [ -d $(ARCHIVE)/hotplug-e2-helper.git ]; \
		then cd $(ARCHIVE)/hotplug-e2-helper.git; git pull $(SILENT_CONFIGURE); \
		else cd $(ARCHIVE); git clone $(SILENT_CONFIGURE) https://github.com/OpenPLi/hotplug-e2-helper.git hotplug-e2-helper.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/hotplug-e2-helper.git $(BUILD_TMP)/hotplug-e2-helper
	$(SET) -e; cd $(BUILD_TMP)/hotplug-e2-helper; \
		$(call apply_patches,$(HOTPLUG_E2_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR)
	$(REMOVE)/hotplug-e2-helper
	$(TOUCH)

#
# enigma2_tuxtxtlib
#
TUXTXTLIB_PATCH = tuxtxtlib-1.0-fix-dbox-headers.patch

$(D)/enigma2_tuxtxtlib: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/tuxtxtlib
	$(SILENT)if [ -d $(ARCHIVE)/tuxtxt.git ]; \
		then cd $(ARCHIVE)/tuxtxt.git; git pull $(SILENT_CONFIGURE); \
		else cd $(ARCHIVE); git clone $(SILENT_CONFIGURE) https://github.com/OpenPLi/tuxtxt.git tuxtxt.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/tuxtxt.git/libtuxtxt $(BUILD_TMP)/tuxtxtlib
	$(SILENT)cd $(BUILD_TMP)/tuxtxtlib; \
		$(call apply_patches,$(TUXTXTLIB_PATCH)); \
		aclocal; \
		autoheader; \
		autoconf; \
		libtoolize --force; \
		automake --foreign --add-missing; \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) $(SILENT_OPT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--with-boxtype=generic \
			--with-configdir=/etc \
			--with-datadir=/usr/share/tuxtxt \
			--with-fontdir=/usr/share/fonts \
		; \
		$(MAKE) all; \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/tuxbox-tuxtxt.pc
	$(REWRITE_LIBTOOL)/libtuxtxt.la
	$(REMOVE)/tuxtxtlib
	$(TOUCH)

#
# enigma2_tuxtxt32bpp
#
TUXTXT32BPP_PATCH = tuxtxt32bpp-1.0-fix-dbox-headers.patch

$(D)/enigma2_tuxtxt32bpp: $(D)/bootstrap $(D)/enigma2_tuxtxtlib
	$(START_BUILD)
	$(REMOVE)/tuxtxt
	$(SILENT)cp -ra $(ARCHIVE)/tuxtxt.git/tuxtxt $(BUILD_TMP)/tuxtxt
	$(SET) -e; cd $(BUILD_TMP)/tuxtxt; \
		$(call apply_patches,$(TUXTXT32BPP_PATCH)); \
		aclocal; \
		autoheader; \
		autoconf; \
		libtoolize --force; \
		automake --foreign --add-missing; \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) $(SILENT_OPT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--with-fbdev=/dev/fb0 \
			--with-boxtype=generic \
			--with-configdir=/etc \
			--with-datadir=/usr/share/tuxtxt \
			--with-fontdir=/usr/share/fonts \
		; \
		$(MAKE) all; \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libtuxtxt32bpp.la
	$(REMOVE)/tuxtxt
	$(TOUCH)

#
# Plugins
#
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 0 2))
ifneq ($(MEDIAFW), buildinplayer)
E2_PLUGIN_DEPS = enigma2_servicemp3
#E2_PLUGIN_DEPS = enigma2_servicemp3epl
endif
endif
$(D)/enigma2-plugins: $(D)/enigma2_networkbrowser $(D)/enigma2_openwebif $(E2_PLUGIN_DEPS)

#
# enigma2-openwebif
#
$(D)/enigma2_openwebif: $(D)/bootstrap $(D)/python $(D)/python_cheetah $(D)/python_ipaddress
	$(START_BUILD)
	$(REMOVE)/e2openplugin-OpenWebif
	$(SILENT)if [ -d $(ARCHIVE)/e2openplugin-OpenWebif.git ]; \
		then cd $(ARCHIVE)/e2openplugin-OpenWebif.git; git pull $(SILENT_CONFIGURE); \
		else cd $(ARCHIVE); git clone $(SILENT_CONFIGURE) https://github.com/E2OpenPlugins/e2openplugin-OpenWebif.git e2openplugin-OpenWebif.git; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/e2openplugin-OpenWebif.git $(BUILD_TMP)/e2openplugin-OpenWebif
	$(SET) -e; cd $(BUILD_TMP)/e2openplugin-OpenWebif; \
		$(BUILDENV) \
		cp -a plugin $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif; \
		python -O -m compileall $(SILENT_OPT) $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/cs/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/de/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/el/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/nl/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/pl/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/uk/LC_MESSAGES; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/cs/LC_MESSAGES/OpenWebif.mo locale/cs.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/de/LC_MESSAGES/OpenWebif.mo locale/de.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/el/LC_MESSAGES/OpenWebif.mo locale/el.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/nl/LC_MESSAGES/OpenWebif.mo locale/nl.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/pl/LC_MESSAGES/OpenWebif.mo locale/pl.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/uk/LC_MESSAGES/OpenWebif.mo locale/uk.po
	$(REMOVE)/e2openplugin-OpenWebif
	$(TOUCH)

#
# enigma2-networkbrowser
#
ENIGMA2_NETWORBROWSER_PATCH = enigma2-networkbrowser-support-autofs.patch

$(D)/enigma2_networkbrowser: $(D)/bootstrap $(D)/python
	$(START_BUILD)
	$(REMOVE)/enigma2-networkbrowser
	$(SILENT)if [ -d $(ARCHIVE)/enigma2-plugins.git ]; \
		then cd $(ARCHIVE)/enigma2-plugins.git; git pull $(SILENT_CONFIGURE); \
		else cd $(ARCHIVE); git clone $(SILENT_CONFIGURE) https://github.com/OpenPLi/enigma2-plugins.git enigma2-plugins.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/enigma2-plugins.git/networkbrowser/ $(BUILD_TMP)/enigma2-networkbrowser
	$(SET) -e; cd $(BUILD_TMP)/enigma2-networkbrowser; \
		$(call apply_patches,$(ENIGMA2_NETWORBROWSER_PATCH))
	$(SET) -e; cd $(BUILD_TMP)/enigma2-networkbrowser/src/lib; \
		$(BUILDENV) \
		sh4-linux-gcc -shared -o netscan.so \
			-I $(TARGET_DIR)/usr/include/python$(PYTHON_VER_MAJOR) \
			-include Python.h \
			errors.h \
			list.c \
			list.h \
			main.c \
			nbtscan.c \
			nbtscan.h \
			range.c \
			range.h \
			showmount.c \
			showmount.h \
			smb.h \
			smbinfo.c \
			smbinfo.h \
			statusq.c \
			statusq.h \
			time_compat.h
	$(SET) -e; cd $(BUILD_TMP)/enigma2-networkbrowser; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser; \
		cp -a po $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/; \
		cp -a meta $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/; \
		cp -a src/* $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/; \
		cp -a src/lib/netscan.so $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/; \
		python -O -m compileall $(SILENT_OPT) $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/lib; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/Makefile.am; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/icons/Makefile.am; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/meta/Makefile.am; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/po/Makefile.am
	$(REMOVE)/enigma2-networkbrowser
	$(TOUCH)

#
# enigma2-servicemp3
#
SERVICEMP3_VER       = 0.1
SERVICEMP3_DEPS      = $(D)/bootstrap $(D)/enigma2
SERVICEMP3_CPPFLAGS  = -std=c++11
SERVICEMP3_CPPFLAGS += -I$(TARGET_DIR)/usr/include/python$(PYTHON_VER_MAJOR)
SERVICEMP3_CPPFLAGS += -I$(SOURCE_DIR)/enigma2
SERVICEMP3_CPPFLAGS += -I$(SOURCE_DIR)/enigma2/include
SERVICEMP3_CPPFLAGS += -I$(KERNEL_DIR)/include
ifeq ($(MEDIAFW), eplayer3)
SERVICEMP3_DEPS     += $(D)/tools-eplayer3
SERVICEMP3_CPPFLAGS += -L$(APPS_DIR)/tools/eplayer3
SERVICEMP3_CONF     += --enable-libeplayer3
endif

ifeq ($(MEDIAFW), gstreamer)
SERVICEMP3_DEPS    += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly $(D)/gst_plugins_dvbmediasink
SERVICEMP3_CONF    += --enable-mediafwgstreamer
SERVICEMP3_CONF    += --with-gstversion=1.0
endif

ifeq ($(MEDIAFW), gst-eplayer3)
SERVICEMP3_DEPS    += $(D)/tools-libeplayer3
SERVICEMP3_DEPS    += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly $(D)/gst_plugins_dvbmediasink
SERVICEMP3_CONF    += --enable-libeplayer3
SERVICEMP3_CONF    += --enable-mediafwgstreamer
SERVICEMP3_CONF    += --with-gstversion=1.0
endif
SERVICEMP3_PATCH = enigma2-servicemp3-$(SERVICEMP3_VER).patch

$(D)/enigma2_servicemp3: | $(SERVICEMP3_DEPS)
	$(START_BUILD)
	$(REMOVE)/enigma2-servicemp3-$(SERVICEMP3_VER)
	$(SILENT)if [ -d $(ARCHIVE)/enigma2-servicemp3-$(SERVICEMP3_VER).git ]; \
		then cd $(ARCHIVE)/enigma2-servicemp3-$(SERVICEMP3_VER).git; git pull $(SILENT_CONFIGURE); \
		else cd $(ARCHIVE); git clone $(SILENT_CONFIGURE) https://github.com/OpenPLi/servicemp3.git enigma2-servicemp3-$(SERVICEMP3_VER).git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/enigma2-servicemp3-$(SERVICEMP3_VER).git/ $(BUILD_TMP)/enigma2-servicemp3-$(SERVICEMP3_VER)
	$(SET) -e; cd $(BUILD_TMP)/enigma2-servicemp3-$(SERVICEMP3_VER); \
		$(call apply_patches,$(SERVICEMP3_PATCH)); \
		./autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			$(SERVICEMP3_CONF) \
			CPPFLAGS="$(SERVICEMP3_CPPFLAGS)" \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/enigma2-servicemp3-$(SERVICEMP3_VER)
	$(TOUCH)

#
# enigma2-servicemp3epl
#
SERVICEMP3EPL_VER       = 0.1
SERVICEMP3EPL_DEPS      = $(D)/bootstrap $(D)/enigma2
SERVICEMP3EPL_CPPFLAGS  = -std=c++11
SERVICEMP3EPL_CPPFLAGS += -I$(TARGET_DIR)/usr/include/python$(PYTHON_VER_MAJOR)
SERVICEMP3EPL_CPPFLAGS += -I$(SOURCE_DIR)/enigma2
SERVICEMP3EPL_CPPFLAGS += -I$(SOURCE_DIR)/enigma2/include
SERVICEMP3EPL_CPPFLAGS += -I$(KERNEL_DIR)/include
ifeq ($(MEDIAFW), eplayer3)
SERVICEMP3EPL_DEPS     += $(D)/tools-eplayer3
SERVICEMP3EPL_CPPFLAGS += -L$(APPS_DIR)/tools/eplayer3
SERVICEMP3EPL_CONF     += --enable-libeplayer3
endif

ifeq ($(MEDIAFW), gstreamer)
SERVICEMP3EPL_DEPS    += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly $(D)/gst_plugins_dvbmediasink
SERVICEMP3EPL_CONF    += --enable-gstreamer
SERVICEMP3EPL_CONF    += --with-gstversion=1.0
endif

ifeq ($(MEDIAFW), gst-eplayer3)
SERVICEMP3EPL_DEPS    += $(D)/tools-libeplayer3
SERVICEMP3EPL_DEPS    += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly $(D)/gst_plugins_dvbmediasink
SERVICEMP3EPL_CONF    += --enable-libeplayer3
SERVICEMP3EPL_CONF    += --enable-gstreamer
SERVICEMP3EPL_CONF    += --with-gstversion=1.0
endif
SERVICEMP3EPL_PATCH = enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).patch

$(D)/enigma2_servicemp3epl: | $(SERVICEMP3EPL_DEPS)
	$(START_BUILD)
	$(REMOVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER)
	$(SILENT)if [ -d $(ARCHIVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).git ]; \
		then cd $(ARCHIVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).git; git pull $(SILENT_CONFIGURE); \
		else cd $(ARCHIVE); git clone $(SILENT_CONFIGURE) https://github.com/PLi-metas/servicemp3epl.git enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).git/ $(BUILD_TMP)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER)
	$(SET) -e; cd $(BUILD_TMP)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER); \
		$(call apply_patches,$(SERVICEMP3EPL_PATCH)); \
		./autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			$(SERVICEMP3EPL_CONF) \
			CPPFLAGS="$(SERVICEMP3EPL_CPPFLAGS)" \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER)
	$(TOUCH)

