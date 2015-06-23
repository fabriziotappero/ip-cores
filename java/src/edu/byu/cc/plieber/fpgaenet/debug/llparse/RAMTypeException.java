/*
@LICENSE@
*/

package edu.byu.cc.plieber.fpgaenet.debug.llparse;

/**
 * An exception indicating that a problem was encountered regarding
 * the type of a RAM. The problem usually is a unknown RAM type.
 *
 * @author Paul Graham */
class RAMTypeException extends Exception {
  
  /** Standard parameterless constructor */
  RAMTypeException(){
    super();
  }

  /** Constructor with message <code>String</code> 
   *
   * @param message The message <code>String</code> for the
   *                exeception. */
  RAMTypeException(String message) {
    super(message);
  }
}
