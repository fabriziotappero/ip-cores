
from myhdl import *



def fifo_sync(clk, reset, 
              full_o, wen_i, data_i,
              data_avail_o, rden_i, data_o,
              DWIDTH=8, SIZE=8):
  '''FIFO with clock synchronous read and write

  I/O pins:
  =========
  clk           : clock signal
  reset         : reset will empty the memory and reset full_o and
                  data_avail_o signals
  full_o        : signal that the FIFO is full. No further input data
                  are taken.
  wen_i         : write enable for the data_i data
  data_i        : input data with data width as specified by DWIDTH

  data_avail_o  : signal that there are data in the FIFO available for
                  reading out
  rden_i        : read enable for the data_o signal
  data_o        : output data. Only valid if the data_avail_o signal is
                  active

  parameters:
  ===========

  DWIDTH  : data width
  SIZE    : size of the FIFO
  '''

  mem = [Signal(intbv(0)[DWIDTH:]) for i in range(SIZE)]
  wp, rp = [Signal(int(0)) for i in range(2)]
  fill_ctr = Signal(intbv(0, min=0, max=SIZE+1))

  @always(clk.posedge, reset.posedge)
  def write_data():
    
    if reset:
      data_o.next = 0
      rp.next = 0

    else:
      if wen_i and not full_o:
        mem[wp.val].next = data_i
        if wp < SIZE-1:
          wp.next = wp + 1
        else:
          wp.next = 0

  @always(clk.posedge, reset.posedge)
  def read_data():

    if reset:
      data_o.next = 0
      rp.next = 0

    else:
      if rden_i and data_avail_o:
        data_o.next = mem[rp.val]
        if rp < SIZE-1:
          rp.next = rp + 1
        else:
          rp.next = 0


  @always(clk.posedge, reset.posedge)
  def count_load():

    if reset:
      fill_ctr.next = 0
    else:

      if (rden_i and data_avail_o) and not (wen_i and not full_o) \
          and (fill_ctr > 0):

            fill_ctr.next = fill_ctr - 1

      elif (wen_i and not full_o) and not (rden_i and data_avail_o) \
          and (fill_ctr < SIZE):

            fill_ctr.next = fill_ctr + 1


  @always_comb
  def comb():
    if fill_ctr == SIZE:
      full_o.next = 1
    else:
      full_o.next = 0

    if fill_ctr > 0:
      data_avail_o.next = 1
    else:
      data_avail_o.next = 0

  return instances()
