#ifndef LISTWINDOW_H
#define LISTWINDOW_H

#include <QWidget>

//#include "toolwindow.h"
//#include "miniwindow.h"
#include "listwindow.h"
#include "projectsetwizard.h"
#include "finddialog.h"

#include "button.h"

#include "titlebar.h"
#include "menubar.h"
#include "splitter.h"
#include "treemodel.h"


QT_BEGIN_NAMESPACE
class QAction;
class QActionGroup;
class QLabel;
class QMenu;
class QMenuBar;
class QPushButton;
class QSplitter;
class QTreeWidget;
class QImage;
class TreeView;
class EziDebugTreeModel ;
class QStandardItemModel ;
class QStandardItem ;
class EziDebugPrj ;
//class FindDialog;
QT_END_NAMESPACE

class ListWindow : public QWidget
{
    Q_OBJECT
public:
    explicit ListWindow(QWidget *parent = 0, Qt::WindowFlags f = 0 );
    ~ListWindow();
    QStandardItem *addMessage(const QString &type ,const QString &message,QStandardItem *parentitem = NULL) ;
    //列表窗口是否隐藏
    bool isListWindowHidden();
    void setListWindowHidden(bool flag);
    void enterEvent(QEvent * event);
    void leaveEvent(QEvent * event);
    void setChainActEnable(bool addenable,bool delenable);
    EziDebugInstanceTreeItem * getCurrentTreeItem(void);
    void setCurrentTreeItem(EziDebugInstanceTreeItem * item);
    void clearTreeView(void) ;
    void welcomeinfoinit(EziDebugPrj *prj) ;

    //列表窗口是否吸附在工具栏窗口
    //bool isListWindowAdsorbed();
    //获取ToolWindow的指针，以获取其位置等信息
    void getToolWindowPointer(QWidget *toolWin);
    bool windowIsStick(void) const
    {
        return isStick;
    }
    void setWindowStick(bool stick)
    {
        isStick = stick ;
    }


    enum enum_Direction{
        eNone = 0,
        eTop,
        eBottom,
        eRight,
        eLeft,
        eTopRight,
        eBottomLeft,
        eRightBottom,
        eLeftTop
    };


signals:
    void mouseReleased(const QRect rect);//窗口移动后，将listWindow的窗口位置发送给toolWindow

public slots:
    //右上角标题栏按钮
    void close();//仅隐藏列表窗口

    //算法中用到的槽
    //void proSetting();
    //void proUpdate();
    //void deleteChain();
    void testbenchGeneration();

private slots:

//    //其它窗口和本窗口有关的标题栏按钮
//    void closeAll();//迷你模式和工具栏窗口关闭时，触发该槽，关闭所有窗口
//    void toMiniMode();  //普通模式转换到迷你模式
//    void toNormalMode();//迷你模式转换到普通模式
    //void moveListWindow(const QPoint &p, QPoint bottomLeft, QPoint bottomRight);//移动ListWindow到点p




    void find();
    void about();
    void show_contextmenu(const QPoint& pos) ;
    void generateTreeView(EziDebugInstanceTreeItem* item);



private:
    void createActions();   //创建选项
    void createMenus();     //创建菜单
    void createButtons();   //创建按钮
    //listwindow中现无button,该函数现已不用,关闭按钮在类titlebar中实现
    QPushButton *createToolButton(const QString &toolTip, const QIcon &icon, const QSize &size, const char *member);
    void mousePressEvent(QMouseEvent *);        //自定义一个鼠标点击事件函数
    void mouseMoveEvent(QMouseEvent *);         //自定义一个鼠标拖动事件函数
    void mouseReleaseEvent(QMouseEvent *);
    void moveEvent(QMoveEvent *);  // 窗体移动事件
//    void paintEvent(QPaintEvent *);             //自定义一个刷屏事件函数
    void resizeEvent(QResizeEvent *event);      //自定义一个改变窗口大小事件函数，随着窗体变化而设置背景

    void mouseDoubleClickEvent(QMouseEvent *event);//自定义一个鼠标双击事件函数
    void SetCursorStyle(enum_Direction direction);//设置鼠标样式
    int PointValid(int x, int y);//判断鼠标所在位置在当前窗口的哪个边界（上下左右）上
    void SetDrayMove(int nXGlobal,int nYGlobal,enum_Direction direction);//设置鼠标拖动的窗口位置信息
    void magneticMove(const QRect &bechmarkRect, const QRect &targetRect) ;

    //菜单
    MenuBar *menuBar;
    QMenu *addMenu;
    QMenu *checkMenu;
    QMenu *sortMenu;
    QMenu *findMenu;
    QMenu *helpMenu;
    QMenu * m_pcontextMenu ;


    QAction *proSettingWizardAct;   //工程设置向导
    QAction *setProPathAct;     //设置工程目录
    QAction *setRegNumACt;      //设置每条链的寄存器个数
    QAction *useVerilogAct;    //使用verilog语言
    QAction *useVHDLAct;        //使用VHDL语言
    QAction *useMixeLanguagedAct;    //使用混合语言
    QAction *setSlotAct;        //设置计时器的时钟
    QAction *useAlteraAct;      //使用Altera
    QAction *useXilinxAct;      //使用Xilinx
    QAction *exitAct;           //退出

    QAction *rankAfterFileNameAct;  //按文件名
    QAction *rankAfterPathNameAct;  //按路径名

    QAction *fastOrientAct; //快速定位
    QAction *findAct;       //查找
    QAction *findNextAct;   //查找下一个

    QAction *aboutEziDebugAct;  //关于
    QAction *helpFileAct;   //帮助文件

    QAction *m_paddChainAct ;  // 添加链
    QAction *m_pdeleteChainAct ; // 删除链

    //右上角标题栏按钮
    //QPushButton *exitButton;  //退出
    Button * closeButton ;
    QPushButton * button1 ;

    Splitter *mainSplitter;
    QTreeWidget *modulesTreeWidget;
    QTreeWidget *chainsTreeWidget;
    TreeItem*  m_ptestTreeItem ; // 测试存放右键点击获得的树状节点
    EziDebugInstanceTreeItem * m_ptreeItem ; //
    TreeModel *moduleTree;//存放各个module及其相互关系的树型列表
    EziDebugTreeModel * m_peziDebugTreeModel ;
    TreeView *moduleTreeView;  //显示module树的view
    TreeView *m_pmessageTreeView ;
    QStandardItemModel *m_iShowMessageModel ;
	
	
    //窗口缩放需要的变量
    TitleBar *titleBar;//标题栏
    QPoint pointPressGlobal;//记录按下鼠标左键时的全局位置
    QPoint pointMove;//记录鼠标移动后的全局位置
    QRect rectRestoreWindow;//记录当前窗口的大小和位置
    bool isLeftButtonPress;//是否点击鼠标左键
    bool isMaxWin;//该窗口是否最大化
    bool isStick;
    bool isDrag;


    QPoint oldPointGlobal;
    QPoint NewPointGlobal;
    QPoint oldWindowPoint ;
    QPoint mousePressPoint ;  //记录鼠标按下时的相对坐标
    QPoint mouseMovePoint ;  // 记录鼠标移动中的相对坐标
    QRect  parentRect ; // 记录父窗口的坐标
    QPoint diffPos;    // 相对坐标差

    enum_Direction eDirection;//记录鼠标在那个方向

    QWidget *toolWindow;//指向ToolWindow的指针
	
	
    bool isListWindowHiddenFlag;//普通模式下，ToolWindow不隐藏时，列表窗口是否隐藏
    //bool isListWindowAdsorbedFlag;//普通模式下,列表界面是否吸附在工具栏窗口的下方



    //定义一个QPoint的成员变量，记录窗口移动的位置
    QPoint dragPosition;

    //窗口背景图片
    QPixmap listBackground;

    //各个Action和Button调用的对话框

    FindDialog *findDialog;//查找

    //算法中用到的参数
    QString proPathStr;         //工程目录
    QVector<int> regNumVector;  //每条链的寄存器个数
    bool isUseVerilog;          //使用verilog语言
    bool isUseVHDL;             //使用VHDL语言
    int slot;                   //计时器的时钟
    bool isUseAlteraAct;        //使用Altera
    bool isUseXilinxAct;        //使用Xilinx

    //QList<QStandardItem*> m_iitemList ;
};

#endif // LISTWINDOW_H
