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
public class ClockControl {

	private FCPProtocol protocol;
	private int channel;
	/**
	 * 
	 */
	public ClockControl(FCPProtocol p, int c) {
		protocol = p;
		channel = c;
	}
	
	public void deassertAll() {
		try {
			protocol.sendData(channel, (byte)0);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void assertReset() {
		try {
			protocol.sendData(channel, (byte)0);
			protocol.sendData(channel, (byte)0x04);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void singleStep() {
		try {
			protocol.sendData(channel, (byte)0);
			ArrayList<Byte> data = new ArrayList<Byte>();
			data.add((byte)0x00);
			data.add((byte)0x00);
			data.add((byte)0x00);
			data.add((byte)0x01);
			data.add((byte)0x01);
			protocol.sendData(channel, data);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void runClock(int numClocks) {
		try {
			protocol.sendData(channel, (byte)0);
			ArrayList<Byte> data = new ArrayList<Byte>();
			data.add((byte)((numClocks >> 24) & 0xff));
			data.add((byte)((numClocks >> 16) & 0xff));
			data.add((byte)((numClocks >> 8) & 0xff));
			data.add((byte)(numClocks & 0xff));
			data.add((byte)0x01);
			protocol.sendData(channel, data);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void freeRunClock() {
		try {
			protocol.sendData(channel, (byte)0);
			protocol.sendData(channel, (byte)0x02);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public int getChannel() {
		return channel;
	}

	public void setChannel(int channel) {
		this.channel = channel;
	}

}
