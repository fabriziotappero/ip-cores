#ifndef SPLITTER_H
#define SPLITTER_H

#include <QSplitter>

class Splitter : public QSplitter
{
    Q_OBJECT
public:
    explicit Splitter(QWidget *parent = 0);
    Splitter(Qt::Orientation orientation, QWidget *parent = 0 );

signals:

public slots:

private:
    void mousePressEvent(QMouseEvent *);        //自定义一个鼠标点击事件函数
    void mouseMoveEvent(QMouseEvent *);         //自定义一个鼠标拖动事件函数
    void mouseReleaseEvent(QMouseEvent *);
    //void resizeEvent(QResizeEvent *);
    void contextMenuEvent(QContextMenuEvent *event);
};

#endif // SPLITTER_H
