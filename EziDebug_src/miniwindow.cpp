#include "miniwindow.h"
//#include "button.h"//移至"miniwindow.h"中

#include <QtGui>

MiniWindow::MiniWindow(QWidget *parent) :
    QWidget(parent)
{
    QTextCodec::setCodecForTr(QTextCodec::codecForName("gb18030"));
    setMouseTracking (true);
    setWindowTitle(tr("EziDebug"));

    statusLabel = new QLabel(tr("         Status"));


    createActions();   //创建右键菜单的选项0
    createButtons();   //创建按钮

    //设置系统图标,状态栏图标

    QPixmap objPixmap(tr(":/images/EziDebugIcon.bmp"));
    QPixmap iconPix;
    objPixmap.setMask(QPixmap(tr(":/images/EziDebugIconMask.bmp")));
    iconPix = objPixmap.copy(0, 0, 127, 104).scaled(32, 31);
    setWindowIcon(iconPix);


    //设置背景
    //QPixmap maskPix;
    QPalette palette;
    backgroundPix.load(":/images/miniBackground.bmp",0,Qt::AvoidDither|Qt::ThresholdDither|Qt::ThresholdAlphaDither);
    //maskPix.load(":/images/miniMask.bmp");
    palette.setBrush(QPalette::Background, QBrush(backgroundPix));
    //setMask(maskPix);
    setPalette(palette);
    //setMask(backgroundPix.mask());   //通过QPixmap的方法获得图片的过滤掉透明的部分得到的图片，作为Widget的不规则边框
    //setWindowOpacity(1.0);  //设置图片透明度

    //设置对话框的位置和大小
    setGeometry(QRect(250,100,298,34));
    //setMinimumSize(480,42);
    setFixedSize(backgroundPix.size());//设置窗口的尺寸为图片的尺寸
    setContentsMargins(0,0,0,0);
    Qt::WindowFlags flags = Qt::Widget;
    flags |= Qt::WindowStaysOnTopHint;//最前端显示
    flags |= Qt::FramelessWindowHint;//设置为无边框
    setWindowFlags(flags);

    //设置掩板
    QPixmap maskPix;
    maskPix.load(":/images/miniMask.bmp");
    setMask(maskPix);
//    //生成一张位图
//    QBitmap objBitmap(size());
//    //QPainter用于在位图上绘画
//    QPainter painter(&objBitmap);
//    //填充位图矩形框(用白色填充)
//    painter.fillRect(rect(),Qt::white);
//    painter.setBrush(QColor(0,0,0));
//    //在位图上画圆角矩形(用黑色填充)
//    painter.drawRoundedRect(this->rect(),8,8);
//    //使用setmask过滤即可
//    setMask(objBitmap);


    //设置迷你模式下的按键
    //大版的位置
//    proSettingButton->setGeometry(QRect(60, 1, 42, 41));//工程设置
//    proUpdateButton->setGeometry(QRect(102, 1, 42, 41));//更新
//    proPartlyUpdateButton->setGeometry(QRect(144, 1, 42, 41));//部分更新
//    deleteChainButton->setGeometry(QRect(186, 1, 42, 41));//删除
//    testbenchGenerationButton->setGeometry(QRect(228, 1, 42, 41));//testbench生成
//    proUndoButton->setGeometry(QRect(270, 1, 42, 41));//撤销（undo）

//    minimizeButton->setGeometry(QRect(390, 0, 27, 19));
//    normalModeButton->setGeometry(QRect(416, 0, 27, 19));
//    exitButton->setGeometry(QRect(442, 0, 33, 19));

    //设置迷你模式下的按键
     //中版的位置
     proSettingButton->setGeometry(QRect(40, 4, 26, 25));
     proUpdateButton->setGeometry(QRect(65, 4, 26, 25));
     proPartlyUpdateButton->setGeometry(QRect(90, 4, 26, 25));
     deleteChainButton->setGeometry(QRect(115, 4, 26, 25));
     testbenchGenerationButton->setGeometry(QRect(140, 4, 26, 25));
     proUndoButton->setGeometry(QRect(165, 4, 26, 25));

     minimizeButton->setGeometry(QRect(240, 0, 16, 11));
     normalModeButton->setGeometry(QRect(257, 0, 16, 11));
     exitButton->setGeometry(QRect(274, 0, 20, 11));

     //    //小版的位置
//    proSettingButton->setGeometry(QRect(30, 2, 21, 20));//工程设置
//    proUpdateButton->setGeometry(QRect(50, 2, 21, 20));//更新
//    proPartlyUpdateButton->setGeometry(QRect(70, 2, 21, 20));//部分更新
//    deleteChainButton->setGeometry(QRect(90, 2, 21, 20));//删除
//    testbenchGenerationButton->setGeometry(QRect(110, 2, 21, 20));//testbench生成
//    proUndoButton->setGeometry(QRect(130, 2, 21, 20));//撤销（undo）

//    minimizeButton->setGeometry(QRect(255, 0, 14, 10));
//    normalModeButton->setGeometry(QRect(268, 0, 14, 10));
//    exitButton->setGeometry(QRect(281, 0, 17, 10));

//    //miniIconLabel->setGeometry(QRect(100, 1, 105, 20));
//    minimizeButton->setGeometry(QRect(317, 4, 11, 10));
//    //showStatusButton->hide();
//    //minimizeButton->setGeometry(QRect(305, 4, 11, 10));
//    //showStatusButton->setGeometry(QRect(317, 4, 11, 10));
//    normalModeButton->setGeometry(QRect(329, 4, 11, 10));
//    exitButton->setGeometry(QRect(341, 4, 11, 10));


    //状态显示
//    statusRoll = new RollCaption(this);
//    statusRoll->setGeometry(QRect(118, 2, 162, 21));
//    statusRoll->setText(tr("status of EziDebug, this is a demo, just for test. "));
////    statusRoll->setSpeed(50);
////    statusRoll->setcolor(QColor(0, 0, 0));

////    QLabel *statusLabel1 = new QLabel(tr("Status"));
////    //statusLabel1->setTextFormat();
////    statusLabel1->setGeometry(QRect(118, 2, 170, 21));

//    //迷你模式下的状态栏
    statusWidget = new QWidget;
//    QHBoxLayout *StatusLayout = new QHBoxLayout;
//    StatusLayout->addWidget(statusLabel);
//    StatusLayout->setMargin(0);
//    statusWidget->setLayout(StatusLayout);
//    flags =  Qt::Widget;
//    flags |= Qt::WindowStaysOnTopHint;//最前端显示
//    flags |= Qt::FramelessWindowHint;//设置为无边框
//    statusWidget->setWindowFlags(flags);

//    palette.setColor(QPalette::Background, QColor(27,61,125));
//    statusWidget->setPalette(palette);
//    //statusWidget->setFont();

//    statusWidget->resize(size());
//    QPoint p = frameGeometry().topLeft();
//    p.setX(p.rx() + width());
//    statusWidget->move(p);

    statusWidget->setHidden(true);
    isMiniStatusLabelHidden = true;

}

void MiniWindow::createButtons()
{
    //工具栏按钮  tr("工程设置")
    proSettingButton = createToolButton(tr("Set Project Parameter"),
                                        tr(":/images/projectSetting.bmp"),
                                        QSize(26, 25));//(42, 41)

	// tr("更新")
    proUpdateButton = createToolButton(tr("Update"),
                                       tr(":/images/projectUpdate.bmp"),
                                       QSize(26, 25));
    // tr("部分更新")
    proPartlyUpdateButton = createToolButton(tr("Update fast"),
                                       tr(":/images/projectPartlyUpdate.bmp"),
                                       QSize(26, 25));

	// tr("删除")
    deleteChainButton = createToolButton(tr("Delete all scan chain"),
                                         tr(":/images/deleteChain.bmp"),
                                         QSize(26, 25));

	// tr("testbench生成")
    testbenchGenerationButton = createToolButton(tr("Gnerate testbench"),
                                                 tr(":/images/testbenchGeneration.bmp"),
                                                 QSize(26, 25));
    // tr("撤消")
    proUndoButton = createToolButton(tr("Undo"),
                                                     tr(":/images/undo.bmp"),
                                                     QSize(26, 25));



    //右上角标题栏按钮
    // tr("最小化")
    minimizeButton = createToolButton(tr("Minimize"),
                                          tr(":/images/ToolWindowminimize.bmp"),
                                          QSize(20, 14));//QSize(27, 19)

	// tr("普通模式")
    normalModeButton = createToolButton(tr("Normal mode"),
                                        tr(":/images/ToolWindowNormal.bmp"),
                                        QSize(20, 14));
    // tr("退出")
    exitButton = createToolButton(tr("Quit"),
                                      tr(":/images/ToolWindowExit.bmp"),
                                      QSize(24, 14));//QSize(33, 19)



//原代码,留connect对象供参考
//    minimizeButton = createToolButton(tr("最小化"),
//                                          QIcon(":/images/miniMinimize.bmp"),
//                                          QSize(11, 10),
//                                           SLOT(minimize()));

//    showStatusButton = createToolButton(tr("运行状态"),
//                                            QIcon(":/images/miniShowStatus.bmp"),
//                                            QSize(11, 10),
//                                            SLOT(showStatusWedgit()));

//    normalModeButton = createToolButton(tr("普通模式"),
//                                        QIcon(":/images/miniNormal.bmp"),
//                                        QSize(11, 10),
//                                        SIGNAL(toNormalMode()));

//    exitButton = createToolButton(tr("退出"),
//                                      QIcon(":/images/miniExit.bmp"),
//                                      QSize(11, 10),
//                                      SLOT(close()));
    //connect(minimizeButton, SIGNAL(clicked()), this, SLOT(minimize()));//在toolwindow中connect
    connect(normalModeButton, SIGNAL(clicked()), this, SIGNAL(toNormalMode()));
    connect(exitButton, SIGNAL(clicked()), this, SLOT(close()));

}

void MiniWindow::createActions()
{   
    // tr("退出")
    exitAct = new QAction(tr("Quit"), this);
    exitAct->setShortcuts(QKeySequence::Quit);
    //exitAct->setStatusTip(tr("退出"));
    connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));

	// tr("最小化")
    minimizeAct = new QAction(tr("Minimize"), this);
    //minimizeAct->setShortcuts(QKeySequence::);
    //minimizeAct->setStatusTip(tr("Exit the application"));
    connect(minimizeAct, SIGNAL(triggered()), this, SLOT(minimize()));

	// tr("普通模式")
    toNormalModeAct = new QAction(tr("Normal mode"), this);
    //normalAct->setShortcuts(QKeySequence::Quit);
    //normalAct->setStatusTip(tr("Exit the application"));
    connect(toNormalModeAct, SIGNAL(triggered()), this, SIGNAL(toNormalMode()));

}

Button *MiniWindow::createToolButton(const QString &toolTip,
                                          const QString &iconstr,const QSize &size)
{
    Button *button = new Button(iconstr, this);
    button->setToolTip(toolTip);
    //button->setIcon(icon);
    button->setIconSize(size);//(QSize(10, 10));
    // button->setSizeIncrement(size);
    //button->setSizePolicy(size.width(), size.height());
    button->setFlat(true);
    //connect(button, SIGNAL(clicked()), this, member);

    return button;
}

void MiniWindow::contextMenuEvent(QContextMenuEvent *event)
{
    QMenu menu(this);
    menu.addAction(minimizeAct);
    menu.addAction(toNormalModeAct);
    menu.addAction(exitAct);
    menu.exec(event->globalPos());
}

void MiniWindow::mousePressEvent(QMouseEvent * event)
{
    if (event->button() == Qt::LeftButton) //点击左边鼠标
    {
        //globalPos()获取根窗口的相对路径，frameGeometry().topLeft()获取主窗口左上角的位置
            dragPosition = event->globalPos() - frameGeometry().topLeft();

        event->accept();   //鼠标事件被系统接收
    }
    //    if (event->button() == Qt::RightButton)
    //    {
    //         close();
    //    }
}

void MiniWindow::mouseMoveEvent(QMouseEvent * event)
{
    if (event->buttons() == Qt::LeftButton) //当满足鼠标左键被点击时。
    {

            QPoint p = event->globalPos() - dragPosition;
            move(p);//移动窗口
            p.setX(p.rx() + width());
            statusWidget->move(p);

        event->accept();
    }
}


//以下代码(直到"exitButton->move(size().width() - 17, 4);"一句)
//均为mini窗口可放大缩小的前提下设置的,现注释掉,以后调整需求后或许有用
////当鼠标移动到主界面内部周围5像素时，改变鼠标形状；当进行伸缩拖动时，根据拖动方向进行主界面的位置和大小设置即可。
////鼠标按下事件
//void MiniWindow::mousePressEvent(QMouseEvent *event)
//{
//    if (event->button() == Qt::LeftButton)
//    {
//        isLeftButtonPress = true;

//        //判读是窗口移动还是缩放
//        eDirection = (enum_Direction)PointValid(event->x());
//        if(eDirection == eNone)//是窗口移动
//        {
//            isWindowMovement = true;
//            //globalPos()获取根窗口的相对路径，frameGeometry().topLeft()获取主窗口左上角的位置
//            dragPosition = event->globalPos() - frameGeometry().topLeft();
//        }
//        else//是窗口缩放
//        {
//            isWindowMovement = false;
//            pointPressGlobal = event->globalPos();
//        }

//        event->accept();   //鼠标事件被系统接收
//    }
//}
////鼠标移动事件
//void MiniWindow::mouseMoveEvent(QMouseEvent *event)
//{
//    if(!isLeftButtonPress)
//    {
//        eDirection = (enum_Direction)PointValid(event->x());
//        SetCursorStyle(eDirection);
//    }
//    else
//    {
//        if(eDirection == eNone)//是窗口移动
//        {
//            QPoint p = event->globalPos() - dragPosition;
//            move(p);//移动窗口
//            //                        p.setX(p.rx() + width());
//            //                        statusWidget->move(p);

//        }
//        else//是窗口缩放
//        {
//            int nXGlobal = event->globalX();
//            int nYGlobal = event->globalY();
//            SetDrayMove(nXGlobal, eDirection);
//            pointPressGlobal =QPoint(nXGlobal,nYGlobal);
//        }
//    }

//    event->accept();

//}

////鼠标释放事件
//void MiniWindow::mouseReleaseEvent(QMouseEvent *event)
//{
//    if (event->button() == Qt::LeftButton)
//    {
//        isLeftButtonPress = false;
//        eDirection = eNone;
//    }
//}

////判断鼠标所在位置在当前窗口的什么位置，左右 边界上，或者都不是
//int MiniWindow::PointValid(int x)
//{
//    enum_Direction direction = eNone;
//    if ((x >= 0) && (x < 6))
//    {

//            direction = eLeft;
//    }
//    else if((x > this->width() - 6) && (x <= this->width()))
//    {

//            direction = eRight;
//    }

//   return (int)direction;
//}

////设置鼠标样式
//void MiniWindow::SetCursorStyle(enum_Direction direction)
//{
//    //设置左右的鼠标形状
//    switch(direction)
//    {
//    case eRight:
//    case eLeft:
//        setCursor(Qt::SizeHorCursor);
//        break;
//    default:
//        setCursor(Qt::ArrowCursor);
//        break;
//    }
//}

////设置鼠标拖动的窗口位置信息
//void MiniWindow::SetDrayMove(int nXGlobal, enum_Direction direction)
//{
//    //获得主窗口位置信息
//    QRect rectWindow = geometry();
//    //判别方向
//    switch(direction)
//    {

//    case eRight:
//        rectWindow.setRight(nXGlobal);
//        break;
//    case eLeft:
//        rectWindow.setLeft(nXGlobal);
//        break;
//    default:
//        break;
//    }

//    if(rectWindow.width()< minimumWidth())
//    {
//        return;
//    }
//    //重新设置窗口位置为新位置信息
//    setGeometry(rectWindow);
//}

//// 随着窗体变化而设置背景
//void MiniWindow::resizeEvent(QResizeEvent *event)
//{
//    QWidget::resizeEvent(event);

//    //背景图片缩放
//    //创建一个size为变化后size的新画布
//    QImage img(event->size(), QImage::Format_ARGB32);
//    QPainter *paint = new QPainter(&img);
//    //在新区域画图，左-fixed，中-scaled，右-fixed
//    paint->drawPixmap(0, 0, backgroundPix.copy(0, 0, 120, 25));
//    paint->drawPixmap(120, 0, backgroundPix.copy(120, 0, 156, 25).scaled(QSize(event->size().width() - 202, 25),
//                                                                         Qt::IgnoreAspectRatio,
//                                                                         Qt::SmoothTransformation));
//    paint->drawPixmap(event->size().width() - 82, 0, backgroundPix.copy(276, 0, 82, 25));
//    paint->end();
//    //setPixmap(QPixmap::fromImage(displayImg));
//    QPalette pal(palette());
//    pal.setBrush(QPalette::Window,QBrush(img));
//    //    pal.setBrush(QPalette::Window,
//    //                 QBrush(backgroundPix.scaled(event->size(),
//    //                                              Qt::IgnoreAspectRatio,
//    //                                              Qt::SmoothTransformation)));
//    setPalette(pal);



//    //设置掩板
//    //生成一张位图
//    QBitmap objBitmap(size());
//    //QPainter用于在位图上绘画
//    QPainter painter(&objBitmap);
//    //填充位图矩形框(用白色填充)
//    painter.fillRect(rect(),Qt::white);
//    painter.setBrush(QColor(0,0,0));
//    //在位图上画圆角矩形(用黑色填充)
//    painter.drawRoundedRect(this->rect(),8,8);
//    //使用setmask过滤即可
//    setMask(objBitmap);

//    //移动右侧按钮的位置
//    minimizeButton->move(size().width() - 41, 4);
//    normalModeButton->move(size().width() - 29, 4);
//    exitButton->move(size().width() - 17, 4);


//}






//void MiniWindow::paintEvent(QPaintEvent *)
//{
//    QPainter painter(this);//创建一个QPainter对象
//    painter.drawPixmap(0,0,QPixmap(":/images/Watermelon.png"));//绘制图片到窗口
//    /*
//      QPixmap(":/images/Watermelon.png")如果改为QPixmap()，则只能看到绘制出的框架，看不到图片颜色，也就是看不到图片。
//    */
//}

void MiniWindow::minimize()
{
    this->hide();
    if(isMiniStatusLabelHidden == false)
        statusWidget->hide();
}

void MiniWindow::showStatusWedgit()
{

    if(isMiniStatusLabelHidden == true){
        isMiniStatusLabelHidden = false;
        statusWidget->setHidden(false);

    }
    else{
        isMiniStatusLabelHidden = true;
        statusWidget->setHidden(true);
    }

}

//void MiniWindow::toNormalMode()
//{
////    mainWindow->show();
////    if(isNormalListWindowHidden == false)
////        listWindow->show();
//    statusWidget->hide();
//    this->hide();
//}

void MiniWindow::close()
{
//    listWindow->close();
//    mainWindow->close();
    statusWidget->close();
    QWidget::close();
}

bool MiniWindow::statusWidgetHidden()
{
    return isMiniStatusLabelHidden;
}

void MiniWindow::setStatusWidgetHidden(bool flag)
{
    if(flag == true)
        statusWidget->hide();
    else
        statusWidget->show();
}


