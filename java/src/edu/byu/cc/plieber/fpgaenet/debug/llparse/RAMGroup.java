/*
@LICENSE@
*/

package edu.byu.cc.plieber.fpgaenet.debug.llparse;
import java.lang.String;

/**
 * This class stores all of the readback bitstream offset information
 * for an entire LUT RAM or BlockRAM.  It contains such information as
 * the name of the physical block containing the RAM, the type of the
 * RAM, an array of {@link RBLocation} objects (one object per bit in
 * the RAM), and the name of the RAM's output.
 *
 * @author Paul Graham */
public class RAMGroup {

  /* The sizes of basic RAM elements */
  /** The number of bits in a LUT RAM */
  static final int LUTSIZE = 64;
  /** The number of bits in a BlockRAM */
  static final int BLOCKRAMSIZE = 36864;

  /** Holds the block location of the RAM */
  String block;
  /** Holds the type of the RAM as defined by {@link RAMTypes}. */
  RAMTypes RAMType;
  /** Holds the readback offsets of the various RAM bits. The index
   * into the array is the same as the address for the RAM's bit, in
   * other words, the readback bitstream offset information for
   * address 10 of the RAM is accessed using an index of 10. */
  RBLocation[] offsets ;
  /** 
   * Refers to the name of the RAM's output net. An artifact of the
   * old way readback was performed. */
  String netName;

  /** 
   * Creates the object with the block location and with an array of
   * readback offsets appropriate to the <code>RAMType</code>. The
   * <code>RAMType</code> is also set for the RAM.
   *
   * @param new_block A <code>String</code> representing the physical
   *                  location of the block (SLICE/BlockRAM)
   *                  containing the RAM.
   *
   * @param new_RAMType The type of the RAM being represented by this
   *                    object (see {@link RAMTypes} to discover the
   *                    appropriate values).
   **/
  RAMGroup(String new_block,RAMTypes new_RAMType) throws RAMTypeException{
    block = new_block;
    RAMType = new_RAMType;
    switch(RAMType) {
    case A:
    case B:
    case C:
    case D:
      offsets = new RBLocation[RAMGroup.LUTSIZE];
      break;
    case BRAM:
      offsets = new RBLocation[RAMGroup.BLOCKRAMSIZE];
      break;
    default:
      throw new RAMTypeException("Invalid RAM Type Value:"+RAMType);
    }
  }

  /** 
   * Creates the object with the block location and with an array of
   * readback offsets appropriate to the <code>RAMType</code> and
   * records the readback offset information for one bit of the RAM.
   * The <code>RAMType</code> is also set for the RAM.
   *
   * @param RE A <code>RAMRBEntry</code> object reflecting the FPGA
   *           block containing the RAM as well as the readback
   *           bitstream offset data.
   *  */
  RAMGroup(RAMRBEntry RE) throws RAMTypeException{
    block = RE.getBlock();
    RAMType = RE.RAMType;
    switch(RAMType) {
    case A:
    case B:
    case C:
    case D:
      offsets = new RBLocation[RAMGroup.LUTSIZE];
      break;
    case BRAM:
      offsets = new RBLocation[RAMGroup.BLOCKRAMSIZE];
      break;
    default:
      throw new RAMTypeException("Invalid RAM Type Value:"+RAMType);
    }
    offsets[RE.address]=new RBLocation(RE.getOffset(),RE.getFrame(),
				       RE.getFrameOffset()); 
  }

  /**
   * Sets the name of the RAM's data output signal (not necessary with
   * the current scheme).
   *
   * @param net_netName The name of the RAM's data output signal
   *  */
  void setNetName(String new_netName) {
    netName = new_netName;
  }

  /**
   * Retrieves the name of the RAM's data output signal.
   *
   * @return  The name of the RAM's data output signal.
   */
  String getNetName() {
    return netName;
  }

  /**
   * Adds a readback bitstream offset entry for a bit of the RAM.
   *
   * @param RE A <code>RAMRBEntry</code> object reflecting the
   *           readback bitstream offset data for a specific bi in the
   *           RAM.  */
  void addRAMEntry(RAMRBEntry RE) {
    offsets[RE.address] = new RBLocation(RE.getOffset(),RE.getFrame(),
					 RE.getFrameOffset());
  }

  /**
   * Returns the type of the RAM (see {@link RAMTypes}).
   *
   * @return The encoded type of the RAM as defined in
   *         <code>RAMTypes</code>.  */
  RAMTypes getRAMType() {
    return RAMType;
  }

  /**
   * Returns the block location string for the block containing the
   * RAM.
   *
   * @return The block location string for the block containing the
   *         RAM.  */
  String getBlock() {
    return block;
  }


  /**
   * Returns an array of <code>RBLocation</code> objects representing
   * the readback bitstream offsets for bits in the RAM.  The index
   * into the array is the same as the address for the RAM's bit, in
   * other words, the readback bitstream offset information for
   * address 10 of the RAM is accessed using an index of 10. */
  RBLocation[] getOffsets() {
    return offsets;
  }

  /**
   * Returns a <code>String</code> with all of the readback bitstream
   * offset information.
   *
   * @return A <code>String</code> with readback bitstream offset
   *         information.
   *  */
  public String toString() {
    StringBuffer retval;

    retval = new StringBuffer();
    for(int i=0;i<offsets.length;i++) {
      retval.append("  " +offsets[i]+" " +netName+"."+
    		  RAMType.toString()+"."+i+"\n");
    }
    return retval.toString();
  }

  /**
   * Returns a <code>String</code> with all of the readback bitstream
   * offset information after a header describing the RAMGroup (output
   * net name and RAM size in bits).
   *
   * @return A <code>String</code> with readback bitstream offset
   *         information.
   *  */
  public String toGroupString() {
    StringBuffer retval;

    retval = new StringBuffer();
    retval.append("RAMGroup: "+netName+" "+offsets.length+"\n");
    for(int i=0;i<offsets.length;i++) {
      retval.append("  " +netName+"."+
    		  RAMType.toString()+"."+i+" "+i+"\n");
    }
    return retval.toString();
  }
}
    
