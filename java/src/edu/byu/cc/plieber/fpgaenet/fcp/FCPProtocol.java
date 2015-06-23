/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.fcp;

import java.io.*;
import java.net.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.LinkedBlockingQueue;

import javax.swing.text.html.MinimalHTMLWriter;

/**
 * The main class to instantiate for communication of an FCP/UDP/IP connection. 
 * Provides methods to send data, request data, and received data. All data is 
 * sent and received as byte arrays.
 * 
 * @author Peter Lieber
 * 
 */
public class FCPProtocol {
	
	/**
	 * Creates new FCPProtocol object with default ports: 3001(remote), 3000(local)
	 * 
	 * @throws IOException
	 */
	public FCPProtocol() throws IOException {
		this.init(0x3000, 0x3001);
	}
	
	/**
	 * Creates new FCPProtocol object with default local port, 3000
	 * @param port Local UDP Port
	 * @throws IOException
	 */
	public FCPProtocol(int port) throws IOException {
		this.init(port, 0x3001);
	}
	
	/**
	 * Creates new FCPProtocol object
	 * @param port Local UDP Port
	 * @param destport Remote UDP Port
	 * @throws IOException
	 */
	public FCPProtocol(int port, int destport) throws IOException {
		this.init(port, destport);
	}
	
	/**
	 * Initializes protocol parameters and threads
	 * @param port
	 * @param destport
	 * @throws IOException
	 */
	private void init(int port, int destport) throws IOException {
		rec_cur = 1;
		rec_last_rcv = 0;
		snd_cur = 0;
		snd_last_ack = 0;
		timeout = 1000;
		socket = new DatagramSocket(port);
		socket.setSoTimeout(50);
		connectedPort = destport;
		connected = false;
		this.receivedQueue = new LinkedBlockingQueue<FCPPacket>();
		this.packetOutbox = new ConcurrentHashMap<Integer, FCPPacket>();
		recThread = new FCPReceiveThread(this);
		recThread.start();
		sendThread = new FCPSendThread(this);
		sendThread.start();
	}
	
	protected int recWindow = 1;
	protected int sendWindow = 20;
	
	protected volatile int rec_cur;
	protected volatile int rec_last_rcv;
	protected volatile int snd_cur;
	protected volatile int snd_last_ack;
	
	protected DatagramSocket socket;
	private FCPReceiveThread recThread;
	private FCPSendThread sendThread;
	protected boolean connected;
	protected InetAddress connectedAddress;
	protected int connectedPort;
	
	LinkedBlockingQueue<FCPPacket> receivedQueue;
	ConcurrentHashMap<Integer, FCPPacket> packetOutbox;
	protected long timeout = 500;
	
	public boolean packetsPending() {
		return !packetOutbox.isEmpty() || !sendThread.sendQueue.isEmpty();
	}
	
	/**
	 * Sends acknowledgement packet (internal)
	 * @param address
	 * @param seq
	 */
	protected void sendAck(InetAddress address, int seq) {
		// TODO Auto-generated method stub
		FCPPacket fp = new FCPPacket();
		fp.version = 0;
		fp.command = 1;
		fp.port = 0;
		fp.seq = seq;
		fp.len = 0;
		fp.dest = connectedAddress;
		fp.dstPort = connectedPort;
		try {
			sendThread.sendQueue.put(fp);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * Sends connection acknowledgement packet (internal)
	 */
	public void sendConAck() {
		FCPPacket fp = new FCPPacket();
		fp.version = 0;
		fp.command = 3;
		fp.port = 0;
		fp.seq = 0;
		fp.len = 0;
		fp.dest = connectedAddress;
		fp.dstPort = connectedPort;
		try {
			sendThread.sendQueue.put(fp);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * Sends a request for some number of bytes.
	 * @param port FCP port number
	 * @param numBytes Number of bytes expected
	 * @return
	 * @throws FCPException 
	 */
	public boolean sendDataRequest(int port, int numBytes) throws FCPException {
		if (!this.connected) throw new FCPException("Not connected to FPGA!");
		FCPPacket fp = new FCPPacket();
		fp.version = 0;
		fp.command = 4;
		fp.port = port;
		fp.len = numBytes;
		fp.dest = connectedAddress;
		fp.dstPort = connectedPort;
		try {
			sendThread.sendQueue.put(fp);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return true;
	}
	
	/**
	 * Sends data through the specified FCP port. The data must be less than 1024 bytes long.
	 * @param port FCP port number
	 * @param data data to be sent
	 * @param count number of bytes to send
	 * @return
	 * @throws IOException 
	 * @throws FCPException 
	 */
	public boolean send(int port, byte[] data, int count) throws FCPException {
		if (!this.connected) throw new FCPException("Not connected to FPGA!");
		FCPPacket fp = new FCPPacket();
		fp.version = 0;
		fp.command = 0;
		fp.port = port;
		fp.len = count;
		fp.dest = connectedAddress;
		fp.dstPort = connectedPort;
		fp.data = data.clone();
		try {
			sendThread.sendQueue.put(fp);
		} catch (InterruptedException e) {
			throw new FCPException("Interrupted Send Operation");
		}
		checkHealth();
		return true;
	}
	
	/**
	 * Sends data through the specified FCP port.  The data can be any length (within reason).
	 * @param port
	 * @param bytes
	 * @param numBytes
	 * @return
	 * @throws FCPException 
	 */
	public boolean sendData(int port, List<Byte> bytes, int numBytes) throws FCPException {
		int offset = 0;
		int numRead = 0;
		while (offset < numBytes) {
			numRead = Math.min(offset+1024, numBytes) - offset;
			this.send(port, bytes.subList(offset, offset+numRead), numRead);
			offset += 1024;
		}
		return true;
	}

	public void sendData(int port, ArrayList<Byte> bytes) throws FCPException {
		this.sendData(port, bytes, bytes.size());
	}

	public void sendData(int port, byte value) throws FCPException {
		this.send(port, value);
	}

	/**
	 * Sends data through the specified FCP port. The data must be less than 1024 bytes long.
	 * @param port FCP port number
	 * @param bytes data to be sent
	 * @param count number of bytes to send
	 * @return
	 * @throws FCPException 
	 */
	public boolean send(int port, List<Byte> bytes, int count) throws FCPException {
		
		if (!this.connected) throw new FCPException("Not connected to FPGA!");
		FCPPacket fp = new FCPPacket();
		fp.version = 0;
		fp.command = 0;
		fp.port = port;
		fp.len = count;
		fp.dest = connectedAddress;
		fp.dstPort = connectedPort;
		fp.data = new byte[bytes.size()];
		for (int i=0; i<fp.data.length; i++) {
			fp.data[i] = bytes.get(i);
		}
		try {
			sendThread.sendQueue.put(fp);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return true;
	}

	private boolean send(int port, byte value) throws FCPException {
		if (!this.connected) throw new FCPException("Not connected to FPGA!");
		FCPPacket fp = new FCPPacket();
		fp.version = 0;
		fp.command = 0;
		fp.port = port;
		fp.len = 1;
		fp.dest = connectedAddress;
		fp.dstPort = connectedPort;
		fp.data = new byte[1];
		fp.data[0] = value;
		try {
			sendThread.sendQueue.put(fp);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return true;
	}

	private void checkHealth() throws FCPException {
		if (!this.sendThread.isAlive()) {
			if (this.sendThread.sendTimeout) throw new FCPException("Send Error: timeout");
			else if (this.sendThread.ioException) throw new FCPException("I/O Error");
		}
	}

	void processPacket(FCPPacket fcppacket) {
		if (fcppacket.command == 5) {
			try {
				this.receivedQueue.put(fcppacket);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * Connects to an FPGA at the given address
	 * @param address Address (usually derived from IP address)
	 * @param port Remote UDP port (0x3001)
	 */
	public void connect(InetAddress address, int port) {
		FCPPacket fp = new FCPPacket();
		fp.version = 0;
		fp.command = 2;
		fp.port = 0;
		fp.seq = 0;
		fp.len = 0;
		fp.dest = address;
		fp.dstPort = port;
		this.connected = false;
		try {
			sendThread.sendQueue.put(fp);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	public void connect(InetAddress address) {
		FCPPacket fp = new FCPPacket();
		fp.version = 0;
		fp.command = 2;
		fp.port = 0;
		fp.seq = 0;
		fp.len = 0;
		fp.dest = address;
		fp.dstPort = 0x3001;
		try {
			sendThread.sendQueue.put(fp);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * Disconnect from FPGA.  This method does not send anything to the FPGA, 
	 * but only ends the send and receiving threads of execution and closes 
	 * the UDP socket.
	 */
	public void disconnect() {
		recThread.done = true;
		sendThread.done = true;
		try {
			synchronized (recThread) {
				recThread.join();
			}
			synchronized (sendThread) {
				sendThread.join();
			}
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		socket.close();
	}

	void resetSW() {
		rec_cur = 1;
		rec_last_rcv = 0;
		snd_cur = 0;
		snd_last_ack = 0;	
	}

	/**
	 * Gets the response data that has been received due to a data request. 
	 * Blocks until data is available. 
	 * 
	 * @return
	 * @throws InterruptedException 
	 */
	public byte[] getDataResponse() {
		FCPPacket packet;
		try {
			packet = this.receivedQueue.take();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			packet = null;
		}
		if (packet != null)
			return packet.data;
		else return null;
	}
	
	@Override
	public String toString() {
		return "FCP Protocol< FPGA: " + this.connectedAddress.toString() + " >";
	}

	void send(FCPPacket fcpPacket) {
		try {
			this.socket.send(fcpPacket.wrapInDatagram());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public boolean isConnected() {
		return this.connected;
	}

	public void setSendWindow(int i) {
		this.sendWindow = i;		
	}

	public int getSourceUDPPort() {
		return this.socket.getLocalPort();
	}
	
	public int getDestUDPPort() {
		return this.connectedPort;
	}
	
	public InetAddress getDestIPAddress() {
		return this.connectedAddress;
	}
	
	public long getWhileCount() {
		return this.sendThread.whileCount;
	}

	public void resetWhileCount() {
		this.sendThread.whileCount = 0;
	}
}
