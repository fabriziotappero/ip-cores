#include <QString>
#include <QDir>
#include <QMap>
#include <QStringList>
#include <QXmlStreamReader>
#include <QtXml>
#include <QFileInfo>
#include <string.h>
#include <QMessageBox>
#include <QDebug>


#include "UpdateDetectThread.h"
#include "ezidebugprj.h"
#include "ezidebugmodule.h"
#include "ezidebugvlgfile.h"
#include "ezidebugvhdlfile.h"
#include "ezidebugscanchain.h"
#include "ezidebuginstancetreeitem.h"
#include <algorithm>


char *month[13] = {"", "Jan" ,"Feb" , "Mar" , "Apr" , "May" , "Jun" , "Jul" , "Aug" , "Sep" \
                    "Oct" , "Nov" , "Dec" } ;


char *day[8] = {"", "Mon" , "Tue" , "Wed" , "Thu" , "Fri" , "Sat" , "Sun"} ;





EziDebugPrj::EziDebugPrj(int maxregnum , QString projectdir , TOOL tool , QObject * parent)\
    : QObject(parent) ,m_iprjPath(QDir(projectdir)),m_nmaxRegNumInChain(maxregnum),m_eusedTool(tool)
{
    m_pthread  = new UpdateDetectThread(this,NULL);
    m_headItem = NULL ;
    m_pLastOperateChain = NULL ;
    m_pLastOperteTreeItem = NULL ;
    m_elastOperation = OperateTypeNone ;
    m_isLogFileExist = false ;
    m_ipermettedMaxRegNum = 0 ;
    m_imaxRegWidth = 0 ;
    m_isUpdated = false ;
    m_isLogFileDestroyed = false ;
}

EziDebugPrj::~EziDebugPrj()
{
    // 注::工程指针 析构时 其他对象不能使用
    qDebug() << "Attention : Begin to destruct EziDebugPrj object!";

    if(m_pthread->isRunning())
    {
        m_pthread->quit();
        m_pthread->wait();
    }
    delete m_pthread ;

    if(EziDebugScanChain::getUserDir().toLower() != "no dir")
    {
        QDir idir(m_iprjPath.absolutePath() + EziDebugScanChain::getUserDir());

        idir.setFilter(QDir::Files);
        QFileInfoList iinfolist = idir.entryInfoList();
        for(int i = 0; i < iinfolist.size(); ++i)
        {
            QFileInfo fileInfo = iinfolist.at(i);
            QString ifileName = fileInfo.fileName() ;
            if(!(fileInfo.fileName().endsWith(".v")||fileInfo.fileName().endsWith(".vhd")))
            {
                idir.remove(ifileName);
            }
        }
    }

    // verilog file 指针析构
    QMap<QString,EziDebugVlgFile*>::iterator i =  m_ivlgFileMap.begin() ;
    while(i != m_ivlgFileMap.end())
    {
       EziDebugVlgFile* pfile = m_ivlgFileMap.value(i.key());
       if(pfile)
       {
           delete pfile ;
       }
       ++i ;
    }
    m_ivlgFileMap.clear() ;

    // vhdl file 指针析构
    QMap<QString,EziDebugVhdlFile*>::iterator j =  m_ivhdlFileMap.begin() ;
    while(j != m_ivhdlFileMap.end())
    {
       EziDebugVhdlFile* pfile = m_ivhdlFileMap.value(j.key());
       if(pfile)
       {
           delete pfile ;
       }
       ++j ;
    }
    m_ivhdlFileMap.clear() ;

    // module 析构
    QMap<QString,EziDebugModule*>::iterator k =  m_imoduleMap.begin() ;
    while(k != m_imoduleMap.end())
    {
       EziDebugModule* pmodule = m_imoduleMap.value(k.key());
       if(pmodule)
       {
           delete pmodule ;
       }
       ++k ;
    }
    m_imoduleMap.clear() ;


    // treeitemmap 析构
//    QMap<QString,EziDebugInstanceTreeItem*>::iterator itreeItemIterator =  m_ichainTreeItemMap.begin() ;
//    while(itreeItemIterator != m_ichainTreeItemMap.end())
//    {
//       EziDebugInstanceTreeItem* pitem = m_ichainTreeItemMap.value(itreeItemIterator.key());
//       if(!pitem)
//       {
//           delete pitem ;
//       }
//       ++itreeItemIterator ;
//    }
    m_ichainTreeItemMap.clear() ;

    // backup TreeItemMap 析构
//    QMap<QString,EziDebugInstanceTreeItem*>::iterator ibakTreeItemIterator =  m_ibackupChainTreeItemMap.begin() ;
//    while(ibakTreeItemIterator != m_ibackupChainTreeItemMap.end())
//    {
//       EziDebugInstanceTreeItem* pitem = m_ibackupChainTreeItemMap.value(ibakTreeItemIterator.key());
//       if(!pitem)
//       {
//           delete pitem ;
//       }
//       ++ibakTreeItemIterator ;
//    }
    m_ibackupChainTreeItemMap.clear() ;

    // m_ichainInfoMap 析构
    QMap<QString,EziDebugScanChain*>::iterator ichainIterator =  m_ichainInfoMap.begin() ;
    while(ichainIterator != m_ichainInfoMap.end())
    {
        // LastOperateChain 析构
       EziDebugScanChain* pitem = m_ichainInfoMap.value(ichainIterator.key());
       if(pitem)
       {
           if(pitem == m_pLastOperateChain)
           {
               m_pLastOperateChain = NULL ;
           }
           delete pitem ;
       }
       ++ichainIterator ;
    }
    m_ichainInfoMap.clear() ;

    // backupchaininfo 析构
    QMap<QString,EziDebugScanChain*>::iterator ibakChainIterator =  m_ibackupChainInfoMap.begin() ;
    while(ibakChainIterator != m_ibackupChainInfoMap.end())
    {
       EziDebugScanChain* pitem = m_ibackupChainInfoMap.value(ibakChainIterator.key());
       if(pitem)
       {
           delete pitem ;
       }
       ++ibakChainIterator ;
    }

    m_ibackupChainInfoMap.clear() ;

    m_iqueryTreeItemMap.clear();
    m_ibackupQueryTreeItemMap.clear();

    if(m_pLastOperateChain)
        delete m_pLastOperateChain ;

    // LastOperteTreeItem 析构
//    if(!m_pLastOperteTreeItem)
    m_pLastOperteTreeItem = NULL ;

}


const EziDebugPrj::TOOL &EziDebugPrj::getToolType(void) const
{
    return  m_eusedTool ;
}

const QDir &EziDebugPrj::getCurrentDir(void) const
{
    return m_iprjPath ;
}

bool EziDebugPrj::getSoftwareXilinxErrCheckedFlag(void)
{
    return m_isDisXilinxErrChecked ;
}
QString EziDebugPrj::getTopModule(void)
{
    return m_itopModule ;
}

UpdateDetectThread *EziDebugPrj::getThread(void) const
{
    return m_pthread ;
}

bool EziDebugPrj::getLogFileExistFlag(void)
{
    return m_isLogFileExist ;
}

const QMap<QString,EziDebugScanChain*> &EziDebugPrj::getScanChainInfo(void) const
{
    return m_ichainInfoMap ;
}

const QMap<QString,EziDebugInstanceTreeItem*> &EziDebugPrj::getChainTreeItemMap(void) const
{
    return m_ichainTreeItemMap ;
}

const QMap<QString,EziDebugInstanceTreeItem*> &EziDebugPrj::getBackupChainTreeItemMap(void) const
{
   return m_ibackupChainTreeItemMap ;
}

const QMap<QString,EziDebugScanChain*> &EziDebugPrj::getBackupChainMap(void) const
{
   return m_ibackupChainInfoMap ;
}

const QStringList &EziDebugPrj::getPrjCodeFileNameList(void) const
{
    return m_iCodefileNameList ;
}

const QStringList &EziDebugPrj::getUpdateFileList(FILE_UPDATE_TYPE fileupdatetype) const
{
    if(fileupdatetype == addedUpdateFileType)
    {
        return m_iupdateAddedFileList ;
    }
    else if(fileupdatetype == deletedUpdateFileType)
    {
        return m_iupdateDeletedFileList ;
    }
    else
    {
        return m_iupdateChangedFileList ;
    }
}
const QStringList &EziDebugPrj::getFileNameList(void) const
{
    return m_iCodefileNameList ;
}

const QString &EziDebugPrj::getPrjName(void) const
{
    return  m_iprjName ;
}

EziDebugPrj::OPERATE_TYPE EziDebugPrj::getLastOperation(void)
{
    return m_elastOperation ;
}

int EziDebugPrj::getPermittedRegNum(void)
{
    return m_ipermettedMaxRegNum ;
}

EziDebugScanChain* EziDebugPrj::getLastOperateChain(void)
{
    return m_pLastOperateChain ;
}

int EziDebugPrj::eliminateLastOperation(void)
{
    QString ieziDebugFileSuffix ;

    /*对上一步操作进行善后*/
    if(m_elastOperation == OperateTypeAddScanChain)
    {
        if(!m_pLastOperateChain)
        {
            qDebug() << "Error:Last Operation chain is NULL Pointer!";
            return 1 ;
        }
        ieziDebugFileSuffix = QObject::tr(".add.%1").arg(m_pLastOperateChain->getChainName());
        QStringList iscanFileList = m_pLastOperateChain->getScanedFileList() ;
        for(int i = 0 ; i < iscanFileList.count();i++)
        {
            // 获取备份的文件名全称
            QFileInfo ifileInfo(iscanFileList.at(i));



            QString ibackupFileName = m_iprjPath.absolutePath() \
                    + EziDebugScanChain::getUserDir() + QObject::tr("/") + ifileInfo.fileName() \
                    + ieziDebugFileSuffix;
            QFile ibackupFile(ibackupFileName) ;

            // 删除上一步操作备份的文件
            ibackupFile.remove();
        }
        // 清空所有上次备份
        m_elastOperation = OperateTypeNone ;
        m_pLastOperateChain = NULL ;
        m_pLastOperteTreeItem = NULL ;
    }
    else if(m_elastOperation == OperateTypeDelSingleScanChain)
    {
        // 释放
        if(!m_pLastOperateChain)
        {
            qDebug() << "Error:Last Operation chain is NULL Pointer!";
            return 1 ;
        }
        ieziDebugFileSuffix = QObject::tr(".delete.%1").arg(m_pLastOperateChain->getChainName());

        QStringList iscanFileList = m_pLastOperateChain->getScanedFileList() ;
        for(int i = 0 ; i < iscanFileList.count();i++)
        {
            // 获取备份的文件名全称
            QFileInfo ifileInfo(iscanFileList.at(i));



            QString ibackupFileName = m_iprjPath.absolutePath() \
                    + EziDebugScanChain::getUserDir() + QObject::tr("/") + ifileInfo.fileName() \
                    + ieziDebugFileSuffix ;
            QFile ibackupFile(ibackupFileName) ;

            // 删除上一步操作备份的文件
            ibackupFile.remove();
        }

        delete m_pLastOperateChain ;
        // 清空所有上次备份
        //updateOperation(OperateTypeNone , NULL , NULL);
        m_elastOperation = OperateTypeNone ;
        m_pLastOperateChain = NULL ;
        m_pLastOperteTreeItem = NULL ;
    }
    else if(m_elastOperation == OperateTypeDelAllScanChain)
    {
        ieziDebugFileSuffix = QObject::tr(".deleteall");

        // 将所有 扫描立链指针内存 释放
        QMap<QString,EziDebugScanChain*>::const_iterator i = m_ibackupChainInfoMap.constBegin() ;
        while(i !=  m_ibackupChainInfoMap.constEnd())
        {
           EziDebugScanChain* pchain =  i.value();
           if(!pchain)
           {
               qDebug() << "Error: The chain Pointer is NULL !";
               ++i ;
               continue ;
           }

           QStringList iscanFileList = pchain->getScanedFileList() ;
           for(int j = 0 ; j < iscanFileList.count();j++)
           {
               // 获取备份的文件名全称
               QFileInfo ifileInfo(iscanFileList.at(j));

               QString ibackupFileName = m_iprjPath.absolutePath() \
                       + EziDebugScanChain::getUserDir()+ QObject::tr("/") +ifileInfo.fileName() \
                       + ieziDebugFileSuffix ;
               QFile ibackupFile(ibackupFileName) ;

               // 删除上一步操作备份的文件
               ibackupFile.remove();
           }

           delete pchain ;
           pchain = NULL ;
           ++i ;
        }
        // 清空所有上次备份
        updateOperation(OperateTypeNone , NULL , NULL);
    }
    else if(m_elastOperation == OperateTypeNone)
    {
        return 0 ;
    }
    else
    {
        qDebug() << "Error:Last Operation Type is Wrong!";
        return 1 ;
    }

    return 0 ;

}

EziDebugInstanceTreeItem* EziDebugPrj::getLastOperateTreeItem(void)
{
    return  m_pLastOperteTreeItem ;
}

const QMap<QString,EziDebugModule*> &EziDebugPrj::getPrjModuleMap(void) const
{
    return m_imoduleMap ;
}

const QMap<QString,EziDebugVlgFile*> &EziDebugPrj::getPrjVlgFileMap(void) const
{
    return m_ivlgFileMap ;
}

const QMap<QString,EziDebugVhdlFile*> &EziDebugPrj::getPrjVhdlFileMap(void) const
{
    return m_ivhdlFileMap ;
}

int  EziDebugPrj::eliminateFile(const QString &filename,QList<LOG_FILE_INFO*> &infolist)
{
    if(filename.endsWith(".v"))
    {
        EziDebugVlgFile* pfile = m_ivlgFileMap.value(filename);
        if(pfile)
        {
            struct LOG_FILE_INFO* pinfo = new LOG_FILE_INFO ;
            pinfo->etype = infoTypeFileInfo ;
            pinfo->pinfo = NULL ;
            memcpy(pinfo->ainfoName,pfile->fileName().toAscii().data(),pfile->fileName().size()+1);
            infolist.append(pinfo);
            QStringList imoduleList = pfile->getModuleList();
            for(int i = 0 ; i < imoduleList.count();i++)
            {
                EziDebugModule *pmodule = m_imoduleMap.value(imoduleList.at(i),NULL) ;
                if(!pmodule)
                {
                    struct LOG_FILE_INFO* pinfo = new LOG_FILE_INFO ;
                    pinfo->etype = infoTypeModuleStructure ;
                    pinfo->pinfo = NULL ;
                    memcpy(pinfo->ainfoName,pmodule->getModuleName().toAscii().data(),pmodule->getModuleName().size()+1);
                    infolist.append(pinfo);
                }
                m_imoduleMap.remove(imoduleList.at(i));
                delete pmodule ;
            }
        }
        m_ivlgFileMap.remove(filename);
        delete pfile ;
    }
    else if(filename.endsWith(".vhd"))
    {
        EziDebugVhdlFile* pfile = m_ivhdlFileMap.value(filename);
        if(!pfile)
            delete pfile ;
        m_ivhdlFileMap.remove(filename);
    }
    else
    {
        return 1 ;
    }
    return 0 ;
}

int  EziDebugPrj::addFile(const QString &filename ,SCAN_TYPE type,QList<LOG_FILE_INFO*> &infolist)
{
    QList<LOG_FILE_INFO*> ideletedinfoList ;
    if(filename.endsWith(".v"))
    {
        QFileInfo ifileInfo(m_iprjPath,filename);
        EziDebugVlgFile* pfile = new EziDebugVlgFile(ifileInfo.absoluteDir().absolutePath() + QObject::tr("'/") + ifileInfo.fileName()) ;
        if(!pfile->scanFile(this,type,infolist,ideletedinfoList))
        {
            m_ivlgFileMap.insert(filename,pfile) ;
        }
        else
        {
            // 删除所有 list 节点
            return  1 ;
        }
    }
    else if(filename.endsWith(".vhd"))
    {
//        EziDebugVhdlFile* pfile = new EziDebugVhdlFile(filename) ;
//        if(!pfile->scanFile(this,type))
//        {
//             m_ivhdlFileMap.insert(filename,pfile);
//        }
//        else
//        {

//        }
    }
    else
    {
        return 1 ;
    }

    return 0 ;
}

void  EziDebugPrj::addToModuleMap(const QString &modoule,EziDebugModule *pmodule)
{
    EziDebugModule *poriginModule  = m_imoduleMap.value(modoule,NULL) ;
	
    if(!poriginModule)
    {
        m_imoduleMap.insert(modoule,pmodule);
    }
    else
    {
        qDebug() << "Info: There is already existing this module:" << modoule \
                 << "Ready to delete it!";
        m_imoduleMap.remove(modoule) ;
        delete poriginModule ;
        m_imoduleMap.insert(modoule,pmodule);
    }
    return ;
}

void  EziDebugPrj::addToDestroyedChainList(const QString& chainname)
{
    if(!m_idestroyedChain.contains(chainname))
    {
        m_idestroyedChain.append(chainname);
    }
}

void  EziDebugPrj::addToCheckedChainList(const QString& chainname)
{
    if(!m_icheckedChain.contains(chainname))
    {
        m_icheckedChain.append(chainname);
    }
}

void  EziDebugPrj::clearupDestroyedChainList(void)
{
    m_idestroyedChain.clear();
}

void  EziDebugPrj::clearupCheckedChainList(void)
{
    m_icheckedChain.clear();
}

QStringList  EziDebugPrj::checkChainExist(void)
{
    QStringList iunexistChain ;
    QMap<QString,EziDebugScanChain*>::const_iterator ichainIter = m_ichainInfoMap.constBegin() ;

    while(ichainIter != m_ichainInfoMap.constEnd())
    {
        QString ichainName = ichainIter.key() ;

        m_idestroyedChain.append(ichainName);
        ++ichainIter ;
    }
    m_icheckedChain.clear();
    return iunexistChain ;
}


const QStringList &EziDebugPrj::getDestroyedChainList(void) const
{
    return m_idestroyedChain ;
}

const QStringList &EziDebugPrj::getCheckedChainList(void) const
{
    return m_icheckedChain ;
}

QStringList EziDebugPrj::deleteDestroyedChain(QList<LOG_FILE_INFO*> &addedinfoList,QList<LOG_FILE_INFO*> &deletedinfoList)
{
    QString ieziDebugFileSuffix ;
    QStringList iundelChainList ;

    for(int i = 0 ; i < m_idestroyedChain.count() ; i++)
    {
        QString ichainName =  m_idestroyedChain.at(i)  ;
        EziDebugScanChain* pchain = m_ichainInfoMap.value(ichainName , NULL);
        if(!pchain)
        {
            continue ;
        }
        ieziDebugFileSuffix = QObject::tr(".delete.%1").arg(ichainName);

        EziDebugInstanceTreeItem* pitem = m_ichainTreeItemMap.value(ichainName , NULL);

        if(pitem)
        {
            if(pitem->deleteScanChain(OperateTypeDelSingleScanChain))
            {
                // 恢复文件

                /*读取删除链 已经扫描过的文件,从已经备份的文件进行恢复*/
                for(int i = 0 ; i < pchain->getScanedFileList().count();i++)
                {
                    // 获取备份的文件名全称
                    QString ifileName = pchain->getScanedFileList().at(i) ;
                    QFileInfo ifileInfo(pchain->getScanedFileList().at(i));

                    QString ibackupFileName = this->getCurrentDir().absolutePath() \
                            + EziDebugScanChain::getUserDir() + tr("/") + ifileInfo.fileName() \
                            + ieziDebugFileSuffix;
                    QFile ibackupFile(ibackupFileName) ;

                    QFileInfo ibakfileInfo(ibackupFileName);
                    QDateTime idateTime = ibakfileInfo.lastModified();

                    QString irelativeName = m_iprjPath.relativeFilePath(ifileName) ;

                    // 恢复 源文件
                    if(ibakfileInfo.exists())
                    {
                        if(ifileName.endsWith(".v"))
                        {
                            m_ivlgFileMap.value(irelativeName)->remove();
                            ibackupFile.copy(ifileName);
                            m_ivlgFileMap.value(irelativeName)->modifyStoredTime(idateTime);
                        }
                        else if(ifileName.endsWith(".vhd"))
                        {
                            m_ivhdlFileMap.value(irelativeName)->remove();
                            ibackupFile.copy(ifileName);
                            m_ivhdlFileMap.value(irelativeName)->modifyStoredTime(idateTime);
                        }
                        else
                        {
                            // do nothing
                        }
                        // 删除备份文件
                        ibackupFile.remove();
                    }
                }
                // 错误 这条链没有被删除 ,检查文件是否编译通过
                iundelChainList << ichainName ;
                continue ;
            }

            m_ichainInfoMap.remove(ichainName) ;
            m_ichainTreeItemMap.remove(ichainName) ;
            m_iqueryTreeItemMap.remove(pitem->getNameData());

            if(m_pLastOperateChain)
            {
                if(m_pLastOperateChain->getChainName() == ichainName)
                {
                    m_pLastOperateChain = NULL ;
                    m_pLastOperteTreeItem = NULL ;
                    m_elastOperation = OperateTypeNone ;
                }
            }


            pitem->setScanChainInfo(NULL);

            // 删除备份文件
            QStringList iscanFileList = pchain->getScanedFileList();
            for(int i = 0 ; i < iscanFileList.count(); i++)
            {
                QString ifileName = iscanFileList.at(i) ;
                QString irelativeName = m_iprjPath.relativeFilePath(ifileName) ;
                QFileInfo ifileInfo(ifileName);
                QDateTime idateTime = ifileInfo.lastModified();

                QFile ibakFile(ifileName + ieziDebugFileSuffix) ;
                if(ibakFile.exists())
                {
                    ibakFile.remove();
                }

                // 更改文件时间
                if(ifileName.endsWith(".v"))
                {
                    m_ivlgFileMap.value(irelativeName)->modifyStoredTime(idateTime);

                    EziDebugVlgFile* pfile = m_ivlgFileMap.value(irelativeName) ;

                    EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                    pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                    pdelFileInfo->pinfo = NULL ;
                    memcpy(pdelFileInfo->ainfoName , irelativeName.toAscii().data() , irelativeName.size()+1);
                    deletedinfoList.append(pdelFileInfo);

                    struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                    paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                    paddFileInfo->pinfo = pfile ;
                    memcpy(paddFileInfo->ainfoName , irelativeName.toAscii().data(), irelativeName.size()+1);
                    addedinfoList.append(paddFileInfo);

                }
                else if(ifileName.endsWith(".vhd"))
                {
                    m_ivhdlFileMap.value(irelativeName)->modifyStoredTime(idateTime);

                    EziDebugVhdlFile* pfile = m_ivhdlFileMap.value(irelativeName) ;
                    EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                    pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                    pdelFileInfo->pinfo = NULL ;
                    memcpy(pdelFileInfo->ainfoName , irelativeName.toAscii().data() , irelativeName.size()+1);
                    deletedinfoList.append(pdelFileInfo);

                    struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                    paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                    paddFileInfo->pinfo = pfile ;
                    memcpy(paddFileInfo->ainfoName , irelativeName.toAscii().data(), irelativeName.size()+1);
                    addedinfoList.append(paddFileInfo);
                }
                else
                {
                    // do nothing
                    continue ;
                }

            }

            // 删除链指针
            delete pchain ;
        }
    }
    // 删除破坏掉的链,下次接着扫描链是否被破坏
    m_idestroyedChain.clear() ;
    return iundelChainList ;
}


bool EziDebugPrj::isPrjFileExist(void)
{
    QStringList inameFilter ;
    QStringList ifileList ;

    if(ToolQuartus == m_eusedTool)
    {
        inameFilter.append("*.qsf");
    }
    else if(ToolIse == m_eusedTool)
    {
        // 版本 10.1
        inameFilter.append("*.restore");
        // 版本 14.4
        inameFilter.append("*.xise");
    }
    else
    {
        /*do nothing*/
        qDebug() << "Is there other tool in the world ?" ;
        return 0 ;
    }
    ifileList = m_iprjPath.entryList(inameFilter,QDir::Files) ;
    if(!ifileList.count())
    {
        //qDebug() << "Please Check the path \""<< m_iprjPath.absolutePath() <<"\" to verify the " << inameFilter.at(0) << "file exist !";
        QMessageBox::warning(NULL, QObject::tr("EziDebug"),QObject::tr("Please Check the path \n \"%1\" \n to verify the %2 file exist!").arg(m_iprjPath.absolutePath()) \
                             .arg(inameFilter.at(0))) ;
        //  .arg(inameFilter.at(0))));
        return 0 ;
    }
    else if(ifileList.count() > 1)
    {
        qDebug() << "Please Delete the unnecessary file " << inameFilter.at(0) ;
		QMessageBox::warning(NULL, QObject::tr("EziDebug"),QObject::tr("Please delete the unnecessary \"%1\"file!").arg(inameFilter.at(0)));
        return 0 ;
    }
    else
    {
        m_iprjName = const_cast<QString&>(ifileList.at(0));
        m_iprjName = m_iprjPath.absoluteFilePath(m_iprjName);
        qDebug() << "isPrjFileExist" << m_iprjName ;
        return 1 ;
    }
}

void EziDebugPrj::preModifyPrjFile(void)
{
    QString itrueStr = "true" ;
    QString ifalseStr = "false" ;
    if((ToolIse == m_eusedTool)&&(m_itoolSoftwareVersion == "10.x"))
    {
        // m_isXilinxErrChecked 如果为true 才进行修改  否则保持不变

        QFile iprjFile(m_iprjName);
        QString iline;

        if(!iprjFile.open(QIODevice::ReadOnly|QIODevice::Text))
        {
            qDebug() << "Cannot Open file for reading:" << qPrintable(iprjFile.errorString());
            return  ;
        }

        QTextStream iinStream(&iprjFile) ;
        iline = iinStream.readAll() ;
        int nKeyWordsPos = iline.indexOf("PROP_xstEquivRegRemoval") ;
        int ntrueBoolValue = iline.indexOf(itrueStr,nKeyWordsPos) ;
        int nfalseBoolValue = iline.indexOf(ifalseStr,nKeyWordsPos);
        if(ntrueBoolValue < nfalseBoolValue)
        {
            if(m_isDisXilinxErrChecked)
            {
                // 改为 false
                iline.replace(ntrueBoolValue,itrueStr.size(),ifalseStr);
            }
            else
            {
                // 改为 true
                iprjFile.close();
                return ;
            }
        }
        else
        {
            if(m_isDisXilinxErrChecked)
            {
                // 改为 false
                iprjFile.close();
                return ;
            }
            else
            {
                // 改为 true
                iline.replace(nfalseBoolValue,ifalseStr.size(),itrueStr);
            }
        }

        iprjFile.close();

        if(!iprjFile.open(QIODevice::WriteOnly|QIODevice::Text))
        {
            qDebug() << "Cannot Open file for reading:" << qPrintable(iprjFile.errorString());
            return  ;
        }

        QTextStream ioutStream(&iprjFile) ;
        ioutStream << iline ;
        iprjFile.close();
    }
}
int EziDebugPrj::parseQuartusPrjFile(QMap<QString,EziDebugVlgFile*> &vlgFileMap ,QMap<QString,EziDebugVhdlFile*> &vhdlFileMap)
{
    QFile iprjFile(m_iprjName);
    if(!iprjFile.open(QIODevice::ReadOnly|QIODevice::Text))
    {
        qDebug() << "Cannot Open file for reading:" << qPrintable(iprjFile.errorString());
        return 1 ;
    }
    QTextStream iinStream(&iprjFile) ;
    while(!iinStream.atEnd())
    {
        QString iline = iinStream.readLine();

        if(iline.contains(QRegExp("\\bLAST_QUARTUS_VERSION\\b")))
        {
            QStringList ifileds = iline.split(QRegExp("\\s+"));
            if(ifileds.size()!=4)
            {
                qDebug()<< "the project file has problem!" ;
                break;
            }
            else
            {
                if(ifileds.at(2) == "LAST_QUARTUS_VERSION")
                {
                    m_itoolSoftwareVersion =  ifileds.at(3) ;
                }
                else
                {
                    qDebug()<< "the project file has problem!" ;
                    break;
                }
            }
        }

        if(iline.contains(QRegExp("\\bVERILOG_FILE\\b")))
        {
            QStringList ifileds = iline.split(QRegExp("\\s+"));
            if(ifileds.size()!=4)
            {
                qDebug()<< "the project file has problem!" ;
                break;
            }
            else
            {
                if(ifileds.at(2) == "VERILOG_FILE")
                {
                    QString  ifileName = ifileds.at(3) ;
                    // 转换成绝对路径
                    if(!(ifileName.endsWith("_EziDebug_ScanChainReg.v")||ifileName.endsWith("_EziDebug_TOUT_m.v")))
                    {
                        QFileInfo ifileinfo(m_iprjPath,ifileName);

                        if(ifileinfo.exists())
                        {
                            EziDebugVlgFile *ifileObj = new EziDebugVlgFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName());
                            vlgFileMap.insert(ifileName,ifileObj);
                            m_iCodefileNameList.append(ifileName);
                        }
                    }
//                  vlgfilemap.insert(ifileName,ifileObj);
                }
                else
                {
                    qDebug()<< "the project file has problem!" ;
                    break;
                }
            }
        }

        if(iline.contains(QRegExp("\\bVHDL_FILE\\b")))
        {
            QStringList ifileds = iline.split(QRegExp("\\s+"));
            if(ifileds.size()!=4)
            {
                qDebug()<< "the project file has problem!" ;
                break;
            }
            else
            {
                if(ifileds.at(2) == "VHDL_FILE")
                {
                    QString  ifileName = ifileds.at(3) ;
                    // 转换成绝对路径
                    QFileInfo ifileinfo(m_iprjPath,ifileName);
                    if(ifileinfo.exists())
                    {
                        EziDebugVhdlFile *ifileObj = new EziDebugVhdlFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName());
                        vhdlFileMap.insert(ifileName,ifileObj);
                        m_iCodefileNameList.append(ifileName);
                    }
//                  vhdlfilemap.insert(ifileName,ifileObj);
                }
                else
                {
                    qDebug()<< "the project file has problem!" ;
                    break;
                }
            }
        }

        if(iline.contains(QRegExp("\\bTOP_LEVEL_ENTITY\\b")))
        {
            QStringList ifileds = iline.split(QRegExp("\\s+"));
            if(ifileds.size()!=4)
            {
                qDebug()<< "the project file has problem!" ;
                break;
            }
            else
            {
                if(ifileds.at(2) == "TOP_LEVEL_ENTITY")
                {
                    m_itopModule = ifileds.at(3) ;
                }
                else
                {
                    qDebug()<< "the project file has problem!" ;
                    break;
                }
            }
        }

        if(iline.contains(QRegExp("\\bSIGNALTAP_FILE\\b")))
        {
            QStringList ifileds = iline.split(QRegExp("\\s+"));
            if(ifileds.size()!=4)
            {
                qDebug()<< "the project file has problem!" ;
                break;
            }
            else
            {
                if(ifileds.at(2) == "SIGNALTAP_FILE")
                {
                    m_iwaveFileList << ifileds.at(3) ;
                }
                else
                {
                    qDebug()<< "the project file has problem!" ;
                    break;
                }
            }
        }

    }
    return 0 ;
}

int EziDebugPrj::parseQuartusPrjFile(QStringList &filelist)
{
    QFile iprjFile(m_iprjName);
    if(!iprjFile.open(QIODevice::ReadOnly|QIODevice::Text))
    {
        qDebug() << "Cannot Open file for reading:" << qPrintable(iprjFile.errorString());
        return 1 ;
    }
    QTextStream iinStream(&iprjFile) ;
    while(!iinStream.atEnd())
    {
        QString iline = iinStream.readLine();
        if(iline.contains(QRegExp("\\bVERILOG_FILE\\b")))
        {
            QStringList ifileds = iline.split(QRegExp("\\s+"));
            if(ifileds.size()!=4)
            {
                qDebug()<< "the project file has problem!" ;
                break;
            }
            else
            {
                if(ifileds.at(2) == "VERILOG_FILE")
                {
                    QString  ifileName = ifileds.at(3) ;
                    QFileInfo ifileinfo(m_iprjPath,ifileName);

                    if(!(ifileName.endsWith("_EziDebug_ScanChainReg.v")||ifileName.endsWith("_EziDebug_TOUT_m.v")))
                    {
                        if(ifileinfo.exists())
                        {
                            filelist.append(ifileName);
                        }
                    }
//                  vlgfilemap.insert(ifileName,ifileObj);
                }
                else
                {
                    qDebug()<< "the project file has problem!" ;
                    break;
                }
            }
        }
        if(iline.contains(QRegExp("\\bVHDL_FILE\\b")))
        {
            QStringList ifileds = iline.split(QRegExp("\\s+"));
            if(ifileds.size()!=4)
            {
                qDebug()<< "the project file has problem!" ;
                break;
            }
            else
            {
                if(ifileds.at(2) == "VHDL_FILE")
                {
                    QString  ifileName = ifileds.at(3) ;
                    QFileInfo ifileinfo(m_iprjPath,ifileName);
                    if(ifileinfo.exists())
                    {
                        filelist.append(ifileName);
                    }
//                  vhdlfilemap.insert(ifileName,ifileObj);
                }
                else
                {
                    qDebug()<< "the project file has problem!" ;
                    break;
                }
            }
        }
// 暂时去掉  暂不考虑 topmodule 被修改了 ,作为遗留问题跟踪
//        if(iline.contains(QRegExp("\\bTOP_LEVEL_ENTITY\\b")))
//        {
//            QStringList ifileds = iline.split(QRegExp("\\s+"));
//            if(ifileds.size()!=4)
//            {
//                qDebug()<< "the project file has problem!" ;
//                break;
//            }
//            else
//            {
//                if(ifileds.at(2) == "TOP_LEVEL_ENTITY")
//                {
//                    topmodue = ifileds.at(3) ;
//                }
//                else
//                {
//                    qDebug()<< "the project file has problem!" ;
//                    break;
//                }
//            }
//        }

    }
    iprjFile.close();
    return 0 ;
}

int EziDebugPrj::parseIsePrjFile(QMap<QString,EziDebugVlgFile*> &vlgFileMap ,QMap<QString,EziDebugVhdlFile*> &vhdlFileMap)
{
    qDebug() << "parseIsePrjFile " << __LINE__ ;
    QFile iprjFile(m_iprjName);
    QString iLangType ;
    QString ifileInfo ;
    QString iprjInfo ;
    QString iProcessInfo ;
    QStringList ifileInfoList ;
    QStringList iProcessInfoList ;
    if(!iprjFile.open(QIODevice::ReadOnly|QIODevice::Text))
    {
        qDebug() << "Cannot Open file for reading:" << qPrintable(iprjFile.errorString());
        return 1 ;
    }
    QTextStream iinStream(&iprjFile) ;
    QString iline = iinStream.readAll();
    int nstartPos = 0 ;
    int npositionOfProjectSetting = 0 ;
    int npositionOfFileKeyWord = 0 ;
    int npositionOfFileLeftBracket = 0 ;
    int npositionOfFileRightBracket = 0 ;
    int npositionOfProcessKeyWord = 0 ;
    int npositionOfProcessLeftBracket = 0 ;
    int npositionOfProcessRightBracket = 0 ;

    //m_iprjName
    //  查找所有 代码文件
    if(m_iprjName.endsWith(".restore",Qt::CaseSensitive))
    {
        m_itoolSoftwareVersion = "10.x" ;
        npositionOfProjectSetting = iline.indexOf(QRegExp("\\bset\\s+project_settings\\b"),0);
        if(npositionOfProjectSetting != -1 )
        {
            npositionOfFileLeftBracket = iline.indexOf("{",npositionOfProjectSetting,Qt::CaseSensitive);
            if(npositionOfFileLeftBracket != -1 )
            {
               npositionOfFileRightBracket = iline.indexOf("}",npositionOfFileLeftBracket,Qt::CaseSensitive);
               if(npositionOfFileRightBracket != -1)
               {
                   iprjInfo = iline.mid(npositionOfFileLeftBracket+1,npositionOfFileRightBracket-npositionOfFileLeftBracket-1);
                   QRegExp iLangExp("\"\\s*PROP_PreferredLanguage\"\\s*");
                   int nKeyOfLang = iLangExp.indexIn(iprjInfo,0);
                   if(nKeyOfLang != -1)
                   {
                       int nlen = iLangExp.matchedLength();
                       int nFirstQuote = iprjInfo.indexOf("\"" ,nKeyOfLang + nlen );
                       int nSecondQuote = iprjInfo.indexOf("\"",nFirstQuote + 1);
                       m_icoreLangType = iprjInfo.mid(nFirstQuote + 1 ,nSecondQuote - nFirstQuote - 1) ;
                   }
                   else
                   {
                       iprjFile.close();

                       return 1 ;
                   }
               }
            }
            else
            {
                qDebug() << "The project File error :The left bracket is not exist!" ;
                iprjFile.close();

                return 1 ;
            }
        }
        else
        {
            iprjFile.close();

            return 1 ;
        }

        nstartPos = npositionOfFileRightBracket + 1 ;

        //  搜索代码文件
        npositionOfFileKeyWord = iline.indexOf(QRegExp("\\bset\\s+user_files\\b"),nstartPos);
        if(npositionOfFileKeyWord != -1)
        {
            npositionOfFileLeftBracket = iline.indexOf("{",npositionOfFileKeyWord,Qt::CaseSensitive);
            if( npositionOfFileLeftBracket != -1)
            {
                npositionOfFileRightBracket = iline.indexOf("}",npositionOfFileKeyWord,Qt::CaseSensitive);
                if(npositionOfFileRightBracket != -1)
                {
                    ifileInfo = iline.mid(npositionOfFileLeftBracket+1,npositionOfFileRightBracket-npositionOfFileLeftBracket-1);
                    ifileInfoList = ifileInfo.split("\"",QString::KeepEmptyParts);
                    QStringList::const_iterator constIterator ;
                    for (constIterator = ifileInfoList.constBegin(); constIterator != ifileInfoList.constEnd();++constIterator)
                    {
                        QString ifileName = (*constIterator) ;
                        if(ifileName.endsWith(".vhd", Qt::CaseSensitive))
                        {
                            // 转换成绝对路径
                            QFileInfo ifileinfo(m_iprjPath,*constIterator);
                            EziDebugVhdlFile* pvhdlFileObj = new EziDebugVhdlFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName());
                            qDebug() << const_cast<QString&>(*constIterator);
                            if(!(ifileName.endsWith("_EziDebug_ScanChainReg.vhd")||ifileName.endsWith("_EziDebug_TOUT_m.vhd")))
                            {
                                vhdlFileMap.insert(ifileName,pvhdlFileObj);
                                m_iCodefileNameList.append(ifileName);
                            }
//                          vhdlfilemap.insert((*constIterator),pvhdlFileObj);
                        }
                        else if(ifileName.endsWith(".v", Qt::CaseSensitive))
                        {
                            QFileInfo ifileinfo(m_iprjPath,*constIterator);
                            EziDebugVlgFile* pvlgFileObj = new EziDebugVlgFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName());
                            qDebug() << const_cast<QString&>(*constIterator);
                            if(!(ifileName.endsWith("_EziDebug_ScanChainReg.v")||ifileName.endsWith("_EziDebug_TOUT_m.v")))
                            {
                                vlgFileMap.insert((*constIterator),pvlgFileObj);
                                m_iCodefileNameList.append((*constIterator));
                            }
//                            vlgfilemap.insert((*constIterator),pvlgFileObj);
                        }
                        else if(ifileName.endsWith(".xco", Qt::CaseSensitive))
                        {
#if 1
                            QString iHdlFileName ;
                            QString iCompleteRelativeHdlFileName = *constIterator ;

                            QFileInfo ifileinfo(m_iprjPath,*constIterator);
                            iHdlFileName = ifileinfo.fileName();

                            qDebug() << const_cast<QString&>(*constIterator);
                            if(m_icoreLangType == "Verilog")
                            {
                                iHdlFileName.replace(".xco",".v");
                                iCompleteRelativeHdlFileName.replace(".xco",".v");
                                // 用绝对路径构造
                                EziDebugVlgFile* pvlgFileObj = new EziDebugVlgFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + iHdlFileName);
                                pvlgFileObj->setLibaryFlag(true);
                                vlgFileMap.insert(iCompleteRelativeHdlFileName,pvlgFileObj);
                                m_iCodefileNameList.append(iCompleteRelativeHdlFileName);
                            }
                            else
                            {
                                // 用绝对路径构造
                                iHdlFileName.replace(".xco",".vhd");
                                iCompleteRelativeHdlFileName.replace(".xco",".vhd") ;
                                EziDebugVhdlFile* pvhdlFileObj = new EziDebugVhdlFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + iHdlFileName);
                                pvhdlFileObj->setLibaryFlag(true);
                                vhdlFileMap.insert(iCompleteRelativeHdlFileName,pvhdlFileObj);
                                m_iCodefileNameList.append(iCompleteRelativeHdlFileName);
                            }
#endif
                        }
                    }
                }
                else
                {
                    qDebug() << "the setting file has some problem!" ;
                    iprjFile.close();
                    return 1 ;
                }
            }
            else
            {
                qDebug() << "There is leftbracket after \"set user_files\" !";
                iprjFile.close();
                return 1 ;
            }
        }
        else
        {
            qDebug() << "There is leftbracket after \"set user_files\" !";
            iprjFile.close();
            return 1 ;
        }


        nstartPos =  npositionOfFileRightBracket + 1;
        npositionOfProcessKeyWord = iline.indexOf(QRegExp("\\bset\\s+process_props\\b"),nstartPos);

        npositionOfProcessLeftBracket = iline.indexOf("{",npositionOfProcessKeyWord,Qt::CaseSensitive);
        if( npositionOfProcessLeftBracket != -1)
        {
            npositionOfProcessRightBracket = iline.indexOf("}",npositionOfProcessKeyWord,Qt::CaseSensitive);
            if(npositionOfProcessRightBracket != -1)
            {
                iProcessInfo = iline.mid(npositionOfProcessLeftBracket+1,npositionOfProcessRightBracket-npositionOfFileLeftBracket-1);
                iProcessInfoList = iProcessInfo.split("\"",QString::SkipEmptyParts);
                QStringList::const_iterator constIterator ;
                for (constIterator = iProcessInfoList.constBegin(); constIterator != iProcessInfoList.constEnd();++constIterator)
                {
                    if((*constIterator)== "PROP_SynthTop")
                    {
                        constIterator += 2 ;
                        qDebug() << "detect top key word!" ;
                        if(((*constIterator).contains("Module"),Qt::CaseSensitive)||((*constIterator).contains("Architecture"),Qt::CaseSensitive))
                        {
                            QString itopmodule = *constIterator ;

                            QStringList itopModuleList = itopmodule.split("|");
                            m_itopModule = itopModuleList.at(1);
                            qDebug() << m_itopModule ;
                        }
                        else
                        {
                            qDebug() << "parseIsePrjFile error!";
                            iprjFile.close();
                            return 1 ;
                        }
                    }
                }
            }
            else
            {
                qDebug() << "the setting file has some problem!" ;
                iprjFile.close();
                return 1 ;
            }
        }
        else
        {
            qDebug() << "There is leftbracket after \"set user_files\" !";
            iprjFile.close();
            return 1 ;
        }

    }
    else if(m_iprjName.endsWith(".xise",Qt::CaseSensitive))
    {
        QDomDocument idomDocument ;
        QString iErrorStr ;
        int nErrorLine ;
        int nErrorColumn = 0 ;
        if (!idomDocument.setContent(&iprjFile, true, &iErrorStr, &nErrorLine, &nErrorColumn))
        {
            qDebug() << tr("Parse error at line %1, column %2:\n%3").arg(nErrorLine)\
                        .arg(nErrorColumn).arg(iErrorStr) ;
            return 1 ;
        }

        QDomElement root = idomDocument.documentElement();
        if(root.tagName() == "project")
        {
            //  获取工程设置的代码语言  以及  获取 topmodule
            QDomElement iPrjProperties = root.firstChildElement("properties");
            if(!iPrjProperties.isNull())
            {
                QDomElement iPrjProperty = iPrjProperties.firstChildElement("property");
                while(!iPrjProperty.isNull())
                {
                    if(iPrjProperty.attribute("xil_pn:name") == "Implementation Top")
                    {
                        m_itopModule = iPrjProperty.attribute("xil_pn:value") ;
                    }

                    if(iPrjProperty.attribute("xil_pn:name") == "Preferred Language")
                    {
                        m_icoreLangType = iPrjProperty.attribute("xil_pn:value");
                        break ;
                    }
                    iPrjProperty =  iPrjProperties.nextSiblingElement("property") ;
                }
            }
            else
            {
                qDebug() << "The project file parse error!";
                iprjFile.close();
                return 1 ;
            }

            if(m_itopModule.isEmpty())
            {
                qDebug() << "The project file parse error: NO Topmodule!";
                iprjFile.close();
                return 1 ;
            }

            if(iLangType.isEmpty())
            {
                qDebug() << "The project file parse error: NO Language Type!";
                iprjFile.close();
                return 1 ;
            }

            QDomElement ifilesChild = root.firstChildElement("files");
            if(!ifilesChild.isNull())
            {
                QDomElement ifileChild = ifilesChild.firstChildElement("file");

                while(!ifileChild.isNull())
                {
                    // 相对路径
                    QString ifileName = ifileChild.attribute("xil_pn:name") ;
                    if(ifileName.endsWith(".v"))
                    {
                        QFileInfo ifileinfo(m_iprjPath,ifileName);
                        EziDebugVlgFile* pvlgFileObj = new EziDebugVlgFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName());
                        qDebug() << ifileName ;
                        if(!(ifileName.endsWith("_EziDebug_ScanChainReg.v")||ifileName.endsWith("_EziDebug_TOUT_m.v")))
                        {
                            vlgFileMap.insert(ifileName,pvlgFileObj);
                            m_iCodefileNameList.append(ifileName);
                        }

                    }
                    else if(ifileName.endsWith(".vhd"))
                    {
                        QFileInfo ifileinfo(m_iprjPath,ifileName);
                        EziDebugVhdlFile* pvhdlFileObj = new EziDebugVhdlFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName());
                        qDebug() << ifileName ;
                        if(!(ifileName.endsWith("_EziDebug_ScanChainReg.vhd")||ifileName.endsWith("_EziDebug_TOUT_m.vhd")))
                        {
                            vhdlFileMap.insert(ifileName,pvhdlFileObj);
                            m_iCodefileNameList.append(ifileName);
                        }
                    }
                    else if(ifileName.endsWith(".xco"))
                    {
                        if(iLangType == "Verilog")
                        {
                            ifileName.replace(".xco",".v") ;
                            QFileInfo ifileinfo(m_iprjPath,ifileName);
                            EziDebugVlgFile* pvlgFileObj = new EziDebugVlgFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName());
                            qDebug() << ifileName ;

                            vlgFileMap.insert(ifileName,pvlgFileObj);
                            m_iCodefileNameList.append(ifileName);
                        }
                        else
                        {
                            ifileName.replace(".xco",".vhd") ;
                            QFileInfo ifileinfo(m_iprjPath,ifileName);
                            EziDebugVhdlFile* pvhdlFileObj = new EziDebugVhdlFile(ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName());
                            qDebug() << ifileName ;

                            vhdlFileMap.insert(ifileName,pvhdlFileObj);
                            m_iCodefileNameList.append(ifileName);
                        }
                    }

                    ifileChild = ifilesChild.nextSiblingElement("file");
                }
            }
            else
            {
                iprjFile.close();
                return 1 ;
            }
            m_itoolSoftwareVersion = "14.x" ;
        }
    }

    iprjFile.close();
    return 0 ;
}

int EziDebugPrj::parseIsePrjFile(QStringList &filelist)
{
    qDebug() << "parseIsePrjFile " << __LINE__ ;
    QFile iprjFile(m_iprjName);
    QString ifileInfo ;
    QString iPrjInfo ;
    QString iPreferLang ;
    //QString iProcessInfo ;
    QStringList ifileInfoList ;
    QStringList iPrjInfoList ;
    //QStringList iProcessInfoList ;
    if(!iprjFile.open(QIODevice::ReadOnly|QIODevice::Text))
    {
        qDebug() << "Cannot Open file for reading:" << qPrintable(iprjFile.errorString());
        return 1 ;
    }
    QTextStream iinStream(&iprjFile) ;
    QString iline = iinStream.readAll();
    //int searchPosition = 0 ;
    int npositionOfFileKeyWord = 0 ;
    int npositionOfFileLeftBracket = 0 ;
    int npositionOfFileRightBracket = 0 ;
    int npositionOfPrjKeyWord = 0 ;
//  int npositionOfProcessLeftBracket = 0 ;
//  int npositionOfProcessRightBracket = 0 ;

    if(m_itoolSoftwareVersion.isEmpty())
    {
        if(m_iprjName.endsWith(".restore",Qt::CaseSensitive))
        {
            m_itoolSoftwareVersion = "10.x" ;
        }
        else if(m_iprjName.endsWith(".xise",Qt::CaseSensitive))
        {
            m_itoolSoftwareVersion = "14.x" ;
        }
        else
        {
            qDebug("EziDebug Error: the version of software that opened the project is confused!");
            return 1 ;
        }
    }

    if(m_itoolSoftwareVersion == "10.x")
    {
        npositionOfPrjKeyWord  = iline.indexOf(QRegExp("\\bset\\s+project_settings\\b"),0);
        if(npositionOfPrjKeyWord != -1)
        {
            npositionOfFileLeftBracket = iline.indexOf("{" , npositionOfPrjKeyWord , Qt::CaseSensitive);
            if( npositionOfFileLeftBracket != -1)
            {
                npositionOfFileRightBracket = iline.indexOf("}",npositionOfFileLeftBracket,Qt::CaseSensitive);
                if(npositionOfFileRightBracket != -1)
                {
                    iPrjInfo = iline.mid(npositionOfFileLeftBracket+1,npositionOfFileRightBracket-npositionOfFileLeftBracket-1);
                    iPrjInfoList = iPrjInfo.split("\"",QString::SkipEmptyParts);
                    QStringList::ConstIterator iprjIter = iPrjInfoList.constBegin();
                    while(iprjIter != iPrjInfoList.constEnd())
                    {
                       QString iKeyWords = *iprjIter ;
                       if(iKeyWords == "PROP_PreferredLanguage")
                       {
                            iprjIter += 2 ;
                            iPreferLang = *iprjIter ;
                            break ;
                       }
                       ++iprjIter ;
                    }
                }
                else
                {
                    iprjFile.close();
                    qDebug() << "The Prject file parse failed!";
                    return 1 ;
                }
            }
            else
            {
                iprjFile.close();
                qDebug() << "The Prject file parse failed!";
                return 1 ;
            }
        }
        else
        {
            iprjFile.close();
            qDebug() << "The Prject file parse failed!";
            return 1 ;
        }

        npositionOfFileKeyWord = iline.indexOf(QRegExp("\\bset\\s+user_files\\b"),0);
        if(npositionOfFileKeyWord != -1)
        {
            npositionOfFileLeftBracket = iline.indexOf("{" , npositionOfFileKeyWord , Qt::CaseSensitive);
            if( npositionOfFileLeftBracket != -1)
            {
                npositionOfFileRightBracket = iline.indexOf("}",npositionOfFileLeftBracket,Qt::CaseSensitive);
                if(npositionOfFileRightBracket != -1)
                {
                    //searchPosition = npositionOfFileRightBracket ;
                    ifileInfo = iline.mid(npositionOfFileLeftBracket+1,npositionOfFileRightBracket-npositionOfFileLeftBracket-1);

                    ifileInfoList = ifileInfo.split("\"",QString::SkipEmptyParts);
                    QStringList::const_iterator constIterator ;
                    for (constIterator = ifileInfoList.constBegin(); constIterator != ifileInfoList.constEnd();++constIterator)
                    {
                        QString ifileName = (*constIterator) ;

                        if(ifileName.endsWith(".vhd", Qt::CaseSensitive))
                        {
                            qDebug() << const_cast<QString&>(*constIterator);
                            if(!(ifileName.endsWith("_EziDebug_ScanChainReg.vhd")||ifileName.endsWith("_EziDebug_TOUT_m.vhd")))
                            {
                                filelist.append(ifileName);
                            }
//                          vhdlfilemap.insert((*constIterator),pvhdlFileObj);
                        }
                        else if(ifileName.endsWith(".v", Qt::CaseSensitive))
                        {
                            qDebug() << const_cast<QString&>(*constIterator);
                            if(!(ifileName.endsWith("_EziDebug_ScanChainReg.v")||ifileName.endsWith("_EziDebug_TOUT_m.v")))
                            {
                                filelist.append(ifileName);
                            }
//                          vlgfilemap.insert((*constIterator),pvlgFileObj);
                        }
                        else if(ifileName.endsWith(".xco",Qt::CaseSensitive))
                        {
                            if(iPreferLang == "Verilog")
                            {
                                ifileName.replace(".xco",".v");
                                filelist.append(ifileName);
                            }
                            else
                            {
                                ifileName.replace(".xco",".vhd");
                                filelist.append(ifileName);
                            }
                        }
                    }
                }
                else
                {
                    qDebug() << "the setting file has some problem!" ;
                    iprjFile.close();
                    return 1 ;
                }
            }
            else
            {
                qDebug() << "There is leftbracket after \"set user_files\" !";
                iprjFile.close();
                return 1 ;
            }
        }
        else
        {
            iprjFile.close();
            return 1 ;
        }
    }
    else if(m_itoolSoftwareVersion == "14.x")
    {
        QDomDocument idomDocument ;
        QString iErrorStr ;
        int nErrorLine ;
        int nErrorColumn = 0 ;
        if (!idomDocument.setContent(&iprjFile, true, &iErrorStr, &nErrorLine, &nErrorColumn))
        {
            qDebug() << tr("Parse error at line %1, column %2:\n%3").arg(nErrorLine)\
                        .arg(nErrorColumn).arg(iErrorStr) ;
            return 1 ;
        }

        QDomElement root = idomDocument.documentElement();
        if(root.tagName() == "project")
        {
            QDomElement ifilesChild = root.firstChildElement("files");
            if(!ifilesChild.isNull())
            {
                QDomElement ifileChild = ifilesChild.firstChildElement("file");

                while(!ifileChild.isNull())
                {
                    // 相对路径
                    QString ifileName = ifileChild.attribute("xil_pn:name") ;
                    if(ifileName.endsWith(".v"))
                    {
                        if(!(ifileName.endsWith("_EziDebug_ScanChainReg.v")||ifileName.endsWith("_EziDebug_TOUT_m.v")))
                        {
                            filelist.append(ifileName);
                        }
                    }
                    else if(ifileName.endsWith(".vhd"))
                    {
                        if(!(ifileName.endsWith("_EziDebug_ScanChainReg.vhd")||ifileName.endsWith("_EziDebug_TOUT_m.vhd")))
                        {
                           filelist.append(ifileName);
                        }
                    }
                    else if(ifileName.endsWith(".xco"))
                    {
                        if(m_icoreLangType == "Verilog")
                        {
                            ifileName.replace(".xco",".v") ;
                            filelist.append(ifileName);
                        }
                        else
                        {
                            ifileName.replace(".xco",".vhd") ;
                            filelist.append(ifileName);
                        }
                    }
                    ifileChild = ifilesChild.nextSiblingElement("file");
                }
            }
            else
            {
                qDebug() << "The project file parse failed: NO root element!";
                iprjFile.close();
                return 1 ;
            }
        }
    }

    iprjFile.close();
    return 0 ;
}

void EziDebugPrj::deleteAllEziDebugCode(const QMap<QString,EziDebugVlgFile*> &vlgFileMap ,const QMap<QString,EziDebugVhdlFile*> &vhdlFileMap)
{
    QMap<QString,EziDebugVlgFile*>::const_iterator i = vlgFileMap.constBegin() ;
    while(i != vlgFileMap.constEnd())
    {
        EziDebugVlgFile* pfile =   i.value();
        pfile->deleteEziDebugCode();
        ++i;
    }

    QMap<QString,EziDebugVhdlFile*>::const_iterator j = vhdlFileMap.constBegin() ;
    while(j != vhdlFileMap.constEnd())
    {
        EziDebugVhdlFile* pfile =   j.value();
        pfile->deleteEziDebugCode();
        ++j;
    }
}


int EziDebugPrj::domParseFileInfoElement(const QDomElement &element, char readflag)
{
    /*子节点数目是否为零*/
    if(!(element.childNodes().count()))
    {
        qDebug() << "domParseFileInfoElement Error:There is no fileinfo!";
        return 0 ;
    }

    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "file")
        {
            if(domParseFileStructure(ichild.toElement(),readflag))
            {
                qDebug() << "domParseFileInfoElement Error :fileinfo format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "Info:There is no file element in the log file!";
            return 0 ;
        }
        ichild = ichild.nextSibling();
    }
    return 0 ;
}

int EziDebugPrj::domParseFileStructure(const QDomElement &element, char readflag)
{
    QString  ifileName ;
    QDateTime idateTime ;
    QDate idate ;
    QTime itime ;
    QStringList imoduleList ;

    if(element.attribute("file_name").isEmpty())
    {
        return 1 ;
    }

    if(element.attribute("modified_date").isEmpty())
    {
        return 1 ;
    }

    if(element.attribute("modified_time").isEmpty())
    {
        return 1 ;
    }

//    if(element.attribute("module_array").isEmpty())
//    {
//        return 1 ;
//    }

    if(element.attribute("macro").isEmpty())
    {
        return 1 ;
    }

    if(element.attribute("defparameter").isEmpty())
    {
        return 1 ;
    }

    ifileName = element.attribute("file_name");
    imoduleList = element.attribute("module_array").split(QRegExp("\\s+"));
    QStringList idateList = element.attribute("modified_date").split("/") ;
    QStringList itimeList = element.attribute("modified_time").split(":") ;

    idate = QDate(idateList.at(2).toInt(),idateList.at(0).toInt(),idateList.at(1).toInt()) ;
    itime = QTime(itimeList.at(0).toInt(),itimeList.at(1).toInt(),itimeList.at(2).toInt()) ;

    idateTime = QDateTime(idate,itime) ;

    if((ifileName.endsWith(".v",Qt::CaseSensitive)))
    {
        if(readflag&READ_FILE_INFO)
        {
            /*创建文件对象指针 并加入工程对象的文件map中*/
            QFileInfo ifileinfo(m_iprjPath,ifileName);
            QString ifileFullName = ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName() ;
            EziDebugVlgFile * pvlgFileObj = new EziDebugVlgFile(ifileFullName,idateTime,imoduleList);

            if(element.attribute("macro").compare("No Macro"))
            {
                QStringList imacroList = element.attribute("macro").split("$$") ;
                int nmacroCount = 0 ;
                for(;nmacroCount < imacroList.count();nmacroCount++)
                {
                    QString imacroStr = imacroList.at(nmacroCount).split("::").at(0) ;
                    QString imacroVal = imacroList.at(nmacroCount).split("::").at(1) ;
                    pvlgFileObj->addToMacroMap(imacroStr , imacroVal);
                }

            }

            if(element.attribute("defparameter").compare("No Defparam"))
            {
                QStringList idefParmeterList = element.attribute("defparameter").split("$$") ;
                int ndefparameterCount = 0 ;
                for(;ndefparameterCount < idefParmeterList.count();ndefparameterCount++)
                {
                    QString icomDefParaStr = idefParmeterList.at(ndefparameterCount).split("::").at(0) ;
                    QString idefParaVal = idefParmeterList.at(ndefparameterCount).split("::").at(1) ;
                    QString iinstanceName = icomDefParaStr.split(".").at(0) ;
                    QString idefParaStr = icomDefParaStr.split(".").at(1) ;
                    pvlgFileObj->addToDefParameterMap(iinstanceName ,idefParaStr ,idefParaVal);
                }
            }

            m_ivlgFileMap.insert(ifileName,pvlgFileObj);
            m_iCodefileNameList << ifileName ;
        }
    }
    else if((ifileName.endsWith(".vhd",Qt::CaseSensitive)))
    {
        /*创建文件对象指针 并加入工程对象的文件map中*/
        if(readflag&READ_FILE_INFO)
        {
            QFileInfo ifileinfo(m_iprjPath,ifileName);
            QString ifileFullName = ifileinfo.absoluteDir().absolutePath()+ QObject::tr("/") + ifileinfo.fileName() ;
            EziDebugVhdlFile * pvlgFileObj = new EziDebugVhdlFile(ifileFullName,idateTime,imoduleList);
            m_ivhdlFileMap.insert(ifileName,pvlgFileObj);
            m_iCodefileNameList << ifileName ;
        }
    }
    else
    {
        qDebug() << "domParseFileStructure Error:The log file format is not right(the source code file type is not right)!";
        return 1 ;
    }
    return 0 ;
}

int EziDebugPrj::domParseModuleInfoElement(const QDomElement &element, char readflag)
{
    QString imoduleName ;
    EziDebugModule *pmoduleObj = NULL ;
    /*子节点数目是否为零*/
    if(!(element.childNodes().count()))
    {
        qDebug() << "Info:There is no module info in the log file!";
        return 0 ;
    }

    // 存在 module 则检查 topmodule
    if(element.attribute("topmodule").isEmpty())
    {
        qDebug() << "domParseEziDebugElement Error:There is no topmodule!" ;
        return 1 ;
    }
    else
    {
        if(element.attribute("topmodule").toLower() != "no module")
        {
            m_itopModule =  element.attribute("topmodule") ;
        }
    }

    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "module")
        {
            if(ichild.toElement().attribute("module_name").isEmpty())
            {
                return 1 ;
            }

//            if(ichild.toElement().attribute("appearance_count").isEmpty())
//            {
//                return 1 ;
//            }

//            if(QRegExp("^\\d+$").exactMatch(ichild.toElement().attribute("appearance_count")))
//            {
//                return 1 ;
//            }

            if(ichild.toElement().attribute("lib_core").isEmpty())
            {
                return 1 ;
            }

            if(!QRegExp("^\\d+$").exactMatch(ichild.toElement().attribute("lib_core")))
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("file_name").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("instance_array").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("reset_signal").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("parameter").isEmpty())
            {
                return 1 ;
            }

            if(readflag&READ_MODULE_INFO)
            {
                imoduleName = ichild.toElement().attribute("module_name") ;
                qDebug() << "Test module" <<imoduleName ;
                pmoduleObj = new EziDebugModule(imoduleName) ;
                if(!pmoduleObj)
                {
                    qDebug() << "Error: domParseModuleInfoElement :There is no memory left !" ;
                    return 1 ;
                }

                pmoduleObj->m_isLibaryCore = ichild.toElement().attribute("lib_core").toInt() ;
                //pmoduleObj->m_ninstanceTimes = ichild.toElement().attribute("appearance_count").toInt();
                pmoduleObj->m_ilocatedFile = ichild.toElement().attribute("file_name") ;

                if(!(ichild.toElement().attribute("instance_array").toLower() == "no instance"))
                {
                    pmoduleObj->m_iinstanceNameList = ichild.toElement().attribute("instance_array").split("|") ;
                }

                if(ichild.toElement().attribute("reset_signal").compare("No Reset Signal"))
                {

                    pmoduleObj->m_iresetMap.insert(ichild.toElement().attribute("reset_signal").split(":").at(0),\
                                                   ichild.toElement().attribute("reset_signal").split(":").at(1));
                }

                if(ichild.toElement().attribute("parameter").compare("No Parameter"))
                {
                    QStringList iparameterList = ichild.toElement().attribute("parameter").split("$$") ;
                    int nparameterCount = 0 ;
                    for( ; nparameterCount < iparameterList.count() ;nparameterCount++)
                    {
                        QString iparameterStr = iparameterList.at(nparameterCount).split("::").at(0) ;
                        QString iparameterVal = iparameterList.at(nparameterCount).split("::").at(1) ;
                        pmoduleObj->m_iparameter.insert(iparameterStr,iparameterVal) ;
                    }
                }
            }



            /*解析module 结构*/
            if(domParseModuleStructure(ichild.toElement() , readflag , pmoduleObj))
            {
                qDebug() << "domParseFileInfoElement Error :moduleinfo format is not right!";
                return 1 ;
            }

            if(pmoduleObj)
            {
                m_imoduleMap.insert(pmoduleObj->getModuleName(),pmoduleObj);
            }

        }
        else
        {
            qDebug() << "domParseFileInfoElement Error : There is strange element in the file!";
            return 1 ;
        }
        ichild = ichild.nextSibling();
    }
    return 0 ;
}

int EziDebugPrj::domParseModuleStructure(const QDomElement &element,char readflag,EziDebugModule* module)
{
    /*子节点数目是否为零*/
    int emoduleStructureExistFlag = 0 ;
    if(element.childNodes().count() != 4)
    {
        qDebug() << "domParseFileInfoElement Error:module format is not right!";
        return 1 ;
    }
    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "clock_description")
        {
            emoduleStructureExistFlag |= MODULE_STRUCTURE_CLOCK_DESCRIPTION ;
            if(domParseClockDescriptionElement(ichild.toElement() , readflag , module))
            {
                qDebug() << "domParseModuleStructure Error :moduleinfo format is not right!";
                return 1 ;
            }
        }
        else if(ichild.toElement().tagName() == "reg_description")
        {
            emoduleStructureExistFlag |= MODULE_STRUCTURE_REG_DESCRIPTION ;
            if(domParseRegDescriptionElement(ichild.toElement() , readflag , module))
            {
                qDebug() << "domParseModuleStructure Error :reginfo format is not right!";
                return 1 ;
            }
        }
        else if(ichild.toElement().tagName() == "port_description")
        {
            emoduleStructureExistFlag |= MODULE_STRUCTURE_PORT_DESCRIPTION ;
            if(domParsePortDescriptionElement(ichild.toElement() , readflag ,module))
            {
                qDebug() << "domParseModuleStructure Error :portinfo format is not right!";
                return 1 ;
            }
        }
        else if(ichild.toElement().tagName() == "instance_port_map_description")
        {
            emoduleStructureExistFlag |= MODULE_STRUCTURE_INSTANCE_PORT_MAP_DESCRIPTION ;
            if(domParseInstancePortMapDescriptionElement(ichild.toElement() , readflag ,module))
            {
                qDebug() << "domParseModuleStructure Error :portmap format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "domParseModuleStructure Error : There is strange element in the file!";
            return 1 ;
        }
        ichild = ichild.nextSibling();
    }

    if((emoduleStructureExistFlag&MODULE_STRUCTURE_ALL_DESCRIPTION) == MODULE_STRUCTURE_ALL_DESCRIPTION )
    {
        return 0 ;
    }
    else
    {
        return 1 ;
    }

}


int EziDebugPrj::domParseClockDescriptionElement(const QDomElement &element, char readflag, EziDebugModule* module)
{
    /*子节点数目是否为零*/
    if(!(element.childNodes().count()))
    {
        qDebug() << "EziDebug Info: There is no clockinfo " << (module? (QObject::tr("in module:%1").arg(module->getModuleName())):"");
        return 0 ;
    }
    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "clock")
        {

            if(ichild.toElement().attribute("clock_name").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("polarity").isEmpty())
            {
                return 1 ;
            }

            if(!((ichild.toElement().attribute("polarity").toLower() == "posedge") \
                 || (ichild.toElement().attribute("polarity").toLower() == "negedge")))
            {
                return 1 ;
            }

            if(readflag & READ_MODULE_INFO)
            {
                if(module)
                {
                    QString iclockName  = ichild.toElement().attribute("clock_name");
                    module->m_iclockMap.insert(iclockName,ichild.toElement().attribute("polarity"));
                }
                else
                {
                    qDebug() << "domParseClockDescriptionElement: NULL Pointer!";
                    return 1 ;
                }
            }

        }
        else
        {
            qDebug() << "domParseFileInfoElement Error : There is strange element in the file!";
            return 1 ;
        }
        ichild = ichild.nextSibling();
    }
    return 0 ;
}

int EziDebugPrj::domParseClockStructure(const QDomElement &element, char readflag , EziDebugModule* module)
{
    return 0 ;
}


int EziDebugPrj::domParseRegDescriptionElement(const QDomElement &element ,char readflag, EziDebugModule* module)
{
    /*子节点数目是否为零*/
    if(!(element.childNodes().count()))
    {
        qDebug() << "EziDebug Info:There is no reginfo in the module " << (module ? module->getModuleName() : "") << "!";
        return 0 ;
    }
    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "reg")
        {
            if(ichild.toElement().attribute("module_name").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("locate_clock").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("reg_name").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("bitwidth").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("regnum").isEmpty())
            {
                return 1 ;
            }
#if 0
            if(ichild.toElement().attribute("endian").isEmpty())
            {
                return 1 ;
            }
#endif

            if(ichild.toElement().attribute("polarity").isEmpty())
            {
                return 1 ;
            }

            if(!((ichild.toElement().attribute("polarity").toLower() == "posedge") \
                 || (ichild.toElement().attribute("polarity").toLower() == "negedge") \
                 || (ichild.toElement().attribute("polarity").toLower() == "low") \
                 || (ichild.toElement().attribute("polarity").toLower() == "high")))
            {
                return 1 ;
            }
#if 0
            if(!((ichild.toElement().attribute("endian") == "0")\
                 ||(ichild.toElement().attribute("endian") == "1")))
            {
                return 1 ;
            }
#endif

            if(readflag & READ_MODULE_INFO)
            {
                if(module)
                {
                    EziDebugModule::RegStructure * preg= new EziDebugModule::RegStructure ;
//                  preg->m_isEndian     = ichild.toElement().attribute("endian").toInt();

//                  preg->m_pMouduleName = (char*)malloc(ichild.toElement().attribute("module_name").size()+1);
                    memcpy(preg->m_pMouduleName,ichild.toElement().attribute("module_name").toAscii().data(),ichild.toElement().attribute("module_name").size()+1);

//                  preg->m_pRegName =  (char*)malloc(ichild.toElement().attribute("reg_name").size()+1);
                    memcpy(preg->m_pRegName,ichild.toElement().attribute("reg_name").toAscii().data(),ichild.toElement().attribute("reg_name").size()+1);

                    memset(preg->m_pExpString,0,64) ;
                    if(ichild.toElement().attribute("bitwidth").size() <= 63)
                    {
                        qstrcpy(preg->m_pExpString,ichild.toElement().attribute("bitwidth").toAscii().constData());
                    }

                    memset(preg->m_pregNum,0,64) ;
                    if(ichild.toElement().attribute("regnum").size() <= 63)
                    {
                        qstrcpy(preg->m_pregNum ,ichild.toElement().attribute("regnum").toAscii().constData()) ;
                    }


                    if(ichild.toElement().attribute("polarity").toLower() == "posedge")
                    {
                        preg->m_eedge = EziDebugModule::signalPosEdge ;
                    }
                    else if(ichild.toElement().attribute("polarity").toLower() == "negedge")
                    {
                        preg->m_eedge = EziDebugModule::signalNegEdge ;
                    }
                    else if(ichild.toElement().attribute("polarity").toLower() == "low")
                    {
                        preg->m_eedge = EziDebugModule::signalLow ;
                    }
                    else
                    {
                        preg->m_eedge = EziDebugModule::signalHigh ;
                    }

                    QString iclockName   = ichild.toElement().attribute("locate_clock");
                    qstrcpy(preg->m_pclockName,iclockName.toAscii().data());
                    QVector<EziDebugModule::RegStructure*> iregStructureVec = module->m_iregMap.value(iclockName) ;
                    iregStructureVec.append(preg);
                    module->m_iregMap.insert(iclockName,iregStructureVec);
                }
                else
                {
                    qDebug() << "domParseRegDescriptionElement Error: NULL Pointer!";
                    return 1 ;
                }
            }
        }
        else
        {
            qDebug() << "domParseRegDescriptionElement Error : There is strange element in the file!";
            return 1 ;
        }
        ichild = ichild.nextSibling();
    }
    return 0 ;
}

int EziDebugPrj::domParseRegStructure(const QDomElement &element , char readflag , EziDebugModule* module)
{
    return 0 ;
}

int EziDebugPrj::domParsePortDescriptionElement(const QDomElement &element ,char readflag, EziDebugModule* module)
{
    /*子节点数目是否为零*/
    if(!(element.childNodes().count()))
    {
        qDebug() << "domParsePortDescriptionElement Error:There is no port!";
        return 1 ;
    }
    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "port")
        {
            if(ichild.toElement().attribute("port_name").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("module_name").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("direction_type").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("bitwidth").isEmpty())
            {
                return 1 ;
            }

#if 0
            if(ichild.toElement().attribute("endian").isEmpty())
            {
                return 1 ;
            }


            if(!((ichild.toElement().attribute("endian").toLower() == "little")\
                 ||(ichild.toElement().attribute("endian").toLower()== "big")))
            {
                return 1 ;
            }
#endif

            if(!((ichild.toElement().attribute("direction_type").toLower() == "in")\
                 ||(ichild.toElement().attribute("direction_type").toLower() == "out")\
                 ||(ichild.toElement().attribute("direction_type").toLower() == "inout")))
            {
                return 1 ;
            }

            if(readflag & READ_MODULE_INFO)
            {
                if(module)
                {
                    EziDebugModule::PortStructure * pport= new EziDebugModule::PortStructure ;

                    // pport->m_isEndian     = (ichild.toElement().attribute("endian").toLower() == "big");

                    //pport->m_pModuleName     = (char*)malloc(ichild.toElement().attribute("module_name").size()+1);
                    memcpy(pport->m_pModuleName,ichild.toElement().attribute("module_name").toAscii().data(),ichild.toElement().attribute("module_name").size()+1);

                    //pport->m_pPortName     = (char*)malloc(ichild.toElement().attribute("port_name").size()+1);
                    memcpy(pport->m_pPortName,ichild.toElement().attribute("port_name").toAscii().data(),ichild.toElement().attribute("port_name").size()+1);

                    if(ichild.toElement().attribute("direction_type").toLower() == "in")
                    {
                        pport->eDirectionType =  EziDebugModule::directionTypeInput ;
                    }
                    else if(ichild.toElement().attribute("direction_type").toLower() == "out")
                    {
                         pport->eDirectionType =  EziDebugModule::directionTypeOutput ;
                    }
                    else
                    {
                         pport->eDirectionType =  EziDebugModule::directionTypeInoutput ;
                    }

                    memset(pport->m_pBitWidth,0,64) ;
                    if(ichild.toElement().attribute("bitwidth").size() <= 63)
                    {
                        qstrcpy(pport->m_pBitWidth ,ichild.toElement().attribute("bitwidth").toAscii().constData());
                    }

                    if(pport)
                    {
                        module->m_iportVec.append(pport);
                    }
                    else
                    {
                        return 1 ;
                    }
                }
                else
                {
                    qDebug() << "readPortStructure: NULL Pointer!";
                    return 1 ;
                }
            }
        }
        else
        {
            qDebug() << "domParsePortDescriptionElement Error : There is strange element in the file!";
            return 1 ;
        }
        ichild = ichild.nextSibling();
    }
    return 0 ;
}

int EziDebugPrj::domParseInstancePortMapDescriptionElement(const QDomElement &element,char readflag, EziDebugModule* module)
{
    /*子节点数目是否为零*/
    if(!(element.childNodes().count()))
    {
        qDebug() << "EziDebug Info:There is no instance port map !";
        return 0 ;
    }
    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "instance")
        {
            if(ichild.toElement().attribute("instance_name").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("port_map").isEmpty())
            {
                return 1 ;
            }
        }

        if(readflag & READ_MODULE_INFO)
        {
            if(module)
            {
               int i = 0 ;
               QString iinstanceName = ichild.toElement().attribute("instance_name") ;
               QMap<QString,QString> iportMap ;
               QString iportMapStr = ichild.toElement().attribute("port_map") ;
               QStringList iportMapList = iportMapStr.split('#');
               for(;i < iportMapList.count() ;i++)
               {
                   iportMap.insert(iportMapList.at(i).split('@').at(0),iportMapList.at(i).split('@').at(1));
               }
               module->m_iinstancePortMap.insert(iinstanceName,iportMap) ;
            }
            else
            {
                qDebug() << "domParsePortDescriptionElement Error : The pmodule is NULL pointer!";
                return 1 ;
            }
        }
        ichild = ichild.nextSibling();
    }
    return 0 ;
}

int EziDebugPrj::domParsePortStructure(const QDomElement &element, char readflag , EziDebugModule* module)
{
    return 0 ;
}

int EziDebugPrj::domParseScanChainInfoElement(const QDomElement &element,char readflag)
{
    QString ichainName ;
    QString iscanRegCore ;
    QString itoutCore ;
    QString iuserDir ;
    EziDebugScanChain *pchainObj = NULL ;

    if(element.attribute("scanreg_core_name").toLower() != "no core")
    {
        iscanRegCore = element.attribute("scanreg_core_name");
    }
    else
    {
        iscanRegCore = "No Core";
    }

    if(element.attribute("tout_core_name").toLower() != "no core")
    {
        itoutCore = element.attribute("tout_core_name");
    }
    else
    {
        itoutCore = "No Core" ;
    }

    if(element.attribute("user_dir").toLower() != "no dir")
    {
        iuserDir = element.attribute("user_dir");
    }
    else
    {
        iuserDir = "No Dir" ;
    }

    EziDebugScanChain::saveEziDebugAddedInfo(iscanRegCore , itoutCore , iuserDir) ;

    /*子节点数目是否为零*/
    if(!(element.childNodes().count()))
    {
        qDebug() << "EziDebug Info: There is no Scan chain infomation!";
        return 0 ;
    }


    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "chain")
        {
            if(ichild.toElement().attribute("chain_name").isEmpty())
            {
                return 1 ;
            }

//            if(ichild.toElement().attribute("instance_list").isEmpty())
//            {
//                return 1 ;
//            }
            if(ichild.toElement().attribute("scaned_file_list").isEmpty())

            {
                return 1 ;
            }

            if(ichild.toElement().attribute("system_output").isEmpty())
            {
                return 1 ;
            }

            ichainName = ichild.toElement().attribute("chain_name") ;

            if(readflag&READ_CHAIN_INFO)
            {
                pchainObj = new EziDebugScanChain(ichainName) ;
                if(!pchainObj)
                {
                    qDebug() << "Error: domParseScanChainInfoElement :There is no memory left !" ;
                    return 1 ;
                }
                pchainObj->m_iinstanceItemList = ichild.toElement().attribute("instance_list").split("|") ;
                pchainObj->m_iscanedFileNameList = ichild.toElement().attribute("scaned_file_list").split("|") ;
                if(ichild.toElement().attribute("system_output")!= "No Sysoutput")
                {
                    pchainObj->m_isysCoreOutputPortList = ichild.toElement().attribute("system_output").split("@") ;
                }
            }

           //
            /*解析扫描链结构*/
            if(domParseScanChainStructure(ichild.toElement() , readflag , pchainObj))
            {
                qDebug() << "domParseScanChainInfoElement Error :chaininfo format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "domParseScanChainInfoElement Error : There is strange element in the file!";
            return 1 ;
        }
        ichild = ichild.nextSibling();
    }
    return 0 ;
}

int EziDebugPrj::domParseScanChainStructure(const QDomElement &element,char readflag, EziDebugScanChain *chain)
{
    /*子节点数目是否为零*/
    int echainStructureExistFlag = 0 ;
    if(element.childNodes().count() != 2)
    {
        qDebug() << "domParseScanChainStructure Error:There is no fileinfo!";
        return 1 ;
    }
    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "reglist_description")
        {
            echainStructureExistFlag |= SCAN_CHAIN_STRUCTURE_REGLIST_DESCRIPTION ;
            if(domParseReglistDescriptionElement(ichild.toElement() , readflag , chain))
            {
                qDebug() << "domParseScanChainStructure Error :fileinfo format is not right!";
                return 1 ;
            }
        }
        else if(ichild.toElement().tagName() == "code_description")
        {
            echainStructureExistFlag |= SCAN_CHAIN_STRUCTURE_CODE_DESCRIPTION ;
            if(domParseCodeDescriptionElement(ichild.toElement() , readflag , chain))
            {
                qDebug() << "domParseScanChainStructure Error :reginfo format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "domParseScanChainStructure Error : There is strange element in the file!";
            return 1 ;
        }
        ichild = ichild.nextSibling();
    }

    if((echainStructureExistFlag&SCAN_CHAIN_STRUCTURE_ALL_DESCRIPTION) == SCAN_CHAIN_STRUCTURE_ALL_DESCRIPTION )
    {
        if(readflag&READ_CHAIN_INFO)
        {
            m_ichainInfoMap.insert(chain->m_iChainName,chain);
        }
        return 0 ;
    }
    else
    {
        return 1 ;
    }

    return 0 ;
}

int EziDebugPrj::domParseReglistDescriptionElement(const QDomElement &element,char readflag, EziDebugScanChain *chain)
{
    QVector<QStringList> iregListVec ;

    /*子节点数目是否为零*/
    if(!(element.childNodes().count()))
    {
        qDebug() << "domParseReglistDescriptionElement Error:There is no fileinfo!";
        return 1 ;
    }
    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if(ichild.toElement().tagName() == "regchain")
        {
            if(ichild.toElement().attribute("reglist").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("insertclock").isEmpty())
            {
                return 1 ;
            }

            if(readflag&READ_CHAIN_INFO)
            {
                if(chain)
                {
                   QString iinsertClock = ichild.toElement().attribute("insertclock") ;

                   int nregCount = ichild.toElement().attribute("regcount").toInt();

                   chain->m_nregCountMap.insert(iinsertClock,nregCount);

                   QStringList ireglist = ichild.toElement().attribute("reglist").split("@") ;

                   iregListVec.append(ireglist);

                   chain->m_iregChainStructure.insert(iinsertClock,iregListVec) ;
                }
                else
                {
                    return 1 ;
                }
            }

        }
        else
        {
            qDebug() << "domParseReglistStructure Error : There is unknown element in the EziDebug file!";
            return 1 ;
        }
        ichild = ichild.nextSibling();
    }
    return 0 ;
}

//int EziDebugPrj::domParseReglistStructure(const QDomElement &element,char readflag, EziDebugScanChain *chain)
//{
//    /*子节点数目是否为零*/
//    if(!(element.childNodes().count()))
//    {
//        qDebug() << "domParseReglistStructure Error:There is no fileinfo!";
//        return 1 ;
//    }
//    QDomNode ichild = element.firstChild();
//    /*扫描子节点 ，是否存在下一个子节点*/
//    while (!ichild.isNull())
//    {
//        if(ichild.toElement().tagName() == "regchain")
//        {
//            if(ichild.toElement().attribute("reglist").isEmpty())
//            {
//                return 1 ;
//            }

//            if(readflag&READ_CHAIN_INFO)
//            {
//                if(chain)
//                {
//                   QStringList ireglist = ichild.toElement().attribute("reglist").split("|") ;
//                   QList<EziDebugScanChain::RegListStructure*> itempRegList ;
//                   for (int i = 0; i < ireglist.size(); i++)
//                   {
//                       QStringList isinglereglist = ireglist.at(i).split("%") ;
//                       EziDebugScanChain::RegListStructure* preg = new  EziDebugScanChain::RegListStructure ;
//                       preg->m_pnamehiberarchy =  (char*)malloc(isinglereglist.at(0).size()+1);
//                       memcpy(preg->m_pnamehiberarchy,isinglereglist.at(0).toAscii().data(),isinglereglist.at(0).size()+1);

//                       preg->m_pregName = (char*)malloc(isinglereglist.at(1).size()+1) ;
//                       memcpy(preg->m_pregName,isinglereglist.at(1).toAscii().data(),isinglereglist.at(1).size()+1);

//                       preg->m_pclock = (char*)malloc(isinglereglist.at(2).size()+1);
//                       memcpy(preg->m_pclock,isinglereglist.at(2).toAscii().data(),isinglereglist.at(2).size()+1);

//                       preg->m_nbitwidth = isinglereglist.at(3).toInt();
//                       preg->m_nstartbit = isinglereglist.at(4).toInt();
//                       preg->m_nendbit = isinglereglist.at(5).toInt();

//                       itempRegList.append(preg);
//                       chain->m_iregChainStructure.append(itempRegList);
//                   }
//                }
//                else
//                {
//                    return 1 ;
//                }
//            }

//        }
//        else
//        {
//            qDebug() << "domParseReglistStructure Error : There is unknown element in the EziDebug file!";
//            return 1 ;
//        }
//        ichild = ichild.nextSibling();
//    }
//    return 0 ;
//}

int EziDebugPrj::domParseCodeDescriptionElement(const QDomElement &element,char readflag, EziDebugScanChain *chain)
{
    if(!(element.childNodes().count()))
    {
        qDebug() << "domParseCodeDescriptionElement Error:There is no codedescription int ScanChain infomation!";
        return 1 ;
    }
    QDomNode ichild = element.firstChild();
    /*扫描子节点 ，是否存在下一个子节点*/
    while (!ichild.isNull())
    {
        if (ichild.toElement().tagName() == "added_code")
        {
            if(ichild.toElement().attribute("module_name").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("user_line_code").isEmpty())
            {
                return 1 ;
            }

            if(ichild.toElement().attribute("user_block_code").isEmpty())
            {
                return 1 ;
            }


            if(readflag&READ_CHAIN_INFO)
            {
                if(chain)
                {
                    chain->m_icodeMap.insert(ichild.toElement().attribute("module_name"),ichild.toElement().attribute("user_line_code").split("#"));
                    if(ichild.toElement().attribute("user_block_code").toLower() != "no code")
                    {
                        chain->m_iblockCodeMap.insert(ichild.toElement().attribute("module_name"),ichild.toElement().attribute("user_block_code").split("#"));
                    }
                }
                else
                {
                    return 1 ;
                }
            }

        }
        else
        {
            qDebug() << "domParseCodeStructure Error : There is unknown element in the EziDebug file!";
            return 1 ;
        }
        ichild = ichild.nextSibling();
    }
    return 0 ;
}


//int EziDebugPrj::domParseCodeStructure(const QDomElement &element,char readflag ,EziDebugScanChain * chain)
//{
//    /*子节点数目是否为零*/
//    if(!(element.childNodes().count()))
//    {
//        qDebug() << "domParseScanChainStructure Error:There is no fileinfo!";
//        return 1 ;
//    }
//    QDomNode ichild = element.firstChild();
//    /*扫描子节点 ，是否存在下一个子节点*/
//    while (!ichild.isNull())
//    {
//        if (ichild.toElement().tagName() == "added_code")
//        {
//            if(ichild.toElement().attribute("module_name").isEmpty())
//            {
//                return 1 ;
//            }

//            if(ichild.toElement().attribute("user_code").isEmpty())
//            {
//                return 1 ;
//            }

//            if(ichild.toElement().attribute("user_core_code").isEmpty())
//            {
//                return 1 ;
//            }

//            if(readflag&READ_CHAIN_INFO)
//            {
//                if(chain)
//                {
//                    chain->m_icodeMap.insert(ichild.toElement().attribute("module_name"),ichild.toElement().attribute("user_code").split("#"));
//                    chain->m_iuserDefineCoreMap.insert(ichild.toElement().attribute("module_name"),ichild.toElement().attribute("user_core_code"));
//                }
//                else
//                {
//                    return 1 ;
//                }
//            }

//        }
//        else
//        {
//            qDebug() << "domParseCodeStructure Error : There is unknown element in the EziDebug file!";
//            return 1 ;
//        }
//        ichild = ichild.nextSibling();
//    }
//    return 0 ;
//}


// 读取log文件中的 有关文件的信息
int EziDebugPrj::readFileInfo(char readflag)
{
    // 过程中只能遇到三种类型的 xml 标签
    bool  isFileInfoExist = 0 ;
    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "FILE_INFO")
            {
                /*do nothing! 继续读取 文件信息*/
                isFileInfoExist = 1 ;

                if(readFileStructure(readflag))
                    return 1 ;
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file is not complete!";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file's format is not right!";
                return 1 ;
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name()== "FILE_INFO")
            {
                /*存在 FILE_INFO 标签*/
                if(isFileInfoExist)
                {
                    return 0 ;
                }
                else
                {
                    /*不存在 FILE_INFO 开始标签*/
                    qDebug() << "There is not label \"FILE_INFO\"'s StartElement !" ;
                    return 1 ;
                }
            }
            else
            {
                qDebug() << "readFileInfo: The log file is not complete!" ;
                return 1 ;
            }
        }
        else
        {
            qDebug() << "readFileInfo: the log file format is not right!";
            return 1 ;
        }
    }
    return 0 ;
}


int EziDebugPrj::readFileStructure(char readflag)
{
    // 过程中只能遇到三种类型的 xml 标签
    QString  ifileName ;
    QDateTime idateTime ;
    QDate idate ;
    QTime itime ;
    QStringList imoduleList ;
    bool  isFileStructureInfoExist = 0 ;
    int   nfileStructureInfoCount = 0 ;

    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "file")
            {
                isFileStructureInfoExist = 1 ;
                nfileStructureInfoCount++ ;
                if(m_ireader.attributes().value("filename").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("modify_date").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("modify_time").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("module_array").isEmpty())
                {
                    return 1 ;
                }

                ifileName = m_ireader.attributes().value("filename").toString();
                imoduleList = m_ireader.attributes().value("filename").toString().split(QRegExp("\\s+"));
                QStringList idateList = m_ireader.attributes().value("modify_date").toString().split("/") ;
                QStringList itimeList = m_ireader.attributes().value("modify_time").toString().split(":") ;

                idate = QDate(idateList.at(2).toInt(),idateList.at(0).toInt(),idateList.at(1).toInt()) ;
                itime = QTime(itimeList.at(0).toInt(),itimeList.at(1).toInt(),itimeList.at(2).toInt()) ;

                idateTime = QDateTime(idate,itime) ;
                if((ifileName.endsWith(".v",Qt::CaseSensitive))&&(readflag|READ_FILE_INFO))
                {
                    /*创建文件对象指针 并加入工程对象的文件map中*/
                    EziDebugVlgFile * pvlgFileObj = new EziDebugVlgFile(ifileName,idateTime,imoduleList);
                    m_ivlgFileMap.insert(ifileName,pvlgFileObj);
                    m_ireader.readNext() ;
                }
                else if((ifileName.endsWith(".vhd",Qt::CaseSensitive))&&(readflag|READ_FILE_INFO))
                {
                    /*创建文件对象指针 并加入工程对象的文件map中*/
                    EziDebugVhdlFile * pvlgFileObj = new EziDebugVhdlFile(ifileName,idateTime,imoduleList);
                    m_ivhdlFileMap.insert(ifileName,pvlgFileObj);
                    m_ireader.readNext() ;
                }
                else
                {
                    qDebug() << "The log file format is not right(the source code file type is not right)!";
                    return 1 ;
                }
            }
            else
            {
                qDebug() << "the log file is not complete!";
                return 1 ;
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name() == "file")
            {
                if(1 == isFileStructureInfoExist)
                {
                    m_ireader.readNext();
                    isFileStructureInfoExist = 0 ;
                }
                else
                {
                    qDebug() << "The Label File Has No endElement!" ;
                    return 1 ;
                }
            }
            else if(m_ireader.name() == "FILE_INFO")
            {
                if(!nfileStructureInfoCount)
                {
                    qDebug() << "there is not file info exist!" ;
                    return 1 ;
                }
                else
                {
                    return 0 ;
                }
            }
            else
            {
                qDebug() << "end element is not completed";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file's format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "the log file is not right!";
            return 1 ;
        }
    }
    return 0 ;
}

int EziDebugPrj::readModuleInfo(char readflag)
{
    // 过程中只能遇到三种类型的 xml 标签
    bool  isModuleInfoExist = 0 ;

    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "MODULE_INFO")
            {
                /*继续读取 文件信息*/
                isModuleInfoExist = 1 ;
                /*读取topmodule信息*/
                if(m_ireader.attributes().value("topmodule").isEmpty())
                {
                    qDebug()<< "readModuleInfo: There is no top Module in the log file! ";
                    return 1 ;
                }
                else
                {
                    // 从默认路径下恢复 数据结构时  需要topmodule ，正常流程下 topmodule 会一致么 ?
                    if(m_ireader.attributes().value("topmodule").toString() != m_itopModule)
                    {
                        //重新设置topmodule
                        qDebug()<< "readModuleInfo: The topmodule in log file is not agree with QSF file";
                        return 1 ;
                    }
                }
                if(readModuleStructure(readflag))
                    return 1 ;
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file is not complete!";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file's format is not right!";
                return 1 ;
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name()== "MODULE_INFO")
            {
                /*存在 MODULE_INFO 标签*/
                if(isModuleInfoExist)
                {
                    return 0 ;
                }
                else
                {
                    /*不存在 MODULE_INFO 开始标签*/
                    qDebug() << "The Label \"MODULE_INFO\" Has no StartElement !" ;
                    return 1 ;
                }
            }
            else
            {
                qDebug() << "readModuleInfo: The log file is not complete!" ;
                return 1 ;
            }
        }
        else
        {
            qDebug() << "readModuleInfo: the log file format is not right!";
            return 1 ;
        }
    }
    return 0 ;
}

int EziDebugPrj::readModuleStructure(char readflag)
{
    // 过程中只能遇到三种类型的 xml 标签
    QString imoduleName ;

//    QStringList iclockNameList ;

//    EziDebugModule::RegStructure* preg ;
//    EziDebugModule::PortStructure *pport ;

    EziDebugModule * pmoduleObj = NULL ;

    bool  isModuleStructureInfoExist = 0 ;
    int   nModuleStructureInfoCount = 0 ;


    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "module")
            {
                isModuleStructureInfoExist = 1 ;
                nModuleStructureInfoCount++ ;

                if(m_ireader.attributes().value("name").isEmpty())
                {
                    return 1 ;
                }

                /*
                if(m_ireader.attributes().value("appearance_count").isEmpty())
                {
                    return 1 ;
                }
                */
                if(m_ireader.attributes().value("lib_core").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("file_name").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("array_name").isEmpty())
                {
                    return 1 ;
                }

                if(readflag & READ_MODULE_INFO)
                {
                    /*创建module对象指针 并加入工程对象的module map中*/
                    imoduleName = m_ireader.attributes().value("name").toString();

                    EziDebugModule *ptempModuleObj = new EziDebugModule(imoduleName);
                    if(!ptempModuleObj)
                        return 1 ;
                    pmoduleObj = ptempModuleObj ;

                    m_imoduleMap.insert(imoduleName,ptempModuleObj);
                    ptempModuleObj->m_imoduleName       = m_ireader.attributes().value("name").toString();
                    //ptempModuleObj->m_ninstanceTimes   = static_cast<bool>(m_ireader.attributes().value("appearance_count").toString().toInt()) ;
                    ptempModuleObj->m_isLibaryCore      = (m_ireader.attributes().value("lib_core").toString().toLower() == "yes") ;
                    ptempModuleObj->m_ilocatedFile      = m_ireader.attributes().value("file_name").toString() ;
                    ptempModuleObj->m_iinstanceNameList = m_ireader.attributes().value("file_name").toString().split("|");

                }

                if(!readClockDescription(readflag , pmoduleObj))
                {
                    if(!readRegDescription(readflag , pmoduleObj))
                    {
                        if(!readPortDescription(readflag , pmoduleObj))
                        {
                            m_ireader.readNext();
                        }
                        else
                        {
                            if(pmoduleObj)
                            {
                                delete pmoduleObj ;
                                pmoduleObj = NULL ;
                                qDebug() << "after readPortDescription ,There is no memory left !";
                                return 1 ;
                            }
                        }
                    }
                    else
                    {
                        if(pmoduleObj)
                        {
                            delete pmoduleObj ;
                            pmoduleObj = NULL ;
                            qDebug() << "after readRegDescription ,There is no memory left !";
                            return 1 ;
                        }
                    }
                }
                else
                {
                    if(pmoduleObj)
                    {
                        delete pmoduleObj ;
                        pmoduleObj = NULL ;
                        qDebug() << "after readClockDescription ,There is no memory left !";
                        return 1 ;
                    }

                }
            }
            else
            {
                qDebug() << "readModuleStructure:The Label module is not complete!";
                return 1 ;
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name() == "module")
            {
                if(1 == isModuleStructureInfoExist)
                {
                    m_ireader.readNext();
                    isModuleStructureInfoExist = 0 ;
                }
                else
                {
                    qDebug() << "readModuleStructure:The Label File Has No endElement!" ;
                    return 1 ;
                }
            }
            else if(m_ireader.name() == "FILE_INFO")
            {
                if(!isModuleStructureInfoExist)
                {
                    qDebug() << "readModuleStructure:there is not file info exist!" ;
                    return 1 ;
                }
                else
                {
                    return 0 ;
                }
            }
            else
            {
                qDebug() << "readModuleStructure:end element is not completed";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "readModuleStructure:the log file's format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "readModuleStructure:the log file is not right!";
            return 1 ;
        }
    }
    return 0 ;
}

int EziDebugPrj::readClockDescription(char readflag, EziDebugModule* module)
{
    bool  isClockDescriptionMarkExist = 0 ;
    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "clock_description")
            {
                isClockDescriptionMarkExist = 1 ;
                if(readClockStructure(readflag,module))
                {
                    qDebug() << "readClockDescription: ClockStructure has some problem!";
                    return 1 ;
                }
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name() == "clock_description")
            {
                if(1 == isClockDescriptionMarkExist)
                {
                    return 0 ;
                }
                else
                {
                    qDebug() << "readClockDescription:The Label clock_description Has No StartElement!" ;
                    return 1 ;
                }
            }
            else
            {
                qDebug() << "readClockDescription:The Label clock_description Has No EndElement!";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "readClockDescription:the log file's format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "readClockDescription:the log file is not right!";
            return 1 ;
        }
    }
    return 0 ;
}

int EziDebugPrj::readClockStructure(char readflag, EziDebugModule* module)
{
    // 过程中只能遇到三种类型的 xml 标签
    bool  isClockStructureInfoExist = 0 ;
    int   nclockStructureInfoCount = 0 ;
    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "clock")
            {
                isClockStructureInfoExist = 1 ;
                nclockStructureInfoCount++ ;

                if(m_ireader.attributes().value("clock_name").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("polarity").isEmpty())
                {
                    return 1 ;
                }

                if(!(m_ireader.attributes().value("polarity").toString().toLower().compare("posedge")\
                     &m_ireader.attributes().value("polarity").toString().toLower().compare("negedge")))
                {
                    return 1 ;
                }

                if(readflag & READ_MODULE_INFO)
                {
                    if(module)
                    {

                        QString iclockName  = m_ireader.attributes().value("clock_name").toString();
                        module->m_iclockMap.insert(iclockName,m_ireader.attributes().value("polarity").toString());
                    }
                    else
                    {
                        qDebug() << "readClockStructure: NULL Pointer!";
                        return 1 ;
                    }

                }
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file is not complete!";
                return 1 ;
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name() == "clock")
            {
                if(1 == isClockStructureInfoExist)
                {
                    m_ireader.readNext();
                    isClockStructureInfoExist = 0 ;
                }
                else
                {
                    qDebug() << "The Label clock Has No StartElement!" ;
                    return 1 ;
                }
            }
            else if(m_ireader.name() == "clock_description")
            {
                if(!nclockStructureInfoCount)
                {
                    qDebug() << "there is not clock structure info exist!" ;
                    return 1 ;
                }
                else
                {
                    return 0 ;
                }
            }
            else
            {
                qDebug() << "end element is not completed";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file's format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "the log file is not right!";
            return 1 ;
        }
    }
    return 0 ;
}

int EziDebugPrj::readRegDescription(char readflag , EziDebugModule* module)
{
    bool  isRegDescriptionMarkExist = 0 ;
    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "reg_description")
            {
                isRegDescriptionMarkExist = 1 ;
                if(readRegStructure(readflag,module))
                {
                    qDebug() << "readRegDescription: readRegStructure has some problem!";
                    return 1 ;
                }
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name() == "reg_description")
            {
                if(1 == isRegDescriptionMarkExist)
                {
                    return 0 ;
                }
                else
                {
                    qDebug() << "readRegDescription:The Label reg_description Has No StartElement!" ;
                    return 1 ;
                }
            }
            else
            {
                qDebug() << "readRegDescription:The Label reg_description Has No EndElement!";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "readClockDescription:the log file's format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "readClockDescription:the log file is not right!";
            return 1 ;
        }
    }
    return 0 ;
}

int EziDebugPrj::readRegStructure(char readflag , EziDebugModule* module)
{
    // 过程中只能遇到三种类型的 xml 标签
    bool  isRegStructureInfoExist = 0 ;
    int   nregStructureInfoCount = 0 ;
    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "reg")
            {
                isRegStructureInfoExist = 1 ;
                nregStructureInfoCount++ ;

                if(m_ireader.attributes().value("module_name").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("locate_clock").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("reg_name").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("bitwidth").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("regnum").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("endian").isEmpty())
                {
                    return 1 ;
                }

                if(!(m_ireader.attributes().value("endian").toString().toLower().compare("little")\
                     &m_ireader.attributes().value("endian").toString().toLower().compare("big")))
                {
                    return 1 ;
                }

                if(readflag & READ_MODULE_INFO)
                {
                    if(module)
                    {
                        EziDebugModule::RegStructure * preg= new EziDebugModule::RegStructure ;
//                      preg->m_isEndian     = static_cast<bool>(m_ireader.attributes().value("endian").toString().toLower().compare("little"));

                        memcpy(preg->m_pMouduleName,m_ireader.attributes().value("module_name").toString().toAscii().data(),sizeof(preg->m_pMouduleName));
                        memcpy(preg->m_pRegName,m_ireader.attributes().value("reg_name").toString().toAscii().data(),sizeof(preg->m_pRegName));

//                      preg->m_unBitWidth   = m_ireader.attributes().value("bitwidth").toString().toInt();
                        preg->m_unRegNum     = m_ireader.attributes().value("regnum").toString().toInt();
                        QString iclockName   = m_ireader.attributes().value("locate_clock").toString();
                        QVector<EziDebugModule::RegStructure*> iregStructureVec = module->m_iregMap.value(iclockName) ;
                        iregStructureVec.append(preg);
                        module->m_iregMap.insert(iclockName,iregStructureVec);
                    }
                    else
                    {
                        qDebug() << "readRegStructure: NULL Pointer!";
                        return 1 ;
                    }
                }
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "readRegStructure: the log file is not complete!(There is no reg)";
                return 1 ;
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name() == "reg")
            {
                if(1 == isRegStructureInfoExist)
                {
                    m_ireader.readNext();
                    isRegStructureInfoExist = 0 ;
                }
                else
                {
                    qDebug() << "The Label reg Has No StartElement!" ;
                    return 1 ;
                }
            }
            else if(m_ireader.name() == "reg_description")
            {
                if(!nregStructureInfoCount)
                {
                    qDebug() << "there is not reg structure info exist!" ;
                    return 1 ;
                }
                else
                {
                    return 0 ;
                }
            }
            else
            {
                qDebug() << "end element is not completed";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file's format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "the log file is not right!";
            return 1 ;
        }
    }
    return 0 ;
}


int EziDebugPrj::readPortDescription(char readflag , EziDebugModule* module)
{
    bool  isPortDescriptionMarkExist = 0 ;
    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "port_description")
            {
                isPortDescriptionMarkExist = 1 ;
                if(readPortStructure(readflag,module))
                {
                    qDebug() << "readPortDescription: readPortStructure has some problem!";
                    return 1 ;
                }
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name() == "port_description")
            {
                if(1 == isPortDescriptionMarkExist)
                {
                    return 0 ;
                }
                else
                {
                    qDebug() << "readPortDescription:The Label port_description Has No StartElement!" ;
                    return 1 ;
                }
            }
            else
            {
                qDebug() << "readPortDescription:The Label port_description Has No EndElement!";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "readPortDescription:the log file's format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "readPortDescription:the log file is not right!";
            return 1 ;
        }
    }
    return 0 ;
}

int EziDebugPrj::readPortStructure(char readflag , EziDebugModule* module)
{
    // 过程中只能遇到三种类型的 xml 标签
    bool  isPortStructureInfoExist = 0 ;
    int   nPortStructureInfoCount = 0 ;
    /*读取下一个有效的开始 标签*/
    m_ireader.readNext();
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "reg")
            {
                isPortStructureInfoExist = 1 ;
                nPortStructureInfoCount++ ;

                if(m_ireader.attributes().value("port_name").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("module_name").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("direction_type").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("bitwidth").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("endian").isEmpty())
                {
                    return 1 ;
                }

                if(!(m_ireader.attributes().value("endian").toString().toLower().compare("little")\
                     &m_ireader.attributes().value("endian").toString().toLower().compare("big")))
                {
                    return 1 ;
                }

                if(!(m_ireader.attributes().value("direction_type").toString().toLower().compare("in")\
                     &m_ireader.attributes().value("direction_type").toString().toLower().compare("out")))
                {
                    return 1 ;
                }

                if(readflag & READ_MODULE_INFO)
                {
                    if(module)
                    {
                        EziDebugModule::PortStructure * pport= new EziDebugModule::PortStructure ;
                        // pport->m_isEndian     = static_cast<bool>(m_ireader.attributes().value("endian").toString().toLower().compare("little"));

                        //pport->m_pModuleName = m_ireader.attributes().value("module_name").toString().toAscii().data();
                        memcpy(pport->m_pModuleName,m_ireader.attributes().value("module_name").toString().toAscii().data(),m_ireader.attributes().value("module_name").size()+1);

                        if(m_ireader.attributes().value("direction_type").toString().toLower() == "in")
                        {
                            pport->eDirectionType =  EziDebugModule::directionTypeInput ;
                        }
                        else if(m_ireader.attributes().value("direction_type").toString().toLower() == "out")
                        {
                             pport->eDirectionType =  EziDebugModule::directionTypeInput ;
                        }
                        else
                        {
                            delete pport ;
                            return 1 ;
                        }
                        pport->m_unBitwidth   = m_ireader.attributes().value("bitwidth").toString().toInt();
                        //pport->m_pPortName     = m_ireader.attributes().value("regnum").toString().toAscii().data();
                        memcpy(pport->m_pPortName,m_ireader.attributes().value("regnum").toString().toAscii().data(),m_ireader.attributes().value("regnum").size()+1);

                        if(pport)
                        {
                            module->m_iportVec.append(pport);
                        }
                        else
                        {
                            return 1 ;
                        }
                    }
                    else
                    {
                        qDebug() << "readPortStructure: NULL Pointer!";
                        return 1 ;
                    }
                }
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "readPortStructure: the log file is not complete!(There is no reg)";
                return 1 ;
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name() == "port")
            {
                if(1 == isPortStructureInfoExist)
                {
                    m_ireader.readNext();
                    isPortStructureInfoExist = 0 ;
                }
                else
                {
                    qDebug() << "The Label port Has No StartElement!" ;
                    return 1 ;
                }
            }
            else if(m_ireader.name() == "port_description")
            {
                if(!nPortStructureInfoCount)
                {
                    qDebug() << "there is not port structure info exist!" ;
                    return 1 ;
                }
                else
                {
                    return 0 ;
                }
            }
            else
            {
                qDebug() << "end element is not completed";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file's format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "the log file is not right!";
            return 1 ;
        }
    }


    return 0 ;
}


int EziDebugPrj::readScanChainInfo(char readflag)
{
    // 过程中只能遇到三种类型的 xml 标签
    QString  ifileName ;
    QDateTime idateTime ;
    QDate idate ;
    QTime itime ;
    QStringList imoduleList ;
    bool  isFileStructureInfoExist = 0 ;
    int   nfileStructureInfoCount = 0 ;
    m_ireader.readNext();
    /*读取下一个有效的开始 标签*/
    while(!m_ireader.atEnd())
    {
        if(m_ireader.isStartElement())
        {
            if(m_ireader.name() == "file")
            {
                isFileStructureInfoExist = 1 ;
                nfileStructureInfoCount++ ;
                if(m_ireader.attributes().value("filename").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("modify_date").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("modify_time").isEmpty())
                {
                    return 1 ;
                }

                if(m_ireader.attributes().value("module_array").isEmpty())
                {
                    return 1 ;
                }

                ifileName = m_ireader.attributes().value("filename").toString();
                imoduleList = m_ireader.attributes().value("filename").toString().split(QRegExp("\\s+"));
                QStringList idateList = m_ireader.attributes().value("modify_date").toString().split("/") ;
                QStringList itimeList = m_ireader.attributes().value("modify_time").toString().split(":") ;

                idate = QDate(idateList.at(2).toInt(),idateList.at(0).toInt(),idateList.at(1).toInt()) ;
                itime = QTime(itimeList.at(0).toInt(),itimeList.at(1).toInt(),itimeList.at(2).toInt()) ;

                idateTime = QDateTime(idate,itime) ;
                if((ifileName.endsWith(".v",Qt::CaseSensitive))&&(readflag|READ_FILE_INFO))
                {
                    /*创建文件对象指针 并加入工程对象的文件map中*/
                    EziDebugVlgFile * pvlgFileObj = new EziDebugVlgFile(ifileName,idateTime,imoduleList);
                    m_ivlgFileMap.insert(ifileName,pvlgFileObj);
                    continue ;
                }
                else if((ifileName.endsWith(".vhd",Qt::CaseSensitive))&&(readflag|READ_FILE_INFO))
                {
                    /*创建文件对象指针 并加入工程对象的文件map中*/
                    EziDebugVhdlFile * pvlgFileObj = new EziDebugVhdlFile(ifileName,idateTime,imoduleList);
                    m_ivhdlFileMap.insert(ifileName,pvlgFileObj);
                    continue ;
                }
                else
                {
                    qDebug() << "The log file format is not right(the source code file type is not right)!";
                    return 1 ;
                }
            }
            else
            {
                qDebug() << "the log file is not complete!";
                return 1 ;
            }
        }
        else if(m_ireader.isEndElement())
        {
            if(m_ireader.name() == "file")
            {
                if(1 == isFileStructureInfoExist)
                {
                    m_ireader.readNext();
                    isFileStructureInfoExist = 0 ;
                }
                else
                {
                    qDebug() << "The Label File Has No endElement!" ;
                    return 1 ;
                }
            }
            else if(m_ireader.name() == "FILE_INFO")
            {
                if(!nfileStructureInfoCount)
                {
                    qDebug() << "there is not file info exist!" ;
                    return 1 ;
                }
                else
                {
                    return 0 ;
                }
            }
            else
            {
                qDebug() << "end element is not completed";
                return 1 ;
            }
        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                qDebug() << "the log file's format is not right!";
                return 1 ;
            }
        }
        else
        {
            qDebug() << "the log file is not right!";
            return 1 ;
        }
    }
    return 0 ;
}

/*检测 log 文件 是否 OK */
int EziDebugPrj::detectLogFile(char nreadFlag)
{
            QFile file(m_ilogFileName);

        #ifdef Parse_by_QXmlStreamReader
            bool  isFileMarkExist = 0 ;
        #endif

            if (!file.open(QFile::ReadOnly | QFile::Text))
            {
                qDebug() << "Error: Cannot read file " << qPrintable(m_ilogFileName) \
                          << ": " << qPrintable(file.errorString()) << __LINE__ << __FILE__;
                return 1 ;
            }

        #ifdef Parse_by_QDom
            QString ierrorStr;
            int nerrorLine;
            int nerrorColumn;

            QDomDocument idoc ;
            if (!idoc.setContent(&file, false, &ierrorStr, &nerrorLine,
                                &nerrorColumn)) {
                qDebug() << "Error: Parse error at line " << nerrorLine << ", "
                          << "column " << nerrorColumn << ": "
                          << qPrintable(ierrorStr) ;
                return 1 ;
            }

    QDomElement irootElement = idoc.documentElement();

    if (irootElement.tagName() != "EziDebug")
    {
        qDebug() << "detectLogFile Error: Not a EziDebug file" ;
        return 1 ;
    }

    if(domParseEziDebugElement(irootElement,nreadFlag))
    {
        file.close();
        return 1 ;
    }
#endif

#ifdef Parse_by_QXmlStreamReader

    m_ireader.setDevice(&file);
    m_ireader.readNext();

    while (!m_ireader.atEnd())
    {
        if (m_ireader.isStartElement())
        {
            QStringRef ielement = m_ireader.name();
            QString ielementString = ielement.toString();
            if (ielementString == "EZIDEBUG")
            {
                isFileMarkExist = 1 ;

                if(readFileInfo(nreadFlag))
                {
                    qDebug() << "detectLogFile: encounter some problem in readFileInfo!";
                    file.close();
                    return 1 ;
                }
                else
                {
                    if(readModuleInfo(nreadFlag))
                    {
                        qDebug() << "detectLogFile: encounter some problem in readModuleInfo!";
                        file.close();
                        return 1 ;
                    }
                    else
                    {
                        m_ireader.readNext();
                        if(readScanChainInfo(nreadFlag))
                        {
                            qDebug() << "detectLogFile: encounter some problem in readScanChainInfo!";
                            file.close();
                            return 1 ;
                        }
                    }
                }
            }
            else if(m_ireader.isEndElement())
            {
                if(m_ireader.name() == "EZIDEBUG")
                {
                    if(isFileMarkExist)
                    {
//                        return 0 ;
                        // do nothing !
                    }
                    else
                    {
                        qDebug() << "detectLogFile: \"EZIDEBUG\" has no StartElement ";
                        file.close();
                        return 1 ;
                    }
                }
                else
                {
                    qDebug() << "detectLogFile: This Is Not a EziDebug File!";
                    file.close();
                    return 1 ;
                }
            }
            else
            {
                m_ireader.raiseError(QObject::tr("Not a EZIDEBUG file"));
                file.close();
                return 1 ;
            }

        }
        else if(m_ireader.isCharacters())
        {
            QRegExp icomExp("\\s+");
            if(icomExp.exactMatch(m_ireader.text().toString()))
            {
                m_ireader.readNext();
            }
            else
            {
                break ;
            }
        }
        else if(m_ireader.isStartDocument())
        {
            m_ireader.readNext();
        }
        else
        {
            qDebug() << "the saved logfile format is not right, needed to scan the whole prject again!" ;
            file.close();
            return 1 ;
        }
    }
#endif
    file.close();
    return 0 ;
}

int EziDebugPrj::updatePrjAllFile(const QStringList& addfilelist,const QStringList& delfilelist,const QStringList& chgfilelist,QList<LOG_FILE_INFO*>& addinfolist , QList<LOG_FILE_INFO*> &deleteinfolist ,bool updateFlag)
{
    int i = 0 ;
    QStringList ifileList ;
    ifileList = delfilelist ;
    /*获取删除的文件信息*/
    /*找到相应的文件对象，删除有关的结构，然后释放对象指针*/
    for(; i < ifileList.count(); i++)
    {

        eliminateFile(ifileList.at(i),deleteinfolist);
        preupdateProgressBar(updateFlag,(10+(i/ifileList.count())*10));

    }
    ifileList.clear();
    ifileList = addfilelist ;
    /*获取增加的文件信息*/
    /*扫描新添加的文件、创建文件对象指针、加入相应的结构*/
    for(i = 0 ; i < ifileList.count() ; i++)
    {
        preupdateProgressBar(updateFlag,(20+(i/ifileList.count())*15));

        if(addFile(ifileList.at(i),partScanType,addinfolist))
        {   
            #if 0
            QMessageBox::StandardButton rb = QMessageBox::question(NULL, tr("扫描文件错误"), tr("是否继续扫描?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
			#else
            QMessageBox::StandardButton rb = QMessageBox::question(NULL, tr("EziDebug"), tr("Scan file Error , do you want to continue to scan file ?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
			#endif
			
            if(rb == QMessageBox::Yes)
            {
               ++i;
               continue ;
            }
            else
            {
                return 1 ;
            }
        }
    }

    ifileList.clear();
    ifileList = chgfilelist ;
    /*获取更改的文件信息*/
    /*扫描被更改的文件、创建文件对象指针、加入相应的结构 */
    for(i = 0 ; i < ifileList.count() ; i++)
    {
        QString irelativeFileName = ifileList.at(i);
        if(ifileList.at(i).endsWith(".v"))
        {
            EziDebugVlgFile* pfile = m_ivlgFileMap.value(ifileList.at(i)) ;

            preupdateProgressBar(updateFlag,(35+(i/ifileList.count())*15));

            if(!pfile->scanFile(this,partScanType,addinfolist,deleteinfolist))
            {
                // 文件被修改了 需要重新保存文件日期
                LOG_FILE_INFO* pdelFileInfo = new LOG_FILE_INFO ;
                pdelFileInfo->etype = infoTypeFileInfo ;
                pdelFileInfo->pinfo = NULL ;
                memcpy(pdelFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
                deleteinfolist.append(pdelFileInfo);

                struct LOG_FILE_INFO* paddFileInfo = new LOG_FILE_INFO ;
                paddFileInfo->etype = infoTypeFileInfo ;
                paddFileInfo->pinfo = pfile ;
                memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data(), irelativeFileName.size()+1);
                addinfolist.append(paddFileInfo);
            }
            else
            {
                // 如果出错 ,提示是否继续扫描
                #if 0
                QMessageBox::StandardButton rb = QMessageBox::question(NULL, tr("扫描文件错误"), tr("是否继续扫描?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
                #else
                QMessageBox::StandardButton rb = QMessageBox::question(NULL, tr("EziDebug"), tr("Scan file Error , do you want to continue to scan file ?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
                #endif

                if(rb == QMessageBox::Yes)
                {
                   ++i;
                   continue ;
                }
                else
                {
                    return 1 ;
                }
            }
        }
        else if(ifileList.at(i).endsWith(".vhd"))
        {
            EziDebugVhdlFile* pfile = m_ivhdlFileMap.value(ifileList.at(i)) ;
//            if(!pfile->scanFile(currentPrj,EziDebugPrj::partScanType,iaddedinfoList,ideletedinfoList))
//            {

//            }
//            else
//            {
//                // 如果出错 ,提示是否继续扫描
//            }
        }
        else
        {

        }
    }
    return  0 ;
}

void EziDebugPrj::preupdateProgressBar(bool updateflag ,int value)
{
    if(updateflag)
    {
        emit updateProgressBar(value);
    }
}

void EziDebugPrj::compareFileList(const QStringList& newfilelist,QStringList& addFileList,QStringList &delFileList,QStringList &chgFileList)
{
    std::list<QString> ideletedFileList(m_iCodefileNameList.count()) ;
    std::list<QString> iidenticalFileList(m_iCodefileNameList.count()) ;
    std::list<QString> iaddedFileList(m_iCodefileNameList.count()) ;

    std::list<QString>::iterator ioutDelIterator = ideletedFileList.begin() ;
    std::list<QString>::iterator ioutIdenticalIterator = iidenticalFileList.begin() ;
    std::list<QString>::iterator ioutAddIterator = iaddedFileList.begin() ;

    //newfilelist.sort();
    QStringList::const_iterator ifirstBeginIterator = newfilelist.begin() ;
    QStringList::const_iterator ifirstEndIterator = newfilelist.end() ;

    m_iCodefileNameList.sort();
    QStringList::Iterator iSecondBeginIterator = m_iCodefileNameList.begin() ;
    QStringList::Iterator iSecondEndIterator = m_iCodefileNameList.end() ;

    // ifirstBeginIterator 最新文件列表   iSecondBeginIterator 旧的文件列表
    std::set_difference(ifirstBeginIterator,ifirstEndIterator,iSecondBeginIterator,iSecondEndIterator,ioutDelIterator);

    addFileList = QList<QString>::fromStdList(ideletedFileList) ;
    addFileList = delFileList.filter(QRegExp(QObject::tr(".+"))) ;


    std::set_difference(iSecondBeginIterator,iSecondEndIterator,ifirstBeginIterator,ifirstEndIterator,ioutAddIterator);
    delFileList = QList<QString>::fromStdList(iaddedFileList);
    delFileList = addFileList.filter(QRegExp(QObject::tr(".+"))) ;


    std::set_intersection(ifirstBeginIterator,ifirstEndIterator,iSecondBeginIterator,iSecondEndIterator,ioutIdenticalIterator);

    ioutIdenticalIterator = iidenticalFileList.begin() ;
    while(ioutIdenticalIterator != iidenticalFileList.end())
    {
        QFileInfo itempFileInfo(m_iprjPath,*ioutIdenticalIterator);
        QDateTime idateTime = itempFileInfo.lastModified() ;


        if((*ioutIdenticalIterator).endsWith(".v"))
        {
            QDateTime ilastDateTime = m_ivlgFileMap.value(*ioutIdenticalIterator)->getLastStoredTime();
            if(idateTime.toString("dd.MM.yyyy hh:mm:ss") != ilastDateTime.toString("dd.MM.yyyy hh:mm:ss"))
            {
                qDebug() << idateTime << ilastDateTime ;
                chgFileList.append(*ioutIdenticalIterator);
            }
        }
        else if((*ioutIdenticalIterator).endsWith(".vhd"))
        {
            QDateTime ilastDateTime = m_ivhdlFileMap.value(*ioutIdenticalIterator)->getLastStoredTime();
            if(idateTime != ilastDateTime)
            {
                chgFileList.append(*ioutIdenticalIterator);
            }
        }
        else
        {
            // do nothing
        }
        ++ioutIdenticalIterator ;
     }

    if(addFileList.count()&&delFileList.count()&&chgFileList.count())
    {
        m_isUpdated = true ;
    }
}

int EziDebugPrj::domParseEziDebugElement(const QDomElement &element,char readflag)
{
    QDomNode ichild = element.firstChild();
    bool  eeziDebugFileStructureExistFlag = 0 ;
    qDebug() << "Attention: Begin to detect the log file!";

    while(!ichild.isNull())
    {
        if(ichild.toElement().tagName() == "FILE_INFO")
        {
            eeziDebugFileStructureExistFlag |= EZIDEBUG_STRUCTURE_FILE ;
            if(domParseFileInfoElement(ichild.toElement(),readflag))
            {
                qDebug() << "domParseEziDebugElement Error: function domParseFileInfoElement return wrong!" ;
                goto Error ;
            }
        }
        else if(ichild.toElement().tagName() == "MODULE_INFO")
        {
            eeziDebugFileStructureExistFlag |= EZIDEBUG_STRUCTURE_MODULE ;
            if(domParseModuleInfoElement(ichild.toElement(),readflag))
            {
                qDebug() << "domParseEziDebugElement Error: function domParseModuleInfoElement return wrong!" ;
                goto Error ;
            }
        }
        else if(ichild.toElement().tagName() == "SCAN_CHAIN_INFO")
        {
            eeziDebugFileStructureExistFlag |= EZIDEBUG_STRUCTURE_SCAN_CHAIN ;
            if(domParseScanChainInfoElement(ichild.toElement(),readflag))
            {
                qDebug() << "domParseEziDebugElement Error: function domParseScanChainInfoElement return wrong!" ;
                goto Error ;
            }
        }
        else
        {
            qDebug() << "domParseEziDebugElement Error: There is unknown element in the EziDebug File!" ;
            goto Error ;
        }

        ichild = ichild.nextSibling();
    }

    if((eeziDebugFileStructureExistFlag&EZIDEBUG_STRUCTURE_ALL) == EZIDEBUG_STRUCTURE_ALL)
    {
        goto Error ;
    }

    return 0 ;

Error:
    return 1 ;

}

const int &EziDebugPrj::getMaxRegNumPerChain(void) const
{
    return  m_nmaxRegNumInChain ;
}

int EziDebugPrj::setToolType(TOOL tool)
{
    if(ToolOther <= tool)
    {
       //QMessageBox::warning(0,QObject::tr("设置工具类型"),QObject::tr("确认工具是否正确"))；

        return 1 ;
    }
    m_eusedTool = tool ;
    return 0 ;
}

int EziDebugPrj::setMaxRegNumPerChain(int num)
{
    /*需要 判断 个数是否在 范围中 */
    m_nmaxRegNumInChain = num ;
    return 0 ;
}


void EziDebugPrj::setLogFileExistFlag(bool flag)
{
    m_isLogFileExist =  flag ;
    return ;
}

void EziDebugPrj::setXilinxErrCheckedFlag(bool flag)
{
    m_isDisXilinxErrChecked = flag ;
}

void EziDebugPrj::setLogFileName(const QString& filename)
{
    m_ilogFileName = filename ;
    return ;
}

void EziDebugPrj::setMaxRegWidth(int width)
{
    if(m_imaxRegWidth < width)
    {
        m_imaxRegWidth = width ;
    }
}

void EziDebugPrj::setLogfileDestroyedFlag(bool flag)
{
    m_isLogFileDestroyed = flag ;
}

bool EziDebugPrj::getLogfileDestroyedFlag(void)
{
    return m_isLogFileDestroyed ;
}

int EziDebugPrj::parsePrjFile(QMap<QString,EziDebugVlgFile*> &vlgFileMap ,QMap<QString,EziDebugVhdlFile*> &vhdlFileMap)
{
    m_iCodefileNameList.clear();
    if(ToolQuartus == m_eusedTool)
    {
        if(parseQuartusPrjFile(vlgFileMap,vhdlFileMap))
        {
            qDebug() << "Error:Parse Quartus PrjFile failed!" ;
            return 1 ;
        }
    }
    else if(ToolIse == m_eusedTool)
    {
        if(parseIsePrjFile(vlgFileMap,vhdlFileMap))
        {
            qDebug() << "Error:Parse ISE PrjFile failed!" ;
            return 1 ;
        }
    }
    else
    {
        qDebug() << "EziDebug is not support this sortware project file parse!";
        return 1 ;
    }

    // QMessageBox::information(0, QObject::tr("EziDebug解析文件"),QObject::tr("可以继续试验了"));

    return 0 ;
}

void EziDebugPrj::checkDelFile(QMap<QString,EziDebugVlgFile*> &vlgFileMap , QMap<QString,EziDebugVhdlFile*> &vhdlFileMap , QList<LOG_FILE_INFO*> &deleteinfolist)
{
    QMap<QString,EziDebugVlgFile*>::const_iterator i =  m_ivlgFileMap.constBegin();
    while(i != m_ivlgFileMap.constEnd())
    {
        QString ifileName = i.key() ;
        EziDebugVlgFile* pnewFile = vlgFileMap.value(ifileName,NULL);
        if(!pnewFile)
        {
            struct LOG_FILE_INFO* pdelFileInfo = new LOG_FILE_INFO ;
            pdelFileInfo->etype = infoTypeFileInfo ;
            pdelFileInfo->pinfo = NULL ;
            memcpy(pdelFileInfo->ainfoName , ifileName.toAscii().data() , ifileName.size()+1);
            deleteinfolist.append(pdelFileInfo);
        }
        ++i ;
    }

    QMap<QString,EziDebugVhdlFile*>::const_iterator j = m_ivhdlFileMap.constBegin() ;
    while(j != m_ivhdlFileMap.constEnd())
    {
        QString ifileName = j.key() ;
        EziDebugVhdlFile* pnewFile = vhdlFileMap.value(ifileName,NULL);
        if(!pnewFile)
        {
            struct LOG_FILE_INFO* pdelFileInfo = new LOG_FILE_INFO ;
            pdelFileInfo->etype = infoTypeFileInfo ;
            pdelFileInfo->pinfo = NULL ;
            memcpy(pdelFileInfo->ainfoName , ifileName.toAscii().data() , ifileName.size()+1);
            deleteinfolist.append(pdelFileInfo);
        }
        ++j ;
    }

}

void EziDebugPrj::updateFileMap(const QMap<QString,EziDebugVlgFile*> &vlgFileMap ,const QMap<QString,EziDebugVhdlFile*> &vhdlFileMap)
{
    EziDebugVlgFile* poldVlgFile = NULL ;
    EziDebugVhdlFile* poldVhdlFile = NULL ;
    EziDebugVlgFile* pnewVlgFile = NULL ;
    EziDebugVhdlFile* pnewVhdlFile = NULL ;
    QMap<QString,EziDebugVlgFile*>::const_iterator ivlgFileIter = m_ivlgFileMap.constBegin() ;
     QMap<QString,EziDebugVhdlFile*>::const_iterator ivhdlFileIter = m_ivhdlFileMap.constBegin() ;

    while(ivlgFileIter != m_ivlgFileMap.constEnd())
    {
        poldVlgFile = ivlgFileIter.value() ;
        delete poldVlgFile ;
        poldVlgFile = NULL ;
        ++ivlgFileIter ;
    }
    m_ivlgFileMap.clear();

    while(ivhdlFileIter != m_ivhdlFileMap.constEnd())
    {
        poldVhdlFile = ivhdlFileIter.value() ;
        delete poldVhdlFile ;
        poldVhdlFile = NULL ;
        ++ivhdlFileIter ;
    }
    m_ivhdlFileMap.clear();

    if(vlgFileMap.count()!= 0)
    {
        ivlgFileIter = vlgFileMap.constBegin();
        while(ivlgFileIter != vlgFileMap.constEnd())
        {
            pnewVlgFile = ivlgFileIter.value() ;
            m_ivlgFileMap.insert(ivlgFileIter.key() , pnewVlgFile);
            ++ivlgFileIter ;
        }

    }

    if(vhdlFileMap.count()!= 0)
    {
        ivhdlFileIter = vhdlFileMap.constBegin();
        while(ivhdlFileIter != vhdlFileMap.constEnd())
        {
            pnewVhdlFile = ivhdlFileIter.value() ;
            m_ivhdlFileMap.insert(ivhdlFileIter.key() , pnewVhdlFile);
            ++ivhdlFileIter ;
        }
    }
}

int EziDebugPrj::traverseAllCodeFile(EziDebugPrj::SCAN_TYPE type , const QMap<QString,EziDebugVlgFile*> &vlgFileMap ,const QMap<QString,EziDebugVhdlFile*> &vhdlFileMap ,QList<LOG_FILE_INFO*> &addedinfoList,QList<LOG_FILE_INFO*> &deletedinfoList)
 {
     //QList<LOG_FILE_INFO*> iaddedinfoList ;
     //QList<LOG_FILE_INFO*> ideletedinfoList ;
     QString irelativeFileName ;
     EziDebugVlgFile* poldVlgFile = NULL ;
     EziDebugVhdlFile* poldVhdlFile = NULL ;
     EziDebugVlgFile* pnewVlgFile = NULL ;
     EziDebugVhdlFile* pnewVhdlFile = NULL ;
     int nfileCount = 0 ;

     /*解析每个代码文件*/
     qDebug() <<  QObject::tr("EziDebug::Begin traverAllCodeFile!");
     /* 遍历 verilog 文件 获取 所有 module 信息*/
     // 15 + (i/vlgFileMap.count())*45
     if(vlgFileMap.count()!= 0)
     {
         QMap<QString,EziDebugVlgFile*>::const_iterator i = vlgFileMap.constBegin();
         while(i != vlgFileMap.constEnd())
         {
             pnewVlgFile = i.value() ;
             irelativeFileName = i.key() ;
             if(pnewVlgFile)
             {
                 if(pnewVlgFile->scanFile(this,type,addedinfoList,deletedinfoList))
                 {
                     qDebug() << "traverseAllCodeFile:scan file failed! FILE NAME" << i.key();
                     //dynamic_cast<QWidget*>(this->parent())
                     #if 0
                     QMessageBox::StandardButton rb = QMessageBox::question(NULL, tr("扫描文件错误"), tr("是否继续扫描?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
                     #else
                     QMessageBox::StandardButton rb = QMessageBox::question(NULL, tr("EziDebug"), tr("Scan file Error , do you want to continue to scan file ?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
                     #endif

                     if(rb == QMessageBox::Yes)
                     {
                        ++i;
                        continue ;
                     }
                     else
                     {
                         return 1 ;
                     }
                 }
                 else
                 {
                     // 已经存在 扫描文件
                     if((poldVlgFile = m_ivlgFileMap.value(i.key(),NULL)))
                     {
                         if((poldVlgFile->getLastStoredTime() != pnewVlgFile->getLastStoredTime())\
                                 ||(poldVlgFile->getModuleList() == pnewVlgFile->getModuleList()))
                         {
                             struct LOG_FILE_INFO* pdelFileInfo = new LOG_FILE_INFO ;
                             pdelFileInfo->etype = infoTypeFileInfo ;
                             pdelFileInfo->pinfo = NULL ;
                             memcpy(pdelFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
                             deletedinfoList.append(pdelFileInfo);

                             // 新增文件
                             struct LOG_FILE_INFO* paddFileInfo = new LOG_FILE_INFO ;
                             paddFileInfo->etype = infoTypeFileInfo ;
                             paddFileInfo->pinfo = pnewVlgFile ;
                             memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data(), irelativeFileName.size()+1);
                             addedinfoList.append(paddFileInfo);
                         }
//                       m_ivlgFileMap.remove(i.key());
//                       delete poldVlgFile ;
                     }
                     else
                     {
                         // 新增文件
                         struct LOG_FILE_INFO* paddFileInfo = new LOG_FILE_INFO ;
                         paddFileInfo->etype = infoTypeFileInfo ;
                         paddFileInfo->pinfo = pnewVlgFile ;
                         memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
                         addedinfoList.append(paddFileInfo);
                     }
//                   m_ivlgFileMap.insert(i.key() , pnewVlgFile);
                     ++i;
                     emit updateProgressBar(15 + (nfileCount/vlgFileMap.count())*45);
                     nfileCount++ ;
                     continue ;
                 }
             }
             else
             {
                 qDebug() << "null fileobj pointer!";
             }
             ++i;
         }
	     
     }

     /* 遍历 vhdl 文件 获取 所有 module 信息*/
     if(vhdlFileMap.count() != 0)
     {
         QMap<QString,EziDebugVhdlFile*>::const_iterator i = vhdlFileMap.constBegin();
         while(i != vhdlFileMap.constEnd())
         {
             if(i.value())
             {
                 //(i.value())->scanFile();
             }
             else
             {
                 qDebug() << "null fileobj pointer!";
                 return 1 ;
             }
             ++i;
         }
     }

     qDebug() << QObject::tr("EziDebug:: finish tranverse all code file!");
	 
     return 0 ;
 }

int EziDebugPrj::resumeDataFromFile(void)
{

    return 0 ;
}

int EziDebugPrj::generateTreeView(void)
{
    QStringList imoduleList ;
    QString itopModuleName = m_itopModule + QObject::tr(":")+ m_itopModule ;

    if(!m_imoduleMap.contains(m_itopModule))
    {
        qDebug() << "EziDebug Error: There is no Topmodule definition!";
        return 1;
    }

    /*根据topmodule 构造树状显示结构的数据信息*/
    //  if (!m_imoduleMap.contains(m_itopModule))
    //  {
    //        qDebug() << " there is not topModule!";
    //        return 1 ;
    //  }

    EziDebugInstanceTreeItem* item = new EziDebugInstanceTreeItem(m_itopModule,m_itopModule);
    if(!item)
    {
        qDebug() << "Error:There is no memory left!";
        return 1 ;
    }
    m_headItem = item ;
    //return (traverseModuleTree(itopModuleName,item));
    return(traverseModuleTree(itopModuleName,item)) ;
}

int EziDebugPrj::traverseModuleTree(const QString &module,EziDebugInstanceTreeItem* item)
{
    QString iparentItemModuleName = module.split(":").at(0);
    QString iparentItemInstanceName = module.split(":").at(1);
    QMap<QString,QString> iparentClockMap = m_imoduleMap.value(iparentItemModuleName)->getClockSignal();
    QStringList iinstanceList ;
    QString ihierarchyName  ;
   // QMap<QString,QString> iclockSignalMap = m_imoduleMap.value(pchildItem->getModuleName())->getClockSignal() ;
    QMap<QString,QString> ichildClockMap ;
    QMap<QString,QString>::const_iterator  iclockIter = iparentClockMap .constBegin();
    QMap<QString,QString> iparentResetMap = m_imoduleMap.value(iparentItemModuleName)->getResetSignal();
    QMap<QString,QString> ichildResetMap ;

    // 创建本节点  然后再根据 子module 创建 子节点
    EziDebugInstanceTreeItem* pparentItem = item ;
    if(!pparentItem)
    {
        qDebug() << "Error:There is no memory left!" ;
        return 1 ;
    }

    if(iparentItemModuleName == m_itopModule)
    {   
        qDebug() << "This is topModule!" ; 
        pparentItem->settItemHierarchyName(ihierarchyName);
    }
    else
    {   
        ihierarchyName = pparentItem->parent()->getItemHierarchyName();
        ihierarchyName = ihierarchyName ;
        ihierarchyName.append(QObject::tr("%1:%2|").arg(iparentItemModuleName).arg(iparentItemInstanceName));
        pparentItem->settItemHierarchyName(ihierarchyName);
        // chainInfo 有值 、treeitem无值
        if((m_ichainInfoMap.count())&&(!m_ichainTreeItemMap.count()))
        {
            QMap<QString,EziDebugScanChain*>::const_iterator i =  m_ichainInfoMap.constBegin() ;
            while(i != m_ichainInfoMap.constEnd())
            {
                EziDebugScanChain *pchain = i.value() ;
                if(pchain)
                {
                    QString itopInstanceNode = pchain->getInstanceItemList().last();
                    if(itopInstanceNode == module)
                    {
                        pparentItem->setScanChainInfo(pchain);
                        pchain->setHeadTreeItem(pparentItem);
                        m_ibackupChainTreeItemMap.insert(pchain->getChainName(),pparentItem);
                        m_iqueryTreeItemMap.insert(module,pparentItem);
                        m_ichainInfoMap.remove(i.key());
                        break ;
                    }
                }
                ++i ;
            }
        }
    }


    if(m_imoduleMap.contains(iparentItemModuleName))
    {
        iinstanceList = (m_imoduleMap.value(iparentItemModuleName))->getInstanceList();

        // 将所有的defparameter 记录到 module中方便 计算寄存器宽度
        QMap<QString,QString> idefparameterMap =  m_idefparameter.value(iparentItemInstanceName);
        QMap<QString,QString>::const_iterator iiterrator = idefparameterMap.constBegin() ;
        while(iiterrator != idefparameterMap.constEnd())
        {
            m_imoduleMap.value(iparentItemModuleName)->addToDefParameterMap(iparentItemInstanceName,iiterrator.key(),iiterrator.value());
            ++iiterrator ;
        }
        m_imoduleMap.value(iparentItemModuleName)->calInstanceRegData(this,iparentItemInstanceName);
        // 将寄存器宽度 所有的 宏全部替换

    }
    else
    {
        qDebug() << "Error:module:" << iparentItemModuleName << "has no definition !" << "Can't finded in module map!"  ;
        return 1 ;
    }

    if(!(iinstanceList.count()))
    {
        return 0 ;
    }
    else
    {
        for(int i = 0 ; i < iinstanceList.count();i++)
        {
            QString ichildItemCombinedName = iinstanceList.at(i) ;
            QString ichildItemModuleName = (ichildItemCombinedName.split(":")).at(0) ;

            // 每个子例化名
            if(!m_imoduleMap.value(ichildItemModuleName,NULL))
            {
                qDebug() << "Warnning:: module:" << ichildItemModuleName << "has no definition!";
                continue  ;
            }

            // 确定　子module 与　父module 之间的　clock 对应关系
            QString ichildItemInstanceName = (ichildItemCombinedName.split(":")).at(1) ;
            EziDebugInstanceTreeItem * pchildItem = new EziDebugInstanceTreeItem(ichildItemInstanceName,ichildItemModuleName);
            if(!pchildItem)
            {
                qDebug() << "Error:There is not memory left !" ;
                return 1 ;
            }

            pparentItem->appendChild(pchildItem);

            pchildItem->setItemParent(pparentItem);

            if(m_imoduleMap.value(pchildItem->getModuleName())->isLibaryCore())
            {
                // 专门为 libarycore 加入 层次名
                QString ichildhierarchyName = pparentItem->getItemHierarchyName();
                ichildhierarchyName.append(QObject::tr("%1:%2|").arg(ichildItemModuleName).arg(ichildItemInstanceName));
                pchildItem->settItemHierarchyName(ichildhierarchyName);
                continue ;
            }


            //            QString iparentClockName ;

            // 只针对单一时钟情况　遍历所有节点之前　　确保父节点　有 存在　clock
            //            QMap<QString,QString>::const_iterator iclockIter = iclockSignalMap.constBegin();
            //            int j = 0 ;
            //            if(!iparentClockMap.count())
            //            {
            //                /*检查 clock 是否 缺少*/
            //                /*根据子节点 的 port-map 和 子节点 的 clock 来找到 父节点 的 clock */
            //                QString icheckInstanceName = pchildItem->getInstanceName() ;
            //                QString icheckModuleName = pchildItem->getModuleName() ;

            //                if(!iclockSignalMap.count())
            //                {
            //                    qDebug() <<  "EziDebug Info: child module:"<< pchildItem->getModuleName() << "has no clock!";


            //                    while(!iclockSignalMap.count())
            //                    {
            //                        j++ ;
            //                        if(j >= iinstanceList.count())
            //                        {
            //                            qDebug() <<  "EziDebug Error: The module:" << iparentItemModuleName << "'s child instance is ignoreg for no clock!" ;
            //                            return 0 ;
            //                        }

            //                        icheckInstanceName = iinstanceList.at(i+j).split(":").at(1) ;
            //                        icheckModuleName = iinstanceList.at(i+j).split(':').at(0) ;
            //                        iclockSignalMap = m_imoduleMap.value(icheckModuleName)->getClockSignal();
            //                    }
            //                }
            //                else
            //                {
            //                    //iparentClockName = ;
            //                    if(iclockSignalMap.count()>1)
            //                    {
            //                        qDebug() <<  "EziDebug Error: It is not Supported muticlock domain!";
            //                        return 1 ;
            //                    }

            //                    iclockIter = iclockSignalMap.constBegin();
            //                    while(iclockIter != iclockSignalMap.constEnd())
            //                    {
            //                        iparentClockName = m_imoduleMap.value(pparentItem->getModuleName())->getInstancePortMap(pchildItem->getInstanceName()).value(iclockIter.key(),NULL);
            //                        if(iparentClockName.isEmpty())
            //                        {
            //                            qDebug() <<  "EziDebug Error: clock wire is not correspond to the clock port!";
            //                            return 1 ;
            //                        }
            //                        m_imoduleMap.value(pparentItem->getModuleName())->addToClockMap(iparentClockName);
            //                        ++iclockIter ;
            //                    }
            //                }



            //                if(iclockSignalMap.count()>1)
            //                {
            //                    qDebug() <<  "EziDebug Error: It is not Supported muticlock domain!";
            //                    return 1 ;
            //                }

            //                iclockIter = iclockSignalMap.constBegin();
            //                while(iclockIter != iclockSignalMap.constEnd())
            //                {
            //                    iparentClockName = m_imoduleMap.value(pparentItem->getModuleName())->getInstancePortMap(icheckInstanceName).value(iclockIter.key(),NULL);
            //                    if(iparentClockName.isEmpty())
            //                    {
            //                        qDebug() <<  "EziDebug Error: clock wire is not correspond to the clock port!";
            //                        return 1 ;
            //                    }
            //                    ++iclockIter ;
            //                }


            //                QString ichildClockName ;

            //                QVector<EziDebugModule::PortStructure*> iportVec = m_imoduleMap.value(pchildItem->getModuleName())->getPort() ;
            //                while(iclockIter != iclockSignalMap.constEnd())
            //                {
            //                    for(int j = 0 ; j < iportVec.count(); j++)
            //                    {
            //                        if(iclockIter.key() == QString::fromAscii(iportVec.at(j)->m_pPortName))
            //                        {
            //                            ichildClockName = iclockIter.key() ;
            //                            QMap<QString,QString> iportMap = m_imoduleMap.value(pparentItem->getModuleName())->getInstancePortMap(pchildItem->getInstanceName());
            //                            iparentClockName = iportMap.value(ichildClockName,QString()) ;
            //                            if(iparentClockName.isEmpty())
            //                            {
            //                                qDebug() <<  "Error: The clock is not correspond!";
            //                                return 1 ;
            //                            }

            //                            // 以后加上  检查 父节点端口 clock 和 例化端口 的 clock 是不是 一一对应的
            //                            if(m_imoduleMap.value(pparentItem->getModuleName())->getClockSignal().value(iparentClockName,QString()).isEmpty())
            //                            {
            //                                m_imoduleMap.value(pparentItem->getModuleName())->addToClockMap(iparentClockName);

            //                            }
            //                        }
            //                    }
            //                    ++iclockIter ;
            //                }


            //iclockSignalMap.clear();
            // 添加相应的 本module里面的 clock 和 子例化的 module clock 名字对应关系
            // 以后要 获取 是否 存在 clock 的别名，用于 clock 的 连接 <端口clock,别名clock>
            // 在找对应关系时 端口clock 和 instance 的clock 不匹配 ，则尝试用别名匹配


            QMap<QString,QMap<QString,QString> > iinstancePortMap = m_imoduleMap.value(iparentItemModuleName)->getInstancePortMap() ;
            QMap<QString,QString> ichildPortMap = iinstancePortMap.value(ichildItemInstanceName);
            //QMap<QString,QMap<QString,QString> >::const_iterator i = iinstancePortMap.constBegin() ;

            if(traverseModuleTree(ichildItemCombinedName,pchildItem))
            {
                qDebug() << "EziDebug Error: The node" << ichildItemCombinedName << "Travere Error!";

                pparentItem->removeChild(pchildItem);

                pchildItem->setItemParent(NULL);

                delete pchildItem ;

                return 1;
            }
            else
            {

                // 子节点的时钟 map , 将子节点的时钟 填充到 父节点 中 ,防止 父节点无时钟
                ichildClockMap =   m_imoduleMap.value(pchildItem->getModuleName())->getClockSignal() ;
                iclockIter = ichildClockMap.constBegin() ;
                while(iclockIter != ichildClockMap.constEnd())
                {
                    // 将所有子节点的时钟 加入 到 父节点的 时钟 map 中
                    // 应该 根据 iclockIter.key() 和  端口 列表 以及 端口对应关系 得到 父节点的时钟
                    // 目前不考虑  时钟名字 改变 即 子节点的时钟端口名与时钟名一致
                    QString iparentCLockName = ichildPortMap.value(iclockIter.key(),QString()) ;
                    if(!iparentCLockName.isEmpty())
                    {
                        m_imoduleMap.value(pparentItem->getModuleName())->addToClockMap(iparentCLockName);
                    }
                    ++iclockIter ;
                }

                // 子节点的时钟 map , 将子节点的时钟 填充到 父节点 中 ,防止 父节点无时钟
                ichildResetMap =   m_imoduleMap.value(pchildItem->getModuleName())->getResetSignal();
                iclockIter = ichildResetMap.constBegin() ;
                while(iclockIter != ichildResetMap.constEnd())
                {
                    // 将所有子节点的时钟 加入 到 父节点的 时钟 map 中
                    // 应该 根据 iclockIter.key() 和  端口 列表 以及 端口对应关系 得到 父节点的时钟
                    // 目前不考虑  时钟名字 改变 即 子节点的时钟端口名与时钟名一致
                    QString iparentResetName = ichildPortMap.value(iclockIter.key(),QString()) ;
                    QString iedge = iclockIter.value() ;
                    if(!iparentResetName.isEmpty())
                    {
                        m_imoduleMap.value(pparentItem->getModuleName())->addToResetSignalMap(iparentResetName,iedge);
                    }
                    ++iclockIter ;
                }

                //iclockSignalMap.clear();
                //iclockSignalMap =  m_imoduleMap.value(pparentItem->getModuleName())->getClockSignal() ;
            }
        }
        QMap<QString,QString> iclockMap ;

        iparentClockMap = m_imoduleMap.value(iparentItemModuleName)->getClockSignal();
        iparentResetMap = m_imoduleMap.value(iparentItemModuleName)->getResetSignal();


        // 遍历完所有节点之后 根据父节点 的 clock map 找到 填充 子节点 的 clock map
        // 填充 父节点的clock map

        for(int i = 0 ; i < pparentItem->childCount();i++)
        {
            iclockMap.clear();
            QString ichildModuleName = pparentItem->child(i)->getModuleName() ;
            QString ichildInstanceName = pparentItem->child(i)->getInstanceName() ;

            QMap<QString,QString> ichildPortMap = m_imoduleMap.value(iparentItemModuleName)->getInstancePortMap(ichildInstanceName) ;
            iclockIter = iparentClockMap.constBegin() ;
            ichildClockMap = m_imoduleMap.value(ichildModuleName)->getClockSignal();

            while(iclockIter != iparentClockMap.constEnd())
            {
                QString ichildClockName = ichildPortMap.key(iclockIter.key());

                if(!ichildClockName.isEmpty())
                {
                    QMap<QString,QMap<QString,QString> > iinstancesPortMap = m_imoduleMap.value(ichildModuleName)->getInstancePortMap();
                    QMap<QString,QMap<QString,QString> >::const_iterator iportMapIter = iinstancesPortMap.constBegin() ;
                    while(iportMapIter != iinstancesPortMap.constEnd())
                    {
                        QMap<QString,QString> iinstancePortMap = iportMapIter.value();

                        if(!(iinstancePortMap.key(ichildClockName,QString()).isEmpty()))
                        {
                            // 子节点用到了 这个 clock
                            m_imoduleMap.value(ichildModuleName)->addToClockMap(ichildClockName) ;
                            iclockMap.insert(iclockIter.key(),ichildClockName);
                        }
                        ++iportMapIter ;
                    }

                    //子节点 本身含有 这个clock
                    if(!ichildClockMap.value(ichildClockName,QString()).isEmpty())
                    {
                        iclockMap.insert(iclockIter.key(),ichildClockName);
                    }
                }
                ++iclockIter ;
            }
            pparentItem->setModuleClockMap(ichildInstanceName,iclockMap);


            iclockIter = iparentResetMap.constBegin() ;
            while(iclockIter != iparentResetMap.constEnd())
            {
                QString ichildResetSignalName = ichildPortMap.key(iclockIter.key());
                QString iedge = iclockIter.value() ;
                if(!ichildResetSignalName.isEmpty())
                {
                    QMap<QString,QMap<QString,QString> > iinstancesPortMap = m_imoduleMap.value(ichildModuleName)->getInstancePortMap();
                    QMap<QString,QMap<QString,QString> >::const_iterator iportMapIter = iinstancesPortMap.constBegin() ;
                    while(iportMapIter != iinstancesPortMap.constEnd())
                    {
                        QMap<QString,QString> iinstancePortMap = iportMapIter.value();

                        if(!(iinstancePortMap.key(ichildResetSignalName,QString()).isEmpty()))
                        {
                            // 子节点用到了 这个 clock
                            m_imoduleMap.value(ichildModuleName)->addToResetSignalMap(ichildResetSignalName,iedge);
                        }
                        ++iportMapIter ;
                    }
                }
                ++iclockIter ;
            }
        }
    }
    return 0 ;
}



EziDebugInstanceTreeItem * EziDebugPrj::getInstanceTreeHeadItem(void)
{
    return m_headItem ;
}

void EziDebugPrj::setInstanceTreeHeadItem(EziDebugInstanceTreeItem *item)
{
    m_headItem = item ;
    return ;
}

void EziDebugPrj::updateOperation(OPERATE_TYPE type, EziDebugScanChain* chain,EziDebugInstanceTreeItem* item)
{
    m_elastOperation = type ;
    m_pLastOperateChain = chain ;
    m_pLastOperteTreeItem = item ;

    if(OperateTypeNone == type)
    {
        m_ibackupChainInfoMap.clear();
        m_ibackupChainTreeItemMap.clear();
        m_ibackupQueryTreeItemMap.clear();
    }
    return ;
}

int  EziDebugPrj::changedLogFile(const QList<LOG_FILE_INFO*>& addlist, const QList<LOG_FILE_INFO*> &deletelist)
{
    QFile file(m_ilogFileName);

    if(!file.open(QFile::ReadOnly | QFile::Text))
    {
        qDebug() << "Error: Cannot read file " << qPrintable(m_ilogFileName) \
                  << ": " << qPrintable(file.errorString()) << __LINE__ << __FILE__;
        return 1 ;
    }

    QDomDocument idoc;
    QString ierrorStr;
    int nerrorLine;
    int nerrorColumn;

    if (!idoc.setContent(&file, false, &ierrorStr, &nerrorLine,&nerrorColumn))
    {
        qDebug() << "Error: Parse error at line " << nerrorLine << ", "
                  << "column " << nerrorColumn << ": "
                  << qPrintable(ierrorStr) ;
        return 1 ;
    }

    qDebug() << "changedLogFile" << __FILE__ << __LINE__ << deletelist.count();
    for(int i = 0 ; i < deletelist.count() ; i++)
    {
        LOG_FILE_INFO* pinfo = deletelist.at(i) ;
        if(deleteLogFileElement(idoc,pinfo))
        {
            file.close();
            return 1 ;
        }
    }
	
    for(int i = 0 ; i < addlist.count() ; i++)
    {
        LOG_FILE_INFO* pinfo = addlist.at(i) ;
        if(saveInfoToLogFile(idoc,pinfo))
        {
            file.close();
            qDebug() << "Error:save info!!!!" ;
            return 1 ;
        }
        qDebug() << "save info to log file " << i;
    }


    file.close();
    if(!file.open(QFile::WriteOnly | QIODevice::Truncate | QFile::Text))
    {
        qDebug() << "Error: Cannot write file " << qPrintable(m_ilogFileName) \
                  << ": " << qPrintable(file.errorString());
        return 1 ;
    }
    QTextStream iout(&file);
    iout.setCodec("UTF-8");
    idoc.save(iout,4,QDomNode::EncodingFromTextStream);
    file.close();
    return 0 ;
}


int EziDebugPrj::createLogFile(void)
{
    QString iuserDir = "No Dir";
    QString itoutCore = "No Core" ;
    QString iscanRegCore = "No Core" ;

    QDomDocument idoc;

    QDomElement iroot = idoc.createElement("EziDebug");

    idoc.appendChild(iroot);

    QDomElement ifileInfo = idoc.createElement("FILE_INFO");
    iroot.appendChild(ifileInfo);

    QDomElement imoduleInfo = idoc.createElement("MODULE_INFO");
    imoduleInfo.setAttribute("topmodule","No Module");
    iroot.appendChild(imoduleInfo);

    if(EziDebugScanChain::getChainRegCore().toLower() != "no core")
    {
        iscanRegCore = EziDebugScanChain::getChainRegCore() ;
    }

    if(EziDebugScanChain::getChainToutCore().toLower() != "no core")
    {
        itoutCore = EziDebugScanChain::getChainToutCore() ;
    }

    if(EziDebugScanChain::getUserDir().toLower() != "no dir")
    {
        iuserDir = EziDebugScanChain::getUserDir() ;
    }

    QDomElement iscanChainInfo = idoc.createElement("SCAN_CHAIN_INFO");
    iscanChainInfo.setAttribute("scanreg_core_name",iscanRegCore);
    iscanChainInfo.setAttribute("tout_core_name",itoutCore);
    iscanChainInfo.setAttribute("user_dir",iuserDir);
    iroot.appendChild(iscanChainInfo);

    QFile ifile(m_iprjPath.absoluteFilePath("config.ezi"));
    if (!ifile.open(QIODevice::WriteOnly | QIODevice::Truncate |QIODevice::Text))
    {
        return 1 ;
    }

    QTextStream iout(&ifile);

    iout.setCodec("UTF-8");

    idoc.save(iout,4,QDomNode::EncodingFromTextStream);
    m_ilogFileName = m_iprjPath.absoluteFilePath("config.ezi") ;
    ifile.close();
    return 0 ;
}

int EziDebugPrj::updateCodeFile()
{
    return 0 ;
}

int EziDebugPrj::saveInfoToLogFile(QDomDocument &idoc, LOG_FILE_INFO* loginfo)
{
    //void *info , INFO_TYPE type
    INFO_TYPE type = loginfo->etype ;
    void *info = loginfo->pinfo ;
    if(!loginfo)
    {
        qDebug() << "NULL Pointer!" << __LINE__ << __FILE__ ;
        return 1 ;
    }

    if(!info)
    {
        qDebug() << "NULL Pointer!" << __LINE__ << __FILE__ ;
        return 1 ;
    }

    if(type == infoTypeFileInfo)
    {   
    	//qDebug() << "saveInfoToLogFile!" << __LINE__ << __FILE__ ;
        EziDebugFile * pfile = static_cast<EziDebugFile*>(info);

        if(pfile->fileName().endsWith(".v"))
        {
            EziDebugVlgFile *pvlgFile = static_cast<EziDebugVlgFile*>(info);

            QDomElement ielement = idoc.elementsByTagName("FILE_INFO").at(0).toElement() ;
            QDomElement ifileElement = idoc.createElement("file") ;
            QStringList imoduleList = pvlgFile->getModuleList() ;
            QString imodule_array = imoduleList.join(",");

            ifileElement.setAttribute("file_name",m_iprjPath.relativeFilePath(pvlgFile->fileName()));
            ifileElement.setAttribute("module_array",imodule_array);
            QDateTime idateTime = pvlgFile->getLastStoredTime() ;
            QDate imodifiedDate =  idateTime.date();
            QTime imodifiedTime =  idateTime.time();

            if(imodifiedDate.isNull()||imodifiedTime.isNull())
            {
                qDebug() << "EziDebug Error: !!!!! save date and time error !!!!";
            }

            ifileElement.setAttribute("modified_date",imodifiedDate.toString("MM/dd/yyyy"));
            ifileElement.setAttribute("modified_time",imodifiedTime.toString("hh:mm:ss"));

            // macro
            QStringList imacroStrList ;

            QMap<QString,QString>::const_iterator imacroIter = pvlgFile->m_imacro.constBegin() ;
            while(imacroIter != pvlgFile->m_imacro.constEnd())
            {
                QString imacroStr = imacroIter.key() ;
                QString imacroVal = imacroIter.value() ;
                imacroStrList.append(imacroStr + tr("::") + imacroVal) ;
                ++imacroIter ;
            }

            if(imacroStrList.count())
            {
                ifileElement.setAttribute("macro",imacroStrList.join("$$"));
            }
            else
            {
                ifileElement.setAttribute("macro" , "No Macro");
            }

            // defparameter
            QStringList idefParamList ;
            QMap<QString,QMap<QString,QString> >::const_iterator idefParaIter = pvlgFile->m_idefparameter.constBegin() ;
            while(idefParaIter != pvlgFile->m_idefparameter.constEnd())
            {
                QString iinstanceName = idefParaIter.key() ;
                QMap<QString,QString> iparameterMap = idefParaIter.value() ;
                QMap<QString,QString>::const_iterator iparameterIter = iparameterMap.constBegin() ;
                while(iparameterIter != iparameterMap.constEnd())
                {
                    QString iparameterStr = iparameterIter.key() ;
                    QString iparameterVal = iparameterIter.value() ;
                    idefParamList.append(iinstanceName + tr(".") + iparameterStr + tr("::") + iparameterVal);
                    ++iparameterIter ;
                }
                ++idefParaIter ;
            }

            if(idefParamList.count())
            {
                ifileElement.setAttribute("defparameter",idefParamList.join("$$"));
            }
            else
            {
                ifileElement.setAttribute("defparameter", "No Defparam");
            }

            ielement.appendChild(ifileElement);

        }
    }
    else if(type == infoTypeModuleStructure)
    {   
    	//qDebug() << "saveInfoToLogFile!" << __LINE__ << __FILE__ ;
		
        EziDebugModule *pmodule = static_cast<EziDebugModule*>(info);
        QDomElement imoduleInfoElement = idoc.elementsByTagName("MODULE_INFO").at(0).toElement() ;

        if(imoduleInfoElement.attribute("topmodule").toLower() == "no module")
        {
            imoduleInfoElement.setAttribute("topmodule",m_itopModule);
        }

        //qDebug() << "saveInfoToLogFile!" << __LINE__ << __FILE__ ;

        QDomElement imoduleElement = idoc.createElement("module") ;
        imoduleElement.setAttribute("module_name",pmodule->m_imoduleName);
        //imoduleElement.setAttribute("appearance_count",QString::number(pmodule->m_ninstanceTimes));

        imoduleElement.setAttribute("lib_core",pmodule->m_isLibaryCore);
        imoduleElement.setAttribute("file_name",pmodule->m_ilocatedFile);

        if(!pmodule->m_iinstanceNameList.size())
        {
            imoduleElement.setAttribute("instance_array","No Instance");
        }
        else
        {
            imoduleElement.setAttribute("instance_array",pmodule->m_iinstanceNameList.join("|"));
        }

        //qDebug() << "saveInfoToLogFile!" << __LINE__ << __FILE__ ;

        QStringList iresetList ;
        QMap<QString,QString>::const_iterator i = pmodule->m_iresetMap.constBegin();
        while (i != pmodule->m_iresetMap.constEnd())
        {
            iresetList.append(i.key()+ QObject::tr(":") + i.value());
			++i;
        }

        if(iresetList.size())
        {
            imoduleElement.setAttribute("reset_signal",iresetList.join("|"));
        }
        else
        {
            imoduleElement.setAttribute("reset_signal","No Reset Signal");
        }

        // 插入parameter 参数
        QStringList ipraramList ;
        QMap<QString,QString>::const_iterator iparamIter = pmodule->m_iparameter.constBegin() ;
        while(iparamIter != pmodule->m_iparameter.constEnd())
        {
            QString iparamStr = iparamIter.key() ;
            QString iparamVal = iparamIter.value() ;
            ipraramList.append(iparamStr + tr("::") + iparamVal);
            ++iparamIter ;
        }

        if(ipraramList.count())
        {
            imoduleElement.setAttribute("parameter",ipraramList.join("$$"));
        }
        else
        {
            imoduleElement.setAttribute("parameter","No Parameter");
        }


        QDomElement iclockDescriptionElement = idoc.createElement("clock_description") ;
        QMap<QString,QString>::const_iterator j = pmodule->m_iclockMap.constBegin();
        while (j != pmodule->m_iclockMap.constEnd())
        {
            QDomElement iclock = idoc.createElement("clock") ;
            iclock.setAttribute("clock_name",j.key());
            iclock.setAttribute("polarity",j.value());
            iclockDescriptionElement.appendChild(iclock);
			++j ;
        }
        imoduleElement.appendChild(iclockDescriptionElement) ;

        //qDebug() << "saveInfoToLogFile!" << __LINE__ << __FILE__ ;

        QDomElement iregDescriptionElement   = idoc.createElement("reg_description") ;
        QMap<QString,QVector<EziDebugModule::RegStructure*> >::const_iterator k= pmodule->m_iregMap.constBegin();
        while (k!= pmodule->m_iregMap.constEnd())
        {
            for(int m = 0; m < k.value().size(); ++m)
            {
                QDomElement ireg = idoc.createElement("reg") ;
                EziDebugModule::RegStructure * preg = k.value().at(m) ;
                ireg.setAttribute("module_name",QString::fromLocal8Bit(preg->m_pMouduleName));
                ireg.setAttribute("locate_clock",k.key());
                ireg.setAttribute("reg_name",QString::fromLocal8Bit(preg->m_pRegName));
                ireg.setAttribute("regnum",preg->m_pregNum);
                //ireg.setAttribute("endian",preg->m_isEndian);
                // 保存 位宽字符串
                ireg.setAttribute("bitwidth",QString::fromAscii(preg->m_pExpString));
                if(preg->m_eedge == EziDebugModule::signalPosEdge)
                {
                    ireg.setAttribute("polarity","posedge");
                }
                else if(preg->m_eedge == EziDebugModule::signalNegEdge)
                {
                    ireg.setAttribute("polarity","negedge");
                }
                else
                {
                    ireg.setAttribute("polarity","noedge");
                }

                iregDescriptionElement.appendChild(ireg);
            }
			++k ;
        }
        imoduleElement.appendChild(iregDescriptionElement) ;

        //qDebug() << "saveInfoToLogFile!" << __LINE__ << __FILE__ ;

        QDomElement iportDescriptionElement  = idoc.createElement("port_description") ;
        for(int n = 0 ; n < pmodule->m_iportVec.size();++n)
        {
            QDomElement iport = idoc.createElement("port") ;
            EziDebugModule::PortStructure *pport = pmodule->m_iportVec.at(n) ;
            iport.setAttribute("port_name",QString::fromLocal8Bit(pport->m_pPortName));
            iport.setAttribute("module_name",QString::fromLocal8Bit(pport->m_pModuleName));
            if(pport->eDirectionType == EziDebugModule::directionTypeInput)
            {
                iport.setAttribute("direction_type","in");
            }
            else if(pport->eDirectionType == EziDebugModule::directionTypeOutput)
            {
                iport.setAttribute("direction_type","out");
            }
            else
            {
                iport.setAttribute("direction_type","inout");
            }

            iport.setAttribute("bitwidth",QString::fromAscii(pport->m_pBitWidth));

            // iport.setAttribute("endian",(pport->m_isEndian ? "big" :"little"));
            iportDescriptionElement.appendChild(iport);
        }
        imoduleElement.appendChild(iportDescriptionElement);

        //qDebug() << "saveInfoToLogFile!" << __LINE__ << __FILE__ ;
        QStringList iportList ;
        QDomElement iinstancePortMapDescriptionElement  = idoc.createElement("instance_port_map_description") ;
        QMap<QString,QMap<QString,QString> > iinstancePortMap = pmodule->getInstancePortMap() ;
        QMap<QString,QMap<QString,QString> >::const_iterator instanceportiterator =  iinstancePortMap.constBegin();
        while(instanceportiterator != iinstancePortMap.constEnd())
        {
            iportList.clear();
            QDomElement iinstance = idoc.createElement("instance") ;
            iinstance.setAttribute("instance_name",instanceportiterator.key());
            QMap<QString,QString> iportMap = instanceportiterator.value() ;
            QMap<QString,QString>::const_iterator iportMapIterator = iportMap.constBegin();
            while(iportMapIterator != iportMap.constEnd())
            {
                iportList << iportMapIterator.key() + QObject::tr("@") + iportMapIterator.value();
                ++iportMapIterator ;
            }
            iinstance.setAttribute("port_map",iportList.join("#"));
            iinstancePortMapDescriptionElement.appendChild(iinstance);
            ++instanceportiterator ;
        }

        imoduleElement.appendChild(iinstancePortMapDescriptionElement);
        imoduleInfoElement.appendChild(imoduleElement);
    }
    else if(type == infoTypeScanChainStructure)
    {
         EziDebugScanChain * pchain = static_cast<EziDebugScanChain*>(info);

         QDomElement ielement = idoc.elementsByTagName("SCAN_CHAIN_INFO").at(0).toElement() ;

         // 重新创建log文件时, 保证信息不为空
         if(ielement.attribute("scanreg_core_name").toLower() == "no core")
         {
             QString iregCore = EziDebugScanChain::getChainRegCore().toLower() ;
             if(iregCore == "no core")
             {
                 qDebug() << "EziDebug Error: there is no core info!";
             }
             ielement.setAttribute("scanreg_core_name","_EziDebug_ScnReg");
         }

         if(ielement.attribute("tout_core_name").toLower() == "no core")
         {
             QString itoutCore = EziDebugScanChain::getChainToutCore().toLower() ;
             if(itoutCore == "no core")
             {
                 qDebug() << "EziDebug Error: there is no core info!";
             }
             ielement.setAttribute("tout_core_name","_EziDebug_TOUT_m");
         }

         if(ielement.attribute("user_dir").toLower().toLower() == "no dir")
         {
             ielement.setAttribute("user_dir","/EziDebug_1.0");
         }


         QDomElement ichainElement = idoc.createElement("chain") ;
         ichainElement.setAttribute("chain_name",pchain->m_iChainName);

         ichainElement.setAttribute("instance_list",pchain->m_iinstanceItemList.join("|"));

         ichainElement.setAttribute("scaned_file_list",pchain->m_iscanedFileNameList.join("|"));
         if(pchain->m_isysCoreOutputPortList.count())
         {
            ichainElement.setAttribute("system_output",pchain->m_isysCoreOutputPortList.join("@"));
         }
         else
         {
             ichainElement.setAttribute("system_output","No Sysoutput");
         }

         QDomElement iregListDescriptionElement = idoc.createElement("reglist_description");

         QMap<QString,QVector<QStringList> >::const_iterator iregChainIter = pchain->m_iregChainStructure.constBegin() ;
         while(iregChainIter != pchain->m_iregChainStructure.constEnd())
         {
             QString iinsertClock = iregChainIter.key() ;
             QVector<QStringList> iregListVec = iregChainIter.value() ;

             for(int p = 0 ; p < iregListVec.size(); ++p)
             {
                 QStringList iregList = iregListVec.at(p) ;
                 QString iregString ;
                 iregString = iregList.join("@");

                 QDomElement iregChainElement = idoc.createElement("regchain") ;
                 iregChainElement.setAttribute("insertclock",iinsertClock);

                 iregChainElement.setAttribute("regcount",pchain->m_nregCountMap.value(iinsertClock,0));

                 iregChainElement.setAttribute("reglist",iregString);
                 iregListDescriptionElement.appendChild(iregChainElement);
             }

             ++iregChainIter ;
         }

         ichainElement.appendChild(iregListDescriptionElement);

         QDomElement icodeDescriptionElement = idoc.createElement("code_description") ;

         QMap<QString,QStringList>::const_iterator u = pchain->m_icodeMap.constBegin() ;
         while(u != pchain->m_icodeMap.constEnd())
         {
             QStringList iblockCodeList = pchain->m_iblockCodeMap.value(u.key(),QStringList()) ;
             QDomElement icode = idoc.createElement("added_code");
             icode.setAttribute("module_name",u.key());

             icode.setAttribute("user_line_code",u.value().join("#"));
             icodeDescriptionElement.appendChild(icode);

             if(iblockCodeList.count())
             {
                 icode.setAttribute("user_block_code",iblockCodeList.join("#"));
             }
             else
             {
                 icode.setAttribute("user_block_code","No Code");
             }
             ++u ;
         }


         ichainElement.appendChild(icodeDescriptionElement);

         ielement.appendChild(ichainElement);
    }
    else
    {
        return 1 ;
    }

    return 0 ;
}

// 删除指定的 file、module、chain 元素
int EziDebugPrj::deleteLogFileElement(QDomDocument &idoc ,LOG_FILE_INFO* loginfo)
{
    QString ielementName ;
    QString iattributionName ;
    if(!loginfo)
    {
        return 1 ;
    }
    QString iinfoName = QString::fromAscii(loginfo->ainfoName);
    INFO_TYPE etype = loginfo->etype ;
    QDomNode ielement ;
    if(etype == infoTypeFileInfo)
    {
        ielement  = idoc.elementsByTagName("FILE_INFO").at(0);
        ielementName = "file" ;
        iattributionName = "file_name" ;
    }
    else if(etype == infoTypeModuleStructure)
    {
        ielement =  idoc.elementsByTagName("MODULE_INFO").at(0);
        ielementName = "module" ;
        iattributionName = "module_name" ;
    }
    else if(etype == infoTypeScanChainStructure)
    {
        ielement =  idoc.elementsByTagName("SCAN_CHAIN_INFO").at(0);
        ielementName = "chain" ;
        iattributionName = "chain_name" ;
    }
    else
    {
        qDebug() << "Error: The element type is not suppport now!";
        return 1 ;
    }
    //ichild.toElement().attribute("module_name")
    QDomNode ichild = ielement.firstChild() ;
    while(!ichild.isNull())
    {
        if((ichild.toElement().tagName() == ielementName )&&(ichild.toElement().attribute(iattributionName) == iinfoName))
        {
            ielement.removeChild(ichild);            
            return 0 ;
        }
        ichild = ichild.nextSibling() ;
    }

    qDebug() << "EziDebug Info: The element is not delete !" ;
    return 0 ;

}

void EziDebugPrj::addToChainMap(EziDebugScanChain* chain)
{
    m_ichainInfoMap.insert(chain->getChainName(),chain);
    return ;
}

void EziDebugPrj::addToTreeItemMap(const QString &chain ,EziDebugInstanceTreeItem* item)
{
    m_ichainTreeItemMap.insert(chain,item);
    return ;
}

void EziDebugPrj::addToQueryItemMap(const QString &name ,EziDebugInstanceTreeItem* item)
{
    m_iqueryTreeItemMap.insert(name,item);
    return ;
}

// 将所有文件中的宏放入到 prj 中 方便后面读取
void EziDebugPrj::addToMacroMap(void)
{
    // 目前只考虑 verilog 的宏  不清楚 vhdl 的宏或者其他参数等
    m_imacro.clear();
    QMap<QString,EziDebugVlgFile*>::const_iterator ifileIter = m_ivlgFileMap.constBegin() ;
    while(ifileIter != m_ivlgFileMap.constEnd())
    {
        EziDebugVlgFile *pfile = ifileIter.value() ;
        QMap<QString,QString> imacroMap = pfile->getMacroMap();
        QMap<QString,QString>::const_iterator imacroIter = imacroMap.constBegin() ;
        while(imacroIter != imacroMap.constEnd())
        {
            QString imacroStr = imacroIter.key() ;
            QString imacroVal = imacroIter.value() ;
            m_imacro.insert(imacroStr,imacroVal);
            ++imacroIter ;
        }
        ++ifileIter ;
    }
}

const QMap<QString,QString> &EziDebugPrj::getMacroMap(void) const
{
    return m_imacro ;
}

void EziDebugPrj::addToDefparameterMap(void)
{
    m_idefparameter.clear();
    QMap<QString,EziDebugVlgFile*>::const_iterator ifileIter = m_ivlgFileMap.constBegin() ;
    while(ifileIter != m_ivlgFileMap.constEnd())
    {
        EziDebugVlgFile* pfile = ifileIter.value();
        QMap<QString,QMap<QString,QString> > idefParamMap = pfile->getDefParamMap() ;
        QMap<QString,QMap<QString,QString> >::const_iterator idefParamIter = idefParamMap.constBegin() ;
        while(idefParamIter != idefParamMap.constEnd())
        {   QMap<QString,QString> iparamMap = idefParamIter.value() ;
            QString iinstanceName = idefParamIter.key() ;
            QMap<QString,QString>::const_iterator iparamIter = iparamMap.constBegin() ;
            while(iparamIter != iparamMap.constEnd())
            {
                QString iparamStr = iparamIter.key() ;
                QString iparamVal = iparamIter.value() ;
                QMap<QString,QString> ivalueMap ;
                ivalueMap = m_idefparameter.value(iinstanceName,ivalueMap) ;
                ivalueMap.insert(iparamStr,iparamVal) ;
                m_idefparameter.insert(iinstanceName,ivalueMap) ;
                ++iparamIter ;
            }
            ++idefParamIter ;
        }
        ++ifileIter ;
    }
}

QMap<QString,QString> EziDebugPrj::getdefparam(const QString &instancename)
{
   QMap<QString,QString> idefparamMap ;
   return m_idefparameter.value(instancename,idefparamMap) ;
}

EziDebugInstanceTreeItem* EziDebugPrj::getQueryItem(const QString &name)
{
    return m_iqueryTreeItemMap.value(name,NULL);
}

void EziDebugPrj::updateTreeItem(EziDebugInstanceTreeItem* item)
{
    EziDebugInstanceTreeItem* pitem = NULL ;
	
    // 获得 那些已经加入链的  头节点,用来给新的节点 赋值 
    if(m_elastOperation == OperateTypeDelAllScanChain)
    {
        pitem = m_ibackupQueryTreeItemMap.value(item->getNameData(),NULL);
        if(pitem)
        {
           item->setScanChainInfo(pitem->getScanChainInfo()) ;
           m_iqueryTreeItemMap.insert(item->getNameData(),item);
           m_ibackupChainTreeItemMap.insert(pitem->getScanChainInfo()->getChainName(),item);
        }
    }
    else
    {
        pitem = m_iqueryTreeItemMap.value(item->getNameData(),NULL);
        if(pitem)
        {
            item->setScanChainInfo(pitem->getScanChainInfo()) ;
            m_ibackupQueryTreeItemMap.insert(item->getNameData(),item);
            m_ichainTreeItemMap.insert(pitem->getScanChainInfo()->getChainName(),item);
        }

        // 添加链、或删除链
        if(m_pLastOperteTreeItem)
        {
            if(m_pLastOperteTreeItem->getNameData() == item->getNameData())
            {
                m_pLastOperteTreeItem = item ;
            }
        }

    }

//        m_ichainTreeItemMap.insert(pitem->getScanChainInfo()->getChainName(),item);

//        EziDebugScanChain* pchain = m_ichainInfoMap.value(pitem->getScanChainInfo()->getChainName(),NULL);
//        if(pchain)
//        {
//            pchain->setHeadTreeItem(item);
//        }
//        else
//        {
//            qDebug() << "NULL Pointer!" << __LINE__ << __FILE__ ;
//        }

    // 遍历所有子节点
    for(int i = 0 ; i < item->childCount() ;i++)
    {
        updateTreeItem(item->child(i));
    }

}

void EziDebugPrj::eliminateChainFromMap(const QString &chain)
{
    m_ichainInfoMap.remove(chain);
    return ;
}

void EziDebugPrj::eliminateTreeItemFromMap(const QString &chain)

{
    m_ichainTreeItemMap.remove(chain);
    return ;
}

void EziDebugPrj::eliminateTreeItemFromQueryMap(const QString &combinedname)
{
    m_iqueryTreeItemMap.remove(combinedname);
    return ;
}

void EziDebugPrj::backupChainQueryTreeItemMap(void)
{
    m_ibackupQueryTreeItemMap = m_iqueryTreeItemMap ;
    return ;
}

void EziDebugPrj::backupChainTreeItemMap(void)
{
    m_ibackupChainTreeItemMap = m_ichainTreeItemMap ;
    return ;
}

void EziDebugPrj::cleanupBakChainTreeItemMap(void)
{
    m_ibackupChainTreeItemMap.clear() ;
    return ;
}

 void EziDebugPrj::cleanupChainTreeItemMap(void)
 {
    m_ichainTreeItemMap.clear();
    return ;
 }

 void EziDebugPrj::cleanupChainQueryTreeItemMap(void)
 {
    m_iqueryTreeItemMap.clear();
    return ;
 }

 void EziDebugPrj::cleanupBakChainQueryTreeItemMap(void)
 {
    m_ibackupQueryTreeItemMap.clear();
    return ;
 }

void EziDebugPrj::resumeChainTreeItemMap(void)
{
    m_ichainTreeItemMap = m_ibackupChainTreeItemMap ;
}

void EziDebugPrj::resumeChainQueryTreeItemMap(void)
{
    m_iqueryTreeItemMap = m_ibackupQueryTreeItemMap ;
}

void EziDebugPrj::backupChainMap(void)
{
    m_ibackupChainInfoMap = m_ichainInfoMap ;
}

void EziDebugPrj::cleanupChainMap(void)
{
    m_ichainInfoMap.clear();
}

void EziDebugPrj::resumeChainMap(void)
{
    m_ichainInfoMap = m_ibackupChainInfoMap ;
    return ;
}

int EziDebugPrj::createCfgFile(EziDebugInstanceTreeItem * item)
{
    if(m_eusedTool == ToolQuartus)
    {
        if(m_itoolSoftwareVersion == "8.0")
        {
            /*创建 stp 文件 */
            QString istpFileName("_EziDebug_stp.stp");
            int istpCount = 0 ;
            while(m_iwaveFileList.contains(istpFileName))
            {
                istpFileName = QObject::tr("_EziDebug_stp%1.stp").arg(istpCount);
                istpCount++ ;
            }

            QFileInfo istpFileInfo(m_iprjPath ,istpFileName);
            QFile istpFile(istpFileInfo.absoluteFilePath());
			
            if(!istpFile.open(QIODevice::WriteOnly|QIODevice::Text))
            {
                qDebug() << "Cannot Open file for reading:" << qPrintable(istpFile.errorString());
                return  1 ;
            }

            QTextStream istpOutStream(&istpFile) ;

            /*判断软件版本*/
            QString ifileContent ;
            // <session sof_file="" top_level_entity="tb_ifft_top">
            QString ilabelSessionStart(QObject::tr("<session sof_file=\"\" top_level_entity=\"%1\">").arg(m_itopModule));
            // <display_tree gui_logging_enabled="0">
            QString ilabelDisplay_treeStart(QObject::tr("\n  <display_tree gui_logging_enabled=\"0\">"));
            ifileContent.append(ilabelSessionStart);
            ifileContent.append(ilabelDisplay_treeStart);

            /*
                <display_branch instance="auto_signaltap_0" signal_set="USE_GLOBAL_TEMP" trigger="USE_GLOBAL_TEMP"/>
                <display_branch instance="auto_signaltap_1" signal_set="USE_GLOBAL_TEMP" trigger="USE_GLOBAL_TEMP"/>
            */

            EziDebugModule *pmodule = this->getPrjModuleMap().value(item->getModuleName());

            for(int i = 0 ; i < pmodule->getClockSignal().count() ;i++)
            {
                QString ilabelDisplay_branch(QObject::tr("\n    <display_branch instance=\"auto_signaltap_%1\" signal_set=\"USE_GLOBAL_TEMP\" trigger=\"USE_GLOBAL_TEMP\"/>")\
                                             .arg(i)) ;
                ifileContent.append(ilabelDisplay_branch);
            }

            // </display_tree>
            QString ilabelDisplay_treeEnd(QObject::tr("\n  </display_tree>")) ;
            ifileContent.append(ilabelDisplay_treeEnd);


            /*创建 各个时钟 的 instance */

            /*
             <instance entity_name="sld_signaltap" is_auto_node="yes" is_expanded="true" name="auto_signaltap_0" source_file="sld_signaltap.vhd">
             <node_ip_info instance_id="0" mfg_id="110" node_id="0" version="6"/>
                <position_info>
                    <single attribute="active tab" value="1"/>
                    <single attribute="setup horizontal scroll position" value="0"/>
                    <single attribute="setup vertical scroll position" value="0"/>
                </position_info>
            */

//            QString ilabelInstanceStart(tr(""\
//                                           "<instance entity_name=\"sld_signaltap\" is_auto_node=\"yes\" is_expanded=\"true\" name=\"auto_signaltap_0\" source_file=\"sld_signaltap.vhd\">")) ;


//            ifileContent.append(ilabelInstanceStart);

            QString iinstanceString = constructCfgInstanceString(item);

            if(iinstanceString.isEmpty())
            {
                return 1 ;
            }
            ifileContent.append(iinstanceString);

            QString ilabelGlobal_infoStart(QObject::tr("\n  <global_info>"));
            ifileContent.append(ilabelGlobal_infoStart);

            QString ilabelSingle1(QObject::tr("\n    <single attribute=\"active instance\" value=\"0\"/>"));
            ifileContent.append(ilabelSingle1);

            QString ilabelSingle2(QObject::tr("\n    <single attribute=\"lock mode\" value=\"36110\"/>"));
            ifileContent.append(ilabelSingle2);

            QString ilabelmulti1(QObject::tr("\n    <multi attribute=\"column width\" size=\"18\" value=\"34,34,223,74,68,70,88,100,101,101,101,101,101,101,101,101,107,78\"/>"));
            ifileContent.append(ilabelmulti1);

            QString ilabelmulti2(QObject::tr("\n    <multi attribute=\"window position\" size=\"9\" value=\"1440,799,398,124,356,50,124,0,0\"/>"));
            ifileContent.append(ilabelmulti2);

            QString ilabelGlobal_infoEnd(QObject::tr("\n  </global_info>"));
            ifileContent.append(ilabelGlobal_infoEnd);

            QString ilabelSessionEnd(QObject::tr("\n</session>"));
            ifileContent.append(ilabelSessionEnd);

            istpOutStream << ifileContent ;

            istpFile.close();

            QFile iprjFile(m_iprjName);
            if(!iprjFile.open(QIODevice::ReadOnly|QIODevice::Text))
            {
                qDebug() << "Cannot Open file for reading:" << qPrintable(iprjFile.errorString());
                return 1 ;
            }

            QTextStream iinStream(&iprjFile) ;
            QString ifileAllString =  iinStream.readAll();
            iprjFile.close();

            int nlastPosOfVlgKeyWord = ifileAllString.lastIndexOf(QRegExp(QObject::tr("\\bVERILOG_FILE\\b")));
            int nlastPosOfVhdlKeyWord = ifileAllString.lastIndexOf(QRegExp(QObject::tr("\\bVHDL_FILE\\b"))) ;


            if(nlastPosOfVlgKeyWord > nlastPosOfVhdlKeyWord)
            {
                int ienterPos = ifileAllString.indexOf('\n',nlastPosOfVlgKeyWord);

                ifileAllString.insert(ienterPos,QObject::tr("\n""set_global_assignment -name SIGNALTAP_FILE %1").arg(istpFileName));
            }
            else
            {
                int ienterPos = ifileAllString.indexOf('\n',nlastPosOfVhdlKeyWord);
                ifileAllString.insert(ienterPos,QObject::tr("\n""set_global_assignment -name SIGNALTAP_FILE %1").arg(istpFileName));
            }


            if(!iprjFile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate))
            {
                qDebug() << "Cannot Open file for reading:" << qPrintable(iprjFile.errorString());
                return 1 ;
            }

            QTextStream iprjOutStream(&iprjFile) ;

            iprjOutStream << ifileAllString ;

            iprjFile.close();

        }
    }
    else if(m_eusedTool == ToolIse)
    {
        QString iinstanceName = item->getInstanceName();
        QString ifileContent(QObject::tr("#ChipScope Core Inserter Project File Version 3.0")) ;
        /*创建 cdc 文件 */
        QString icdcFileName(QObject::tr("_EziDebug_%1.cdc").arg(iinstanceName));
        QString ichainName(item->getScanChainInfo()->getChainName())   ;
        QString iilaStr ;
        int icdcCount = 0 ;
        while(m_iprjPath.exists(icdcFileName))
        {
            icdcFileName = QObject::tr("_EziDebug_%1.cdc").arg(iinstanceName+QString::number(icdcCount));
            icdcCount++ ;
        }
        QString iprjPath ;
        iprjPath.clear();
        QString iinputFilePath = m_iprjPath.absolutePath();

        QString isingleSep(QDir::separator());
        QString idoubleSep ;

        if(isingleSep == "\\")
        {
            isingleSep = "\\";
            idoubleSep = "\\\\" ;
        }
        else
        {
            isingleSep = "\\";
            idoubleSep = "\\\\" ;
        }
        iinputFilePath = QDir::toNativeSeparators(iinputFilePath) ;

        iinputFilePath.replace(isingleSep ,idoubleSep );


        QString icolon ;
        icolon.append(isingleSep + ":");
        iinputFilePath.replace(":", icolon);
        iprjPath.append(iinputFilePath) ;
        iinputFilePath.append(tr("%1%2.ngc").arg(idoubleSep).arg(m_headItem->getModuleName()));

        QString ioutputDir = iprjPath.append(tr("%1_ngo").arg(idoubleSep));

        QFileInfo icdcFileInfo(m_iprjPath ,icdcFileName);
        QFile icdcFile(icdcFileInfo.absoluteFilePath());
        if(!icdcFile.open(QIODevice::WriteOnly|QIODevice::Text))
        {
            qDebug() << "Cannot Open file for reading:" << icdcFile.errorString();
            return  1 ;
        }

        QTextStream icdcOutStream(&icdcFile) ;

        QDate icurrentDate = QDate::currentDate() ;
        QTime icurrentTime = QTime::currentTime() ;

        //QString idateCom = QObject::tr("%1" "%2" "%3").arg(day[icurrentDate.dayOfWeek()]).arg(month[icurrentDate.month()]).arg(icurrentDate.daysInMonth());
        // icurrentDate.toString("ddd MMM dd")
        QString itimeString(QObject::tr("\n""#%1 %2 %3 %4 CST %5")\
                            .arg(day[icurrentDate.dayOfWeek()]) \
                            .arg(month[icurrentDate.month()])\
                            .arg(icurrentDate.toString("dd"))\
                            .arg(icurrentTime.toString(QObject::tr("hh:mm:ss")))
                            .arg(icurrentDate.year())) ;


        /*工程 导入 的网表文件 和 导出的 网表文件 */
        QString iinNetFile(QObject::tr("\n""Project.device.designInputFile=%1").arg(iinputFilePath));
        QString ioutNetFile(QObject::tr("\n""Project.device.designOutputFile=%1").arg(iinputFilePath));

        QString ideviceFamily(QObject::tr("\n""Project.device.deviceFamily=12"));
        QString idevice_enableRPMs(QObject::tr("\n""Project.device.enableRPMs=true"));
        QString idevice_outputDirectory(QObject::tr("\n""Project.device.outputDirectory=%1").arg(ioutputDir));
        QString idevice_useSRL16(QObject::tr("\n""Project.device.useSRL16=true"));
        QString ifilter_dimension(QObject::tr("\n""Project.filter.dimension=1"));
        QString ifilter(QObject::tr("\n""Project.filter<0>="));
        QString iicon_boundaryScanChain(QObject::tr("\n""Project.icon.boundaryScanChain=1"));
        QString iicon_disableBUFGInsertion(QObject::tr("\n""Project.icon.disableBUFGInsertion=false"));
        QString iicon_enableExtTriggerIn(QObject::tr("\n""Project.icon.enableExtTriggerIn=false"));
        QString iicon_enableExtTriggerOut(QObject::tr("\n""Project.icon.enableExtTriggerOut=false"));
        QString iicon_triggerInPinName(QObject::tr("\n""Project.icon.triggerInPinName="));
        QString iicon_triggerOutPinName(QObject::tr("\n""Project.icon.triggerOutPinName="));


        /*
            #ChipScope Core Inserter Project File Version 3.0
            #Mon Sep 03 15:30:56 CST 2012
            Project.device.designInputFile=E\:\\gy\\ise_test\\ise_test.ngc
            Project.device.designOutputFile=E\:\\gy\\ise_test\\ise_test.ngc
            Project.device.deviceFamily=12
            Project.device.enableRPMs=true
            Project.device.outputDirectory=E\:\\gy\\ise_test\\_ngo
            Project.device.useSRL16=true
            Project.filter.dimension=1
            Project.filter<0>=
            Project.icon.boundaryScanChain=1
            Project.icon.disableBUFGInsertion=false
            Project.icon.enableExtTriggerIn=false
            Project.icon.enableExtTriggerOut=false
            Project.icon.triggerInPinName=
            Project.icon.triggerOutPinName=
            Project.unit.dimension=1
            Project.unit<0>.clockChannel=clk_BUFGP
            Project.unit<0>.clockEdge=Rising
            Project.unit<0>.dataDepth=512
            Project.unit<0>.dataEqualsTrigger=true
            Project.unit<0>.dataPortWidth=2
            Project.unit<0>.enableGaps=false
            Project.unit<0>.enableStorageQualification=true
            Project.unit<0>.enableTimestamps=false
            Project.unit<0>.timestampDepth=0
            Project.unit<0>.timestampWidth=0
            Project.unit<0>.triggerChannel<0><0>=cnt1
            Project.unit<0>.triggerChannel<0><1>=cnt2
            Project.unit<0>.triggerConditionCountWidth=0
            Project.unit<0>.triggerMatchCount<0>=1
            Project.unit<0>.triggerMatchCountWidth<0><0>=0
            Project.unit<0>.triggerMatchType<0><0>=0
            Project.unit<0>.triggerPortCount=1
            Project.unit<0>.triggerPortIsData<0>=true
            Project.unit<0>.triggerPortWidth<0>=2
            Project.unit<0>.triggerSequencerLevels=16
            Project.unit<0>.triggerSequencerType=1
            Project.unit<0>.type=ilaprol
        */
        //

        QMap<QString,QString> iclockMap = item->parent()->getModuleClockMap(item->getInstanceName()) ;
        QString iregHiberarchy =  item->getItemHierarchyName();

        QRegExp ireplaceRegExp(QObject::tr("\\b\\w*:"));
        QRegExp iregExp(QObject::tr("\\b%1:%2.*").arg(item->getModuleName()).arg(item->getInstanceName()));
        QString inewRegHiberarchy = iregHiberarchy.replace('|','/') ;
        inewRegHiberarchy = inewRegHiberarchy.replace(iregExp,"") ;
        // 剔出 modulexxx: 字符
        inewRegHiberarchy.replace(ireplaceRegExp,"");

        int i = 0 ;
        int ntriggerNum = 0 ;

        QMap<QString,QString>::const_iterator iclockIterator = iclockMap.constBegin();
        {
            int nregWidth = -1 ;
            ntriggerNum = 0 ;
            QString itriggerChannelString ;
            //Project.unit<0>.clockChannel=clk_BUFGP
            //Project.unit<0>.clockEdge=Rising
            // .arg(iclockIterator.key())

#if 0
            QString iedgeString = this->getPrjModuleMap().value(item->getModuleName())->getClockSignal().value(iclockIterator.value());
            if(iedgeString == "posedge")
            {
                iedgeString = QObject::tr("Rising");
            }
            else
            {
                iedgeString = QObject::tr("Descending");
            }
#endif

            if((iclockIterator.key() == item->getScanChainInfo()->getscaningPortClock())||(iclockMap.count()==1))
            {
                QString isuffixString ;
                QString itdoPortRegName(QObject::tr("_EziDebug_%1_%2_tdo_r").arg(item->getScanChainInfo()->getChainName()).arg(iclockIterator.value()));


                for(int m = (item->getScanChainInfo()->getChildChainNum(iclockIterator.key()) - 1) ; m >= 0  ; m--)
                {
                    if(item->getScanChainInfo()->getChildChainNum(iclockIterator.key()) > 1)
                    {
                        isuffixString = QObject::tr("<%1>").arg(m) ;
                    }
                    else
                    {
                        isuffixString.clear();
                    }

                    if(nregWidth == 255)
                    {
                        ntriggerNum++ ;
                        nregWidth = 0 ;
                    }
                    else
                    {
                        nregWidth++ ;
                    }

                    itriggerChannelString.append(QObject::tr("\n""Project.unit<%1>.triggerChannel<%2><%3>=%4")\
                                               .arg(i).arg(ntriggerNum).arg(nregWidth).arg(inewRegHiberarchy + itdoPortRegName + isuffixString));

                }

                // tout

                if(nregWidth == 255)
                {
                    ntriggerNum++ ;
                    nregWidth = 0 ;
                }
                else
                {
                    nregWidth++ ;
                }
                QString itoutPortRegName(QObject::tr("_EziDebug_%1_tout_r").arg(item->getScanChainInfo()->getChainName()));
                itriggerChannelString.append(QObject::tr("\n""Project.unit<%1>.triggerChannel<%2><%3>=%4")\
                                             .arg(i).arg(ntriggerNum).arg(nregWidth).arg(inewRegHiberarchy + itoutPortRegName));



                EziDebugModule *  pmodule = m_imoduleMap.value(item->getModuleName(),NULL) ;

                if(!pmodule)
                {
                    qDebug() << "EziDebug Error: NULL Pointer!";
                    return  1 ;
                }

                QVector<EziDebugModule::PortStructure*> iportVec = this->getPrjModuleMap().value(item->getModuleName())->getPort(this,item->getInstanceName());
                for(int j = 0 ; j < iportVec.count() ; j++)
                {
                    QString iportName = QString::fromAscii(iportVec.at(j)->m_pPortName) ;
                    QString iportRegName(QObject::tr("_EziDebug_%1_%2_r").arg(ichainName).arg(iportName));
                    // 跳过时钟  复位信号
                    if(!(pmodule->getClockSignal().value(iportName,QString())).isEmpty())
                    {
                        continue ;
                    }

                    if(!(pmodule->getResetSignal().value(iportName,QString())).isEmpty())
                    {
                        continue ;
                    }

                    QString isuffixString ;
                    for(int m = 0 ; m < iportVec.at(j)->m_unBitwidth ; m++)
                    {
                        if(1 == iportVec.at(j)->m_unBitwidth)
                        {
                            isuffixString.clear();
                        }
                        else
                        {
                            if(iportVec.at(j)->m_eEndian == EziDebugModule::endianBig)
                            {

                                isuffixString = QObject::tr("<%1>").arg(iportVec.at(j)->m_unStartBit- m) ;
                            }
                            else
                            {
                                isuffixString = QObject::tr("<%1>").arg(iportVec.at(j)->m_unStartBit + m) ;
                            }
                        }

                        if(nregWidth == 255)
                        {
                            ntriggerNum++ ;
                            nregWidth = 0 ;
                        }
                        else
                        {
                            nregWidth++ ;
                        }

                        itriggerChannelString.append(QObject::tr("\n""Project.unit<%1>.triggerChannel<%2><%3>=%4")\
                                                     .arg(i).arg(ntriggerNum).arg(nregWidth).arg(inewRegHiberarchy + iportRegName + isuffixString));

                    }                           
                }

                // 内部端口寄存器
                QStringList  iportList = item->getScanChainInfo()->getSyscoreOutputPortList() ;
                for(int n = 0 ; n < iportList.count() ; n++ )
                {
                    QString ihierarchyName = iportList.at(n).split(QObject::tr("#")).at(0);
                    QRegExp ieraseExp(QObject::tr("\\b\\w*:"));
                    ihierarchyName.replace(ieraseExp,"");
                    ihierarchyName.replace("|","/");

                    QString iregName = iportList.at(n).split(QObject::tr("#")).at(2);
                    int nbitWidth =  iportList.at(n).split(QObject::tr("#")).at(3).toInt();
                    QString isuffixString ;
                    for(int n = (nbitWidth -1) ; n >= 0 ; n--)
                    {
                        if(nbitWidth > 1)
                        {
                            isuffixString = QObject::tr("<%1>").arg(n) ;
                        }
                        else
                        {
                            isuffixString.clear();
                        }

                        if(nregWidth == 255)
                        {
                            ntriggerNum++ ;
                            nregWidth = 0 ;
                        }
                        else
                        {
                            nregWidth++ ;
                        }

                        itriggerChannelString.append(QObject::tr("\n""Project.unit<%1>.triggerChannel<%2><%3>=%4")\
                                                     .arg(i).arg(ntriggerNum).arg(nregWidth).arg(ihierarchyName + iregName + isuffixString));
                    }
                }

            }
            else
            {
                qDebug() << "EziDebug Error: create the cdc file error!";
                return 2 ;
            }

            QString  iclockChannel(QObject::tr("\n""Project.unit<%1>.clockChannel=").arg(i));
            QString  iclockEdge(QObject::tr("\n""Project.unit<%1>.clockEdge=").arg(i));
            QString  idataDepth(QObject::tr("\n""Project.unit<%1>.dataDepth=%2").arg(i).arg(m_nmaxRegNumInChain*2));
            QString  idataEqualsTrigger(QObject::tr("\n""Project.unit<%1>.dataEqualsTrigger=true").arg(i));

            QString idataPortWidth(QObject::tr("\n""Project.unit<%1>.dataPortWidth=").arg(i));
            QString ienableGaps(QObject::tr("\n""Project.unit<%1>.enableGaps=false").arg(i));
            QString ienableStorageQualification(QObject::tr("\n""Project.unit<%1>.enableStorageQualification=true").arg(i));
            QString ienableTimestamps(QObject::tr("\n""Project.unit<%1>.enableTimestamps=false").arg(i));
            QString itimestampDepth(QObject::tr("\n""Project.unit<%1>.timestampDepth=0").arg(i));
            QString itimestampWidth(QObject::tr("\n""Project.unit<%1>.timestampWidth=0").arg(i));

            QString itriggerConditionCountWidth(QObject::tr("\n""Project.unit<%1>.triggerConditionCountWidth=0").arg(i));
            QString itriggerMatchCount(QObject::tr("\n""Project.unit<%1>.triggerMatchCount<0>=1").arg(i));
            QString itriggerMatchCountWidth(QObject::tr("\n""Project.unit<%1>.triggerMatchCountWidth<0><0>=0").arg(i));
            QString itriggerMatchType(QObject::tr("\n""Project.unit<%1>.triggerMatchType<0><0>=0").arg(i));
            QString itriggerPortCount(QObject::tr("\n""Project.unit<%1>.triggerPortCount=%2").arg(i).arg(ntriggerNum+1)) ;
            QString itriggerPortIsData ;
            for(int trinum = 0 ; trinum < (ntriggerNum+1);trinum++)
            {
                itriggerPortIsData.append(QObject::tr("\n""Project.unit<%1>.triggerPortIsData<%2>=true").arg(i).arg(trinum));
            }

            QString itriggerPortWidth ;
            for(int trinum = 0 ; trinum < (ntriggerNum+1);trinum++)
            {
                if(trinum == ntriggerNum)
                {
                    itriggerPortWidth.append(QObject::tr("\n""Project.unit<%1>.triggerPortWidth<%2>=%3").arg(i).arg(trinum).arg(nregWidth));
                }
                else
                {
                    itriggerPortWidth.append(QObject::tr("\n""Project.unit<%1>.triggerPortWidth<%2>=%3").arg(i).arg(trinum).arg(255));
                }
            }
            QString itriggerSequencerLevels(QObject::tr("\n""Project.unit<%1>.triggerSequencerLevels=16").arg(i));
            QString itriggerSequencerType(QObject::tr("\n""Project.unit<%1>.triggerSequencerType=1").arg(i));
            QString itype(QObject::tr("\n""Project.unit<%1>.type=ilapro").arg(i));


            QString iprjUnit = iclockChannel \
                    + iclockEdge \
                    + idataDepth \
                    + idataEqualsTrigger \
                    + idataPortWidth \
                    + ienableGaps \
                    + ienableStorageQualification \
                    + ienableTimestamps \
                    + itimestampDepth \
                    + itimestampWidth \
                    + itriggerChannelString \
                    + itriggerConditionCountWidth \
                    + itriggerMatchCount \
                    + itriggerMatchCountWidth \
                    + itriggerPortCount \
                    + itriggerMatchType \
                    + itriggerPortIsData \
                    + itriggerPortWidth \
                    + itriggerSequencerLevels \
                    + itriggerSequencerType \
                    + itype ;
            iilaStr.append(iprjUnit) ;

            ++i ;
            ++iclockIterator ;
        }


        QString iunit_dimension(QObject::tr("\n""Project.unit.dimension=%1").arg(i));

        QString ipartOneString = itimeString \
                + iinNetFile  \
                + ioutNetFile \
                + ideviceFamily  \
                + idevice_enableRPMs  \
                + idevice_outputDirectory  \
                + idevice_useSRL16 \
                + ifilter_dimension  \
                + ifilter \
                + iicon_boundaryScanChain  \
                + iicon_disableBUFGInsertion  \
                + iicon_enableExtTriggerIn  \
                + iicon_enableExtTriggerOut  \
                + iicon_triggerInPinName  \
                + iicon_triggerOutPinName \
                + iunit_dimension ;

        ifileContent.append(ipartOneString) ;
        ifileContent.append(iilaStr) ;

        icdcOutStream <<  ifileContent ;
        icdcFile.close();
    }
    else
    {
        /*输出文本*/
        return 1 ;
    }

    return 0 ;
}

int EziDebugPrj:: chkEziDebugFileInvolved()
{
    QFile iprjFile(m_iprjName);
    if(!iprjFile.open(QIODevice::Text|QIODevice::ReadOnly))
    {
        qDebug() << "EziDebug Error:Can not Open file for reading:" << qPrintable(iprjFile.errorString());
        return -1 ;
    }
    //       "A" "" "" "" "PROP_UserBrowsedStrategyFiles" ""
    QTextStream ifileStream(&iprjFile);
    QString ifileContent  = ifileStream.readAll() ;
    iprjFile.close();


    if(m_eusedTool == ToolQuartus)
    {
        return 0 ;
    }
    else if(m_eusedTool == ToolIse)
    {
        if(m_itoolSoftwareVersion == "10.x")
        {
            // 修改 set user_files

            // set user_files
            int nfileKeyPos = ifileContent.indexOf("set user_files") ;
            if(nfileKeyPos != -1)
            {
                int nleftBra = ifileContent.indexOf('}',nfileKeyPos) ;
                if(nleftBra != -1)
                {
                    QString ifileListStr = ifileContent.mid(nfileKeyPos,nleftBra - nfileKeyPos + 1);
                    if((ifileListStr.contains(QRegExp("\"EziDebug_1.0/_EziDebug_ScanChainReg.v\"")))
                        &&(ifileListStr.contains(QRegExp("\"EziDebug_1.0/_EziDebug_TOUT_m.v\""))))
                    {
                        qDebug() << "The project file already contains the new file info!";
                        return 1 ;
                    }
                    else
                    {
                        return 0 ;
                    }

                }
                else
                {
                    qDebug() << "EziDebug Error:reading filecontent error!" << __LINE__;
                    return -1;
                }
            }
            else
            {
                qDebug() << "EziDebug Error:reading filecontent error!" << __LINE__;
                return -1 ;
            }
        }
        else if(m_itoolSoftwareVersion == "14.x")
        {
            return 0 ;
        }
        else
        {
            return 0 ; // do nothing!
        }
    }
    else
    {
        return 0 ; // do nothing!
    }
}

QString EziDebugPrj::constructCfgInstanceString(EziDebugInstanceTreeItem * item)
{
    /*
    <node_ip_info instance_id="0" mfg_id="110" node_id="0" version="6"/>
    <position_info>
      <single attribute="active tab" value="1"/>
      <single attribute="setup horizontal scroll position" value="0"/>
      <single attribute="setup vertical scroll position" value="0"/>
    </position_info>
    */
    QString ifileContent ;

    EziDebugModule *pmodule = this->getPrjModuleMap().value(item->getModuleName());

    QMap<QString,QString>::const_iterator iclockiterator = pmodule->getClockSignal().constBegin() ;

    QString iscanPortClock = item->getScanChainInfo()->getscaningPortClock() ;
    if(!iscanPortClock.isEmpty())
    {   
        iscanPortClock = item->parent()->getModuleClockMap(item->getInstanceName()).value(item->getScanChainInfo()->getscaningPortClock(),QString());
    }
    else
    {
        if(pmodule->getClockSignal().count()!= 1)
        {
            return QString();
        }
        else
        {
            while(iclockiterator != pmodule->getClockSignal().constEnd())
            {
                iscanPortClock = iclockiterator.key();
                ++iclockiterator ;
            }
        }
    }


    int i = 0 ;
    iclockiterator = pmodule->getClockSignal().constBegin() ;
    while(iclockiterator != pmodule->getClockSignal().constEnd())
    {
        QString ilabelInstanceStart(QObject::tr("\n  <instance entity_name=\"sld_signaltap\" is_auto_node=\"yes\" is_expanded=\"true\" name=\"auto_signaltap_%1\" source_file=\"sld_signaltap.vhd\">").arg(i));
        ifileContent.append(ilabelInstanceStart);

        QString ilabelNode_ip_info(QObject::tr("\n    <node_ip_info instance_id=\"%1\" mfg_id=\"110\" node_id=\"0\" version=\"6\"/>").arg(i));
        ifileContent.append(ilabelNode_ip_info);


        /*
            <signal_set global_temp="1" name="signal_set: 2012/10/31 17:44:31  #0">
            <clock name="auto_stp_external_clock_0" polarity="posedge" tap_mode="classic"/>
            <config ram_type="M4K" reserved_data_nodes="0" reserved_trigger_nodes="0" sample_depth="128" trigger_in_enable="no" trigger_out_enable="no"/>
            <top_entity/>
            <signal_vec>
            <trigger_input_vec>
            */
        QDate icurrentDate = QDate::currentDate();
        QTime icurrentTime = QTime::currentTime();

        QString ilabelSignal_setStart(QObject::tr("\n    <signal_set global_temp=\"1\" name=\"signal_set: %1 %2  #0\">").arg(icurrentDate.toString(QObject::tr("yyyy/MM/dd")))\
                                    .arg(icurrentTime.toString(QObject::tr("hh:mm:ss")))) ;
        ifileContent.append(ilabelSignal_setStart);

        QString idefaultLabelClock(QObject::tr("\n      <clock name=\"auto_stp_external_clock_0\" polarity=\"posedge\" tap_mode=\"classic\"/>"));
        ifileContent.append(idefaultLabelClock);

        QString idefaultConfig(QObject::tr("\n      <config ram_type=\"M4K\" reserved_data_nodes=\"0\" reserved_trigger_nodes=\"0\" sample_depth=\"128\" trigger_in_enable=\"no\" trigger_out_enable=\"no\"/>"));
        ifileContent.append(idefaultConfig);

        QString ilabelTop_entity(QObject::tr("\n      <top_entity/>"));
        ifileContent.append(ilabelTop_entity);

        QString ilabelSignal_vecStart(QObject::tr("\n      <signal_vec>"));
        ifileContent.append(ilabelSignal_vecStart);

        QString ilabeltrigger_input_vecStart(QObject::tr("\n        <trigger_input_vec>"));
        ifileContent.append(ilabeltrigger_input_vecStart);


        // 新加入的 tdo_reg 输出端口 的 reg
        QString iTdoPortName(QObject::tr("_EziDebug_%1_%2_TDO_r").arg(item->getScanChainInfo()->getChainName()).arg(iclockiterator.key()));

        QString ichainClock = item->parent()->getModuleClockMap(item->getInstanceName()).key(iclockiterator.key(),QString());
        int nchildChainNum =  item->getScanChainInfo()->getChildChainNum(ichainClock);
        QString iregTdoHiberarchy = item->getItemHierarchyName();
        if(1 == nchildChainNum)
        {
            QString itdo_reg(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iregTdoHiberarchy + iTdoPortName));
            ifileContent.append(itdo_reg);
        }
        else if(nchildChainNum > 1)
        {
            for(int m = 0 ; m < nchildChainNum ; m++)
            {
                QString itdo_reg(QObject::tr("\n          <wire name=\"%1[%2]\" tap_mode=\"classic\" type=\"register\"/>").arg(iregTdoHiberarchy + iTdoPortName).arg(m));
                ifileContent.append(itdo_reg);
            }
        }
        else
        {
            return QString();
        }

        QString iToutRegName(QObject::tr("_EziDebug_%1_TOUT_reg").arg(item->getScanChainInfo()->getChainName()));
        QString itout_reg(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iregTdoHiberarchy + iToutRegName));
        ifileContent.append(itout_reg);

        if(iscanPortClock == iclockiterator.key())
        {
            // 所有观测模块的 输入输出端口的  reg
            QVector<EziDebugModule::PortStructure*> iportVec = pmodule->getPort(this,item->getInstanceName());
            for(int i = 0 ; i < iportVec.count() ;i++)
            {
                QString iportName = QString::fromAscii(iportVec.at(i)->m_pPortName) ;
                if(!(pmodule->getClockSignal().value(iportName,QString())).isEmpty())
                {
                    continue ;
                }

                if(!(pmodule->getResetSignal().value(iportName,QString())).isEmpty())
                {
                    continue ;
                }

                QString iregHiberarchy = item->getItemHierarchyName();
                QString ieziDebugPortName ;
                //ieziDebugPortName.append(QObject::tr("_EziDebug_")+iportName + QObject::tr("_r"));
                ieziDebugPortName.append(QObject::tr("_EziDebug_%1_%2_r").arg(item->getScanChainInfo()->getChainName()).arg(iportName));
                if(1 == iportVec.at(i)->m_unBitwidth)
                {
                    QString ilabelwire(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iregHiberarchy + ieziDebugPortName));
                    ifileContent.append(ilabelwire);
                }
                else
                {
                    for(unsigned int j  = 0 ;j < iportVec.at(i)->m_unBitwidth ; j++)
                    {
                        QString ilabelwire(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iregHiberarchy +ieziDebugPortName+QObject::tr("[%1]").arg(j)));
                        ifileContent.append(ilabelwire);
                    }
                }
            }
        }

        if(iscanPortClock == iclockiterator.key())
        {
            // 内部系统模块的输出端口  reg
            QStringList iportList = item->getScanChainInfo()->getSyscoreOutputPortList() ;
            for(int n = 0 ; n < iportList.count() ;n++)
            {
                QString iportHiberarchy = iportList.at(n).split(QObject::tr("#")).at(0);
                QString iportName = iportList.at(n).split(QObject::tr("#")).at(1);
                QString iportBitWidth = iportList.at(n).split(QObject::tr("#")).at(2) ;
  //            QString iportEndian = iportList.at(n).split(QObject::tr("#")).at(3) ;

                QString iportReg = QObject::tr("_EziDebug_%1_%2_r").arg(item->getScanChainInfo()->getChainName()).arg(iportName);

                int nportBitWidth = iportBitWidth.toInt();
                if(1 == nportBitWidth)
                {
                    QString itdo_reg(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iportHiberarchy + iportReg));
                    ifileContent.append(itdo_reg);
                }
                else if(nportBitWidth > 1)
                {
                    for(int m = 0 ; m < nchildChainNum ; m++)
                    {
                        QString itdo_reg(QObject::tr("\n          <wire name=\"%1[%2]\" tap_mode=\"classic\" type=\"register\"/>").arg(iportHiberarchy + iportReg).arg(m));
                        ifileContent.append(itdo_reg);
                    }
                }
                else
                {
                    return QString();
                }
            }
        }

        QString ilabeltrigger_input_vecEnd(QObject::tr("\n        </trigger_input_vec>"));
        ifileContent.append(ilabeltrigger_input_vecEnd);


        QString ilabelData_input_vecStart(QObject::tr("\n        <data_input_vec>"));
        ifileContent.append(ilabelData_input_vecStart);


        // 新加入的 tdo_reg 输出端口 的 reg
//        QString iTdoPortName(QObject::tr("_EziDebug_%1_%2_TDO_r").arg(item->getScanChainInfo()->getChainName()).arg(iclockiterator.key()));
//        int nchildChainNum =  item->getScanChainInfo()->getChildChainNum(iclockiterator.key());

        if(1 == nchildChainNum)
        {
            QString itdo_reg(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iregTdoHiberarchy + iTdoPortName));
            ifileContent.append(itdo_reg);
        }
        else if(nchildChainNum > 1)
        {
            for(int m = 0 ; m < nchildChainNum ; m++)
            {
                QString itdo_reg(QObject::tr("\n          <wire name=\"%1[%2]\" tap_mode=\"classic\" type=\"register\"/>").arg(iregTdoHiberarchy + iTdoPortName).arg(m));
                ifileContent.append(itdo_reg);
            }
        }
        else
        {
            return QString();
        }

        QString itout_reg1(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iregTdoHiberarchy + iToutRegName));
        ifileContent.append(itout_reg1);

        if(iscanPortClock == iclockiterator.key())
        {
            // 所有观测模块的 输入输出端口的  reg
            QVector<EziDebugModule::PortStructure*> iportVec = pmodule->getPort(this,item->getInstanceName());
            for(int i = 0 ; i < iportVec.count() ;i++)
            {
                QString iportName = QString::fromAscii(iportVec.at(i)->m_pPortName) ;

                if(!(pmodule->getClockSignal().value(iportName,QString())).isEmpty())
                {
                    continue ;
                }

                if(!(pmodule->getResetSignal().value(iportName,QString())).isEmpty())
                {
                    continue ;
                }

                QString iregHiberarchy = item->getItemHierarchyName();
                QString ieziDebugPortName ;
                ieziDebugPortName.append(QObject::tr("_EziDebug_%1_%2_r").arg(item->getScanChainInfo()->getChainName()).arg(iportName));
                if(1 == iportVec.at(i)->m_unBitwidth)
                {
                    QString ilabelwire(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iregHiberarchy + ieziDebugPortName));
                    ifileContent.append(ilabelwire);
                }
                else
                {
                    for(unsigned int j  = 0 ;j < iportVec.at(i)->m_unBitwidth ; j++)
                    {
                        QString ilabelwire(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iregHiberarchy + ieziDebugPortName + QObject::tr("[%1]").arg(j)));
                        ifileContent.append(ilabelwire);
                    }
                }
            }
        }


        if(iscanPortClock == iclockiterator.key())
        {
            // 内部系统模块的输出端口  reg
            QStringList iportList = item->getScanChainInfo()->getSyscoreOutputPortList() ;
            for(int n = 0 ; n < iportList.count() ;n++)
            {
                QString iportHiberarchy = iportList.at(n).split(QObject::tr("#")).at(0);
                QString iportName = iportList.at(n).split(QObject::tr("#")).at(1);
                int nportBitWidth = iportList.at(n).split(QObject::tr("#")).at(2).toInt();

                QString iportReg = QObject::tr("_EziDebug_%1_%2_r").arg(item->getScanChainInfo()->getChainName()).arg(iportName);

                if(1 == nportBitWidth)
                {
                    QString itdo_reg(QObject::tr("\n          <wire name=\"%1\" tap_mode=\"classic\" type=\"register\"/>").arg(iportHiberarchy + iportReg));
                    ifileContent.append(itdo_reg);
                }
                else if(nportBitWidth > 1)
                {
                    for(int m = 0 ; m < nchildChainNum ; m++)
                    {
                        QString itdo_reg(QObject::tr("\n          <wire name=\"%1[%2]\" tap_mode=\"classic\" type=\"register\"/>").arg(iportHiberarchy + iportReg).arg(m));
                        ifileContent.append(itdo_reg);
                    }
                }
                else
                {
                    return QString();
                }
            }
        }

        QString ilabelData_input_vecEnd(QObject::tr("\n        </data_input_vec>"));
        ifileContent.append(ilabelData_input_vecEnd);

        QString ilabelSignal_vecEnd(QObject::tr("\n      </signal_vec>"));
        ifileContent.append(ilabelSignal_vecEnd);

        QString ilabelPresentationStart(QObject::tr("\n      <presentation>"));
        ifileContent.append(ilabelPresentationStart);

        QString ilabelData_viewStart(QObject::tr("\n        <data_view>"));
        ifileContent.append(ilabelData_viewStart);



        // 新加入的 tdo_reg 输出端口 的 reg
//      QString iTdoPortName(QObject::tr("_EziDebug_%1_%2_TDO_r").arg(item->getScanChainInfo()->getChainName()).arg(iclockiterator.key()));
//      int nchildChainNum =  item->getScanChainInfo()->getChildChainNum(iclockiterator.key());

        if(1 == nchildChainNum)
        {
            QString ilabelnet(QObject::tr("\n          <net is_signal_inverted=\"no\" name=\"%1\"/>").arg(iregTdoHiberarchy + iTdoPortName));
            ifileContent.append(ilabelnet);
        }
        else if(nchildChainNum > 1)
        {
            QString ilabelbusStart(QObject::tr("\n          <bus is_signal_inverted=\"no\" link=\"all\" name=\"%1\" order=\"lsb_to_msb\" radix=\"hex\" state=\"collapse\" type=\"register\">").arg(iTdoPortName));
            ifileContent.append(ilabelbusStart);
            for(int m = 0 ; m < nchildChainNum ; m++)
            {
                QString ilabelnet(QObject::tr("\n            <net is_signal_inverted=\"no\" name=\"%1[%2]\"/>").arg(iregTdoHiberarchy + iTdoPortName).arg(m));
                ifileContent.append(ilabelnet);
            }
            QString ilabelbusEnd(QObject::tr("\n          </bus>"));
            ifileContent.append(ilabelbusEnd);
        }
        else
        {
            return QString();
        }

        QString itout_reg2(QObject::tr("\n          <net is_signal_inverted=\"no\" name=\"%1\"/>").arg(iregTdoHiberarchy + iToutRegName));
        ifileContent.append(itout_reg2);

        if(iscanPortClock == iclockiterator.key())
        {
            // 所有观测模块的 输入输出端口的  reg
            QVector<EziDebugModule::PortStructure*> iportVec = pmodule->getPort(this,item->getInstanceName());
            for(int i = 0 ; i < iportVec.count() ;i++)
            {
                QString iportName = QString::fromAscii(iportVec.at(i)->m_pPortName) ;
                if(!(pmodule->getClockSignal().value(iportName,QString())).isEmpty())
                {
                    continue ;
                }

                if(!(pmodule->getResetSignal().value(iportName,QString())).isEmpty())
                {
                    continue ;
                }

                QString iregHiberarchy = item->getItemHierarchyName();
                QString ieziDebugPortName ;
                //ieziDebugPortName.append(QObject::tr("_EziDebug_")+iportName + QObject::tr("_r"));
                ieziDebugPortName.append(QObject::tr("_EziDebug_%1_%2_r").arg(item->getScanChainInfo()->getChainName()).arg(iportName));
                if(1 == iportVec.at(i)->m_unBitwidth)
                {
                    QString ilabelnet(QObject::tr("\n          <net is_signal_inverted=\"no\" name=\"%1\"/>").arg(iregHiberarchy + ieziDebugPortName));
                    ifileContent.append(ilabelnet);
                }
                else
                {
                    QString ilabelbusStart(QObject::tr("\n          <bus is_signal_inverted=\"no\" link=\"all\" name=\"%1\" order=\"lsb_to_msb\" radix=\"hex\" state=\"collapse\" type=\"register\">").arg(ieziDebugPortName));
                    ifileContent.append(ilabelbusStart);
                    for(unsigned int j  = 0 ;j < iportVec.at(i)->m_unBitwidth ; j++)
                    {
                        QString ilabelnet(QObject::tr("\n            <net is_signal_inverted=\"no\" name=\"%1[%2]\"/>").arg(iregHiberarchy + ieziDebugPortName).arg(j));
                        ifileContent.append(ilabelnet);
                    }
                    QString ilabelbusEnd(QObject::tr("\n          </bus>"));
                    ifileContent.append(ilabelbusEnd);
                }
            }
        }


        if(iscanPortClock == iclockiterator.key())
        {
            // 内部系统模块的输出端口  reg
            QStringList iportList = item->getScanChainInfo()->getSyscoreOutputPortList() ;
            for(int n = 0 ; n < iportList.count() ;n++)
            {
                QString iportHiberarchy = iportList.at(n).split(QObject::tr("#")).at(0);
                QString iportName = iportList.at(n).split(QObject::tr("#")).at(1);
                int nportBitWidth = iportList.at(n).split(QObject::tr("#")).at(2).toInt();
                QString iportReg = QObject::tr("_EziDebug_%1_%2_r").arg(item->getScanChainInfo()->getChainName()).arg(iportName);

                if(1 == nportBitWidth)
                {
                    QString ilabelnet(QObject::tr("\n          <net is_signal_inverted=\"no\" name=\"%1\"/>").arg(iportHiberarchy + iportReg));
                    ifileContent.append(ilabelnet);
                }
                else if(nportBitWidth > 1)
                {
                    QString ilabelbusStart(QObject::tr("\n          <bus is_signal_inverted=\"no\" link=\"all\" name=\"%1\" order=\"lsb_to_msb\" radix=\"hex\" state=\"collapse\" type=\"register\">").arg(iportHiberarchy + iportReg));
                    ifileContent.append(ilabelbusStart);
                    for(int m = 0 ; m < nchildChainNum ; m++)
                    {
                        QString ilabelnet(QObject::tr("\n            <net is_signal_inverted=\"no\" name=\"%1[%2]\"/>").arg(iportHiberarchy + iportName).arg(m));
                        ifileContent.append(ilabelnet);
                    }
                    QString ilabelbusEnd(QObject::tr("\n          </bus>"));
                    ifileContent.append(ilabelbusEnd);
                }
                else
                {
                    return QString();
                }
            }
        }

        QString ilabelData_viewEnd(QObject::tr("\n        </data_view>"));
        ifileContent.append(ilabelData_viewEnd);


        QString ilabelSetup_viewStart(QObject::tr("\n        <setup_view>"));
        ifileContent.append(ilabelSetup_viewStart);


        // 新加入的 tdo_reg 输出端口 的 reg
//      QString iTdoPortName(QObject::tr("_EziDebug_%1_%2_TDO_r").arg(item->getScanChainInfo()->getChainName()).arg(iclockiterator.key()));
//      int nchildChainNum =  item->getScanChainInfo()->getChildChainNum(iclockiterator.key());

        if(1 == nchildChainNum)
        {
            QString ilabelnet(QObject::tr("\n          <net is_signal_inverted=\"no\" name=\"%1\"/>").arg(iregTdoHiberarchy + iTdoPortName));
            ifileContent.append(ilabelnet);
        }
        else if(nchildChainNum > 1)
        {
            QString ilabelbusStart(QObject::tr("\n          <bus is_signal_inverted=\"no\" link=\"all\" name=\"%1\" order=\"lsb_to_msb\" radix=\"hex\" state=\"collapse\" type=\"register\">").arg(iTdoPortName));
            ifileContent.append(ilabelbusStart);
            for(int m = 0 ; m < nchildChainNum ; m++)
            {
                QString ilabelnet(QObject::tr("\n            <net is_signal_inverted=\"no\" name=\"%1[%2]\"/>").arg(iregTdoHiberarchy + iTdoPortName).arg(m));
                ifileContent.append(ilabelnet);
            }
            QString ilabelbusEnd(QObject::tr("\n          </bus>"));
            ifileContent.append(ilabelbusEnd);
        }
        else
        {
            return QString();
        }

        QString itout_reg3(QObject::tr("\n          <net is_signal_inverted=\"no\" name=\"%1\"/>").arg(iregTdoHiberarchy + iToutRegName));
        ifileContent.append(itout_reg3);

        if(iscanPortClock == iclockiterator.key())
        {
            // 所有观测模块的 输入输出端口的  reg
            QVector<EziDebugModule::PortStructure*> iportVec = pmodule->getPort(this,item->getInstanceName());
            for(int i = 0 ; i < iportVec.count() ;i++)
            {
                QString iportName = QString::fromAscii(iportVec.at(i)->m_pPortName) ;
                if(!(pmodule->getClockSignal().value(iportName,QString())).isEmpty())
                {
                    continue ;
                }

                if(!(pmodule->getResetSignal().value(iportName,QString())).isEmpty())
                {
                    continue ;
                }

                QString iregHiberarchy = item->getItemHierarchyName();
                QString ieziDebugPortName ;
                //ieziDebugPortName.append(QObject::tr("_EziDebug_")+iportName + QObject::tr("_r"));
                ieziDebugPortName.append(QObject::tr("_EziDebug_%1_%2_r").arg(item->getScanChainInfo()->getChainName()).arg(iportName));

                if(1 == iportVec.at(i)->m_unBitwidth)
                {
                    QString ilabelnet(QObject::tr("\n          <net is_signal_inverted=\"no\" name=\"%1\"/>").arg(iregHiberarchy + ieziDebugPortName));
                    ifileContent.append(ilabelnet);
                }
                else
                {
                    QString ilabelbusStart(QObject::tr("\n          <bus is_signal_inverted=\"no\" link=\"all\" name=\"%1\" order=\"lsb_to_msb\" radix=\"hex\" state=\"collapse\" type=\"register\">").arg(ieziDebugPortName));
                    ifileContent.append(ilabelbusStart);
                    for(int j  = 0 ;j < iportVec.at(i)->m_unBitwidth ; j++)
                    {
                        QString ilabelnet(QObject::tr("\n            <net is_signal_inverted=\"no\" name=\"%1[%2]\"/>").arg(iregHiberarchy + ieziDebugPortName).arg(j));
                        ifileContent.append(ilabelnet);
                    }
                    QString ilabelbusEnd(QObject::tr("\n          </bus>"));
                    ifileContent.append(ilabelbusEnd);
                }
            }
        }


        if(iscanPortClock == iclockiterator.key())
        {
            // 内部系统模块的输出端口  reg
            QStringList iportList = item->getScanChainInfo()->getSyscoreOutputPortList() ;
            for(int n = 0 ; n < iportList.count() ;n++)
            {
                QString iportHiberarchy = iportList.at(n).split(QObject::tr("#")).at(0);
                QString iportName = iportList.at(n).split(QObject::tr("#")).at(1);
                QString iportReg = QObject::tr("_EziDebug_%1_%2_r").arg(item->getScanChainInfo()->getChainName()).arg(iportName);


                int nportBitWidth = iportList.at(n).split(QObject::tr("#")).at(2).toInt();
                if(1 == nportBitWidth)
                {
                    QString ilabelnet(QObject::tr("\n          <net is_signal_inverted=\"no\" name=\"%1\"/>").arg(iportHiberarchy + iportReg));
                    ifileContent.append(ilabelnet);
                }
                else if(nportBitWidth > 1)
                {
                    QString ilabelbusStart(QObject::tr("\n          <bus is_signal_inverted=\"no\" link=\"all\" name=\"%1\" order=\"lsb_to_msb\" radix=\"hex\" state=\"collapse\" type=\"register\">").arg(iportHiberarchy + iportReg));
                    ifileContent.append(ilabelbusStart);
                    for(int m = 0 ; m < nchildChainNum ; m++)
                    {
                        QString ilabelnet(QObject::tr("\n            <net is_signal_inverted=\"no\" name=\"%1[%2]\"/>").arg(iportHiberarchy + iportReg).arg(m));
                        ifileContent.append(ilabelnet);
                    }
                    QString ilabelbusEnd(QObject::tr("\n          </bus>"));
                    ifileContent.append(ilabelbusEnd);
                }
                else
                {
                    return QString();
                }
            }
        }

        QString ilabelSetup_viewEnd(QObject::tr("\n        </setup_view>"));
        ifileContent.append(ilabelSetup_viewEnd);


        QString ilabelPresentationEnd("\n      </presentation>");
        ifileContent.append(ilabelPresentationEnd);

        /*
            <trigger attribute_mem_mode="false" global_temp="1" name="trigger: 2012/10/31 19:32:21  #1" position="pre" power_up_trigger_mode="false" segment_size="1" trigger_in="dont_care" trigger_out="active high" trigger_type="circular">
              <power_up_trigger position="pre" trigger_in="dont_care" trigger_out="active high"/>
              <events use_custom_flow_control="no">
                <level enabled="yes" name="condition1" type="basic">
                  <power_up enabled="yes">
                  </power_up>
                  <op_node/>
                </level>
              </events>
            </trigger>
          </signal_set>
        </instance>
        <mnemonics/>
        */

        icurrentDate = QDate::currentDate();
        icurrentTime = QTime::currentTime();

        QString ilabelTriggerStart(QObject::tr("\n      <trigger attribute_mem_mode=\"false\" global_temp=\"1\" name=\"trigger: %1 %2  #1\" position=\"pre\" power_up_trigger_mode=\"false\" segment_size=\"1\" trigger_in=\"dont_care\" trigger_out=\"active high\" trigger_type=\"circular\">").arg(icurrentDate.toString(QObject::tr("yyyy/MM/dd")))\
                                   .arg(icurrentTime.toString(QObject::tr("hh:mm:ss")))) ;
        ifileContent.append(ilabelTriggerStart);

        QString ilabelPower_up_trigger(QObject::tr("\n        <power_up_trigger position=\"pre\" trigger_in=\"dont_care\" trigger_out=\"active high\"/>"));
        ifileContent.append(ilabelPower_up_trigger);

        QString ilabelEventStart(QObject::tr("\n        <events use_custom_flow_control=\"no\">"));
        ifileContent.append(ilabelEventStart);

        QString ilabelLevelStart(QObject::tr("\n          <level enabled=\"yes\" name=\"condition1\" type=\"basic\">"));
        ifileContent.append(ilabelLevelStart);

        QString ilabelPower_upStart(QObject::tr("\n            <power_up enabled=\"yes\">"));
        ifileContent.append(ilabelPower_upStart);


        QString ilabelPower_upEnd(QObject::tr("\n            </power_up>"));
        ifileContent.append(ilabelPower_upEnd);

        QString ilabelOp_nodeStart(QObject::tr("\n            <op_node/>"));
        ifileContent.append(ilabelOp_nodeStart);

        QString ilabelLevelEnd(QObject::tr("\n          </level>"));
        ifileContent.append(ilabelLevelEnd);

        QString ilabelEventEnd(QObject::tr("\n        </events>"));
        ifileContent.append(ilabelEventEnd);

        QString ilabelTriggerEnd(QObject::tr("\n      </trigger>"));
        ifileContent.append(ilabelTriggerEnd);


        QString ilabelSignal_setEnd(QObject::tr("\n    </signal_set>"));
        ifileContent.append(ilabelSignal_setEnd);

        QString ilabelPosition_infoStart(QObject::tr("\n    <position_info>")) ;
        ifileContent.append(ilabelPosition_infoStart);

        QString ilableSingle1(QObject::tr("\n      <single attribute=\"active tab\" value=\"1\"/>"));
        ifileContent.append(ilableSingle1);

        QString ilableSingle2(QObject::tr("\n      <single attribute=\"setup horizontal scroll position\" value=\"0\"/>"));
        ifileContent.append(ilableSingle2);

        QString ilableSingle3(QObject::tr("\n      <single attribute=\"setup vertical scroll position\" value=\"0\"/>"));
        ifileContent.append(ilableSingle3);

        QString ilabelPosition_infoEnd(QObject::tr("\n    </position_info>")) ;
        ifileContent.append(ilabelPosition_infoEnd);

        QString ilabelInstanceEnd(QObject::tr("\n  </instance>"));
        ifileContent.append(ilabelInstanceEnd);


        if(0 == i)
        {
            QString ilabelMnemonics(QObject::tr("\n  <mnemonics/>"));
            ifileContent.append(ilabelMnemonics);
        }

        ++iclockiterator ;
        ++i ;
    }

    return  ifileContent ;
}

#if 0
void EziDebugPrj::constructIlaunitString(int &regwidth,int &triggernum)
{
    if(regwidth >= 255)
    {
        regwidth = 0 ;
        triggernum++ ;
    }
    else
    {
        ++regwidth ;
    }
}
#endif





