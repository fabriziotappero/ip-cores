package edu.byu.cc.plieber.fpgaenet.modmod;
import java.util.ArrayList;

import com.trolltech.qt.core.Qt.AlignmentFlag;
import com.trolltech.qt.gui.*;

public class AvailableModulesWidget extends QWidget implements ModuleContainer {

    public static void main(String[] args) {
        QApplication.initialize(args);

        AvailableModulesWidget testAvailableModulesWidget = new AvailableModulesWidget(null);
        testAvailableModulesWidget.show();

        QApplication.exec();
    }
    
    private QVBoxLayout layout;

    public AvailableModulesWidget(QWidget parent){
        super(parent);
        /*QLabel background = new QLabel(this);
        background.setPixmap(new QPixmap("classpath:edu/byu/cc/plieber/fpgaenet/modmod/g/availProto.png"));
        QBoxLayout layout = new QVBoxLayout();
        this.setLayout(layout);
        layout.addWidget(background);*/
        availableModules = new ArrayList<AvailableModule>();
        layout = new QVBoxLayout(this);
        QLabel label = new QLabel("Available Modules");
        label.font().setPixelSize(30);
        layout.addWidget(label);
        layout.addStretch();
    }
    
    private ArrayList<AvailableModule> availableModules;

	@Override
	public void addModule(AvailableModule module) {
		availableModules.add(module);
		module.setParentContainer(this);
		module.setAvailable(true);
		layout.insertWidget(availableModules.size(), module);
	}

	@Override
	public void removeModule(AvailableModule module) {
		availableModules.remove(module);
		layout.removeWidget(module);
		module.close();
	}
}
