#include "titlebar.h"
#include "listwindow.h"

#include <QtGui>
TitleBar::TitleBar(QWidget *parent) :
    QWidget(parent)
{
    //test
//    setAutoFillBackground(true);
//    QPixmap backgroundPix;
//    QPalette palette;
//    backgroundPix.load(":/images/mainBackground.bmp",0,Qt::AvoidDither|Qt::ThresholdDither|Qt::ThresholdAlphaDither);
//    palette.setBrush(QPalette::Background, QBrush(backgroundPix.copy(0,0,290,17)));
//    this->setPalette(palette);


    QTextCodec::setCodecForTr(QTextCodec::codecForName("gb18030"));
    setMouseTracking (true);
    //setCursor(Qt::ArrowCursor);
    isLeftButtonPress = false;

    CreateWidget();//创建子部件
    //SetWidgetStyle();//设置子部件样式(qss)
    //CreateLayout();//创建设置布局
}






//创建子部件
void TitleBar::CreateWidget()
{
//    background.load(":/images/listBackground.bmp",
//                        0,Qt::AvoidDither|Qt::ThresholdDither|Qt::ThresholdAlphaDither);
//    //background = background.copy(0, 0, background.width(), 17);
//    background = background.copy(0, 4, background.width(), 13);




//    QPixmap objPixmap(background);

//    iconLabel = new QLabel(this);//最左侧的小图标
//    iconLabel->setPixmap(objPixmap.copy(5, 0, 20, 13));

//    lineLabel = new QLabel(this);//中间的长直线
//    lineLabel->setPixmap(objPixmap.copy(25, 0, 235, 13));

//    closeButtonLabel = new QLabel(this);//最右侧关闭按键的图标
//    closeButtonLabel->setPixmap(objPixmap.copy(260, 0, background.width() - 259-5, 13));
//    closeButtonLabel->setCursor(Qt::PointingHandCursor);


    //setGeometry(QRect(0, 0, 290, 17));
    setMinimumSize(423, 26);
    setFixedHeight(26);
    closeButton = new Button(tr(":/images/ListWindowExit.bmp"), this);
    closeButton->setIconSize(QSize(33, 19));
    closeButton->setGeometry(QRect(385, 0, 33, 19));
    setContentsMargins(0,0,0,0);


//    //图像标签--logo
//    m_pLabelIcon = new QLabel(this);
//    QPixmap objPixmap(":/image/360AboutLogo.png");
//    m_pLabelIcon->setPixmap(objPixmap.scaled(TITLE_H,TITLE_H));
//    //文本标签--标题
//    m_pLabelTitle = new QLabel(this);
//    m_pLabelTitle->setText(QString("360 Safe Guard V8.5"));
//    //文本标签--样式版本
//    m_pLabelVersion = new QLabel(this);
//    m_pLabelVersion->setText(QString("Use Class Style"));
//    //设置鼠标形状
//    m_pLabelVersion->setCursor(Qt::PointingHandCursor);
//    //按钮--更换皮肤
//    m_pBtnSkin = new QToolButton(this);
//    //设置初始图片
//    SetBtnIcon(m_pBtnSkin,eBtnStateDefault,true);
//    //按钮--菜单
//    m_pBtnMenu = new QToolButton(this);
//    SetBtnIcon(m_pBtnMenu,eBtnStateDefault,true);
//    //按钮--最小化
//    m_pBtnMin = new QToolButton(this);
//    SetBtnIcon(m_pBtnMin,eBtnStateDefault,true);
//    //按钮--最大化/还原
//    m_pBtnMax = new QToolButton(this);
//    SetBtnIcon(m_pBtnMax,eBtnStateDefault,true);
//    //按钮--关闭
//    m_pBtnClose = new QToolButton(this);
//    SetBtnIcon(m_pBtnClose,eBtnStateDefault,true);
    //获得子部件
    const QObjectList &objList = children();
    for(int nIndex=0; nIndex < objList.count(); ++nIndex)
    {
        //设置子部件的MouseTracking属性
        ((QWidget*)(objList.at(nIndex)))->setMouseTracking(true);
//        //如果是QToolButton部件
//        if(0==qstrcmp(objList.at(nIndex)->metaObject()->className(),"QToolButton"))
//        {
//            //连接pressed信号为slot_btnpress
//            connect(((QToolButton*)(objList.at(nIndex))),SIGNAL(pressed()),this,SLOT(slot_btnpress()));
//            //连接clicked信号为slot_btnclick
//            connect(((QToolButton*)(objList.at(nIndex))),SIGNAL(clicked()),this,SLOT(slot_btnclick()));
//            //设置顶部间距
//            ((QToolButton*)(objList.at(nIndex)))->setContentsMargins(0,VALUE_DIS,0,0);
//        }
    }
}

//设置子部件样式(qss)
void TitleBar::SetWidgetStyle()
{
    //设置标签的文本颜色，大小等以及按钮的边框
    setStyleSheet("QLabel{color:#CCCCCC;font-size:12px;font-weight:bold;}Button{border:0px;}");
    //设置左边距
   // m_pLabelTitle->setStyleSheet("margin-left:6px;");
    //设置右边距以及鼠标移上去时的文本颜色
    //m_pLabelVersion->setStyleSheet("QLabel{margin-right:10px;}QLabel:hover{color:#00AA00;}");
}

//创建设置布局
void TitleBar::CreateLayout()
{
    //水平布局
//    layout = new QHBoxLayout(this);
//    //添加部件
////    layout->addWidget(iconLabel);
////    layout->addWidget(lineLabel);
//    //添加伸缩项
//    layout->addStretch(1);
//    //添加部件
//    layout->addWidget(closeButton);
////    layout->addWidget(m_pBtnSkin);
////    layout->addWidget(m_pBtnMenu);
////    layout->addWidget(m_pBtnMin);
////    layout->addWidget(m_pBtnMax);
////    layout->addWidget(m_pBtnClose);
//    //设置Margin
//    layout->setContentsMargins(0,0,0,0);
////    layout->setContentsMargins(0,0,VALUE_DIS,0);

//    //设置部件之间的space
//    layout->setSpacing(0);
//    setLayout(layout);
}



//设置按钮不同状态下的图标
//void TitleBar::SetBtnIcon(QToolButton *pBtn,eBtnMoustState state,bool bInit/*=false*/)
//{
//    //获得图片路径
//    QString strImagePath = GetBtnImagePath(pBtn,bInit);
//    //创建QPixmap对象
//    QPixmap objPixmap(strImagePath);
//    //得到图像宽和高
//    int nPixWidth = objPixmap.width();
//    int nPixHeight = objPixmap.height();
//    //如果状态不是无效值
//    if(state!=eBtnStateNone)
//    {
//        /*设置按钮图片
//按钮的图片是连续在一起的，如前1/4部分表示默认状态下的图片部分,接后的1/4部分表示鼠标移到按钮状态下的图片部分
//*/
//        pBtn->setIcon(objPixmap.copy((nPixWidth/4)*(state-1),0,nPixWidth/4,nPixHeight));
//        //设置按钮图片大小
//        pBtn->setIconSize(QSize(nPixWidth/4,nPixHeight));
//    }
//}

////获得图片路径(固定值)
//const QString TitleBar::GetBtnImagePath(QToolButton *pBtn,bool bInit/*=false*/)
//{
//    QString strImagePath;
//    //皮肤按钮
//    if(m_pBtnSkin==pBtn)
//    {
//        strImagePath = ":/image/SkinButtom.png";
//    }
//    //菜单按钮
//    if(m_pBtnMenu==pBtn)
//    {
//        strImagePath = ":/image/title_bar_menu.png";
//    }
//    //最小化
//    if(m_pBtnMin==pBtn)
//    {
//        strImagePath = ":/image/sys_button_min.png";
//    }
//    //最大化/还原按钮，所以包括最大化和还原两张图片
//    if(m_pBtnMax==pBtn)
//    {
//        //如果是初始设置或者主界面的最大化标志不为真(其中MainWindow::Instance()使用单例设计模式)
//        if(bInit==true || MainWindow::Instance()->GetMaxWin()==false)
//        {
//            //最大化按钮图片路径
//            strImagePath = ":/image/sys_button_max.png";
//        }
//        else
//        {
//            //还原按钮图片路径
//            strImagePath = ":/image/sys_button_restore.png";
//        }
//    }
//    //关闭按钮
//    if(m_pBtnClose==pBtn)
//    {
//        strImagePath = ":/image/sys_button_close.png";
//    }
//    return strImagePath;
//}

////创建事件过滤器
//void TitleBar::CreateEventFiter()
//{
//    m_pBtnSkin->installEventFilter(this);
//    m_pBtnMenu->installEventFilter(this);
//    m_pBtnMin->installEventFilter(this);
//    m_pBtnMax->installEventFilter(this);
//    m_pBtnClose->installEventFilter(this);
//}
////事件过滤
//bool TitleBar::eventFilter(QObject *obj, QEvent *event)
//{
//    //按钮状态
//    eBtnMoustState eState = eBtnStateNone;
//    //判断事件类型--QEvent::Enter
//    if (event->type() == QEvent::Enter)
//    {
//        eState = eBtnStateHover;
//    }
//    //判断事件类型--QEvent::Leave
//    if (event->type() == QEvent::Leave)
//    {
//        eState = eBtnStateDefault;
//    }
//    //判断事件类型--QEvent::MouseButtonPress
//    if (event->type() == QEvent::MouseButtonPress && ((QMouseEvent*)(event))->button()== Qt::LeftButton)
//    {
//        eState = eBtnStatePress;
//    }
//    //判断目标
//    if(m_pBtnSkin==obj || m_pBtnMenu==obj || m_pBtnMin==obj || m_pBtnMax==obj || m_pBtnClose==obj)
//    {
//        //如果状态有效
//        if(eState != eBtnStateNone)
//        {
//            //根据状态设置按钮图标
//            SetBtnIcon((QToolButton *)obj,eState);
//            return false;
//        }
//    }
//    return QWidget::eventFilter(obj,event);
//}

////槽函数--slot_btnclick
//void TitleBar::slot_btnclick()
//{
//    QToolButton *pBtn = (QToolButton*)(sender());
//    if(pBtn==m_pBtnMin)
//    {
//        emit signal_min();
//    }
//    if(pBtn==m_pBtnMax)
//    {
//        emit signal_maxrestore();
//    }
//    if(pBtn==m_pBtnClose)
//    {
//        emit signal_close();
//    }
//}













//鼠标按下事件
void TitleBar::mousePressEvent(QMouseEvent *event)
{
//    qDebug()<< "TitleBar mousePress Event" << "the relative coordination"<< event->x()<< event->y();
//    if (event->button() == Qt::LeftButton)
//    {
//        if(event->y()<VALUE_DIS||event->x()<VALUE_DIS||rect().width()-event->x()<5)
//        {
//            event->ignore();
//            return;
//        }
//        else
//        {
//            pointPress = event->globalPos();
//            isLeftButtonPress = true;
//            //test
//            event->accept();
//            return;
//        }
//    }

    event->ignore();
}



//鼠标移动事件
void TitleBar::mouseMoveEvent(QMouseEvent *event)
{
//    qDebug()<< "TitleBar mouseMove Event" << "the relative coordination"<< event->x()<< event->y();
//    if(isLeftButtonPress)//已经按下左键拖拽窗口
//    {
//        pointMove = event->globalPos();
//        //移动主窗口
//        ListWindow *pMainWindow = (qobject_cast<ListWindow *>(parent()));
//        pMainWindow->move(pMainWindow->pos() + pointMove - pointPress);
//        //重新设置pointPress;
//        pointPress = pointMove;

//        //test
//        event->accept();
////        event->ignore();
//        return;//
//    }
    event->ignore();
}
//鼠标释放事件
void TitleBar::mouseReleaseEvent(QMouseEvent *event)
{
//    qDebug() << "TitleBar::mouseReleaseEvent";
    if (event->button() == Qt::LeftButton)
    {
        isLeftButtonPress = false;

//        //获取父窗口指针
//        ListWindow *pMainWindow = (qobject_cast<ListWindow *>(parent()));
//                //如果ListWindow的上边沿和ToolWindow的下边沿靠近，则移至紧紧贴合的位置
//                int disY = pMainWindow->toolWindow->geometry().bottom() - pMainWindow->geometry().top();
//                if((disY < 15) && (disY > -15)){
//                    move(pMainWindow->geometry().left(), pMainWindow->geometry().top() + disY);//移动窗口
//                    pMainWindow->toolWindow->setListWindowAdsorbedFlag(true);
//                }
//                else{
//                    pMainWindow->toolWindow->setListWindowAdsorbedFlag(false);
//                }

    }
    event->ignore();
}

//缩放时调用该函数
void TitleBar::resizeEvent(QResizeEvent *event)
{
    QWidget::resizeEvent(event);
    closeButton->move(size().width() - 38, 0);

}
