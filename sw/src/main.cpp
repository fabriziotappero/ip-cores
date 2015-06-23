#include <QtGui/QApplication>
#include "rvioscilloscope.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    RVIOscilloscope w;
    w.show();
    return a.exec();
}
