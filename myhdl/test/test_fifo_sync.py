#!/usr/bin/env python

import unittest
import os
from myhdl import *

if __name__ == '__main__':
  import sys
  sys.path.append('../')

from rtl.fifo_sync import fifo_sync


class TestFifo(unittest.TestCase):

  def test_fifo_simple(self):

    def bench():

      DWIDTH = 4
      SIZE = 4

      clk, reset, full_o, wen_i, data_avail_o, rden_i = \
          [Signal(bool(0)) for i in range(6)]

      data_i, data_o = [Signal(intbv(0)[DWIDTH:]) for i in range(2)]

      fifo_inst = fifo_sync( clk, reset,
                              full_o, wen_i, data_i,
                              data_avail_o, rden_i, data_o,
                              DWIDTH,SIZE)

      @always(delay(10))
      def clkgen():
        clk.next = not clk

      @instance
      def stim_and_check():
        reset.next = 1
        yield clk.negedge
        reset.next = 0
        yield clk.negedge

        self.assertEqual(full_o, 0)
        self.assertEqual(data_avail_o, 0)
          
        # write fifo full
        yield clk.negedge
        for i in range(SIZE+1):

          data_i.next = i
          wen_i.next = 1
          yield clk.negedge

          if i < SIZE-1:
            msg = "full (0): %d at %d"%(full_o, now())
            self.assertEqual(full_o, 0, msg)
          else:
            msg = "full (1): %d at %d"%(full_o, now())
            self.assertEqual(full_o, 1, msg)

        wen_i.next = 0
        
        # read fifo back empty
        yield clk.negedge
        rden_i.next = 1
        
        yield clk.posedge
        self.assertEqual(full_o, 1)
        
        yield delay(1)
        self.assertEqual(full_o, 0)
        
        for i in range(SIZE+1):
          yield clk.negedge

          if i < SIZE-1:
            msg = "i: %d data_o: %d at %d"%(i, data_o, now())
            self.assertEqual(data_o, i, msg)
          elif i == SIZE-1:
            msg = "i: %d data_o: %d at %d"%(i, data_o, now())
            self.assertEqual(data_o, SIZE-1, msg)
            self.assertEqual(data_avail_o, 0)
            
        rden_i.next = 0
        yield clk.negedge

        #
        # fill 2 words, read/write 3 words, should not get full
        #

        # 1st data
        data_i.next = 1
        wen_i.next = 1
        yield clk.negedge

        self.assertEqual(data_avail_o, 1)

        # 2nd data
        data_i.next = 2
        yield clk.negedge

        # write and read
        rden_i.next = 1
        for i in range(3):
          data_i.next = 11 + i
          yield clk.negedge

          self.assertEqual(full_o, 0)
          self.assertEqual(data_avail_o, 1)

          if i == 0:
            self.assertEqual(data_o, 1)
          elif i == 1:
            self.assertEqual(data_o, 2)
          elif i == 2:
            self.assertEqual(data_o, 11)

        wen_i.next = 0

        yield clk.negedge
        self.assertEqual(full_o, 0)
        self.assertEqual(data_avail_o, 1)
        self.assertEqual(data_o, 12)
        
        yield clk.negedge
        self.assertEqual(full_o, 0)
        self.assertEqual(data_avail_o, 0)
        self.assertEqual(data_o, 13)

        
        yield clk.negedge
        self.assertEqual(full_o, 0)
        self.assertEqual(data_avail_o, 0)
        self.assertEqual(data_o, 13)

        rden_i.next = 0

        raise StopSimulation

      return instances()

    tb = bench()
    #tb = traceSignals(bench)
    sim = Simulation(tb)
    sim.run()

########################################################################
# main
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(TestFifo)
  unittest.TextTestRunner(verbosity=2).run(suite)
