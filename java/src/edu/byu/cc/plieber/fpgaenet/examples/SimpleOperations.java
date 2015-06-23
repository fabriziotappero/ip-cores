/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.examples;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;
import edu.byu.cc.plieber.util.StringUtil;

/**
 * @author Peter Lieber
 * 
 */
public class SimpleOperations {

	/** 
	 * Sends or receives data to/from the FPGA over FCP through the given channel.
	 * @param args
	 * @throws UnknownHostException
	 */
	public static void main(String[] args) throws UnknownHostException {
		if (args.length < 4) {
			System.out
					.println("Usage: SimpleOperations <'send'|'read'> <ipaddress> <channel> <dataToSend(hex byte)|numBytesToRead> [more data...]");
		}
		FCPProtocol p = createConnection(InetAddress.getByName(args[2]));
		int channel = Integer.parseInt(args[3]);
		if (args[1] == "send") {
			int numBytes = args.length - 4;
			ArrayList<Byte> data = new ArrayList<Byte>();
			for (int i = 4; i < args.length; i++) {
				data.add(new Byte((byte) (Integer.parseInt(args[i], 16))));
			}
			send(p, channel, data, numBytes);
		} else if (args[1] == "read") {
			ArrayList<Byte> data = read(p, channel, Integer.parseInt(args[4]));
			System.out.println(StringUtil.listToString(data));
		} else {
			System.out
					.println("Usage: SimpleOperations <'send'|'read'> <ipaddress> <dataToSend(hex byte)|numBytesToRead> [more data...]");
		}
	}

	private static ArrayList<Byte> read(FCPProtocol p, int channel, int numBytes) {
		try {
			p.sendDataRequest(channel, numBytes);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		byte[] data = p.getDataResponse();
		ArrayList<Byte> ret = new ArrayList<Byte>();
		for (int i = 0; i < data.length; i++) {
			ret.add(data[i]);
		}
		return ret;
	}

	private static void send(FCPProtocol p, int channel, ArrayList<Byte> data, int numBytes) {
		try {
			p.sendData(channel, data, numBytes);
		} catch (FCPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	static FCPProtocol createConnection(java.net.InetAddress address) {
		FCPProtocol p = null;
		try {
			p = new FCPProtocol();
			p.connect(address);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		while (!p.isConnected())
			;
		return p;
	}

}
