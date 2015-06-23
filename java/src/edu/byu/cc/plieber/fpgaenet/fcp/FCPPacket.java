/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.fcp;

import java.net.DatagramPacket;
import java.net.InetAddress;

/**
 * @author plieber
 * 
 */
public class FCPPacket {
	public InetAddress source;
	public InetAddress dest;
	public int srcPort;
	public int dstPort;
	public int version;
	public int command;
	public int port;
	public int seq;
	public int len;
	public byte[] data;

	/**
	 * Constructs an FCP packet from the data of a UDP datagram packet.
	 * @param packet The UDP datagram packet containing exactly one FCP packet.
	 */
	public FCPPacket(DatagramPacket packet) {
		source = packet.getAddress();
		srcPort = packet.getPort();
		version = (packet.getData()[0] & 0xf0) >> 4;
		command = packet.getData()[0] & 0x0f;
		port = packet.getData()[1] & 0xff;
		seq = ((packet.getData()[2] << 8) & 0xff00) + (packet.getData()[3] & 0xff);
		len = ((packet.getData()[4] << 8) & 0xff00) + (packet.getData()[5] & 0xff);
		data = new byte[len];
		for (int i = 0; i < len; i++) {
			data[i] = packet.getData()[6 + i];
		}
	}

	public FCPPacket() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public String toString() {
		String ret = "FCP IcapPacket { version=" + version + ", command=" + command
				+ ", port=" + port + ", seq=" + seq + ", len=" + len;
		if (this.len > 0 && data != null) {
			ret += " <data: ";
			for (int i=0; i<(len-1); i++) {
				ret += String.format("%H", data[i] & 0xff) + ",";
			}
			ret += String.format("%H", data[len-1] & 0xff) + ">";
		}
		return ret + " }";
	}

	/**
	 * Wraps this FCP packet into a datagram packet for sending over a UDP socket.
	 * @param dest Destination internet address
	 * @param port remote port number
	 * @return
	 */
	public DatagramPacket wrapInDatagram(InetAddress dest, int port) {
		byte[] buf = new byte[6 + (this.command != 4 ? len: 0)];

		buf[0] = (byte) (((version << 4) & 0xf0) | (command & 0x0f));
		buf[1] = (byte) this.port;
		buf[2] = (byte) ((seq >> 8) & 0xff);
		buf[3] = (byte) (seq & 0xff);
		buf[4] = (byte) ((len >> 8) & 0xff);
		buf[5] = (byte) (len & 0xff);
		if (this.command != 4) {
			for (int i = 0; i < len; i++) {
				buf[6 + i] = data[i];
			}
		}

		DatagramPacket packet = new DatagramPacket(buf, buf.length);
		packet.setPort(port);
		packet.setAddress(dest);
		return packet;
	}

	/**
	 * Wraps this FCP packet into a datagram packet for sending over a UDP socket.
	 * @return
	 */
	public DatagramPacket wrapInDatagram() {
		byte[] buf = new byte[6 + (this.command != 4 ? len: 0)];

		buf[0] = (byte) (((version << 4) & 0xf0) | (command & 0x0f));
		buf[1] = (byte) this.port;
		buf[2] = (byte) ((seq >> 8) & 0xff);
		buf[3] = (byte) (seq & 0xff);
		buf[4] = (byte) ((len >> 8) & 0xff);
		buf[5] = (byte) (len & 0xff);
		if (this.command != 4) {
			for (int i = 0; i < len; i++) {
				buf[6 + i] = data[i];
			}
		}

		DatagramPacket packet = new DatagramPacket(buf, buf.length);
		packet.setPort(this.dstPort);
		packet.setAddress(this.dest);
		return packet;
	}
}
