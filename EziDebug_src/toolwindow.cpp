#include <QtGui>
#include <QDebug>
#include <QSystemTrayIcon>
#include <QDir>
#include <QList>


#include "button.h"
#include "toolwindow.h"
#include "ezidebugprj.h"

#include "ezidebugmodule.h"
#include "ezidebugvlgfile.h"
#include "ezidebugvhdlfile.h"
#include "ezidebuginstancetreeitem.h"
#include "ezidebugscanchain.h"
#include "importdatadialog.h"
#include "textquery.h"
//#include "updatedetectthread.h"

#define ZERO_REG_NUM  0
#define PARAMETER_OK            0x0
#define NO_PARAMETER_TOOL       0x01
#define NO_PARAMETER_REG_NUM    0x02
#define NO_PARAMETER_DIR        0x04
#define NO_PARAMETER_ALL        (0x01|0x02|0x04)
static unsigned long long tic = 0 ;


ToolWindow::ToolWindow(QWidget *parent) :
    QWidget(parent)
{
    QTextCodec::setCodecForTr(QTextCodec::codecForName("gb18030"));
    isNeededUpdate = false ;
    currentPrj = NULL  ;
    readSetting() ;  // 读取软件保存的配置信息
    setWindowTitle(tr("EziDebug"));
    //普通模式下的列表窗口 Qt::FramelessWindowHint
    listWindow = new ListWindow(this,Qt::FramelessWindowHint);
    m_proSetWiz = 0 ;
    //m_pcurrentPrj = 0 ;
    createActions();   //创建右键菜单的选项
    createButtons();   //创建按钮
    creatTrayIcon();   //创建托盘图标

    //设置背景
    QPixmap backgroundPix;
    QPixmap maskPix;
    QPalette palette;
    maskPix.load(":/images/toolWindowMask.bmp");
    setMask(maskPix);
    backgroundPix.load(":/images/mainBackground.bmp",0,Qt::AvoidDither|Qt::ThresholdDither|Qt::ThresholdAlphaDither);
    palette.setBrush(QPalette::Background, QBrush(backgroundPix));
    setPalette(palette);
    //setMask(backgroundPix.mask());   //通过QPixmap的方法获得图片的过滤掉透明的部分得到的图片，作为Widget的不规则边框
    //setWindowOpacity(1.0);  //设置图片透明度
    //设置对话框的位置和大小
    //setGeometry(QRect(250,100,355,25));
    setFixedSize(backgroundPix.size());//设置窗口的尺寸为图片的尺寸
    move((qApp->desktop()->width() - this->width()) / 2,
         (qApp->desktop()->height() - this->height()) /2 - 100);//将窗口移至屏幕中间靠上的位置
    setWindowFlags(Qt::FramelessWindowHint|Qt::WindowSystemMenuHint | Qt::WindowMinimizeButtonHint);//设置为无边框 允许任务栏按钮右键菜单 允许最小化与还原
    //
    //设置普通模式下按钮的位置和大小
    //标题栏按钮
    minimizeButton->setGeometry(251, 0, 27, 19);//最小化
    miniModeButton->setGeometry(QRect(277, 0, 27, 19));//迷你模式
    showListWindowButton->setGeometry(QRect(303, 0, 27, 19));//展开listWindow的按钮
    exitButton->setGeometry(QRect(329, 0, 33, 19));//关闭
    //功能按钮
    proSettingButton->setGeometry(QRect(23, 37, 42, 41));//工程设置
    proUpdateButton->setGeometry(QRect(65, 37, 42, 41));//更新
    proPartlyUpdateButton->setGeometry(QRect(107, 37, 42, 41));//部分更新
    deleteChainButton->setGeometry(QRect(149, 37, 42, 41));//删除
    testbenchGenerationButton->setGeometry(QRect(191, 37, 42, 41));//testbench生成
    proUndoButton->setGeometry(QRect(233, 37, 42, 41));//撤销（undo）

    //进度条
    progressBar = new QProgressBar(this);
    progressBar->setGeometry(QRect(28, 88, 248, 10));
    progressBar->setRange(0, 100);
    progressBar->setValue(0);

    //progressBar->setStyleSheet("QProgressBar { border: 2px solid grey; border-radius: 5px; }");
//    progressBar->setStyleSheet("QProgressBar::chunk { background-color: #6cccff;width: 6px;}");
//    progressBar->setStyleSheet("QProgressBar { border: 0px solid grey;border-radius: 2px; text-align: right;}");

    progressBar->setTextVisible(false);
    progressBar->setStyleSheet(
    "QProgressBar {"
    "border: 0px solid black;"
    "width: 10px;"
    "background: QLinearGradient( x1: 0, y1: 0.1, x2: 0, y2: 0.9,"
    "stop: 0 #fff,"
    "stop: 0.4999 #eee,"
    "stop: 0.5 #ddd,"
    "stop: 1 #eee );}");

    progressBar->setStyleSheet(
    "QProgressBar::chunk {"
    "background: QLinearGradient( x1: 0, y1: 0.1, x2: 0, y2: 0.9,"
    "stop: 0 #ace5ff,"
    "stop: 0.4999 #42c8ff,"
    "stop: 0.5 #22b8ff,"
    "stop: 1 #ace5ff );"
    "border: 0px solid black;}");


//    progressBar->setStyleSheet("  \
//    QProgressBar {  \
//    border: 0px solid black;  \
//    text-align: right;    \
//    padding: 1px;   \
//    border-top-left-radius: 5px;    \
//    border-bottom-left-radius: 5px; \
//    width: 8px;   \
//    background: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1,    \
//    stop: 0 #fff,   \
//    stop: 0.4999 #eee,  \
//    stop: 0.5 #ddd, \
//    stop: 1 #eee );}");

//    progressBar->setStyleSheet("    \
//    QProgressBar::chunk {   \
//    background: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1,   \
//    stop: 0 #78d,   \
//    stop: 0.4999 #46a,   \
//    stop: 0.5 #45a,   \
//    stop: 1 #238 );   \
//    border-top-left-radius: 5px;    \
//    border-bottom-left-radius: 5px; \
//    border: 0px solid black;}");


    //m_iplogolabel = new QLabel(this) ;
    //EziDebugIcon1
    //m_iplogolabel->setPixmap(QPixmap(":/images/indication.bmp"));
    //m_iplogolabel->setGeometry(QRect(30, 20, 80, 44));

    updatehintButton = new QPushButton(this) ;
    //updatehintButton->setIcon(QIcon(":/images/update2.png"));
    updatehintButton->setIcon(QIcon(":/images/update2.png"));
    updatehintButton->setFlat(true);
    updatehintButton->setIconSize(QSize(30,29));
    updatehintButton->setGeometry(QRect(320, 75, 30, 29));
    updatehintButton->setFocusPolicy(Qt::NoFocus);
    updatehintButton->setDisabled(true);

    iChangeUpdateButtonTimer = new QTimer(this) ;
    connect(iChangeUpdateButtonTimer, SIGNAL(timeout()), this, SLOT(changeUpdatePic()));


    // setListWindowAdsorbedFlag(true);

//进度条演示
//   QTimer *timer = new QTimer(this);
//       connect(timer, SIGNAL(timeout()), this, SLOT(progressBarDemo()));
//       timer->start(1000);



//单独的窗口显示进度条
//    QProgressDialog progressDialog(this);
//    progressDialog.setCancelButtonText(tr("取消"));
//    progressDialog.setRange(0, 100);
//    progressDialog.setWindowTitle(tr("进度条"));

//    for (int i = 0; i < 100; ++i) {
//        progressDialog.setValue(i);
//        progressDialog.setLabelText(tr("进度为 %1 / %2...")
//                                    .arg(i).arg(100));
//        qApp->processEvents();
//        if (progressDialog.wasCanceled()){
//            //添加取消时的工作
//            break;
//        }
//        for (int j = 0; j < 100000000; ++j);
//    }



    listWindow->setWindowFlags(Qt::SplashScreen);

    // 为 listwindow 安装事件过滤器
    // listWindow->installEventFilter(this);
    // listWindow->setWindowFlags(Qt::Window);

//    aa = new QWidget(this,Qt::FramelessWindowHint) ;
//    aa->setWindowTitle("zenmehuishi");
//    aa->show();
//    aa->raise();
//    aa->activateWindow();
//    qDebug()<< this->frameGeometry().left() << this->frameGeometry().bottom();


    listWindow->move(this->frameGeometry().bottomLeft());//列表窗口初始位置为toolWindow的正下方
    listWindow->setWindowStick(true);
//  listWindow->move(this->frameGeometry().left()-3,this->frameGeometry().bottom()-29);
//  listWindow->move(0,0);

//    qDebug()<< listWindow->pos().x()<<listWindow->pos().y();
//    qDebug()<< listWindow->pos().rx()<<listWindow->pos().ry();

//    qDebug()<< this->frameGeometry().bottom();
//    qDebug()<< listWindow->frameGeometry().top();




    //不隐藏列表窗口
    listWindow->setListWindowHidden(false);
    //列表窗口默认吸附在工具栏窗口下方
    isListWindowAdsorbed = true;

    //已修改
#if 0
    connect(listWindow, SIGNAL(mouseReleased(const QRect)),
            this, SLOT(listWindowMouseReleased(const QRect)));
#endif

    connect(this,SIGNAL(updateTreeView(EziDebugInstanceTreeItem*)),listWindow,SLOT(generateTreeView(EziDebugInstanceTreeItem*)));


    //迷你模式下的主窗口和状态栏
    //miniWindow = 0;
    miniWindow = new MiniWindow;
    miniWindow->hide();
    isNormalMode = true ;
    //迷你模式转换到普通模式
    connect(miniWindow, SIGNAL(toNormalMode()), this, SLOT(toNormalMode()));
    //miniWindow最小化时，修改相关菜单信息
    connect(miniWindow->minimizeButton, SIGNAL(clicked()), this, SLOT(miniWindowMinimized()));

    //工程设置
    connect(miniWindow->proSettingButton, SIGNAL(clicked()), this, SLOT(proSetting()));
    //更新
    connect(miniWindow->proUpdateButton, SIGNAL(clicked()), this, SLOT(proUpdate()));
    //部分更新
    connect(miniWindow->proPartlyUpdateButton, SIGNAL(clicked()), this, SLOT(fastUpdate()));
    //删除
    connect(miniWindow->deleteChainButton, SIGNAL(clicked()), this, SLOT(deleteAllChain()));
    //testbench生成
    connect(miniWindow->testbenchGenerationButton, SIGNAL(clicked()), this, SLOT(testbenchGeneration()));
    //撤销（undo）
    connect(miniWindow->proUndoButton, SIGNAL(clicked()), this, SLOT(undoOperation()));
}

ToolWindow::~ToolWindow()
{
    qDebug() << "Attention:Begin to destruct toolwindow!";
    if(currentPrj)
        delete currentPrj ;
}

//bool ToolWindow::eventFilter(QObject *obj, QEvent *event)
//{
//    if(obj == listWindow)
//    {
//        qDebug()<< "nothing to do !";
//        return 0 ;
//    }
//    else
//    {
//        return QWidget::eventFilter(obj,event);
//    }
//}
void ToolWindow::proSetting()
{
    int nexecResult = 0 ;
    if(!m_proSetWiz)
    {
        m_proSetWiz = new ProjectSetWizard(this);
    }
    else
    {
        delete m_proSetWiz ;
        m_proSetWiz = new ProjectSetWizard(this);
    }
    //connect
    if((nexecResult = m_proSetWiz->exec()))
    {   
#if 0
        QMessageBox::information(this, QObject::tr("工程向导"),QObject::tr("参数设置完成"));
#else
        QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Finishing setting the project configurations!"));
#endif

        /*根据设置的参数来 判断是否进行重新创建工程对象*/
        if(!currentPrj)
        {
            currentPrj = new EziDebugPrj(m_proSetWiz->m_uncurrentRegNum,m_proSetWiz->m_icurrentDir,m_proSetWiz->m_ecurrentTool,this);
                            currentPrj->setXilinxErrCheckedFlag(m_proSetWiz->m_isXilinxErrChecked);
            UpdateDetectThread * pthread =  currentPrj->getThread() ;
            connect(pthread,SIGNAL(codeFileChanged()),this,SLOT(updateIndicate()));
            connect(currentPrj,SIGNAL(updateProgressBar(int)),this,SLOT(changeProgressBar(int)));

            listWindow->addMessage("info","EziDebug info: open new project!");
            QStandardItem * pitem = listWindow->addMessage("info",tr("The current project parameter:"));
            listWindow->addMessage("process",tr("      The  maximum register number of scan chain: %1").arg(m_proSetWiz->m_uncurrentRegNum),pitem);
            listWindow->addMessage("process",tr("      The current project path: %1").arg(m_proSetWiz->m_icurrentDir),pitem);
            listWindow->addMessage("process",tr("      The compile software: \"%1\"").arg((m_proSetWiz->m_ecurrentTool == EziDebugPrj::ToolQuartus) ? ("quartus") :("ise")),pitem);
        }
        else
        {
            if((m_proSetWiz->m_uncurrentRegNum == currentPrj->getMaxRegNumPerChain())\
                &&(m_proSetWiz->m_ecurrentTool == currentPrj->getToolType())\
                &&(QDir::toNativeSeparators(m_proSetWiz->m_icurrentDir) == QDir::toNativeSeparators(currentPrj->getCurrentDir().absolutePath()))\
                    &&(m_proSetWiz->m_isXilinxErrChecked == currentPrj->getSoftwareXilinxErrCheckedFlag()))
            {
                /*do nothing*/
                listWindow->addMessage("info","EziDebug info: The project parameters are the same as before!");
                QStandardItem * pitem = listWindow->addMessage("process",tr("The new project parameters:"));
                listWindow->addMessage("info",tr("      The  maximum register number of scan chain: %1").arg(m_proSetWiz->m_uncurrentRegNum),pitem);
                listWindow->addMessage("info",tr("      The current project path: %1").arg(m_proSetWiz->m_icurrentDir),pitem);
                listWindow->addMessage("info",tr("      The compile software: \"%1\"").arg((m_proSetWiz->m_ecurrentTool == EziDebugPrj::ToolQuartus) ? ("quartus") :("ise")),pitem);
            }
            else if(QDir::toNativeSeparators(m_proSetWiz->m_icurrentDir) != QDir::toNativeSeparators(currentPrj->getCurrentDir().absolutePath()))
            {
                qDebug() << m_proSetWiz->m_icurrentDir << endl << currentPrj->getCurrentDir().absolutePath() << QDir::toNativeSeparators(currentPrj->getCurrentDir().absolutePath()) ;
                delete currentPrj ;
                currentPrj = NULL ;
                EziDebugInstanceTreeItem::setProject(NULL);
                listWindow->clearTreeView();

                currentPrj = new EziDebugPrj(m_proSetWiz->m_uncurrentRegNum,m_proSetWiz->m_icurrentDir,m_proSetWiz->m_ecurrentTool,this);
                currentPrj->setXilinxErrCheckedFlag(m_proSetWiz->m_isXilinxErrChecked);
                //pparent->setCurrentProject(pcurrentPrj);
                UpdateDetectThread * pthread =  currentPrj->getThread() ;
                connect(pthread,SIGNAL(codeFileChanged()),this,SLOT(updateIndicate()));
                connect(currentPrj,SIGNAL(updateProgressBar(int)),this,SLOT(changeProgressBar(int)));

				#if 0
                QMessageBox::information(this, QObject::tr("工程设置"),QObject::tr("准备解析新的工程！"));
				#else
				QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Ready to parse new project!"));
				#endif
				
                listWindow->addMessage("info","EziDebug info: The project is changed !");
                QStandardItem * pitem = listWindow->addMessage("warning",tr("The new project parameters:"));
                listWindow->addMessage("warning",tr("      The  maximum register number of scan chain: %1").arg(m_proSetWiz->m_uncurrentRegNum),pitem);
                listWindow->addMessage("warning",tr("      The current project path: %1").arg(m_proSetWiz->m_icurrentDir),pitem);
                listWindow->addMessage("warning",tr("      The compile software: \"%1\"").arg((m_proSetWiz->m_ecurrentTool == EziDebugPrj::ToolQuartus) ? ("quartus") :("ise")),pitem);


                /*等待用户 update all 重新解析工程*/
                /*toolwindow 初始化时 部分更新 全部更新 删除全部链 生成testbench 均不可用*/
            }
            else if(m_proSetWiz->m_ecurrentTool != currentPrj->getToolType())
            {

                /*重新设置工程参数*/
                currentPrj->setToolType(m_proSetWiz->m_ecurrentTool);
                listWindow->addMessage("warning","EziDebug warning: The project's parameters have been changed!");
                listWindow->addMessage("warning","EziDebug warning: Please delete all scan chains and insert the chain again!");


                bool eneededCreateTestBenchFlag = false ;
                QMap<QString,EziDebugScanChain*>::const_iterator i = currentPrj->getScanChainInfo().constBegin();
                while (i != currentPrj->getScanChainInfo().constEnd())
                {
                    EziDebugScanChain * pchain = i.value() ;
                    if(!pchain->getCfgFileName().isEmpty())
                    {
                        eneededCreateTestBenchFlag = true ;
                        break ;
                    }
                }

                if(eneededCreateTestBenchFlag)
                {
                    /*提示是否重新生成testbench*/
					#if 0
                    QMessageBox::information(this, QObject::tr("工程设置"),QObject::tr("原代码中存在扫描链,请删除所有链之后重新添加并生成相应的testBench文件!"));
					#else
					QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("The existed scan chain isn't available, Plesase delete it !"));
					#endif
                }

                delete currentPrj ;
                currentPrj = NULL ;
                EziDebugInstanceTreeItem::setProject(NULL);
                listWindow->clearTreeView();

                currentPrj = new EziDebugPrj(m_proSetWiz->m_uncurrentRegNum,m_proSetWiz->m_icurrentDir,m_proSetWiz->m_ecurrentTool,this);
                currentPrj->setXilinxErrCheckedFlag(m_proSetWiz->m_isXilinxErrChecked);
                //pparent->setCurrentProject(pcurrentPrj);
                UpdateDetectThread * pthread =  currentPrj->getThread() ;
                connect(pthread,SIGNAL(codeFileChanged()),this,SLOT(updateIndicate()));
                connect(currentPrj,SIGNAL(updateProgressBar(int)),this,SLOT(changeProgressBar(int)));

				#if 0
                QMessageBox::information(this, QObject::tr("工程设置"),QObject::tr("准备解析新的工程！"));
				#else
				QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Ready to parse project!"));
				#endif
				
                listWindow->addMessage("info","EziDebug info: The project is changed !");
                QStandardItem * pitem = listWindow->addMessage("warning",tr("The new project parameter:"));
                listWindow->addMessage("warning",tr("      The  maximum register number of scan chain: %1").arg(m_proSetWiz->m_uncurrentRegNum),pitem);
                listWindow->addMessage("warning",tr("      The current project path: %1").arg(m_proSetWiz->m_icurrentDir),pitem);
                listWindow->addMessage("warning",tr("      The compile software: \"%1\"").arg((m_proSetWiz->m_ecurrentTool == EziDebugPrj::ToolQuartus) ? ("quartus") :("ise")),pitem);

            }
            else
            {
                if(m_proSetWiz->m_uncurrentRegNum != currentPrj->getMaxRegNumPerChain())
                {
                    /*重新设置工程参数*/
                    currentPrj->setMaxRegNumPerChain(m_proSetWiz->m_uncurrentRegNum);
                    listWindow->addMessage("info","EziDebug info: The project parameter is changed !");
                    if(currentPrj->getScanChainInfo().count())
                    {
                        /*提示重新添加链 并重新生成testbench*/
						#if 0
                        QMessageBox::information(this, QObject::tr("工程设置"),QObject::tr("最大链寄存器个数已更改,之前所加扫描链不可用,请删除所有扫描链！"));
						#else
						QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("The  maximum register number of scan chain has been changed, \n Please delete all scan chain codes inserted before!"));
						#endif
                    }
                }


                if((m_proSetWiz->m_isXilinxErrChecked != currentPrj->getSoftwareXilinxErrCheckedFlag())&&(m_proSetWiz->m_ecurrentTool == EziDebugPrj::ToolIse))
                {
                    /*提示是否重新生成testbench*/
					#if 0
                    QMessageBox::warning(this, QObject::tr("工程设置"),QObject::tr("注意在 Xilinx 工程下 可能会导致 扫描链截取信号不正确!"));
					#else
					QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("Note: With Xilinx,information of scan chains may be mistaken!"));
					#endif
                    /**/
                }

                QStandardItem * pitem = listWindow->addMessage("warning",tr("The new project parameters:"));
                listWindow->addMessage("process",tr("      The  maximum register number of scan chain: %1").arg(m_proSetWiz->m_uncurrentRegNum),pitem);
                listWindow->addMessage("process",tr("      The current project path: %1").arg(m_proSetWiz->m_icurrentDir),pitem);
                listWindow->addMessage("process",tr("      The compile software: \"%1\"").arg((m_proSetWiz->m_ecurrentTool == EziDebugPrj::ToolQuartus) ? ("quartus") :("ise")),pitem);

            }

        }
        return ;
    }
}

void ToolWindow::proUpdate()
{
    EziDebugInstanceTreeItem *pitem = NULL ;
    UpdateDetectThread* pthread = NULL ;

    QMap<QString,EziDebugVlgFile*> ivlgFileMap ;
    QMap<QString,EziDebugVhdlFile*> ivhdlFileMap ;
    QList<EziDebugPrj::LOG_FILE_INFO*> iaddedinfoList ;
    QList<EziDebugPrj::LOG_FILE_INFO*> ideletedinfoList ;
    EziDebugPrj::SCAN_TYPE etype = EziDebugPrj::partScanType ;
    QStringList ideletedChainList ;

    if(!currentPrj)
    {   
#if 0
        QMessageBox::information(this, QObject::tr("全部更新"),QObject::tr("您所指定的工程不存在或者未设置工程参数!"));
#else
        QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("The project is not existed or the project parameter is NULL!"));
#endif
		
        return ;
    }

    // progress

    pthread = currentPrj->getThread() ;
    /*
      1、重新构建 工程 进行扫描
      2、发现有更新的文件，进行扫描
      3、更改工程参数 进行扫描  = 重建工程进行扫描 ; 这时候需要 根据 路径 对比结果 来判断， 然后析构前工程，再后创建新的工程
    */

    // 发现有更新的文件,进行全部更新
    if((currentPrj->getPrjVlgFileMap().count()!= 0)||(currentPrj->getPrjVhdlFileMap().count()!= 0))
    {
        if(isNeededUpdate)
        {
            listWindow->addMessage("info","EziDebug info: You can continue to update project!");
        }
        else
        {   
#if 0
            QMessageBox::information(this, QObject::tr("全部更新"),QObject::tr("无文件可更新!"));
#else
            QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("No file changed in project!"));
#endif
            progressBar->setValue(0);

            return ;
        }

        if(pthread->isRunning())
        {
            pthread->quit();
            pthread->wait();
        }

        // 5%
        progressBar->setValue(5);

        // 重新得到所有代码文件
        if(currentPrj->parsePrjFile(ivlgFileMap,ivhdlFileMap))
        {
            listWindow->addMessage("error","EziDebug error: parse project file Error!");

            QMap<QString,EziDebugVlgFile*>::iterator i =  ivlgFileMap.begin() ;
            while(i != ivlgFileMap.end())
            {
               EziDebugVlgFile* pfile = ivlgFileMap.value(i.key());
               if(pfile)
               {
                   delete pfile ;
               }
               ++i ;
            }
            ivlgFileMap.clear() ;

            // vhdl file pointer destruct
            QMap<QString,EziDebugVhdlFile*>::iterator j =  ivhdlFileMap.begin() ;
            while(j != ivhdlFileMap.end())
            {
               EziDebugVhdlFile* pfile = ivhdlFileMap.value(j.key());
               if(pfile)
               {
                   delete pfile ;
               }
               ++j ;
            }
            ivhdlFileMap.clear() ;

            delete currentPrj ;
            setCurrentProject(NULL);

            // 0%
#if 0
            QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
#else
            QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Update project failed -- The software interior error!"));
#endif

            progressBar->setValue(0);
            return ;
        }
        etype = EziDebugPrj::partScanType ;

        // 10%
        progressBar->setValue(10);

        // check deleted files
        currentPrj->checkDelFile(ivlgFileMap,ivhdlFileMap,ideletedinfoList);

        // clear up the related chainlist last time
        currentPrj->clearupCheckedChainList();
        currentPrj->clearupDestroyedChainList();

        // 15%
        progressBar->setValue(15);

        // scan file all over (can't find the deleted file)
        if(currentPrj->traverseAllCodeFile(etype ,ivlgFileMap , ivhdlFileMap ,iaddedinfoList,ideletedinfoList))
        {
            listWindow->addMessage("error","EziDebug error: traverse code file error !");

            QMap<QString,EziDebugVlgFile*>::iterator i =  ivlgFileMap.begin() ;
            while(i != ivlgFileMap.end())
            {
               EziDebugVlgFile* pfile = ivlgFileMap.value(i.key());
               if(pfile)
               {
                   delete pfile ;
               }
               ++i ;
            }
            ivlgFileMap.clear() ;

            // vhdl file pointer destruct
            QMap<QString,EziDebugVhdlFile*>::iterator j =  ivhdlFileMap.begin() ;
            while(j != ivhdlFileMap.end())
            {
               EziDebugVhdlFile* pfile = ivhdlFileMap.value(j.key());
               if(pfile)
               {
                   delete pfile ;
               }
               ++j ;
            }
            ivhdlFileMap.clear() ;

            delete currentPrj ;
            setCurrentProject(NULL);

            qDeleteAll(iaddedinfoList);
            qDeleteAll(ideletedinfoList);

#if 0
            QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
#else
            QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Update project failed -- The software interior error!"));
#endif
            // 0%
            progressBar->setValue(0);

            return ;
        }

        // 60%
        progressBar->setValue(60);

        // update file  map
        currentPrj->updateFileMap(ivlgFileMap,ivhdlFileMap);

        currentPrj->addToMacroMap();
        // 老的树状 头节点 置空
        currentPrj->setInstanceTreeHeadItem(NULL);


        QString itopModule = currentPrj->getTopModule() ;

        if(!currentPrj->getPrjModuleMap().contains(itopModule))
        {
            listWindow->addMessage("error","EziDebug error: There is no top module definition!");
            delete currentPrj ;
            setCurrentProject(NULL);

#if 0
            QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
#else
            QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Update project failed -- The software interior error!"));
#endif

            progressBar->setValue(0);

            return ;
        }

        QString itopModuleComboName = itopModule + QObject::tr(":")+ itopModule ;

        // 创建新的树状 头节点
        EziDebugInstanceTreeItem* pnewHeadItem = new EziDebugInstanceTreeItem(itopModule,itopModule);
        if(!pnewHeadItem)
        {
            listWindow->addMessage("error","EziDebug error: There is no memory left!");
            delete currentPrj ;
            setCurrentProject(NULL);

#if 0
            QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
#else
            QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Update project failed -- The software interior error!"));
#endif

            progressBar->setValue(0);

            return ;
        }

        // 65%
        progressBar->setValue(65);

        //  生成整个树的 节点
        if(currentPrj->traverseModuleTree(itopModuleComboName,pnewHeadItem))
        {
            listWindow->addMessage("error","EziDebug error: fast update failed!");

#if 0
            QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
#else
            QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Update project failed -- The software interior error!"));
#endif
			
            progressBar->setValue(0);
            return ;
        }

        // 75%
        progressBar->setValue(75);

        currentPrj->setInstanceTreeHeadItem(pnewHeadItem);

        if(currentPrj->getDestroyedChainList().count())
        {
            // 把所有破坏掉的链打印出来
            QString ichain ;
            QStringList idestroyedChainList = currentPrj->getDestroyedChainList() ;

            listWindow->addMessage("warning","EziDebug warning: Some chains are destroyed!");
            listWindow->addMessage("warning","the destroyed chains are:");
            for(int i = 0 ; i < idestroyedChainList.count() ;i++)
            {
                QString ichainName = idestroyedChainList.at(i) ;

                EziDebugInstanceTreeItem *pitem = currentPrj->getChainTreeItemMap().value(ichainName,NULL);
                if(pitem)
                {
                    ichain.append(tr("EziDebug chain:%1  topInstance:%2:%3").arg(ichainName)\
                                  .arg(pitem->getModuleName()).arg(pitem->getInstanceName())) ;
                }
                listWindow->addMessage("warning",ichain);
            }

            // 扫描链被破坏 ,提示删除
            #if 0
            QMessageBox::StandardButton rb = QMessageBox::question(this, tr("部分扫描链被破坏"), tr("是否删除相关扫描链代码"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
			#else
			QMessageBox::StandardButton rb = QMessageBox::question(this, tr("EziDebug"), tr("Some scan chains have been destroyed ,\n Do you want to delete all scan chain code ?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
			#endif
			
            if(rb == QMessageBox::Yes)
            {
                QStringList iunDelChainList = currentPrj->deleteDestroyedChain(iaddedinfoList,ideletedinfoList) ;
                if(iunDelChainList.count())
                {
                    listWindow->addMessage("error","EziDebug error: Some chains can not be deleted for some reasons!");
                    for(int i = 0 ; i < iunDelChainList.count() ;i++)
                    {
                        listWindow->addMessage("error",tr("EziDebug chain:%1").arg(iunDelChainList.at(i)));
                    }
                    listWindow->addMessage("error","EziDebug error: Please check the code file is compiled successfully or not!");
                }

                for(int i = 0 ; i < idestroyedChainList.count() ; i++)
                {
                    QString idestroyedChain = idestroyedChainList.at(i) ;
                    ideletedChainList.append(idestroyedChain);
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

        QStringList icheckChainList = currentPrj->checkChainExist();

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



        // 80%
        progressBar->setValue(80);

        if(currentPrj->changedLogFile(iaddedinfoList,ideletedinfoList))
        {
           listWindow->addMessage("info","EziDebug info: save log file failed!");
        }

        qDeleteAll(iaddedinfoList);
        qDeleteAll(ideletedinfoList);

        // 90%
        progressBar->setValue(90);

        currentPrj->cleanupChainTreeItemMap();
        currentPrj->cleanupBakChainTreeItemMap();

        if(currentPrj->getLastOperation() == EziDebugPrj::OperateTypeDelAllScanChain)
        {
            currentPrj->cleanupChainQueryTreeItemMap();
        }
        else
        {
            currentPrj->cleanupBakChainQueryTreeItemMap();
        }

        // 原来加入 链的节点 信息 导入
        currentPrj->updateTreeItem(pnewHeadItem);

        if(currentPrj->getLastOperation() == EziDebugPrj::OperateTypeDelAllScanChain)
        {
            // ChainTreeItemMap 存放新的节点map
            // 恢复 bakChainTreeItemMap 删除 ChainTreeItemMap

            // ChainQueryTreeItemMap 存放新的节点map
            // 恢复 bakChainQueryTreeItemMap 删除 ChainQueryTreeItemMap
            // update 用的 BakChainQueryTreeItemMap 放原始的、 ChainQueryTreeItemMap 放的新的
            currentPrj->cleanupBakChainQueryTreeItemMap();
            currentPrj->backupChainQueryTreeItemMap();
            currentPrj->cleanupChainQueryTreeItemMap();
        }
        else
        {
            // update 用的 ChainQueryTreeItemMap 放原始的、 bakChainQueryTreeItemMap 放新的
            currentPrj->cleanupChainQueryTreeItemMap();
            currentPrj->resumeChainQueryTreeItemMap();
            currentPrj->cleanupBakChainQueryTreeItemMap();
        }


        isNeededUpdate = false ;
        iChangeUpdateButtonTimer->stop();
        updatehintButton->setIcon(QIcon(":/images/update2.png"));
        updatehintButton->setDisabled(true);


        pthread->start();

        emit updateTreeView(pnewHeadItem);

        // 100%
        progressBar->setValue(100);

		#if 0
        QMessageBox::information(this, QObject::tr("全部更新"),QObject::tr("更新代码完毕！"));
		#else
		QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Update project finished!"));

		#endif


    }
    else
    {
        /*检查所需工程文件是否存在 0:存在 1:不存在*/
        if(!currentPrj->isPrjFileExist())
        {
            listWindow->addMessage("error","EziDebug error: The project file is not exist!");
            delete currentPrj ;
            setCurrentProject(NULL);

#if 0
            QMessageBox::warning(this, QObject::tr("全部更新失败"),QObject::tr("您所指定的工程文件不存在！"));
#else
            QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("Update Poject failed -- The project file is not existed!"));
#endif

            progressBar->setValue(0);

            return ;
        }
        // 2%
        progressBar->setValue(2);

        if(currentPrj->getCurrentDir().exists("config.ezi"))
        {
            currentPrj->setLogFileExistFlag(true);

            currentPrj->setLogFileName(currentPrj->getCurrentDir().absoluteFilePath("config.ezi")) ;

            if(currentPrj->parsePrjFile(ivlgFileMap,ivhdlFileMap))
            {
                listWindow->addMessage("error","EziDebug error: parse project file failed!");
                delete currentPrj ;
                setCurrentProject(NULL);
				
#if 0
                QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
#else
                QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Update Project failed -- The software interior error !"));
#endif
				
                progressBar->setValue(0);

                return ;
            }

            // 5%
            progressBar->setValue(5);

            if(currentPrj->detectLogFile(READ_CHAIN_INFO))
            {   
#if 0
                QMessageBox::StandardButton rb = QMessageBox::question(this, tr("log文件内部被破坏"), tr("是否删除内部可能存在的扫描链代码后再进行扫描"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
#else
                QMessageBox::StandardButton rb = QMessageBox::question(this, tr("EziDebug"), tr("EziDebug configuration file contains one or more errors ,\n Do you want to delete all scan chain codes before updating project ?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);

#endif

                if(rb == QMessageBox::Yes)
                {
                    // 遍历所有文件　删除可能存在的　EziDebug 代码
                    currentPrj->deleteAllEziDebugCode(ivlgFileMap,ivhdlFileMap);

                    QMap<QString,EziDebugScanChain*> ichainMap = currentPrj->getScanChainInfo();
                    QMap<QString,EziDebugScanChain*>::const_iterator k = ichainMap.constBegin() ;
                    while(k != ichainMap.constEnd())
                    {
                        EziDebugScanChain* pchain = k.value() ;
                        if(pchain)
                        {
                            delete pchain ;
                        }
                        ++k ;
                    }
                    currentPrj->cleanupChainMap();

                    // 原log文件 完全删除 无任何以前的信息
                    currentPrj->setLogFileExistFlag(false);

                }
            }

            // 删除　原log　文件
            QFile ilogFile(currentPrj->getCurrentDir().absoluteFilePath("config.ezi")) ;
            ilogFile.remove();

            // 如果　源　EziDebug_v1.0文件夹存在　 暂不删除

            // 重新　创建新log文件
            if(currentPrj->createLogFile())
            {
                listWindow->addMessage("error","EziDebug error: EziDebug configuration file is failed to create!");
                delete currentPrj ;
                setCurrentProject(NULL);

				#if 0
                QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
				#else
				QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Update Project failed -- The software interior error !"));
				#endif
				
                progressBar->setValue(0);

                return  ;
            }

            progressBar->setValue(10);

            etype = EziDebugPrj::fullScanType ;
        }
        else
        {
            // 不存在则创建文件
            if(currentPrj->createLogFile())
            {
                listWindow->addMessage("error","EziDebug error: EziDebug configuration file is failed to create!");
                delete currentPrj ;
                setCurrentProject(NULL);

				#if 0
                QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
				#else
				QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Update Project failed -- The software interior error !"));
				#endif
				
                progressBar->setValue(0);

                return  ;
            }
            // 5%
            progressBar->setValue(5);

            currentPrj->setLogFileName(currentPrj->getCurrentDir().absoluteFilePath("config.ezi")) ;

            if(currentPrj->parsePrjFile(ivlgFileMap,ivhdlFileMap))
            {
                listWindow->addMessage("error","EziDebug error: parse project file error !");
                QMap<QString,EziDebugVlgFile*>::iterator i =  ivlgFileMap.begin() ;
                while(i != ivlgFileMap.end())
                {
                   EziDebugVlgFile* pfile = ivlgFileMap.value(i.key());
                   if(pfile)
                   {
                       delete pfile ;
                   }
                   ++i ;
                }

                ivlgFileMap.clear() ;

                // vhdl file 指针析构
                QMap<QString,EziDebugVhdlFile*>::iterator j =  ivhdlFileMap.begin() ;
                while(j != ivhdlFileMap.end())
                {
                   EziDebugVhdlFile* pfile = ivhdlFileMap.value(j.key());
                   if(pfile)
                   {
                       delete pfile ;
                   }
                   ++j ;
                }
                ivhdlFileMap.clear() ;

                delete currentPrj ;
                setCurrentProject(NULL);
				
#if 0
                QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
#else
                QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Update Project failed -- The software interior error !"));
#endif
				
                progressBar->setValue(0);

                return ;
            }
            // 10%
            progressBar->setValue(10);

            etype = EziDebugPrj::partScanType ;
        }

#if 0
        QMessageBox::information(this, QObject::tr("扫描所有代码文件"),QObject::tr("准备获取module信息"));
#else
        QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("ready to get module information!"));
#endif

        if(currentPrj->traverseAllCodeFile(etype , ivlgFileMap , ivhdlFileMap ,iaddedinfoList,ideletedinfoList))
        {
            qDeleteAll(iaddedinfoList) ;
            qDeleteAll(ideletedinfoList) ;
            iaddedinfoList.clear();
            ideletedinfoList.clear();

            listWindow->addMessage("error","EziDebug error: traverse code file failed !");
            QMap<QString,EziDebugVlgFile*>::iterator i =  ivlgFileMap.begin() ;
            while(i != ivlgFileMap.end())
            {
                EziDebugVlgFile* pfile = ivlgFileMap.value(i.key());
                if(pfile)
                {
                    delete pfile ;
                }
                ++i ;
            }
            ivlgFileMap.clear() ;

            // vhdl file 指针析构
            QMap<QString,EziDebugVhdlFile*>::iterator j =  ivhdlFileMap.begin() ;
            while(j != ivhdlFileMap.end())
            {
                EziDebugVhdlFile* pfile = ivhdlFileMap.value(j.key());
                if(pfile)
                {
                    delete pfile ;
                }
                ++j ;
            }
            ivhdlFileMap.clear() ;


            delete currentPrj ;
            setCurrentProject(NULL);


            qDeleteAll(iaddedinfoList);
            qDeleteAll(ideletedinfoList);

#if 0
            QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
#else
            QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Project Update failed -- The software interior error !"));
#endif
            progressBar->setValue(0);

            return ;
        }


        currentPrj->updateFileMap(ivlgFileMap,ivhdlFileMap);

        currentPrj->addToMacroMap() ;
        listWindow->addMessage("info","EziDebug info: ready to traverse instances tree !");

        progressBar->setValue(65);

        if(currentPrj->getScanChainInfo().count())
        {
            currentPrj->backupChainMap();
            currentPrj->cleanupBakChainTreeItemMap();
            currentPrj->cleanupChainTreeItemMap();
        }

        if(currentPrj->generateTreeView())
        {
            listWindow->addMessage("error","EziDebug error: traverse instances tree error !");
            delete currentPrj ;
            setCurrentProject(NULL);
			
            #if 0
            QMessageBox::critical(this, QObject::tr("全部更新失败"),QObject::tr("软件内部错误！"));
			#else
			QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr(" Project Update failed -- The software interior error !"));
			#endif
			
            progressBar->setValue(0);

            return ;
        }

        progressBar->setValue(70);

        if(currentPrj->getBackupChainMap().count())
        {
            currentPrj->resumeChainMap();
            currentPrj->resumeChainTreeItemMap();
            // 用于清空 备份的 map
            currentPrj->updateOperation(EziDebugPrj::OperateTypeNone,NULL,NULL);
        }

        listWindow->addMessage("info","EziDebug info: finishing traverse instances tree !");

        pitem = currentPrj->getInstanceTreeHeadItem() ;

        EziDebugInstanceTreeItem::setProject(currentPrj);

        progressBar->setValue(75);

        // (代码中的扫描链 在 log文件中不存在  说明log文件曾经被破坏过!)
        if(currentPrj->getLogFileExistFlag()&&currentPrj->getLogfileDestroyedFlag())
        {
            // 提示删除所有链
            #if 0
            QMessageBox::StandardButton rb = QMessageBox::question(this, tr("部分扫描链信息丢失"), tr("是否删除所有扫描链代码"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
			#else
			QMessageBox::StandardButton rb = QMessageBox::question(this, tr("EziDebug"), tr("Some scan chain information have been lost, Do you want to delete all scan chain code ?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
			#endif
			
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

        progressBar->setValue(80);


        if(currentPrj->getDestroyedChainList().count())
        {
            // 把所有破坏掉的链打印出来
            QString ichain ;
            QStringList idestroyedChain = currentPrj->getDestroyedChainList() ;

            listWindow->addMessage("warning","EziDebug warning: Some chains are destroyed!");
            listWindow->addMessage("warning","the chain :");
            for(int i = 0 ; i < idestroyedChain.count() ;i++)
            {
                QString ichainName = idestroyedChain.at(i) ;

                EziDebugInstanceTreeItem *pitem = currentPrj->getChainTreeItemMap().value(ichainName);
                if(pitem)
                {
                    ichain.append(tr("EziDebug chain:%1  topInstance:%2:%3").arg(ichainName)\
                                  .arg(pitem->getModuleName()).arg(pitem->getInstanceName())) ;
                }
                listWindow->addMessage("warning",ichain);
            }

            // 扫描链被破坏 ,提示删除
            #if 0
            QMessageBox::StandardButton rb = QMessageBox::question(this, tr("部分扫描链被破坏"), tr("是否删除相关扫描链代码"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
            #else
			QMessageBox::StandardButton rb = QMessageBox::question(this, tr("EziDebug"), tr("Some scan chains have been destroyed ,Do you want to delete all the scan chain code?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
			#endif
			
			if(rb == QMessageBox::Yes)
            {
                QStringList iunDelChainList = currentPrj->deleteDestroyedChain(iaddedinfoList,ideletedinfoList) ;
                if(iunDelChainList.count())
                {
                    listWindow->addMessage("error","EziDebug error: Some chains can not be deleted for some reasons!");
                    for(int i = 0 ; i < iunDelChainList.count() ;i++)
                    {
                        listWindow->addMessage("error",tr("EziDebug chain:%1").arg(iunDelChainList.at(i)));
                    }
                    listWindow->addMessage("error","EziDebug error: Please check the code file is compiled successfully or not!");
                }
            }
        }
        progressBar->setValue(85);


        QMap<QString,EziDebugScanChain*>::const_iterator iaddedChainIter = currentPrj->getScanChainInfo().constBegin() ;
        while(iaddedChainIter !=  currentPrj->getScanChainInfo().constEnd())
        {
           QString ichainName = iaddedChainIter.key();
           struct EziDebugPrj::LOG_FILE_INFO* pinfo = new EziDebugPrj::LOG_FILE_INFO ;
           memcpy(pinfo->ainfoName ,ichainName.toAscii().data(),ichainName.size()+1);
           pinfo->pinfo = iaddedChainIter.value() ;
           pinfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
           iaddedinfoList << pinfo ;
           ++iaddedChainIter ;
        }

        // modify the project file at last
        currentPrj->preModifyPrjFile();

        progressBar->setValue(90);

        if(currentPrj->changedLogFile(iaddedinfoList,ideletedinfoList))
        {
            qDebug() << QObject::tr("保存log文件错误!");
        }

        qDeleteAll(iaddedinfoList);
        qDeleteAll(ideletedinfoList);

        pthread->start();

        emit updateTreeView(pitem);

        progressBar->setValue(100);

		#if 0
        QMessageBox::information(this, QObject::tr("全部更新"),QObject::tr("更新代码完毕！"));
		#else
		QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Project update  finished!"));
		#endif

    }
    progressBar->setValue(0);

}


int ToolWindow::deleteScanChain()
{
    EziDebugInstanceTreeItem * ptreeItem = NULL ;
    EziDebugScanChain *pchain = NULL ;
    UpdateDetectThread* pthread = NULL ;
    QList<EziDebugPrj::LOG_FILE_INFO*> iaddedinfoList ;
    QList<EziDebugPrj::LOG_FILE_INFO*> ideletedinfoList ;

    // 是否需要更新
    if(isNeededUpdate)
    {
        // 提示需要 请快速更新后再进行 操作
        #if 0
        QMessageBox::information(this, QObject::tr("删除扫描链"),QObject::tr("检测到有文件被更新,请更新后再进行删除"));
		#else
		QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Please update project before deleting scan chain !"));
		#endif

        return 0 ;
    }
    else
    {
        //
        UpdateDetectThread *pthread = currentPrj->getThread();
        pthread->update() ;
        if(isNeededUpdate)
        {   
            #if 0
            QMessageBox::information(this, QObject::tr("删除扫描链"),QObject::tr("检测到有文件被更新,请更新后再进行删除"));
			#else
			QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Please update project before deleting scan chain !"));
			#endif
			
            return 0 ;
        }
    }


    ptreeItem = listWindow->getCurrentTreeItem();
    if(!ptreeItem)
    {   
        #if 0
        QMessageBox::critical(this, QObject::tr("删除扫描链"),QObject::tr("软件内部错误！"));
		#else
		QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Delete scan chain failed -- The software interior error!"));
		#endif
		
        return 1;
    }

    pchain = ptreeItem->getScanChainInfo();
    if(!pchain)
    {   
        #if 0
        QMessageBox::critical(this, QObject::tr("删除扫描链"),QObject::tr("软件内部错误！"));
		#else 
		QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Delete scan chain failed -- The software interior error!"));
		#endif
		
        return 1;
    }


    pchain->backupFileList();

    pchain->clearupFileList();


    // 停止检测更新   退出线程
    pthread = currentPrj->getThread() ;
    if(pthread->isRunning())
    {
        pthread->quit();
        pthread->wait();
    }

    if(!ptreeItem->deleteScanChain(EziDebugPrj::OperateTypeDelSingleScanChain))
    {
        /*对上一步操作进行善后*/
        if(currentPrj->eliminateLastOperation())
        {
            listWindow->addMessage("error","EziDebug error: delete last chain error!");
			
			#if 0
            QMessageBox::critical(this, QObject::tr("删除扫描链"),QObject::tr("软件内部错误！"));
			#else
			QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Delete scan chain failed -- The software interior error!"));

			#endif

            return  1 ;
        }

        /*更新上一步操作*/
        currentPrj->updateOperation(EziDebugPrj::OperateTypeDelSingleScanChain,pchain,ptreeItem);

        /*将扫描链 从 链 map 取下来*/
        currentPrj->eliminateChainFromMap(pchain->getChainName());

        /*将扫描链 从 树状节点 map 取下来*/
        currentPrj->eliminateTreeItemFromMap(pchain->getChainName());

        /*重置节点下 链指针*/
        ptreeItem->setScanChainInfo(NULL);

        /*删除用于查询的 map*/
        currentPrj->eliminateTreeItemFromQueryMap(ptreeItem->getNameData());

        /*改动 log 文件 */
        struct EziDebugPrj::LOG_FILE_INFO* pdelChainInfo = new EziDebugPrj::LOG_FILE_INFO ;
        memcpy(pdelChainInfo->ainfoName,pchain->getChainName().toAscii().data(),pchain->getChainName().size()+1);
        pdelChainInfo->pinfo = NULL ;
        pdelChainInfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
        ideletedinfoList << pdelChainInfo ;

        QStringList iscanFileList = pchain->getScanedFileList() ;

        for(int i = 0 ; i < iscanFileList.count() ; i++)
        {
            QString ifileName = iscanFileList.at(i) ;
            QString irelativeFileName = currentPrj->getCurrentDir().relativeFilePath(ifileName);

            // 文件被修改了 需要重新保存文件日期
            struct EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
            pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
            pdelFileInfo->pinfo = NULL ;
            memcpy(pdelFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
            ideletedinfoList.append(pdelFileInfo);

            struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
            paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;


            if(irelativeFileName.endsWith(".v"))
            {
                EziDebugVlgFile *pvlgFile = currentPrj->getPrjVlgFileMap().value(irelativeFileName,NULL);
                paddFileInfo->pinfo = pvlgFile ;
            }
            else if(irelativeFileName.endsWith(".vhd"))
            {
                EziDebugVhdlFile *pvhdlFile = currentPrj->getPrjVhdlFileMap().value(irelativeFileName,NULL);
                paddFileInfo->pinfo = pvhdlFile ;
            }
            else
            {
                delete paddFileInfo ;
                continue ;
            }

            memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data(), irelativeFileName.size()+1);
            iaddedinfoList.append(paddFileInfo);
        }


        if(currentPrj->changedLogFile(iaddedinfoList,ideletedinfoList))
        {
            // 提示 保存 log 文件出错
            qDebug() << tr("保存log文件出错") ;
        }

//        // 根据链的个数 删除创建的自定义core文件
//        if(!currentPrj->getScanChainInfo().count())
//        {
//            // 删除 创建的文件夹
//            QDir idir(currentPrj->getCurrentDir().absolutePath() + EziDebugScanChain::getUserDir());
//            idir.remove(EziDebugScanChain::getChainRegCore()+tr(".v"));
//            idir.remove(EziDebugScanChain::getChainToutCore()+tr(".v"));
//            currentPrj->getCurrentDir().rmdir(idir.absolutePath());
//        }


        qDeleteAll(ideletedinfoList);
        qDeleteAll(iaddedinfoList);

        pthread->start();

		#if 0
        QMessageBox::information(this, QObject::tr("删除扫描链"),QObject::tr("删除扫描链成功！"));
		#else
		QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Delete scan chain successfully!"));

		#endif

    }
    else
    {
        /*读取删除链 已经扫描过的文件,从已经备份的文件进行恢复*/
        for(int i = 0 ; i < pchain->getScanedFileList().count();i++)
        {
            // 获取备份的文件名全称
            QString ifileName = pchain->getScanedFileList().at(i) ;
            QFileInfo ifileInfo(pchain->getScanedFileList().at(i));
            QString ieziDebugFileSuffix ;
            ieziDebugFileSuffix.append(QObject::tr(".delete.%1").arg(currentPrj->getLastOperateChain()->getChainName()));

            QString ibackupFileName = currentPrj->getCurrentDir().absolutePath() \
                    + EziDebugScanChain::getUserDir() + ifileInfo.fileName() \
                    + ieziDebugFileSuffix;
            QFile ibackupFile(ibackupFileName) ;

            QFileInfo ibakfileInfo(ibackupFileName);
            QDateTime idateTime = ibakfileInfo.lastModified();
            // 已经是绝对路径了

            // 更改时间
            QString irelativeName = currentPrj->getCurrentDir().relativeFilePath(ifileName) ;

            if(ibakfileInfo.exists())
            {
                if(ifileName.endsWith(".v"))
                {
                    currentPrj->getPrjVlgFileMap().value(irelativeName)->remove();
                    ibackupFile.copy(ifileName);
                    currentPrj->getPrjVlgFileMap().value(irelativeName)->modifyStoredTime(idateTime);
                }
                else if(ifileName.endsWith(".vhd"))
                {
                    currentPrj->getPrjVlgFileMap().value(irelativeName)->remove();
                    ibackupFile.copy(ifileName);
                    currentPrj->getPrjVlgFileMap().value(irelativeName)->modifyStoredTime(idateTime);
                }
                else
                {
                    // do nothing
                }
                // 删除当前备份的文件
                ibackupFile.remove();
            }
        }

        pchain->resumeFileList();

        qDeleteAll(ideletedinfoList);
        qDeleteAll(iaddedinfoList);

        pthread->start();

		#if 0
        QMessageBox::warning(this, QObject::tr("删除扫描链"),QObject::tr("删除扫描链失败！"));
		#else
		QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("Delete scan chain failed!"));
		#endif

        return 1;
    }

    return 0 ;
}

void ToolWindow::addScanChain()
{
    EziDebugInstanceTreeItem * ptreeItem = NULL ;
    EziDebugModule* pmodule = NULL ;
    UpdateDetectThread* pthread = NULL ;
    QList<EziDebugPrj::LOG_FILE_INFO*> iaddedinfoList ;
    QList<EziDebugPrj::LOG_FILE_INFO*> ideletedinfoList ;
    QMap<QString,int> iregNumMap ;
    bool isrepeatFlag = false ;
    QString ichainName = tr("chn") ;
    int nresult = 0 ;
    int i = 0 ;


    // 是否需要更新
    if(isNeededUpdate)
    {
        // 提示需要 请快速更新后再进行 操作
        #if 0
        QMessageBox::information(0, QObject::tr("添加扫描链"),QObject::tr("检测到有文件被更新,请更新后再进行添加链!"));
        #else
		QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Please update project before inserting scan chain !"));
		#endif
		
        return ;
    }
    else
    {
        //
        UpdateDetectThread *pthread = currentPrj->getThread();
        pthread->update() ;
        if(isNeededUpdate)
        {   
            #if 0
            QMessageBox::information(0, QObject::tr("添加扫描链"),QObject::tr("检测到有文件被更新,请更新后再进行添加链!"));
			#else
		    QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Please update project before inserting scan chain !"));
			#endif
			
            return ;
        }
    }

    ptreeItem = listWindow->getCurrentTreeItem();
    if(!ptreeItem)
    {
        /*向文本栏提示 添加链错误 该节点不存在*/
		
        listWindow->addMessage("error","EziDebug error: The tree item is not exist!");

		#if 0
        QMessageBox::critical(this, QObject::tr("添加扫描链"),QObject::tr("软件内部错误!"));
		#else
		QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain failed -- The software interior error!"));
		#endif

        return ;
    }

    if(currentPrj->getPrjModuleMap().contains(ptreeItem->getModuleName()))
    {
        pmodule =  currentPrj->getPrjModuleMap().value(ptreeItem->getModuleName());
        if(!pmodule)
        {
            /*向文本栏提示 添加链错误 该节点对应的module无定义*/
            listWindow->addMessage("error", tr("EziDebug error: the module:%1 object is null !").arg(ptreeItem->getModuleName()));
			
			#if 0
            QMessageBox::critical(this, QObject::tr("添加扫描链"),QObject::tr("软件内部错误!"));
			#else
			QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain failed -- The software interior error!"));
			#endif

            return ;
        }
    }
    else
    {
        /*向文本栏提示 添加链错误 该节点对应的module无定义*/
        listWindow->addMessage("error", tr("EziDebug error: the module:").arg(ptreeItem->getModuleName()) + tr("has no definition!"));

		#if 0
        QMessageBox::critical(this, QObject::tr("添加扫描链"),QObject::tr("软件内部错误!"));
		#else
		QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain failed -- The software interior error!"));
		#endif

        return ;
    }
    //QString iinstanceName = ptreeItem->getInstanceName() ;

    /*判断扫描链名字是否重复*/
    isrepeatFlag = currentPrj->getScanChainInfo().contains(ichainName) ;
    while(isrepeatFlag)
    {
        ichainName = tr("chn") + tr("%1").arg(i) ;
        isrepeatFlag = currentPrj->getScanChainInfo().contains(ichainName) ;
        i++ ;
    }

    if((pmodule->getLocatedFileName()).endsWith(".v"))
    {
        QMap<QString,EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE *> ichainListStructureMap ;
        int nmaxRegNum = currentPrj->getMaxRegNumPerChain() ;
        EziDebugVlgFile* pvlgFile =  currentPrj->getPrjVlgFileMap().value(pmodule->getLocatedFileName());
//      EziDebugInstanceTreeItem *pparent = ptreeItem->parent();
        EziDebugModule* pmodule = currentPrj->getPrjModuleMap().value(ptreeItem->getModuleName()) ;
        EziDebugScanChain * pscanChain = new EziDebugScanChain(ichainName);
        pscanChain->traverseAllInstanceNode(ptreeItem) ;
        pscanChain->traverseChainAllReg(ptreeItem) ;
        QMap<QString,QString>::const_iterator i =  pmodule->getClockSignal().constBegin() ;

        //1、遍历树状结构 先查找有几个clock 分别计算每个 clock 下面 寄存器 个数,
        // 从右键 选择的 顶层节点开始 往下一层层遍历
        while(i != pmodule->getClockSignal().constEnd())
        {
            //QString iclock = pparent->getModuleClockMap().value(i.key());
            int nbitWidth  = 0  ;
            /*获得当前节点的clock名字*/
            int nregBitCount = 0 ;
            ptreeItem->getAllRegNum(i.key() ,ichainName, nregBitCount , nbitWidth , pscanChain->getInstanceItemList());
            if((!nregBitCount) && (!nbitWidth))
            {
                listWindow->addMessage("warning", tr("EziDebug warning: There is no register with clock:%1 in the chain:%2").arg(i.key()).arg(ichainName));
                ++i;
                continue ;
            }
            iregNumMap.insert(i.key(),nbitWidth*currentPrj->getMaxRegNumPerChain()+nregBitCount);
            nbitWidth++ ;
            
            // 根据设置的 最大链个数 得到要 每个 clock 要 分配的 TDI、TDO 位宽  ,加入到对应的 map 中

            EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE *pchainStructure = (EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE *)operator new(sizeof(EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE));
            pchainStructure->m_uncurrentChainNumber = 0 ;
            pchainStructure->m_untotalChainNumber = nbitWidth ;
            pchainStructure->m_unleftRegNumber = nmaxRegNum ;


            ichainListStructureMap.insert(i.key(),pchainStructure);
            ++i ;

        }

        if(!ichainListStructureMap.count())
        {
            listWindow->addMessage("warning", tr("EziDebug warning: There is no register in the chain!"));
            delete pscanChain ;
			
			#if 0
            QMessageBox::warning(this, QObject::tr("添加扫描链"),QObject::tr("添加扫描链失败!"));
			#else
			QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain failed!"));
			#endif

            return  ;
        }


        QMap<QString,EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE *>::const_iterator iscanchain = ichainListStructureMap.constBegin();
        while(iscanchain != ichainListStructureMap.constEnd())
        {
            // parent clock(key) -> child clock(value)
            
            QString iclock = ptreeItem->parent()->getModuleClockMap(ptreeItem->getInstanceName()).key(iscanchain.key(),QString());
            if(iclock.isEmpty())
            {
                listWindow->addMessage("warning", tr("EziDebug warning: can't find the module %1 's clock ,insert scan chain failed !").arg(ptreeItem->getModuleName()));
                delete pscanChain ;
				
				#if 0
                QMessageBox::critical(this, QObject::tr("添加扫描链"),QObject::tr("添加扫描链失败!"));
				#else
				QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain failed!"));
				#endif

                return ;
            }
            EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE * pchainSt = iscanchain.value();
            pscanChain->setChildChainNum(iclock,pchainSt->m_untotalChainNumber);
            ++iscanchain ;
        }

        //2、创建相应的用户module core
        // 如果是第一次加入扫描链 则需要创建  或者 误删除掉了 则重新添加自定义 module
        if(!currentPrj->getScanChainInfo().count())
        {
            if(pvlgFile->createUserCoreFile(currentPrj))
            {
                delete pscanChain ;
                listWindow->addMessage("warning", tr("EziDebug error: create EziDebug core error!"));
				
				#if 0
                QMessageBox::critical(this, QObject::tr("添加扫描链"),QObject::tr("软件内部错误!"));
				#else
				QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain failed -- The software interior error!"));
				#endif

                return ;
            }
        }
        else
        {
            /*误删除 1、使用过程中 2、没有使用时就删除掉了  在扫描log文件时就没有相应的*/
        }

        /*遍历链状树，计算 每个module 在扫描连中例化的次数*/
        //ptreeItem->traverseChainTreeItem();

        /*在插入扫描链之前 清空扫描过的文件列表*/
        pscanChain->clearupFileList();

        // 插入扫描链之前  停止检测更新   退出线程
        pthread = currentPrj->getThread() ;
        if(pthread->isRunning())
        {
            pthread->quit();
            pthread->wait();
        }



        // m_pheadItem
        pscanChain->setHeadTreeItem(ptreeItem);

        if(!(nresult = ptreeItem->insertScanChain(ichainListStructureMap,pscanChain,ptreeItem->getInstanceName())))
        {
            if(currentPrj->eliminateLastOperation())
            {
                listWindow->addMessage("error", tr("EziDebug error: delete last chain error!"));

				#if 0
                QMessageBox::critical(this, QObject::tr("添加扫描链"),QObject::tr("软件内部错误!"));
				#else
	            QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain failed -- The software interior error!"));
				#endif

                return ;
            }

            /*更新上一步操作*/
            currentPrj->updateOperation(EziDebugPrj::OperateTypeAddScanChain,pscanChain,ptreeItem);

            /*将新添加的 扫描链加入 到 prj 的 的 map 中*/
            currentPrj->addToChainMap(pscanChain);

            /*加入到 树状节点 map 中*/
            currentPrj->addToTreeItemMap(pscanChain->getChainName(),ptreeItem);

            /*加入到 用于查询 的 节点 map 中*/
            currentPrj->addToQueryItemMap(ptreeItem->getNameData(),ptreeItem);

            /* 重置 节点下 链指针 */
            ptreeItem->setScanChainInfo(pscanChain);

            /*保存各个时钟寄存器 总数 信息*/
            QMap<QString,int>::const_iterator iclkRegNumIter = iregNumMap.constBegin();
            while(iclkRegNumIter != iregNumMap.constEnd())
            {
                QString ichainClock = pscanChain->getChainClock(ptreeItem->getInstanceName(),iclkRegNumIter.key());
                pscanChain->setChainRegCount(ichainClock,iclkRegNumIter.value());
                ++iclkRegNumIter ;
            }

            struct EziDebugPrj::LOG_FILE_INFO* pinfo = new EziDebugPrj::LOG_FILE_INFO ;
            memcpy(pinfo->ainfoName ,pscanChain->getChainName().toAscii().data(),pscanChain->getChainName().size()+1);
            pinfo->pinfo = pscanChain ;
            pinfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
            iaddedinfoList << pinfo ;

            pscanChain->removeScanedFileListDuplicate();
            for(int i = 0 ; i < pscanChain->getScanedFileList().count() ; i++)
            {
                // 文件被修改了 需要重新保存文件日期

                QString ifileName = pscanChain->getScanedFileList().at(i) ;

                struct EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                pdelFileInfo->pinfo = NULL ;

                qstrcpy(pdelFileInfo->ainfoName,currentPrj->getCurrentDir().relativeFilePath(ifileName).toAscii().data()) ;
                ideletedinfoList.append(pdelFileInfo);

                struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;

                if(ifileName.endsWith(".v"))
                {
                    paddFileInfo->pinfo = currentPrj->getPrjVlgFileMap().value(currentPrj->getCurrentDir().relativeFilePath(ifileName)) ;
                }
                else if(ifileName.endsWith(".vhd"))
                {
                    paddFileInfo->pinfo = currentPrj->getPrjVhdlFileMap().value(currentPrj->getCurrentDir().relativeFilePath(ifileName)) ;
                }
                else
                {
                    qDeleteAll(iaddedinfoList);
                    qDeleteAll(ideletedinfoList);
                    pthread->start();

                    listWindow->addMessage("warning", tr("EziDebug warning: detect the unknown file!"));
                    continue ;
                }
                qstrcpy(pdelFileInfo->ainfoName,currentPrj->getCurrentDir().relativeFilePath(ifileName).toAscii().data()) ;
                iaddedinfoList.append(paddFileInfo);
            }


            if(currentPrj->changedLogFile(iaddedinfoList,ideletedinfoList))
            {
                qDebug() << tr("Warnning:addScanChain Save Log File Error!");
            }

            qDeleteAll(iaddedinfoList);
            qDeleteAll(ideletedinfoList);

            listWindow->addMessage("info","EziDebug info: Create a new scan chain!");
            QStandardItem * pitem = listWindow->addMessage("info",tr("The New ScanChain Parameter:"));
            listWindow->addMessage("process" , tr("      The chain name: %1").arg(pscanChain->getChainName()),pitem);
            listWindow->addMessage("process" , tr("      The chain topNode: %1").arg(ptreeItem->getNameData()),pitem);
            QString iclockNumStr ;
            QString itraversedInstStr ;
            QMap<QString,QVector<QStringList> > iregChain = pscanChain->getRegChain();
            QMap<QString,QVector<QStringList> >::const_iterator iregChainIter = iregChain.constBegin() ;
            while( iregChainIter != iregChain.constEnd())
            {
                iclockNumStr.append(tr("%1 (%2)     ").arg(pscanChain->getChainRegCount(iregChainIter.key())).arg(iregChainIter.key()));
                ++iregChainIter ;
            }

            listWindow->addMessage("process" , tr("      The total register number of chain: %1").arg(iclockNumStr),pitem);

            listWindow->addMessage("process" , tr("      The traversed NodeList:"),pitem);

            for(int j = 0 ; j < pscanChain->getInstanceItemList().count() ;j++)
            {
                if(j == 0)
                {
                    itraversedInstStr.append("  ->  ");
                }
                if(j == (pscanChain->getInstanceItemList().count()-1))
                {
                    itraversedInstStr.append(pscanChain->getInstanceItemList().at(j)) ;
                }
                else
                {
                    itraversedInstStr.append(pscanChain->getInstanceItemList().at(j) + tr("  ->  ")) ;
                }
                if((j+1)%3 == 0)
                {
                    listWindow->addMessage("process" , tr("      ") + itraversedInstStr,pitem);
                    itraversedInstStr.clear();
                }
            }

            if(!itraversedInstStr.isEmpty())
            {
                listWindow->addMessage("process" , tr("      ") + itraversedInstStr,pitem);
            }

            /*加入扫描链成功后 ，去使能 树状节点的 右键菜单中 添加链功能*/
//          listWindow->m_paddChainAct->setEnabled(false);
//          listWindow->m_pdeleteChainAct->setEnabled(true);

            // 向工程文件中加入 新添加的文件
            // "EziDebug_1.0/_EziDebug_ScanChainReg.v"
            // "EziDebug_1.0/_EziDebug_TOUT_m.v"
            // 单纯修改 restore 文件无效  必须手工添加 工程文件
            nresult = currentPrj->chkEziDebugFileInvolved() ;
            if(nresult == 0)
            {   
                #if 0
                QMessageBox::information(this , QObject::tr("EziDebug") , QObject::tr("请将当前工程路径下EziDebug_v1.0目录下的文件加入到工程中!"));
				#else
				QMessageBox::information(this , QObject::tr("EziDebug") , QObject::tr("Please add the source files under \"EziDebug_v1.0\" directory to your project"
				                                                                      "Before you synthetize the project!"));
				#endif
            }
            else if(nresult == -1)
            {
                listWindow->addMessage("error" , tr("EziDebug Error:Please check project file!"));
            }
            else
            {
                //
            }


            // 生成 signaltap 文件 或者 cdc 文件
            currentPrj->createCfgFile(ptreeItem);

            listWindow->addMessage("info",tr("EziDebug info: Before you synthetize the project ,Please "
                                             "add the source files under \"EziDebug_v1.0\" directory to your project!"));

            //qDebug() << "add Scan Chain Success !";

            pthread->start();

			#if 0
            QMessageBox::information(this, QObject::tr("添加扫描链"),QObject::tr("添加扫描链成功!"));
			#else
			QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain successfully!"));
			#endif

        }
        else
        {

            /*读取删除链 已经扫描过的文件,从已经备份的文件中恢复*/
            for(int i = 0 ; i < pscanChain->getScanedFileList().count();i++)
            {
                // 获取备份的文件名全称
                QString ifileName = pscanChain->getScanedFileList().at(i) ;
                QFileInfo ifileInfo(ifileName);
                QString ieziDebugFileSuffix ;

                ieziDebugFileSuffix.append(QObject::tr(".add.%1").arg(pscanChain->getChainName()));

                QString ibackupFileName = currentPrj->getCurrentDir().absolutePath() \
                        + EziDebugScanChain::getUserDir()+ tr("/")+ ifileInfo.fileName() \
                        + ieziDebugFileSuffix;
                QFile ibackupFile(ibackupFileName) ;
                QFileInfo ibakfileInfo(ibackupFileName);
                QDateTime idateTime = ibakfileInfo.lastModified();
                // 已经是绝对路径了

                // 更改时间
                QString irelativeName = currentPrj->getCurrentDir().relativeFilePath(ifileName) ;

                if(ibakfileInfo.exists())
                {
                    if(ifileName.endsWith(".v"))
                    {
                        currentPrj->getPrjVlgFileMap().value(irelativeName)->remove();
                        ibackupFile.copy(ifileName);
                        currentPrj->getPrjVlgFileMap().value(irelativeName)->modifyStoredTime(idateTime);
                    }
                    else if(ifileName.endsWith(".vhd"))
                    {
                        currentPrj->getPrjVlgFileMap().value(irelativeName)->remove();
                        ibackupFile.copy(ifileName);
                        currentPrj->getPrjVlgFileMap().value(irelativeName)->modifyStoredTime(idateTime);
                    }
                    else
                    {
                        // do nothing
                    }
                    // 删除当前备份的文件
                    ibackupFile.remove();
                }
            }

            pscanChain->setHeadTreeItem(NULL);

            /*删除新创建的扫描链*/
            delete pscanChain ;

            qDeleteAll(iaddedinfoList);
            qDeleteAll(ideletedinfoList);

            pthread->start();

            if(nresult == 2)
            {
                listWindow->addMessage("error" , tr("The top clock is not found for the clock name is not corresponding!"));
				
				#if 0
                QMessageBox::warning(this, QObject::tr("添加扫描链"),QObject::tr("添加扫描链失败!"));
				#else
				QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain failed!"));
				#endif
				
                return ;
            }
            goto ErrorHandle ;
        }
    }
    else if((pmodule->getLocatedFileName()).endsWith(".vhd"))
    {
        //currentPrj->m_ivhdlFileMap ;
    }
    else
    {

    }

    return ;

ErrorHandle:
	
	#if 0
    QMessageBox::critical(this, QObject::tr("添加扫描链"),QObject::tr("添加扫描链失败!"));
	#else
	QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Insert scan chain failed!"));
	#endif

    return ;

}

int ToolWindow::deleteAllChain()
{
    //EziDebugScanChain *plastChain = NULL ;
    QMap<QString,EziDebugInstanceTreeItem*> ichainTreeItemMap ;
    UpdateDetectThread* pthread = NULL ;
    QList<EziDebugPrj::LOG_FILE_INFO*> iaddedinfoList ;
    QList<EziDebugPrj::LOG_FILE_INFO*> ideletedinfoList ;
    QStringList ifileList  ;

    //qDebug() << "deleteAllChain";


    if(!currentPrj)
    {   
#if 0
        QMessageBox::information(this, QObject::tr("删除所有扫描链"),QObject::tr("工程不存在!"));
#else
        QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("The project is not existed , please set the project parameter first !"));
#endif
        return 0 ;
    }

    // 是否需要更新
    if(isNeededUpdate)
    {
        // 提示需要 请快速更新后再进行 操作
        #if 0
        QMessageBox::information(this, QObject::tr("删除所有扫描链"),QObject::tr("检测到有文件被更新,检测到有文件被更新,请更新后再进行删除所有链操作!"));
		#else
	    QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Please update project before you delete all scan chains !"));
		#endif
        return 0 ;
    }
    else
    {
        //
        UpdateDetectThread *pthread = currentPrj->getThread();
        pthread->update() ;
        if(isNeededUpdate)
        {   
            #if 0
            QMessageBox::information(this, QObject::tr("删除所有扫描链"),QObject::tr("检测到有文件被更新,请更新后再进行删除所有链操作!"));
			#else
			QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Please update project before you delete all scan chains !"));
			#endif
            return 0 ;
        }
    }


    // 从扫描链 获取所有的 链信息
    ichainTreeItemMap = currentPrj->getChainTreeItemMap() ;

    if(!ichainTreeItemMap.size())
    {   
        #if 0
        QMessageBox::information(this, QObject::tr("删除所有扫描链"),QObject::tr("不存在任何扫描链!"));
		#else
		QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Delete all scan chain failed -- There is no scan chain!"));
		#endif
        return 0 ;
    }
    //QMap<QString,EziDebugScanChain*> ichainMap = currentPrj->getScanChainInfo();

    /*成功删除所有链之后 删除上一步操作 备份的文件*/
//    plastChain = currentPrj->getLastOperateChain() ;
//    QStringList iscanFileList = plastChain->getScanedFileList() ;

    /*对所有树状节点 备份 针对 undo  deleteAllChain 操作*/
    currentPrj->backupChainTreeItemMap();

    /*对所有链进行备份*/
    currentPrj->backupChainMap();

    //
    currentPrj->backupChainQueryTreeItemMap();

    QMap<QString,EziDebugScanChain*>::const_iterator ibakiterator = currentPrj->getBackupChainMap().constBegin();

    // 删除扫描链之前  停止检测更新   退出线程
    pthread = currentPrj->getThread() ;
    if(pthread->isRunning())
    {
        pthread->quit();
        pthread->wait();
    }

    QMap<QString,EziDebugInstanceTreeItem*>::const_iterator i = ichainTreeItemMap.constBegin();
    QMap<QString,EziDebugInstanceTreeItem*>::const_iterator backup = i ;
    while(i != ichainTreeItemMap.constEnd())
    {
        EziDebugInstanceTreeItem * ptreeItem = i.value();
        if(!ptreeItem)
        {
            pthread->start();
			#if 0
            QMessageBox::critical(this, QObject::tr("删除所有扫描链"),QObject::tr("软件内部错误!"));
			#else 
			QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Delete all scan chain failed -- The software interior error!"));
			#endif
            return 1;
        }

        EziDebugScanChain *pchain = ptreeItem->getScanChainInfo();
        if(!pchain)
        {
            pthread->start();
			#if 0
            QMessageBox::critical(this, QObject::tr("删除所有扫描链"),QObject::tr("软件内部错误!"));
			#else
			QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Delete all scan chain failed -- The software interior error!"));
			#endif
            return 1;
        }

        pchain->backupFileList();

        pchain->clearupFileList();


        if(!ptreeItem->deleteScanChain(EziDebugPrj::OperateTypeDelAllScanChain))
        {
           /*重置节点下 链指针*/
           ptreeItem->setScanChainInfo(NULL);
        }
        else
        {
            backup = i ;
            /*如果在删除扫描链过程中 出现错误*/
            goto ErrorHandle;
        }
        ++i ;
    }


    if(currentPrj->eliminateLastOperation())
    {
        qDebug() << tr("删除上一次链错误");
        pthread->start();
        //QMessageBox::critical(this, QObject::tr("删除所有扫描链"),QObject::tr("软件内部错误!"));

        goto ErrorHandle;
    }


    /*更新上一步操作*/
    currentPrj->updateOperation(EziDebugPrj::OperateTypeDelAllScanChain,NULL,NULL);

    /*清空 treeItemMap*/
    currentPrj->cleanupChainTreeItemMap();

    /*清空 chainMap*/
    currentPrj->cleanupChainMap();

    // 全部删除 按键 去使能
    while(ibakiterator != currentPrj->getBackupChainMap().constEnd())
    {
        QString ichainName = ibakiterator.key() ;
        EziDebugScanChain *pchain = ibakiterator.value();
        struct EziDebugPrj::LOG_FILE_INFO* pinfo = new EziDebugPrj::LOG_FILE_INFO ;
        qstrcpy(pinfo->ainfoName,ichainName.toAscii().data());
        pinfo->pinfo = NULL ;
        pinfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
        ideletedinfoList << pinfo ;

        QStringList iscanFileList = pchain->getScanedFileList() ;

        for(int i = 0 ; i < iscanFileList.count() ; i++)
        {
            QString ifileName = iscanFileList.at(i) ;
            if(!ifileList.contains(ifileName))
            {
                ifileList << ifileName ;
                QString irelativeFileName = currentPrj->getCurrentDir().relativeFilePath(ifileName);

                // 文件被修改了 需要重新保存文件日期
                struct EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                pdelFileInfo->pinfo = NULL ;
                memcpy(pdelFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
                ideletedinfoList.append(pdelFileInfo);

                struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;


                if(irelativeFileName.endsWith(".v"))
                {
                    EziDebugVlgFile *pvlgFile = currentPrj->getPrjVlgFileMap().value(irelativeFileName,NULL);
                    paddFileInfo->pinfo = pvlgFile ;
                }
                else if(irelativeFileName.endsWith(".vhd"))
                {
                    EziDebugVhdlFile *pvhdlFile = currentPrj->getPrjVhdlFileMap().value(irelativeFileName,NULL);
                    paddFileInfo->pinfo = pvhdlFile ;
                }
                else
                {
                    delete paddFileInfo ;
                    continue ;
                }

                memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data(), irelativeFileName.size()+1);
                iaddedinfoList.append(paddFileInfo);
            }
        }
        ++ibakiterator;
    }

    if(currentPrj->changedLogFile(iaddedinfoList,ideletedinfoList))
    {
        // 提示 保存 log 文件出错
        qDebug() << "Error:Save log info Error In delete all chain!";
    }

    qDeleteAll(iaddedinfoList);
    qDeleteAll(ideletedinfoList);

    // 开启检测更新线程
    pthread->start();

	#if 0
    QMessageBox::information(this, QObject::tr("删除所有扫描链"),QObject::tr("删除所有扫描链成功!"));
	#else
	QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Delete scan chain successfully!"));
	#endif

    return 0 ;

ErrorHandle:

    /*恢复 treeItemMap*/
    currentPrj->resumeChainTreeItemMap();

    /*恢复 chainMap*/
    currentPrj->resumeChainMap();

    i = ichainTreeItemMap.constBegin();
    {
        /*将chain指针加入到 树状节点下面*/
        EziDebugInstanceTreeItem* pitem = i.value() ;
        EziDebugScanChain * plastChain = currentPrj->getScanChainInfo().value(i.key());
        pitem->setScanChainInfo(plastChain);
        plastChain->resumeFileList();

        /*读取删除链 已经扫描过的文件,从已经备份的文件中恢复*/
        for(int p = 0 ; p < plastChain->getScanedFileList().count();p++)
        {
            // 获取备份的文件名全称
            QFileInfo ifileInfo(plastChain->getScanedFileList().at(p));
            QString ieziDebugFileSuffix ;

            ieziDebugFileSuffix.append(QObject::tr(".deleteall"));

            QString ibackupFileName = currentPrj->getCurrentDir().absolutePath() \
                    + EziDebugScanChain::getUserDir() + ifileInfo.fileName() \
                    + ieziDebugFileSuffix;
            QFile ibackupFile(ibackupFileName) ;

            // 已经是绝对路径了
            ibackupFile.copy(plastChain->getScanedFileList().at(p));

            // 删除当前备份的文件
            ibackupFile.remove();
        }


        i++ ;
    }while(i != backup)

    qDeleteAll(iaddedinfoList);
    qDeleteAll(ideletedinfoList);

    // 开启检测更新线程
    pthread->start();
	#if 0
    QMessageBox::warning(this, QObject::tr("删除所有扫描链"),QObject::tr("删除所有扫描链失败!"));
	#else
	QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("Delete all scan chain failed!"));
	#endif

    return 1 ;
}

void ToolWindow::testbenchGeneration()
{
    qDebug() << "testbenchGeneration!" ;
    QString ichainName ;
    QStringList idataFileNameList ;
    QString ioutputDirectory ;
    UpdateDetectThread* pthread ;

    QList<TextQuery::module_top*> inoutList;
    QList<TextQuery::sample*> isampleList ;
    QList<TextQuery::system_port*> isysinoutList ;
    QVector<QList<TextQuery::regchain*> > ichainVec ;
    QMap<int,QString> ifileMap ;
    QMap<int,QString>::const_iterator ifileMapIter ;

    TextQuery::FPGA_Type ifgpaType ;

    QString iclockPortName ;
    QString iresetPortName ;

    ImportDataDialog::EDGE_TYPE eresetType ;
    TextQuery::EDGE_TYPE eresetTypeLast ;
    QString iresetSigVal ;


    if(!currentPrj)
    {   
#if 0
        QMessageBox::warning(this, QObject::tr("生成testBench"),QObject::tr("工程不存在，请进行设置工程参数并进行扫描!"));
#else
        QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("The project is not existed , please set the project parameter !"));
#endif
        return ;
    }

    if(!currentPrj->getScanChainInfo().count())
    {   
#if 0
        QMessageBox::warning(this, QObject::tr("生成testBench"),QObject::tr("不存在任何扫描链!"));
#else
        QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("There is no scan chain in project!"));
#endif
        return ;
    }

    //QMessageBox::information(this, QObject::tr("undo 操作"),QObject::tr("目前只支持对相邻的上一步操作的取消!"));
    //undoOperation();
    // Qt::WA_DeleteOnClose
    ImportDataDialog *idataDialg = new ImportDataDialog(currentPrj->getChainTreeItemMap(),this);
    if(idataDialg->exec())
    {
        qDebug() << "generate test bench" << "chainName:" << idataDialg->getChainName() \
                 << "fileName:" << idataDialg->getDataFileName();
        ichainName = idataDialg->getChainName() ;
        ifileMap = idataDialg->getFileIndexMap() ;

        for(int i = 0 ; i < ifileMap.count() ;i++)
        {
            if(!ifileMap.value(i,QString()).isEmpty())
            {
                QString ifileName = ifileMap.value(i);
                if(currentPrj->getToolType() == EziDebugPrj::ToolIse)
                {
                    if(!ifileName.endsWith(".prn"))
                    {   
                        #if 0
                        QMessageBox::warning(this, QObject::tr("生成testBench"),QObject::tr("数据文件格式不正确!"));
						#else
						QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("The data file type is not correct!"));
						#endif
                        return ;
                    }
                }
                else if(currentPrj->getToolType() == EziDebugPrj::ToolQuartus)
                {
                    if(!ifileName.endsWith(".txt"))
                    {   
                        #if 0
                        QMessageBox::warning(this, QObject::tr("生成testBench"),QObject::tr("数据文件格式不正确!"));
						#else
						QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("The data file type is not correct!"));
						#endif

                        return ;
                    }
                }
                else
                {   
                    #if 0
                    QMessageBox::warning(this, QObject::tr("生成testBench"),QObject::tr("工具软件类型不正确!"));
					#else
					QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("The tool type is not correct!"));
					#endif
                    return ;
                }
                idataFileNameList.append(ifileName);
            }
        }

        ioutputDirectory = idataDialg->getOutputDirectory() ;

        idataDialg->getResetSig(iresetPortName,eresetType,iresetSigVal);

        EziDebugScanChain *pchain = currentPrj->getScanChainInfo().value(idataDialg->getChainName(),NULL);
        if(!pchain)
        {   
            #if 0
            QMessageBox::critical(this, QObject::tr("生成testBench"),QObject::tr("%1 不存在!").arg(idataDialg->getChainName()));
			#else
			QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("The scan chain \"%1\" is not existed!").arg(idataDialg->getChainName()));
			#endif
			
            return ;
        }

        EziDebugInstanceTreeItem * pitem = currentPrj->getChainTreeItemMap().value(ichainName ,NULL);
        if(!pitem)
        {   
            #if 0
            QMessageBox::critical(this, QObject::tr("生成testBench"),QObject::tr("%1 对应的节点不存在!").arg(idataDialg->getChainName()));
			#else
			QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("The node \"%1\" is not existed!").arg(idataDialg->getChainName()));
			#endif
            return ;
        }

        listWindow->addMessage("info","EziDebug info: Generating TestBench !");
        QStandardItem * pmessageitem = listWindow->addMessage("info","EziDebug info: The input and output parameters are as follows:");
        listWindow->addMessage("process",tr("%1ChainName: %2").arg(tr(" ").repeated(6)).arg(ichainName),pmessageitem);

        for(int j = 0 ; j < idataFileNameList.count() ; j++)
        {
            QString ifileName = idataFileNameList.at(j) ;
            listWindow->addMessage("process",tr("%1FileName: %2").arg(tr(" ").repeated(6)).arg(QDir::toNativeSeparators(ifileName)),pmessageitem);
        }

        listWindow->addMessage("process",tr("%1Output directory: %2").arg(tr(" ").repeated(6)).arg(QDir::toNativeSeparators(ioutputDirectory)),pmessageitem);




        // tdo tout
        EziDebugModule *pmodule = currentPrj->getPrjModuleMap().value(pitem->getModuleName(),NULL);

        QMap<QString,QString>::const_iterator iclockiter = pmodule->getClockSignal().constBegin() ;
        while(iclockiter != pmodule->getClockSignal().constEnd())
        {
            QString icombinedName ;
            QString iclock = iclockiter.key() ;
			
            QString ichainClock = pitem->parent()->getModuleClockMap(pitem->getInstanceName()).key(iclock,QString());
            int nchildChainNum =  pitem->getScanChainInfo()->getChildChainNum(ichainClock);

            QString itdoPortName(QObject::tr("_EziDebug_%1_%2_tdo_r").arg(pitem->getScanChainInfo()->getChainName()).arg(iclock));
            if(nchildChainNum > 1)
            {
                icombinedName = itdoPortName + QObject::tr("[%1:0]").arg(nchildChainNum -1);
            }
            else
            {
                icombinedName = itdoPortName ;
            }

            struct TextQuery::sample* psample = (struct TextQuery::sample*)malloc(sizeof(struct TextQuery::sample)) ;
            memset((void*)psample,0,sizeof(struct TextQuery::sample));

            psample->sample_name = (char*) malloc(icombinedName.size()+1);
            memset((void*)psample->sample_name,0,icombinedName.size()+1);
            qstrcpy(psample->sample_name , icombinedName.toAscii().constData());

            *(psample->sample_name + icombinedName.size()) = '\0' ;

            if(nchildChainNum > 1)
            {
                psample->width_first = nchildChainNum -1 ;
                psample->width_second = 0 ;
            }
            else
            {
                psample->width_first = 0 ;
                psample->width_second = 0 ;
            }


            isampleList.append(psample);

            ++iclockiter ;
        }


        struct TextQuery::sample* psample = (struct TextQuery::sample*)malloc(sizeof(struct TextQuery::sample)) ;
        memset((void*)psample,0,sizeof(struct TextQuery::sample));
        //_EziDebug_%1_TOUT_reg
        QString itoutPortName = QObject::tr("_EziDebug_%1_tout_r").arg(pitem->getScanChainInfo()->getChainName());
        psample->sample_name = (char*)malloc(itoutPortName.size()+1);
        memset((void*)psample->sample_name,0,itoutPortName.size()+1);

        qstrcpy(psample->sample_name , itoutPortName.toAscii().constData());
        *(psample->sample_name + itoutPortName.size()) = '\0' ;

        psample->width_first = 0 ;
        psample->width_second = 0 ;

        isampleList.append(psample);

        // port
        QVector<EziDebugModule::PortStructure*> iportVec = pmodule->getPort(currentPrj , pitem->getInstanceName()) ;
        for(int i = 0 ; i < iportVec.count() ;i++)
        {
            EziDebugModule::PortStructure*  pmodulePort = iportVec.at(i) ;
            QString iportName = QString::fromAscii(pmodulePort->m_pPortName);

            struct TextQuery::module_top* pport = (struct TextQuery::module_top*)malloc(sizeof(struct TextQuery::module_top)) ;
            memset((void*)pport,0,(sizeof(struct TextQuery::module_top)));

            pport->port_name = (char*)malloc(strlen(pmodulePort->m_pPortName)+1);
            memset((void*)pport->port_name,0,(strlen(pmodulePort->m_pPortName)+1));

            strncpy(pport->port_name,pmodulePort->m_pPortName,strlen(pmodulePort->m_pPortName)+1);

            if(pmodulePort->eDirectionType == EziDebugModule::directionTypeInput)
            {
                pport->inout = 1 ;
            }
            else if(pmodulePort->eDirectionType == EziDebugModule::directionTypeOutput)
            {
                pport->inout = 0 ;
            }
            else
            {

            }

            pport->width_first = pmodulePort->m_unStartBit ;
            pport->width_second = pmodulePort->m_unEndBit ;

            inoutList.append(pport);

            if(!(pmodule->getClockSignal().value(iportName,QString())).isEmpty())
            {
                iclockPortName = iportName ;
                continue ;
            }

#if 0
            if(!(pmodule->getResetSignal().value(iportName,QString())).isEmpty())
            {
                iresetName = iportName ;
                continue ;
            }
#endif


            if(iresetPortName == iportName)
            {
                continue ;
            }

            struct TextQuery::sample* psample = (struct TextQuery::sample*)malloc((sizeof(struct TextQuery::sample)/4+1)*4) ;
            memset((void*)psample,0,(sizeof(struct TextQuery::sample)/4+1)*4);

            // strlen(pmodulePort->m_pPortName + 1)
            psample->sample_name = (char*)malloc(strlen(pmodulePort->m_pPortName) +1);
            memset((void*)psample->sample_name,0,(strlen(pmodulePort->m_pPortName) + 1));
            strcpy(psample->sample_name,pmodulePort->m_pPortName);


            psample->width_first = pmodulePort->m_unStartBit ;
            psample->width_second = pmodulePort->m_unEndBit ;

            isampleList.append(psample);

        }

        // memory fifo
        QStringList isysPortList = pchain->getSyscoreOutputPortList() ;
        for(int i = 0 ; i < isysPortList.count() ; i++)
        {
            QString ihierarchicalName = isysPortList.at(i).split("#").at(0);
            QString iportName = isysPortList.at(i).split("#").at(1);
            QString iregName = isysPortList.at(i).split("#").at(2);
            int nbitWidth = isysPortList.at(i).split("#").at(3).toInt();


            QRegExp ireplaceRegExp(QObject::tr("\\b\\w*:"));

            struct TextQuery::system_port* pport = (struct TextQuery::system_port*)malloc(sizeof(struct TextQuery::system_port)) ;
            memset((void*)pport,0,sizeof(struct TextQuery::system_port));

            iportName.replace("|",".");
            iportName.replace(ireplaceRegExp,"");


            pport->port_name = (char*)malloc(iportName.size()+1);
            pport->reg_name = (char*)malloc(iregName.size()+1);
            memset((void*)pport->port_name,0,iportName.size()+1);
            memset((void*)pport->reg_name,0,iregName.size()+1);

            strcpy(pport->port_name,iportName.toAscii().constData());
            *(pport->port_name +iportName.size()) = '\0' ;
            strcpy(pport->reg_name,iregName.toAscii().constData());
            *(pport->reg_name +iregName.size()) = '\0' ;

            pport->width_first = nbitWidth -1 ;
            pport->width_second = 0 ;

            isysinoutList.append(pport);

            struct TextQuery::sample* psample = (struct TextQuery::sample*)malloc(sizeof(struct TextQuery::sample)) ;
            memset((void*)psample,0,sizeof(struct TextQuery::sample));

            psample->sample_name = (char*) malloc(iregName.size() + 1);
            memset((void*)psample->sample_name,0,iregName.size() + 1);
            strcpy(psample->sample_name , iregName.toAscii().constData());
            *(psample->sample_name + iregName.size()) = '\0' ;

            psample->width_first = nbitWidth -1 ;
            psample->width_second = 0 ;

            isampleList.append(psample);
        }


        // tdo  _EziDebug_%1_%2_TDO_reg

        //EziDebugModule *pmodule = currentPrj->getPrjModuleMap().value(pitem->getModuleName(),NULL);


        // 采样 寄存器
        // "reg" << sample_table[i].sample_name  << "_temp[1:`DATA_WIDTH]
        // reglist
        QMap<QString,QVector<QStringList> > iregChainMap = pchain->getRegChain();
        QMap<QString,QVector<QStringList> >::const_iterator iregChainIter = iregChainMap.constBegin() ;
        while(iregChainIter != iregChainMap.constEnd())
        {
            QVector<QStringList> iregList = iregChainIter.value();
            for(int i = 0 ; i < iregList.count() ; i++)
            {
                QStringList iregChainStr = iregList.at(i) ;
                QList<TextQuery::regchain*> iregChainList ;
                for(int j = 0 ; j < iregChainStr.count() ; j++)
                {
                    QString iregStr = iregChainStr.at(j);
                    QString ireghiberarchyName = iregStr.split("#").at(3) ;
                    QString iregName = iregStr.split("#").at(4);

                    int nstartBit = iregStr.split("#").at(5).toInt();
                    int nendBit = iregStr.split("#").at(6).toInt();

                    struct TextQuery::regchain* pregChain = (struct TextQuery::regchain*)malloc(sizeof(struct TextQuery::regchain)) ;
                    memset((char*)pregChain ,0 ,sizeof(struct TextQuery::regchain));

                    int nstartPos = ireghiberarchyName.indexOf(tr("%1:%2").arg(pitem->getModuleName()).arg(pitem->getInstanceName()));
                    ireghiberarchyName = ireghiberarchyName.mid(nstartPos);
                    ireghiberarchyName.replace(QRegExp(tr("\\w+:")),"");
                    ireghiberarchyName.replace("|",".");
                    nstartPos = ireghiberarchyName.indexOf(".");
                    ireghiberarchyName = ireghiberarchyName.mid(nstartPos+1);
                    QString icombinedName = tr("%1%2").arg(ireghiberarchyName).arg(iregName);

                    pregChain->reg_name = (char*)malloc(icombinedName.size()+1);
                    memset((char*)pregChain->reg_name ,0 ,icombinedName.size()+1);
                    strcpy(pregChain->reg_name,icombinedName.toAscii().data());
                    *(pregChain->reg_name+icombinedName.size()) = '\0' ;

                    pregChain->width_first = nstartBit ;
                    pregChain->width_second = nendBit ;

                    iregChainList.append(pregChain);
                }
                ichainVec.append(iregChainList);
            }
            ++iregChainIter ;
        }

        if(currentPrj->getToolType() == EziDebugPrj::ToolQuartus)
        {
            ifgpaType = TextQuery::Altera ;
        }
        else
        {
            ifgpaType = TextQuery::Xilinx ;
        }

        //pitem->getModuleName(),idataFileName,ioutputDirectory ,
        TextQuery itest(pitem->getModuleName(),idataFileNameList , ioutputDirectory , inoutList ,isampleList ,ichainVec , isysinoutList ,ifgpaType) ;


        eresetTypeLast = static_cast<TextQuery::EDGE_TYPE>(eresetType);

        itest.setNoNeedSig(iclockPortName , iresetPortName , eresetTypeLast ,iresetSigVal);

        // 插入扫描链之前  停止检测更新   退出线程
        pthread = currentPrj->getThread() ;

        if(pthread->isRunning())
        {
            pthread->quit();
            pthread->wait();
        }


        itest.doit();

        pthread->start();

        qDebug() << "Generate testBench finish !" << __LINE__ ;

        listWindow->addMessage("info","EziDebug info: Finishing generating testBench file!");



        // 释放内存
        // malloc 用 free 释放

        int nfreecount = 0 ;

        for(;nfreecount < inoutList.count(); nfreecount++)
        {
            TextQuery::module_top* pmodule = inoutList.at(nfreecount) ;
            char * pportName = pmodule->port_name ;

            free(pportName);
            pportName = NULL ;


            free((char*)pmodule);
            pmodule = NULL ;
        }

        for(nfreecount = 0 ; nfreecount < isampleList.count(); nfreecount++)
        {
            TextQuery::sample *psample = isampleList.at(nfreecount) ;
            char* psampleName = psample->sample_name ;

            free(psampleName) ;
            psampleName = NULL ;
            free((char*)psample);
            psample = NULL ;
        }

        for(nfreecount = 0 ; nfreecount < isysinoutList.count(); nfreecount++)
        {
            TextQuery::system_port* pport = isysinoutList.at(nfreecount) ;
            char *pportName = pport->port_name ;
            char *pregName = pport->reg_name ;
            free(pportName);
            pportName = NULL ;
            free(pregName);
            pregName = NULL ;
            free((char*)pport);
            pport = NULL ;
        }

        for(nfreecount = 0 ; nfreecount < ichainVec.count() ; nfreecount++)
        {
            int nregcount = 0 ;
            QList<TextQuery::regchain*> iregChainList = ichainVec.at(nfreecount) ;
            for(;nregcount < iregChainList.count() ; nregcount++)
            {
                TextQuery::regchain* pregChain = iregChainList.at(nregcount);
                char* pregName = pregChain->reg_name ;
                free(pregName);
                pregName = NULL ;
                free((char*)pregChain);
                pregChain = NULL ;
            }
        }

		#if 0
        QMessageBox::information(this, QObject::tr("生成testBench"),QObject::tr("testBench生成完毕!"));
		#else
		QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("The testbench is generated successfully!"));
		#endif

    }
    else
    {
        qDebug() << "do nothing!" ;
    }
}

void ToolWindow::miniWindowMinimized()
{
    miniSizeAction->setDisabled(true);
    restoreWinAction->setDisabled(false);
}

//进度条演示
void ToolWindow::progressBarDemo()
{
    //    QProgressDialog progressDialog(this);
//    progressDialog.setCancelButtonText(tr("取消"));
//    progressDialog.setRange(0, 100);
//    progressDialog.setWindowTitle(tr("进度条"));


    for (int i = 0; i < 100; ++i) {
        progressBar->setValue(i);
        //progressBarsetLabelText(tr("进度为 %1 / %2...")
                                   // .arg(i).arg(100));
        qApp->processEvents();


//        if (progressDialog.wasCanceled()){
//            //添加取消时的工作
//            break;
//        }

        for (int j = 0; j < 100000000; ++j);
    }
}

const EziDebugPrj* ToolWindow::getCurrentProject(void) const
{
    return  currentPrj ;
}

void ToolWindow::setCurrentProject(EziDebugPrj* prj)
{
    currentPrj = prj ;
    return ;
}

void  ToolWindow::listwindowInfoInit(void)
{
    listWindow->welcomeinfoinit(currentPrj);
}

void ToolWindow::setListWindowAdsorbedFlag(bool flag)
{
    isListWindowAdsorbed = flag ;
}

void ToolWindow::createButtons()
{
    //工具栏按钮
    // projectSetting AprojectSetting
//    proSettingButton = new Button(tr(":/images/projectSetting4.bmp"), this);
//    proSettingButton->setIconSize(QSize(30, 29));
//    connect(proSettingButton, SIGNAL(clicked()), this, SLOT(proSetting()));
//    proSettingButton->setToolTip(tr("工程设置"));

//    proUpdateButton = new Button(tr(":/images/projectUpdate4.bmp"), this);
//    proUpdateButton->setIconSize(QSize(30, 29));
//    connect(proUpdateButton, SIGNAL(clicked()), this, SLOT(proUpdate()));
//    proUpdateButton->setToolTip(tr("更新"));

//    proPartlyUpdateButton = new Button(tr(":/images/"), this);
//    proPartlyUpdateButton->setIconSize(QSize(30, 29));
//    connect(proPartlyUpdateButton, SIGNAL(clicked()), this, SLOT(fastUpdate()));
//    proPartlyUpdateButton->setToolTip(tr("部分更新"));

//    deleteChainButton = new Button(tr(":/images/deleteChain4.bmp"), this);
//    deleteChainButton->setIconSize(QSize(30, 29));
//    connect(deleteChainButton, SIGNAL(clicked()), this, SLOT(deleteAllChain()));
//    deleteChainButton->setToolTip(tr("删除"));

//    proUndoButton = new Button(tr(":/images/undo4.bmp"), this);
//    proUndoButton->setIconSize(QSize(30, 29));
//    connect(proUndoButton, SIGNAL(clicked()), this, SLOT(undoOperation()));
//    proUndoButton->setToolTip(tr("撤销"));

//    testbenchGenerationButton = new Button(tr(":/images/testbenchGeneration4.bmp"), this);
//    testbenchGenerationButton->setIconSize(QSize(30, 29));
//    connect(testbenchGenerationButton, SIGNAL(clicked()), this, SLOT(testbenchGeneration()));
//    testbenchGenerationButton->setToolTip(tr("testbench生成"));



    //工具栏按钮
    //tr("工程设置")
    proSettingButton = createToolButton(tr("Project parameter settings  "),
                                        tr(":/images/projectSetting.bmp"),
                                        QSize(42, 41),
                                        this,
                                        SLOT(proSetting()));
    // tr("更新")
    proUpdateButton = createToolButton(tr("Update"),
                                       tr(":/images/projectUpdate.bmp"),
                                       QSize(42, 41),
                                       this,
                                       SLOT(proUpdate()));

	// tr("部分更新")
    proPartlyUpdateButton = createToolButton(tr("Update fast"),
                                       tr(":/images/projectPartlyUpdate.bmp"),
                                       QSize(42, 41),
                                       this,
                                       SLOT(fastUpdate()));

	// tr("删除")
    deleteChainButton = createToolButton(tr("Delete all scan chain"),
                                         tr(":/images/deleteChain.bmp"),
                                         QSize(42, 41),
                                         this,
                                         SLOT(deleteAllChain()));

	// tr("Testbench生成")
    testbenchGenerationButton = createToolButton(tr("Testbench Generation "),
                                                 tr(":/images/testbenchGeneration.bmp"),
                                                 QSize(42, 41),
                                                 this,
                                                 SLOT(testbenchGeneration()));
    // tr("撤消")
    proUndoButton = createToolButton(tr("Undo"),
                                                 tr(":/images/undo.bmp"),
                                                 QSize(42, 41),
                                                 this,
                                                 SLOT(undoOperation()));


    //右上角标题栏按钮
    // tr("最小化")
    minimizeButton = createToolButton(tr("Minimize"),
                                      tr(":/images/ToolWindowminimize.bmp"),
                                      QSize(27, 19),
                                      this,
                                      SLOT(minimize()));

	// tr("迷你模式")
    miniModeButton = createToolButton(tr("Mini mode"),
                                      tr(":/images/ToolWindowNormal.bmp"),
                                      QSize(27, 19),
                                      this,
                                      SLOT(toMiniMode()));
     // tr("完整模式")
    showListWindowButton = createToolButton(tr("Normal mode"),
                                            tr(":/images/showListWindow.bmp"),
                                            QSize(27, 19),
                                            this,
                                            SLOT(showListWindow()));

	// tr("退出")
    exitButton = createToolButton(tr("Quit"),
                                  tr(":/images/ToolWindowExit.bmp"),
                                  QSize(33, 19),
                                  this,
                                  SLOT(close()));


}

void ToolWindow::createActions()
{   
    #if 0
    exitAct = new QAction(tr("退  出"), this);
	#else
	exitAct = new QAction(tr("Quit"), this);
	#endif
	
    exitAct->setShortcuts(QKeySequence::Quit);
    //exitAct->setStatusTip(tr("退出"));
    connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));

	#if 0
    minimizeAct = new QAction(tr("最小化"), this);
	#else
	minimizeAct = new QAction(tr("Minimize"), this);
	#endif
    //minimizeAct->setShortcuts(QKeySequence::);
    //minimizeAct->setStatusTip(tr("Exit the application"));
    connect(minimizeAct, SIGNAL(triggered()), this, SLOT(minimize()));

	#if 0
    toMiniModeAct = new QAction(tr("迷你模式"), this);
	#else
	toMiniModeAct = new QAction(tr("Mini mode"), this);
	#endif
    //normalAct->setShortcuts(QKeySequence::Quit);
    //normalAct->setStatusTip(tr("Exit the application"));
    connect(toMiniModeAct, SIGNAL(triggered()), this, SLOT(toMiniMode()));

	#if 0
    aboutAct = new QAction(tr("关 于..."),this);
	#else
	aboutAct = new QAction(tr("About..."),this);
	#endif
    connect(aboutAct,SIGNAL(triggered()),this,SLOT(about()));

	#if 0
    helpAct = new QAction(tr("帮  助"),this);
	#else
	helpAct = new QAction(tr("Help"),this);
	#endif
    connect(helpAct,SIGNAL(triggered()),this,SLOT(help()));

}

//创建系统托盘的右键菜单
void ToolWindow::CreatTrayMenu()
{   
    #if 0
    miniSizeAction = new QAction(tr("最小化"),this);
    maxSizeAction = new QAction(tr("最大化"),this);
    restoreWinAction = new QAction(tr("还  原"),this);
    quitAction = new QAction(tr("退  出"),this);
    aboutAction = new QAction(tr("关 于..."),this);
    helpAction = new QAction(tr("帮  助"),this);
	#else
	miniSizeAction = new QAction(tr("Minimize"),this);
    maxSizeAction = new QAction(tr("Maximize"),this);
    restoreWinAction = new QAction(tr("Resume to normal mode"),this);
    quitAction = new QAction(tr("Quit"),this);
    aboutAction = new QAction(tr("About..."),this);
    helpAction = new QAction(tr("Help"),this);
	#endif

    this->connect(miniSizeAction,SIGNAL(triggered()),this,SLOT(minimize()));
    this->connect(maxSizeAction,SIGNAL(triggered()),this,SLOT(showMaximized()));
    this->connect(restoreWinAction,SIGNAL(triggered()),this,SLOT(showNormal()));
    this->connect(quitAction,SIGNAL(triggered()),qApp,SLOT(quit()));
    this->connect(aboutAction,SIGNAL(triggered()),this,SLOT(about()));
    this->connect(helpAction,SIGNAL(triggered()),this,SLOT(help()));

    myMenu = new QMenu((QWidget*)QApplication::desktop());

    myMenu->addAction(miniSizeAction);
    miniSizeAction->setDisabled(false);
    myMenu->addAction(maxSizeAction);
    maxSizeAction->setDisabled(true);
    myMenu->addAction(restoreWinAction);
    restoreWinAction->setDisabled(false);
    myMenu->addSeparator();     //加入一个分离符
    myMenu->addAction(aboutAction);
    aboutAction->setDisabled(false);
    myMenu->addAction(helpAction);
    helpAction->setDisabled(false);
    myMenu->addSeparator();     //加入一个分离符
    myMenu->addAction(quitAction);
}

//创建系统托盘图标
void ToolWindow::creatTrayIcon()
{
    CreatTrayMenu();

    if (!QSystemTrayIcon::isSystemTrayAvailable())      //判断系统是否支持系统托盘图标
    {
        return ;
    }

    myTrayIcon = new QSystemTrayIcon(this);

    QPixmap objPixmap(tr(":/images/EziDebugIcon.bmp"));
    QPixmap iconPix;

//    iconPix = objPixmap.copy(0, 0, 127, 120);//.scaled(21, 20);
//    iconPix.setMask(QPixmap(tr(":/images/EziDebugIconMask.bmp")));

    objPixmap.setMask(QPixmap(tr(":/images/EziDebugIconMask.bmp")));
    iconPix = objPixmap.copy(0, 0, 127, 104).scaled(21, 20);
    myTrayIcon->setIcon(iconPix);   //设置图标图片
    setWindowIcon(iconPix);  //把图片设置到窗口上

    myTrayIcon->setToolTip("EziDebug");    //托盘时，鼠标放上去的提示信息

    myTrayIcon->showMessage("EziDebug", "Hi,This is my EziDebug.",QSystemTrayIcon::Information,10000);



    myTrayIcon->setContextMenu(myMenu);     //设置托盘上下文菜单

    myTrayIcon->show();
    this->connect(myTrayIcon,SIGNAL(activated(QSystemTrayIcon::ActivationReason)),this,SLOT(iconActivated(QSystemTrayIcon::ActivationReason)));
}


Button *ToolWindow::createToolButton(const QString &toolTip, const QString &iconstr,
                                    const QSize &size, const QObject * receiver, const char *member)
{
    Button *button = new Button(iconstr, this);
    button->setToolTip(toolTip);
    //button->setIcon(icon);
    button->setIconSize(size);//(QSize(10, 10));
    // button->setSizeIncrement(size);
    //button->setSizePolicy(size.width(), size.height());
    button->setFlat(true);
    connect(button, SIGNAL(clicked()), receiver, member);

//    Button *button = new Button(this);

//    button->setToolTip(toolTip);
//    //button->setIcon(icon);
//    button->setIconSize(size);//(QSize(10, 10));
//    // button->setSizeIncrement(size);
//    //button->setSizePolicy(size.width(), size.height());
//    button->setFlat(true);
//    connect(button, SIGNAL(clicked()), receiver, member);

    return button;
}

//重载各个事件
void ToolWindow::contextMenuEvent(QContextMenuEvent *event)
{
    QMenu menu(this);
    menu.addAction(minimizeAct);
    menu.addAction(toMiniModeAct);
    menu.addAction(aboutAct);
    menu.addAction(helpAct);
    menu.addSeparator();
    menu.addAction(exitAct);
    menu.exec(event->globalPos());
}

void ToolWindow::mousePressEvent(QMouseEvent * event)
{

//    static int i = 0 ;
//    qDebug()<<"mouse Press Event"<<i++ ;
    if (event->button() == Qt::LeftButton) //点击左边鼠标
    {
        //globalPos()获取根窗口的相对路径，frameGeometry().topLeft()获取主窗口左上角的位置
//        dragPosition = event->globalPos() - frameGeometry().topLeft();
        dragPosition = event->globalPos() - geometry().topLeft();
        oriGlobalPos = event->globalPos() - listWindow->geometry().topLeft();

        event->accept();   //鼠标事件被系统接收
    }
//        if (event->button() == Qt::RightButton)
//        {
//             close();
//        }
}

void ToolWindow::mouseMoveEvent(QMouseEvent * event)
{

//    qDebug()<<"mouse Move Event"<< event->globalX()<< event->globalY() ;
//    qDebug()<<"mouse Move Event"<<event->pos().x()<<event->pos().y() ;
//    qDebug()<< this->pos().x()<< this->pos().y()<< this->geometry().left() \
//            << this->geometry().bottom() <<this->width() << this->height();
//    qDebug()<< listWindow->isListWindowHidden()<< isListWindowAdsorbed ;

    if (event->buttons() == Qt::LeftButton) //当满足鼠标左键被点击时。
    {
        move(event->globalPos() - dragPosition);//移动窗口
        if((!listWindow->isListWindowHidden()) &&
                (listWindow->windowIsStick()))
        {
            listWindow->move(event->globalPos() - oriGlobalPos);//移动
        }
        event->accept();
    }
}

void ToolWindow::paintEvent(QPaintEvent *)
{
    QPainter painter(this);//创建一个QPainter对象
    painter.drawPixmap(0,0,QPixmap(":/images/Watermelon.png"));//绘制图片到窗口
    /*
      QPixmap(":/images/Watermelon.png")如果改为QPixmap()，则只能看到绘制出的框架，看不到图片颜色，也就是看不到图片。
    */
}

void ToolWindow::showEvent(QShowEvent* event)
{
//    qDebug() << "toolwindow show event!";
//    readSetting() ;
//    return ;
}

void ToolWindow::readSetting()
{
    int  nparameterFlag  = PARAMETER_OK ;
    UpdateDetectThread * pthread = NULL ;
    EziDebugPrj::TOOL etool = EziDebugPrj::ToolOther ;
    QSettings isettings("EDA Center.", "EziDebug");
    // 获取工程参数，如果有就创建工程对象；没有的话，不创建
    isettings.beginGroup("project");
    unsigned int unMaxRegNum = isettings.value("MaxRegNum").toInt();
    QString idir = isettings.value("dir").toString();
    QString itool = isettings.value("tool").toString();
    bool isXilinxERRChecked = isettings.value("isXilinxERRChecked").toBool();
    isettings.endGroup();

    if(idir.isEmpty())
    {
        nparameterFlag |=  NO_PARAMETER_DIR ;
        qDebug() << "EziDebug Info: No the Dir parameter!" ;
    }


    if(ZERO_REG_NUM == unMaxRegNum)
    {
        nparameterFlag |=  NO_PARAMETER_REG_NUM ;
        qDebug() << "EziDebug Info: No Reg Num parameter!" ;
    }


    if(itool.isEmpty())
    {
        nparameterFlag |=  NO_PARAMETER_TOOL ;
        qDebug() << "EziDebug Info: No the Tool parameter!" ;
    }
    else
    {
        if(!itool.compare("quartus"))
        {
            etool =  EziDebugPrj::ToolQuartus ;
        }
        else if(!itool.compare("ise"))
        {
            etool =  EziDebugPrj::ToolIse ;
        }
        else
        {
            nparameterFlag |=  NO_PARAMETER_TOOL ;
        }
    }

    if(nparameterFlag)
    {
        if(nparameterFlag == NO_PARAMETER_ALL)
        {
            //没有使用过软件
            qDebug() << "EziDebug Info:There is no software infomation finded!";
            goto Parameter_incomplete ;
        }
        else
        {
            //上一次保存的参数 不完整或者不正确
            #if 0
            QMessageBox::information(this, QObject::tr("读取软件使用信息"),QObject::tr("参数错误!"));
			#else
			QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("There were parameter errors when reading software using information !"));
			#endif
            goto Parameter_incomplete ;
        }
    }

    currentPrj = new EziDebugPrj(unMaxRegNum,idir,etool,this) ;
    currentPrj->setXilinxErrCheckedFlag(isXilinxERRChecked);
    pthread =  currentPrj->getThread() ;
    connect(pthread,SIGNAL(codeFileChanged()),this,SLOT(updateIndicate()));
    connect(currentPrj,SIGNAL(updateProgressBar(int)),this,SLOT(changeProgressBar(int)));

Parameter_incomplete:
    return ;

}

void ToolWindow::writeSetting()
{
    QString itool ;
    unsigned int unMaxRegNum = 0 ;
    QString idir ;
    bool isXilinxERRChecked = false ;

#if 1
    if(currentPrj)
    {
        unMaxRegNum = currentPrj->getMaxRegNumPerChain() ;

        idir = currentPrj->getCurrentDir().absolutePath();

        if(currentPrj->getToolType() == EziDebugPrj::ToolQuartus)
        {
            itool = "quartus" ;
        }
        else if(currentPrj->getToolType() == EziDebugPrj::ToolIse)
        {
            itool = "ise" ;
        }
        else
        {
            itool = "" ;
        }

        isXilinxERRChecked = currentPrj->getSoftwareXilinxErrCheckedFlag() ;
    }
#endif

    qDebug() << "Attention: Begin to writtingSetting!" ;
    QSettings isettings("EDA Center.", "EziDebug");
    // 获取工程参数，如果有就创建工程对象；没有的话，不创建
    isettings.beginGroup("project");
    isettings.setValue("MaxRegNum",unMaxRegNum);
    isettings.setValue("dir",idir);
    isettings.setValue("tool",itool);
    isettings.setValue("isXilinxERRChecked",isXilinxERRChecked);
    isettings.endGroup();
    qDebug() << "Attention: End to writtingSetting!" << unMaxRegNum  \
                << idir << itool ;

}

void ToolWindow::closeEvent(QCloseEvent *event)
{
    myTrayIcon->hide(); //test
    if (myTrayIcon->isVisible())
    {
        myTrayIcon->showMessage("EziDebug", "EziDebug.",QSystemTrayIcon::Information,5000);

        hide();     //最小化
        event->ignore();
    }
    else
    {
        writeSetting() ;
        event->accept();
    }
}


//-----------------------各个slot------------------------
//最小化//点击最小化按钮时，工具栏窗口和列表窗口都隐藏
void ToolWindow::minimize()
{
    //showMinimized();
    this->hide();
    //if(!isNormalListWindowHidden)
    listWindow->hide();

    miniWindow->hide();

    miniSizeAction->setDisabled(true);
    restoreWinAction->setDisabled(false);
}

//转换到迷你模式
void ToolWindow::toMiniMode()
{
//    mainWindow->show();
//    if(isNormalListWindowHidden == false)
//        listWindow->show();
//    statusWidget->hide();


//    if(isNormalListWindowHidden == false)
//        emit hideListWindow();
//    this->hide();
    isNormalMode = false;
    this->hide();
    listWindow->hide();
    miniWindow->show();


}

//迷你模式和工具栏窗口关闭时，触发该槽
void ToolWindow::close()
{
//    statusWidget->close();
    listWindow->close();
    miniWindow->close();
    QWidget::close();
}


void ToolWindow::updateIndicate() // 更新提示
{
    tic = 0 ;
    isNeededUpdate = true ;
    // 快速更新  全部更新 按钮可用
    updatehintButton->setEnabled(true);
    iChangeUpdateButtonTimer->start(300);

    return ;
}

void ToolWindow::fastUpdate()
{
    QStringList iaddFileList ;
    QStringList idelFileList ;
    QStringList ichgFileList ;
    UpdateDetectThread *pthread = NULL ;
    QStringList ideletedChainList ;
    QList<EziDebugPrj::LOG_FILE_INFO*> iaddedinfoList ;
    QList<EziDebugPrj::LOG_FILE_INFO*> ideletedinfoList ;

    if(!currentPrj)
    {   
#if 0
        QMessageBox::warning(this, QObject::tr("快速更新"),QObject::tr("您所指定的工程不存在!"));
#else
        QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("The project is not existed!"));
#endif
        return ;
    }


    if(!isNeededUpdate)
    {   
        #if 0
        QMessageBox::information(this, QObject::tr("快速更新"),QObject::tr("无文件可更新!"));
		#else
		QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("There is no updated file in project!"));
		#endif
        return ;
    }

    progressBar->setValue(2);

    /*退出更新线程*/
    pthread = currentPrj->getThread() ;
    if(pthread->isRunning())
    {
        pthread->quit();
        pthread->wait();
    }

    idelFileList = currentPrj->getUpdateFileList(EziDebugPrj::deletedUpdateFileType) ;
    iaddFileList = currentPrj->getUpdateFileList(EziDebugPrj::addedUpdateFileType) ;
    ichgFileList = currentPrj->getUpdateFileList(EziDebugPrj::changedUpdateFileType) ;

    // clear up the related chainlist last time
    currentPrj->clearupCheckedChainList();
    currentPrj->clearupDestroyedChainList();

    progressBar->setValue(10);

    if(currentPrj->updatePrjAllFile(iaddFileList,idelFileList,ichgFileList,iaddedinfoList,ideletedinfoList,true))
    {   
        #if 0
        QMessageBox::warning(this, QObject::tr("快速更新失败"),QObject::tr("软件内部错误!"));
		#else
	    QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("Fast update failed -- The software interior error!"));
		#endif

        /*重启更新线程*/
        pthread->start();

        progressBar->setValue(0);
        return ;

    }

    currentPrj->setInstanceTreeHeadItem(NULL);
    QString itopModule = currentPrj->getTopModule() ;


    QString itopModuleComboName = itopModule + QObject::tr(":")+ itopModule ;
    EziDebugInstanceTreeItem* pnewHeadItem = new EziDebugInstanceTreeItem(itopModule,itopModule);
    if(!pnewHeadItem)
    {   
        #if 0
        QMessageBox::critical(this, QObject::tr("快速更新失败"),QObject::tr("软件内部错误!"));
		#else
		QMessageBox::critical(this, QObject::tr("EziDebug"),QObject::tr("Fast update failed -- The software interior error!"));
		#endif
        return ;
    }

    progressBar->setValue(50);

    if(currentPrj->traverseModuleTree(itopModuleComboName,pnewHeadItem))
    {
        qDebug() << tr("快速更新失败") << __FILE__ << __LINE__ ;
        delete pnewHeadItem ;
        qDeleteAll(iaddedinfoList);
        qDeleteAll(ideletedinfoList);
        pthread->start();
		#if 0
        QMessageBox::warning(this, QObject::tr("快速更新失败"),QObject::tr("软件内部错误!"));
		#else
		QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("Fast update failed -- The software interior error!"));
		#endif
        return ;
    }

    progressBar->setValue(70);

    currentPrj->setInstanceTreeHeadItem(pnewHeadItem);

    /////////////////////////////
    if(currentPrj->getDestroyedChainList().count())
    {
        // 把所有破坏掉的链打印出来
        QString ichain ;
        QStringList idestroyedChainList = currentPrj->getDestroyedChainList() ;

        listWindow->addMessage("warning","EziDebug warning: Some chains are destroyed!");
        listWindow->addMessage("warning","the destroyed chain are:");
        for(int i = 0 ; i < idestroyedChainList.count() ;i++)
        {
            QString ichainName = idestroyedChainList.at(i) ;

            EziDebugInstanceTreeItem *pitem = currentPrj->getChainTreeItemMap().value(ichainName,NULL);
            if(pitem)
            {
                ichain.append(tr("EziDebug chain:%1  topInstance:%2:%3").arg(ichainName)\
                              .arg(pitem->getModuleName()).arg(pitem->getInstanceName())) ;
            }
            listWindow->addMessage("warning",ichain);
        }

        // 扫描链被破坏 ,提示删除
        #if 0
        QMessageBox::StandardButton rb = QMessageBox::question(this, tr("部分扫描链被破坏"), tr("是否删除相关扫描链代码"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes) ;
		#else
		QMessageBox::StandardButton rb = QMessageBox::question(this, tr("EziDebug"), tr("some scan chains has been destroyed, \n Do you want to delete all scan chain code?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes) ;
		#endif
		
        if(rb == QMessageBox::Yes)
        {
            QStringList iunDelChainList = currentPrj->deleteDestroyedChain(iaddedinfoList,ideletedinfoList) ;
            if(iunDelChainList.count())
            {
                listWindow->addMessage("error","EziDebug error: Some chains can not be deleted for some reasons!");
                for(int i = 0 ; i < iunDelChainList.count() ;i++)
                {
                    listWindow->addMessage("error",tr("EziDebug chain:%1").arg(iunDelChainList.at(i)));
                }
                listWindow->addMessage("error","EziDebug error: Please check the code file is compiled successed!");
            }

            for(int i = 0 ; i < idestroyedChainList.count() ; i++)
            {
                QString idestroyedChain = idestroyedChainList.at(i) ;
                ideletedChainList.append(idestroyedChain);
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

    QStringList icheckChainList = currentPrj->checkChainExist();

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

    /////////////////////////////
    progressBar->setValue(80);

    if(currentPrj->changedLogFile(iaddedinfoList,ideletedinfoList))
    {
        //提示 保存 log 文件出错
        qDebug() << "Error: changedLogFile Error!";
    }

    // 删除 新分配的  log_file_info 指针
    qDeleteAll(iaddedinfoList);
    qDeleteAll(ideletedinfoList);

    progressBar->setValue(90);

    currentPrj->cleanupChainTreeItemMap();
    currentPrj->cleanupBakChainTreeItemMap();

    if(currentPrj->getLastOperation() == EziDebugPrj::OperateTypeDelAllScanChain)
    {
        currentPrj->cleanupChainQueryTreeItemMap();
    }
    else
    {
        currentPrj->cleanupBakChainQueryTreeItemMap();
    }

    currentPrj->updateTreeItem(pnewHeadItem);


    if(currentPrj->getLastOperation() == EziDebugPrj::OperateTypeDelAllScanChain)
    {
        // ChainTreeItemMap 存放新的节点map
        // 恢复 bakChainTreeItemMap 删除 ChainTreeItemMap

        // ChainQueryTreeItemMap 存放新的节点map
        // 恢复 bakChainQueryTreeItemMap 删除 ChainQueryTreeItemMap
        // update 用的 BakChainQueryTreeItemMap 放原始的、 ChainQueryTreeItemMap 放的新的
        currentPrj->cleanupBakChainQueryTreeItemMap();
        currentPrj->backupChainQueryTreeItemMap();
        currentPrj->cleanupChainQueryTreeItemMap();
    }
    else
    {
        // update 用的 ChainQueryTreeItemMap 放原始的、 bakChainQueryTreeItemMap 放新的
        currentPrj->cleanupChainQueryTreeItemMap();
        currentPrj->resumeChainQueryTreeItemMap();
        currentPrj->cleanupBakChainQueryTreeItemMap();
        // treeitemmap 、ChainQueryTreeItemMap、m_ichainInfoMap 非空
    }

    emit updateTreeView(pnewHeadItem);

    // 重置 更新提示
    isNeededUpdate = false ;
    updatehintButton->setIcon(QIcon(":/images/update2.png"));
    updatehintButton->setDisabled(true);
    iChangeUpdateButtonTimer->stop();

    /*重启更新线程*/
    pthread->start();

    progressBar->setValue(100);

	#if 0
    QMessageBox::warning(this, QObject::tr("快速更新"),QObject::tr("快速更新完毕!"));
	#else
	QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Fast update completed!"));
	#endif

    progressBar->setValue(0);

}

void ToolWindow::undoOperation()
{
    QList<EziDebugPrj::LOG_FILE_INFO*> iaddedinfoList ;
    QList<EziDebugPrj::LOG_FILE_INFO*> ideletedinfoList ;
    QString irelativeFileName ;
    UpdateDetectThread* pthread = NULL ;
    QDateTime ilastModifedTime ;
    QString ifileName ;
    EziDebugVlgFile *pvlgFile = NULL ;
    EziDebugVhdlFile *pvhdlFile = NULL ;
    QStringList ifileList ;
    bool isstopFlag = false ;
    int i = 0 ;

    if(!currentPrj)
    {   
#if 0
        QMessageBox::warning(this, QObject::tr("撤销上一步操作"),QObject::tr("您所指定的工程不存在!"));
#else
        QMessageBox::warning(this, QObject::tr("EziDebug"),QObject::tr("The project is not existed!"));
#endif
        return ;
    }

    // 停止检测更新   退出线程
    pthread = currentPrj->getThread() ;
    if(pthread->isRunning())
    {
        pthread->quit();
        pthread->wait();
        isstopFlag = true ;
    }

    // 5%
    if(EziDebugPrj::OperateTypeAddScanChain == currentPrj->getLastOperation())
    {
        // 删除链相关的指针对象
        EziDebugScanChain *plastOperatedChain = currentPrj->getLastOperateChain() ;
        if(!plastOperatedChain)
        {
            /*提示 无扫描链*/
			#if 0
            QMessageBox::information(this, QObject::tr("undo 失败"),QObject::tr("上一步操作的扫描链不存在!"));
			#else
			QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("There is no scan chain in last operation!"));
			#endif
            pthread->start();
            return ;
        }


        ifileList = plastOperatedChain->getScanedFileList() ;
        // 10%
        // check the backup file exist
        i = 0 ;
        for( ; i < ifileList.count() ; i++)
        {
            // 获取备份的文件名全称
            // 10% +
            ifileName = ifileList.at(i) ;
            QFileInfo ifileInfo(ifileName);
            QString ieziDebugFileSuffix ;
            irelativeFileName = currentPrj->getCurrentDir().relativeFilePath(ifileName);

            ieziDebugFileSuffix.append(QObject::tr(".add.%1").arg(currentPrj->getLastOperateChain()->getChainName()));

            QString ibackupFileName = currentPrj->getCurrentDir().absolutePath() \
                    + EziDebugScanChain::getUserDir() + QObject::tr("/") + ifileInfo.fileName() \
                    + ieziDebugFileSuffix;
            QFile ibackupFile(ibackupFileName) ;

            if(!ibackupFile.exists())
            {   
                #if 0
                QMessageBox::information(this, QObject::tr("undo"),QObject::tr("备份文件%1不存在!").arg(ibackupFileName));
				#else
				QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Undo failed ,there is no backup file \"%1\"").arg(ibackupFileName));
				#endif
                pthread->start();
                return ;
            }
        }

        /*从备份文件中恢复文件*/
        i = 0 ;
        for( ; i < ifileList.count() ; i++)
        {
            // 获取备份的文件名全称
            ifileName = ifileList.at(i) ;
            QFileInfo ifileInfo(ifileName);
            QString ieziDebugFileSuffix ;
            irelativeFileName = currentPrj->getCurrentDir().relativeFilePath(ifileName);

            ieziDebugFileSuffix.append(QObject::tr(".add.%1").arg(currentPrj->getLastOperateChain()->getChainName()));

            QString ibackupFileName = currentPrj->getCurrentDir().absolutePath() \
                    + EziDebugScanChain::getUserDir() + QObject::tr("/") + ifileInfo.fileName() \
                    + ieziDebugFileSuffix;
            QFile ibackupFile(ibackupFileName) ;

            if(!ibackupFile.exists())
            {   
                #if 0
                QMessageBox::information(this, QObject::tr("undo失败"),QObject::tr("备份文件%1不存在!").arg(ibackupFileName));
				#else
				QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Undo failed ,there is no backup file \"%1\"!").arg(ibackupFileName));
				#endif
                pthread->start();
                return ;
            }

            // 文件被修改了 需要重新保存文件日期
            struct EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
            pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
            pdelFileInfo->pinfo = NULL ;
            memcpy(pdelFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
            ideletedinfoList.append(pdelFileInfo);


            struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
            paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;

            if(ifileName.endsWith(".v"))
            {
                pvlgFile = currentPrj->getPrjVlgFileMap().value(currentPrj->getCurrentDir().relativeFilePath(ifileName)) ;
                pvlgFile->remove();
                // 已经是绝对路径了
                ibackupFile.copy(ifileName);
                pvlgFile->modifyStoredTime(ifileInfo.lastModified());
                paddFileInfo->pinfo = pvlgFile ;
            }
            else if(ifileName.endsWith(".vhd"))
            {
                // 已经是绝对路径了
                // ibackupFile.copy(plastOperatedChain->getScanedFileList().at(i));
            }
            else
            {
                continue ;
            }

            memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data(), irelativeFileName.size()+1);
            iaddedinfoList.append(paddFileInfo);

            // 删除备份的文件
            ibackupFile.remove();
        }

        // undo success delete scanchain info in log file!
        struct EziDebugPrj::LOG_FILE_INFO* pdelChainInfo = new EziDebugPrj::LOG_FILE_INFO ;
        memcpy(pdelChainInfo->ainfoName,plastOperatedChain->getChainName().toAscii().data(),plastOperatedChain->getChainName().size()+1);
        pdelChainInfo->pinfo = NULL ;
        pdelChainInfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
        ideletedinfoList.append(pdelChainInfo) ;

        // 从chain map 中删除
        currentPrj->eliminateChainFromMap(plastOperatedChain->getChainName());

        // 将 item 的 chain 置为空
        EziDebugInstanceTreeItem * item = currentPrj->getChainTreeItemMap().value(plastOperatedChain->getChainName());
        if(item)
        {
            item->setScanChainInfo(NULL);
        }
        else
        {
            pthread->start();
            return ;
        }
        // 从item map 中删除
        currentPrj->eliminateTreeItemFromMap(plastOperatedChain->getChainName());

        currentPrj->eliminateTreeItemFromQueryMap(item->getNameData());

        // 删除指针对象
        delete  plastOperatedChain ;
        plastOperatedChain = NULL ;

        // 上一步操作相关对象 置空
        currentPrj->updateOperation(EziDebugPrj::OperateTypeNone,NULL,NULL);
    }
    else if(EziDebugPrj::OperateTypeDelSingleScanChain == currentPrj->getLastOperation())
    {
        // 恢复 上次删除的链
        EziDebugScanChain *plastOperatedChain = currentPrj->getLastOperateChain() ;
        if(!plastOperatedChain)
        {
            /*提示 无扫描链*/
            pthread->start();
            return ;
        }
        EziDebugInstanceTreeItem * plastOperatedItem = currentPrj->getLastOperateTreeItem();
        if(!plastOperatedItem)
        {
            /*提示 无此节点*/
            pthread->start();
            return ;
        }

        // check the back up file
        for(i = 0 ; i < plastOperatedChain->getScanedFileList().count();i++)
        {
            // 获取备份的文件名全称
            ifileName = plastOperatedChain->getScanedFileList().at(i) ;
            irelativeFileName = currentPrj->getCurrentDir().relativeFilePath(ifileName);

            QFileInfo ifileInfo(ifileName);
            QString ieziDebugFileSuffix ;
            ieziDebugFileSuffix.append(QObject::tr(".delete.%1").arg(plastOperatedChain->getChainName()));

            QString ibackupFileName = currentPrj->getCurrentDir().absolutePath() \
                    + EziDebugScanChain::getUserDir() + QObject::tr("/") + ifileInfo.fileName() \
                    + ieziDebugFileSuffix;
            QFile ibackupFile(ibackupFileName) ;
            if(!ibackupFile.exists())
            {   
                #if 0
                QMessageBox::information(this, QObject::tr("undo失败"),QObject::tr("备份文件%1不存在!").arg(ibackupFileName));
				#else
				QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Undo failed , there is no backup file \"%1\"!").arg(ibackupFileName));
				#endif
                pthread->start();
                return ;
            }
        }

         // 恢复源文件
        for(i = 0 ; i < plastOperatedChain->getScanedFileList().count();i++)
        {
            // 获取备份的文件名全称
            ifileName = plastOperatedChain->getScanedFileList().at(i) ;
            irelativeFileName = currentPrj->getCurrentDir().relativeFilePath(ifileName);

            QFileInfo ifileInfo(ifileName);
            QString ieziDebugFileSuffix ;
            ieziDebugFileSuffix.append(QObject::tr(".delete.%1").arg(plastOperatedChain->getChainName()));

            QString ibackupFileName = currentPrj->getCurrentDir().absolutePath() \
                    + EziDebugScanChain::getUserDir() + QObject::tr("/") + ifileInfo.fileName() \
                    + ieziDebugFileSuffix;
            QFile ibackupFile(ibackupFileName) ;


            struct EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
            pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
            pdelFileInfo->pinfo = NULL ;
            memcpy(pdelFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
            ideletedinfoList.append(pdelFileInfo);

            struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
            paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;

            if(ifileName.endsWith(".v"))
            {
                pvlgFile = currentPrj->getPrjVlgFileMap().value(currentPrj->getCurrentDir().relativeFilePath(ifileName)) ;
                pvlgFile->remove();
                // 已经是绝对路径了
                ibackupFile.copy(ifileName);
                pvlgFile->modifyStoredTime(ifileInfo.lastModified());
                paddFileInfo->pinfo = pvlgFile ;
            }
            else if(ifileName.endsWith(".vhd"))
            {
                // 已经是绝对路径了
                // ibackupFile.copy(plastOperatedChain->getScanedFileList().at(i));
            }
            else
            {
                continue ;
            }
            memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data(), irelativeFileName.size()+1);
            iaddedinfoList.append(paddFileInfo);

            // 删除备份的文件
            ibackupFile.remove();
        }


        // add chain info to log file
        struct EziDebugPrj::LOG_FILE_INFO* paddChainInfo = new EziDebugPrj::LOG_FILE_INFO ;
        memcpy(paddChainInfo->ainfoName ,plastOperatedChain->getChainName().toAscii().data(),plastOperatedChain->getChainName().size()+1);
        paddChainInfo->pinfo = plastOperatedChain ;
        paddChainInfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
        iaddedinfoList << paddChainInfo ;

        //
        plastOperatedItem->setScanChainInfo(plastOperatedChain);

        //  加入 item map
        currentPrj->addToTreeItemMap(plastOperatedChain->getChainName(),plastOperatedItem);


        //  加入 item map
        currentPrj->addToChainMap(plastOperatedChain);

        //
        currentPrj->addToQueryItemMap(plastOperatedItem->getNameData(),plastOperatedItem);

        // 上一步操作相关对象 置空
        currentPrj->updateOperation(EziDebugPrj::OperateTypeNone,NULL,NULL);

    }
    else if(EziDebugPrj::OperateTypeDelAllScanChain == currentPrj->getLastOperation())
    {
        QStringList irepeatedFileList ;

        QMap<QString,EziDebugInstanceTreeItem*> ichainTreeItemMap = currentPrj->getBackupChainTreeItemMap();
        QMap<QString,EziDebugInstanceTreeItem*>::const_iterator i = ichainTreeItemMap.constBegin();
        // check backup file exist
        while( i != ichainTreeItemMap.constEnd())
        {
            EziDebugScanChain * plastChain = currentPrj->getBackupChainMap().value(i.key());
            /*读取删除链 已经扫描过的文件,从已经备份的文件中恢复*/
            for(int p = 0 ; p < plastChain->getScanedFileList().count();p++)
            {
                // 获取备份的文件名全称
                ifileName = plastChain->getScanedFileList().at(p) ;
                irelativeFileName = currentPrj->getCurrentDir().relativeFilePath(ifileName);

                QFileInfo ifileInfo(ifileName);
                QString ieziDebugFileSuffix ;

                ieziDebugFileSuffix.append(QObject::tr(".deleteall"));

                QString ibackupFileName = currentPrj->getCurrentDir().absolutePath() \
                        + EziDebugScanChain::getUserDir()+ QObject::tr("/") + ifileInfo.fileName() \
                        + ieziDebugFileSuffix;
                QFile ibackupFile(ibackupFileName) ;
                if(!ibackupFile.exists())
                {   
                    #if 0
                    QMessageBox::information(this, QObject::tr("undo失败"),QObject::tr("备份文件%1不存在!").arg(ibackupFileName));
					#else
					QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("Undo failed , there is no backup file \"%1\" !").arg(ibackupFileName));
					#endif
                    pthread->start();
                    return ;
                }
            }
            ++i ;
        }

        // 恢复源文件
        i = ichainTreeItemMap.constBegin();
        while(i != ichainTreeItemMap.constEnd())
        {
            /*将chain指针加入到 树状节点下面*/
            EziDebugInstanceTreeItem* pitem = i.value() ;

            EziDebugScanChain * plastChain = currentPrj->getBackupChainMap().value(i.key());
            pitem->setScanChainInfo(plastChain);


            struct EziDebugPrj::LOG_FILE_INFO* paddChainInfo = new EziDebugPrj::LOG_FILE_INFO ;
            memcpy(paddChainInfo->ainfoName ,plastChain->getChainName().toAscii().data(),plastChain->getChainName().size()+1);
            paddChainInfo->pinfo = plastChain ;
            paddChainInfo->etype = EziDebugPrj::infoTypeScanChainStructure ;
            iaddedinfoList << paddChainInfo ;


            /*读取删除链 已经扫描过的文件,从已经备份的文件中恢复*/
            for(int p = 0 ; p < plastChain->getScanedFileList().count();p++)
            {
                // 获取备份的文件名全称
                ifileName = plastChain->getScanedFileList().at(p) ;
                irelativeFileName = currentPrj->getCurrentDir().relativeFilePath(ifileName);

                QFileInfo ifileInfo(ifileName);
                QString ieziDebugFileSuffix ;

                ieziDebugFileSuffix.append(QObject::tr(".deleteall"));

                QString ibackupFileName = currentPrj->getCurrentDir().absolutePath() \
                        + EziDebugScanChain::getUserDir()+ QObject::tr("/") + ifileInfo.fileName() \
                        + ieziDebugFileSuffix;
                QFile ibackupFile(ibackupFileName) ;

                struct EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
                pdelFileInfo->pinfo = NULL ;
                memcpy(pdelFileInfo->ainfoName , irelativeFileName.toAscii().data() , irelativeFileName.size()+1);
                ideletedinfoList.append(pdelFileInfo);

                struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
                paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;

                if(ifileName.endsWith(".v"))
                {
                    pvlgFile = currentPrj->getPrjVlgFileMap().value(currentPrj->getCurrentDir().relativeFilePath(ifileName)) ;
                    pvlgFile->remove();

                    ibackupFile.copy(ifileName);
                    pvlgFile->modifyStoredTime(ifileInfo.lastModified());
                    paddFileInfo->pinfo = pvlgFile ;
                }
                else if(ifileName.endsWith(".vhd"))
                {
                    // 已经是绝对路径了
                    // ibackupFile.copy(plastOperatedChain->getScanedFileList().at(i));
                }
                else
                {
                    continue ;
                }
                memcpy(paddFileInfo->ainfoName , irelativeFileName.toAscii().data(), irelativeFileName.size()+1);
                iaddedinfoList.append(paddFileInfo);
                // 删除当前备份的文件
                ibackupFile.remove();
            }

            i++ ;
        }

        //
        currentPrj->resumeChainMap();

        //
        currentPrj->resumeChainTreeItemMap();

        //
        currentPrj->resumeChainQueryTreeItemMap();

        // 上一步操作相关对象 置空
        currentPrj->updateOperation(EziDebugPrj::OperateTypeNone,NULL,NULL);
    }
    else
    {   
        #if 0
        QMessageBox::information(this , QObject::tr("注意") , QObject::tr("上一步无操作!"));
		#else
		QMessageBox::information(this , QObject::tr("EziDebug") , QObject::tr("Note: there is no last operation!"));
		#endif

        if(isstopFlag == true)
        {
            pthread->start();
        }
        return ;
    }

    // 90%
    if(currentPrj->changedLogFile(iaddedinfoList,ideletedinfoList))
    {
        // 提示 保存 log 文件出错
        qDebug() << tr("Error:Save log file error in undo operation!") ;
    }

    qDeleteAll(ideletedinfoList);
    qDeleteAll(iaddedinfoList);

    if(isstopFlag == true)
    {
        pthread->start();
    }

    // 100%
    #if 0
    QMessageBox::information(this, QObject::tr("undo操作"),QObject::tr("撤销上一步操作完毕!"));
	#else
	QMessageBox::information(this, QObject::tr("EziDebug"),QObject::tr("The last operation is undo successfully!"));
	#endif

    return ;
}

void ToolWindow::changeUpdatePic()
{
    tic++ ;
    if(tic%2)
    {
        updatehintButton->setIcon(QIcon(":/images/update3.png"));
    }
    else
    {
        updatehintButton->setIcon(QIcon(":/images/update2.png"));
    }
    iChangeUpdateButtonTimer->start();
}

//从最小化还原
void ToolWindow::showNormal()
{
    miniSizeAction->setDisabled(false);
    restoreWinAction->setDisabled(true);
    if(isNormalMode)
    {

    if(!listWindow->isListWindowHidden())
        listWindow->show();
        this->show();
    }
    else
        miniWindow->show();

}

void ToolWindow::changeProgressBar(int value)
{
    progressBar->setValue(value);
}


//右侧中部按钮，打开toolwindow下方的列表窗口
void ToolWindow::showListWindow()
{

    if(listWindow->isListWindowHidden()){
        listWindow->setListWindowHidden(false);

    }
    else{
        listWindow->setListWindowHidden(true);
    }
}

//关于
void ToolWindow::about()
{   
#if 0
    QMessageBox::about(this, tr("关于"), tr("    版权由中科院EDA中心所有    \n\n"));
#else
    QMessageBox::about(this,tr("About EziDebug"),tr("    EziDebug CopyRight(c) 2013-2018 by EziGroup.    \n\n"));
#endif

}

//帮助
void ToolWindow::help()
{

}


//系统托盘相关函数
void ToolWindow::iconActivated(QSystemTrayIcon::ActivationReason reason)
{
    switch(reason)
    {
    case QSystemTrayIcon::Trigger:
    case QSystemTrayIcon::DoubleClick:
        //普通模式下，窗口最小化或者不在顶层
        if(isNormalMode)
        {
            if(this->isHidden() || !this->isTopLevel())
            {
                if(!listWindow->isListWindowHidden()){
                    listWindow->show();
                    listWindow->raise();
                    listWindow->activateWindow();
                }
                this->show();
                this->raise();
                this->activateWindow();

                miniSizeAction->setDisabled(false);
                restoreWinAction->setDisabled(true);
            }
            else
            {

                this->hide();
                listWindow->hide();

                miniSizeAction->setDisabled(true);
                restoreWinAction->setDisabled(false);
            }
        }
        //迷你模式下，窗口最小化
        else
        {
            if(miniWindow->isHidden())
            {
                miniWindow->showNormal();

                miniSizeAction->setDisabled(false);
                restoreWinAction->setDisabled(true);
            }
            else
            {
                miniWindow->hide();
                miniSizeAction->setDisabled(true);
                restoreWinAction->setDisabled(false);
            }
        }
        break;
    case QSystemTrayIcon::MiddleClick:
        myTrayIcon->showMessage("EziDebug", "EziDebug.",QSystemTrayIcon::Information,10000);
        break;

    default:
        break;
    }
}

//迷你模式下，还原为普通模式
void ToolWindow::toNormalMode()
{
    isNormalMode = true;
    this->show();
    if(!listWindow->isListWindowHidden())
        listWindow->show();
    miniWindow->hide();
    //miniWindow->setStatusWidgetHidden(true);
}


//listWindow的窗口移动或缩放后，判断listWindow是否吸附
void ToolWindow::listWindowMouseReleased(const QRect listWinGeo)
{
    const int disMax = 15;
    isListWindowAdsorbed = false;
    int dis = this->geometry().bottom() - listWinGeo.top();
    if((dis < disMax) && (dis > -disMax)){
        listWindow->move(listWinGeo.left(), this->geometry().bottom());//移动窗口
        isListWindowAdsorbed = true;
    }
    dis = this->geometry().top() - listWinGeo.bottom();
    if((dis < disMax) && (dis > -disMax)){
        listWindow->move(listWinGeo.left(), listWinGeo.top() + dis);//移动窗口
        isListWindowAdsorbed = true;
    }
    dis = this->geometry().right() - listWinGeo.left();
    if((dis < disMax) && (dis > -disMax)){
        listWindow->move(this->geometry().right(), listWindow->geometry().top());//移动窗口
        isListWindowAdsorbed = true;
    }

    dis = this->geometry().left() - listWinGeo.right();
    if((dis < disMax) && (dis > -disMax)){
        listWindow->move(listWindow->geometry().left() + dis, listWindow->geometry().top());//移动窗口
        isListWindowAdsorbed = true;
    }
}

//void ToolWindow::proSetting()
//{
////    ProjectSetWizard proSetWiz(this);
////    if (proSetWiz.exec()) {
////        QString str = tr("aa");

////    }

//}











