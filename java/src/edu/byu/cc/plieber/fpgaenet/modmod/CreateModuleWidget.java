package edu.byu.cc.plieber.fpgaenet.modmod;

import java.util.ArrayList;

import com.trolltech.qt.core.Qt.WindowModality;
import com.trolltech.qt.gui.*;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;

public class CreateModuleWidget extends QWidget {

	public static void main(String[] args) {
		QApplication.initialize(args);

		CreateModuleWidget testCreateModuleWidget = new CreateModuleWidget(null, null);
		testCreateModuleWidget.show();

		QApplication.exec();
	}

	Signal1<AvailableModule> AvailableModuleCreated;
	private FCPProtocol fcpProtocol;

	public CreateModuleWidget(QWidget parent, FCPProtocol p) {
		super(parent);
		AvailableModuleCreated = new Signal1<AvailableModule>();
		fcpProtocol = p;
		createWidgets();
		populateWidgets();
		createLayout();
		connectSignalsAndSlots();
	}

	private void createWidgets() {
		txtName = new QLineEdit();
		cmbWidget = new QComboBox();
		txtCh5Bitstream = new QLineEdit();
		btnCh5Bitstream = new QPushButton("Browse");
		txtCh6Bitstream = new QLineEdit();
		btnCh6Bitstream = new QPushButton("Browse");
		btnOk = new QPushButton("Ok");
		btnCancel = new QPushButton("Cancel");
	}

	private void populateWidgets() {
		cmbWidget.insertItem(0, "MD5 Control", new MD5Widget(null, fcpProtocol));
		cmbWidget.insertItem(1, "SHA1 Control", new SHA1Widget(null, fcpProtocol));
	}

	private void createLayout() {
		QVBoxLayout layout = new QVBoxLayout();
		this.setLayout(layout);
		QFormLayout formLayout = new QFormLayout();
		formLayout.addRow(tr("Name"), txtName);
		formLayout.addRow(tr("Widget"), cmbWidget);
		QHBoxLayout ch5Layout = new QHBoxLayout();
		ch5Layout.addWidget(txtCh5Bitstream);
		ch5Layout.addWidget(btnCh5Bitstream);
		formLayout.addRow(tr("Channel 5 Bitstream"), ch5Layout);
		QHBoxLayout ch6Layout = new QHBoxLayout();
		ch6Layout.addWidget(txtCh6Bitstream);
		ch6Layout.addWidget(btnCh6Bitstream);
		formLayout.addRow(tr("Channel 6 Bitstream"), ch6Layout);
		layout.addLayout(formLayout);
		layout.addStretch();
		QHBoxLayout buttonLayout = new QHBoxLayout();
		buttonLayout.addStretch();
		buttonLayout.addWidget(btnOk);
		buttonLayout.addWidget(btnCancel);
		layout.addLayout(buttonLayout);
		setWindowModality(WindowModality.ApplicationModal);
	}

	private void connectSignalsAndSlots() {
		btnOk.clicked.connect(this, "ok()");
		btnCancel.clicked.connect(this, "cancel()");
		btnCh5Bitstream.clicked.connect(this, "ch5ButtonPressed()");
		btnCh6Bitstream.clicked.connect(this, "ch6ButtonPressed()");
	}

	@SuppressWarnings("unused")
	private void ok() {
		ArrayList<String> bitstreams = new ArrayList<String>(6);
		bitstreams.add("");
		bitstreams.add("");
		bitstreams.add("");
		bitstreams.add("");
		bitstreams.add("");
		bitstreams.add(txtCh5Bitstream.text());
		bitstreams.add(txtCh6Bitstream.text());
		this.AvailableModuleCreated.emit(new AvailableModule(this.txtName.text(), null, (ModuleControlWidget) cmbWidget
				.itemData(cmbWidget.currentIndex()), bitstreams));
		this.close();
	}

	@SuppressWarnings("unused")
	private void cancel() {
		this.close();
	}

	@SuppressWarnings("unused")
	private void ch5ButtonPressed() {
		String fName = QFileDialog.getOpenFileName(this, tr("Open Channel 5 " + txtName.text() + " Bit File"), "",
				new QFileDialog.Filter(tr("Bit Files (*.bit)")));
		if (fName == null)
			return;
		txtCh5Bitstream.setText(fName);
	}

	@SuppressWarnings("unused")
	private void ch6ButtonPressed() {
		String fName = QFileDialog.getOpenFileName(this, tr("Open Channel 6 " + txtName.text() + " Bit File"), "",
				new QFileDialog.Filter(tr("Bit Files (*.bit)")));
		if (fName == null)
			return;
		txtCh6Bitstream.setText(fName);
	}

	private QLineEdit txtName;
	private QComboBox cmbWidget;
	private QLineEdit txtCh5Bitstream;
	private QPushButton btnCh5Bitstream;
	private QLineEdit txtCh6Bitstream;
	private QPushButton btnCh6Bitstream;
	private QPushButton btnOk;
	private QPushButton btnCancel;
}
