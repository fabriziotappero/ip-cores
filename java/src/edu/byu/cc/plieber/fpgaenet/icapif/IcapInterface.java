/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.icapif;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;
import java.util.ArrayList;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPProtocol;

/**
 * @author plieber
 * 
 * @version 0.1
 */
public class IcapInterface {

	protected FCPProtocol fcpprotocol;

	protected int icapWritePort = 3;
	protected int icapReadPort = 4;

	/**
	 * Create IcapInterface, attached to the given FCP layer, with the default
	 * FCP ports for the ICAP functions.
	 * 
	 * @param fcpprotocol
	 */
	public IcapInterface(FCPProtocol fcpprotocol) {
		this.init(fcpprotocol, 3, 4);
	}

	/**
	 * Create IcapInterface, attached to the given FCP layer, with the given
	 * FCP ports for the ICAP functions.
	 * 
	 * @param fcpprotocol
	 * @param icapWritePort
	 * @param icapReadPort
	 */
	public IcapInterface(FCPProtocol fcpprotocol, int icapWritePort,
			int icapReadPort) {
		this.init(fcpprotocol, icapWritePort, icapReadPort);
	}

	/**
	 * Initialize this object
	 * @param fcpprotocol
	 * @param icapWritePort
	 * @param icapReadPort
	 */
	private void init(FCPProtocol fcpprotocol, int icapWritePort,
			int icapReadPort) {
		this.fcpprotocol = fcpprotocol;
		this.icapReadPort = icapReadPort;
		this.icapWritePort = icapWritePort;
	}

	@Override
	public String toString() {
		return "ICAP Interface< " + this.fcpprotocol.toString() + " >";
	}

	/**
	 * Send a list of bytes to the ICAP.
	 * @param bytes
	 * @throws FCPException 
	 */
	public void sendIcapData(java.util.List<Byte> bytes) throws FCPException {
		this.fcpprotocol.send(this.icapWritePort, bytes, bytes.size());
	}

	/**
	 * Send an array of byte to the ICAP.
	 * @param bytes
	 * @throws FCPException 
	 */
	public void sendIcapData(byte[] bytes, int numBytes) throws FCPException {
		byte[] writereg = new byte[1024];
		int offset = 0;
		int numRead = 0;
		while (offset < numBytes) {
			for (int i = 0; i < 1024 && offset < numBytes; i++, offset++) {
				writereg[i] = bytes[offset];
				numRead++;
			}
			this.fcpprotocol.send(3, writereg, numRead);
		}
	}
	
	public void sendIcapFile(String fileName) throws FCPException {
		try {
			File file = new File(fileName);
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
				fcpprotocol.send(3, writereg, numRead);
			}
		} catch (FileNotFoundException e) {
			throw new FCPException("File not found: " + fileName);
		} catch (IOException e) {
			throw new FCPException("Error reading file: " + fileName);
		}
	}

	/**
	 * Send a data request for ICAP data from the ICAP controller. 
	 * @param numBytes The number of bytes expected at the next receiveIcapData function call.
	 * @throws FCPException 
	 */
	public void requestIcapData(int numBytes) throws FCPException {
		byte[] read4 = new byte[] { (byte) ((numBytes >> 8) & 0xff), (byte) (numBytes & 0xff) };
		this.fcpprotocol.send(this.icapReadPort, read4, read4.length);
		this.fcpprotocol.sendDataRequest(this.icapReadPort, numBytes);
	}

	/**
	 * Receive a list of bytes from the ICAP. 
	 * @return List of bytes returned from the ICAP.
	 */
	public ArrayList<Byte> receiveIcapData() {
		ArrayList<Byte> ret = new ArrayList<Byte>();
		byte[] bytes = this.fcpprotocol.getDataResponse();
		for (int i = 0; i < bytes.length; i++) {
			ret.add(bytes[i]);
		}
		return ret;
	}

	/**
	 * Read a certain number of bytes from the ICAP. This function encapsulates calls to both requestIcapData and receiveIcapData.
	 * @param numBytes The number of bytes expected
	 * @return List of bytes returned from the ICAP
	 * @throws FCPException 
	 */
	public ArrayList<Byte> read(int numBytes) throws FCPException {
		this.requestIcapData(numBytes);
		return this.receiveIcapData();
	}
}
