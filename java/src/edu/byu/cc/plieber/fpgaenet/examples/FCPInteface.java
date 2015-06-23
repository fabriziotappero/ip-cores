package edu.byu.cc.plieber.fpgaenet.examples;
import java.io.IOException;
import java.lang.Character.UnicodeBlock;
import java.net.InetAddress;
import java.util.ArrayList;

import com.trolltech.qt.gui.*;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;
import edu.byu.cc.plieber.util.StringUtil;

public class FCPInteface extends QWidget{

    public static void main(String[] args) {
        QApplication.initialize(args);

        FCPInteface testFCPInteface = new FCPInteface(null);
        testFCPInteface.show();

        QApplication.exec();
        
        testFCPInteface.tearDown();
    }
    
    private QVBoxLayout mainLayout;
    private QHBoxLayout toprow;
    private QGridLayout mainrow;
    private QGridLayout readcon;
    private QVBoxLayout writecon;
    
    private QLabel lblPort;
    private QLineEdit txtPort;
    private QPushButton btnConnect;
    private QPushButton btnRead;
    private QLabel lblNumBytes;
    private QLineEdit txtNumBytes;
    private QTextEdit textRead;
    private QPushButton btnWrite;
    private QRadioButton radASCII;
    private QRadioButton radHex;
    private QTextEdit textWrite;

    public FCPInteface(QWidget parent){
        super(parent);
        setWindowTitle("FCP Interface");
        makeConnections();
        createWidgets();
        connectSignalsAndSlots();
    }

    FCPProtocol fcpProtocol;
	private void makeConnections() {
		try {
			fcpProtocol = new FCPProtocol();
			fcpProtocol.connect(InetAddress.getByName("192.168.1.222"), 0x3001);
		} catch (IOException e) {
			return;
		}
		while(!fcpProtocol.isConnected());
	}

	private void createWidgets() {
		// TODO Auto-generated method stub
		mainLayout = new QVBoxLayout(this);
		this.setLayout(mainLayout);
		toprow = new QHBoxLayout();
		mainrow = new QGridLayout();
		mainLayout.addLayout(toprow);
		mainLayout.addLayout(mainrow);
		readcon = new QGridLayout();
		writecon = new QVBoxLayout();
		mainrow.addLayout(readcon, 0, 0);
		mainrow.addLayout(writecon, 1, 0);
		
		lblPort = new QLabel("Port");
		txtPort = new QLineEdit("1");
		btnConnect = new QPushButton("Connect");
		btnRead = new QPushButton("Read");
		lblNumBytes = new QLabel("#");
		txtNumBytes = new QLineEdit("1");
		textRead = new QTextEdit();
		btnWrite = new QPushButton("Write");
		radASCII = new QRadioButton("ASCII");
		radHex = new QRadioButton("Hex");
		textWrite = new QTextEdit();
		
		toprow.addWidget(lblPort);
		toprow.addWidget(txtPort);
		toprow.addWidget(btnConnect);
		readcon.addWidget(btnRead, 0, 0, 1, 2);
		readcon.addWidget(lblNumBytes, 1, 0);
		readcon.addWidget(txtNumBytes, 1, 1);
		mainrow.addWidget(textRead, 0, 1);
		writecon.addWidget(btnWrite);
		writecon.addWidget(radASCII);
		writecon.addWidget(radHex);
		mainrow.addWidget(textWrite, 1, 1);
	}

	private void connectSignalsAndSlots() {
		btnRead.clicked.connect(this, "readData()");
		btnWrite.clicked.connect(this, "writeData()");	
	}
	
	@SuppressWarnings("unused")
	private void writeData() {
		//QMessageBox.information(this, "Write Data", "Writing Data ...");
		String text = textWrite.document().toPlainText();
		ArrayList<Byte> bytes = new ArrayList<Byte>();
		if (radHex.isChecked()) {
			String[] tokens = text.split(" ");
			for (String bytestr : tokens) {
				byte thebyte = (byte) Integer.parseInt(bytestr, 16);
				bytes.add(thebyte);
			}
		}
		else {
			char[] chars = text.toCharArray();
			for (char bytechar : chars) {
				byte thebyte = (byte) (bytechar & 0xff);
				bytes.add(thebyte);
			}
		}
		try {
			fcpProtocol.sendData(Integer.parseInt(txtPort.text()), bytes, bytes.size());
		} catch (NumberFormatException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		this.setStatusTip(StringUtil.listToString(bytes) + " written to FCP Channel " + txtPort.text());
	}
	
	@SuppressWarnings("unused")
	private void readData() {
		//QMessageBox.information(this, "Read Data", "Reading Data ...");
		int numBytes = Integer.parseInt(txtNumBytes.text());
		int port = Integer.parseInt(txtPort.text());
		try {
			fcpProtocol.sendDataRequest(port, numBytes);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		byte[] bytes = fcpProtocol.getDataResponse();
		textRead.clear();
		textRead.append(StringUtil.arrayToString(bytes));
	}
	
	public  void tearDown() {
		fcpProtocol.disconnect();
	}
}
