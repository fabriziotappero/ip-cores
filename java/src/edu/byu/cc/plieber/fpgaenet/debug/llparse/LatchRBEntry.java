/*
@LICENSE@
*/

package edu.byu.cc.plieber.fpgaenet.debug.llparse;
import java.lang.String;

/**
 * This class is used to record flip-flop readback bitstream location
 * information provided by <code>.ll</code> files for Virtex2 FPGAs.
 *
 * @author Paul Graham
 */
public class LatchRBEntry extends RBEntry{

  /* Here are the various locations of latches: input, output, 
     and internal */
  /** Represents a latch which is in an input port of the chip */
  static final int INPORT = 1;
  /** Represents a latch which is in an output port of the chip */
  static final int OUTPORT = 2;
  /** Represents a latch which is internal to the chip */
  static final int INTERNAL = 3;

  /** Holds the latch type for this object */
  String type;
  /** Holds the name of the net associated with this latch */
  String name;
  /** Holds the location of the latch: input port, an output port, 
   *  or internal.
   */
  int loc;
  /** Holds the index of the net in a signal vector */
  int index;

  /**
   * Constructor used to record readback bitstream information for a
   * flip-flop which is associated with an atomic net (not part of a
   * bus). 
   *
   * @param new_offset The "junk" offset provided by the
   *                   <code>.ll</code> file.
   *
   * @param new_frame The frame number for the readback bitstream data
   *                  for the flip-flop provided by the
   *                  <code>.ll</code> file.
   *
   * @param new_frameOffset The frame offset for the readback
   *                        bitstream data for the flip-flop provided
   *                        by the <code>.ll</code> file.
   *
   * @param new_block The physical location of the block containing
   *                  the state element (C21, CLB_R8C55.S1,
   *                  RAMB4_R4C1) provided by the <code>.ll</code>
   *                  file.
   *
   * @param new_type The type of the flip-flop (XQ,YQ,IQ, etc.)
   *                 provided by the <code>.ll</code> file.
   *
   * @param new_name The name of the signal attached to the output of
   *                 the flip-flop, provided by the <code>.ll</code>
   *                 file.
   * */
  LatchRBEntry(int new_offset, int new_frame, int new_frameOffset,
	  String new_block,String new_type,String new_name) {
    super(new_offset,new_frame,new_frameOffset,new_block);
    if(new_type.indexOf("I")!= -1)
      loc = LatchRBEntry.INPORT;
    else if(new_type.indexOf("O")!= -1)
      loc = LatchRBEntry.OUTPORT;
    else 
      loc = LatchRBEntry.INTERNAL;
    type = new_type;
    name = new_name;
    index = -1;
  }

  /**
   * Constructor used to record readback bitstream information for a
   * flip-flop which is associated with either an atomic wire or a
   * bus.
   *
   * @param new_offset The "junk" offset provided by the
   *                   <code>.ll</code> file.
   *
   * @param new_frame The frame number for the readback bitstream data
   *                  for the flip-flop provided by the
   *                  <code>.ll</code> file.
   *
   * @param new_frameOffset The frame offset for the readback
   *                        bitstream data for the flip-flop provided
   *                        by the <code>.ll</code> file.
   *
   * @param new_block The physical location of the block containing
   *                  the state element (C21, CLB_R8C55.S1,
   *                  RAMB4_R4C1) provided by the <code>.ll</code>
   *                  file.
   *
   * @param new_type The type of the flip-flop (XQ,YQ,IQ, etc.)
   *                 provided by the <code>.ll</code> file.
   *
   * @param new_name The name of the signal or bus attached to the
   *                 output of the flip-flop, provided by the
   *                 <code>.ll</code> file. This <em>does not</em>
   *                 include the wire's index within the bus.
   *
   * @param new_index The bus index of the signal attached to the
   *                  flip-flop's output.  For single-bit (atomic)
   *                  wires, the index should be "-1".*/
  LatchRBEntry(int new_offset, int new_frame, int new_frameOffset,
	  String new_block,String new_type,String new_name,int new_index) {
    super(new_offset,new_frame,new_frameOffset,new_block);
    if(new_type.indexOf("I")!= -1)
      loc = LatchRBEntry.INPORT;
    else if(new_type.indexOf("O")!= -1)
      loc = LatchRBEntry.OUTPORT;
    else 
      loc = LatchRBEntry.INTERNAL;
    type = new_type;
    name = new_name;
    index = new_index;
  }

  /**
   * Retrieves the type of the flip-flop.
   *
   * @return The flip-flop's type.
   */
  public String getType() {
    return type;
  }

  /**
   * Retrieves the name of the signal attached to the flip-flop's
   * output.
   *
   * @return The output signal's name.  */
  public String getName() {
    return name;
  }
  
  public String getFullName() {
	  if(index != -1) 
		  return name+"<"+index+">";
	  return name;
  }
  
  public boolean isBus() {
	  return (index != -1);
  }

  /**
   * Retrieves a classification of the flip-flop's function: whether
   * it is an input flip-flop, output flip-flop, or flip-flop internal
   * to the chip.
   *
   * @return The flip-flop's "function".  */
  public int getLocation() {
    return loc;
  }

  /**
   * Retrieves the bus index of the signal attached to the flip-flop's
   * output. If the index is equal to "-1", the wire is not a part of
   * a bus.
   *
   * @return The output signal's bus index.  */
  public int getIndex() {
    return index;
  }

  /**
   * Tests whether the flip-flop is an FPGA input flip-flop.
   *
   * @return Returns <code>true</code> if the flip-flop is an FPGA
   *         input flip-flop; otherwise, it returns
   *         <code>false</code>.  */
  public boolean isInPort() {
    return (loc == LatchRBEntry.INPORT);
  }

  /**
   * Tests whether the flip-flop is an FPGA output flip-flop.
   *
   * @return Returns <code>true</code> if the flip-flop is an FPGA
   *         output flip-flop; otherwise, it returns
   *         <code>false</code>.  */
  public boolean isOutPort() {
    return (loc == LatchRBEntry.OUTPORT);
  }

  /**
   * Tests whether the flip-flop is an internal FPGA flip-flop.
   *
   * @return Returns <code>true</code> if the flip-flop is an internal
   *         FPGA flip-flop; otherwise, it returns <code>false</code>.
   *         */
  boolean isInternal() {
    return (loc == LatchRBEntry.INTERNAL);
  }

  /**
   * Returns a string of the entry's offset, signal name (and index),
   * and the type of the flip-flop */
  public String toString() {
    if(index != -1) 
      return "  "+offset+" "+name+"<"+index+">."+type+"\n";
    return "  "+offset+" "+name+"."+type+"\n";
  }

  /**
   * Returns a string of the entry's signal name (and index), the type
   * of the flip-flop, and the signal name's array index.  If the
   * index is "-1" (the signal is not part of a bus), a "0" is used as
   * the array index.*/
  public String toGroupString() {
    if(index != -1) 
      return "  "+name+"<"+index+">."+type+" "+index+"\n";
    return "  "+name+"."+type+" 0\n";
  }
}
    
