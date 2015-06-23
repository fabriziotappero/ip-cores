////////////////////////////////////////////////////////////////
//
// WriteRegisterTransaction.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class defines a transaction object which is passed to
// the RSP coder in order to perform a register write 
// transaction.
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


public class WriteRegisterTransaction implements TargetTransaction {

		private String packetString = null;
	
	public WriteRegisterTransaction(targetDebugRegisterSet.regType reg, long val) {
		packetString = new String("P"); // 'P' is write one register
		int regAddr = targetDebugRegisterSet.getRegisterAddress(reg);
		
		packetString += Integer.toHexString(regAddr);
		packetString += "=";
		
		String valueStr = Long.toHexString(val);
		
		// There must be 8 bytes of 'value'
		if(valueStr.length() > 8) {
			// Use the last 8 bytes, the first 8 may just be a sign extension
			valueStr = valueStr.substring(valueStr.length() - 8, valueStr.length());
		}
		
		int padsize = 8 - valueStr.length();
		for(int i = 0; i < padsize; i++) {
			packetString += '0';
		}
		
		packetString += valueStr;
	}
	
	@Override
	public String getDataToSend() {
		return packetString;
	}

	@Override
	public boolean receivePacket(String pkt) {

		// Only one valid response from a register write: "OK"
		if(pkt.charAt(0) == 'O' && pkt.charAt(1) == 'K') {
			return true;
		}		
		
		return false;
	}

}
