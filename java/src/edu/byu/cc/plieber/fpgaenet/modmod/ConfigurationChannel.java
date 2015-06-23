package edu.byu.cc.plieber.fpgaenet.modmod;

import java.nio.channels.Channel;

import com.trolltech.extensions.signalhandler.QSignalHandler1;
import com.trolltech.qt.QSignalEmitter.Signal1;
import com.trolltech.qt.gui.QDragEnterEvent;
import com.trolltech.qt.gui.QDragLeaveEvent;
import com.trolltech.qt.gui.QDropEvent;
import com.trolltech.qt.gui.QFrame;
import com.trolltech.qt.gui.QMouseEvent;
import com.trolltech.qt.gui.QWidget;

public class ConfigurationChannel extends QFrame implements ModuleContainer {

	public ConfigurationChannel(int ch) {
		setFrameStyle(QFrame.Shape.Panel.value());
		setLineWidth(2);
		setMinimumSize(80, 80);
		setMaximumSize(80, 80);
		channel = ch;
		ChannelConfiguredSignal = new Signal1<ConfigurationChannel>();
		ModuleRemovedSignal = new Signal1<AvailableModule>();
		ModuleSelectedSignal = new Signal1<AvailableModule>();
		setAcceptDrops(true);
	}

	private int channel;

	public void setChannel(int ch) {
		channel = ch;
	}

	public int getChannel() {
		return channel;
	}

	AvailableModule resident;

	public boolean isOccupied() {
		return (resident != null);
	}

	public AvailableModule getResident() {
		return resident;
	}

	@Override
	public void addModule(AvailableModule module) {
		if (resident != null) {
			removeModule(resident);
		}
		resident = module;
		resident.setAvailable(false);
		resident.move(0, 0);
		resident.show();
		ChannelConfiguredSignal.emit(this);
	}

	@Override
	public void removeModule(AvailableModule module) {
		ModuleRemovedSignal.emit(resident);
		resident.close();
		resident = null;
	}

	@Override
	protected void dragEnterEvent(QDragEnterEvent event) {
		if (event.mimeData().hasFormat("application/x-availablemodule")) {
			event.acceptProposedAction();
		}
		this.setLineWidth(4);
	}

	@Override
	protected void dropEvent(QDropEvent event) {
		if (event.mimeData().hasFormat("application/x-availablemodule")) {
			event.acceptProposedAction();
			AvailableModule module =(AvailableModule) event.source();
			AvailableModule newmodule = new AvailableModule(module, this);
			module.getParentContainer().removeModule(module);
			this.addModule(newmodule);
			this.setLineWidth(4);
			ModuleSelectedSignal.emit(resident);
		}
	}

	@Override
	protected void dragLeaveEvent(QDragLeaveEvent event) {
		this.setLineWidth(2);
	}
	
	@Override
	protected void mouseReleaseEvent(QMouseEvent arg__1) {
		this.setLineWidth(4);
		if (resident != null)
			ModuleSelectedSignal.emit(resident);
	}

	public Signal1<ConfigurationChannel> ChannelConfiguredSignal;
	public Signal1<AvailableModule> ModuleRemovedSignal;
	public Signal1<AvailableModule> ModuleSelectedSignal;

	private boolean programmable;

	public boolean isProgrammable() {
		return programmable;
	}

	public void setProgrammable(boolean programmable) {
		this.programmable = programmable;
		setAcceptDrops(programmable);
	}
	
	@SuppressWarnings("unused")
	private void moduleSelectedHandler(AvailableModule am) {
		if (am != null && am == this.getResident())
			this.setLineWidth(4);
		else
			this.setLineWidth(2);
	}
}
