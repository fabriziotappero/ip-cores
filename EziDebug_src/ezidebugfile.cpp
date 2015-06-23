#include <QFile>
#include <QMap>
#include <QDateTime>

#include "ezidebugfile.h"
#include <QDebug>


//QString EziDebugFile::m_icreatedRelativeDir(tr("No Dir"));
EziDebugFile::EziDebugFile(const QString &filename):QFile(filename)
{
    m_isLibrary = false ;
}

EziDebugFile::EziDebugFile(const QString &filename,const QDateTime &datetime,const QStringList &modulelist)
    :QFile(filename),m_iUpdateTime(datetime),m_iModuleList(modulelist)
{
    m_isLibrary = false ;
}

EziDebugFile::~EziDebugFile()
{

}

void EziDebugFile::addToFileModuleMap(QString modulename , EziDebugModule* moduleobj)
{
    return ;
}

void EziDebugFile::addToPrjModuleMap(QString modulename , EziDebugModule* moduleobj)
{

    return ;
}

void EziDebugFile::deleteFromFileModuleMap(QString modulename , EziDebugModule* moduleobj)
{
    return ;
}

void EziDebugFile::deleteFromPrjModuleMap(QString modulename , EziDebugModule* moduleobj)
{
    return ;
}

int EziDebugFile::deleteEziDebugCode()
{
    return 0 ;
}

bool EziDebugFile::isExistEziDebugCode() const
{

    return 0 ;
}

const QDateTime& EziDebugFile::getLastStoredTime() const
{
    return m_iUpdateTime;
}

void  EziDebugFile::modifyStoredTime(const QDateTime &datetime)
{
    m_iUpdateTime =  datetime ;
    return ;
}

bool  EziDebugFile::isModifedRecently(void)
{
    QFileInfo ifileInfo(fileName());
    QDateTime idateTime = ifileInfo.lastModified() ;
    if(idateTime != m_iUpdateTime)
    {
        return true ;
    }
    else
    {
        return false ;
    }
}

void  EziDebugFile::addToModuleList(const QString& modulename)
{
    m_iModuleList << modulename ;
    return ;
}

void  EziDebugFile::clearModuleList(void)
{
    m_iModuleList.clear();
    return ;
}




const QStringList &EziDebugFile::getModuleList() const
{
    return m_iModuleList ;
}

void EziDebugFile::deleteScanChain(EziDebugInstanceTreeItem* item)
{
    /*判断是不是topmodule所在文件删除链*/
    /*根据代码信息 分别删除*/
    /*不确认的代码需要提示用户*/
    return  ;
}

void EziDebugFile::addScanChain(EziDebugInstanceTreeItem* item)
{
    /*判断是不是topmodule所在文件添加链*/
    return ;
}

int EziDebugFile::scanFile(EziDebugPrj* prj,EziDebugPrj::SCAN_TYPE type)
{

    return 0 ;
}

int EziDebugFile::caculateExpression(QString)
{
    return 0 ;
}

bool EziDebugFile::isLibaryFile()
{
    //qDebug()<< "the parent object do nothing!";

    return m_isLibrary ;
}

void EziDebugFile::setLibaryFlag(bool flag)
{
    m_isLibrary = flag ;
}

/*
const QString& EziDebugFile::getCreatedRelavieDir(void)
{
    return m_icreatedRelativeDir ;
}
*/


