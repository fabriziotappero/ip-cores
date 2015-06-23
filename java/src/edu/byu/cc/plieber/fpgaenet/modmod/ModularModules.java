package edu.byu.cc.plieber.fpgaenet.modmod;

import java.io.IOException;
import java.net.InetAddress;
import java.util.ArrayList;

import com.trolltech.qt.gui.*;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;
import edu.byu.cc.plieber.fpgaenet.icapif.IcapInterface;

public class ModularModules extends QMainWindow {

	private QMenu fileMenu;
	private QMenu helpMenu;

	private QAction addModule;
	private QAction connectAct;
	private QAction exitAct;
	private QAction aboutAct;
	private QAction aboutQtJambiAct;

	public static void main(String[] args) {
		QApplication.initialize(args);

		ModularModules testModularModules = new ModularModules(null);
		testModularModules.show();

		QApplication.exec();

		testModularModules.tearDown();
	}

	private FCPProtocol fcpProtocol;
	private IcapInterface icapInterface;

	private QFrame mainFrame;

	private MD5Widget md5Widget;
	private SHA1Widget sha1Widget;

	private QVBoxLayout mainLayout;
	private QHBoxLayout bottomLayout;
	private QStackedWidget moduleStack;

	private ConnectionWidget connectWidget;
	private StaticModulesWidget staticWidget;
	private AvailableModulesWidget availWidget;
	private ChannelConfigurationWidget configWidget;

	public ModularModules(QWidget parent) {
		super(parent);
		this.setWindowTitle("Module Modules");
		try {
			fcpProtocol = new FCPProtocol();
			icapInterface = new IcapInterface(fcpProtocol, 3, 4);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			QMessageBox.critical(this, "Bind Error", "Could not bind socket.");
		}
		
		createActions();
		createMenus();
		// makeConnections();
		createWidgets();
		createLayout();
		connectSignalsAndSlots();
		
		connectionChanged();
	}

	@SuppressWarnings("unused")
	private void connect() {
		ConnectionWidget cw = new ConnectionWidget(null, fcpProtocol);
		cw.ConnectionChangedSignal.connect(this, "connectionChanged()");
		cw.show();
	}

	private void connectionChanged() {
		statusBar().showMessage(
				tr("FCP is "
						+ (this.fcpProtocol.isConnected() ? "" : "not ")
						+ "connected"
						+ (this.fcpProtocol.isConnected() ? (" to " + fcpProtocol.getDestIPAddress().getHostAddress()
								+ " on port " + fcpProtocol.getDestUDPPort() + ".") : ".")));
	}

	@SuppressWarnings("unused")
	private void addModule() {
		CreateModuleWidget cmw = new CreateModuleWidget(null, fcpProtocol);
		cmw.AvailableModuleCreated.connect(this, "AvailableModuleCreatedHandler(AvailableModule)");
		cmw.show();
	}

	@SuppressWarnings("unused")
	private void AvailableModuleCreatedHandler(AvailableModule am) {
		availWidget.addModule(am);
		if (!moduleStack.children().contains(am.getControlWidget())) {
			moduleStack.addWidget(am.getControlWidget());
		}
	}

	private void createActions() {
		addModule = new QAction(tr("&Add Module"), this);
		addModule.setShortcut(tr("Ctrl+A"));
		addModule.setStatusTip(tr("Add Available Module"));
		addModule.triggered.connect(this, "addModule()");

		connectAct = new QAction(tr("&Connect"), this);
		connectAct.setShortcut(tr("Ctrl+N"));
		connectAct.setStatusTip(tr("Connect to FPGA"));
		connectAct.triggered.connect(this, "connect()");

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
		fileMenu.addAction(addModule);
		fileMenu.addAction(connectAct);
		fileMenu.addAction(exitAct);

		helpMenu = menuBar().addMenu(tr("&Help"));
		helpMenu.addAction(aboutAct);
		helpMenu.addAction(aboutQtJambiAct);
	}

	private void createWidgets() {
		moduleStack = new QStackedWidget(this);
		staticWidget = new StaticModulesWidget(this, fcpProtocol);
		availWidget = new AvailableModulesWidget(this);
		configWidget = new ChannelConfigurationWidget(this);
		md5Widget = new MD5Widget(moduleStack, fcpProtocol);
		sha1Widget = new SHA1Widget(moduleStack, fcpProtocol);
	}

	private void createLayout() {
		mainFrame = new QFrame(this);
		this.setCentralWidget(mainFrame);
		mainLayout = new QVBoxLayout(mainFrame);
		bottomLayout = new QHBoxLayout();
		mainLayout.addWidget(configWidget);
		mainLayout.addLayout(bottomLayout);
		mainLayout.addStretch();
		moduleStack.addWidget(new QFrame(moduleStack));
		moduleStack.addWidget(md5Widget);
		moduleStack.addWidget(sha1Widget);
		bottomLayout.addWidget(availWidget);
		bottomLayout.addWidget(staticWidget);
		bottomLayout.addWidget(moduleStack);
		bottomLayout.setStretch(0, 0);
		bottomLayout.setStretch(1, 1);
		bottomLayout.setStretch(2, 6);
	}

	private void connectSignalsAndSlots() {
		configWidget.ChannelConfiguredSignal.connect(this, "channelConfiguredHandler(ConfigurationChannel)");
		configWidget.ModuleRemovedSignal.connect(this, "moduleRemovedHandler(AvailableModule)");
		configWidget.ModuleSelectedSignal.connect(this, "moduleSelectedHandler(AvailableModule)");
	}

	protected void about() {
		QMessageBox.information(this, "Info",
				"Modular Modules Demo\nv 0.0.1\ncopyright 2010 Peter Lieber\nBrigham Young University");
	}

	public void tearDown() {
		if (fcpProtocol != null)
			fcpProtocol.disconnect();
	}

	@SuppressWarnings("unused")
	private void channelConfiguredHandler(ConfigurationChannel cc) {
		AvailableModule am = cc.getResident();
		try {
			icapInterface.sendIcapFile(am.getBitStreams().get(cc.getChannel()));
			am.getControlWidget().setChannelNumber(cc.getChannel());
		} catch (Exception e) {
			cc.removeModule(am);
			QMessageBox.critical(this, "Error", "Error configuring channel!\n" + e.getMessage());
		}
		// QMessageBox.information(this, "Configuration", "Channel " +
		// cc.getChannel() + " configured.");
	}

	@SuppressWarnings("unused")
	private void moduleRemovedHandler(AvailableModule am) {
		availWidget.addModule(new AvailableModule(am));
	}

	@SuppressWarnings("unused")
	private void moduleSelectedHandler(AvailableModule am) {
		if (am != null)
			moduleStack.setCurrentWidget(am.getControlWidget());
	}
}
