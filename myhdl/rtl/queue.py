
from myhdl import *

def queue(clk, reset, shift, d_i, d_o, qlen=3):
  '''Queue of specified length consists of registers that will shift
  their content and enter input data when the shift signal is activ.
  When inactive content of the current registers will be kept.

  I/O pins:
  =========
  clk     : shifting and registering input data happens synchronous to
            the clock signal
  reset   : reset all registers to 0
  shift   : input data at d_i will be registered to the first register
            and content of each register will be shifted to the next
            register. The content of the last register will be dropped
  d_i     : input data, will be registered to the first register if
            the shift signal is active
  d_o     : output data, resembles the data of the last register

  parameter:
  ==========
  qlen  :   number of registers in the queue

  '''
  m = 2**(len(d_i)-1)
  chain = [Signal(intbv(0, min=-m, max=m)) for i in range(qlen-1)]

  reg_inst = [None for i in range(qlen)]


  for i in range(qlen):
    if i == 0:
      reg_inst[i] = simple_reg(clk, reset, shift, d_i, chain[i])
    elif i > 0 and i < (qlen-1):
      reg_inst[i] = simple_reg(clk, reset, shift, chain[i-1], chain[i])
    elif i == (qlen-1):
      reg_inst[i] = simple_reg(clk, reset, shift, chain[i-1], d_o)

  return instances()



def simple_reg(clk, reset, w_en, d_i, d_o):
  '''Simple register is the unit of the queue. It will register the
  input when w_en is active, remain the current value on inactive w_en
  and reset the value on active reset.
  '''
  @always (clk.posedge)
  def reg_logic():
    if reset == 1:
      d_o.next = 0
    else:

      if w_en:
        d_o.next = d_i
      else:
        d_o.next = d_o
  return instances()
