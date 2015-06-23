#ifndef BUTTON_H
#define BUTTON_H

#include <QPushButton>

class Button : public QPushButton
{
    Q_OBJECT
public:
    explicit Button(QWidget *parent = 0);
    Button(QString str, QWidget *parent = 0);

    void setButtonPicture(QPixmap pic);
    void setPressPicture(QPixmap pic);
    void setReleasePicture(QPixmap pic);
    void setEnterPicture(QPixmap pic);
    void setLeavePicture(QPixmap pic);
    void set_X_Y_width_height(int x, int y, int width, int height);
    void resizeit(int w , int h);

signals:

public slots:

private:
    void mouseDoubleClickEvent(QMouseEvent *event);
    void mousePressEvent (QMouseEvent *event);
    void mouseMoveEvent(QMouseEvent *event);
    void mouseReleaseEvent (QMouseEvent *event);
    void enterEvent(QEvent *);
    void leaveEvent(QEvent *);

    QPixmap *buttonPicture;
    QPixmap *pressPicture ;
    QPixmap *releasePicture;
    QPixmap *enterPicture ;
    QPixmap *leavePicture ;
    bool flag;//鼠标enter时为true，鼠标leave时为false




};

#endif // BUTTON_H
