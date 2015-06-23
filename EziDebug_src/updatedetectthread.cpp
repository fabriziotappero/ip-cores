#include "updatedetectthread.h"
#include "QWaitCondition"
#include "ezidebugvlgfile.h"
#include <algorithm>
#include <QDebug>
#include <QTimer>
#include <algorithm>



UpdateDetectThread::UpdateDetectThread(EziDebugPrj *prj,QObject *parent):QThread(parent),m_pprj(prj)
{

}

//UpdateDetectThread::~UpdateDetectThread()
//{
//    // 怎么搞 ?
//}

void UpdateDetectThread::run()
{
    m_ptimer = new QTimer ;
    connect(m_ptimer, SIGNAL(timeout()), this, SLOT(update()),Qt::DirectConnection);

    //,Qt::DirectConnection
    m_ptimer->start(1000*5);
    qDebug() << "Start Timer!" << QThread::currentThreadId();
    exec();
    qDebug() << "Stop Timer!";
    m_ptimer->stop();
    delete m_ptimer ;
}

//void UpdateDetectThread::codeFileChanged()
//{
//    return ;
//}


void UpdateDetectThread::update()
{

    QStringList ifileList ;
    bool eneedUpdatedFlag = 0 ;


    qDebug() << "!!!!!!!!!!!!!Attention: New Thread!!!!!!!!!!!!" << QThread::currentThreadId();

    /*这时候使用 全局唯一的 prj 对象指针时，要注意工程发生变化时 prj 也随着变化*/
    if(EziDebugPrj::ToolQuartus == m_pprj->m_eusedTool)
    {
        m_pprj->parseQuartusPrjFile(ifileList);
    }
    else if(EziDebugPrj::ToolIse == m_pprj->m_eusedTool)
    {
        m_pprj->parseIsePrjFile(ifileList);
    }
    else
    {
        qDebug() << "EziDebug is not support this sortware project file parse!";
    }

    ifileList.sort();

    m_pprj->m_iupdateAddedFileList.clear();
    m_pprj->m_iupdateDeletedFileList.clear();
    m_pprj->m_iupdateChangedFileList.clear();

    m_pprj->compareFileList(ifileList , m_pprj->m_iupdateAddedFileList , m_pprj->m_iupdateDeletedFileList , m_pprj->m_iupdateChangedFileList);


    if(!(m_pprj->m_iupdateDeletedFileList.isEmpty() \
         && m_pprj->m_iupdateAddedFileList.isEmpty() \
         && m_pprj->m_iupdateChangedFileList.isEmpty()))

    {
        eneedUpdatedFlag = true ;
    }


#if 0
    QStringList::Iterator ifirstBeginIterator = ifileList.begin() ;
    QStringList::Iterator ifirstEndIterator = ifileList.end() ;

    QStringList::Iterator iSecondBeginIterator = m_pprj->m_iCodefileNameList.begin() ;
    QStringList::Iterator iSecondEndIterator = m_pprj->m_iCodefileNameList.end() ;

    /*删除的file*/
    qDebug() << "!!!!!!!!!!!!!Attention: New Thread First!!!!!!!!!!!!" ;
    std::set_difference(ifirstBeginIterator,ifirstEndIterator,iSecondBeginIterator,iSecondEndIterator,ioutDelIterator);

    m_pprj->m_iupdateDeletedFileList = QList<QString>::fromStdList(ideletedFileList);
    m_pprj->m_iupdateDeletedFileList = m_pprj->m_iupdateDeletedFileList.filter(QRegExp(QObject::tr(".+"))) ;


//        ioutDelIterator = ideletedFileList.begin() ;
//        while(ioutDelIterator != ideletedFileList.end())
//        {
//           m_pprj->m_iupdateDeletedFileList << *ioutDelIterator ;
//           ++ioutDelIterator ;
//        }



    //m_pprj->m_iupdateDeletedFileList = QList<QString>::fromStdList(ideletedFileList);


   // m_pprj->m_iupdateDeletedFileList = QList::fromStdList(ideletedFileList) ;


    qDebug() << "!!!!!!!!!!!!!Attention: New Thread Second!!!!!!!!!!!!" ;


    //ioutBeginIterator = iaddedFileList.begin() ;
    /*新增的file*/
    std::set_difference(iSecondBeginIterator,iSecondEndIterator,ifirstBeginIterator,ifirstEndIterator,ioutAddIterator);
    m_pprj->m_iupdateAddedFileList = QList<QString>::fromStdList(iaddedFileList);
    m_pprj->m_iupdateAddedFileList = m_pprj->m_iupdateAddedFileList.filter(QRegExp(QObject::tr(".+"))) ;
    if(!m_pprj->m_iupdateAddedFileList.isEmpty())
    {
        eneedUpdatedFlag = true ;
    }

    //        ioutAddIterator = iaddedFileList.begin() ;
    //        while(ioutAddIterator != iaddedFileList.end())
    //        {
    //           m_pprj->m_iupdateAddedFileList << *ioutAddIterator ;
    //           ++ioutAddIterator ;
    //        }


    //m_pprj->m_iupdateAddedFileList = QList<QString>::fromStdList(iaddedFileList);


    /*共同的file*/
    qDebug() << "!!!!!!!!!!!!!Attention: New Thread Third!!!!!!!!!!!!" ;

    //ioutBeginIterator = iidenticalFileList.begin() ;

    std::set_intersection(ifirstBeginIterator,ifirstEndIterator,iSecondBeginIterator,iSecondEndIterator,ioutIdenticalIterator);

    ioutIdenticalIterator = iidenticalFileList.begin() ;
    while(ioutIdenticalIterator != iidenticalFileList.end())
    {
        QFileInfo itempFileInfo(m_pprj->m_iprjPath.path(),*ioutIdenticalIterator);
        QDateTime idateTime = itempFileInfo.lastModified() ;
        if((*ioutIdenticalIterator).endsWith(".v"))
        {
            if(idateTime != m_pprj->m_ivlgFileMap.value(*ioutIdenticalIterator)->m_iUpdateTime)
            {
                m_pprj->m_iupdateChangedFileList.append(*ioutIdenticalIterator);
            }
        }
        else if((*ioutIdenticalIterator).endsWith(".vhd"))
        {
            if(idateTime != m_pprj->m_ivlgFileMap.value(*ioutIdenticalIterator)->m_iUpdateTime)
            {
                m_pprj->m_iupdateChangedFileList.append(*ioutIdenticalIterator);
            }
        }
        else
        {

        }

       ++ioutIdenticalIterator ;
    }


    //m_pprj->m_iupdateChangedFileList = QList<QString>::fromStdList(iidenticalFileList) ;

    if(!m_pprj->m_iupdateChangedFileList.isEmpty())
    {
        eneedUpdatedFlag = true ;
    }
#endif

    if(eneedUpdatedFlag)
    {
        emit codeFileChanged();
    }
}
