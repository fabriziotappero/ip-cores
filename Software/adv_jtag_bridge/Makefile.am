AUTOMAKE_OPTIONS = foreign

# Without the ACLOCAL_AMFLAGS line below, you get this warning:
#   libtoolize: Consider adding `-I m4' to ACLOCAL_AMFLAGS in Makefile.am.
# However, with it, autoreconf does not work if you don't manually create
# the m4 subdirectory beforehand, even if you add the --install flag here.
# I have tested with autoconf 2.65 and automake 1.11.1 .
#   ACLOCAL_AMFLAGS = -I m4

bin_PROGRAMS = adv_jtag_bridge

adv_jtag_bridge_CPPFLAGS =

my_headers = \
  adv_dbg_commands.h  \
  cable_common.h \
  cable_usbblaster.h \
  except.h \
  opencores_tap.h \
  adv_jtag_bridge.h \
  cable_xpc_dlc9.h \
  hardware_monitor.h \
  or32_selftest.h \
  altera_virtual_jtag.h \
  chain_commands.h \
  hwp_server.h \
  rsp-server.h \
  bsdl.h \
  dbg_api.h \
  jsp_server.h \
  spr-defs.h \
  bsdl_parse.h \
  cable_sim.h \
  errcodes.h \
  legacy_dbg_commands.h \
  utilities.h

adv_jtag_bridge_SOURCES = \
  $(my_headers) \
  adv_jtag_bridge.c \
  rsp-server.c \
  chain_commands.c \
  cable_common.c bsdl.c \
  or32_selftest.c \
  cable_sim.c \
  utilities.c \
  bsdl_parse.c \
  errcodes.c \
  adv_dbg_commands.c \
  dbg_api.c \
  legacy_dbg_commands.c \
  hardware_monitor.c \
  hwp_server.c

adv_jtag_bridge_LDFLAGS = -lpthread -lrt


if SUPPORT_PARALLEL_CABLES
  adv_jtag_bridge_CPPFLAGS += -D__SUPPORT_PARALLEL_CABLES__
  adv_jtag_bridge_SOURCES  += cable_parallel.h cable_parallel.c
endif

if SUPPORT_FTDI_CABLES
  adv_jtag_bridge_CPPFLAGS += -D__SUPPORT_FTDI_CABLES__
  adv_jtag_bridge_LDFLAGS  += -lftdi
  adv_jtag_bridge_SOURCES  += cable_ft2232.h cable_ft245.h cable_ft2232.c cable_ft245.c
endif

# Must come after SUPPORT_FTDI_CABLES, see below.
if SUPPORT_USB_CABLES
  adv_jtag_bridge_CPPFLAGS += -D__SUPPORT_USB_CABLES__
  adv_jtag_bridge_SOURCES  += cable_xpc_dlc9.h cable_usbblaster.h cable_xpc_dlc9.c cable_usbblaster.c
  # libusb must follow libftdi in the list of libraries
  adv_jtag_bridge_LDFLAGS  += -lusb
endif

if INCLUDE_JSP_SERVER
  adv_jtag_bridge_CPPFLAGS += -DENABLE_JSP
  adv_jtag_bridge_SOURCES  += jsp_server.h jsp_server.c
endif
