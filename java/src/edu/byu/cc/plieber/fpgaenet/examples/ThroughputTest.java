/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.examples;

import java.io.IOException;
import java.net.InetAddress;
import java.util.ArrayList;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;

/**
 * @author Peter Lieber
 * 
 */
public class ThroughputTest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		FCPProtocol p = null;
		try {
			p = new FCPProtocol();
			p.setSendWindow(10);
			p.connect(InetAddress.getByName("10.0.1.42"));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		while (!p.isConnected())
			;

		ArrayList<Byte> data = new ArrayList<Byte>();
		for (int i = 0; i < 1024; i++) {
			data.add(new Byte((byte) 0x0));
		}

		long totaltime = 0;
		for (int j = 0; j < 10; j++) {
			long time = System.currentTimeMillis();
			for (int i = 0; i < 4096; i++) {
				//data.set(1023, new Byte((byte)i));
				try {
					p.sendData(1, data, 1024);
				} catch (FCPException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			while (p.packetsPending())
				;
			time = System.currentTimeMillis() - time;
			System.out.println("4 MB time: " + time);
			System.out.println("While Count: " + p.getWhileCount());
			p.resetWhileCount();
			totaltime += time;
		}
		System.out.println("Total Time: " + totaltime + " ms");
		System.out.println("Average Throughput: " + 40.0 / ((double)totaltime/ 1000.0) + " MB/s");
		System.out.println("Average Throughput: " + 320.0 / ((double)totaltime/ 1000.0) + " Mb/s");
		p.disconnect();
	}

}
