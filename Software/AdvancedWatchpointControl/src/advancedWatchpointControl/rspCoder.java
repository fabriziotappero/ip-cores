////////////////////////////////////////////////////////////////
//
// rspCoder.java
//
// Copyright (C) 2010 Nathan Yawn 
//                    (nyawn@opencores.org)
//
// This class handles formatting, escaping, and checksumming
// for packets sent to and received from the network layer.
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


public class rspCoder {


	
	public enum rcvStateType { WAITING_FOR_START, RECEIVING_DATA, RECEIVING_CSUM1, 
		RECEIVING_CSUM2, FINISHED }
	
	private networkSystem netSys = null;
	private rcvStateType rcvState = rcvStateType.WAITING_FOR_START;
	private StringBuilder rcvPacketStringBuilder = null;

	public rspCoder(networkSystem ns) {
		rcvPacketStringBuilder = new StringBuilder();
		netSys = ns;
	}
	
	public void Transact(TargetTransaction t) throws IOException {
		int retries_remaining = 3;
		int rcvchar;
		boolean ret = false;
		
		// Send the packet and look for an RSP ack ("+")
		do {
			escapePacketAndSend(t.getDataToSend());
			rcvchar = netSys.getChar(); // Get +/-
			// If -, retry up to 3 times
		} while((rcvchar != '+') && ((retries_remaining--) >= 0));
		
		if(retries_remaining < 0) {
			throw new IOException("Retries exceeded sending data");
		}
		
		retries_remaining = 3;
		
		do {
			ret = false;
			// Get one complete packet
			String dataPacket = getDataPacket();
			// Unescape, un-RLE, and test the checksum.  Returns null if bad checksum
			String decodedPacket = decodeRSPPacket(dataPacket);
			if(decodedPacket != null) {
				// Let the transaction object parse the specific packet type
				ret = t.receivePacket(decodedPacket);
			}
			if(!ret) {
				sendNak();
			}
		
		} while ((!ret)&& ((retries_remaining--) >= 0));

		if(retries_remaining < 0) {
			throw new IOException("Retries exceeded parsing data");
		}
		
		sendAck();
		
	}  // Transact()

	
	private boolean escapePacketAndSend(String packetString) {
		//System.out.println("Sending packet: \"" + packetString + "\"");
		String protocolString = new String("$");
		
		// Escape the packet data.  '}' is 0x7d, the escape char.
		// Escaped char must be XOR'd with 0x20.
		packetString.replace("}", "}"+('}'^0x20));  // This must be escaped first!
		packetString.replace("#", "}"+('#'^0x20));  // '#' is 0x23
		packetString.replace("$", "}"+('$'^0x20));  // '$' is 0x24
		
		// Add the packet data
		protocolString += packetString;
		
		// Add the separator
		protocolString += "#";
		
		// Create the checksum (from packetString, not protocolString)
		int checksum = getChecksum(packetString);
		
		// Add the checksum
		if(checksum < 0x10)
			protocolString += "0";
		protocolString += Integer.toHexString(checksum);
		
		// Send it.
		return netSys.sendData(protocolString);
	}
	
	
	// This reads one complete data packet from the network, including checksum
	public String getDataPacket() throws IOException {
		int rcvChar;
		rcvState = rcvStateType.WAITING_FOR_START;
		
		do {
			rcvChar = netSys.getChar();
			//System.out.println("parseData: " + rcvChar);
			switch(rcvState) {
				case WAITING_FOR_START:
					if(rcvChar == '$') {
						// discard the '$' character
						rcvState = rcvStateType.RECEIVING_DATA;
						rcvPacketStringBuilder = new StringBuilder();
					}
					break;
				case RECEIVING_DATA:
					if(rcvChar == '#') {
						rcvState = rcvStateType.RECEIVING_CSUM1;
					}
					rcvPacketStringBuilder.append((char)rcvChar);
					break;
				case RECEIVING_CSUM1:
					rcvPacketStringBuilder.append((char)rcvChar);
					rcvState = rcvStateType.RECEIVING_CSUM2;
					break;
				case RECEIVING_CSUM2:
					rcvPacketStringBuilder.append((char)rcvChar);
					rcvState = rcvStateType.FINISHED;
					break;
			}		
		} while(rcvState != rcvStateType.FINISHED);
		
		return rcvPacketStringBuilder.toString();
	}  // parseData()
	
	
	// This looks like it modifies the input String.  But since a String
	// is actually constant, a new String object should be created each
	// time we "modify" the String, so the original input parameter
	// should remain intact.
	private String decodeRSPPacket(String packet) {
		
		//System.out.println("Parsing packet: \"" + packet + "\"\n");
		
		// Test the checksum
		int checksum = 0;
		try {
			//System.out.println("Checksum substring: " + packet.substring(packet.length()-2));
			checksum = Integer.parseInt(packet.substring(packet.length()-2), 16);
		} catch (NumberFormatException e) {
			// TODO Log the error
			sendNak();
			System.out.println("Got bad checksum: calculated " + getChecksum(packet) + ", read " + checksum);
			return null;			
		}
		// Cut off the '#' and checksum
		packet = packet.substring(0, packet.length()-3);
		
		if(checksum != getChecksum(packet)) {
			// TODO Log the error
			sendNak();
			System.out.println("Got bad checksum: calculated " + getChecksum(packet) + ", read " + checksum);
			return null;
		}
		
		// Un-escape
		packet.replace("}"+('#'^0x20), "#");
		packet.replace("}"+('$'^0x20), "$");
		packet.replace("}"+('}'^0x20), "}");
		
		// Undo any run-length encoding.  This code is so ugly.
		if(packet.indexOf("*") != -1) {
			StringBuffer sb = new StringBuffer(packet);
			int thisIndex = 0;
			int lastIndex = 0;
			
			while(-1 != (thisIndex = sb.indexOf("*", lastIndex))) {
				int runlength = sb.charAt(thisIndex+1) - 28;
				sb.deleteCharAt(thisIndex+1);
				sb.deleteCharAt(thisIndex);
				char c = sb.charAt(thisIndex-1);
				for(int i = 0; i < runlength; i++) {
					sb.insert(thisIndex, c);
				}
				lastIndex = thisIndex;
			}

			packet = sb.toString();
		}
		
		return packet;
	}  // handleRSPPacket()

	
	public void sendAck() {
		netSys.sendData("+");
	}
	
	public void sendNak() {
		netSys.sendData("-");
	}
	

	private int getChecksum(String packet) {
		int csum = 0;
		for(int i = 0; i < packet.length(); i++) {
			csum += packet.charAt(i);
			//System.out.println("checksum adding char: " + packet.charAt(i) + ", checksum " + csum);
		}
		csum = csum & 0xFF;
		//System.out.println("Final checksum: " + csum);
		return csum;
	}
}
