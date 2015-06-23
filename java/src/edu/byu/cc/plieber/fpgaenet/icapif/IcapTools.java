/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.icapif;

import java.util.ArrayList;
import java.util.List;

import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.util.StringUtil;
import edu.byu.ece.bitstreamTools.bitstream.BitstreamException;
import edu.byu.ece.bitstreamTools.bitstream.DummySyncData;
import edu.byu.ece.bitstreamTools.bitstream.Packet;
import edu.byu.ece.bitstreamTools.bitstream.PacketList;
import edu.byu.ece.bitstreamTools.bitstream.PacketOpcode;
import edu.byu.ece.bitstreamTools.bitstream.PacketType;
import edu.byu.ece.bitstreamTools.bitstream.PacketUtils;
import edu.byu.ece.bitstreamTools.bitstream.RegisterType;
import edu.byu.ece.bitstreamTools.configuration.Frame;
import edu.byu.ece.bitstreamTools.configuration.FrameData;

/**
 * @author plieber
 *
 */
public class IcapTools {
	
	protected IcapInterface icapif;
	
	/**
	 * Creates a new IcapTools object attached to given IcapInterface instance.
	 * @param icapif IcapInterface instance to use
	 */
	public IcapTools(IcapInterface icapif) {
		this.icapif = icapif;
	}
	
	/**
	 * Writes a packet to the ICAP
	 * @param packet
	 * @throws FCPException 
	 */
	public void write(edu.byu.ece.bitstreamTools.bitstream.Packet packet) throws FCPException {
		this.icapif.sendIcapData(packet.toByteArray());
	}
	
	/**
	 * Writes a packet list to the ICAP
	 * @param packet
	 * @throws FCPException 
	 */
	public void write(edu.byu.ece.bitstreamTools.bitstream.PacketList packetList) throws FCPException {
		this.icapif.sendIcapData(packetList.toByteArray());
	}
	
	/**
	 * Writes dummy/synch data from a DummySyncData object.
	 * @param synchData
	 * @throws FCPException 
	 */
	public void write(edu.byu.ece.bitstreamTools.bitstream.DummySyncData synchData) throws FCPException {
		this.icapif.sendIcapData(synchData.getData());
	}
	
	public void write(edu.byu.ece.bitstreamTools.configuration.Frame frame) throws BitstreamException, FCPException {
		PacketList packets = new PacketList();
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		packets.add(PacketUtils.RCRC_CMD_PACKET);
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		packets.add(PacketUtils.COR_PACKET(0x100531E5));
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		packets.add(PacketUtils.IDCODE_PACKET(0x2AD6093));
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		packets.add(PacketUtils.FAR_WRITE_PACKET(frame.getFrameAddress()));
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		packets.add(PacketUtils.WCFG_CMD_PACKET);
		packets.addAll(PacketUtils.NOP_PACKETS(3));
		
		
		ArrayList<Integer> Data = new ArrayList<Integer>();
		Data.addAll(frame.getData().getAllFrameWords());
		Data.addAll(frame.getData().getAllFrameWords());
		packets.add(PacketUtils.TYPE_ONE_WRITE_PACKET(RegisterType.FDRI,  Data));
		
		//packets.addAll(PacketUtils.FDRI_WRITE_PACKETS(frame.getData().getAllFrameWords()));
		//packets.addAll(PacketUtils.FDRI_WRITE_PACKETS(frame.getData().getAllFrameWords()));
		packets.addAll(PacketUtils.NOP_PACKETS(3));
		this.write(packets);
	}
	
	public void write(edu.byu.ece.bitstreamTools.bitstream.RegisterType regtype, int value) throws BitstreamException, FCPException {
		PacketList packets = new PacketList();
		//packets.addAll(PacketUtils.NOP_PACKETS(1));
		//packets.add(PacketUtils.IDCODE_PACKET(0x2AD6093));
		//packets.addAll(PacketUtils.NOP_PACKETS(1));
		ArrayList<Integer> valuelist = new ArrayList<Integer>();
		valuelist.add(value);
		//ArrayList<Integer> valuelist2 = new ArrayList<Integer>();
		//valuelist2.add(0x7);
		packets.addAll(PacketUtils.NOP_PACKETS(1));
		packets.addAll(PacketUtils.NOP_PACKETS(1));
		packets.add(PacketUtils.TYPE_ONE_WRITE_PACKET(regtype, valuelist));
		//packets.addAll(PacketUtils.NOP_PACKETS(100));
		
		//packets.add(PacketUtils.COR_PACKET(0x100531E5));
		//packets.addAll(PacketUtils.NOP_PACKETS(1));
		//packets.addAll(PacketUtils.NOP_PACKETS(1));
		//ArrayList<Integer> valuelist = new ArrayList<Integer>();
		//valuelist.add(value);
		//packets.add(PacketUtils.TYPE_ONE_WRITE_PACKET(regtype, valuelist));
		//packets.addAll(PacketUtils.NOP_PACKETS(1));
		//packets.add(PacketUtils.RCRC_CMD_PACKET);
		//packets.addAll(PacketUtils.NOP_PACKETS(1));
		//packets.add(PacketUtils.TYPE_ONE_WRITE_PACKET(regtype, valuelist2));
		//packets.addAll(PacketUtils.NOP_PACKETS(20));
		this.write(packets);
	}
	
	public void synchIcap() throws FCPException {
		//write(DummySyncData.V5_V6_ICAP_DUMMY_SYNC_DATA);
		write(DummySyncData.V5_V6_STANDARD_DUMMY_SYNC_DATA);
	}
	
	public void deviceIdCheck(int deviceId) {
		
	}
	
	public void clearCRC(int deviceId) {
		
	}
	
	/**
	 * Reads a frame from the ICAP. This methods stores the frame data into the frame instance given as a paramter.
	 * @param frame The Frame in which to store the read frame data.
	 * @return A reference to the Frame where the data was stored.
	 * @throws FCPException 
	 */
	public edu.byu.ece.bitstreamTools.configuration.Frame readFrame(edu.byu.ece.bitstreamTools.configuration.Frame frame) throws FCPException {
		PacketList packets = new PacketList();
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		//packets.add(PacketUtils.GCAPTURE_CMD_PACKET);
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		packets.add(PacketUtils.NULL_CMD_PACKET);
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		packets.add(PacketUtils.FAR_WRITE_PACKET(frame.getFrameAddress()));
		packets.add(PacketUtils.RCFG_CMD_PACKET);
		packets.addAll(PacketUtils.NOP_PACKETS(3));
		packets.addAll(PacketUtils.FDRO_READ_PACKETS(1));
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		this.icapif.sendIcapData(packets.toByteArray());
		this.icapif.requestIcapData(332);
		ArrayList<Byte> bytes = this.icapif.receiveIcapData();
		frame.configure(new FrameData(bytes.subList(168, bytes.size())));
		return frame;
	}
	
	public int readRegister(RegisterType T) throws FCPException, BitstreamException{
		
		PacketList packets = new PacketList();
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		List<Integer> data = new ArrayList<Integer>();
		packets.add(new Packet(Packet.getHeader(PacketType.ONE, PacketOpcode.READ, T, 0) | 1, data));
		packets.addAll(PacketUtils.NOP_PACKETS(2));
		System.out.println(packets.toString());
		this.icapif.sendIcapData(packets.toByteArray());
		this.icapif.requestIcapData(4);
		ArrayList<Byte> bytes = this.icapif.receiveIcapData();
	    int value=0;	
		for(int i = 0; i < bytes.size(); i++){
			System.out.println(Integer.toHexString(bytes.get(i)));
			value = value | bytes.get(i) << ( i * 8);
		}
		return value;
	}
	/**
	 * Read a frame from the ICAP. A new Frame is created and returned.
	 * @param frameAddress The frame address to read
	 * @return
	 * @throws FCPException 
	 */
	public edu.byu.ece.bitstreamTools.configuration.Frame readFrame(int frameAddress) throws FCPException {
		Frame frame = new Frame(41, frameAddress);
		return this.readFrame(frame);
	}
}
