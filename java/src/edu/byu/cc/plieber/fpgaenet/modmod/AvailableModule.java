package edu.byu.cc.plieber.fpgaenet.modmod;

import java.util.ArrayList;

import com.trolltech.qt.core.QByteArray;
import com.trolltech.qt.core.QMimeData;
import com.trolltech.qt.core.QPoint;
import com.trolltech.qt.core.Qt;
import com.trolltech.qt.gui.*;

public class AvailableModule extends QLabel {

	private ModuleContainer parentContainer;

	public AvailableModule() {
		super();
		this.setup(null, null);
	}

	public AvailableModule(String text, QWidget parent) {
		super(text, parent);
		this.setup(null, null);
	}

	public AvailableModule(String text) {
		super(text);
		this.setup(null, null);
	}

	public AvailableModule(String text, QWidget parent, ModuleControlWidget controlWidget) {
		super(text, parent);
		this.setup(controlWidget, null);
	}

	public AvailableModule(String text, QWidget parent, ModuleControlWidget controlWidget, ArrayList<String> bitstreams) {
		super(text, parent);
		this.setup(controlWidget, bitstreams);
	}
	
	public AvailableModule(AvailableModule am, QWidget parent) {
		super(am.text(), parent);
		this.setup(am.getControlWidget(), am.getBitStreams());
		this.controlWidget = am.controlWidget;
	}

	public AvailableModule(AvailableModule am) {
		super(am.text());
		this.setup(am.getControlWidget(), am.getBitStreams());
		this.controlWidget = am.controlWidget;
	}

	private void setup(ModuleControlWidget controlWidget, ArrayList<String> bitstreams) {
		this.setFrameShape(QFrame.Shape.Panel);
		this.setMinimumSize(80, 80);
		this.setMaximumSize(80, 80);
		this.setAlignment(Qt.AlignmentFlag.AlignCenter);
		this.controlWidget = controlWidget;
		this.bitStreams = bitstreams;
		this.available = true;
	}

	private boolean grabbed = false;
	private QPoint grabbedPoint;

	@Override
	protected void mouseMoveEvent(QMouseEvent ev) {
		if (available && grabbed) {
			QPoint dp = grabbedPoint.subtract(ev.pos());
			if (dp.x() * dp.x() + dp.y() * dp.y() > 16) {
				QDrag drag = new QDrag(this);
				QMimeData mimeData = new QMimeData();
				mimeData.setData("application/x-availablemodule", new QByteArray());
				drag.setMimeData(mimeData);
				QPixmap pixmap = new QPixmap(this.size());
				this.render(pixmap);
				drag.setPixmap(pixmap);
				drag.setObjectName(this.text());
				drag.setHotSpot(ev.pos());
				drag.exec(Qt.DropAction.MoveAction);
				grabbed = false;
			}
		}
	}

	@Override
	protected void mousePressEvent(QMouseEvent ev) {
		if (available) {
			grabbed = true;
			grabbedPoint = ev.pos();
		}
	}

	@Override
	protected void mouseReleaseEvent(QMouseEvent ev) {
		grabbed = false;
		ev.setAccepted(false);
	}

	private ModuleControlWidget controlWidget;

	public ModuleControlWidget getControlWidget() {
		return controlWidget;
	}

	public void setControlWidget(ModuleControlWidget cw) {
		controlWidget = cw;
	}

	public void setParentContainer(ModuleContainer parent) {
		this.parentContainer = parent;
	}

	public ModuleContainer getParentContainer() {
		return parentContainer;
	}

	private boolean available = true;

	public boolean isAvailable() {
		return available;
	}

	public void setAvailable(boolean available) {
		this.available = available;
	}

	private ArrayList<String> bitStreams;

	public ArrayList<String> getBitStreams() {
		return bitStreams;
	}

	public void setBitStreams(ArrayList<String> bitStreams) {
		this.bitStreams = bitStreams;
	}

}
