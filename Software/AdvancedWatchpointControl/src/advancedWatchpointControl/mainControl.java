////////////////////////////////////////////////////////////////
//
// mainControl.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This is the central control in the program.  It oversees
// the processes of reading and writing the target hardware.
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

import java.io.IOException;
import java.util.LinkedList;
import java.util.List;


public class mainControl {

	public enum connectionStatus { NOT_CONNECTED, CONNECTING, CONNECTED, CONNECT_ERROR }
	
	private targetDebugRegisterSet regSet = null;
	private networkSystem netSys = null;
	private targetTransactor transactor = null;
	private rspCoder rsp = null;
	// Yes, there really need to have three different observer interfaces,
	// in case a single UI class wants to be more than one.
	private List<RegisterObserver> registerObserverList = null;
	private List<NetworkStatusObserver> networkStatusObserverList = null;
	private List<LogMessageObserver> logmsgObserverList = null;
	private String networkStatus = "";
	private String logMessage = "";
	
	public mainControl() {
		registerObserverList = new LinkedList<RegisterObserver>();
		networkStatusObserverList = new LinkedList<NetworkStatusObserver>();
		logmsgObserverList = new LinkedList<LogMessageObserver>();
		regSet = new targetDebugRegisterSet();  // Create the object to hold the debug registers
		netSys = new networkSystem(this);
		rsp = new rspCoder(netSys);
		transactor = new targetTransactor(rsp);
	}

	public void setNetworkSystem(networkSystem ns) {
		netSys = ns;
	}
	
	public void registerForRegsetUpdates(RegisterObserver obs) {
		registerObserverList.add(obs);
	}
	
	public void registerForNetworkStatusUpdates(NetworkStatusObserver obs) {
		networkStatusObserverList.add(obs);
	}
	
	public void registerForLogMessages(LogMessageObserver obs) {
		logmsgObserverList.add(obs);
	}
	
	public targetDebugRegisterSet getRegSet() {
		return regSet;
	}
	
	public void doNetworkConnect(String serverHostname, int port) {
		if(netSys != null) {
			netSys.connect(serverHostname, port);
		}
	}
	
	public synchronized void doReadAllRegisters() {
		try {  // Any target interaction may throw an IOException.
			
			if(transactor.isTargetRunning()) {
				setLogMessage("Cannot read registers while target is running");
				return;
			}
		
			// get all (debug) registers (we use) from the target
			regSet.setDCR(0, transactor.readRegister(targetDebugRegisterSet.regType.DCR0));
			regSet.setDCR(1, transactor.readRegister(targetDebugRegisterSet.regType.DCR1));
			regSet.setDCR(2, transactor.readRegister(targetDebugRegisterSet.regType.DCR2));
			regSet.setDCR(3, transactor.readRegister(targetDebugRegisterSet.regType.DCR3));
			regSet.setDCR(4, transactor.readRegister(targetDebugRegisterSet.regType.DCR4));
			regSet.setDCR(5, transactor.readRegister(targetDebugRegisterSet.regType.DCR5));
			regSet.setDCR(6, transactor.readRegister(targetDebugRegisterSet.regType.DCR6));
			regSet.setDCR(7, transactor.readRegister(targetDebugRegisterSet.regType.DCR7));
			regSet.setDVR(0, transactor.readRegister(targetDebugRegisterSet.regType.DVR0));
			regSet.setDVR(1, transactor.readRegister(targetDebugRegisterSet.regType.DVR1));
			regSet.setDVR(2, transactor.readRegister(targetDebugRegisterSet.regType.DVR2));
			regSet.setDVR(3, transactor.readRegister(targetDebugRegisterSet.regType.DVR3));
			regSet.setDVR(4, transactor.readRegister(targetDebugRegisterSet.regType.DVR4));
			regSet.setDVR(5, transactor.readRegister(targetDebugRegisterSet.regType.DVR5));
			regSet.setDVR(6, transactor.readRegister(targetDebugRegisterSet.regType.DVR6));
			regSet.setDVR(7, transactor.readRegister(targetDebugRegisterSet.regType.DVR7));
			regSet.setDWCR0(transactor.readRegister(targetDebugRegisterSet.regType.DWCR0));
			regSet.setDWCR1(transactor.readRegister(targetDebugRegisterSet.regType.DWCR1));		
			regSet.setDMR1(transactor.readRegister(targetDebugRegisterSet.regType.DMR1));
			regSet.setDMR2(transactor.readRegister(targetDebugRegisterSet.regType.DMR2));
		} catch (IOException e) {
			setLogMessage("Network error: " + e.getMessage());
			// *** TODO Disconnect?? Retry?
		}
	
		// Notify observers to set GUI elements accordingly
		try {
			for(RegisterObserver obs : registerObserverList) {
				obs.notifyRegisterUpdate(RegisterObserver.updateDirection.REGS_TO_GUI);
			}
		} catch(NumberFormatException e) {
			// Since we're going long->String, this should never happen.
			setLogMessage("Impossible exception while updating GUI!");
		}
	}
	
	public synchronized void doWriteAllRegisters() {
		
		try {
			
			if(transactor.isTargetRunning()) {
				setLogMessage("Cannot write registers while target is running");
				return;
			}

			// Notify observers to set registers from GUI elements
			try {
				for(RegisterObserver obs : registerObserverList) {
					obs.notifyRegisterUpdate(RegisterObserver.updateDirection.GUI_TO_REGS);
				}
			} catch (NumberFormatException e) {
				// DVRs must be converted from Strings.  This may fail and throw the exception.
				setLogMessage("Illegal DVR value, registers not written");
				return;
			}

			transactor.writeRegister(targetDebugRegisterSet.regType.DCR0, regSet.getDCR(0));
			transactor.writeRegister(targetDebugRegisterSet.regType.DCR1, regSet.getDCR(1));
			transactor.writeRegister(targetDebugRegisterSet.regType.DCR2, regSet.getDCR(2));
			transactor.writeRegister(targetDebugRegisterSet.regType.DCR3, regSet.getDCR(3));
			transactor.writeRegister(targetDebugRegisterSet.regType.DCR4, regSet.getDCR(4));
			transactor.writeRegister(targetDebugRegisterSet.regType.DCR5, regSet.getDCR(5));
			transactor.writeRegister(targetDebugRegisterSet.regType.DCR6, regSet.getDCR(6));
			transactor.writeRegister(targetDebugRegisterSet.regType.DCR7, regSet.getDCR(7));
			transactor.writeRegister(targetDebugRegisterSet.regType.DVR0, regSet.getDVR(0));
			transactor.writeRegister(targetDebugRegisterSet.regType.DVR1, regSet.getDVR(1));
			transactor.writeRegister(targetDebugRegisterSet.regType.DVR2, regSet.getDVR(2));
			transactor.writeRegister(targetDebugRegisterSet.regType.DVR3, regSet.getDVR(3));
			transactor.writeRegister(targetDebugRegisterSet.regType.DVR4, regSet.getDVR(4));
			transactor.writeRegister(targetDebugRegisterSet.regType.DVR5, regSet.getDVR(5));
			transactor.writeRegister(targetDebugRegisterSet.regType.DVR6, regSet.getDVR(6));
			transactor.writeRegister(targetDebugRegisterSet.regType.DVR7, regSet.getDVR(7));
			transactor.writeRegister(targetDebugRegisterSet.regType.DWCR0, regSet.getDWCR0());
			transactor.writeRegister(targetDebugRegisterSet.regType.DWCR1, regSet.getDWCR1());
			// Note that DMR2 must be written AFTER the DWCR registers.  If
			// DMR2 is written first, then the trap condition will be cleared,
			// but it will still exist because count still equals match val
			// in the DWCR.
			transactor.writeRegister(targetDebugRegisterSet.regType.DMR1, regSet.getDMR1());
			transactor.writeRegister(targetDebugRegisterSet.regType.DMR2, regSet.getDMR2());
		} catch (IOException e) {
			setLogMessage("Network error: " + e.getMessage());
			// TODO *** Disconnect?  Retry??
		}
	}

	
	// This is thread-safe for the GUI.  It must be used by the network thread (receiveResponse()
	// and anything called from it) to log messages to the GUI.
	public void setLogMessage(final String msg) {
		
		logMessage = msg;
		
		// Tell the display(s) to fetch and show the status
		for(LogMessageObserver obs : logmsgObserverList) {
			obs.notifyLogMessage();
		}
	}
	
	public String getLogMessage() {
		return logMessage;
	}
	
	// This just puts the status into a member variable,
	// for the network status observers to retrieve.
	public void setNetworkStatus(connectionStatus cStatus) {		
		switch(cStatus) {
		case NOT_CONNECTED:
			networkStatus = "Not Connected";
			break;
		case CONNECTING:
			networkStatus = "Connecting...";
			break;
		case CONNECTED:
			networkStatus = "Connected";
			break;
		case CONNECT_ERROR:
			networkStatus = "Error Connecting";
			break;
		default:
			networkStatus = "Unknown Error";
		}
		
		// Tell the display(s) to fetch and show the status
		for(NetworkStatusObserver obs : networkStatusObserverList) {
			obs.notifyNetworkStatus();
		}
	}
	
	public String getNetworkStatus() {
		return networkStatus;
	}
}
