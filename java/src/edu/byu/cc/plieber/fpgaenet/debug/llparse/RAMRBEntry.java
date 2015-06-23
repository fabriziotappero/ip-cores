/*
@LICENSE@
*/

package edu.byu.cc.plieber.fpgaenet.debug.llparse;
import java.lang.String;

/**
 * A class recording readback information for a single RAM bit.  The
 * class records the type of the RAM and the RAM bit's address in
 * addition to the offset, frame, frame offset, and block location
 * information recorded by the {@link RBEntry} object. 
 *
 * @author Paul Graham
 */
public class RAMRBEntry extends RBEntry{

  /** Holds the RAMType for this object (see {@link RAMTypes}). */
  RAMTypes RAMType;
  /** Holds the address of the RAM bit. */
  int address;

  /**
   * Constructs a new object based on readback bitstream information
   * from the <code>.ll</code> file.
   *
   * @param new_offset The "junk" bit offset provided by the Virtex2
   *                   <code>.ll</code> file.
   *
   * @param new_frame The frame number of the RAM bit's state
   *                  information in the readback bitstream.
   *
   * @param new_frameOffset The frame offset of the RAM bit's state
   *                        information in the readback bitstream.
   *
   * @param new_block The name of the block holding the RAM.
   *
   * @param new_RAMType A <code>String</code> representing the type of
   *                    the RAM.  This can have one of the following
   *                    values: "F", "G", "M", or "B".
   *
   * @param new_address The bit's address in the RAM.
   * */
  RAMRBEntry(int new_offset, int new_frame, int new_frameOffset,
	  String new_block,String new_RAMType,int new_address) throws RAMTypeException {
    super(new_offset,new_frame,new_frameOffset,new_block);
    if (new_block.startsWith("SLICE"))
    {
    if(new_RAMType.equals("A"))
      RAMType = RAMTypes.A;
    else if(new_RAMType.equals("B"))
      RAMType = RAMTypes.B;
    else if(new_RAMType.equals("C"))
      RAMType = RAMTypes.C;
    else if(new_RAMType.equals("D"))
      RAMType = RAMTypes.D;
    else
      throw new RAMTypeException("Unknown RAM Type");
    }
    else
    {
    	if (!new_RAMType.equals("B")) {
    		throw new RAMTypeException("Unknown RAM Type");
    	}
    	RAMType = RAMTypes.BRAM;
    }
    address = new_address;
  }

  /**
   * Returns the RAM's type based on the encoding in {@link RAMTypes}.
   *
   * @return The RAM's type based on the encoding in {@link RAMTypes}.  */
  RAMTypes getRAMType() {
    return RAMType;
  }

  /**
   * Returns the RAM bit's address within the RAM.
   *
   * @return The RAM bit's address within the RAM.  */
  int getAddress() {
    return address;
  }

}
    
