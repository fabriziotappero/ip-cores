#include <QtGui>

#include "toolwindow.h"
#include "treeview.h"
#include "treeitem.h"
//#include "ezidebugprj.h"
#include "ezidebugmodule.h"
#include "updatedetectthread.h"
#include "ezidebuginstancetreeitem.h"
#include "ezidebugtreemodel.h"
#include "ezidebugscanchain.h"


#include<QDebug>

ListWindow::ListWindow(QWidget *parent, Qt::WindowFlags f) :
    QWidget(parent, f)
{
    QStringList ifileList ;
    QTextCodec::setCodecForTr(QTextCodec::codecForName("gb18030"));
    setMouseTracking(true);
    getToolWindowPointer(parent);

    findDialog = 0;
    moduleTreeView = NULL ;
    m_peziDebugTreeModel = NULL ;
    eDirection = eNone ;
    isLeftButtonPress = false ;

    //创建菜单栏和按钮
    //createButtons();
//    createActions();
//    createMenus();
    //    QPalette palette;
    //    palette.setBrush(QColor(255,255,255));
    //    menuBar->setPalette(palette);
    //    menuBar->setWindowOpacity(0);

    //创建标题栏
    titleBar = new TitleBar(this);

    connect(titleBar->closeButton, SIGNAL(clicked()), this, SLOT(close()));
    //创建工具栏
    //QToolBar toolBar = new ToolBar(this);
    //创建内容区域
    //QPushButton *btn = new QPushButton(this);
    //btn->setText(tr("cancel"));
    //QWidget *contentWidget = new QWidget(this);
    //分栏
//    closeButton = new Button(tr(":/images/ListWindowExit.bmp"), this);
//    //closeButton = new Button ;
//    closeButton->setIconSize(QSize(11, 10));
//   // closeButton->setGeometry(QRect(this->geometry().left()-20, 7, 11, 10));
//    closeButton->setGeometry(QRect(this->geometry().width()-20, 7, 11, 10));
//    qDebug()<< this->geometry().width()<<geometry().height();
//    connect(closeButton, SIGNAL(clicked()), this, SLOT(close()));
//    button1 = new QPushButton(tr("hello"),this);
//    button1->setGeometry(QRect(10,7, 11, 10));
//    connect(button1, SIGNAL(clicked()), this, SLOT(close()));
    m_pmessageTreeView = new TreeView(this) ;


    m_iShowMessageModel = new QStandardItemModel(0,2,this);


    m_iShowMessageModel->setHeaderData(0, Qt::Horizontal, QObject::tr("Type"));
    m_iShowMessageModel->setHeaderData(1, Qt::Horizontal, QObject::tr("Message"));


    moduleTreeView = new TreeView(this);

    moduleTreeView->setWindowTitle(QObject::tr("Simple Tree Model"));
    m_pcontextMenu = new QMenu(moduleTreeView);

	#if 0
    m_paddChainAct = m_pcontextMenu->addAction(QIcon(":/images/insert.png"),tr("添加链"));
    m_pdeleteChainAct = m_pcontextMenu->addAction(QIcon(":/images/delete.png"),tr("删除链"));
	#else
	m_paddChainAct = m_pcontextMenu->addAction(QIcon(":/images/insert.png"),tr("insert scanchain"));
    m_pdeleteChainAct = m_pcontextMenu->addAction(QIcon(":/images/delete.png"),tr("delete scanchain"));
	#endif
	
    connect(m_paddChainAct,SIGNAL(triggered()), toolWindow, SLOT(addScanChain()));
    connect(m_pdeleteChainAct,SIGNAL(triggered()),toolWindow, SLOT(deleteScanChain()));

    moduleTreeView->setModel(NULL);
    m_pmessageTreeView->setModel(m_iShowMessageModel);

    mainSplitter = new Splitter(Qt::Horizontal, this);


    mainSplitter->addWidget(moduleTreeView);
    mainSplitter->addWidget(m_pmessageTreeView);


    moduleTreeView->setContextMenuPolicy(Qt::CustomContextMenu);
    connect(moduleTreeView, SIGNAL(customContextMenuRequested(const QPoint&)),
            this, SLOT(show_contextmenu(const QPoint&)));
    moduleTreeView->show();

    addMessage("welcome","####Welcome to EziDebug####");

    /* 根据工程 文件是否创建 来是否显示 树状结构图*/
    // 在 toolwindow 的 构造 时 检测是否存在 默认路径 ，如果存在有效的默认路径，则会根据该路径1个工程对象
    // 构造完 toolwindow 后 接着 构造 listwindow ，如果 listwidow 检查 toolwindow 下的
    // 工程对象指针来 判断 是否 需要 重现 树状结构 ，如果 工程对象指针 不为空的话 ，

    // 1 、根据工程对象指针 来判断 是否存在 log 文件、以及工程文件
    // 如果没有的话 不在窗口构造的时候 构造树形结构，在旁边的 文本栏 提示错误信息：默认路径 不存在有效数据
    // 2 、从log 文件恢复 所有数据，恢复时 检测 log 文件 是否 ok，如果有错误，则在 文本栏提示 错误信息 log 文件被破坏
    //
    // 当构造函数完成最后，开启 进程信息，并开启定时器，定时器定时 从工程文件中提取所有的 代码文件信息，与目前工程文件中保存的
    // 所有文件信息进行对比，检查 代码文件是否 被更新，如果更新 则将 部分更新按钮 有效
    //
    // 部分更新按钮初始化后不可用，待线程启用后，检测到文件可更新时，再可用
    ToolWindow * pparent = static_cast<ToolWindow*>(toolWindow) ;
    EziDebugPrj* prj ;
    if(prj = const_cast<EziDebugPrj*>(pparent->getCurrentProject()))
    {
        /*检查所需工程文件是否存在 0:存在 1:不存在*/

        if(!prj->isPrjFileExist())
        {
            addMessage("error",tr("EziDebug error: There is no Project file in the default path:%1").arg(prj->getCurrentDir().absolutePath()));
            delete prj ;
            pparent->setCurrentProject(NULL);
        }
        else
        {
            // 检测log文件是否存在
            if(prj->getCurrentDir().exists("config.ezi"))
            {
                prj->setLogFileExistFlag(true);

                prj->setLogFileName(prj->getCurrentDir().absoluteFilePath("config.ezi")) ;

                /*检查保存的log文件是否ok 并恢复log文件中的扫描链信息，用于检测要扫描的工程是否被修改导致扫描链被破坏,提取所有信息*/
                if(prj->detectLogFile(READ_MODULE_INFO|READ_FILE_INFO|READ_CHAIN_INFO))
                {
                   // do nothing until the toolwindow show!!
                   // listwindow will show infomation after toolwindow show!
                }
                else
                {
                    prj->clearupCheckedChainList();
                    prj->clearupDestroyedChainList();
                    //  对所有改动过的文件(文件时间不一致、文件增、删)进行扫描
                    if(EziDebugPrj::ToolQuartus == prj->getToolType())
                    {
                        prj->parseQuartusPrjFile(ifileList);
                    }
                    else if(EziDebugPrj::ToolIse == prj->getToolType())
                    {
                        prj->parseIsePrjFile(ifileList);
                    }
                    else
                    {
                        addMessage("error","EziDebug error: EziDebug is not support this kind project file parse!");
                        delete prj ;
                        pparent->setCurrentProject(NULL);
                    }

                    QStringList iaddFileList ;
                    QStringList idelFileList ;
                    QStringList ichgFileList ;

                    QList<EziDebugPrj::LOG_FILE_INFO*> iaddedinfoList ;
                    QList<EziDebugPrj::LOG_FILE_INFO*> ideletedinfoList ;

                    ifileList.sort();

                    prj->compareFileList(ifileList,iaddFileList,idelFileList,ichgFileList);

                    if(prj->updatePrjAllFile(iaddFileList,idelFileList,ichgFileList,iaddedinfoList,ideletedinfoList,false))
                    {
                        delete prj ;
                        pparent->setCurrentProject(NULL);
                        qDeleteAll(iaddedinfoList);
                        qDeleteAll(ideletedinfoList);
                    }
                    else
                    {
                        // store to macro
                        prj->addToMacroMap();

                        QString itopModule = prj->getTopModule() ;

                        QString itopModuleComboName = itopModule + QObject::tr(":")+ itopModule ;
                        EziDebugInstanceTreeItem* pnewHeadItem = new EziDebugInstanceTreeItem(itopModule,itopModule);
                        if(!pnewHeadItem)
                        {
                            addMessage("error","EziDebug error: There is no memory left!");
                            delete prj ;
                            pparent->setCurrentProject(NULL);
                        }
                        else
                        {
                            if(!itopModule.isEmpty())
                            {
                                if(prj->getScanChainInfo().count())
                                {
                                    // 通过备份 进行还原
                                    prj->backupChainMap();
                                    prj->cleanupBakChainTreeItemMap();
                                    prj->cleanupChainTreeItemMap();
                                }
                                // set the headitem
                                prj->setInstanceTreeHeadItem(pnewHeadItem) ;
                                if(prj->traverseModuleTree(itopModuleComboName,pnewHeadItem))
                                {
                                    qDebug() << tr("从log文件恢复失败") << __FILE__ << __LINE__ ;
                                    addMessage("error","EziDebug error: resume data failed from EziDebug config file!");

                                    prj->resumeChainMap();
                                    prj->updateOperation(EziDebugPrj::OperateTypeNone,NULL,NULL);
                                    delete pnewHeadItem ;
                                    delete prj ;
                                    pparent->setCurrentProject(NULL);
                                    qDeleteAll(iaddedinfoList);
                                    qDeleteAll(ideletedinfoList);
                                    //return ;
                                }
                                else
                                {

                                    if(prj->getBackupChainMap().count())
                                    {
                                        prj->resumeChainMap();
                                        prj->resumeChainTreeItemMap();
                                        // 用于清空 备份的 map
                                        prj->updateOperation(EziDebugPrj::OperateTypeNone,NULL,NULL);
                                    }


                                    EziDebugInstanceTreeItem::setProject(prj);

                                    if(prj->changedLogFile(iaddedinfoList,ideletedinfoList))
                                    {
                                        //提示 保存 log 文件出错
                                        addMessage("info","EziDebug info: changedLogFile encounter some problem!");
                                    }

                                    // 删除 新分配的  log_file_info 指针
                                    qDeleteAll(iaddedinfoList);
                                    qDeleteAll(ideletedinfoList);

                                    m_peziDebugTreeModel = new EziDebugTreeModel(pnewHeadItem,this);
                                    moduleTreeView->setModel(m_peziDebugTreeModel);

                                    // welcomeinfoinit(prj);
#if 0
                                    QStringList iunexistChainList = prj->checkChainExist();
                                    if(iunexistChainList.count())
                                    {
                                        addMessage("warning","EziDebug warning: Some chains lost partly or full  for some reasons!");
                                        for(int i = 0 ; i < iunexistChainList.count() ;i++)
                                        {
                                            addMessage("warning",tr("EziDebug chain:%1").arg(iunexistChainList.at(i)));
                                        }
                                    }

                                    if(prj->getDestroyedChainList().count())
                                    {
                                        // 把所有破坏掉的链打印出来

                                        QString ichain ;
                                        QStringList idestroyedChainList = prj->getDestroyedChainList() ;

                                        addMessage("warning","The destroyed chain are:");
                                        for(int i = 0 ; i < idestroyedChainList.count() ;i++)
                                        {
                                            QString ichainName = idestroyedChainList.at(i) ;

                                            EziDebugInstanceTreeItem *pitem = prj->getChainTreeItemMap().value(ichainName);
                                            if(pitem)
                                            {
                                                ichain.append(tr("EziDebug chain:   %1  topInstance:    %2:%3").arg(ichainName)\
                                                              .arg(pitem->getModuleName()).arg(pitem->getInstanceName())) ;
                                            }
                                            addMessage("warning",ichain);
                                        }

                                        // 扫描链被破坏 ,提示删除  部分扫描链被破坏  是否删除相关扫描链代码,否则相应扫描链不可用！
                                        QMessageBox::StandardButton rb = QMessageBox::question(this, tr("部分扫描链被破坏"), tr("相关扫描链不可用,是否删除相关扫描链代码?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
                                        if(rb == QMessageBox::Yes)
                                        {
                                            QStringList iunDelChainList = prj->deleteDestroyedChain() ;
                                            if(iunDelChainList.count())
                                            {
                                                addMessage("error","EziDebug error: Some chains do not be deleted for some reasons!");
                                                for(int i = 0 ; i < iunDelChainList.count() ;i++)
                                                {
                                                    addMessage("error",tr("EziDebug chain:%1").arg(iunDelChainList.at(i)));
                                                }
                                                addMessage("error","EziDebug error: Please check the code file is compiled successed!");
                                            }

                                            for(int i = 0 ; i < idestroyedChainList.count() ; i++)
                                            {
                                                QString idestroyedChain = idestroyedChainList.at(i) ;
                                                if(!iunDelChainList.contains(idestroyedChain))
                                                {
                                                    struct EziDebugPrj::LOG_FILE_INFO* pdelChainInfo = new EziDebugPrj::LOG_FILE_INFO ;
                                                    memcpy(pdelChainInfo->ainfoName,idestroyedChain.toAscii().data(),idestroyedChain.size()+1);
                                                    pdelChainInfo->pinfo = NULL ;
                                                    pdelChainInfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
                                                    ideletedinfoList << pdelChainInfo ;
                                                }

                                            }

                                        }

                                    }


#if 0
                                    if(prj->getScanChainInfo().count())
                                    {
                                        QMap<QString,EziDebugScanChain*>::const_iterator iaddedChainIter = prj->getScanChainInfo().constBegin() ;
                                        while(iaddedChainIter !=  prj->getScanChainInfo().constEnd())
                                        {
                                            QString ichainName = iaddedChainIter.key();
                                            struct EziDebugPrj::LOG_FILE_INFO* pinfo = new EziDebugPrj::LOG_FILE_INFO ;
                                            memcpy(pinfo->ainfoName ,ichainName.toAscii().data(),ichainName.size()+1);
                                            pinfo->pinfo = iaddedChainIter.value() ;
                                            pinfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
                                            iaddedinfoList << pinfo ;
                                            ++iaddedChainIter ;
                                        }
                                    }
#endif

                                    if(prj->changedLogFile(iaddedinfoList,ideletedinfoList))
                                    {
                                        //提示 保存 log 文件出错
                                        addMessage("info","EziDebug info: changedLogFile encounter some problem!");
                                    }


                                    // 删除 新分配的  log_file_info 指针

                                    qDeleteAll(iaddedinfoList);
                                    qDeleteAll(ideletedinfoList);

                                    QStandardItem * pitem = addMessage("info",tr("EziDebug info: The default project parameter:"));
                                    addMessage("process",tr("      Scanchain Max Reg Number: %1").arg(prj->getMaxRegNumPerChain()),pitem);
                                    addMessage("process",tr("      Project Path: %1").arg(prj->getCurrentDir().absolutePath()),pitem);
                                    addMessage("process",tr("      Compile Software: \"%1\"").arg((prj->getToolType() == EziDebugPrj::ToolQuartus) ? ("quartus") :("ise")),pitem);

                                    if(prj->getChainTreeItemMap().count())
                                    {
                                        QStandardItem * psecondItem = addMessage("info","      EziDebug info: The complete chain are:",pitem);
                                        QMap<QString,EziDebugInstanceTreeItem*> itreeItemMap = prj->getChainTreeItemMap() ;
                                        QMap<QString,EziDebugInstanceTreeItem*>::const_iterator i = itreeItemMap.constBegin() ;
                                        while( i!= itreeItemMap.constEnd())
                                        {
                                            EziDebugInstanceTreeItem* pitem = i.value();
                                            addMessage("process",tr("            EziDebug chain: %1\tInstance Node:%2").arg(i.key()).arg(pitem->getNameData()),psecondItem);
                                            EziDebugScanChain *pscanChain = pitem->getScanChainInfo();
                                            QString iclockNumStr ;
                                            QString itraversedInstStr ;
                                            QMap<QString,QVector<QStringList> > iregChain = pscanChain->getRegChain();
                                            QMap<QString,QVector<QStringList> >::const_iterator iregChainIter = iregChain.constBegin() ;
                                            while( iregChainIter != iregChain.constEnd())
                                            {
                                                iclockNumStr.append(tr("%1 (%2)     ").arg(pscanChain->getChainRegCount(iregChainIter.key())).arg(iregChainIter.key()));
                                                ++iregChainIter ;
                                            }

                                            addMessage("process" , tr("            The chain total reg number: %1").arg(iclockNumStr),psecondItem);
                                            addMessage("process" , tr("            The traversed NodeList:"),psecondItem);

                                            for(int j = 0 ; j < pscanChain->getInstanceItemList().count() ;j++)
                                            {
                                                itraversedInstStr.append(tr("  ->  ") + pscanChain->getInstanceItemList().at(j)) ;
                                                if((j+1)%3 == 0)
                                                {
                                                    addMessage("process" , tr("            ") + itraversedInstStr,psecondItem);
                                                    itraversedInstStr.clear();
                                                }
                                            }
                                            addMessage("process" , tr("            ") + itraversedInstStr,psecondItem);

                                            ++i ;
                                        }
                                    }


                                    UpdateDetectThread * pthread = prj->getThread() ;
                                    pthread->start();
#endif
                                }
                            }
                            else
                            {
                                addMessage("error","EziDebug error: There is no top module definition!");
                                delete pnewHeadItem ;
                                delete prj ;
                                pparent->setCurrentProject(NULL);
                            }
                        }
                    }
                }

            }
            else
            {
                /*向文本栏 传递错误信息 默认路径不存在log文件*/
                addMessage("warning","EziDebug warning: There is no EziDebug config File !");
                delete prj ;
                pparent->setCurrentProject(NULL);
            }
        }
    }
    else
    {
       addMessage("info",tr("EziDebug info: There is no default EziDebug project file!"));
       moduleTreeView->setModel(NULL);
    }

//    //创建状态栏
//    //m_pStatuBar = new StatuBar(this);

    //创建布局
    //QHBoxLayout *secondLayout = new QHBoxLayout(this);
    QVBoxLayout *mainLayout = new QVBoxLayout(this) ;
    //将部件加入到布局中
    mainLayout->addWidget(titleBar);
    //mainLayout->addWidget(closeButton);
    //secondLayout->addStretch(1);
    //secondLayout->addWidget(closeButton);
    //mainLayout->addLayout(secondLayout);
    mainLayout->addWidget(mainSplitter);

    //mainLayout->addWidget(m_pStatuBar);


//    mainSplitter->setStyleSheet("Splitter{margin-left:8px;margin-right:6px;margin-top:6px;margin-bottom:10px;}");
    mainSplitter->setStyleSheet("Splitter{margin-left:6px;margin-right:6px;margin-top:3px;margin-bottom:10px;}");
    //设置间距与边缘空白
    mainLayout->setSpacing(0);
    mainLayout->setContentsMargins(0,0,0,0);
//    mainLayout->setGeometry(QRect(this->geometry().left(),this->geometry().top(),100,100));
    setLayout(mainLayout);



    //设置列表窗口的背景
    setAutoFillBackground(true);
    //设置调色板
    listBackground.load(":/images/listBackground.bmp",//4.jpg",
                        0,Qt::AvoidDither|Qt::ThresholdDither|Qt::ThresholdAlphaDither);
    QPalette palette;
    palette.setBrush(QPalette::Background, QBrush(listBackground));//竖条纹背景对应这QBrush(listBackground.copy(0, 0, 850, 480))
//    palette.setBrush(QPalette::Window,
//                     QBrush(listBackground.scaled(size(), Qt::IgnoreAspectRatio,
//                                                  Qt::SmoothTransformation)));
    setPalette(palette);
//  setGeometry(QRect(toolWindow->frameGeometry().bottomLeft().rx(),
//                      toolWindow->frameGeometry().bottomLeft().ry(),
//                      290, 105));
    //setGeometry(QRect(100, 100, 290, 105));
    resize(listBackground.size());

    //isListWindowAdsorbedFlag = true;//初始状态下，ListWindow吸附在toolWindow下方

    //设置掩板
    //生成一张位图
    QBitmap objBitmap(size());
    //QPainter用于在位图上绘画
    QPainter painter(&objBitmap);
    //填充位图矩形框(用白色填充)
    painter.fillRect(rect(),Qt::white);
    painter.setBrush(QColor(0,0,0));
    //在位图上画圆角矩形(用黑色填充)
    painter.drawRoundedRect(this->rect(),4,4);
    //使用setmask过滤即可
    setMask(objBitmap);


    //设置为无边框
    //setWindowFlags(Qt::FramelessWindowHint);
    //设置窗口的最大尺寸（桌面）和最小尺寸（图片的尺寸）
    setMinimumSize(listBackground.size());
    setMaximumSize(qApp->desktop()->size());
    //setSizePolicy(QSizePolicy::Ignored, QSizePolicy::Ignored);
    isMaxWin = false;   //初始状态下不是最大化的窗口
    //isDrag = true ;
    isDrag = false ;
    isStick = false ;


    //放大，方便调试
//    resize(291,106);


    //设置普通模式下的按键
    //exitButton->setGeometry(QRect(273, 4, 11, 10));
    //menuBar->setGeometry(1, 18, 273, 18);//1, 18, 274, 34
    //titleBar->setGeometry(0,0,290,17);
    qDebug()<< this->hasMouseTracking();
}

ListWindow::~ListWindow()
{
    qDebug() << "Attention: Begin destruct listwindow object!";
    if(m_peziDebugTreeModel)
        delete m_peziDebugTreeModel ;

}

QStandardItem *ListWindow::addMessage(const QString &type ,const QString &message ,QStandardItem *parentitem)
{
    if(!m_iShowMessageModel)
    {
        return NULL ;
    }
    QStandardItem* pparentItem ;
    QStandardItem* piconItem ;
    QStandardItem* pstrItem ;
    QList<QStandardItem*> iitemList ;

    if(!parentitem)
    {
        pparentItem = m_iShowMessageModel->invisibleRootItem() ;
    }
    else
    {
        pparentItem = parentitem ;
    }

    if(type.toLower() == "warning")
    {
        QIcon iwarning(":/images/warning");
        piconItem = new QStandardItem(iwarning,"");
        pstrItem = new QStandardItem(message);
        //pstrItem->setForeground(QBrush(QColor(22,130,54)));
        pstrItem->setForeground(QBrush(QColor(21,255,21)));
        pstrItem->setFont(QFont("Times", 10 , QFont::Bold));
    }
    else if(type.toLower() == "info")
    {
        QIcon iinfo(":/images/info");
        piconItem = new QStandardItem(iinfo,"");
        pstrItem = new QStandardItem(message);
        pstrItem->setFont(QFont("Times", 10 , QFont::Black));
    }
    else if(type.toLower() == "error")
    {
        QIcon ierror(":/images/error");
        piconItem = new QStandardItem(ierror,"");
        pstrItem = new QStandardItem(message);
        pstrItem->setForeground(QBrush(QColor(255,0,0)));
        pstrItem->setFont(QFont("Times", 10 , QFont::Normal));
    }
    else if(type.toLower() == "process")
    {
        QIcon iok(":/images/ok");
        piconItem = new QStandardItem(iok,"");
        pstrItem = new QStandardItem(message);
        pstrItem->setForeground(QBrush(QColor(0,0,255)));
        pstrItem->setFont(QFont("Times", 10 , QFont::Normal));
    }
    else if(type.toLower() == "welcome")
    {
        QIcon iok1(":/images/ok_1");
        piconItem = new QStandardItem(iok1,"");
        pstrItem = new QStandardItem(message);
        pstrItem->setFont(QFont("Times", 10 , QFont::Bold));
    }
    else
    {
        QIcon iinfo(":/images/info");
        piconItem = new QStandardItem(iinfo,"");
        pstrItem = new QStandardItem(message);
        pstrItem->setFont(QFont("Times", 10 , QFont::Black));
    }

    iitemList << piconItem << pstrItem ;
    pparentItem->appendRow(iitemList);


    return  pparentItem->child((pparentItem->rowCount()-1),0) ;
}


//获取ToolWindow的指针，以获取其位置等信息
void ListWindow::getToolWindowPointer(QWidget *toolWin)
{
    toolWindow = toolWin;
}

void ListWindow::createButtons()
{

//    exitButton = createToolButton(tr("退出"),
//                                  QIcon(":/images/ListWindowExit.bmp"),
//                                  QSize(11, 10),
//                                  SLOT(close()));

}

void ListWindow::createActions()
{
    proSettingWizardAct = new QAction(tr("工程设置向导"), this);
    //normalAct->setShortcuts(QKeySequence::Quit);
    //normalAct->setStatusTip(tr("Exit the application"));
    connect(proSettingWizardAct, SIGNAL(triggered()), this, SLOT(proSetting()));

    setProPathAct = new QAction(tr("工程目录"), this);
    connect(setProPathAct, SIGNAL(triggered()), this, SLOT(proUpdate()));

    setRegNumACt = new QAction(tr("设置寄存器个数"), this);
    connect(setRegNumACt, SIGNAL(triggered()), this, SLOT(proUpdate()));

    useVerilogAct = new QAction(tr("使用verilog语言"), this);
    useVerilogAct->setCheckable(true);
    //useVerilogAct->setChecked(spreadsheet->showGrid());
    connect(useVerilogAct, SIGNAL(triggered()), this, SLOT(proUpdate()));

    useVHDLAct = new QAction(tr("使用VHDL语言"), this);
    useVHDLAct->setCheckable(true);
    //useVerilogAct->setChecked(spreadsheet->showGrid());
    connect(useVHDLAct, SIGNAL(triggered()), this, SLOT(proUpdate()));

    useMixeLanguagedAct = new QAction(tr("使用verilong和VHDL语言"), this);
    useMixeLanguagedAct->setCheckable(true);
    //useVerilogAct->setChecked(spreadsheet->showGrid());
    connect(useMixeLanguagedAct, SIGNAL(triggered()), this, SLOT(proUpdate()));

    setSlotAct = new QAction(tr("设置计时器的时钟"), this);
    connect(setSlotAct, SIGNAL(triggered()), this, SLOT(proUpdate()));

    useAlteraAct = new QAction(tr("使用Altera"), this);
    useAlteraAct->setCheckable(true);
    //useVerilogAct->setChecked(spreadsheet->showGrid());
    connect(useAlteraAct, SIGNAL(triggered()), this, SLOT(proUpdate()));

    useXilinxAct = new QAction(tr("使用Xilinx"), this);
    useXilinxAct->setCheckable(true);
    //useVerilogAct->setChecked(spreadsheet->showGrid());
    connect(useXilinxAct, SIGNAL(triggered()), this, SLOT(proUpdate()));

    exitAct = new QAction(tr("退出"), this);
    exitAct->setShortcuts(QKeySequence::Quit);
    //exitAct->setStatusTip(tr("退出"));
    connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));


    rankAfterFileNameAct = new QAction(tr("按文件名"), this);
    connect(rankAfterFileNameAct, SIGNAL(triggered()), this, SLOT(proUpdate()));

    rankAfterPathNameAct = new QAction(tr("按路径名"), this);
    connect(rankAfterPathNameAct, SIGNAL(triggered()), this, SLOT(proUpdate()));


    fastOrientAct = new QAction(tr("快速定位"), this);
    connect(fastOrientAct, SIGNAL(triggered()), this, SLOT(proUpdate()));

    findAct = new QAction(tr("查找"), this);
    //connect(findAct, SIGNAL(triggered()), this, SLOT());
    connect(findAct, SIGNAL(triggered()), this, SLOT(find()));

    findNextAct = new QAction(tr("查找下一个"), this);
    connect(findNextAct, SIGNAL(triggered()), this, SLOT(proUpdate()));


    aboutEziDebugAct = new QAction(tr("关于..."), this);
    connect(aboutEziDebugAct, SIGNAL(triggered()), this, SLOT(about()));

    helpFileAct = new QAction(tr("帮助"), this);
    connect(helpFileAct, SIGNAL(triggered()), this, SLOT(proUpdate()));
}

void ListWindow::createMenus()
{
    menuBar = new MenuBar(this);

    addMenu = menuBar->addMenu(tr("添加"));
    addMenu->addAction(proSettingWizardAct);
    addMenu->addAction(setProPathAct);
    addMenu->addAction(setRegNumACt);
    addMenu->addSeparator();
    addMenu->addAction(useVerilogAct);
    addMenu->addAction(useVHDLAct);
    addMenu->addAction(useMixeLanguagedAct);
    addMenu->addSeparator();
    addMenu->addAction(setSlotAct);
    addMenu->addSeparator();
    addMenu->addAction(useAlteraAct);
    addMenu->addAction(useXilinxAct);
    addMenu->addSeparator();
    addMenu->addAction(exitAct);

    checkMenu = menuBar->addMenu(tr("查看"));

    sortMenu = menuBar->addMenu(tr("排序"));
    sortMenu->addAction(rankAfterFileNameAct);
    sortMenu->addAction(rankAfterPathNameAct);

    findMenu = menuBar->addMenu(tr("查找"));
    findMenu->addAction(fastOrientAct);
    findMenu->addSeparator();
    findMenu->addAction(findAct);
    findMenu->addAction(findNextAct);

    helpMenu = menuBar->addMenu(tr("帮助"));
    helpMenu->addAction(aboutEziDebugAct);
    helpMenu->addAction(helpFileAct);

//    //获取图像
//    QPixmap objPixmap(tr(":/images/listWindowMenubar.bmp"));
//    //得到图像宽和高
//    int nPixWidth = objPixmap.width() / 5;
//    int nPixHeight = objPixmap.height();
//    addMenu->setIcon(QIcon(objPixmap.copy(nPixWidth*0,0,nPixWidth,nPixHeight)));
//    checkMenu->setIcon(QIcon(objPixmap.copy(nPixWidth*1,0,nPixWidth,nPixHeight)));
//    sortMenu->setIcon(QIcon(objPixmap.copy(nPixWidth*2,0,nPixWidth,nPixHeight)));
//    findMenu->setIcon(QIcon(objPixmap.copy(nPixWidth*3,0,nPixWidth,nPixHeight)));
//    helpMenu->setIcon(QIcon(objPixmap.copy(nPixWidth*4,0,nPixWidth,nPixHeight)));

//    addMenu->setContentsMargins(0,0,0,0);
//    //addMenu->setBaseSize(QSize(nPixWidth,nPixHeight));
//    //addMenu->setSizeIncrement(nPixWidth,nPixHeight);
//    addMenu->setFixedSize(nPixWidth,nPixHeight);


}

//void ListWindow::contextMenuEvent(QContextMenuEvent *event)
//{
//    QMenu menu(this);
//    menu.addAction(ListWindowmizeAct);
//    menu.addAction(normalAct);
//    menu.addAction(exitAct);
//    menu.exec(event->globalPos());
//}






//void ListWindow::mousePressEvent(QMouseEvent * event)
//{
//    if (event->button() == Qt::LeftButton) //点击左边鼠标
//    {
//        //globalPos()获取根窗口的相对路径，frameGeometry().topLeft()获取主窗口左上角的位置
//        dragPosition = event->globalPos() - frameGeometry().topLeft();
//        event->accept();   //鼠标事件被系统接收
//    }
//    //    if (event->button() == Qt::RightButton)
//    //    {
//    //         close();
//    //    }
//}

//void ListWindow::mouseMoveEvent(QMouseEvent * event)
//{
//    if (event->buttons() == Qt::LeftButton) //当满足鼠标左键被点击时。
//    {
//        move(event->globalPos() - dragPosition);//移动窗口
////        //如果ListWindow的上边沿和ToolWindow的下边沿靠近，则移至紧紧贴合的位置
////        int disY = toolWindow->geometry().bottom() - this->geometry().top();
////        if(disY < 5 || disY > -5){
////            move(this->geometry().left(), this->geometry().top() + disY);
////        }
//        event->accept();
//    }
//}

//void ListWindow::mouseReleaseEvent(QMouseEvent *event)
//{
////    if (event->buttons() == Qt::LeftButton) //当满足鼠标左键被点击时。
////    {

//        //如果ListWindow的上边沿和ToolWindow的下边沿靠近，则移至紧紧贴合的位置
//        int disY = toolWindow->geometry().bottom() - this->geometry().top();
//        if((disY < 15) && (disY > -15)){
//            move(this->geometry().left(), this->geometry().top() + disY);//移动窗口
//            toolWindow->setListWindowAdsorbedFlag(true);
//        }
//        else{
//            toolWindow->setListWindowAdsorbedFlag(false);
//        }

//        event->accept();
////    }
//}




//当鼠标移动到主界面内部周围5像素时，改变鼠标形状；当进行伸缩拖动时，根据拖动方向进行主界面的位置和大小设置即可。
//鼠标按下事件
void ListWindow::mousePressEvent(QMouseEvent *event)
{
//    static int i = 0 ;
//    qDebug()<<"mouse Press Event"<<i++ ;
    if (event->button() == Qt::LeftButton)
    {
        oldPointGlobal = pointPressGlobal = event->globalPos();
        isLeftButtonPress = true;

        oldWindowPoint = this->geometry().topLeft();

        mousePressPoint = event->pos();
        parentRect = parentWidget()->geometry();
        //isDrag = true ;
    }
    event->accept();
}

// 窗体拖动事件
void ListWindow::moveEvent(QMoveEvent *event)
{
//    static int i = 0 ;
//    qDebug()<<"moveEvent"<<i++ ;
//    QWidget * parent = this->parentWidget();
//    const int disMax = 30;
//    ToolWindow* parent_tool = static_cast<ToolWindow*>(parent);
//    parent_tool->setListWindowAdsorbedFlag(false);

//    int dis = parent_tool->geometry().bottom() - this->geometry().top();
//    if((dis < disMax) && (dis > -disMax)){
////        move(this->geometry().left(), parent->geometry().bottom());//移动窗口
////        move(200,300);
//        qDebug()<< parent_tool->geometry().left()<< parent_tool->geometry().right() \
//                   << parent_tool->geometry().top()<< parent_tool->geometry().bottom ();

//        qDebug()<< this->geometry().left()<< this->geometry().right() \
//                   << this->geometry().top()<< this->geometry().bottom ();

//        move(300,400);
//        qDebug()<<"move the widget to bottom of parent !";
//        parent_tool->setListWindowAdsorbedFlag(true);
//    }
//    dis = parent->geometry().top() - this->geometry().bottom();
//    if((dis < disMax) && (dis > -disMax)){
//        move(this->geometry().left(), this->geometry().top() + dis);//移动窗口
//        parent_tool->setListWindowAdsorbedFlag(true);
//    }
//    dis = parent->geometry().right() - this->geometry().left();
//    if((dis < disMax) && (dis > -disMax)){
//        move(parent->geometry().right(), this->geometry().top());//移动窗口
//        parent_tool->setListWindowAdsorbedFlag(true);
//    }
//    dis = parent->geometry().left() - this->geometry().right();
//    if((dis < disMax) && (dis > -disMax)){
//        move(this->geometry().left() + dis, this->geometry().top());//移动窗口
//        parent_tool->setListWindowAdsorbedFlag(true);
//    }
//    event->accept();
      event->ignore();

    //  event->accept();
     // QWidget::moveEvent(event);
      //event->accept();
}

//鼠标移动事件
void ListWindow::mouseMoveEvent(QMouseEvent *event)
{
    //qDebug()<<"ListWindow::mouseMoveEvent" ;
    // qDebug()<<"ListWindow::mouseMoveEvent"<<this->geometry().width()<<this->geometry().height()<<"mouse track!"<<event->x()<<event->y();
    if(!isLeftButtonPress)
    {
        eDirection = (enum_Direction)PointValid(event->x(),event->y());

        SetCursorStyle(eDirection);

    }
    else
    {
        int nXGlobal = event->globalX();
        int nYGlobal = event->globalY();
        NewPointGlobal = event->globalPos();
        SetDrayMove(nXGlobal,nYGlobal,eDirection);
        pointPressGlobal =QPoint(nXGlobal,nYGlobal);
        if(cursor().shape() == Qt::ArrowCursor)
        {
            mouseMovePoint = event->pos() ;
            diffPos = event->pos() - mousePressPoint;
            magneticMove(parentRect,geometry());
        }

    }
    event->accept();
}
//鼠标释放事件
void ListWindow::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
    {
        isLeftButtonPress = false;
        eDirection = eNone;
        //isDrag = false ;
    }
    event->accept();
}

//鼠标双击事件
void ListWindow::mouseDoubleClickEvent(QMouseEvent *event)
{
    //Null
//    qDebug()<< "list window"<<this->frameGeometry().left() << this->frameGeometry().top();
    if ((event->button() == Qt::LeftButton) && (event->y()<= 10))
        //if ((event->button() == Qt::LeftButton) && (event->y()<= titleBar->height()))
     {
        if(!isMaxWin)
        {
            rectRestoreWindow = geometry();
            setGeometry(qApp->desktop()->availableGeometry());
        }
        else
        {
            setGeometry(rectRestoreWindow);
        }
        isMaxWin = !isMaxWin;
    }
    event->accept();
}

void ListWindow::magneticMove(const QRect &bechmarkRect, const QRect &targetRect)
{
    int bechmarkLeft = bechmarkRect.left();
    int bechmarkRight = bechmarkRect.right();
    int bechmarkTop = bechmarkRect.top();
    int bechmarkBottom = bechmarkRect.bottom();
    int targetLeft = targetRect.left();
    int targetRight = targetRect.right();
    int targetTop = targetRect.top();
    int targetBottom = targetRect.bottom();
    QPoint finalPosition;
    const int magneticOffset = 12 ;

    isStick = false;
//    qDebug()<< "move widget"<<tr("上") <<targetTop <<tr("下") << targetBottom \
//            <<tr("左")<< targetLeft <<tr("右")<< targetRight ;

//    qDebug()<< "static widget"<<tr("上") <<bechmarkTop <<tr("下") << bechmarkBottom \
//            <<tr("左")<< bechmarkLeft <<tr("右")<< bechmarkRight ;

//    qDebug()<< "magneticMove" << mousePressPoint.x() << mousePressPoint.y() \
//            << mouseMovePoint.x()<< mouseMovePoint.y()<< this->parentWidget()->geometry().bottom()\
//               << this->parentWidget()->geometry().right();
    /*
    qDebug() << "bechmarkLeft - targetLeft:" << qAbs(bechmarkLeft - targetLeft);
    qDebug() << "pos().y():" << pos().y();
    qDebug() << "geometry().top():" << geometry().top();
    qDebug() << "bechmarkBottom:" << bechmarkBottom;
    qDebug() << "bechmarkTop - targetRect.height()):" << bechmarkTop - targetRect.height();
    */

    //if (qAbs(bechmarkLeft - targetLeft) < qAbs(bechmarkRight - targetLeft))
    //move(pos() + diffPos);
    // 移动窗口 的 pos()
    //horizontal-1:left to left
     //&& (pos().y() <= bechmarkBottom && pos().y() >= (bechmarkTop - targetRect.height()))
    if(qAbs(diffPos.x()) < magneticOffset \
       &&qAbs(bechmarkLeft - targetLeft) < magneticOffset
       && bechmarkRect.intersects(geometry()))
    {
        qDebug() << "Left To Left" << endl;
        //move(geometry().topLeft() + diffPos);
        //move(bechmarkLeft, pos().y() + diffPos.y());
        finalPosition.setX(bechmarkLeft);
        finalPosition.setY(pos().y() + diffPos.y());
        isStick |= true;
    }

    //horizontal-2:left to right
    if (qAbs(diffPos.x()) < magneticOffset
        && qAbs(bechmarkRight - targetLeft) < magneticOffset
        && bechmarkRect.intersects(QRect(pos().x() - magneticOffset, pos().y(),
                                     targetRect.width(), targetRect.height())))
    {
        qDebug() << "Left To Right" << endl;
        //move(bechmarkRight, pos().y() + diffPos.y());
        finalPosition.setX(bechmarkRight);
        finalPosition.setY(pos().y() + diffPos.y());
        isStick |= true;
    }

    //horizontal-3:right to left
    if (qAbs(diffPos.x()) < magneticOffset
    && qAbs(bechmarkLeft - targetRight) < magneticOffset
    && bechmarkRect.intersects(QRect(pos().x(), pos().y(),
                                     targetRect.width() + magneticOffset, targetRect.height())))
    {
        qDebug() << "Right TO Left" << endl;
        //move(pos().x() + (bechmarkLeft - targetRight),
        //    pos().y() + diffPos.y());
        finalPosition.setX(pos().x() + bechmarkLeft - targetRight);
        finalPosition.setY(pos().y() + diffPos.y());
        qDebug() << "finalPosition.x():" << finalPosition.x() << endl;
        qDebug() << "bechmarkLeft - targetRect.width():" << bechmarkLeft - targetRect.width();
        isStick |= true;
    }

    //horizontal-4:right to right
    if (qAbs(diffPos.x()) < magneticOffset
        && qAbs(bechmarkRight - targetRight) < magneticOffset
        //&& bechmarkRect.intersects(geometry())
        )
    {
        qDebug() << "Right TO Right" << endl;
        //move(pos().x() + (bechmarkRight - targetRight), pos().y() + diffPos.y());
        finalPosition.setX(pos().x() + (bechmarkRight - targetRight));
        //finalPosition.setX(targetLeft + (bechmarkRight - targetRight));
        finalPosition.setY(pos().y() + diffPos.y());
        isStick |= true;
    }

    //veritcal-1:top to top
    if (qAbs(diffPos.y()) < magneticOffset
        && qAbs(bechmarkTop - targetTop) < magneticOffset \
            && bechmarkRect.intersects(geometry())
        //&& (isStick || bechmarkRect.intersects(geometry()))
        )
    {
        qDebug() << "Top TO Top" << endl;

        if (isStick)
        finalPosition.setY(bechmarkTop);
        else
        {
            finalPosition.setX(pos().x() + diffPos.x());
            finalPosition.setY(bechmarkTop);
        }

        //move(pos().x() + diffPos.x(), bechmarkTop);
        isStick |= true;
    }

    //veritcal-2:top to bottom
    if (qAbs(diffPos.y()) < magneticOffset
        && qAbs(bechmarkBottom - targetTop) < magneticOffset
        && bechmarkRect.intersects(QRect(pos().x(), pos().y()- magneticOffset,
                                         targetRect.width(), targetRect.height())))
    {
        qDebug() << "Top To Bottom" << endl;
        //move(pos().x() + diffPos.x(), bechmarkBottom);
        if (isStick)
        {
            qDebug() << "case 1" ;
            finalPosition.setY(bechmarkBottom);
        }
        else
        {
//            finalPosition.setX(pos().x() + diffPos.x());
            finalPosition.setX(pos().x()+diffPos.x());
            finalPosition.setY(bechmarkBottom);
        }
        isStick |= true;
    }

    //veritcal-3:bottom to top
    if (qAbs(diffPos.y()) < magneticOffset
        && qAbs(bechmarkTop - targetBottom) < magneticOffset
        && bechmarkRect.intersects(QRect(pos().x(), pos().y(),
        targetRect.width(), targetRect.height() + magneticOffset)))
    {
        qDebug() << "Bottom TO Top" << endl;
        if (isStick)
        {
            qDebug() << "case 2";
            finalPosition.setY(pos().y() + (bechmarkTop - targetBottom));
        }
        else
        {
            finalPosition.setX(pos().x() + diffPos.x());
            finalPosition.setY(pos().y() + (bechmarkTop - targetBottom));
        }
        //move(pos().x() + diffPos.x(), pos().y() + (bechmarkTop - targetBottom));
        isStick |= true;
    }

    //veritcal-4:bottom to bottom
    if (qAbs(diffPos.y()) < magneticOffset
        && qAbs(bechmarkBottom - targetBottom) < magneticOffset
        && bechmarkRect.intersects(geometry()))
    {
        qDebug() << "Bottom TO Bottom" << endl;

        if (isStick)
            finalPosition.setY(pos().y() + (bechmarkBottom - targetBottom));
        else
        {
            finalPosition.setX(pos().x() + diffPos.x());
            finalPosition.setY(pos().y() + (bechmarkBottom - targetBottom));
        }
        //move(pos().x() + diffPos.x(), pos().y() + (bechmarkBottom - targetBottom));

        isStick |= true;
    }

    if (isStick)
    {
        qDebug()<< "finalPosition" << finalPosition.x()<< finalPosition.y() << isStick ;
        move(finalPosition);
    }
    else
    {

        qDebug()<<"!!!move the widget!!!" << diffPos.x()<< diffPos.y()\
               << (pos() + diffPos).x()<<(pos() + diffPos).y() << isStick;

        move(pos() + diffPos);
    }
//        move(oldWindowPoint+NewPointGlobal-oldPointGlobal);
//        i++ ;
////        move(700,10+i*10);
//        move(700+diffPos.x(),i*5+diffPos.y());
}

//判断鼠标所在位置在当前窗口的什么位置，上下左右 边界上，或者都不是
int ListWindow::PointValid(int x, int y)
{
    enum_Direction direction = eNone;

//    int top = geometry().top();
//    int bottom = geometry().bottom();
//    int left = geometry().left();
//    int right = geometry().right();
//    int width = this->width();
//    int height = this->height();

//    int ra = this->x();
//    int rb = this->y();

//    QRect rr = rect();
//    QRect rg = geometry();
//    QPoint q1 = geometry().topLeft();
//    QPoint q2 = geometry().bottomRight();

//    QSize rsize = this->size();


//    if ((x >= left) && (x < left + 5))
//    {
//        if((y >= top) && (y < top + 5))
//            direction = eLeftTop;
//        else if((y > bottom - 5) && (y <= bottom))
//            direction = eBottomLeft;
//        else
//            direction = eLeft;
//    }
//    else if((x > right - 5) && (x <= right))
//    {
//        if((y >= top) && (y < top + 5))
//            direction = eTopRight;
//        else if((y > bottom - 5) && (y <= bottom))
//            direction = eRightBottom;
//        else
//            direction = eLeft;
//    }
    // this is listwindow
    if ((x >= 0) && (x < 5))
    {
        if((y >= 0) && (y < 5))
            direction = eLeftTop;
        else if((y > this->height() - 5) && (y <= this->height()))
            direction = eBottomLeft;
        else
            direction = eLeft;
    }
    else if((x > this->width() - 5) && (x <= this->width()))
    {
        if((y >= 0) && (y < 5))
            direction = eTopRight;
        else if((y > this->height() - 5) && (y <= this->height()))
            direction = eRightBottom;
        else
            direction = eRight;
    }
    else if((y >= 0) && (y < 5))
    {
        direction = eTop;
    }
    else if((y > this->height() - 5) && (y <= this->height()))
    {
        direction = eBottom;
    }

    //qDebug() << "judget direction" << x << y << direction ;
    return (int)direction;
}

//设置鼠标样式
void ListWindow::SetCursorStyle(enum_Direction direction)
{
    //设置上下左右以及右上、右下、左上、坐下的鼠标形状
    //isDrag = false ;
    switch(direction)
    {
    case eTop:
    case eBottom:
        setCursor(Qt::SizeVerCursor);
        break;
    case eRight:
    case eLeft:
        setCursor(Qt::SizeHorCursor);
        break;
    case eTopRight:
    case eBottomLeft:
        setCursor(Qt::SizeBDiagCursor);
        break;
    case eRightBottom:
    case eLeftTop:
        setCursor(Qt::SizeFDiagCursor);
        break;
    default:
        {
            setCursor(Qt::ArrowCursor);
            //isDrag = true ;
        }
        break;
    }
}

//设置鼠标拖动的窗口位置信息
void ListWindow::SetDrayMove(int nXGlobal,int nYGlobal,enum_Direction direction)
{
//    //计算偏差
//    int ndX = nXGlobal - pointPressGlobal.x();
//    int ndY = nYGlobal - pointPressGlobal.y();
    //获得主窗口位置信息

    QRect rectWindow = geometry();
    qDebug()<< "direction" << direction << geometry().bottom()<<geometry().right();
    //判别方向
    switch(direction)
    {
    case eTop:
        rectWindow.setTop(nYGlobal);
        break;
    case eBottom:
        rectWindow.setBottom(nYGlobal);
        break;
    case eRight:
        rectWindow.setRight(nXGlobal);
        //titleBar->lineLabel->
                //resize(titleBar->lineLabel->size().width() + ndX,
                //                    titleBar->lineLabel->size().height());
        break;
    case eLeft:
        rectWindow.setLeft(nXGlobal);
        break;
    case eTopRight:
        rectWindow.setTop(nYGlobal);
        rectWindow.setRight(nXGlobal);
        break;
    case eBottomLeft:
        rectWindow.setBottom(nYGlobal);
        rectWindow.setLeft(nXGlobal);
        break;
    case eRightBottom:
        rectWindow.setBottom(nYGlobal);
        rectWindow.setRight(nXGlobal);
        break;
    case eLeftTop:
        rectWindow.setTop(nYGlobal);
        rectWindow.setLeft(nXGlobal);
         break;
    default:
        break;
    }

    qDebug()<< "new pos" << rectWindow.top()<< rectWindow.left()<<rectWindow.width()<< rectWindow.height() \
               <<nXGlobal << nYGlobal;
    if(rectWindow.width()< minimumWidth() || rectWindow.height()<minimumHeight())
    {
        qDebug()<< "the window size less than miniumWidth ";


        return;
    }

//  qDebug()<< "new pos" << rectWindow.top()<< rectWindow.left()<<rectWindow.width()<< rectWindow.height();
    qDebug()<< "move positon";
    //重新设置窗口位置为新位置信息
    setGeometry(rectWindow);
//    move(100,200);
}














//bool ListWindow::isAdsorbed()
//{
//    return isNormalListWindowAdsorbed;
//}

//void ListWindow::paintEvent(QPaintEvent *)
//{
//    QPainter painter(this);//创建一个QPainter对象
//    painter.drawPixmap(0,0,QPixmap(":/images/Watermelon.png"));//绘制图片到窗口
//    /*
//      QPixmap(":/images/Watermelon.png")如果改为QPixmap()，则只能看到绘制出的框架，看不到图片颜色，也就是看不到图片。
//    */
//}

// 随着窗体变化而设置背景
void ListWindow::resizeEvent(QResizeEvent *event)
{
//    QWidget::resizeEvent(event);
//    QPalette pal(palette());
//    pal.setBrush(QPalette::Window,
//                 QBrush(listBackground.scaled(event->size(),
//                                                 Qt::IgnoreAspectRatio,
//                                                 Qt::SmoothTransformation)));
////    pal.setBrush(QPalette::Window,
////                QBrush(_image.scaled(event->size(), Qt::IgnoreAspectRatio,
////                        Qt::SmoothTransformation)));
//    setPalette(pal);

    QWidget::resizeEvent(event);



    //背景图片缩放，九宫格，四个角不变，其他缩放
    int dx = event->size().width() - listBackground.width();
    int dy = event->size().height() - listBackground.height();
/*暂时去掉  最小窗口时  无法扩大 */
//    if(dx < 1 || dy <1)
//    {
//        qDebug()<< "no zoom !";
//        return;
//    }
    qDebug()<< "begin zoom !";

    //创建一个size为变化后size的新画布
    QImage img(event->size(), QImage::Format_ARGB32);
    QPainter *paint = new QPainter(&img);
    //在新区域画图
    //左上-fixed，中上-x方向scaled，右上-fixed
    paint->drawPixmap(0, 0, listBackground.copy(0, 0, 5, 27));
    paint->drawPixmap(5, 0, listBackground.copy(5, 0, 321, 27).scaled(QSize(321 + dx, 27),
                                                                         Qt::IgnoreAspectRatio,
                                                                         Qt::SmoothTransformation));
    paint->drawPixmap(326 + dx, 0, listBackground.copy(326, 0, 42, 27));
    //左下-fixed，中下-x方向scaled，右下-fixed
    paint->drawPixmap(0, 359 + dy, listBackground.copy(0, 359, 4, 10));
    paint->drawPixmap(4, 359 + dy, listBackground.copy(4, 359, 363, 10).scaled(QSize(363 + dx, 10),
                                                                         Qt::IgnoreAspectRatio,
                                                                         Qt::SmoothTransformation));
    paint->drawPixmap(363 + dx, 359 + dy, listBackground.copy(363, 359, 5, 10));
    //左中-y方向scaled，中中-xy方向scaled，右中-y方向scaled
    paint->drawPixmap(0, 27, listBackground.copy(0, 27, 4, 333).scaled(QSize(4, 333 + dy),
                                                                       Qt::IgnoreAspectRatio,
                                                                       Qt::SmoothTransformation));
    paint->drawPixmap(4, 27, listBackground.copy(4, 27, 358, 333).scaled(QSize(358 + dx, 333 + dy),
                                                                         Qt::IgnoreAspectRatio,
                                                                         Qt::SmoothTransformation));
    paint->drawPixmap(363 + dx, 27, listBackground.copy(363, 27, 5, 333).scaled(QSize(5, 333 + dy),
                                                                            Qt::IgnoreAspectRatio,
                                                                            Qt::SmoothTransformation));


//保留原背景图片对应的resize参数,以供参考和查错
//    //左上-fixed，中上-x方向scaled，右上-fixed
//    paint->drawPixmap(0, 0, listBackground.copy(0, 0, 24, 40));
//    paint->drawPixmap(24, 0, listBackground.copy(24, 0, 240, 40).scaled(QSize(240 + dx, 40),
//                                                                         Qt::IgnoreAspectRatio,
//                                                                         Qt::SmoothTransformation));
//    paint->drawPixmap(264 + dx, 0, listBackground.copy(264, 0, 25, 40));
//    //左下-fixed，中下-x方向scaled，右下-fixed
//    paint->drawPixmap(0, 52 + dy, listBackground.copy(0, 52, 24, 53));
//    paint->drawPixmap(24, 52 + dy, listBackground.copy(24, 52, 240, 53).scaled(QSize(240 + dx, 53),
//                                                                         Qt::IgnoreAspectRatio,
//                                                                         Qt::SmoothTransformation));
//    paint->drawPixmap(264 + dx, 52 + dy, listBackground.copy(264, 52, 25, 53));
//    //左中-y方向scaled，中中-xy方向scaled，右中-y方向scaled
//    paint->drawPixmap(0, 40, listBackground.copy(0, 40, 24, 12).scaled(QSize(24, 12 + dy),
//                                                                       Qt::IgnoreAspectRatio,
//                                                                       Qt::SmoothTransformation));
//    paint->drawPixmap(24, 40, listBackground.copy(24, 40, 240, 12).scaled(QSize(240 + dx, 12 + dy),
//                                                                         Qt::IgnoreAspectRatio,
//                                                                         Qt::SmoothTransformation));
//    paint->drawPixmap(264 + dx, 40, listBackground.copy(264, 40, 25, 12).scaled(QSize(25, 12 + dy),
//                                                                            Qt::IgnoreAspectRatio,
//                                                                            Qt::SmoothTransformation));
    paint->end();

//    QLabel *l = new QLabel;
//    l->setPixmap(QPixmap::fromImage(img));
//    l->show();

    QPalette pal(palette());
    pal.setBrush(QPalette::Window,QBrush(img));
    //    pal.setBrush(QPalette::Window,
    //                 QBrush(backgroundPix.scaled(event->size(),
    //                                              Qt::IgnoreAspectRatio,
    //                                              Qt::SmoothTransformation)));
    setPalette(pal);

    //设置掩板
    //生成一张位图
    QBitmap objBitmap(size());
    //QPainter用于在位图上绘画
    QPainter painter(&objBitmap);
    //填充位图矩形框(用白色填充)
    painter.fillRect(rect(),Qt::white);
    painter.setBrush(QColor(0,0,0));
    //在位图上画圆角矩形(用黑色填充)
    painter.drawRoundedRect(this->rect(),4,4);
    //使用setmask过滤即可
    setMask(objBitmap);
//    closeButton->setGeometry(QRect(this->geometry().width()-18, 5, 11, 10));
}



//点击右上角标题栏按钮时，仅隐藏列表窗口
void ListWindow::close()
{
    setListWindowHidden(true);
}



//void ListWindow::moveListWindow(const QPoint &p, QPoint bottomLeft, QPoint bottomRight)
//{
//    QPoint listWtopLeft = this->geometry().topLeft();
//    if((listWtopLeft.ry() == bottomLeft.ry())
//            &&((listWtopLeft.rx() <= bottomRight.rx())
//               || (geometry().topRight().rx() >= bottomLeft.rx()))){
//        move(p + geometry().topLeft());
//    }
//}

//void ListWindow::toMiniMode()
//{
//    toolWindow->hide();
//    this->hide();
//    miniWindow->show();
//    if(!miniWindow->statusWidgetHidden())
//        miniWindow->setStatusWidgetHidden(false);
//}

//void ListWindow::deleteChain()
//{

//}

void ListWindow::testbenchGeneration()
{

}

void ListWindow::about()
{
    QMessageBox::about(this, tr("About EziDebug"),
            tr("<h2>EziDebug 0.1</h2>"
               "<p>Copyright &copy; 2012 Software Inc."
               "<p>EziDebug is a application that... "
               ""
               ));
}


void ListWindow::show_contextmenu(const QPoint& pos)
{
    QModelIndex  index = moduleTreeView->indexAt(pos) ;
    EziDebugPrj * pcurrentPrj = NULL ;
    pcurrentPrj = const_cast<EziDebugPrj *>(EziDebugInstanceTreeItem::getProject());
    if(index.isValid())
    {
       m_ptreeItem = static_cast<EziDebugInstanceTreeItem *>(index.internalPointer());

       if(m_ptreeItem)
       {
           if(!m_ptreeItem->getScanChainInfo())
           {
                /*可以添加链 不能删除链*/
               m_paddChainAct->setEnabled(true); ;
               m_pdeleteChainAct->setEnabled(false);
           }
           else
           {
               /*可以删除链 不能添加链*/
               m_paddChainAct->setEnabled(false);
               m_pdeleteChainAct->setEnabled(true);
           }
       }

       if(m_ptreeItem->getModuleName() == pcurrentPrj->getTopModule())
       {
           m_paddChainAct->setEnabled(false);
           m_pdeleteChainAct->setEnabled(false);
       }

       if(pcurrentPrj->getPrjModuleMap().value(m_ptreeItem->getModuleName())->isLibaryCore())
       {
           m_paddChainAct->setEnabled(false);
           m_pdeleteChainAct->setEnabled(false);
       }
    }
    else
    {
        m_paddChainAct->setEnabled(false);
        m_pdeleteChainAct->setEnabled(false);
    }

    QPoint mm = QCursor::pos();
    if(m_pcontextMenu)
       m_pcontextMenu->exec(mm) ;


//        m_pcontextMenu->exec(pos) ;
}

void ListWindow::generateTreeView(EziDebugInstanceTreeItem* item)
{
    // item 是 要显示的节点的头节点
//    QString itopModuleComboName  ;
//    QString itopModule ;
//    EziDebugPrj *pcurrentPrj = NULL ;
    if(!m_peziDebugTreeModel)
    {
        qDebug() << "Generate Tree View!!!" << item->getNameData();
        m_peziDebugTreeModel = new EziDebugTreeModel(item,this);
        moduleTreeView->setModel(m_peziDebugTreeModel);
    }
    else
    {
        qDebug() << "Generate Tree View!!!"  ;

        // 插入链 删除链
        moduleTreeView->setModel(NULL);
        // 更新 图标
        if(!item)
        {
        }
        else
        {
#if 0
            EziDebugInstanceTreeItem* poldTreeRootItem = m_peziDebugTreeModel->getInstanceTreeRootItem() ;
            qDebug() << "top item "<< item ;
            // 替换为新的头节点
            m_peziDebugTreeModel->setInstanceTreeRootItem(item);

            /*成功则 删除 上次更新的所有节点 ,插入链的节点咱不能删除  */
            delete poldTreeRootItem ;

            moduleTreeView->setModel(m_peziDebugTreeModel);
#else
            // EziDebugInstanceTreeItem* poldTreeRootItem = m_peziDebugTreeModel->getInstanceTreeRootItem() ;

            delete m_peziDebugTreeModel ;
            // 替换为新的头节点
            m_peziDebugTreeModel = new EziDebugTreeModel(item,this);

            /*成功则 删除 上次更新的所有节点 ,插入链的节点咱不能删除  */
            //delete poldTreeRootItem ;

            moduleTreeView->setModel(m_peziDebugTreeModel);

#endif
        }

    }
}

void ListWindow::clearTreeView(void)
{
    if(moduleTreeView)
    {
        moduleTreeView->setModel(NULL);
        if(m_peziDebugTreeModel)
        {
            delete m_peziDebugTreeModel ;
            m_peziDebugTreeModel = NULL ;
        }
    }
}

void ListWindow::welcomeinfoinit(EziDebugPrj *prj)
{
 #if 0
    // (代码中的扫描链 在 log文件中不存在  说明log文件曾经被破坏过!)
    if(prj->getLogFileExistFlag()&&prj->getLogfileDestroyedFlag())
    {
        // 提示删除所有链   部分扫描链信息丢失  是否删除所有扫描链代码
        QMessageBox::StandardButton rb = QMessageBox::question(this, tr("部分扫描链信息丢失"), tr("是否删除所有扫描链代码?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
        if(rb == QMessageBox::Yes)
        {
            // 删除所有链代码
            currentPrj->deleteAllEziDebugCode(ivlgFileMap,ivhdlFileMap);
            // 删除所有链相关的信息
            QMap<QString,EziDebugScanChain*> ichainMap = currentPrj->getScanChainInfo();
            QMap<QString,EziDebugScanChain*>::const_iterator k = ichainMap.constBegin() ;
            while(k != ichainMap.constEnd())
            {
                EziDebugScanChain* pchain = k.value() ;
                if(pchain)
                {
                    delete pchain ;
                    pchain = NULL ;
                }
                ++k ;
            }
            currentPrj->cleanupChainMap();
            currentPrj->cleanupChainTreeItemMap();
            currentPrj->cleanupChainQueryTreeItemMap();

            // 删除log所有链信息 (新的log文件所以不用添加信息,此步可跳过)

            // 清空 被破坏的扫描链list
            currentPrj->clearupDestroyedChainList();

        }
        else
        {
            // 不处理
        }

    }
 #endif
    if(prj)
    {
        if(!m_peziDebugTreeModel)
        {
            ToolWindow * pparent = static_cast<ToolWindow*>(toolWindow) ;

            /*向文本栏 传递错误信息 待窗体显示的时候，显示给用户看*/
            addMessage("error","EziDebug error: The EziDebug config file has been destroyed!");

            // log 文件被破坏, 可能还没有扫描到扫描链
            //if(prj->getScanChainInfo().count())
            //{
                // 配置文件被破坏  是否删除工程代码中所有的扫描链代码？
                #if 0
                QMessageBox::StandardButton rb = QMessageBox::question(this, tr("配置文件被破坏"), tr("是否删除工程代码中所有扫描链代码?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
				#else
				QMessageBox::StandardButton rb = QMessageBox::question(this, tr("EziDebug"), tr("The configuration file has been destroyed,\n Do you want to delete all scan chain code ?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);

				#endif

                if(rb == QMessageBox::Yes)
                {
                    QMap<QString,EziDebugVlgFile*> ivlgFileMap ;
                    QMap<QString,EziDebugVhdlFile*> ivhdlFileMap ;
                    if(EziDebugPrj::ToolQuartus == prj->getToolType())
                    {
                        prj->parseQuartusPrjFile(ivlgFileMap,ivhdlFileMap);
                    }
                    else if(EziDebugPrj::ToolIse == prj->getToolType())
                    {
                        prj->parseIsePrjFile(ivlgFileMap,ivhdlFileMap);
                    }
                    else
                    {
                        addMessage("error","EziDebug error: EziDebug is not support this kind project file parse!");
                        delete prj ;
                        pparent->setCurrentProject(NULL);
                    }

                    // delete all ezidebug code
                    prj->deleteAllEziDebugCode(ivlgFileMap,ivhdlFileMap) ;

                    // delete all log file
                    addMessage("warning","EziDebug warning: The EziDebug config file has been deleted!");
                    QFile ilogFile(prj->getCurrentDir().absoluteFilePath("config.ezi"));
                    ilogFile.remove();

                    // set exist flag false
                    //prj->setLogFileExistFlag(false);

                    delete prj ;
                    pparent->setCurrentProject(NULL);

                }
                else
                {
                    // 如果不删除代码,不进行恢复
                    delete prj ;
                    pparent->setCurrentProject(NULL);
                }
            //}
        }
        else
        {
            QList<EziDebugPrj::LOG_FILE_INFO*> iaddedinfoList ;
            QList<EziDebugPrj::LOG_FILE_INFO*> ideletedinfoList ;
            QStringList iunDelChainList ;
            QStringList ideletedChainList ;

            // (代码中的扫描链 在 log文件中不存在  说明log文件曾经被破坏过!)
            if(prj->getLogFileExistFlag()&&prj->getLogfileDestroyedFlag())
            {
                // 提示删除所有链
                // 部分扫描链信息丢失  是否删除所有扫描链代码
                #if 0
                QMessageBox::StandardButton rb = QMessageBox::question(this, tr("部分扫描链信息丢失"), tr("是否删除所有扫描链代码?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
				#else
			    QMessageBox::StandardButton rb = QMessageBox::question(this, tr("EziDebug"), tr("Some scan chain information has lost, \n Do you want to delete all scan chain code ?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
				#endif
                if(rb == QMessageBox::Yes)
                {
                    // 删除所有链代码

                    prj->deleteAllEziDebugCode(prj->getPrjVlgFileMap(),prj->getPrjVhdlFileMap());

                    QMap<QString,EziDebugVlgFile*>::const_iterator ivlgFileIter = prj->getPrjVlgFileMap().constBegin() ;
                    while(ivlgFileIter != prj->getPrjVlgFileMap().constEnd())
                    {
                        QString irelativeFileName = ivlgFileIter.key() ;
                        EziDebugVlgFile* pfile = ivlgFileIter.value() ;

                        EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                        pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                        pdelFileInfo->pinfo = NULL ;
                        memcpy(pdelFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
                        ideletedinfoList.append(pdelFileInfo);

                        struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                        paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                        paddFileInfo->pinfo = pfile ;
                        memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data(), irelativeFileName.size()+1);
                        iaddedinfoList.append(paddFileInfo);

                        ++ivlgFileIter ;
                    }


                    QMap<QString,EziDebugVhdlFile*>::const_iterator ivhdlFileIter = prj->getPrjVhdlFileMap().constBegin() ;
                    while(ivhdlFileIter != prj->getPrjVhdlFileMap().constEnd())
                    {
                        QString irelativeFileName = ivhdlFileIter.key() ;
                        EziDebugVhdlFile* pfile = ivhdlFileIter.value() ;
                        EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                        pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                        pdelFileInfo->pinfo = NULL ;
                        memcpy(pdelFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
                        ideletedinfoList.append(pdelFileInfo);

                        struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                        paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                        paddFileInfo->pinfo = pfile ;
                        memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data(), irelativeFileName.size()+1);
                        iaddedinfoList.append(paddFileInfo);
                        ++ivhdlFileIter ;
                    }


                    // 删除所有链相关的信息
                    QMap<QString,EziDebugScanChain*> ichainMap = prj->getScanChainInfo();
                    QMap<QString,EziDebugScanChain*>::const_iterator k = ichainMap.constBegin() ;
                    while(k != ichainMap.constEnd())
                    {
                        QString ichainName = k.key() ;
                        EziDebugScanChain* pchain = k.value() ;

                        // 从log文件中删除相关信息
                        struct EziDebugPrj::LOG_FILE_INFO* pdelChainInfo = new EziDebugPrj::LOG_FILE_INFO ;
                        memcpy(pdelChainInfo->ainfoName,ichainName.toAscii().data(),ichainName.size()+1);
                        pdelChainInfo->pinfo = NULL ;
                        pdelChainInfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
                        ideletedinfoList << pdelChainInfo ;

                        if(pchain)
                        {
                            delete pchain ;
                            pchain = NULL ;
                        }
                        ++k ;
                    }
                    prj->cleanupChainMap();
                    prj->cleanupChainTreeItemMap();
                    prj->cleanupChainQueryTreeItemMap();

                    // 删除log所有链信息 (新的log文件所以不用添加信息,此步可跳过)

                    // 清空 被破坏的扫描链list
                    prj->clearupDestroyedChainList();

                }
                else
                {
                    // 不处理
                }

            }


            if(prj->getDestroyedChainList().count())
            {
                // 把所有破坏掉的链打印出来

                QString ichain ;
                QStringList idestroyedChainList = prj->getDestroyedChainList() ;

                addMessage("error","The destroyed chain are:");
                for(int i = 0 ; i < idestroyedChainList.count() ;i++)
                {
                    QString ichainName = idestroyedChainList.at(i) ;

                    EziDebugInstanceTreeItem *pitem = prj->getChainTreeItemMap().value(ichainName);
                    if(pitem)
                    {
                        ichain.append(tr("EziDebug chain:   %1  topInstance:    %2:%3").arg(ichainName)\
                                      .arg(pitem->getModuleName()).arg(pitem->getInstanceName())) ;
                    }
                    addMessage("error",ichain);
                }

                // 是否删除相关扫描链代码,否则相应扫描链不可用！
                #if 0
                QMessageBox::StandardButton rb = QMessageBox::question(this, tr("部分扫描链被破坏"), tr("相关扫描链不可用,是否删除相关扫描链代码?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
				#else
				QMessageBox::StandardButton rb = QMessageBox::question(this, tr("EziDebug"), tr("Some scan chains has been destroyed ,\n Do you want to delete all scan chain code ?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
				#endif
                if(rb == QMessageBox::Yes)
                {
                    iunDelChainList = prj->deleteDestroyedChain(iaddedinfoList,ideletedinfoList) ;
                    if(iunDelChainList.count())
                    {
                        addMessage("error","EziDebug error: Some chains can not be deleted for some reasons!");
                        for(int i = 0 ; i < iunDelChainList.count() ;i++)
                        {
                            addMessage("error",tr("EziDebug chain:%1").arg(iunDelChainList.at(i)));
                        }
                        addMessage("error","EziDebug error: Please check the code file is compiled successfully or not!");
                    }

                    for(int i = 0 ; i < idestroyedChainList.count() ; i++)
                    {
                        QString idestroyedChain = idestroyedChainList.at(i) ;
                        if(!iunDelChainList.contains(idestroyedChain))
                        {
                            ideletedChainList.append(idestroyedChain);
                            struct EziDebugPrj::LOG_FILE_INFO* pdelChainInfo = new EziDebugPrj::LOG_FILE_INFO ;
                            memcpy(pdelChainInfo->ainfoName,idestroyedChain.toAscii().data(),idestroyedChain.size()+1);
                            pdelChainInfo->pinfo = NULL ;
                            pdelChainInfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
                            ideletedinfoList << pdelChainInfo ;
                        }
                    }

                }
            }

            QStringList icheckChainList = prj->checkChainExist();

            for(int i = 0 ; i < icheckChainList.count() ;i++)
            {
                QString iupdatedChain = icheckChainList.at(i) ;
                if(!ideletedChainList.contains(iupdatedChain))
                {
                    struct EziDebugPrj::LOG_FILE_INFO* pdelChainInfo = new EziDebugPrj::LOG_FILE_INFO ;
                    memcpy(pdelChainInfo->ainfoName,iupdatedChain.toAscii().data(),iupdatedChain.size()+1);
                    pdelChainInfo->pinfo = NULL ;
                    pdelChainInfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
                    ideletedinfoList << pdelChainInfo ;

                    struct EziDebugPrj::LOG_FILE_INFO* paddChainInfo = new EziDebugPrj::LOG_FILE_INFO ;
                    memcpy(paddChainInfo->ainfoName,iupdatedChain.toAscii().data(),iupdatedChain.size()+1);
                    paddChainInfo->pinfo = paddChainInfo ;
                    paddChainInfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
                    iaddedinfoList << paddChainInfo ;
                }
            }

#if 0
            if(prj->getScanChainInfo().count())
            {
                QMap<QString,EziDebugScanChain*>::const_iterator iaddedChainIter = prj->getScanChainInfo().constBegin() ;
                while(iaddedChainIter !=  prj->getScanChainInfo().constEnd())
                {
                    QString ichainName = iaddedChainIter.key();
                    struct EziDebugPrj::LOG_FILE_INFO* pinfo = new EziDebugPrj::LOG_FILE_INFO ;
                    memcpy(pinfo->ainfoName ,ichainName.toAscii().data(),ichainName.size()+1);
                    pinfo->pinfo = iaddedChainIter.value() ;
                    pinfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
                    iaddedinfoList << pinfo ;
                    ++iaddedChainIter ;
                }
            }
#endif

            if(prj->changedLogFile(iaddedinfoList,ideletedinfoList))
            {
                //提示 保存 log 文件出错
                addMessage("info","EziDebug info: changedLogFile encounter some problem!");
            }


            // 删除 新分配的  log_file_info 指针

            qDeleteAll(iaddedinfoList);
            qDeleteAll(ideletedinfoList);

            QStandardItem * pitem = addMessage("info",tr("EziDebug info: The default project parameters:"));
            addMessage("process",tr("      Scanchain Max Register Number: %1").arg(prj->getMaxRegNumPerChain()),pitem);
            addMessage("process",tr("      Project Path: %1").arg(prj->getCurrentDir().absolutePath()),pitem);
            addMessage("process",tr("      Compile Software: \"%1\"").arg((prj->getToolType() == EziDebugPrj::ToolQuartus) ? ("quartus") :("ise")),pitem);

            if(prj->getChainTreeItemMap().count())
            {
                QStandardItem * psecondItem = addMessage("info","      EziDebug info: The existed chains are:",pitem);
                QMap<QString,EziDebugInstanceTreeItem*> itreeItemMap = prj->getChainTreeItemMap() ;
                QMap<QString,EziDebugInstanceTreeItem*>::const_iterator i = itreeItemMap.constBegin() ;
                while( i!= itreeItemMap.constEnd())
                {
                    EziDebugInstanceTreeItem* pitem = i.value();
                    addMessage("process",tr("            EziDebug chain: %1\tInstance Node:%2").arg(i.key()).arg(pitem->getNameData()),psecondItem);
                    EziDebugScanChain *pscanChain = pitem->getScanChainInfo();
                    QString iclockNumStr ;
                    QString itraversedInstStr ;
                    QMap<QString,QVector<QStringList> > iregChain = pscanChain->getRegChain();
                    QMap<QString,QVector<QStringList> >::const_iterator iregChainIter = iregChain.constBegin() ;
                    while( iregChainIter != iregChain.constEnd())
                    {
                        iclockNumStr.append(tr("%1 (%2)     ").arg(pscanChain->getChainRegCount(iregChainIter.key())).arg(iregChainIter.key()));
                        ++iregChainIter ;
                    }

                    addMessage("process" , tr("            The chain total reg number: %1").arg(iclockNumStr),psecondItem);
                    addMessage("process" , tr("            The traversed NodeList:"),psecondItem);

                    for(int j = 0 ; j < pscanChain->getInstanceItemList().count() ;j++)
                    {
                        itraversedInstStr.append(tr("  ->  ") + pscanChain->getInstanceItemList().at(j)) ;
                        if((j+1)%3 == 0)
                        {
                            addMessage("process" , tr("            ") + itraversedInstStr,psecondItem);
                            itraversedInstStr.clear();
                        }
                    }
                    addMessage("process" , tr("            ") + itraversedInstStr,psecondItem);

                    ++i ;
                }
            }


            UpdateDetectThread * pthread = prj->getThread() ;
            pthread->start();
        }
    }
}


QPushButton *ListWindow::createToolButton(const QString &toolTip, const QIcon &icon,
                                    const QSize &size, const char *member)
{
    QPushButton *button = new QPushButton(this);
    button->setToolTip(toolTip);
    button->setIcon(icon);
    button->setIconSize(size);//(QSize(10, 10));
    // button->setSizeIncrement(size);
    //button->setSizePolicy(size.width(), size.height());
    button->setFlat(true);
    connect(button, SIGNAL(clicked()), this, member);

    return button;
}

void ListWindow::find()
{
    if (!findDialog) {
        findDialog = new FindDialog;
//        connect(findDialog, SIGNAL(findNext(const QString &,
//                                            Qt::CaseSensitivity)),
//                spreadsheet, SLOT(findNext(const QString &,
//                                           Qt::CaseSensitivity)));
//        connect(findDialog, SIGNAL(findPrevious(const QString &,
//                                                Qt::CaseSensitivity)),
//                spreadsheet, SLOT(findPrevious(const QString &,
//                                               Qt::CaseSensitivity)));
    }

    findDialog->show();
    findDialog->raise();
    findDialog->activateWindow();
}


//控制列表窗口是否隐藏
void ListWindow::setListWindowHidden(bool flag)
{
    isListWindowHiddenFlag = flag;
    if(isListWindowHiddenFlag)
        this->hide();
    else
        this->showNormal();
}

//获取普通模式下，ToolWindow不隐藏时，列表窗口是否隐藏
bool ListWindow::isListWindowHidden()
{
    return isListWindowHiddenFlag;
}

void ListWindow::enterEvent(QEvent * event)
{
//    QMouseEvent * mouseEvent = (QMouseEvent *) event ;
//    qDebug()<<"enter  Event" << mouseEvent->x()<< mouseEvent->y()<< this->frameGeometry().right();
//    eDirection = (enum_Direction)PointValid(mouseEvent->x(),mouseEvent->y());
//    SetCursorStyle(eDirection);
}

void ListWindow::leaveEvent(QEvent * event)
{
//    QMouseEvent * mouseEvent = (QMouseEvent *) event ;
//    qDebug()<<"leave  Event" << mouseEvent->x()<< mouseEvent->y()<< this->frameGeometry().right();
//    eDirection = (enum_Direction)PointValid(mouseEvent->x(),mouseEvent->y());
//    SetCursorStyle(eDirection);
}

void ListWindow::setChainActEnable(bool addenable,bool delenable)
{
//    m_paddChainAct->setEnabled(addenable) ;
//    m_pdeleteChainAct->setEnabled(delenable) ;
}

////工具栏窗口只需要获取isListWindowAdsorbed，而不需要更改之
//bool ListWindow::isListWindowAdsorbed()
//{
//    return isListWindowAdsorbedFlag;
//}

EziDebugInstanceTreeItem * ListWindow::getCurrentTreeItem(void)
{
    return m_ptreeItem ;
}

void ListWindow::setCurrentTreeItem(EziDebugInstanceTreeItem * item)
{
    m_ptreeItem = item ;
}
