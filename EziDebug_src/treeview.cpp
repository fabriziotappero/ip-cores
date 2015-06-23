#include <QtGui>
#include "treeview.h"

TreeView::TreeView(QWidget *parent):QTreeView(parent)
{
    setMouseTracking(true);
}

void TreeView::mouseMoveEvent(QMouseEvent *event)
{
    QTreeView::mouseMoveEvent(event) ;
    event->ignore();
}


