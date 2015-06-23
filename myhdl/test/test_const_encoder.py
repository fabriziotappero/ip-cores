#!/usr/bin/env python

import unittest

import os
from myhdl import *

import random

from rtl.const_encoder import const_encoder


########################################################################
#
# Test cases
#
class TestConstEncoder(unittest.TestCase):

    def test_const_encoder(self):
      
      def bench(tc):
        
        clk, reset, \
            wen_i, data_valid_o \
            = [Signal(bool(0)) for i in range(4)]

        const_size_i = Signal(intbv(0)[4:])
        data_i = Signal(intbv(0)[15:])
        x_o, y_o = [Signal(intbv(0, min=-256, max=256)) for i in range(2)]

        const_encoder_inst = const_encoder( clk, reset,
                                            wen_i, const_size_i,
                                            data_i,
                                            data_valid_o, x_o, y_o)
        
        
        @always(delay(10))
        def clkgen():
          clk.next = not clk

        @instance
        def stimulus():

          yield clk.negedge
          reset.next = 1
          yield clk.negedge
          reset.next = 0

         
          # quick test
          sizeL = [3, 4, 5, 6, 7, 8, 9, 10, 11]
          
          # full test
          #sizeL = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

          for size in sizeL:
              #print
              #print 'Testing const_size %d'%size
              #print
              const_size_i.next = size

              yield clk.negedge

              for i in range(2**size):
                data_i.next = i
                wen_i.next = 1
                yield clk.negedge
                wen_i.next = 0

              yield clk.negedge
          
          yield clk.negedge
          raise StopSimulation
          

        @instance
        def verify():
          
          expb2XL = [1, 1, -1, -1]
          expb2YL = [1, -1, 1, -1]
          expb3XL = [1,  1, -1, -1, -3, 1, -1]
          expb3YL = [1, -1,  1, -1,  1, 3, -3]
          expb4XL = [1, 1, 3, 3, 1, 1, 3, 3, -3, -3, -1, -1, -3, -3, -1, -1]
          expb4YL = [1, 3, 1, 3, -3, -1, -3, -1, 1, 3, 1, 3, -3, -1, -3, -1]
          expb5XL = [1, 1, 3, 3,  1,  1,  3,  3, -3, -3, -1, -1, -3, -3, -1, -1,
              5, 5, -5, -5, 1,  1, 3,  3, -3, -3, -1, -1,  5,  5, -5, -5]
          expb5YL = [1, 3, 1, 3, -3, -1, -3, -1,  1,  3,  1,  3, -3, -1, -3, -1,
              1, 3,  1,  3, 5, -5, 5, -5,  5, -5,  5, -5, -3, -1, -3, -1]


          while True:

              expXL = []
              expYL = []
              
              yield data_valid_o.posedge

              if const_size_i == 2:
                expXL = expb2XL
                expYL = expb2YL
              elif const_size_i == 4:
                expXL = expb4XL
                expYL = expb4YL
              elif const_size_i == 5:
                expXL = expb5XL
                expYL = expb5YL

              #print "expXL ", expXL
              #print "expYL ", expYL
              #print "at ", now()


              for j, expX in enumerate(expXL):

                yield clk.negedge
                #print
                #print "data_valid: %d x_o: %d y_o: %d at %d"%( data_valid_o,
                #                                                x_o, y_o,
                #                                                now())
                #print "expecting x_o: %d y_o: %d"%(expX, expYL[j])

                if expX != x_o:
                  tc.fail("%d != x_o: %d at %d"%(expX, x_o, now()))
                if expYL[j] != y_o:
                  tc.fail("%d != y_o: %d at %d"%(expYL[j], y_o, now()))
              
              #raise StopSimulation
          
        return instances()

      
      #####################################
      tb = bench(self)
      #tb = traceSignals(bench)
      sim = Simulation(tb)
      sim.run()


