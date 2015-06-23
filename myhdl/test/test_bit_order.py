#!/usr/bin/env python

import unittest
import os
from myhdl import *

import random


if __name__ == '__main__':
  import sys
  sys.path.append('../')

from rtl.bit_order import bit_order


class TestBitOrder(unittest.TestCase):

  def test_bit_order_simple(self):

    def bench(fp_dataL, ip_dataL, fip_bitL, expOutL):
      '''Verify the proper function of the bit ordering block.

      Function gets passed the input data for the fast and the
      inteleaved path, a list with bits to load from the fast and/or
      interleaved path and the expected output word.
      '''

      DWIDTH = 8
      
      # setup signals 
      clk, reset, \
          fast_data_avail_i, fast_rden_o, \
          inter_data_avail_i, inter_rden_o, \
          ready_o, enable_i, \
          data_out_valid_o \
          = [Signal(bool(0)) for i in range(9)]
   
      fast_data_i, inter_data_i = [Signal(intbv(0)[DWIDTH:]) for i in range(2)]

      fast_bits_i, inter_bits_i = [Signal(intbv(0)[4:]) for i in range(2)]
      data_out_o = Signal(intbv(0)[15:])

      #
      # instantiate DUT
      #
      bit_order_inst = bit_order(clk, reset,
                                  fast_data_avail_i, fast_rden_o, fast_data_i,
                                  inter_data_avail_i, inter_rden_o, inter_data_i,
                                  ready_o, enable_i, fast_bits_i, inter_bits_i,
                                  data_out_valid_o, data_out_o)

      @always(delay(10))
      def clkgen():
        clk.next = not clk

      @instance
      def sendInputData():

        yield reset.negedge
        #print "Got the reset.negedge at %d"%now()
        yield join( fifo(clk, fast_data_avail_i, fast_rden_o, fast_data_i, fp_dataL),
                    fifo(clk, inter_data_avail_i, inter_rden_o, inter_data_i, ip_dataL)
                    )

      @instance
      def ctrlBitOrdering():
        
        # apply reset
        yield clk.negedge
        reset.next = 1
        yield clk.negedge
        reset.next = 0

        yield applyBitValues(clk, ready_o, enable_i, 
                              fast_bits_i, inter_bits_i, 
                              fip_bitL)
        

      @instance
      def verify():

        yield verifyOutput(clk, data_out_valid_o, data_out_o, expOutL)

        raise StopSimulation

      return instances()

    #####################################

    # generate test data
    fp_dataL, ip_dataL, fip_bitL = genData()
   
    # calculate expected output
    expOutL = calcExpectedOutput(fp_dataL, ip_dataL, fip_bitL)


    tb = bench(fp_dataL, ip_dataL, fip_bitL, expOutL)
    #tb = traceSignals(bench, fp_dataL, ip_dataL, fip_bitL, expOutL)
    sim = Simulation(tb)
    sim.run()

##########################################################################
# bus functional models
def verifyOutput(clk, data_out_valid_o, data_out_o, expOutL,
                  TIMEOUT=10):
  '''Bus function model for the bit order block output

  The expected output is provided with expOutL as a list of integers.
  The function will wait for an active data_out_valid_o signal and
  compare the output with a sample of the list.
  '''
  #print "Expected values: ", expOutL

  for exp_value in expOutL:
    to_ctr = 0
    while data_out_valid_o == 0:
      yield clk.negedge
      to_ctr += 1
      if to_ctr > TIMEOUT:
        raise StopSimulation, "verifyOutput timeout ERROR"

    #print "data_out_valid_o: %d at %d"%(data_out_valid_o, now())
    #print "data_out_o: 0x%x expected: 0x%x"%(data_out_o, exp_value)

    yield data_out_valid_o.negedge


def applyBitValues(clk, ready_o, enable_i, fast_bits_i, inter_bits_i, fip_bitL):
  '''BFM for setting the fast and interleaved bits and enabling
  processing

  Waits on an active ready_o and applies the fast_bits_i and
  inter_bits_i data. Then sets enable_i active. Feeds all data from
  fip_bitL to the module this way.
  '''
  #print "Bit list: ", fip_bitL
  for fbits, ibits in fip_bitL:

    # wait until ready is active
    while ready_o == 0:
      yield clk.negedge

    fast_bits_i.next = fbits
    inter_bits_i.next = ibits
    enable_i.next = 1
    #print "applying %d, %d at %d"%(fbits, ibits, now())

    yield clk.negedge
    enable_i.next = 0


def fifo(clk, data_avail_i, rden_o, data_i, dataL):
  '''BFM for sending the fast and interleaved data over the FIFO
  interface

  Waits on a request from the bit order block and sends a data word out.
  '''
  data_avail_i.next = 1
  #print "FIFO data: ", dataL

  for data in dataL:
    data_i.next = data
    while rden_o == 0:
      yield clk.posedge


##########################################################################
# functions for data generation and calculating expected output
def genData():
  '''Generate test data for the bit order block verification
  Return fp_dataL, ip_dataL, fip_bitL

          fp_dataL  : contains the data for the fast path. One byte per
                      entry. Number of bytes (sum of data bits) matches
                      with the sum of bits in fip_bitL for the fast path
          ip_dataL  : contains the data for the interleaved path. One
                      byte per entry. Number of bytes (sum of data bits)
                      matches with the sum of bits in fip_bitL for the
                      interleaved path
          fip_bitL  : list of tuples, with tuples of size 2. Index 0 is
                      the number of bits from the fast path and index 1
                      is the number of bits from the interlaved path.
  '''

  #fp_bitL = [i for i in range(2,16)]
  fp_bitL = [2,8]
  #random.shuffle(fp_bitL)
  bit_sum = sum(fp_bitL)
  rem_bit_sum = bit_sum % 8
  # there is no carrier load of 1 bit, 
  # so in case we need to add 1, add 9
  if rem_bit_sum == 1:
    fp_bitL.append(9)
  elif rem_bit_sum > 1:
    fp_bitL.append(8-rem_bit_sum)
  
  #print "fp_bitL: ", fp_bitL

  ip_bitL = [0]*len(fp_bitL)

  fip_bitL = []
  for i, fp_bits in enumerate(fp_bitL):
    fip_bitL.append((fp_bits, ip_bitL[i]))

  fp_bit_sum = sum(fp_bitL)
  ip_bit_sum = sum(ip_bitL)

  # finished setup the bit list tables

  fp_dataL = []
  ip_dataL = []
  byte_num = fp_bit_sum / 8
  for i in range(byte_num):
    value = random.randrange(256)
    #fp_dataL.append(value)
    fp_dataL.append(16+ i%256)
    #print i, i%256

  return fp_dataL, ip_dataL, fip_bitL


def calcExpectedOutput(fp_dataL, ip_dataL, fip_bitL):
  '''Calculate the expected output of the bit order block
  Return a list with the expected out data words
  '''
  expOutL = []

  # construct a list of bool values from the data. Data for each path
  # come in as one byte per list entry
  fpL = []
  for byte in fp_dataL:
    fpL.extend(byteToBoolList(byte))

  ipL = []
  for byte in ip_dataL:
    ipL.extend(byteToBoolList(byte))


  # reverse the lists, so that the lsb is index -1, as the pop() gets
  fpL.reverse()
  ipL.reverse()
  # the data from the end of the list
  for fp_bits, ip_bits in fip_bitL:
    data_out = 0
    # get first the bits from the fast path
    if fpL:
      for i in range(fp_bits):
        bit = fpL.pop()
        data_out |= bit << i
    
    # now go on with the interleaved path
    if ipL:
      for i in range(ip_bits):
        bit = ipL.pop()
        data_out |= bit << i

    expOutL.append(data_out)


  return expOutL



def byteToBoolList(byte):
  '''Convert an integer byte value to a list of bool types
  index 0 of the list is lsb
  '''
  retL = []
  for i in range(8):
    bit = (byte >> i) & 0x1
    if bit:
      retL.append(1)
    else:
      retL.append(0)

  return retL

########################################################################
# main
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(TestBitOrder)
  unittest.TextTestRunner(verbosity=2).run(suite)
