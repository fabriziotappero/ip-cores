package pl.com.kgajewski.serialcomm.gui;

import gnu.io.CommPort;
import gnu.io.CommPortIdentifier;
import gnu.io.PortInUseException;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigInteger;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.TooManyListenersException;

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.eclipse.swt.graphics.Color;

public class Communication implements SerialPortEventListener {
	
	//passed from main GUI
    Window window = null;

	// just a boolean flag that i use for enabling
	// and disabling buttons depending on whether the program
	// is connected to a serial port or not
	private boolean bConnected = false;

	// the timeout value for connecting with the port
	final static int TIMEOUT = 2000;
    
	// for containing the ports that will be found
	private Enumeration<CommPortIdentifier> ports = null;
	// map the port names to CommPortIdentifiers
	private HashMap<String, CommPortIdentifier> portMap = new HashMap<String, CommPortIdentifier>();

	// this is the object that contains the opened port
	private CommPortIdentifier selectedPortIdentifier = null;
	private SerialPort serialPort = null;

	// input and output streams for sending and receiving data
	private InputStream input = null;
	private OutputStream output = null;

	public Communication(Window window) {
		this.window = window;
	}

	// a string for recording what goes on in the program
	// this string is written to the GUI
	String logText = "";
	
	// search for all the serial ports
	// pre style="font-size: 11px;": none
	// post: adds all the found ports to a combo box on the GUI
	public void searchForPorts() {
		ports = CommPortIdentifier.getPortIdentifiers();

		while (ports.hasMoreElements()) {
			CommPortIdentifier curPort = (CommPortIdentifier) ports
					.nextElement();

			// get only serial ports
			if (curPort.getPortType() == CommPortIdentifier.PORT_SERIAL) {
				window.combo.add(curPort.getName());
				portMap.put(curPort.getName(), curPort);
			}
		}
	}

	// connect to the selected port in the combo box
	// pre style="font-size: 11px;": ports are already found by using the
	// searchForPorts
	// method
	// post: the connected comm port is stored in commPort, otherwise,
	// an exception is generated
	public void connect() {
		if (window.combo.getSelectionIndex() >= 0) {
			String selectedPort = (String) window.combo.getItem(window.combo.getSelectionIndex());
			selectedPortIdentifier = (CommPortIdentifier) portMap
					.get(selectedPort);

			CommPort commPort = null;

			try {
				// the method below returns an object of type CommPort
				commPort = selectedPortIdentifier.open("pl.com.kgajewski.cerialcomm",
						TIMEOUT);
				// the CommPort object can be casted to a SerialPort object
				serialPort = (SerialPort) commPort;
				serialPort.setSerialPortParams(115200,SerialPort.DATABITS_8,SerialPort.STOPBITS_1,SerialPort.PARITY_ODD);

				// for controlling GUI elements
				setConnected(true);

				// logging
				logText = selectedPort + " opened successfully.";
				window.text.setForeground(new Color(window.shell.getDisplay(), 0, 0, 0));
				window.appendText(logText + "\n");

				// CODE ON SETTING BAUD RATE ETC OMITTED
				// XBEE PAIR ASSUMED TO HAVE SAME SETTINGS ALREADY

				// enables the controls on the GUI if a successful connection is
				// made
				window.toggleControls();

			} catch (PortInUseException e) {
				logText = selectedPort + " is in use. (" + e.toString() + ")";

				window.text.setForeground(new Color(window.shell.getDisplay(), 255, 0, 0));
				window.appendText(logText + "\n");
			} catch (Exception e) {
				logText = "Failed to open " + selectedPort + "(" + e.toString()
						+ ")";
				window.appendText(logText + "\n");
				window.text.setForeground(new Color(window.shell.getDisplay(), 255, 0, 0));
			}
		}
	}
	// open the input and output streams
	// pre style="font-size: 11px;": an open port
	// post: initialized input and output streams for use to communicate data
	public boolean initIOStream() {
		// return value for whether opening the streams is successful or not
		boolean successful = false;

		try {
			//
			input = serialPort.getInputStream();
			output = serialPort.getOutputStream();

			successful = true;
			return successful;
		} catch (IOException e) {
			logText = "I/O Streams failed to open. (" + e.toString() + ")";
			window.text.setForeground(new Color(window.shell.getDisplay(), 255, 0, 0));
			window.appendText(logText + "\n");
			return successful;
		}
	}

	// starts the event listener that knows whenever data is available to be
	// read
	// pre style="font-size: 11px;": an open serial port
	// post: an event listener for the serial port that knows when data is
	// received
	public void initListener() {
		try {
			serialPort.addEventListener(this);
			serialPort.notifyOnDataAvailable(true);
		} catch (TooManyListenersException e) {
			logText = "Too many listeners. (" + e.toString() + ")";
			window.text.setForeground(new Color(window.shell.getDisplay(), 255, 0, 0));
			window.appendText(logText + "\n");
		}
	}

	//disconnect the serial port
    //pre style="font-size: 11px;": an open serial port
    //post: closed serial port
    public void disconnect()
    {
        //close the serial port
        try
        {
            serialPort.removeEventListener();
            serialPort.close();
            input.close();
            output.close();
            setConnected(false);
            window.toggleControls();

            logText = "Disconnected.";
            window.text.setForeground(new Color(window.shell.getDisplay(), 255, 0, 0));
            window.appendText(logText + "\n");
        }
        catch (Exception e)
        {
            logText = "Failed to close " + serialPort.getName()
                              + "(" + e.toString() + ")";
            window.text.setForeground(new Color(window.shell.getDisplay(), 255, 0, 0));
            window.appendText(logText + "\n");
        }
    }
	
    //what happens when data is received
    //pre style="font-size: 11px;": serial event is triggered
    //post: processing on the data it reads
    public void serialEvent(SerialPortEvent evt) {
        if (evt.getEventType() == SerialPortEvent.DATA_AVAILABLE)
        {
            try
            {
            	byte [] buffer = new byte[10];
                int n = input.read(buffer);
                if (n > 0)
                {
                	if (n == 1) {
                		BigInteger command = new BigInteger(new byte []{0, buffer[0]});
                		final String s = "Command = " + command.toString(16) + "\n";
                		window.appendText(s);
                	} else {
                		buffer = ArrayUtils.subarray(buffer, 0, buffer.length - 2);
                		buffer = ArrayUtils.add(buffer, (byte)0);
                		ArrayUtils.reverse(buffer);
                		BigInteger data = new BigInteger(buffer);
                		window.appendText(data.toString(16) + "\n");
                	}
                }
                else
                {
                    window.appendText("\n");
                }
            }
            catch (Exception e)
            {
                logText = "Failed to read data. (" + e.toString() + ")";
                window.text.setForeground(new Color(window.shell.getDisplay(), 255, 0, 0));
                window.appendText(logText + "\n");
            }
        }
    }
    
    //method that can be called to send data
    //pre style="font-size: 11px;": open serial port
    //post: data sent to the other device
    public void writeData(String str)
    {
        try
        {
        	for (int i = str.length()-1; i > 0; i -= 2) {
        		String s = str.substring(i-1, i+1);
        		byte b = (byte)(Integer.parseInt(s, 16) & 0xFF);
        		output.write(b);
        		Thread.sleep(1);
        	}
        }
        catch (Exception e)
        {
            logText = "Failed to write data. (" + e.toString() + ")";
            window.text.setForeground(new Color(window.shell.getDisplay(), 255, 0, 0));
            window.appendText(logText + "\n");
        }
    }

    final public boolean getConnected()
    {
        return bConnected;
    }

    public void setConnected(boolean bConnected)
    {
        this.bConnected = bConnected;
    }

	
}
