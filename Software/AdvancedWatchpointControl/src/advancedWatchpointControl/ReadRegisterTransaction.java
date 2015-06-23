////////////////////////////////////////////////////////////////
//
// ReadRegisterTransaction.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class defines a transaction object which is passed to
// the RSP coder in order to perform an RSP 'read' command.
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

public class ReadRegisterTransaction implements TargetTransaction {

	private String packetString = null;
	private long dataValueRead = 0;
	
	public ReadRegisterTransaction(targetDebugRegisterSet.regType reg) {
		packetString = new String("p"); // 'p' is read one register
		int regAddr = targetDebugRegisterSet.getRegisterAddress(reg);
		packetString += Integer.toHexString(regAddr);
	}
	
	@Override
	public String getDataToSend() {
		return packetString;
	}

	@Override
	public boolean receivePacket(String pkt) {

		// A register read response has no leading header / char...
		// so just parse the number.
		long val;
		try {
			val = Long.parseLong(pkt, 16);  // data comes back as a hex string
		} catch (Exception e) {
			// TODO logMessageGUI("Got invalid read data (size " + pkt.length() + "): " + pkt + ": " + e);
			dataValueRead = 0;
			return false;
		}
		
		dataValueRead = val;
		return true;
	}

	public long getDataValueRead() {
		return dataValueRead;
	}
	
}
