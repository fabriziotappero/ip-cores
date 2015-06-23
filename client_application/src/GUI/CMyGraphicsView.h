/*
 * Thanks to the autor of http://www.qtcentre.org/wiki/index.php?title=QGraphicsView:_Smooth_Panning_and_Zooming
 */

#ifndef CMyGraphicsView_H
#define CMyGraphicsView_H

#include <QGraphicsView>
#include <QGraphicsRectItem>
#include <QGraphicsScene>

class CMyGraphicsView : public QGraphicsView
{
	Q_OBJECT

public:
	CMyGraphicsView(QWidget* parent = NULL);

	QGraphicsScene* Scene;

protected:
	//Holds the current centerpoint for the view, used for panning and zooming
	QPointF CurrentCenterPoint;

	//From panning the view
	QPoint LastPanPoint;

	//Set the current centerpoint in the
	void SetCenter(const QPointF& centerPoint);
	QPointF GetCenter() { return CurrentCenterPoint; }

	//Take over the interaction
	virtual void mousePressEvent(QMouseEvent* event);
	virtual void mouseReleaseEvent(QMouseEvent* event);
	virtual void mouseMoveEvent(QMouseEvent* event);
	virtual void wheelEvent(QWheelEvent* event);
	virtual void resizeEvent(QResizeEvent* event);
};

#endif // CMyGraphicsView_H
