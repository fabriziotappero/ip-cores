# -------------------------------------------------
# Project created by QtCreator 2009-06-09T13:45:02
# -------------------------------------------------
QT     += svg
TARGET = rvioscilloscope
TEMPLATE = app
SOURCES += main.cpp \
    rvioscilloscope.cpp \
    data_plot.cpp \
    rviboardtools.cpp  \
    rvicommthread.cpp
HEADERS += data_plot.h \
    rvioscilloscope.h \
    rviboardtools.h  \
    rvicommthread.h
FORMS += rvioscilloscope.ui \
    rviboardtools.ui
TRANSLATIONS    = superapp_es.ts
win32 { 
    SOURCES += include/epp_parallel_use_win.cpp \
        include/epp_parallel_access_win.cpp
    HEADERS += include/epp_parallel_use_win.h \
        include/epp_parallel_access_win.h
}
RESOURCES += rviboardtools.qrc

# -------------------------------------------------
# definitions
VER_MAJ = 5
win32:QWT_ROOT = "C:\Qwt-5.3.0-svn"
win32:DEBUG_SUFFIX = d
RELEASE_SUFFIX =
DEPENDPATH += C:\Qwt-5.3.0-svn\include
INCLUDEPATH += C:\Qwt-5.3.0-svn\include

# VVERSION = $$[QT_VERSION]
CONFIG(debug, debug|release):SUFFIX_STR = $${DEBUG_SUFFIX}
else:SUFFIX_STR = $${RELEASE_SUFFIX}
QWTLIB = qwt$${SUFFIX_STR}
unix { 
    # Qt 4
    DEPENDPATH += /usr/include/qwt-qt4
    INCLUDEPATH += /usr/include/qwt-qt4
    LIBS += -L$${QWT_ROOT}/lib \
        -l$${QWTLIB}-qt4
}
win32 { 
    DEFINES += QWT_DLL \
        QT_DLL
    QWTLIB = $${QWTLIB}$${VER_MAJ}
    LIBS += -L$${QWT_ROOT}/lib \
        -l$${QWTLIB}
}
OTHER_FILES += 
