
from myhdl import *


def flipSign(in_data, out_data, overflow, width):
  '''Flip the sign of the input value.
  The min value will cause an overflow and will be saturated to the max
  value when flipping its sign

  I/O Signals
  ===========
  in_data   : signal with the input data
  out_data  : signal having input data with flipped sign
  overflow  : signal whether an overflow occured. That only happens for
              min value, as the max value = abs(min) - 1

  Parameter
  =========
  width     : input width
  '''
  
  min = -2**(width-1)
  max = 2**(width-1)-1

  @always_comb
  def rtl():

    if in_data == min:
      out_data.next = max
      overflow.next = True
    else:
      out_data.next = -in_data
      overflow.next = False

  return instances()

