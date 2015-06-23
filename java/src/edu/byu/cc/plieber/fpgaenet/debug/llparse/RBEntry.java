/*
@LICENSE@
*/

package edu.byu.cc.plieber.fpgaenet.debug.llparse;
import java.lang.String;

/**
 * The base class for storing Virtex2 readback bitstream offset
 * information from the Xilinx Logical Allocation (<code>.ll</code>)
 * file.
 *
 * @author Paul Graham  */
public class RBEntry {

  /** The offset to a "junk" bit in the Virtex2 bitstream. */
  int offset;
  /** The readback bitstream frame for the state data bit. */
  int frame;
  /** The readback bitstream frame offset for the state data bit. */
  int frameOffset;
  /** 
   * The location of the block (IOB, slice, BlockRAM) containing the
   * state data. */
  String block;

  /**
   * Constructs an object based on the readback bitstream parameters
   * available from the <code>.ll</code> file.
   *
   * @param new_offset The "junk" offset provided by the
   *                   <code>.ll</code> file.
   *
   * @param new_frame The frame number of the state bit in the
   *                  readback bitstream.
   *
   * @param new_frameOffset The frame offset of the state bit in the
   *                        readback bitstream.
   *
   * @param new_block The physical location of the block containing
   *                  the state element (C21, CLB_R8C55.S1,
   *                  RAMB4_R4C1). */
  RBEntry(int new_offset, int new_frame, int new_frameOffset,
	  String new_block) {
    offset = new_offset;
    frame = new_frame;
    frameOffset = new_frameOffset;
    block = new_block;
  }

  /**
   * Returns the offset for the "junk" bit in the Virtex2 bitstream.
   *
   * @return The offset for the "junk" bit in the Virtex2 bitstream. */
  public int getOffset() {
    return offset;
  }

  /**
   * Returns the readback bitstream frame for the state data bit.
   *
   * @return The readback bitstream frame for the state data bit.  */
  public int getFrame() {
    return frame;
  }

  /** 
   * Returns the readback bitstream frame offset for the state data
   * bit. 
   *
   * @return The readback bitstream frame offset for the state data
   *         bit.  */
  public int getFrameOffset() {
    return frameOffset;
  }

  /** 
   * Returns the location of the block containing the state data. 
   *
   * @return The location of the block containing the state data. */
  String getBlock() {
    return block;
  }

}
    
