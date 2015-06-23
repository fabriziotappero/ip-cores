
INCLUDES = @GTK_CFLAGS@
LDADD = @GTK_LIBS@
AM_CFLAGS=-ggdb -Wall -DPKGDATADIR=\"$(pkgdatadir)\"

bin_PROGRAMS = connectk
connectk_SOURCES = \
	src/connectk.c\
	src/draw.c\
	src/file.c\
	src/state.c\
	src/dialogs.c\
	src/tests.c\
	src/connectk.h\
	src/shared.h\
	src/ai/ai.c\
	src/ai/thread.c\
	src/ai/search.c\
	src/ai/sequences.c\
	src/ai/montec.c\
	src/ai/window.c\
	src/ai/threats.c\
	src/ai/mesh.c

EXTRA_DIST = win32
