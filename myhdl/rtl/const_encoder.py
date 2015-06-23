
from myhdl import *


def const_encoder( clk, reset, wen_i, const_size_i, data_i,
                  data_valid_o, x_o, y_o):
  '''Constellation encoder

  I/O pins:
  =========
  clk           : clock input
  reset         : reset input

  wen_i         : write enable for the const_size_i and data_i
  const_size_i  : select the constellation size
  data_i        : data word to be encoded
  data_valid_o  : signal that the output data x_o and y_o are valid
                  after an applied wen_i
  x_o           : real part of the constellation point
  y_o           : imaginary part of the constellation point

  parameters:
  ===========

  '''

  din_reg = Signal(intbv(0)[15:])
  const_size_i_reg = Signal(intbv(0)[4:])
  dvalid_reg = Signal(intbv(0)[1:])

  x,y = [Signal(intbv(0,min=-256,max=256)) for i in range(2)]

  XY = [0,0,0,0, 3,3,3,3, 12,12,12,12, 15,15,15,15, 4,4, 8,8,
      1,2,1,2, 13,14,13,14, 7,7,11,11]
  
  @always(clk.posedge, reset.posedge)
  def reg_input():

    if reset:
      din_reg.next = 0
      const_size_i_reg.next = const_size_i
    else:

      if wen_i:
        #print "data_i: %d size: %d at %d"%(data_i, const_size_i, now())
        din_reg.next = data_i
        const_size_i_reg.next = const_size_i


  @always(clk.posedge, reset.posedge)
  def reg_output():
    
    if reset:
      x_o.next = 0
      y_o.next = 0
      dvalid_reg.next = 0
      data_valid_o.next = 0
    else:
      x_o.next = x
      y_o.next = y
      #print "x_o: %d y_o: %d at %d"%(x_o,y_o,now())

      dvalid_reg.next[0] = wen_i
      data_valid_o.next = dvalid_reg[0]


  @always_comb
  def const_enc():

    if const_size_i_reg[0] == 0:    # even constellation

      if const_size_i_reg == 2:
        x.next = concat(din_reg[1], True).signed()
        y.next = concat(din_reg[0], True).signed()
        #x.next = concat(din_reg[1], True)
        #y.next = concat(din_reg[0], True)
      elif const_size_i_reg == 4:
        x.next = concat(din_reg[3], din_reg[1], True).signed()
        y.next = concat(din_reg[2], din_reg[0], True).signed()
        #x.next = concat(din_reg[3], din_reg[1], True)
        #y.next = concat(din_reg[2], din_reg[0], True)

    else:                           # odd constellation

      if const_size_i_reg == 3:
        if din_reg == 4:
          x.next = -3
          y.next = 1
        elif din_reg == 5:
          x.next = 1
          y.next = 3
        elif din_reg == 6:
          x.next = -1
          y.next = -3
        elif din_reg == 7:
          x.next =  3
          y.next = -1
        else:
          x.next = concat(din_reg[1], True).signed()
          y.next = concat(din_reg[0], True).signed()

      else:
        addr = concat(  din_reg[const_size_i_reg-1], 
                        din_reg[const_size_i_reg-2], 
                        din_reg[const_size_i_reg-3], 
                        din_reg[const_size_i_reg-4], 
                        din_reg[const_size_i_reg-5])
      
        xy = intbv(XY[int(addr)])[4:]
        top2X = xy[4:2]
        top2Y = xy[2:0]

        if const_size_i_reg == 5:
          x.next = concat(top2X, din_reg[1], True).signed()
          y.next = concat(top2Y, din_reg[0], True).signed()

  return instances()


########################################################################
def convert():
  
  clk, reset, \
      wen_i, data_valid_o \
      = [Signal(bool(0)) for i in range(4)]

  const_size_i = Signal(intbv(0)[4:])
  data_i = Signal(intbv(0)[15:])
  x_o, y_o = [Signal(intbv(0, min=-256, max=256)) for i in range(2)]

  toVerilog(const_encoder, 
            clk, reset, 
            wen_i, const_size_i,
            data_i,
            data_valid_o, x_o, y_o)


if __name__ == '__main__':
  convert()
