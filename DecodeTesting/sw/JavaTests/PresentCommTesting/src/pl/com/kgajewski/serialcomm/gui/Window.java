package pl.com.kgajewski.serialcomm.gui;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.MouseAdapter;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

public class Window {
	
	//Communicator object
    Communication communication = null;
	public Display display;
	protected Shell shell;
	public Text text;
	private Text data;
	private Text key;
	public Combo combo;
	private Button btnConnect;
	private Button btnDisconnect;
	private Button btnSendData;

	public void toggleControls()
    {
        if (communication.getConnected() == true)
        {
        	btnDisconnect.setEnabled(true);
            btnConnect.setEnabled(false);
            btnSendData.setEnabled(true);
        }
        else
        {
        	btnDisconnect.setEnabled(false);
            btnConnect.setEnabled(true);
            btnSendData.setEnabled(false);
        }
    }
    
	/**
	 * Launch the application.
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		try {
			Window window = new Window();
			window.open();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Open the window.
	 */
	public void open() {
		display = Display.getDefault();
		createContents();
		communication = new Communication(this);
		communication.searchForPorts();
		toggleControls();
		shell.open();
		shell.layout();
		while (!shell.isDisposed()) {
			if (!display.readAndDispatch()) {
				display.sleep();
			}
		}
	}

	/**
	 * Create contents of the window.
	 */
	protected void createContents() {
		shell = new Shell();
		shell.setSize(470, 274);
		shell.setText("SWT Application");
		shell.setLayout(null);

		Composite composite = new Composite(shell, SWT.NONE);
		composite.setBounds(0, 0, 444, 236);

		text = new Text(composite, SWT.BORDER | SWT.MULTI);
		this.text.setBounds(107, 126, 327, 105);

		combo = new Combo(composite, SWT.NONE);
		combo.setBounds(10, 10, 91, 23);

		btnConnect = new Button(composite, SWT.NONE);
		btnConnect.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseUp(MouseEvent arg0) {
				communication.connect();
		        if (communication.getConnected() == true)
		        {
		            if (communication.initIOStream() == true)
		            {
		            	communication.initListener();
		            }
		        }
			}
		});
		btnConnect.setBounds(107, 10, 75, 25);
		btnConnect.setText("Connect");

		btnDisconnect = new Button(composite, SWT.NONE);
		btnDisconnect.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseUp(MouseEvent arg0) {
				communication.disconnect();
			}
		});
		btnDisconnect.setBounds(188, 10, 75, 25);
		btnDisconnect.setText("Disconnect");

		Label lblLog = new Label(composite, SWT.NONE);
		lblLog.setBounds(107, 105, 186, 15);
		lblLog.setText("Log");

		data = new Text(composite, SWT.BORDER);
		data.setBounds(45, 39, 248, 21);

		key = new Text(composite, SWT.BORDER);
		key.setBounds(45, 66, 248, 21);

		btnSendData = new Button(composite, SWT.NONE);
		btnSendData.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseUp(MouseEvent arg0) {
				communication.writeData(data.getText());
				communication.writeData(key.getText());
			}
		});
		btnSendData.setBounds(10, 100, 75, 25);
		btnSendData.setText("Send");
		
		Label lblData = new Label(composite, SWT.NONE);
		lblData.setBounds(10, 39, 29, 15);
		lblData.setText("Data");
		
		Label lblKey = new Label(composite, SWT.NONE);
		lblKey.setBounds(10, 66, 55, 15);
		lblKey.setText("Key");
	}

	public void appendText(final String s) {
		display.syncExec(new Runnable() {
			public void run() {
				text.append(s);
			}
		});

	}
}
