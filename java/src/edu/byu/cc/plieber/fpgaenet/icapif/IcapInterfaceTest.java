/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.icapif;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.util.ArrayList;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;
import edu.byu.cc.plieber.util.StringUtil;

/**
 * @author Peter Lieber
 *
 */
public class IcapInterfaceTest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		if (args.length != 3) {
			System.out.println("usage: IcapInterfaceTest <IP Address> <input file> <num to read>");
			return;
		}
		int numToRead = Integer.parseInt(args[2]);
		
		FCPProtocol protocol = null;
		
		try {
			protocol = new FCPProtocol();
			protocol.connect(InetAddress.getByName(args[0]), 0x3001);
		} catch (IOException e) {
			System.err.println("IO Error, Exiting...");
			return;
		} finally {
			if (protocol == null) {
				System.err.println("Error creating FCP, Exiting...");
				return;
			}
		}
		while (!protocol.isConnected());
		IcapInterface icapif = new IcapInterface(protocol);
		
		File file = new File(args[1]);
		InputStream is = null;
		try {
			is = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			if (is == null) {
				System.err.println("input stream null");
				return;
			}
		}
		long length = file.length();
		byte[] bytes = new byte[(int)length];
		try {
			is.read(bytes);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return;
		}
		
		try {
			icapif.sendIcapData(bytes, (int) length);
		} catch (FCPException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		if (numToRead > 0) {
			ArrayList<Byte> readBytes = null;
			try {
				icapif.requestIcapData(numToRead);
				readBytes = icapif.receiveIcapData();
			} catch (FCPException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			System.out.println("Data received from ICAP: \n" + StringUtil.listToString(readBytes));
		}
		
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		try {
			in.readLine();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		protocol.disconnect();
	}

}
