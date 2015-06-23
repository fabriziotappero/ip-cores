/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.fcp;

import java.io.IOException;
import java.net.*;

/**
 * @author plieber
 * 
 */
class FCPReceiveThread extends Thread {
	private FCPProtocol protocol;
	protected boolean done;

	public FCPReceiveThread(FCPProtocol protocol) {
		this.protocol = protocol;
	}

	@Override
	public void run() {
		while (true) {
			try {
				if (done == true)
					return;
				byte[] buf = new byte[1280];

				// receive next packet
				DatagramPacket packet = new DatagramPacket(buf, buf.length);
				while (true) {
					try {
						protocol.socket.receive(packet);
						//System.out.println("DatagramPacket: " + packet.toString());
						break;
					} catch (SocketTimeoutException e) {
						if (done == true)
							return;
						else
							continue;
					}
				}
				//System.out.println("Got one!");
				FCPPacket fcppacket = new FCPPacket(packet);
				//System.out.println(fcppacket.toString());
				//System.out.flush();

				if (protocol.connected) {
					// parse
					if (protocol.recWindow == 1) {
						if (fcppacket.command == 0
								&& fcppacket.seq == protocol.rec_cur) {
							protocol
									.sendAck(packet.getAddress(), fcppacket.seq);
							protocol.rec_cur++;
							protocol.processPacket(fcppacket);
						} else if (fcppacket.command == 5) {
							protocol.snd_last_ack = fcppacket.seq;
							protocol.packetOutbox.remove(fcppacket.seq);
							protocol.processPacket(fcppacket);
						} else if (fcppacket.command == 1) {
							protocol.snd_last_ack = fcppacket.seq;
							protocol.packetOutbox.remove(fcppacket.seq);
						} else if (fcppacket.command == 3) {
							protocol.resetSW();
							protocol.connectedAddress = InetAddress
									.getByName(packet.getAddress().getHostAddress());
							protocol.connectedPort = packet.getPort();
							protocol.connected = true;
							System.out.println("Reset Connection");
						}
					} else
						throw new IOException(
								"Receive window greater than 1 not supported");
				} else {
					if (fcppacket.command == 2) {
						protocol.resetSW();
						protocol.connectedAddress = packet.getAddress();
						protocol.connectedPort = packet.getPort();
						protocol.connected = true;
						// This is where we would set the ConARP table
						System.out.println("Received Connection Req");
						System.out.println("Connected to: "
								+ protocol.connectedAddress.getHostAddress()
								+ " on port " + protocol.connectedPort);
						protocol.sendConAck();
					} else if (fcppacket.command == 3 || fcppacket.command == 1) {
						protocol.resetSW();
						protocol.connectedAddress = InetAddress
								.getByName(packet.getAddress().getHostAddress());
						protocol.connectedPort = packet.getPort();
						protocol.connected = true;
						System.out.println("Received Connection Ack");
						System.out.println("Connected to: "
								+ protocol.connectedAddress.getHostAddress()
								+ " on port " + protocol.connectedPort);
					}
				}
			} catch (IOException e) {
				e.printStackTrace();
				return;
			}
		}
	}
}
