#ifndef MENUBAR_H
#define MENUBAR_H

#include <QMenuBar>

class MenuBar : public QMenuBar
{
public:
    MenuBar(QWidget *parent = 0 );

private:
    void mousePressEvent(QMouseEvent *);        //自定义一个鼠标点击事件函数
    void mouseMoveEvent(QMouseEvent *);         //自定义一个鼠标拖动事件函数
    void mouseReleaseEvent(QMouseEvent *);

};

#endif // MENUBAR_H
