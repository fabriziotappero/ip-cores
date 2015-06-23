package edu.byu.cc.plieber.fpgaenet.modmod;
import com.trolltech.qt.gui.*;

public abstract class ModuleControlWidget extends QWidget{
	
	public ModuleControlWidget(QWidget parent) {
		super(parent);
	}

	protected int channelNumber;

	public void setChannelNumber(int channelNumber) {
		this.channelNumber = channelNumber;
	}

	public int getChannelNumber() {
		return channelNumber;
	}
}
