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
public class RegisterInterface {

	private FCPProtocol protocol;
	private int channel;
	/**
	 * 
	 */
	public RegisterInterface(FCPProtocol p) {
		protocol = p;
		channel = 1;
	}

	public RegisterInterface(FCPProtocol p, int channel) {
		protocol = p;
		this.channel = channel;
	}
	
	public void setRegister(int value) {
		ArrayList<Byte> bytes = new ArrayList<Byte>();
		bytes.add(new Byte((byte) (value & 0xff)));
		bytes.add(new Byte((byte) ((value >> 8) & 0xff)));
		bytes.add(new Byte((byte) ((value >> 16) & 0xff)));
		bytes.add(new Byte((byte) ((value >> 24) & 0xff)));
		try {
			protocol.sendData(channel, bytes);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public int getRegister() {
		try {
			protocol.sendDataRequest(channel, 4);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		byte[] bytes = protocol.getDataResponse();
		int res = (((int)bytes[3] & 0xff) << 24) | (((int)bytes[2] & 0xff) << 16) | (((int)bytes[1] & 0xff) << 8) |  (((int)bytes[0] & 0xff));
		return res;
	}

}
