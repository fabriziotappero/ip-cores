////////////////////////////////////////////////////////////////
//
// targetDebugRegisterSet.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class defines a transaction object which is passed
// to the RSP coder in order to determine whether the target
// CPU is running.
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


public class TargetRunningTransaction implements TargetTransaction {

	private boolean isTargetRunning = false;
	
	public TargetRunningTransaction() {
	}
	
	@Override
	public String getDataToSend() {
		return new String("?");
	}

	@Override
	public boolean receivePacket(String pkt) {

		// 'S##' means it's stopped, 'R' means it's running,
		// anything else is an error.
		if(pkt.charAt(0) == 'R') {
			// target is running, disallow accesses
			isTargetRunning = true;
		}
		else if(pkt.charAt(0) == 'S') {
			// We got a stop packet 
			isTargetRunning = false;
		}
		else {
			return false;
		}
		
		return true;
	}

	public boolean getIsTargetRunning() {
		return isTargetRunning;
	}
	
}
