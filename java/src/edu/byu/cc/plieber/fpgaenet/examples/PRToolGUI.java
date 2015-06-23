package edu.byu.cc.plieber.fpgaenet.examples;
import java.io.IOException;
import java.net.InetAddress;

import com.trolltech.qt.core.Qt.ItemDataRole;
import com.trolltech.qt.gui.*;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;
import edu.byu.cc.plieber.fpgaenet.icapif.IcapInterface;

public class PRToolGUI extends QMainWindow {

	private QMenu fileMenu;
	private QMenu helpMenu;

	private QAction addPbitAct;
	private QAction exitAct;
	private QAction aboutAct;
	private QAction aboutQtJambiAct;
	
	private QListWidget prList;
	private QPushButton buttonProgram;
	
	FCPProtocol fcpProtocol;
	IcapInterface icapif;

	public static void main(String[] args) {
		QApplication.initialize(args);

		PRToolGUI testPRToolGUI = new PRToolGUI(null);
		testPRToolGUI.show();

		QApplication.exec();
		
		testPRToolGUI.tearDown();
	}

	private void tearDown() {
		fcpProtocol.disconnect();
	}

	public PRToolGUI(QWidget parent) {
		super(parent);
		setupConnections();
		createActions();
		createMenus();
		createWidgets();
		connectSignals();
	}
	
	private void setupConnections() {
		try {
			fcpProtocol = new FCPProtocol();
			fcpProtocol.connect(InetAddress.getByName("192.168.1.222"), 0x3001);
		} catch (IOException e) {
			return;
		}
		icapif = new IcapInterface(fcpProtocol);
	}

	private void createActions() {
		addPbitAct = new QAction(tr("&Add PR"), this);
		addPbitAct.setShortcut(tr("Ctrl+A"));
		addPbitAct.setStatusTip(tr("Add Partial Bitstream"));
		addPbitAct.triggered.connect(this, "addPR()");

		exitAct = new QAction(tr("E&xit"), this);
		exitAct.setShortcut(tr("Ctrl+Q"));
		exitAct.setStatusTip(tr("Exit the application"));
		exitAct.triggered.connect(this, "close()");

		aboutAct = new QAction(tr("&About"), this);
		aboutAct.setStatusTip(tr("Show the application's About box"));
		aboutAct.triggered.connect(this, "about()");

		aboutQtJambiAct = new QAction(tr("About &Qt Jambi"), this);
		aboutQtJambiAct.setStatusTip(tr("Show the Qt Jambi's About box"));
		aboutQtJambiAct.triggered.connect(QApplication.instance(), "aboutQtJambi()");
	}

	private void createMenus() {
		fileMenu = menuBar().addMenu(tr("&File"));
		fileMenu.addAction(addPbitAct);
		fileMenu.addAction(exitAct);

		helpMenu = menuBar().addMenu(tr("&Help"));
		helpMenu.addAction(aboutAct);
		helpMenu.addAction(aboutQtJambiAct);
	}
	
	private void createWidgets() {
		QFrame mainFrame = new QFrame(this);
		setCentralWidget(mainFrame);
		prList = new QListWidget(mainFrame);
		QVBoxLayout mainLayout = new QVBoxLayout(mainFrame);
		mainLayout.addWidget(prList);
		buttonProgram = new QPushButton(tr("Program"), mainFrame);
		mainLayout.addWidget(buttonProgram);
		mainFrame.setLayout(mainLayout);
	}
	
	private void connectSignals() {
		buttonProgram.clicked.connect(this, "programSelected(boolean)");
		prList.itemDoubleClicked.connect(this, "programClicked(QListWidgetItem)");
	}

	protected void about() {
		QMessageBox.information(this, "Info", "It's your turn now :-)");
	}

	protected void addPR() {
		String fName = QFileDialog.getOpenFileName(this, tr("Open Partial Bit File"), "", new QFileDialog.Filter(
				tr("Bit Files (*.bit)")));
		if (fName == null) return;
		String name = QInputDialog.getText(this, "PR Tool GUI", "PR Bitstream Name", QLineEdit.EchoMode.Normal, fName);
		if (name == null) return;
		QListWidgetItem item = new QListWidgetItem(name, prList);
		item.setData(ItemDataRole.UserRole, fName);
	}
	
	protected void programSelected(boolean checked) {
		QListWidgetItem item = prList.selectedItems().get(0);
		programClicked(item);		
	}
	
	protected void programClicked(QListWidgetItem item) {
		String fName = (String)item.data(ItemDataRole.UserRole);
		try {
			icapif.sendIcapFile(fName);
		} catch (FCPException e) {
			statusBar().showMessage(tr("Programming Failed!"));
		}
		statusBar().showMessage(tr("Programmed: " + fName));
	}
}
