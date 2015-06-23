package edu.byu.cc.plieber.fpgaenet.modmod;
import java.util.ArrayList;

import com.trolltech.qt.gui.*;
import com.trolltech.qt.gui.QSizePolicy.Policy;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;
import edu.byu.cc.plieber.util.StringUtil;

public class MD5Widget extends ModuleControlWidget{
    
    private QVBoxLayout mainLayout;
    private QHBoxLayout formatLayout;
    
    private QLabel lblTitle;
    
    private QRadioButton radASCII;
    private QRadioButton radHex;
    
    private QLineEdit txtRead;
    private QPushButton btnCalculate;
    private QLineEdit txtResult;

    public MD5Widget(QWidget parent, FCPProtocol protocol){
        super(parent);
        fcpProtocol = protocol;
        createWidgets();
        connectSignalsAndSlots();
    }
    
    FCPProtocol fcpProtocol;

	private void createWidgets() {
		mainLayout = new QVBoxLayout(this);
		this.setLayout(mainLayout);
		lblTitle = new QLabel("MD5 Calculator");
		mainLayout.addWidget(lblTitle);
		formatLayout = new QHBoxLayout();
		mainLayout.addLayout(formatLayout);
		radASCII = new QRadioButton("ASCII");
		radASCII.setChecked(true);
		radHex = new QRadioButton("Hex");
		formatLayout.addWidget(radASCII);
		formatLayout.addWidget(radHex);
		formatLayout.addStretch();
		txtRead = new QLineEdit();
		btnCalculate = new QPushButton("Calculate");
		btnCalculate.setSizePolicy(new QSizePolicy(Policy.Maximum, Policy.Maximum));
		txtResult = new QLineEdit();
		mainLayout.addWidget(txtRead);
		mainLayout.addWidget(btnCalculate);
		mainLayout.addWidget(txtResult);
		mainLayout.addStretch();
		
	}

	private void connectSignalsAndSlots() {
		btnCalculate.clicked.connect(this, "calculate()");
	}

	@Override
	public void setChannelNumber(int channelNumber) {
		this.channelNumber = channelNumber;
		lblTitle.setText("MD5 Calculator (Channel " + channelNumber + ")");
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
			fcpProtocol.send(channelNumber, pass, pass.size());
			fcpProtocol.sendDataRequest(channelNumber, 16);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		byte[] bytes = fcpProtocol.getDataResponse();
		txtResult.clear();
		txtResult.setText(StringUtil.arrayToHexString(bytes));
	}
}
