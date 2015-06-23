/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.examples;

import java.util.ArrayList;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;

/**
 * @author Peter Lieber
 *
 */
public class SimpleInterface {

	private FCPProtocol protocol;
	/**
	 * 
	 */
	public SimpleInterface(FCPProtocol p) {
		protocol = p;
	}
	
	public void setLED(byte value) {
		try {
			protocol.sendData(1, value);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public byte getDIP() {
		try {
			protocol.sendDataRequest(1, 1);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		byte[] res = protocol.getDataResponse();
		return res[0];
	}
	
	public void setRegister(int value) {
		ArrayList<Byte> bytes = new ArrayList<Byte>();
		bytes.add(new Byte((byte) (value & 0xff)));
		bytes.add(new Byte((byte) ((value >> 8) & 0xff)));
		bytes.add(new Byte((byte) ((value >> 16) & 0xff)));
		bytes.add(new Byte((byte) ((value >> 24) & 0xff)));
		try {
			protocol.sendData(2, bytes);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public int getRegister() {
		try {
			protocol.sendDataRequest(2, 4);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		byte[] bytes = protocol.getDataResponse();
		int res = (((int)bytes[3] & 0xff) << 24) | (((int)bytes[2] & 0xff) << 16) | (((int)bytes[1] & 0xff) << 8) |  (((int)bytes[0] & 0xff));
		return res;
	}

}
