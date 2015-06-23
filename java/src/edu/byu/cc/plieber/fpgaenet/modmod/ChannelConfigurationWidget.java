package edu.byu.cc.plieber.fpgaenet.modmod;
import com.trolltech.qt.gui.*;
import com.trolltech.qt.QSignalEmitter.Signal1;
import com.trolltech.qt.core.Qt;

public class ChannelConfigurationWidget extends QWidget {

    public static void main(String[] args) {
        QApplication.initialize(args);

        ChannelConfigurationWidget testChannelConfigurationWidget = new ChannelConfigurationWidget(null);
        testChannelConfigurationWidget.show();

        QApplication.exec();
    }
    
    AvailableModule lblChif;
    QLabel lblLEDDIP;
    QLabel lblClockControl;
    QLabel lblICAP;

    public ChannelConfigurationWidget(QWidget parent){
        super(parent);
        //QLabel background = new QLabel(this);
        //background.setPixmap(new QPixmap("classpath:edu/byu/cc/plieber/fpgaenet/modmod/g/configProto.png"));
        //QBoxLayout layout = new QVBoxLayout();
        //this.setLayout(layout);
        //layout.addWidget(background);
        //setAcceptDrops(true);
        setMinimumSize(570, 110);
		ChannelConfiguredSignal = new Signal1<ConfigurationChannel>();
		ModuleRemovedSignal = new Signal1<AvailableModule>();
		ModuleSelectedSignal = new Signal1<AvailableModule>();
        lblChif = new AvailableModule("Channel\nInterface", this);
        lblChif.move(5, 25);
        lblChif.setAvailable(false);
        lblChif.setLineWidth(4);
        lblLEDDIP = new QLabel("LED/DIP\nControl");
        lblLEDDIP.setFrameShape(QFrame.Shape.Panel);
        lblLEDDIP.setMinimumSize(80, 80);
        lblLEDDIP.setMaximumSize(80, 80);
        lblLEDDIP.setAlignment(Qt.AlignmentFlag.AlignCenter);
        lblLEDDIP.setParent(this);
        lblLEDDIP.move(85, 25);
        lblClockControl = new QLabel("Clock\nControl");
        lblClockControl.setFrameShape(QFrame.Shape.Panel);
        lblClockControl.setMinimumSize(80, 80);
        lblClockControl.setMaximumSize(80, 80);
        lblClockControl.setAlignment(Qt.AlignmentFlag.AlignCenter);
        lblClockControl.setParent(this);
        lblClockControl.move(165, 25);
        lblICAP = new QLabel("ICAP Control");
        lblICAP.setFrameShape(QFrame.Shape.Panel);
        lblICAP.setMinimumSize(160, 80);
        lblICAP.setMaximumSize(160, 80);
        lblICAP.setAlignment(Qt.AlignmentFlag.AlignCenter);
        lblICAP.setParent(this);
        lblICAP.move(245, 25);
        ConfigurationChannel cc = new ConfigurationChannel(5);
        cc.ChannelConfiguredSignal.connect(this, "channelConfiguredHandler(ConfigurationChannel)");
        cc.ModuleRemovedSignal.connect(this, "moduleRemovedHandler(AvailableModule)");
        cc.ModuleSelectedSignal.connect(this, "moduleSelectedHandler(AvailableModule)");
        this.ModuleSelectedSignal.connect(cc, "moduleSelectedHandler(AvailableModule)");
        cc.setParent(this);
        cc.move(405, 25);
        cc = new ConfigurationChannel(6);
        cc.ChannelConfiguredSignal.connect(this, "channelConfiguredHandler(ConfigurationChannel)");
        cc.ModuleRemovedSignal.connect(this, "moduleRemovedHandler(AvailableModule)");
        cc.ModuleSelectedSignal.connect(this, "moduleSelectedHandler(AvailableModule)");
        this.ModuleSelectedSignal.connect(cc, "moduleSelectedHandler(AvailableModule)");
        cc.setParent(this);
        cc.move(485, 25);
    }
    
    @Override
    protected void paintEvent(QPaintEvent event) {
        QPainter painter = new QPainter(this);
        drawBackground(painter);
    }

	private void drawBackground(QPainter painter) {
		painter.setPen(new QPen(QColor.black, 4));
		painter.drawLine(45, 15, 525, 15);
		for (int i=45; i<=525; i+=80) {
			painter.drawLine(i, 15, i, 25);
		}
	}
	
	@Override
	protected void resizeEvent(QResizeEvent arg__1) {
        lblChif.move(45 - lblChif.width()/2, 65 - lblChif.height()/2);
		super.resizeEvent(arg__1);
	}

	public Signal1<ConfigurationChannel> ChannelConfiguredSignal;
	public Signal1<AvailableModule> ModuleRemovedSignal;
	public Signal1<AvailableModule> ModuleSelectedSignal;
	
	@SuppressWarnings("unused")
	private void channelConfiguredHandler(ConfigurationChannel cc) {
		ChannelConfiguredSignal.emit(cc);
	}
	
	@SuppressWarnings("unused")
	private void moduleRemovedHandler(AvailableModule am) {
		ModuleRemovedSignal.emit(am);
	}
	
	@SuppressWarnings("unused")
	private void moduleSelectedHandler(AvailableModule am) {
		ModuleSelectedSignal.emit(am);
	}
}
