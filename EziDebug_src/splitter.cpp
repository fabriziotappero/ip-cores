#include "splitter.h"

#include <QtGui>
#include <QDebug>

Splitter::Splitter(QWidget *parent) :
    QSplitter(parent)
{
    QTextCodec::setCodecForTr(QTextCodec::codecForName("gb18030"));
    setMouseTracking (true);

}

Splitter::Splitter(Qt::Orientation orientation, QWidget *parent):
    QSplitter(orientation, parent)
{
    setMouseTracking (true);

}

//鼠标按下事件
void Splitter::mousePressEvent(QMouseEvent *event)
{
//    if (event->button() == Qt::LeftButton)
//    {
//        if(event->y()<5 || event->x()<5 || rect().width()-event->x()<5 || rect().height()-event->y()<5 )
//        {
////            int a  = rect().height();
////            int b = event->y();
////            int c = rect().width();
////            QRect r = geometry();
//            event->ignore();
//            return;
//        }
//        else
//        {
//            event->accept();
//        }
//    }
    //qDebug()<< "Splitter::mousePressEvent";
    QSplitter::mousePressEvent(event);
    event->ignore();
//    event->accept();
}
//鼠标移动事件
void Splitter::mouseMoveEvent(QMouseEvent *event)
{
    //qDebug()<< "Splitter::mouseMoveEvent";
    QSplitter::mouseMoveEvent(event);
    event->ignore();
//  event->accept();
}

void Splitter::mouseReleaseEvent(QMouseEvent *event)
{
    //qDebug()<< "Splitter::mouseReleaseEvent";
    QSplitter::mouseReleaseEvent(event);
    event->ignore();
//    event->accept();
}

////缩放时调用该函数
//void Splitter::resizeEvent(QResizeEvent *event)
//{
//    QSize s = event->size();
//    QRect r = rect();
//    QSize s2 = event->oldSize();
//    QWidget::resizeEvent(event);
//    this->resize(event->size());

//}
void Splitter::contextMenuEvent(QContextMenuEvent *event)
{
//    QMenu* popMenu = new QMenu(this);
//    popMenu->addAction(new QAction(tr("添加"), this));
//    popMenu->addAction(new QAction(tr("删除"), this));
////    if(this->itemAt(mapFromGlobal(QCursor::pos())) != NULL) //如果有item则添加"修改"菜单 [1]*
////    {
////        popMenu->addAction(new QAction("修改", this));
////    }

//    popMenu->exec(QCursor::pos()); // 菜单出现的位置为当前鼠标的位置
}

