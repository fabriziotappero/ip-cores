package com.pjf;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;


public class UDPCxn {
    	private DatagramSocket skt;
    	private InetAddress dstIP;

    	public UDPCxn(long dstIPadr) throws SocketException, UnknownHostException {
    		skt = new DatagramSocket();
			byte[] target = new byte[4];
			target[0] = (byte) ((dstIPadr >> 24) & 0xff);
			target[1] = (byte) ((dstIPadr >> 16) & 0xff);
			target[2] = (byte) ((dstIPadr >> 8) & 0xff);
			target[3] = (byte) (dstIPadr & 0xff);
			dstIP = InetAddress.getByAddress(target);    		
    	}

    	public UDPCxn(String dstIPadr) throws SocketException, UnknownHostException {
    		skt = new DatagramSocket();
    		String[] parts = dstIPadr.split("[.]");
    		if (parts.length != 4) {
    			throw new UnknownHostException("ip addr must have 4 parts");
    		}
			byte[] target = new byte[4];
			for (int i = 0; i<4; i++) {
				target[i] = (byte) Integer.parseInt(parts[i]);
			}
			dstIP = InetAddress.getByAddress(target);    		
    	}

    	public void send(byte[] data, int port) throws IOException {
    		DatagramPacket pkt = new DatagramPacket(data, data.length, dstIP, port);
    		System.out.println("Sending packet");
    		skt.send(pkt);   		
    	}
    	
    	public void fixSend(String str, int port, boolean print) throws IOException {
    		String s1 = str.replace('~','\001');
    		byte[] data = s1.getBytes();
    		DatagramPacket pkt = new DatagramPacket(data, data.length, dstIP, port);
    		if (print) {
    			System.out.println("Sending packet: " + str + " on port " + port);
    		}
    		skt.send(pkt);   		
    	}

    	
    	public byte[] rcv() throws IOException {
  	      	byte[] buf = new byte[1024];
	  	    DatagramPacket pkt = new DatagramPacket(buf, buf.length);
//		    System.out.println("waiting to receive ...");
		    skt.receive(pkt);
		    int len = pkt.getLength();
		    byte[] rd = pkt.getData();
  	      	byte[] data = new byte[len];
		    for (int i=0; i<len; i++) {
		    	data[i] = rd[i];
		    }
		    return data;
    	}
    	
    	public void close() {
		    skt.close();    		
    	}
	}
