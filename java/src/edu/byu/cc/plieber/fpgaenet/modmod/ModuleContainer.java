package edu.byu.cc.plieber.fpgaenet.modmod;

import com.trolltech.qt.gui.QWidget;

public interface ModuleContainer {
	public abstract void addModule(AvailableModule module);
	public abstract void removeModule(AvailableModule module);
}
