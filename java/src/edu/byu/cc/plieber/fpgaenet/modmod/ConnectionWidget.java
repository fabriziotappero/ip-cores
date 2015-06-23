package edu.byu.cc.plieber.fpgaenet.modmod;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;

import com.trolltech.qt.core.Qt;
import com.trolltech.qt.core.Qt.WindowModality;
import com.trolltech.qt.gui.*;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;

public class ConnectionWidget extends QWidget {

	public static void main(String[] args) {
		QApplication.initialize(args);

		FCPProtocol fcpprotocol;
		try {
			fcpprotocol = new FCPProtocol();
			ConnectionWidget testStaticModulesWidget = new ConnectionWidget(null, fcpprotocol);
			testStaticModulesWidget.show();
			QApplication.exec();
			fcpprotocol.disconnect();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private FCPProtocol fcpprotocol;

	public ConnectionWidget(QWidget parent, FCPProtocol protocol) {
		super(parent);
		fcpprotocol = protocol;
		createWidgets();
		createLayout();
		connectSignalsAndSlots();
		setWindowModality(WindowModality.ApplicationModal);
		fillWidgets();
	}

	private void fillWidgets() {
		if (fcpprotocol != null) {
			spnSourcePort.setValue(fcpprotocol.getSourceUDPPort());
			spnDestPort.setValue(fcpprotocol.getDestUDPPort());
			if (fcpprotocol.getDestIPAddress() != null)
				txtFPGAIP.setText(fcpprotocol.getDestIPAddress().getHostAddress());
			else
				txtFPGAIP.setText("10.0.1.42");
			textStatus.setText(fcpprotocol.isConnected() ? "Connected" : "Not Connected");
		} else {
			textStatus.setText("Not Connected");
		}
	}

	private QLabel labelSourcePort = new QLabel("Source UDP Port");
	private QLabel labelDestPort = new QLabel("Destination UDP Port");
	private QLabel labelFPGAIP = new QLabel("FPGA IP Address");
	private QLabel labelStatus = new QLabel("Status");

	private QSpinBox spnSourcePort = new QSpinBox();
	private QSpinBox spnDestPort = new QSpinBox();
	private QLineEdit txtFPGAIP = new QLineEdit();
	private QTextEdit textStatus = new QTextEdit();

	private QPushButton btnConnect = new QPushButton("Connect");
	private QPushButton btnDisconnect = new QPushButton("Disconnect");
	
	public Signal0 ConnectionChangedSignal = new Signal0();

	private void createWidgets() {
		labelSourcePort.setAlignment(Qt.AlignmentFlag.AlignRight);
		labelDestPort.setAlignment(Qt.AlignmentFlag.AlignRight);
		labelFPGAIP.setAlignment(Qt.AlignmentFlag.AlignRight);
		labelStatus.setAlignment(Qt.AlignmentFlag.AlignCenter);
		textStatus.setReadOnly(true);
	}

	private void createLayout() {
		QVBoxLayout mainLayout = new QVBoxLayout(this);
		QHBoxLayout topLayout = new QHBoxLayout();
		mainLayout.addLayout(topLayout);
		QVBoxLayout statusLayout = new QVBoxLayout();
		QHBoxLayout bottomLayout = new QHBoxLayout();
		mainLayout.addLayout(bottomLayout);
		QGridLayout settingsLayout = new QGridLayout();
		topLayout.addLayout(settingsLayout);
		topLayout.addLayout(statusLayout);

		settingsLayout.setRowMinimumHeight(0, 20);
		settingsLayout.addWidget(labelSourcePort, 1, 0);
		spnSourcePort.setMaximum(65535);
		spnSourcePort.setMinimum(1);
		settingsLayout.addWidget(spnSourcePort, 1, 1);
		settingsLayout.addWidget(labelDestPort, 2, 0);
		spnDestPort.setMaximum(65535);
		spnDestPort.setMinimum(1);
		settingsLayout.addWidget(spnDestPort, 2, 1);
		settingsLayout.addWidget(labelFPGAIP, 3, 0);
		settingsLayout.addWidget(txtFPGAIP, 3, 1);
		settingsLayout.setColumnStretch(0, 1);
		settingsLayout.setRowStretch(4, 1);

		statusLayout.addWidget(labelStatus);
		statusLayout.addWidget(textStatus);

		bottomLayout.addWidget(btnConnect);
		bottomLayout.addWidget(btnDisconnect);
	}

	private void connectSignalsAndSlots() {
		btnConnect.clicked.connect(this, "connect()");
		btnDisconnect.clicked.connect(this, "disconnectFCP()");
	}

	@SuppressWarnings("unused")
	private void connect() {
		if (fcpprotocol == null) {
			this.textStatus.setText("Not Connected");
		}
		else {
			try {
				//if (fcpprotocol.isConnected()) fcpprotocol.disconnect();
				fcpprotocol.connect(InetAddress.getByName(this.txtFPGAIP.text()), spnDestPort.value());
				while (!fcpprotocol.isConnected());
				this.textStatus.setText("Connected!");
			} catch (UnknownHostException e) {
				this.textStatus.setText("Not Connected");
			}
			this.ConnectionChangedSignal.emit();
		}
	}
	
	@SuppressWarnings("unused")
	private void disconnectFCP() {
		if (fcpprotocol != null) {
			fcpprotocol.disconnect();
		}
		this.textStatus.setText("Not Connected");
	}
}
