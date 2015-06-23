#ifndef MINIWINDOW_H
#define MINIWINDOW_H

#include <QWidget>
#include "button.h"

QT_BEGIN_NAMESPACE
class QAction;
class QLabel;
class QPushButton;
class QPoint;
QT_END_NAMESPACE

class MiniWindow : public QWidget
{
    Q_OBJECT
public:
    explicit MiniWindow(QWidget *parent = 0);
    bool statusWidgetHidden();
    void setStatusWidgetHidden(bool);
    enum enum_Direction{
        eNone = 0,
        eRight,
        eLeft};

    //工具栏按钮  
    Button *proSettingButton;  //工程设置
    Button *proUpdateButton;   //更新
    Button *proPartlyUpdateButton;   //部分更新
    Button *deleteChainButton; //删除
    Button *testbenchGenerationButton;//testbench生成
    Button *proUndoButton;   //撤销（undo）

    //右上角标题栏按钮
    QPushButton *minimizeButton;    //最小化
    QPushButton *showStatusButton;  //显示运行状态//已删除
    QPushButton *normalModeButton;  //普通模式
    QPushButton *exitButton;        //退出
signals:
    void toNormalMode();

public slots:
    //右上角标题栏按钮
    void minimize();
    void showStatusWedgit();
    void close();

protected:
    void contextMenuEvent(QContextMenuEvent *event);

private slots:
//    //四个工程操作对应的按钮//在类toolwindow中实现
//    void proSetting();
//    void proUpdate();
//    void deleteChain();
//    void testbenchGeneration();

private:
    void createActions();   //创建右键菜单的选项
    void createButtons();   //创建按钮
    //仅作显示用,connect在类toolwindow中完成
    //QPushButton *createToolButton(const QString &toolTip, const QIcon &icon, const QSize &size, const char *member);
    Button *createToolButton(const QString &toolTip, const QString &iconstr,const QSize &size);

    void mousePressEvent(QMouseEvent *);        //自定义一个鼠标点击事件函数
    void mouseMoveEvent(QMouseEvent *);         //自定义一个鼠标拖动事件函数
//    void mouseReleaseEvent(QMouseEvent *event);
//    //void paintEvent(QPaintEvent *);             //自定义一个刷屏事件函数
//    void resizeEvent(QResizeEvent *event);      //自定义一个改变窗口大小事件函数，随着窗体变化而设置背景

    //void mouseDoubleClickEvent(QMouseEvent *event);//自定义一个鼠标双击事件函数
//    void SetCursorStyle(enum_Direction direction);//设置鼠标样式
//    int PointValid(int x);//判断鼠标所在位置在当前窗口的哪个边界（左右）上
//    void SetDrayMove(int nXGlobal,enum_Direction direction);//设置鼠标拖动的窗口位置信息

    //右键菜单的选项
    QAction *exitAct;//退出
    QAction *minimizeAct;   //最小化
    QAction *toNormalModeAct; //转换到普通模式模式


    //定义一个QPoint的成员变量，记录窗口移动的位置
    QPoint dragPosition;

    //迷你模式下的状态栏
    QWidget *statusWidget;
    QLabel *statusLabel;//运行状态
    bool isMiniStatusLabelHidden;//mini模式下状态栏是否隐藏

    //窗口缩放需要的变量
    QPixmap backgroundPix;//窗口背景图片
    QPoint pointPressGlobal;//记录按下鼠标左键时的全局位置
    QPoint pointMove;//记录鼠标移动后的全局位置
    QRect rectRestoreWindow;//记录当前窗口的大小和位置
    bool isLeftButtonPress;//是否点击鼠标左键
    bool isWindowMovement ;//是否是窗口移动
    enum_Direction eDirection;//记录鼠标在那个方向


    //各个Action和Button调用的对话框


};

#endif // MINIWINDOW_H
