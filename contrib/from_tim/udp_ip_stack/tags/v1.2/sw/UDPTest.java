package com.pjf;

import java.io.IOException;
import java.net.SocketException;
import java.net.UnknownHostException;

public class UDPTest {
	private UDPCxn cxn;
	
	public UDPTest() throws SocketException, UnknownHostException {
		cxn = new UDPCxn("192.168.5.9");		
	}

	public void go() throws IOException {
		String fix1 = "1=45~34=201~18=23~";
		cxn.fixSend(fix1, 2000, true);
		byte[] rep = cxn.rcv();
		String reply = new String(rep);
		System.out.println("Got [" + reply + "]");
	}


	public static void main(String[] args) {
		UDPTest ut;
		try {
			ut = new UDPTest();
			ut.go();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}


}
