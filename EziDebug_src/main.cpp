/****************************************************************************
**
** Copyright (C) 2012.
** All rights reserved.
**
****************************************************************************/

#include <QApplication>
#include <QtGui>


#include "toolwindow.h"
//#include "miniwindow.h"
//#include "projectsetwizard.h"
//#include "listwindow.h"


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QString sPath = app.applicationDirPath();
    sPath += QString("/plugins");
    app.addLibraryPath(sPath);

    QString translatorFileName = QLatin1String("qt_");
    translatorFileName += QLocale::system().name();
    QTranslator *translator = new QTranslator(&app);
    if (translator->load(translatorFileName, QLibraryInfo::location(QLibraryInfo::TranslationsPath)))
        app.installTranslator(translator);

    ToolWindow dialog ;
    dialog.show();
    dialog.listwindowInfoInit();


//    TitleBar * aa = new TitleBar ;
//    aa->show();

//    ProjectSetWizard wizard;
//    wizard.show();

//    MiniWindow miniw;
//    miniw.show();

//    ListWindow listw/*(QApplication app)*/;
//    listw.show();

//    TitleBar t;
//    t.show();

//    QDockWidget aa();
//    aa.topLevelChanged(true);
//    aa.show();



    return app.exec();
}


