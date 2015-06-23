#ifndef TREEVIEW_H
#define TREEVIEW_H

#include <QTreeView>
class TreeView : public QTreeView
{
    Q_OBJECT
public:
    explicit TreeView(QWidget *parent = 0);

private:
    void mouseMoveEvent(QMouseEvent *event);         //自定义一个鼠标拖动事件函数

};

#endif // TREEVIEW_H
