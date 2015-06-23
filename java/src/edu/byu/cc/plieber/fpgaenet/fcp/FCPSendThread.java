/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.fcp;

import java.io.IOException;
import java.net.DatagramPacket;
import java.util.LinkedList;
import java.util.concurrent.LinkedBlockingQueue;

;

/**
 * @author Peter Lieber
 * 
 */
class FCPSendThread extends Thread {
	private FCPProtocol protocol;
	protected LinkedBlockingQueue<FCPPacket> sendQueue;
	volatile protected boolean done = false;
	volatile protected boolean sendTimeout = false;
	volatile protected boolean ioException = false;
	protected long whileCount = 0;

	public FCPSendThread(FCPProtocol protocol) {
		this.protocol = protocol;
		this.sendQueue = new LinkedBlockingQueue<FCPPacket>();
	}

	@Override
	public void run() {
		while (true) {
			try {
				if (done == true)
					return;
				while (sendQueue.isEmpty()) {
					if (done == true)
						return;
				}
				FCPPacket fcppacket = sendQueue.take();
				if (fcppacket.command == 0 || fcppacket.command == 4) {
					fcppacket.seq = ++protocol.snd_cur;
					if (fcppacket.seq > 65000) {
						this.reconnect();
						fcppacket.seq = ++protocol.snd_cur;
					}
				}
				else
					fcppacket.seq = 0;
				
				//System.out.println("Sending Packet: " + fcppacket.toString());
				DatagramPacket packet = fcppacket.wrapInDatagram(fcppacket.dest, fcppacket.dstPort);

				// parse
				if ( true ) {//protocol.sendWindow <= 20) {
					if ((fcppacket.command == 0 || fcppacket.command == 4 || fcppacket.command == 2)
							&& fcppacket.seq > protocol.snd_last_ack + protocol.sendWindow) {
						int numResendsLeft = 5;
						long timeouttime = System.currentTimeMillis() + protocol.timeout;
						long newWhileCnt = whileCount + 1;
						while ((fcppacket.command == 0 || fcppacket.command == 4)
								&& fcppacket.seq > protocol.snd_last_ack + protocol.sendWindow) {
							whileCount = newWhileCnt;
							//System.out.println("Waiting");
							if (System.currentTimeMillis() > timeouttime) {
								if (numResendsLeft <= 0)
									throw new FCPException("Communication Error: Resend Limit Reached");
								numResendsLeft--;
								protocol.socket.send(protocol.packetOutbox.get(protocol.snd_last_ack + 1).wrapInDatagram());
								System.out.println("Resent: " + (protocol.snd_last_ack + 1));
								timeouttime = System.currentTimeMillis() + protocol.timeout;
							}
							if (done == true)
								return;
						}
					}
				} 

				if (fcppacket.command == 0 || fcppacket.command == 4)
					protocol.packetOutbox.put(fcppacket.seq, fcppacket);
				protocol.socket.send(packet);
			} catch (IOException e) {
				this.ioException = true;
				return;
			} catch (FCPException e) {
				this.sendTimeout = true;
				return;
			} catch (InterruptedException e) {

			}
		}
	}

	private void reconnect() {
		FCPPacket fp = new FCPPacket();
		fp.version = 0;
		fp.command = 2;
		fp.port = 0;
		fp.seq = 0;
		fp.len = 0;
		fp.dest = protocol.connectedAddress;
		fp.dstPort = protocol.connectedPort;
		try {
			protocol.connected = false;
			protocol.packetOutbox.clear();
			protocol.socket.send(fp.wrapInDatagram());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		while (!protocol.connected);
	}
}
