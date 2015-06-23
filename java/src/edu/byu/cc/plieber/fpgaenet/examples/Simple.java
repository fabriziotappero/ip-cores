/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.examples;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.net.UnknownHostException;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;

/**
 * @author Peter Lieber
 *
 */
public class Simple {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		FCPProtocol p = null;
		try {
			p = new FCPProtocol();
			p.connect(InetAddress.getByName("10.0.1.42"));
			while (!p.isConnected());
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		BufferedReader ir = new BufferedReader(new InputStreamReader(System.in));
		
		SimpleInterface sif = new SimpleInterface(p);
		String in = "";
		System.out.println("Welcome to the Example Design");
		mainloop: while (!in.equalsIgnoreCase("quit")) {
			try {
				in = ir.readLine();
			} catch (IOException e) {
				e.printStackTrace();
				in = "quit";
			} 
			if (in.toLowerCase().startsWith("w")) {
				String[] tokens = in.split(" ");
				if (tokens.length < 2) {
					System.out.println("Usage: w <int to write>");
					continue mainloop;
				}
				int value = Integer.parseInt(tokens[1]);
				sif.setRegister(value);
			}
			else if (in.toLowerCase().startsWith("r")) {
				int value = sif.getRegister();
				System.out.println("Register Value: " + value);
			}
			else if (in.toLowerCase().startsWith("l")) {
				String[] tokens = in.split(" ");
				if (tokens.length < 2) {
					System.out.println("Usage: l <LED value to write>");
					continue mainloop;
				}
				byte value = (byte) (Integer.parseInt(tokens[1]) & 0xff);
				sif.setLED(value);
			}
			else if (in.toLowerCase().startsWith("d")) {
				byte value = sif.getDIP();
				System.out.println("DIP Switch Value: " + value);
			}
		}
		System.out.println("Goodbye!");
		System.exit(0);
	}
	
}
