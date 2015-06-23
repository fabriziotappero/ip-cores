package edu.byu.cc.plieber.fpgaenet.modmod;
import java.util.ArrayList;

import com.trolltech.qt.core.Qt;
import com.trolltech.qt.gui.*;

import edu.byu.cc.plieber.fpgaenet.examples.ClockControl;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;

public class StaticModulesWidget extends QWidget{

    public static void main(String[] args) {
        QApplication.initialize(args);

        StaticModulesWidget testStaticModulesWidget = new StaticModulesWidget(null, null);
        testStaticModulesWidget.show();

        QApplication.exec();
    }
    
    private FCPProtocol fcpprotocol;
    private ClockControl clockControl;

    public StaticModulesWidget(QWidget parent, FCPProtocol protocol){
        super(parent);
        fcpprotocol = protocol;
        clockControl = new ClockControl(protocol, 2);
        createWidgets();
        createLayout();
        connectSignalsAndSlots();
    }
    
    private QGroupBox grpLEDDIP = new QGroupBox("LED / DIP Control");
    private QGroupBox grpClockControl = new QGroupBox("Clock Control");
    
    private QLabel labelStaticModules = new QLabel("Static Module Control");
    private QLabel labelLEDValue = new QLabel("LED Value:");
    private QLabel labelDIPValue = new QLabel("DIP Value:");
    private QLabel labelStepClock = new QLabel("Step Clock:");
    
    private QPushButton btnSetLED = new QPushButton("Set LED");
    private QPushButton btnGetDIP = new QPushButton("Get DIP");
    private QPushButton btnStep = new QPushButton("Step");
    private QPushButton btnSingleStep = new QPushButton("Single Step");
    private QPushButton btnFreeRun = new QPushButton("Free Run");
    private QPushButton btnCCReset = new QPushButton("Reset");
    
    private QLineEdit txtLEDValue = new QLineEdit();
    private QLineEdit txtDIPValue = new QLineEdit();
    private QLineEdit txtNumCycles = new QLineEdit();
    
    private int LEDDIPChannel = 1;
    
    private void createWidgets() {
    	QFont font =labelStaticModules.font(); 
    	font.setPointSize(labelStaticModules.font().pointSize()+2);
    	labelStaticModules.setFont(font);
    	labelLEDValue.setAlignment(Qt.AlignmentFlag.AlignRight);
    	labelDIPValue.setAlignment(Qt.AlignmentFlag.AlignRight);
    	labelStepClock.setAlignment(Qt.AlignmentFlag.AlignRight);
    }
    
    private void createLayout() {
    	QVBoxLayout mainLayout = new QVBoxLayout(this);
    	QGridLayout leddipLayout = new QGridLayout();
    	QGridLayout clockControlLayout = new QGridLayout();
    	
    	leddipLayout.setColumnMinimumWidth(0, 20);
    	//leddipLayout.setColumnMinimumWidth(3, 20);
    	leddipLayout.setColumnStretch(2, 1);
    	leddipLayout.addWidget(labelLEDValue, 0, 1);
    	leddipLayout.addWidget(txtLEDValue, 0, 2);
    	leddipLayout.addWidget(btnSetLED, 0, 3);
    	leddipLayout.addWidget(labelDIPValue, 1, 1);
    	leddipLayout.addWidget(btnGetDIP, 1, 3);
    	leddipLayout.addWidget(txtDIPValue, 1, 2);
    	
    	clockControlLayout.setColumnMinimumWidth(0, 20);
    	//clockControlLayout.setColumnMinimumWidth(3, 20);
    	clockControlLayout.setColumnStretch(2, 1);
    	clockControlLayout.addWidget(labelStepClock, 0, 1);
    	clockControlLayout.addWidget(txtNumCycles, 0, 2);
    	clockControlLayout.addWidget(btnStep, 0, 3);
    	clockControlLayout.addWidget(btnFreeRun, 1, 1);
    	clockControlLayout.addWidget(btnSingleStep, 1, 2);
    	clockControlLayout.addWidget(btnCCReset, 1, 3);
    	
    	grpLEDDIP.setLayout(leddipLayout);
    	grpClockControl.setLayout(clockControlLayout);
    	
    	mainLayout.addWidget(labelStaticModules);
    	mainLayout.addWidget(grpLEDDIP);
    	mainLayout.addWidget(grpClockControl);
    	mainLayout.addStretch();
    }
    
    private void connectSignalsAndSlots() {
    	btnCCReset.clicked.connect(this, "resetModules()");
    	btnFreeRun.clicked.connect(this, "freeRun()");
    	btnGetDIP.clicked.connect(this, "getDIP()");
    	btnSetLED.clicked.connect(this, "setLED()");
    	btnSingleStep.clicked.connect(this, "singleStep()");
    	btnStep.clicked.connect(this, "stepClock()");
    }
    
    @SuppressWarnings("unused")
	private void setLED() {
    	byte ledVal = Byte.parseByte(txtLEDValue.text());
    	try {
			fcpprotocol.sendData(LEDDIPChannel, ledVal);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    @SuppressWarnings("unused")
    private void getDIP() {
    	try {
			fcpprotocol.sendDataRequest(LEDDIPChannel, 1);
			byte[] data = fcpprotocol.getDataResponse();
			if (data.length > 0) txtDIPValue.setText(String.valueOf(data[0]));
			else txtDIPValue.setText("-error-");
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    @SuppressWarnings("unused")
    private void stepClock() {
    	clockControl.runClock(Integer.parseInt(txtNumCycles.text()));
    }

    @SuppressWarnings("unused")
    private void freeRun() {
    	clockControl.freeRunClock();
    }

    @SuppressWarnings("unused")
    private void singleStep() {
    	clockControl.singleStep();
    }

    @SuppressWarnings("unused")
    private void resetModules() {
    	clockControl.assertReset();
    	clockControl.deassertAll();
    }
    
    public void setChannels(int LEDDIP, int ClockControl) {
    	this.LEDDIPChannel = LEDDIP;
    	clockControl.setChannel(ClockControl);
    }

	public int getLEDDIPChannel() {
		return LEDDIPChannel;
	}

	public int getClockControlChannel() {
		return clockControl.getChannel();
	}
    
    
}

