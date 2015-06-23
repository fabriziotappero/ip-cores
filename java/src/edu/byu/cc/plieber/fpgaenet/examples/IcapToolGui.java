package edu.byu.cc.plieber.fpgaenet.examples;

import java.io.IOException;
import java.net.InetAddress;

import com.trolltech.qt.core.QModelIndex;
import com.trolltech.qt.core.Qt.DockWidgetArea;
//import com.trolltech.qt.gui.*;
import com.trolltech.qt.gui.QAbstractItemView.SelectionMode;
import com.trolltech.qt.gui.QAction;
import com.trolltech.qt.gui.QApplication;
import com.trolltech.qt.gui.QBoxLayout;
import com.trolltech.qt.gui.QBoxLayout.Direction;
import com.trolltech.qt.gui.QDockWidget;
import com.trolltech.qt.gui.QFileDialog;
import com.trolltech.qt.gui.QFrame;
import com.trolltech.qt.gui.QHBoxLayout;
import com.trolltech.qt.gui.QItemSelection;
import com.trolltech.qt.gui.QLabel;
import com.trolltech.qt.gui.QLayout;
import com.trolltech.qt.gui.QLineEdit;
import com.trolltech.qt.gui.QListView;
import com.trolltech.qt.gui.QMainWindow;
import com.trolltech.qt.gui.QMenu;
import com.trolltech.qt.gui.QMessageBox;
import com.trolltech.qt.gui.QPushButton;
import com.trolltech.qt.gui.QSortFilterProxyModel;
import com.trolltech.qt.gui.QTableView;
import com.trolltech.qt.gui.QVBoxLayout;
import com.trolltech.qt.gui.QWidget;

import edu.byu.cc.plieber.fpgaenet.debug.IcapReadback;
import edu.byu.cc.plieber.fpgaenet.debug.LogicalMapping;
import edu.byu.cc.plieber.fpgaenet.debug.llparse.LatchRBEntry;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;
import edu.byu.cc.plieber.fpgaenet.icapif.IcapInterface;
import edu.byu.cc.plieber.fpgaenet.icapif.IcapTools;

public class IcapToolGui extends QMainWindow {

	private QMenu fileMenu;
	private QMenu helpMenu;

	private QAction openLL;
	private QAction exitAct;
	private QAction aboutAct;
	private QAction aboutQtJambiAct;
	
	// Widgets
	private QLabel netLabel;
	private QLineEdit netValue;
	private QPushButton buttonGetValue;

	// Model/Views
	private QListView netListView;
	private QTableView netTableView;
	private NetListModel netListModel;
	QSortFilterProxyModel tableProxyModel;
	QSortFilterProxyModel listProxyModel;

	// Connections
	FCPProtocol fcpProtocol;
	IcapInterface icapif;
	IcapTools icapTools;
	IcapReadback icapReadback;
	LatchRBEntry currentEntry;

	public static void main(String[] args) {
		QApplication.initialize(args);

		IcapToolGui testIcapToolGui = new IcapToolGui(null);
		testIcapToolGui.show();

		QApplication.exec();
		
		testIcapToolGui.tearDown();
	}

	public  void tearDown() {
		fcpProtocol.disconnect();
	}

	public IcapToolGui(QWidget parent) {
		super(parent);
		setWindowTitle("ICAP Tool GUI");
		createActions();
		createMenus();
		createWidgets();
		setupConnections();
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
		icapTools = new IcapTools(icapif);
		icapReadback = new IcapReadback(icapTools);
		while(!fcpProtocol.isConnected());
		try {
			icapTools.synchIcap();
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private void createActions() {
		openLL = new QAction(tr("&Open LL File"), this);
		openLL.setShortcut(tr("Ctrl+O"));
		openLL.setStatusTip(tr("Open new LL file"));
		openLL.triggered.connect(this, "openLL()");

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
		fileMenu.addAction(openLL);
		fileMenu.addAction(exitAct);

		helpMenu = menuBar().addMenu(tr("&Help"));
		helpMenu.addAction(aboutAct);
		helpMenu.addAction(aboutQtJambiAct);
	}

	private void createWidgets() {
		// Left Dock Net List
		netListView = new QListView(this);
		netListView.setSelectionMode(SelectionMode.ExtendedSelection);
		QDockWidget dockWidget = new QDockWidget(tr("Net List"), this);
		dockWidget.setAllowedAreas(DockWidgetArea.LeftDockWidgetArea);
		dockWidget.setWidget(netListView);
		addDockWidget(DockWidgetArea.LeftDockWidgetArea, dockWidget);
		
		// Main area Frame -------------------------------------------------
		QFrame mainFrame = new QFrame(this);
		setCentralWidget(mainFrame);
		netTableView = new QTableView(mainFrame);
		QVBoxLayout mainLayout = new QVBoxLayout(mainFrame);
		mainLayout.addWidget(netTableView);
		QHBoxLayout netValueLayout = new QHBoxLayout();
		netLabel = new QLabel(tr("Net Value"));
		netValue = new QLineEdit(tr("<net value>"));
		buttonGetValue = new QPushButton(tr("Get Value"));
		buttonGetValue.clicked.connect(this, "getNetValue()");
		netValueLayout.addWidget(netLabel);
		netValueLayout.addWidget(netValue);
		netValueLayout.addWidget(buttonGetValue);
		mainLayout.addLayout(netValueLayout);
		mainFrame.setLayout(mainLayout);
	}

	private void connectSignals() {
		netListView.doubleClicked.connect(this, "openStatusWidget(QModelIndex)");
	}

	protected void openLL() {
		String fName = QFileDialog.getOpenFileName(this, tr("Open LL File"), "", new QFileDialog.Filter(
				tr("LL Files (*.ll *.LL)")));
		LogicalMapping llMapping = new LogicalMapping(fName);
		netListModel = new NetListModel(llMapping);
		listProxyModel = new QSortFilterProxyModel(this);
		listProxyModel.setSourceModel(netListModel);
		listProxyModel.sort(0);
		netListView.setModel(listProxyModel);
		tableProxyModel = new QSortFilterProxyModel(this);
		tableProxyModel.setSourceModel(netListModel);
		tableProxyModel.setFilterFixedString("");
		netTableView.setModel(tableProxyModel);
		netTableView.setSelectionMode(SelectionMode.SingleSelection);
		netListView.selectionModel().selectionChanged.connect(this,
				"netSelectionChanged(QItemSelection,QItemSelection)");
		netTableView.clicked.connect(this, "netDetailClicked(QModelIndex)");
	}

	protected void about() {
		QMessageBox.information(this, "Info", "It's your turn now :-)");
	}

	protected void openStatusWidget(QModelIndex index) {
		QWidget statusWidget = new QWidget();
		QLayout layout = new QBoxLayout(Direction.LeftToRight);
		layout.addWidget(new QLabel(tr(listProxyModel.data(index).toString()), statusWidget));
		statusWidget.setLayout(layout);
		statusWidget.setWindowTitle(tr("Net Status"));
		statusWidget.show();
	}

	protected void filterTableView(QModelIndex index) {
		//tableProxyModel.setFilterFixedString(listProxyModel.data(index).toString());
	}

	protected void netSelectionChanged(QItemSelection deselected, QItemSelection selected) {
		String regexStr = "^(";
		for (QModelIndex index : netListView.selectionModel().selection().indexes()) {
			regexStr += listProxyModel.data(index).toString() + "|";
		}
		regexStr = regexStr.substring(0, regexStr.length()-1);
		regexStr += ")$";
		tableProxyModel.setFilterRegExp(regexStr);
		tableProxyModel.sort(0);
	}
	
	protected void netDetailClicked(QModelIndex index) {
		currentEntry = netListModel.getEntry(tableProxyModel.mapToSource(index));
		netLabel.setText(currentEntry.getFullName());
		netValue.setText("<Invalid>");
	}
	
	protected void getNetValue() {
		try {
			if (currentEntry != null) {
				 netValue.setText(String.valueOf(icapReadback.readState(currentEntry)));
			}
		} catch (FCPException e) {
			QMessageBox.critical(this, "FCP Error", "Error during FCP communication, connection closed");
			this.fcpProtocol.disconnect();
			this.close();
		}
	}
}
