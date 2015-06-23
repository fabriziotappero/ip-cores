#include <QString>
#include <QStringList>
#include <QVector>
#include <QMap>
#include "ezidebugmodule.h"
#include "ezidebugscanchain.h"
#include <QDebug>
#include "reg_scan.h"


EziDebugModule::EziDebugModule(const QString modulename):m_imoduleName(modulename)
{
    m_ninstanceTimes = 0 ;
    m_isaddedCode = false ;
    m_isLibaryCore = false ;
    m_isSubstituted = false ;

}

EziDebugModule::~EziDebugModule()
{
    //QMap<QString,QVector<EziDebugModule::RegStructure*> > m_iregMap ;
    QMap<QString,QVector<EziDebugModule::RegStructure*> >::iterator i =  m_iregMap.begin() ;
    while(i!= m_iregMap.end())
    {
        QVector<EziDebugModule::RegStructure*> iregVec = i.value();
        qDeleteAll(iregVec);
        ++i;
    }

    QMap<QString,QMap<QString ,QVector<RegStructure*> > >::const_iterator iinstanceRegMapIter = m_iinstanceRegMap.constBegin() ;
    while(iinstanceRegMapIter != m_iinstanceRegMap.constEnd())
    {
        QMap<QString ,QVector<RegStructure*> > iregClockVec = iinstanceRegMapIter.value() ;
        QMap<QString ,QVector<RegStructure*> >::const_iterator iregClockVecIter = iregClockVec.constBegin() ;
        while(iregClockVecIter != iregClockVec.constEnd())
        {
            QVector<RegStructure*> iregVec = iregClockVecIter.value();
            qDeleteAll(iregVec) ;
            ++iregClockVecIter ;
        }
        ++iinstanceRegMapIter ;
    }

    //QVector<PortStructure*> m_iportVec ;
    qDeleteAll(m_iportVec);

}

QString EziDebugModule::getModuleName(void) const
{
    return  m_imoduleName ;
}

QVector<EziDebugModule::RegStructure*> EziDebugModule::getReg(const QString &clock)
{
    return m_iregMap.value(clock) ;
}

const QMap<QString,QVector<EziDebugModule::RegStructure*> >EziDebugModule:: getRegMap(void) const
{
    return  m_iregMap ;
}



const QStringList &EziDebugModule::getInstanceList(void) const
{
    return m_iinstanceNameList ;
}

const QMap<QString,QString> &EziDebugModule::getClockSignal(void) const
{
    return m_iclockMap ;
}

const QMap<QString,QString> &EziDebugModule::getResetSignal(void) const
{
    return m_iresetMap ;
}

const QVector<EziDebugModule::PortStructure*> &EziDebugModule::getPort(EziDebugPrj *prj ,const QString &instancename)
{      
    int nportCount = 0 ;
    int nfirstBit = 0 ;
    int nSecondBit = 0 ;
    bool isParamInvolveMacro = false ;
    QMap<QString,QString> idefParamMap = m_idefparameter.value(instancename) ;
    QMap<QString,QString> imacroMap = prj->getMacroMap() ;
    QString imacroPrefix("`");
    QRegExp imacroStr("`(\\w+)") ;
    PortStructure* pport = NULL ;
    QMap<QString,QString>::const_iterator iparamIter = m_iparameter.constBegin() ;
    for(;nportCount < m_iportVec.count();nportCount++)
    {
        pport = m_iportVec.at(nportCount) ;
        QString iportWidth = QString::fromAscii(pport->m_pBitWidth);

        while(iparamIter != m_iparameter.constEnd())
        {
            if(idefParamMap.value(iparamIter.key(),QString()).isEmpty())
            {
                // 用 paramete 替换
                iportWidth.replace(iparamIter.key() , iparamIter.value());
            }
            else
            {
                // 用 defparam 替换
                iportWidth.replace(iparamIter.key() , idefParamMap.value(iparamIter.key()));
            }


            // 排出 parameter 引入 define 导致 交替引用
            while(-1 != imacroStr.indexIn(iportWidth))
            {
                QString icapMacroStr = imacroStr.cap(1) ;
                iportWidth = iportWidth.replace(imacroPrefix+icapMacroStr,imacroMap.value(icapMacroStr));
                isParamInvolveMacro = true ;
            }

            if(isParamInvolveMacro)
            {
               // 重新扫描 是否含有 parameter
               iparamIter = m_iparameter.constBegin() ;
               isParamInvolveMacro = false ;
               continue ;
            }
            ++iparamIter ;
        }

        if(!iportWidth.compare("1"))
        {
            pport->m_unStartBit = 0 ;
            pport->m_unEndBit =  0 ;
            pport->m_eEndian = endianBig ;
            pport->m_unBitwidth = 1 ;
        }
        else
        {
            getBitRange(iportWidth,&nfirstBit,&nSecondBit);

            if((nfirstBit < 0)||(nSecondBit < 0))
            {
                qDebug() << "EziDebug Error: The caculate result is not right!";
                pport->m_unBitwidth = 0 ;
                break ;
            }

            pport->m_unStartBit = nfirstBit ;
            pport->m_unEndBit = nSecondBit ;

            if(nfirstBit > nSecondBit)
            {
                pport->m_eEndian = endianBig ;
            }
            else
            {
                pport->m_eEndian = endianLittle ;
            }

            pport->m_unBitwidth = qAbs(nfirstBit-nSecondBit) + 1 ;
        }
    }
    return m_iportVec ;
}

void EziDebugModule::addToClockMap(const QString &clock)
{
    // value 暂时没有用处 ，以后可能用于 clock 的别名
    m_iclockMap.insert(clock,"posedge");
    return ;
}

void EziDebugModule::addToResetSignalMap(const QString &reset,const QString &edge)
{
    // value 暂时没有用处 ，以后可能用于 clock 的别名
    m_iresetMap.insert(reset,edge);
    return ;
}

const QString &EziDebugModule::getLocatedFileName(void) const
{
    return m_ilocatedFile ;
}

bool EziDebugModule::getAddCodeFlag(void)
{
    return m_isaddedCode ;
}

int EziDebugModule::getInstancedTimesPerChain(const QString &chainName)
{
    return m_iinstanceTimesPerChain.value(chainName);
}

int EziDebugModule::getConstInstacedTimesPerChain(const QString &chainName)
{
    return m_iconstInstanceTimesPerChain.value(chainName);
}

const QMap<QString,QMap<QString,QString> > &EziDebugModule::getInstancePortMap(void) const
{
     return m_iinstancePortMap ;
}

QMap<QString,QString> EziDebugModule::getInstancePortMap(const QString &instanceName)
{
    return m_iinstancePortMap.value(instanceName);
}

/*
int EziDebugModule::getRegNumber(const QString &clock)
{
    int nnum = 0 ;
    QMap<QString,QVector<EziDebugModule::RegStructure*> >::const_iterator i = m_iregMap.constBegin();
    while (i != m_iregMap.constEnd())
    {
        if(i.key()== clock)
        {
            QVector<EziDebugModule::RegStructure*> iregVec = i.value() ;
            for(int j = 0 ; j < iregVec.count();j++)
            {
                nnum += iregVec.at(j)->m_unBitWidth*iregVec.at(j)->m_unRegNum ;
            }
        }
        ++i;
    }
    return  nnum;
}
*/
void EziDebugModule::getBitRangeInChain(const QString& chainname, const QString &clockname, int* startbit,int * endbit)
{
        QMap<QString,int> iclockStartBitMap = m_istartChainNum.value(chainname);
        *startbit = iclockStartBitMap.value(clockname,-1) ;

        QMap<QString,int> iclockEndBitMap = m_iendChainNum.value(chainname);
        *endbit =iclockEndBitMap.value(clockname,-1) ;
        return ;
}

void EziDebugModule::setBitRangeInChain(const QString& chainname, const QString &clockname, int startbit,int endbit)
{
    QMap<QString,int> iclockStartBitMap ;
    iclockStartBitMap.insert(clockname,startbit);
    m_istartChainNum.insert(chainname,iclockStartBitMap);


    QMap<QString,int> iclockEndBitMap ;
    iclockEndBitMap.insert(clockname,endbit);
    m_iendChainNum.insert(chainname,iclockEndBitMap);

    return ;
}

void  EziDebugModule::AddToRegMap(const QString &clock,RegStructure*preg)
{
    QVector<RegStructure*> iregVec ;
    iregVec = m_iregMap.value(clock,iregVec);

    iregVec.append(preg);

    m_iregMap.insert(clock,iregVec);
    return ;
}

/*
void EziDebugModule::addToVaribleRegMap(const QString &clock,RegStructure*preg)
{
    QVector<RegStructure*> m_ivreg ;

    m_ivreg = m_ivregMap.value(clock,m_ivreg);

    m_ivreg.append(preg);

    m_ivregMap.insert(clock,m_ivreg);
}
*/
void  EziDebugModule::addToDefParameterMap(const QString &instancename, const QString &parametername ,const QString &value)
{
    QMap<QString,QString> iparameter  ;
    iparameter = m_idefparameter.value(instancename,iparameter) ;
    iparameter.insert(parametername,value);
    m_idefparameter.insert(instancename,iparameter);
}

void  EziDebugModule::addToParameterMap(const QString &parametername,const QString &value)
{
    m_iparameter.insert(parametername,value);
}

//void  EziDebugModule::setInstanceTimes(int count)
//{
//    m_ninstanceTimes = count ;
//    return ;
//}


void  EziDebugModule::setInstancedTimesPerChain(const QString &chainname,int count)
{
    m_iinstanceTimesPerChain.insert(chainname,count);
    return ;
}

void  EziDebugModule::setConstInstanceTimesPerChain(const QString &chainname,int count)
{
    m_iconstInstanceTimesPerChain.insert(chainname,count);
    return ;
}

void  EziDebugModule::setEziDebugCoreCounts(const QString &chainname,int count)
{
    m_ieziDebugCoreCounts.insert(chainname,count);
    return ;
}

int  EziDebugModule::getEziDebugCoreCounts(const QString &chainname)
{
    return m_ieziDebugCoreCounts.value(chainname,0);
}

void  EziDebugModule::setEziDebugWireCounts(const QString &chainname,int count)
{
    m_ieziDebugWireCounts.insert(chainname,count);
    return ;
}

int  EziDebugModule::getEziDebugWireCounts(const QString &chainname)
{
    return m_ieziDebugWireCounts.value(chainname,0);
}


void  EziDebugModule::AddToClockWireNameMap(const QString& chainname,const QString& clockname,const QString& lastwirename)
{
    QMap<QString,QString> iclockWireMap ;
    iclockWireMap = m_iclockWireNameMap.value(chainname);
    iclockWireMap.insert(clockname,lastwirename);
    m_iclockWireNameMap.insert(chainname,iclockWireMap);
    return ;
}

void  EziDebugModule::setAddCodeFlag(bool flag)
{
    m_isaddedCode = flag ;
    return ;
}

void  EziDebugModule::setRegInfoToInitalState(void)
{
    // 所有时钟
    int nregCount = 0 ;
    QMap<QString,QVector<RegStructure*> >::iterator iRegMapIter = m_iregMap.begin() ;
    while(iRegMapIter != m_iregMap.end())
    {
        QString iclock =  iRegMapIter.key() ;
        QVector<RegStructure*> iregVec = iRegMapIter.value() ;
        for(;nregCount < iregVec.count() ;nregCount++)
        {
            RegStructure* preg = iregVec.at(nregCount) ;

            preg->m_unMaxRegNum = 0 ;
            preg->m_eRegNumEndian = endianOther ;
            preg->m_eRegNumType = attributeOther ;
            preg->m_unMaxBitWidth = 0 ;
            preg->m_eRegBitWidthEndian = endianOther ;
            preg->m_eRegBitWidthType = attributeOther ;
            preg->m_unStartNum = 0 ;
            preg->m_unEndNum = 0 ;
            preg->m_unRegNum = 0 ;
            preg->m_unStartBit = 0 ;
            preg->m_unEndBit = 0 ;
            preg->m_unRegBitWidth = 0 ;
        }
        m_iregMap.insert(iclock ,iregVec);

        ++iRegMapIter ;
    }

}


bool EziDebugModule::isChainCompleted(EziDebugScanChain *pchain)
{
    int nstartPos = 0 ;
    int nendPos = 0 ;
    bool isFinded = false ;
    //QString iregName ;
    QStringList iinstList = pchain->getInstanceItemList() ;
    QStringList iregRearchResult ;


    QMap<QString,QVector<QStringList> > iregListMap  = pchain->getRegChain() ;

    QMap<QString,QString>::const_iterator imoduleClockIter = m_iclockMap.constBegin() ;

    while(imoduleClockIter != m_iclockMap.constEnd())
    {
        iregRearchResult.clear();
        QMap<QString,QVector<QStringList> >::const_iterator i = iregListMap.constBegin();

        while(i != iregListMap.constEnd())
        {
            QVector<QStringList> iregListVec = i.value();

            for(int m = 0 ; m < iregListVec.count() ; m++)
            {
                QStringList iregList = iregListVec.at(m) ;
                // modulename#instancename#clockname#hibername#regname
                nstartPos = iregList.indexOf(QRegExp(m_imoduleName + QObject::tr("#\\w+") + imoduleClockIter.key() + QObject::tr(".*")),0) ;
                if(nstartPos != -1)
                {
                    // 找到instance name
                    isFinded = true ;
                    nendPos = iregList.lastIndexOf(QRegExp(m_imoduleName + QObject::tr("#\\w+") + imoduleClockIter.key() + QObject::tr(".*")));

                    // 还要继续查找
                    if(-1 != nendPos)
                    {
                        for(int n = nstartPos ; n <= nendPos ; n++)
                        {
                            iregRearchResult <<  iregList.at(n);
                        }
                        break ;
                    }
                }
            }

             // no finded
            if(!isFinded)
            {
                // 换个时钟链
                ++i ;
                continue ;
            }

            QString iregName ;
            QString iregNum ;
            QString ibitWidth ;
            QString icombinatedStr ;

            // finded
            QStringList icompareOne ;
            QStringList icompareSecond ;
            if((nendPos != -1)&&(nstartPos != -1))
            {
                // 将链状 寄存器 转换成 字符串
                for(int i = 0 ; i < iregRearchResult.count(); i++)
                {
                     iregName = iregRearchResult.at(i).split('#').at(4);
                     ibitWidth = iregRearchResult.at(i).split('#').at(7);
                     iregNum = iregRearchResult.at(i).split('#').at(10);

                     icombinatedStr = iregName \
                                            + QObject::tr("#") \
                                            + ibitWidth \
                                            + QObject::tr("#") \
                                            + iregNum ;
                    icompareSecond << icombinatedStr ;
                }
                icompareSecond.removeDuplicates();
                icompareSecond.sort();

                QVector<EziDebugModule::RegStructure*> imoduleRegVec =  m_iregMap.value(imoduleClockIter.key()) ;
                for(int j = 0 ; j < imoduleRegVec.count() ; ++j)
                {
                    EziDebugModule::RegStructure*  preg = imoduleRegVec.at(j);
                     iregName = QString::fromAscii(preg->m_pRegName);
                     ibitWidth = QString::fromAscii(preg->m_pExpString) ;
                     iregNum  = QString::fromAscii(preg->m_pregNum) ;


                     icombinatedStr = iregName \
                            + QObject::tr("#") \
                            + ibitWidth \
                            + QObject::tr("#") \
                            + iregNum  ;

                    icompareOne << icombinatedStr ;
                }
                icompareOne.sort();

                if(icompareOne == icompareSecond)
                {
                    break ;
                }
                else
                {
                    qDebug() << "EziDebug warning:The chain is destroyed!" ;
                    qDebug() << "EziDebug warning:first string"  << icompareOne << endl;
                    qDebug() << "EziDebug warning:second string" << icompareSecond << endl;
                    return 0 ;
                }
            }
            else
            {
                qDebug() << "EziDebug warning: pos is not right!";
                return 0 ;
            }
        }
        ++imoduleClockIter ;
    }


    iinstList.removeDuplicates() ;

    for(int i = 0 ; i< m_iinstanceNameList.count() ;i++)
    {
        if(iinstList.contains(m_iinstanceNameList.at(i)))
        {
            continue ;
        }
        else
        {
            qDebug() << "EziDebug warning:The chain is destroyed!" ;
            qDebug() << "EziDebug warning:old list" << iinstList ;
            qDebug() << "EziDebug warning:new list" << m_iinstanceNameList ;
            return 0 ;
        }
    }

    return 1 ;
}

bool EziDebugModule::isChainCompleted(EziDebugModule *pmodue)
{
    QStringList icompareOne ;
    QStringList icompareSecond ;
    QString icombinatedStr ;
    QString iregName ;
    QString iregNum ;
    QString iendian ;
    QString ibitWidth ;
    QStringList iinstList = pmodue->getInstanceList() ;

    QMap<QString,QString> iclockMap = pmodue->getClockSignal();

    if(iclockMap != m_iclockMap)
    {
        qDebug() << "EziDebug warning:The chain is destroyed!" ;
        qDebug() << "EziDebug warning:old clock" << iclockMap ;
        qDebug() << "EziDebug warning:old clock" << m_iclockMap ;
        return 0 ;
    }

    QMap<QString,QString>::const_iterator imoduleClockIter = iclockMap.constBegin() ;
    while(imoduleClockIter != iclockMap.constEnd())
    {
        QVector<EziDebugModule::RegStructure*> imoduleRegVec =  m_iregMap.value(imoduleClockIter.key()) ;
        for(int j = 0 ; j < imoduleRegVec.count() ; ++j)
        {
            EziDebugModule::RegStructure*  preg = imoduleRegVec.at(j);
            iregName = QString::fromAscii(preg->m_pRegName);
            // iregNum  = QString::number(preg->m_unRegNum) ;
            // iendian = QString::number((int)preg->m_isEndian) ;
            // ibitWidth = QString::number((int)preg->m_unBitWidth) ;
            icombinatedStr = iregName \
                    + QObject::tr("%") \
                    + iregNum \
                    + QObject::tr("%") \
                    + ibitWidth \
                    + QObject::tr("%") \
                    + iendian ;
            icompareOne << icombinatedStr ;
        }
        icompareOne.sort();


        imoduleRegVec = pmodue->getReg(imoduleClockIter.key()) ;

        for(int j = 0 ; j < imoduleRegVec.count() ; ++j)
        {
            EziDebugModule::RegStructure*  preg = imoduleRegVec.at(j);
            iregName = QString::fromAscii(preg->m_pRegName);
            // iregNum  = QString::number(preg->m_unRegNum) ;
            // iendian = QString::number((int)preg->m_isEndian) ;
            // ibitWidth = QString::number((int)preg->m_unBitWidth) ;
            icombinatedStr = iregName \
                    + QObject::tr("%") \
                    + iregNum \
                    + QObject::tr("%") \
                    + ibitWidth \
                    + QObject::tr("%") \
                    + iendian ;
            icompareSecond << icombinatedStr ;
        }
        icompareSecond.sort();

        if(icompareOne == icompareSecond)
        {
            ++imoduleClockIter ;
            continue ;
        }
        else
        {
            qDebug() << "EziDebug warning:The chain is destroyed!" ;
            qDebug() << "EziDebug warning:old string" << icompareOne ;
            qDebug() << "EziDebug warning:new string" << icompareSecond ;
            return 0 ;
        }
        ++imoduleClockIter ;
    }

    for(int i = 0 ; i< m_iinstanceNameList.count() ;i++)
    {
        if(iinstList.contains(m_iinstanceNameList.at(i)))
        {
            continue ;
        }
        else
        {
            qDebug() << "EziDebug warning:The chain is destroyed!" ;
            qDebug() << "EziDebug warning:old list" << iinstList ;
            qDebug() << "EziDebug warning:new list" << m_iinstanceNameList ;
            return 0 ;
        }
    }

    return 1 ;
}

int EziDebugModule::getInstanceTimes(void)
{
    return m_ninstanceTimes ;
}

QString EziDebugModule::getChainClockWireNameMap(const QString& chainname ,const QString& clockname)
{
    QMap<QString,QString> iclockWireMap ;
    iclockWireMap = m_iclockWireNameMap.value(chainname);
    return iclockWireMap.value(clockname,QString());
}

bool EziDebugModule::isLibaryCore(void)
{
    return m_isLibaryCore ;
}

void  EziDebugModule::setLibaryCoreFlag(bool flag)
{
     m_isLibaryCore = flag ;
}

void  EziDebugModule::clearChainInfo(const QString& chainname)
{
    m_iclockWireNameMap.remove(chainname);
    m_istartChainNum.remove(chainname);
    m_iendChainNum.remove(chainname);
    m_iinstanceTimesPerChain.remove(chainname);
    m_iconstInstanceTimesPerChain.remove(chainname);
    m_ieziDebugCoreCounts.remove(chainname);
    m_ieziDebugWireCounts.remove(chainname);
    return ;
}

int  EziDebugModule::getAllRegMap(QString clock ,QVector<EziDebugModule::RegStructure*> &sregVec,QVector<EziDebugModule::RegStructure*> &vregVec)
{     
    // 根据 m_iregMap 所有寄存器中的 动、静标志 来获取所有的寄存器
    int nregCount = 0 ;
    QVector<RegStructure*> iregVec ;
    iregVec = m_iregMap.value(clock ,iregVec) ;
    for(;nregCount < iregVec.count();nregCount++)
    {
        RegStructure* preg = iregVec.at(nregCount);
        if((preg->m_eRegNumType == attributeDynamic)\
          ||(preg->m_eRegBitWidthType == attributeDynamic))
        {
            vregVec.append(preg);
        }
        else if((preg->m_eRegNumType == attributeOther)\
                ||(preg->m_eRegBitWidthType == attributeOther))
        {
            qDebug() << "EziDebug Error: The reg map is wrong!";
            return 1 ;
        }
        else
        {
            sregVec.append(preg);
        }
    }
}

 void  EziDebugModule::calInstanceRegData(EziDebugPrj *prj , const QString &instancename)
 {
     int nFirstBit = 0 ;
     int nSecondBit = 0 ;
     int nregNumFirstBit = 0 ;
     int nregNumSecondBit = 0 ;
     int nregNum = 0 ;
     int nbitWidth = 0 ;
     bool isParamInvolveMacro = false ;

     QString imacroPrefix("`");
     QRegExp imacroStr("`(\\w+)") ;
     QMap<QString,QString> imacroMap = prj->getMacroMap();
     QMap<QString,QString> idefParamMap = prj->getdefparam(instancename);
     // 加入到module的defparameter中
     if(idefParamMap.count())
     {
         m_idefparameter.insert(instancename ,idefParamMap);
     }

     QMap<QString,QString>::const_iterator iparamIter = m_iparameter.constBegin() ;

     QMap<QString,QVector<RegStructure*> >::const_iterator i = m_iregMap.constBegin() ;

     if(!prj)
     {
         return  ;
     }

     if(!m_isSubstituted)
     {
         while(i != m_iregMap.constEnd())
         {
            QVector<RegStructure*>  iregVec = i.value();
            for(int j = 0 ; j < iregVec.count() ; j++)
            {
                RegStructure* preg = iregVec.at(j) ;

                QString iregWidth = QString::fromAscii(preg->m_pExpString) ;
                QString iregNum = QString::fromAscii(preg->m_pregNum);
                // 排出 由于 define 引入的 parameter
                while(-1 != imacroStr.indexIn(iregWidth))
                {
                    QString icapMacroStr = imacroStr.cap(1) ;
                    iregWidth = iregWidth.replace(imacroPrefix+icapMacroStr,imacroMap.value(icapMacroStr));
                }

                while(-1 != imacroStr.indexIn(iregNum))
                {
                    QString icapMacroStr = imacroStr.cap(1) ;
                    iregNum = iregNum.replace(imacroPrefix+icapMacroStr,imacroMap.value(icapMacroStr));
                }

                // 检测 位宽中 是否存在 parameter  ,
                qstrcpy(preg->m_pExpNoMacroString ,iregWidth.toAscii().constData()) ;
                qstrcpy(preg->m_pregNumNoMacroString,iregNum.toAscii().constData()) ;
            }
            ++i ;
         }
         m_isSubstituted = true ;
     }

     i = m_iregMap.constBegin() ;
     while(i != m_iregMap.constEnd())
     {
         QVector<RegStructure*>  iregVec = i.value();
         for(int j = 0 ; j < iregVec.count() ; j++)
         {
             RegStructure* preg = iregVec.at(j) ;
             RegStructure* pnewReg = new RegStructure ;
             QVector<RegStructure*> iregVec ;
             QMap<QString ,QVector<RegStructure*> > iclockRegMap ;

             memcpy((char*)pnewReg ,(char*)preg ,sizeof(struct RegStructure));

             QString iregWidth = QString::fromAscii(preg->m_pExpNoMacroString);
             QString iregNum = QString::fromAscii(preg->m_pregNumNoMacroString) ;
             // 替换所有的 parameter
             iparamIter = m_iparameter.constBegin() ;
             while(iparamIter != m_iparameter.constEnd())
             {
                 if(iregWidth.contains(iparamIter.key()))
                 {
                     if(idefParamMap.value(iparamIter.key(),QString()).isEmpty())
                     {
                         // 用 paramete 替换
                         iregWidth.replace(iparamIter.key() , iparamIter.value());
                     }
                     else
                     {
                         // 用 defparam 替换
                         iregWidth.replace(iparamIter.key() , idefParamMap.value(iparamIter.key()));
                     }

                     // 排出 parameter 引入 define 导致 交替引用
                     while(-1 != imacroStr.indexIn(iregWidth))
                     {
                         QString icapMacroStr = imacroStr.cap(1) ;
                         iregWidth = iregWidth.replace(imacroPrefix+icapMacroStr,imacroMap.value(icapMacroStr));
                         isParamInvolveMacro = true ;
                     }

                     if(isParamInvolveMacro)
                     {
                        // 重新扫描 是否含有 parameter
                        iparamIter = m_iparameter.constBegin() ;
                        isParamInvolveMacro = false ;
                        continue ;
                     }
                 }
                 ++iparamIter ;
             }

             if(!iregWidth.compare("1"))
             {
                 nbitWidth = 1 ;
                 nFirstBit = 0 ;
                 nSecondBit = 0 ;
             }
             else
             {
                 getBitRange(iregWidth,&nFirstBit,&nSecondBit) ;
                 nbitWidth = qAbs(nFirstBit - nSecondBit) + 1 ;
             }


             // copy to new reg pointer
             pnewReg->m_unStartBit = nFirstBit ;
             pnewReg->m_unEndBit = nSecondBit ;
             pnewReg->m_unRegBitWidth = nbitWidth ;
             pnewReg->m_unMaxBitWidth = 0 ;
             pnewReg->m_eRegNumType = attributeOther ;

             if(nFirstBit > nSecondBit)
             {
                pnewReg->m_eRegBitWidthEndian = endianBig ;
             }
             else if(nFirstBit < nSecondBit)
             {
                 pnewReg->m_eRegBitWidthEndian = endianLittle ;
             }
             else
             {
                 if(nbitWidth == 1)
                 {
                     pnewReg->m_eRegBitWidthEndian = endianBig ;
                 }
                 else
                 {
                     pnewReg->m_eRegBitWidthEndian = endianOther ;
                 }
             }

             iparamIter = m_iparameter.constBegin() ;
             while(iparamIter != m_iparameter.constEnd())
             {
                 if(iregNum.contains(iparamIter.key()))
                 {
                     if(idefParamMap.value(iparamIter.key(),QString()).isEmpty())
                     {
                         // 用 paramete 替换
                         iregNum.replace(iparamIter.key() , iparamIter.value());
                     }
                     else
                     {
                         // 用 defparam 替换
                         iregNum.replace(iparamIter.key() , idefParamMap.value(iparamIter.key()));
                     }

                     // 排出 parameter 引入 define 导致 交替引用
                     while(-1 != imacroStr.indexIn(iregNum))
                     {
                         QString icapMacroStr = imacroStr.cap(1) ;
                         iregNum = iregNum.replace(imacroPrefix + icapMacroStr ,imacroMap.value(icapMacroStr));
                         isParamInvolveMacro = true ;
                     }

                     if(isParamInvolveMacro)
                     {
                        // 重新扫描 是否含有 parameter
                        iparamIter = m_iparameter.constBegin() ;
                        isParamInvolveMacro = false ;
                        continue ;
                     }
                 }
                 ++iparamIter ;
             }


             if(!iregNum.compare("1"))
             {
                 nregNum = 1 ;
                 nregNumFirstBit = 0 ;
                 nregNumSecondBit = 0 ;
             }
             else
             {
                 if(iregNum.count(":") == 1)
                 {
                     // 计算　regnum
                     getBitRange(iregNum,&nregNumFirstBit,&nregNumSecondBit);
                     nregNum = qAbs(nregNumFirstBit - nregNumSecondBit) + 1 ;
                 }
                 else
                 {
                     nregNumFirstBit = 0 ;
                     nregNumSecondBit = 0 ;
                     nregNum = 0 ;
                 }
             }

             pnewReg->m_unStartNum = nregNumFirstBit ;
             pnewReg->m_unEndNum = nregNumSecondBit ;
             pnewReg->m_unRegNum = nregNum ;
             pnewReg->m_unMaxRegNum = 0 ;
             pnewReg->m_eRegBitWidthType = attributeOther ;


             if(nregNumFirstBit > nregNumSecondBit)
             {
                pnewReg->m_eRegNumEndian = endianBig ;
             }
             else if(nregNumFirstBit < nregNumSecondBit)
             {
                pnewReg->m_eRegNumEndian = endianLittle ;
             }
             else
             {
                 if(nregNum == 1)
                 {
                    pnewReg->m_eRegNumEndian = endianBig ;
                 }
                 else
                 {
                    pnewReg->m_eRegNumEndian = endianOther ;
                 }
             }

             // add to instance reg map
             iclockRegMap = m_iinstanceRegMap.value(instancename , iclockRegMap) ;
             iregVec = iclockRegMap.value(QString::fromAscii(pnewReg->m_pclockName),iregVec);
             iregVec.append(pnewReg);
             iclockRegMap.insert(QString::fromAscii(pnewReg->m_pclockName),iregVec);
             m_iinstanceRegMap.insert(instancename,iclockRegMap);
         }
         ++i ;
     }
 }

EziDebugModule::RegStructure* EziDebugModule::getInstanceReg(QString instancename , QString clock , QString regname)
{
    int nRegCount = 0 ;
    QMap<QString ,QVector<RegStructure*> > iregMap ;
    QVector<RegStructure*> iregVec ;
    iregMap = m_iinstanceRegMap.value(instancename,iregMap) ;
    iregVec = iregMap.value(clock,iregVec);
    for(;nRegCount < iregVec.count();nRegCount++)
    {
        RegStructure* preg = iregVec.at(nRegCount) ;
        if(regname == QString::fromAscii(preg->m_pRegName))
        {
            return  preg ;
        }
    }

    return NULL ;
}


void  EziDebugModule::getBitRange(const QString &widthStr , int *startbit , int *endbit)
{
    char icalRegWidth[64] = {0}  ;
    QString istartBit = widthStr.split(":").at(0) ;
    QString iendBit = widthStr.split(":").at(1) ;


    // 分别截取 高位 与  低位 bit 算出位宽 注: 暂不支持 ?: 操作符
    if(widthStr.split(":").size() > 2)
    {
        qDebug() << "EziDebug Error: the ? : operator is not sopported or encounter error!";
        *startbit = 0 ;
        *endbit = 0 ;
        return ;
    }

    if((istartBit.size() >= 64)||(iendBit.size() >= 64))
    {
        qDebug() << "EziDebug Error: the reg width string is too long !";
        *startbit = 0 ;
        *endbit = 0 ;
        return ;
    }

    qstrcpy(icalRegWidth ,istartBit.toAscii().constData());
    reg_scan iregCal ;
    iregCal.prog = icalRegWidth ;
    iregCal.EvalExp(*startbit);

    memset(icalRegWidth,0,64);
    qstrcpy(icalRegWidth ,iendBit.toAscii().constData());
    iregCal.prog = icalRegWidth ;
    iregCal.EvalExp(*endbit);

}

int EziDebugModule::constructChainRegMap(EziDebugPrj * prj ,const QStringList &cominstanceList,QString instancename)
{
    int ninstanceCount = 0 ;
    QStringList ichainInstanceList  ;
    int nmaxRegNum = prj->getMaxRegNumPerChain() ;
    QMap<QString ,QVector<RegStructure*> >iinstanceRegVecMap  ;

    // 获取本module在扫描链中所有的例化
    for(;ninstanceCount < cominstanceList.count();ninstanceCount++)
    {
        QString icomStr = cominstanceList.at(ninstanceCount) ;
        QRegExp imoduleExp(m_imoduleName + QObject::tr(":\\w+")) ;
        imoduleExp.exactMatch(icomStr) ;
        ichainInstanceList.append(icomStr.split(":").at(1));
    }

    QStringList iinstanceList = ichainInstanceList.filter(instancename) ;
    if(!iinstanceList.count())
    {
        qDebug() << "EziDebug Error: instance name list is wrong , please check the code!";
        return 1 ;
    }
    else
    {
        iinstanceRegVecMap = m_iinstanceRegMap.value(instancename ,iinstanceRegVecMap) ;
        QMap<QString,QVector<RegStructure*> > ibakRegMap =   m_iregMap ;
        QMap<QString,QVector<RegStructure*> >::const_iterator iregMapIter = m_iregMap.constBegin() ;
        while(iregMapIter != m_iregMap.constEnd())
        {
            int nRegCount = 0 ;
            QString iclock = iregMapIter.key() ;
            QVector<RegStructure*> ioriginRegVec = iregMapIter.value() ;
            QVector<RegStructure*> iinstanceRegVec = iinstanceRegVecMap.value(iclock) ;

            if(!iinstanceRegVec.count())
            {
                qDebug() << "EziDebug Error: The instanceReg is not exist!";
                return 1 ;
            }

            nRegCount = 0 ;

            for(;nRegCount < ioriginRegVec.count(); nRegCount++)
            {
                RegStructure* poriginReg = ioriginRegVec.at(nRegCount) ;
                RegStructure* pinstanceReg = iinstanceRegVec.at(nRegCount) ;

                if((poriginReg->m_eRegNumType == attributeOther)&&(poriginReg->m_eRegBitWidthType == attributeOther))
                {                    
                    poriginReg->m_unStartNum  =  pinstanceReg->m_unStartNum  ;
                    poriginReg->m_unEndNum  =  pinstanceReg->m_unEndNum  ;
                    poriginReg->m_unRegNum  =  pinstanceReg->m_unRegNum  ;
                    poriginReg->m_unStartBit  =  pinstanceReg->m_unStartBit  ;
                    poriginReg->m_unEndBit  =  pinstanceReg->m_unEndBit  ;
                    poriginReg->m_unRegBitWidth  =  pinstanceReg->m_unRegBitWidth  ;
                    poriginReg->m_eRegNumEndian  =  pinstanceReg->m_eRegNumEndian  ;
                    poriginReg->m_eRegBitWidthEndian  =  pinstanceReg->m_eRegBitWidthEndian  ;

                    poriginReg->m_unMaxBitWidth = (pinstanceReg->m_unRegBitWidth)*(pinstanceReg->m_unRegNum) ;
                    poriginReg->m_unMaxRegNum = pinstanceReg->m_unRegNum ;
                    poriginReg->m_eRegNumType = attributeStatic ;
                    poriginReg->m_eRegBitWidthType = attributeStatic ;
                }
                else
                {
                    if((poriginReg->m_unStartBit != pinstanceReg->m_unStartBit)\
                            ||(poriginReg->m_unEndBit != pinstanceReg->m_unEndBit))
                    {
                        poriginReg->m_eRegBitWidthType = attributeDynamic ;
                    }

                    if((poriginReg->m_unStartNum != pinstanceReg->m_unStartNum)\
                            ||(poriginReg->m_unEndNum != pinstanceReg->m_unEndNum))
                    {
                        poriginReg->m_eRegNumType = attributeDynamic ;
                        qDebug() << "The reg number is variable!";
                        m_iregMap = ibakRegMap ;
                        return 3 ;
                    }


                    if((poriginReg->m_eRegNumEndian != pinstanceReg->m_eRegNumEndian)\
                            ||(poriginReg->m_eRegBitWidthEndian != pinstanceReg->m_eRegBitWidthEndian))
                    {
                        qDebug() << "The reg number endian or bitwidth endian is variable!";
                        m_iregMap = ibakRegMap ;
                        return 2 ;
                    }

                    // 变化位宽的 最大寄存器个数  以及 最大位宽  检测
                    if(poriginReg->m_eRegBitWidthType == attributeDynamic)
                    {
                        int ninstanceWidth = pinstanceReg->m_unRegNum * pinstanceReg->m_unRegBitWidth ;
                        if(ninstanceWidth > nmaxRegNum)
                        {
                            qDebug() << "The reg bitwidth sum is exceed the max regnum in the chain!";
                            m_iregMap = ibakRegMap ;
                            return 1 ;
                        }
                        else
                        {
                            if(ninstanceWidth > poriginReg->m_unMaxBitWidth)
                            {
                                poriginReg->m_unMaxBitWidth = ninstanceWidth ;
                            }
                        }
                    }
                }

            }
            ++iregMapIter ;
        }
    }

}

