/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.fcp;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.InetAddress;

/**
 * @author plieber
 * 
 */
public class FCPTest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		if (args.length != 5) {
			System.out
					.println("usage: FCPTest <destaddr> <selfport> <destport> <datafile> <numToRead>");
			return;
		}
		String addr = args[0];
		int port = Integer.parseInt(args[1]);
		int port2 = Integer.parseInt(args[2]);
		int numToRead = Integer.parseInt(args[4]);

		FCPProtocol protocol = null;
		try {
			protocol = new FCPProtocol(port, port2);
			if (args.length == 5) {
				protocol.connect(InetAddress.getByName(addr), port2);
				while (!protocol.connected)
					;
				// byte[] data = new byte[] { 0, 1, 2, 3 };
				// for (int i = 8; i <= 10; i++) {
				// protocol.send(i, data);
				// }
				// protocol.sendDataRequest(1, 5);
				File file = new File(args[3]);
				InputStream is = new FileInputStream(file);
				long length = file.length();
				if (length > Integer.MAX_VALUE) {

				}

				byte[] writereg = new byte[1024];
				int offset = 0;
				int numRead = 0;
				while (offset < file.length()
						&& (numRead = is.read(writereg, 0, 1024)) >= 0) {
					offset += numRead;
					try {
						protocol.send(3, writereg, numRead);
					} catch (FCPException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
				if (numToRead > 0) {
					byte[] read4 = new byte[] { (byte) ((numToRead >> 8) & 0xff), (byte) (numToRead & 0xff) };
					try {
						protocol.send(4, read4, read4.length);
						protocol.sendDataRequest(4, numToRead);
					} catch (FCPException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
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
