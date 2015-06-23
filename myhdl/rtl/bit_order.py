

from myhdl import *


def bit_order(clk, reset, 
              fast_data_avail_i, fast_rden_o, fast_data_i,
              inter_data_avail_i, inter_rden_o, inter_data_i,
              ready_o, enable_i, fast_bits_i, inter_bits_i,
              data_out_valid_o, data_out_o,
              DWIDTH=15):
  '''Bit order block

  I/O pins:
  =========
  clk                 : clock input
  reset               : reset input

  fast_data_avail_i   : signal that there are fast data available
  fast_rden_o         : read pulse for the fast data input
  fast_data_i         : fast data input. Data come from the FIFO and are 8
                        bit wide

  inter_data_avail_i  : signal that there are interleaved data available
  inter_rden_o        : read pulse for the interleaved data input
  inter_data_i        : interleaved data input. Data come from the FIFO
                        and are 8 bit wide

  ready_o             : signal that with enable_i a new processing cycle
                        can start
  enable_i            : pulse to enable the processing for the set input
                        data
  fast_bits_i         : number of bits to be extracted from the fast data
                        path
  inter_bits_i        : number of bits to be extracted from the
                        interleaved data path

  data_out_valid_o    : signal that after an enable_i pulse the data_out_o
                        value is valid
  data_out_o          : DWIDTH bit wide output data


  parameters:
  ===========

  DWIDTH              : output data width. Resembles the maximum number
                        of bits to be loaded per carrier
  '''
  
  #
  # signal setup

  t_state = enum('IDLE', 'FP_LOAD', 'IP_LOAD', 'FIP_SHIFT', 'DOUT')

  state = Signal(t_state.IDLE)

  SWIDTH = (DWIDTH-1-8) + 2*8       # shift register width

  fp_shift_reg, ip_shift_reg \
      = [Signal(intbv(0)[SWIDTH:]) for i in range(2)]
  
  fp_process, ip_process, fp_needs_load, ip_needs_load \
      = [Signal(bool(0)) for i in range(4)]

  fp_shift_load, ip_shift_load \
      = [Signal(int(0)) for i in range(2)]


  #
  # logic

  @always_comb
  def comb_logic_ready():
    if state == t_state.IDLE or data_out_valid_o:
      ready_o.next = 1
    else:
      ready_o.next = 0

  @always_comb
  def comb_logic():
    fp_needs_load.next = fast_bits_i > fp_shift_load
    ip_needs_load.next = inter_bits_i > ip_shift_load

    fp_process.next = fast_bits_i > 0
    ip_process.next = inter_bits_i > 0


  @always(clk.posedge, reset.posedge)
  def fsm():
    
    if reset:
      state.next = t_state.IDLE
    else:
      
      if state == t_state.IDLE:

        if enable_i and fp_process and fp_needs_load:
          state.next = t_state.FP_LOAD
        elif enable_i and not fp_process and ip_process and ip_needs_load:
          state.next = t_state.IP_LOAD
        elif enable_i and not fp_process and ip_process and not ip_needs_load:
          state.next = t_state.FIP_SHIFT

      elif state == t_state.FP_LOAD:

        if not fp_needs_load and ip_process and ip_needs_load:
          state.next = t_state.IP_LOAD
        elif not fp_needs_load and not ip_process:
          state.next = t_state.FIP_SHIFT

      elif state == t_state.IP_LOAD:
      
        if not ip_needs_load:
          state.next = t_state.IP_SHIFT

      elif state == t_state.FIP_SHIFT:

        state.next = t_state.DOUT

      elif state == t_state.DOUT:

        if data_out_valid_o and not enable_i:
          state.next = t_state.IDLE
        elif data_out_valid_o and enable_i \
            and fp_process and fp_needs_load:
          state.next = t_state.FP_LOAD
        elif data_out_valid_o and enable_i \
            and not fp_process and ip_process and ip_needs_load:
          state.next = t_state.IP_LOAD
        elif data_out_valid_o and enable_i \
            and fp_process or ip_process:
          state.next = t_state.FIP_SHIFT



  #
  # fast path load processing
  @always(clk.posedge, reset.negedge)
  def fp_load():

    if reset:
      fast_rden_o.next = 0
      fp_shift_load.next = 0
      fp_shift_reg.next = 0

    else:
      if state == t_state.FP_LOAD:
        if fp_needs_load and fast_data_avail_i and not fast_rden_o:
          fast_rden_o.next = 1
        elif fast_rden_o:
          fast_rden_o.next = 0
          fp_shift_load.next = fp_shift_load + 8

          if fp_shift_load > 0:
            fp_shift_reg.next = concat(fast_data_i, fp_shift_reg[fp_shift_load:])
          else:
            fp_shift_reg.next = fast_data_i
      
      elif state == t_state.FIP_SHIFT:
        fp_shift_load.next = fp_shift_load - fast_bits_i


  #
  # interleaved path load processing
  @always(clk.posedge, reset.negedge)
  def ip_load():

    if reset:
      inter_rden_o.next = 0
      ip_shift_load.next = 0
      ip_shift_reg.next = 0

    else:
      if state == t_state.IP_LOAD:
        if inter_data_avail_i and not inter_rden_o:
          inter_rden_o.next = 1
        elif inter_rden_o:
          inter_rden_o.next = 0
          ip_shift_load.next = ip_shift_load + 8
          if ip_shift_load > 0:
            ip_shift_reg.next = concat(inter_data_i, ip_shift_reg[ip_shift_load:])
          else:
            ip_shift_reg.next = inter_data_i

      elif state == t_state.FIP_SHIFT:
        ip_shift_load.next = ip_shift_load - inter_bits_i


  #
  # fast and interleaved path shift processing
  @always(clk.posedge, reset.negedge)
  def fp_ip_shift():

    if reset:
      data_out_o.next = 0
      data_out_valid_o.next = 0

    else:

      if state == t_state.FIP_SHIFT:
        if fp_process and not ip_process:
          data_out_o.next = fp_shift_reg[fast_bits_i:]
          fp_shift_reg.next = fp_shift_reg[:fast_bits_i]

        elif not fp_process and ip_process:
          data_out_o.next = ip_shift_reg[inter_bits_i:]
          ip_shift_reg.next = ip_shift_reg[:inter_bits_i]

        else:
          data_out_o.next = concat( ip_shift_reg[inter_bits_i:],
                                    fp_shift_reg[fast_bits_i:])
          fp_shift_reg.next = fp_shift_reg[:fast_bits_i]
          ip_shift_reg.next = ip_shift_reg[:inter_bits_i]

        data_out_valid_o.next = 1

      else:
        
        data_out_valid_o.next = 0

  return instances()
