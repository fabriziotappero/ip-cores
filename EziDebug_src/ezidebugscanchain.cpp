#include "ezidebugscanchain.h"
#include "ezidebuginstancetreeitem.h"
#include "ezidebugmodule.h"
#include <QDebug>
EziDebugScanChain::EziDebugScanChain(const QString& chainname):m_iChainName(chainname)
{

}

EziDebugScanChain::~EziDebugScanChain()
{
//    if(!m_ptestBechFile)
//        delete m_ptestBechFile ;
}

QString EziDebugScanChain::m_iscanChainRegCore(QObject::tr("No Core")) ;
QString EziDebugScanChain::m_iscanChainIoCore(QObject::tr("No Core")) ;
QString EziDebugScanChain::m_iscanChainToutCore(QObject::tr("No Core")) ;
QString EziDebugScanChain::m_iuserDir(QObject::tr("No Dir")) ;

const QString &EziDebugScanChain::getChainName(void) const
{
    return m_iChainName ;
}

void EziDebugScanChain::addToInstanceItemList(QString modulename ,QString instancename)
{
    QString iitemString = modulename + QObject::tr(":")+ instancename ;
    m_iinstanceItemList.append(iitemString);

    return ;
}

void EziDebugScanChain::removeItemListDuplicates(void)
{
    m_iinstanceItemList.removeDuplicates();
    return ;
}

void EziDebugScanChain::addToScanedFileList(const QString & filename)
{
    m_iscanedFileNameList <<  filename ;
    return ;
}


void EziDebugScanChain::backupFileList(void)
{
    m_isbackupscanedFileNameList = m_iscanedFileNameList ;
    return ;
}

const QStringList &EziDebugScanChain::getBackupFileList(void) const
{
    return  m_isbackupscanedFileNameList ;
}

void EziDebugScanChain::clearupFileList(void)
{
    m_iscanedFileNameList.clear();
    return ;
}

void EziDebugScanChain::resumeFileList(void)
{
    m_iscanedFileNameList = m_isbackupscanedFileNameList ;
    return ;
}

const QStringList& EziDebugScanChain::getScanedFileList(void) const
{
    return m_iscanedFileNameList ;
}

void EziDebugScanChain::removeScanedFileListDuplicate(void)
{
    m_iscanedFileNameList.removeDuplicates() ;
}

void EziDebugScanChain::setChildChainNum(QString clock ,int num)
{
    m_nchildChainNumMap.insert(clock,num) ;
}

 void EziDebugScanChain::setHeadTreeItem(EziDebugInstanceTreeItem *item)
 {
    m_pheadItem =  item;
    return ;
 }

 EziDebugInstanceTreeItem * EziDebugScanChain::getHeadTreeItem(void)
 {
    return m_pheadItem ;
 }


/*
QString EziDebugScanChain::getFirstInstanceItemName() const
{
    return m_iChainName ;
}
*/

void EziDebugScanChain::addToLineCodeMap(const QString &modulename, const QStringList &code)
{
    QStringList ialreadyExistCodeStr = m_icodeMap.value(modulename,QStringList()) ;
    if(ialreadyExistCodeStr.count())
    {
        m_icodeMap.remove(modulename);
    }
    ialreadyExistCodeStr.append(code);

    m_icodeMap.insert(modulename,ialreadyExistCodeStr);
    return ;
}

void EziDebugScanChain::addToBlockCodeMap(const QString &modulename, const QStringList &code)
{
    QStringList ialreadyExistCodeStr = m_iblockCodeMap.value(modulename,QStringList()) ;
    if(ialreadyExistCodeStr.count())
    {
        m_iblockCodeMap.remove(modulename);
    }
    ialreadyExistCodeStr.append(code);

    m_iblockCodeMap.insert(modulename,ialreadyExistCodeStr);
    return ;
}

void  EziDebugScanChain::replaceLineCodeMap(const QString &modulename, const QStringList &code)
{
    m_icodeMap.remove(modulename) ;
    m_icodeMap.insert(modulename,code);
}

void  EziDebugScanChain::replaceBlockCodeMap(const QString &modulename, const QStringList &code)
{
    m_iblockCodeMap.remove(modulename);
    m_iblockCodeMap.insert(modulename,code);
}


void EziDebugScanChain::addToClockSetMap(EziDebugInstanceTreeItem *item)
{
    if(!item)
        return ;

    if(item == m_pheadItem)
    {   

        EziDebugInstanceTreeItem * pparentItem = item->parent();
        QMap<QString,QString> iclockMap = pparentItem->getModuleClockMap(item->getInstanceName());
        QMap<QString,QString>::const_iterator i = iclockMap.constBegin();
        while( i!= iclockMap.constEnd())
        {
            QStringList itopclock ;
            QString iclock =  i.value() ;
            if(!iclock.isEmpty())
            {
                itopclock.append(item->getInstanceName() + QObject::tr(":") + iclock);
                m_iclockSetMap.insert(i.key(),itopclock);
            }
            ++i ;
        }
    }
    else
    {   

        // 根据 父节点所在集合位置,将本节点的 clock 加入到相应的 集合 , 找不到 端口 时钟对应关系 则不加入
        EziDebugInstanceTreeItem * pparentItem = item->parent();

        QMap<QString,QString> iclockMap = pparentItem->getModuleClockMap(item->getInstanceName());
        QMap<QString,QString>::const_iterator j = iclockMap.constBegin() ;
        while(j != iclockMap.constEnd())
        {
            QString iparentClock  =  pparentItem->getInstanceName() + QObject::tr(":") + j.key();
            QMap<QString,QStringList>::const_iterator i = m_iclockSetMap.constBegin();
            while( i!= m_iclockSetMap.constEnd())
            {
                QStringList iclockList =  i.value();
                if(iclockList.contains(iparentClock))
                {
                    QString iitemClock = iclockMap.value(j.key(),QString());
                    if(!iitemClock.isEmpty())
                    {
                        iclockList << (item->getInstanceName() + QObject::tr(":") +  iitemClock) ;
                        m_iclockSetMap.insert(i.key(),iclockList);
                    }
                }               
                ++i ;
            }
            ++j ;
        }
    }

}


QString EziDebugScanChain::getChainClock(QString instancename,QString clock)
{
    QString iitemClock ;
    iitemClock = instancename + QObject::tr(":") + clock ;
    QMap<QString,QStringList>::const_iterator i = m_iclockSetMap.constBegin();
    while( i!= m_iclockSetMap.constEnd())
    {
        if(m_iclockSetMap.value(i.key()).contains(iitemClock))
        {
            return i.key();
        }
        else
        {
            continue ;
        }
        ++i ;
    }
    iitemClock.clear();
    return iitemClock ;
}

const QMap<QString,QStringList> &EziDebugScanChain::getLineCode(void) const
{
    return m_icodeMap ;
}

const QMap<QString,QStringList> &EziDebugScanChain::getBlockCode(void) const
{
     return m_iblockCodeMap ;
}

/*
int EziDebugScanChain::codeNum(QString modulename)
{
    return 0 ;
}
*/

const QMap<QString,QVector<QStringList> > & EziDebugScanChain::getRegChain(void) const
{
    return m_iregChainStructure ;
}

int EziDebugScanChain::getChildChainNum(QString clock)
{
    return m_nchildChainNumMap.value(clock,0) ;
}

const QStringList &EziDebugScanChain::getSyscoreOutputPortList(void)
{
    return m_isysCoreOutputPortList ;
}

void EziDebugScanChain::addToSyscoreOutputPortList(const QString& portlist)
{
    m_isysCoreOutputPortList.append(portlist);
    return ;
}

const QString &EziDebugScanChain::getscaningPortClock(void) const
{
    return m_iscaningPortClock ;
}

const QString &EziDebugScanChain::getSlowClock(void) const
{
    return m_islowClock ;
}

 const QStringList &EziDebugScanChain::getInstanceItemList(void) const
 {
    return m_iinstanceItemList ;
 }

 int  EziDebugScanChain::traverseAllInstanceNode(EziDebugInstanceTreeItem *item)
 {
     QString imoduleName = item->getModuleName() ;
     int nresult = 0 ;
     EziDebugPrj *icurrentPrj = const_cast<EziDebugPrj *>(EziDebugInstanceTreeItem::getProject());
     if(!icurrentPrj)
     {
         return 1 ;
     }
     int nappearanceTimes =  icurrentPrj->getPrjModuleMap().value(imoduleName)->getInstancedTimesPerChain(m_iChainName) ;

     nappearanceTimes++ ;
     icurrentPrj->getPrjModuleMap().value(imoduleName)->setInstancedTimesPerChain(m_iChainName,nappearanceTimes);
     icurrentPrj->getPrjModuleMap().value(imoduleName)->setConstInstanceTimesPerChain(m_iChainName,nappearanceTimes);
     icurrentPrj->getPrjModuleMap().value(imoduleName)->setAddCodeFlag(false);
     icurrentPrj->getPrjModuleMap().value(imoduleName)->setRegInfoToInitalState();

     // 清空
     for(int i = 0 ; i < item->childCount();i++)
     {
         if(nresult = traverseAllInstanceNode(item->child(i)))
         {
            return nresult ;
         }
     }
     this->addToInstanceItemList(item->getModuleName(),item->getInstanceName());
     return nresult;
 }

int EziDebugScanChain::traverseChainAllReg(EziDebugInstanceTreeItem *item)
{
    EziDebugPrj *icurrentPrj = const_cast<EziDebugPrj *>(EziDebugInstanceTreeItem::getProject());
    int nresult = 0 ;

    if(!icurrentPrj)
    {
        qDebug() << "the Prj Pointer is NULL!";
        return 1 ;
    }

    for(int i = 0 ; i < item->childCount();i++)
    {
        if(nresult = traverseChainAllReg(item->child(i)))
        {
           return nresult ;
        }
    }

    icurrentPrj->getPrjModuleMap().value(item->getModuleName())->constructChainRegMap(icurrentPrj , m_iinstanceItemList,item->getInstanceName()) ;

    return nresult;
}


int EziDebugScanChain::compareCodeSequence(const QMap<QString,int> &ilinesearchposMap ,const QMap<QString,int> &iblocksearchposMap )
{
    return 0 ;
}

void EziDebugScanChain::addToRegChain(QString clock ,int chainNum , const QStringList& reglist)
{
    QVector<QStringList> iregListVec  = m_iregChainStructure.value(clock) ;
    int i = 0 ;

    qDebug() << "EziDebug Info: The insert chain number:" << chainNum  ;

    if(iregListVec.count())
    {
        for(i = 0 ; i < iregListVec.count() ; i++)
        {
            // 加入到 未完毕的链
            if(i == chainNum)
            {
                QStringList ioriginRegList = iregListVec.at(i) ;
                ioriginRegList << reglist ;
                iregListVec.replace(i,ioriginRegList);
                m_iregChainStructure.insert(clock,iregListVec);
                break ;
            }
        }
        // 新增链
        if(i == iregListVec.count())
        {
            // 新增 链
            if(chainNum != iregListVec.count())
            {
                qDebug() << "EziDebug Error: the reglist is insert chain number:" << chainNum  <<" is not equal to total number:" << iregListVec.count() ;
            }
            iregListVec.insert(chainNum ,reglist);
            m_iregChainStructure.insert(clock,iregListVec);
        }
    }
    else
    {
       if(chainNum != 0)
       {
           qDebug() << "EziDebug Error: the reglist is insert chain number:" << chainNum  <<" is not right" ;
       }
       iregListVec.insert(0,reglist);
       m_iregChainStructure.insert(clock,iregListVec);
    }

    return ;
}

void EziDebugScanChain::setChainRegCount(const QString &clock ,int count)
{
    m_nregCountMap.insert(clock,count);
}

int EziDebugScanChain::getChainRegCount(QString clock)
{
   return m_nregCountMap.value(clock,0);
}


const QString &EziDebugScanChain::getCfgFileName(void) const
{
    return m_iChainName ;
}

/*
EziDebugTemplateFile * EziDebugScanChain::getTestBenchFile() const
{
    return m_ptestBechFile ;
}
*/

const QString& EziDebugScanChain::getChainRegCore(void)
{
    return m_iscanChainRegCore ;
}

const QString& EziDebugScanChain::getChainToutCore(void)
{
    return m_iscanChainToutCore ;
}

const QString& EziDebugScanChain::getUserDir(void)
{
    return m_iuserDir ;
}

void  EziDebugScanChain::saveEziDebugAddedInfo(const QString &regcore,const QString &toutcore,const QString &dir)
{
    m_iscanChainRegCore = regcore ;
    m_iscanChainToutCore = toutcore ;
    m_iuserDir = dir ;
}

