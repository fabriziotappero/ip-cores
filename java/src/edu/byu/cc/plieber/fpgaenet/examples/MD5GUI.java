package edu.byu.cc.plieber.fpgaenet.examples;
import java.io.IOException;
import java.net.InetAddress;
import java.util.ArrayList;

import com.trolltech.qt.gui.*;
import com.trolltech.qt.gui.QSizePolicy.Policy;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;
import edu.byu.cc.plieber.util.StringUtil;

public class MD5GUI extends QWidget{

    public static void main(String[] args) {
        QApplication.initialize(args);

        MD5GUI testMD5GUI = new MD5GUI(null);
        testMD5GUI.show();

        QApplication.exec();
        
        testMD5GUI.tearDown();
    }
    
    private QVBoxLayout mainLayout;
    private QHBoxLayout formatLayout;
    
    private QRadioButton radASCII;
    private QRadioButton radHex;
    
    private QLineEdit txtRead;
    private QPushButton btnCalculate;
    private QLineEdit txtResult;

    public MD5GUI(QWidget parent){
        super(parent);
        setWindowTitle("FPGA MD5 Calculator");
        makeConnections();
        createWidgets();
        connectSignalsAndSlots();
    }
    
    FCPProtocol fcpProtocol;

	private void makeConnections() {
		try {
			fcpProtocol = new FCPProtocol();
			fcpProtocol.connect(InetAddress.getByName("10.0.1.42"));
			while(!fcpProtocol.isConnected());
		} catch (IOException e) {
			return;
		}
	}

	private void createWidgets() {
		mainLayout = new QVBoxLayout(this);
		this.setLayout(mainLayout);
		formatLayout = new QHBoxLayout();
		mainLayout.addLayout(formatLayout);
		radASCII = new QRadioButton("ASCII");
		radASCII.setChecked(true);
		radHex = new QRadioButton("Hex");
		formatLayout.addWidget(radASCII);
		formatLayout.addWidget(radHex);
		txtRead = new QLineEdit();
		btnCalculate = new QPushButton("Calculate");
		btnCalculate.setSizePolicy(new QSizePolicy(Policy.Maximum, Policy.Maximum));
		txtResult = new QLineEdit();
		mainLayout.addWidget(txtRead);
		mainLayout.addWidget(btnCalculate);
		mainLayout.addWidget(txtResult);
		
	}

	private void connectSignalsAndSlots() {
		btnCalculate.clicked.connect(this, "calculate()");
	}
	
	@SuppressWarnings("unused")
	private void calculate() {
		String text = txtRead.text();
		ArrayList<Byte> pass;
		long len = 0;
		if (radASCII.isChecked()) {
			pass = StringUtil.stringToByteList(text); 
			len = text.length();
		}
		else {
			String[] tokens = text.split(" ");
			pass = new ArrayList<Byte>();
			for (String bytestr : tokens) {
				pass.add((byte) Integer.parseInt(bytestr, 16));
			}
			len = pass.size();
		}
		pass.add(new Byte((byte)0x80));
		while (pass.size()*8 % 512 != 448) {
			pass.add(new Byte((byte)0x00));
		}
		len = len * 8;
		pass.add(new Byte((byte)((len) & 0xff)));
		pass.add(new Byte((byte)((len >> 8) & 0xff)));
		pass.add(new Byte((byte)((len >> 16) & 0xff)));
		pass.add(new Byte((byte)((len >> 24) & 0xff)));
		pass.add(new Byte((byte)((len >> 32) & 0xff)));
		pass.add(new Byte((byte)((len >> 40) & 0xff)));
		pass.add(new Byte((byte)((len >> 48) & 0xff)));
		pass.add(new Byte((byte)((len >> 56) & 0xff)));
		try {
			fcpProtocol.send(6, pass, pass.size());
			fcpProtocol.sendDataRequest(6, 16);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		byte[] bytes = fcpProtocol.getDataResponse();
		txtResult.clear();
		txtResult.setText(StringUtil.arrayToHexString(bytes));
	}
	
	public void tearDown() {
		fcpProtocol.disconnect();
	}
}
