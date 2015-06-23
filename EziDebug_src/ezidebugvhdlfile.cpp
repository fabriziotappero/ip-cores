#include "ezidebugfile.h"
#include "ezidebugvhdlfile.h"
#include <QDebug>

EziDebugVhdlFile::EziDebugVhdlFile(const QString &filename):EziDebugFile(filename)
{

}

EziDebugVhdlFile::EziDebugVhdlFile(const QString &filename,const QDateTime &datetime,const QStringList &modulelist)\
    :EziDebugFile(filename,datetime,modulelist)
{

}


EziDebugVhdlFile::~EziDebugVhdlFile()
{

}

void EziDebugVhdlFile::deleteScanChain(const QStringList &ideletecodelist)
{

}

void EziDebugVhdlFile::addScanChain(EziDebugInstanceTreeItem* item)
{

}

int EziDebugVhdlFile::scanFile(EziDebugPrj* prj,EziDebugPrj::SCAN_TYPE type)
{
    /*调用倪茂实现的类*/
    qDebug() << "vhdl scanfile!";
    return 0 ;
}

int EziDebugVhdlFile::caculateExpression(QString string)
{
    return 0 ;
}

#if 0
bool EziDebugVhdlFile::isLibaryFile()
{
    /*调用倪茂写的类实现*/
    return 0 ;
}
#endif
