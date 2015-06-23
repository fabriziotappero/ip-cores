TEMPLATE = app
CONFIG += console
CONFIG -= qt
LIBS +=  `freetype-config --libs` -lfreetype
CCFLAG += `freetype-config --cflags`
INCLUDEPATH += /usr/include/freetype2

SOURCES += main.cpp \
    ttfpoint.cpp \
    poly2tri/sweep/sweep_context.cc \
    poly2tri/sweep/sweep.cc \
    poly2tri/sweep/cdt.cc \
    poly2tri/sweep/advancing_front.cc \
    poly2tri/common/shapes.cc

HEADERS += \
    ttfpoint.h \
    poly2tri/sweep/sweep_context.h \
    poly2tri/sweep/sweep.h \
    poly2tri/sweep/cdt.h \
    poly2tri/sweep/advancing_front.h \
    poly2tri/common/utils.h \
    poly2tri/common/shapes.h

