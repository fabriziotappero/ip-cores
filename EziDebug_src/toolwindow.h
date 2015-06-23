#ifndef TOOLWINDOW_H
#define TOOLWINDOW_H

#include <QWidget>
#include <QSystemTrayIcon>

#include "miniwindow.h"
#include "listwindow.h"
//#include "ezidebugprj.h"
#include "projectsetwizard.h"


QT_BEGIN_NAMESPACE
class QAction;
class QLabel;
class Button;
class QProgressBar;
class QMenu;
class QSystemTrayIcon;
class EziDebugPrj ;
class QTimer ;
QT_END_NAMESPACE

class ToolWindow : public QWidget
{
    Q_OBJECT
public:

    explicit ToolWindow(QWidget *parent = 0);
//    bool eventFilter(QObject *, QEvent *);
    ~ToolWindow();

//    //列表窗口是否隐藏
//    void setListWindowHiddenFlag(bool flag);
//    bool getListWindowHiddenFlag();
//    //列表窗口是否吸附在工具栏窗口
      void  setListWindowAdsorbedFlag(bool flag);
      const EziDebugPrj* getCurrentProject(void) const; // 获取当前工程指针
      void  setCurrentProject(EziDebugPrj*);  // 设置当前工程指针
      void  listwindowInfoInit(void) ;


//    bool getListWindowAdsorbedFlag();
    //void getListWindowPointer(QWidget *listWindow);

signals:
     void updateTreeView(EziDebugInstanceTreeItem* item);
    //void closeToolWindow();//关闭本窗口
    //void hideListWindow();
    //void showListWindow();
    //void moveListWindow(const QPoint &p, QPoint bottomLeft, QPoint bottomRight);//移动ListWindow到点p
    //void toMiniMode();  //普通模式转换到迷你模式

public slots:
    //右上角标题栏按钮
    void minimize();    //最小化
    void toMiniMode();  //转换到迷你模式
    void close();       //关闭
    void updateIndicate(); // 更新提示
    void fastUpdate();    // 快速更新
    void changeUpdatePic() ;
    void changeProgressBar(int value) ;

    void about();//关于
    void help();//帮助

    //从最小化还原
    void showNormal();
    //右侧中部按钮，打开toolwindow下方的列表窗口
    void showListWindow();
    //系统托盘相关函数
    void iconActivated(QSystemTrayIcon::ActivationReason reason);

    //迷你模式
    void toNormalMode();//转换到普通模式
    void miniWindowMinimized();//最小化时修改相应菜单选项
    void proSetting(); // 工程设置
    void proUpdate() ; // 工程更新
    //void proPartlyUpdate();// 工程部分更新
    int  deleteScanChain(); // 删除一条扫描链
    void addScanChain();    // 添加一条扫描链
    int  deleteAllChain();  // 删除所有扫描链
    void undoOperation(); // 取消上一步操作
    void testbenchGeneration(); // 生成testbench

    //    改为由listWindow中的slot执行//四个工程操作对应的按钮
    //    void proSetting();
    //    void proUpdate();
    //    void deleteChain();
    //    void testbenchGeneration();



    void progressBarDemo();//进度条演示
    void listWindowMouseReleased(const QRect rect);//listWindow的窗口移动或缩放后，判断listWindow是否吸附

protected:


private:
    void createActions();   //创建右键菜单的选项
    void createButtons();   //创建按钮
    Button *createToolButton(const QString &toolTip, const QString &iconstr,
                             const QSize &size, const QObject * receiver, const char *member);
    void contextMenuEvent(QContextMenuEvent *event);//自定义右键菜单
    void mousePressEvent(QMouseEvent *);        //自定义一个鼠标点击事件函数
    void mouseMoveEvent(QMouseEvent *);         //自定义一个鼠标拖动事件函数
    void paintEvent(QPaintEvent *);             //自定义一个刷屏事件函数
    void showEvent(QShowEvent*);                //自定义一个窗口显示事件函数
    void readSetting();                         //读取上次软件保存的工程信息
    void writeSetting();                        //保存软件打开工程的信息


    //系统托盘相关函数
    void CreatTrayMenu();
    void creatTrayIcon();
    void closeEvent(QCloseEvent *event);



    //另外两个窗口
    MiniWindow *miniWindow;//迷你模式下的主窗口和状态栏
    ListWindow *listWindow;//普通模式下的工具栏窗口
    ProjectSetWizard * m_proSetWiz;//工程设置向导
//  EziDebugPrj* m_pcurrentPrj ;

    //系统托盘及其菜单
    QSystemTrayIcon *myTrayIcon;
    QAction *miniSizeAction;
    QAction *maxSizeAction;
    QAction *restoreWinAction;
    QAction *quitAction;
    QAction *aboutAction;
    QAction *helpAction;
    QMenu *myMenu;



    //右键菜单的选项
    QAction *exitAct;//退出
    QAction *minimizeAct;   //最小化
    QAction *toMiniModeAct; //转换到迷你模式模式
    QAction *aboutAct;
    QAction *helpAct;

    //工具栏按钮
    Button *proSettingButton;  //工程设置
    Button *proUpdateButton;   //更新
    Button *proPartlyUpdateButton;   //部分更新
    Button *deleteChainButton; //删除
    Button *testbenchGenerationButton;//testbench生成
    Button *proUndoButton;   //撤销（undo）
    QPushButton *updatehintButton ; // 提示更新按钮
    QLabel * m_iplogolabel ;  // 放logo

    EziDebugPrj *currentPrj ;


    //右上角标题栏按钮
    Button *minimizeButton;   //最小化
    Button *miniModeButton;//迷你模式
    Button *exitButton;  //退出

    //进度条
    QProgressBar *progressBar ;

    //打开ListWindow
    Button *showListWindowButton;

    //定义一个QPoint的成员变量，记录窗口移动的位置
    QPoint dragPosition;
    QPoint oriGlobalPos;//鼠标左键按下的位置

//    bool isNormalListWindowHidden;//普通模式下，ToolWindow不隐藏时，列表窗口是否隐藏
    bool isListWindowAdsorbed;//普通模式下,列表界面是否吸附在工具栏窗口的下方
//    QWidget *listWindowPointer;//指向ListWindow的指针
    bool isNormalMode;//true--Normal Mode,false--Mini Mode
    bool isNeededUpdate ;

    QTimer *iChangeUpdateButtonTimer ;



};

#endif // TOOLWINDOW_H
