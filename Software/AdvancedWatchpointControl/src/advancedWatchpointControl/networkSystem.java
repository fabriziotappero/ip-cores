////////////////////////////////////////////////////////////////
//
// networkSystem.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class performs the low-level network I/O.
//
////////////////////////////////////////////////////////////////
//
// This source file may be used and distributed without
// restriction provided that this copyright statement is not
// removed from the file and that any derivative work contains
// the original copyright notice and the associated disclaimer.
// 
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation;
// either version 3.0 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied 
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
// 
// You should have received a copy of the GNU General
// Public License along with this source; if not, download it 
// from http://www.gnu.org/licenses/gpl.html
//
////////////////////////////////////////////////////////////////

package advancedWatchpointControl;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;
import java.net.UnknownHostException;
import java.nio.charset.Charset;


public class networkSystem {

	private Socket sockfd = null;
	private DataOutputStream ostream = null;
	private BufferedReader istream = null;
	private boolean isValid = false;
	// We use mainControl for logging / displaying network state
	private mainControl mCtrl = null;

	
	public networkSystem(mainControl mc) {
		mCtrl = mc;
	}
	
	protected void finalize() throws Throwable {
		disconnect(true);
	}
	
	public void connect(String hostname, int portNumber) {
		disconnect(true);
		System.out.println("Network connecting");
		try {
			sockfd = new Socket(hostname, portNumber);
			sockfd.setSoLinger(false, 1);
	   	    istream = new BufferedReader(new InputStreamReader(sockfd.getInputStream(), Charset.forName("US-ASCII")));
	   	    ostream = new DataOutputStream(sockfd.getOutputStream());
	    }
		catch (UnknownHostException e) {
			disconnect(false);
	    	mCtrl.setNetworkStatus(mainControl.connectionStatus.CONNECT_ERROR);
            mCtrl.setLogMessage("Unknown host: " + e);
            return;
        }
	    catch (IOException e) {
	    	disconnect(false);
	    	mCtrl.setNetworkStatus(mainControl.connectionStatus.CONNECT_ERROR);
	    	mCtrl.setLogMessage("Connect error: " + e.getMessage());
	    	return;
	    }
	    
	    isValid = true;
    	mCtrl.setNetworkStatus(mainControl.connectionStatus.CONNECTED);
    	String msg = "Connected to server \"" + hostname + "\", port " + portNumber;
    	mCtrl.setLogMessage(msg);
    	System.out.println("Network connected");
    	mCtrl.doReadAllRegisters();  // Gets regs from target, sets GUI
	}
	
	public void disconnect(boolean waitForReaderExit) {
		System.out.println("Network disconnecting");
		isValid = false;
		
		try {
			if(sockfd != null)
				sockfd.shutdownInput();
			if(sockfd != null)
				sockfd.close();
		}
		catch (IOException e) {
			// Ignore errors when closing socket
		}
		
    	sockfd = null;
    	istream = null;
    	ostream = null;
	}
	
	public boolean isConnected() {
		return isValid;
	}
	
	public boolean sendData(String outdata) {
		if(isValid) {
			try {
				ostream.writeBytes(outdata);
			}
			catch (IOException e) {
		    	mCtrl.setNetworkStatus(mainControl.connectionStatus.CONNECT_ERROR);
		    	mCtrl.setLogMessage(e.getMessage());
		    	disconnect(true);
		    	return false;
			}	
		}
		else {
			mCtrl.setLogMessage("Not connected: connect to server first.");
			return false;
		}
		return true;
	}
	
	public int getChar() throws IOException {
		
		if(istream != null)
			return istream.read();
		
		throw(new IOException("Network reader is null!"));
	}
	
}
