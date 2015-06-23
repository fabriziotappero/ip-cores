/*
@LICENSE@
*/

package edu.byu.cc.plieber.fpgaenet.debug.llparse;

/**
 * This class is used by several other classes for encoding the type
 * of a RAM as an integer.
 *
 * @author Paul Graham
 */
public enum RAMTypes {

  /* Here are the various forms of RAMs */
  /** Represents a LUT RAM in the A LUT */
  A,
  /** Represents a LUT RAM in the B LUT */
  B,
  /** Represents a LUT RAM in the C LUT */
  C,
  /** Represents a LUT RAM in the D LUT */
  D,
  /** Represents a Block RAM (Virtex5) */
  BRAM
}
