#ifndef TITLEBAR_H
#define TITLEBAR_H

#include <QWidget>

#include "button.h"

//#typedef  5 VALUE_DIS
const int VALUE_DIS = 5;

QT_BEGIN_NAMESPACE
//class QAction;
//class QActionGroup;
class QLabel;
class QPoint;
class QHBoxLayout;
//class QPushButton;
class QToolButton;
//class QTreeWidget;
//class QImage;
//class FindDialog;
QT_END_NAMESPACE

class TitleBar : public QWidget
{
    Q_OBJECT
public:
    explicit TitleBar(QWidget *parent = 0);

    //枚举，按钮状态
    enum eBtnMoustState{
        eBtnStateNone,//无效
        eBtnStateDefault,//默认值(如按钮初始显示)
        eBtnStateHover,//鼠标移到按钮上状态
        eBtnStatePress//鼠标按下按钮时状态
    };

    Button *closeButton;//关闭按钮


//    QLabel *iconLabel;//最左侧的小图标
//    QLabel *lineLabel;//中间的长直线
//    QLabel *closeButtonLabel;//最右侧关闭按键的图标

signals:

public slots:

private:
    void mousePressEvent(QMouseEvent *);        //自定义一个鼠标点击事件函数
    void mouseMoveEvent(QMouseEvent *);         //自定义一个鼠标拖动事件函数
    void mouseReleaseEvent(QMouseEvent *);
    void resizeEvent(QResizeEvent *);

    QPoint pointPress;//记录按下鼠标左键时的全局位置
    QPoint pointMove;//记录鼠标移动后的全局位置
    bool isLeftButtonPress;//是否点击鼠标左键

    QHBoxLayout *layout;
//  QPixmap background;//背景图片



    void CreateWidget();//创建子部件
    void SetWidgetStyle();//设置子部件样式(qss)
    void CreateLayout();//创建设置布局

    //void SetBtnIcon(QToolButton *pBtn,eBtnMoustState state,bool bInit=false);//设置按钮不同状态下的图标

};

#endif // TITLEBAR_H
