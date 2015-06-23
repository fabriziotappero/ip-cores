/*
 * @file     main.cpp
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#if QT_MAJOR_VERSION == 4
#include <QtGui/QApplication>
#else
#include <QApplication>
#endif

#include "CCITT4Client.h"

int main(int argc, char *argv[])
{
    CCCITT4Client *pApp;

    QApplication a(argc, argv);

    if(argc > 1)
    {
        pApp = new CCCITT4Client(NULL, QString(argv[1]));
    }
    else
    {
        pApp = new CCCITT4Client();
    }

    pApp->show();
    
    return a.exec();
}
