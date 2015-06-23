#-------------------------------------------------
#
# Project created by QtCreator 2012-08-31T11:43:35
#
#-------------------------------------------------

QT       += core gui

DESTDIR = ../target
TARGET = CCITT4_client
TEMPLATE = app

INCLUDEPATH = ../src/GUI \
        ../src/Kernel \
        ../src/Includes \
        ../src/Libs

SOURCES += ../src/main.cpp \
                ../src/GUI/CCITT4Client.cpp \
                ../src/Kernel/CDevice.cpp \
                ../src/Kernel/CDeviceState.cpp \
                ../src/Kernel/CSerialportDevice.cpp \
    ../src/GUI/CMyGraphicsView.cpp \
    ../src/Kernel/CSerialport.cpp \
    ../src/GUI/PortSelectionDialog.cpp \
    ../src/Libs/CPathLib.cpp

HEADERS += ../src/GUI/CCITT4Client.h \
                ../src/Kernel/CDevice.h \
                ../src/Kernel/CDeviceState.h \
                ../src/Kernel/CSerialportDevice.h \
    ../src/GUI/CMyGraphicsView.h \
    ../src/Kernel/CSerialport.h \
	../src/GUI/PortSelectionDialog.h \
    ../src/Libs/CPathLib.h

FORMS   += ../src/GUI/CCITT4Client.ui \
    ../src/GUI/PortSelectionDialog.ui

Debug:OBJECTS_DIR = ../debug/.obj
Release:OBJECTS_DIR = ../release/.obj

RESOURCES += \
    ../resources/CCITT4Client.qrc

DEFINES += QT
