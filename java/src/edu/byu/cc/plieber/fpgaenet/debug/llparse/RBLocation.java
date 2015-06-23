/*
@LICENSE@
*/

package edu.byu.cc.plieber.fpgaenet.debug.llparse;

/**
 * This class is used to keep track of the location of a symbol
 * (flip-flop or RAM) in the readback bitstream. This is mainly used
 * by {@link Virtex2ToJHDLSyms} and {@link RBSym} objects.
 *
 * @author Paul Graham  */
public class RBLocation {

  /** Holds the readback bitstream absolute offset. */
  public int offset;
  /** Holds the readback bitstream frame number. */
  public int frame;
  /** Holds the readback bitstream frame offset. */
  public int frameOffset;

  /** 
   * Constructs an object, setting the <code>frame</code> and
   * <code>frameOffset</code> to the illegal values of -1 */
  public RBLocation() {
    offset = -1;
    frame = -1;
    frameOffset = -1;
  }

  /** 
   * Constructs an object, copying the values of an existing
   * <code>RBLocation</code> object to the new object.
   * 
   * @param rbloc The RBLocation object to copy. */
  public RBLocation(RBLocation rbloc) {
    offset = rbloc.offset;
    frame = rbloc.frame;
    frameOffset = rbloc.frameOffset;
  }

  /** 
   * Constructs an object by directly setting the frame and frame
   * offset based on its parameters.
   *
   * @deprecated See {@link RBLocation#RBLocation(int,int,int)}
   *
   * @param newFrame An integer representing the frame number for a
   *                 bit in the readback bitstream.
   *
   * @param newFrameOffset An integer representing the frame offset
   *                       for a bit in the readback bitstream. */
  public RBLocation(int newFrame, int newFrameOffset) {
    offset = -1;
    frame = newFrame;
    frameOffset = newFrameOffset;
  }

  /** 
   * Constructs an object by directly setting the frame and frame
   * offset based on its parameters.
   * @param newFrame An integer representing the absolute offset for a
   *                 bit in the readback bitstream.
   *
   * @param newFrame An integer representing the frame number for a
   *                 bit in the readback bitstream.
   *
   * @param newFrameOffset An integer representing the frame offset
   *                       for a bit in the readback bitstream. */
  public RBLocation(int newOffset, int newFrame, int newFrameOffset) {
    offset = newOffset;
    frame = newFrame;
    frameOffset = newFrameOffset;
  }

  /** 
   * Sets the frame and frame offset based on its parameters.
   *
   * @deprecated See {@link RBLocation#setLocation(int,int,int)}
   *
   * @param newFrame An integer representing the frame number for a
   *                 bit in the readback bitstream.
   *
   * @param newFrameOffset An integer representing the frame offset
   *                       for a bit in the readback bitstream. */
  public void setLocation(int newFrame, int newFrameOffset) {
    offset = -1;
    frame = newFrame;
    frameOffset = newFrameOffset;
  }

  /** 
   * Sets the frame and frame offset based on its parameters.
   *
   * @param newOffset An integer representing the absolute offset for
   * 		      a bit in the readback bitstream.
   *
   * @param newFrame An integer representing the frame number for a
   *                 bit in the readback bitstream.
   *
   * @param newFrameOffset An integer representing the frame offset
   *                       for a bit in the readback bitstream. */
  public void setLocation(int newOffset, int newFrame, int newFrameOffset) {
    offset = newOffset;
    frame = newFrame;
    frameOffset = newFrameOffset;
  }

  /**
   * Returns a <code>String</code> describing the frame and frame
   * offset for a bit in the readback bitstream. 
   *
   * @return A <code>String</code> describing the frame and frame
   * offset for a bit in the readback bitstream. */
  public String toString() {
    return "Offset: "+offset+" Frame: "+frame+" FrameOffset: "+frameOffset;
  }
}
