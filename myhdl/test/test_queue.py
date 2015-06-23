
import unittest

from myhdl import *

from rtl.queue import queue, simple_reg


class TestQueue(unittest.TestCase):

  
  def test_simple_reg(self):
    def bench():
      width = 4
      m = 2**(width-1)

      # set some stimulus values, need to be in range of width
      value1 = 7
      value2 = -8
      value3 = -3

      clk, reset, w_en = [Signal(bool(0)) for i in range(3)]
      d_i, d_o = [Signal(intbv(0, min=-m, max=m)) for i in range(2)]
      simple_reg_inst = simple_reg(clk, reset, w_en, d_i, d_o)
    
      @always(delay(10))
      def clkgen():
        clk.next = not clk

      @instance
      def stimulus():

        # reset the reg
        w_en.next = False
        reset.next = True
        yield clk.negedge
        reset.next = False
        yield clk.negedge


        # write a value and expect it as output
        w_en.next = True
        d_i.next = value1
        yield clk.negedge

        # apply a new input value with w_en=False and expect the old
        # output to remain
        w_en.next = False
        d_i.next = value2
        yield clk.negedge

        # apply a new input value with w_en=True and expect the output
        # to change
        w_en.next = True
        d_i.next = value3
        yield clk.negedge

        # and now reset again with active w_en and expect the value to
        # be 0
        w_en.next = True
        reset.next = True
        yield clk.negedge

        w_en.next = False
        reset.next = False
        yield clk.negedge

        raise StopSimulation


      @instance
      def verify():

        yield clk.negedge
        self.assertEqual(reset, True)
        yield clk.negedge
        self.assertEqual(reset, False)
        self.assertEqual(d_o, 0, '%d should be 0 at %d'%(d_o, now()))

        # verify that the first value appears as output
        yield clk.negedge
        self.assertEqual(d_o, value1)

        # expect still the old output value1 to remain
        yield clk.negedge
        self.assertEqual(d_o, value1)
        
        # expect now the new input value3 as output
        yield clk.negedge
        self.assertEqual(d_o, value3)

        # now expect the value to be reset, despite an active w_en
        yield clk.negedge
        self.assertEqual(d_o, 0)
        
        # and still remain 0
        yield clk.negedge
        self.assertEqual(d_o, 0)

      return instances()

    tb = bench()
    #tb = traceSignals(bench)    
    sim = Simulation(tb)
    sim.run()

  
  
  def test_queue(self):

    def bench():

      qlen = 3
      width = 4
      m = 2**(width-1)

      value1 = -m
      value2 = -1
      value3 = m-1
      value4 = 1
      
      clk, reset, shift = [Signal(bool(0)) for i in range(3)]
      d_i, d_o = [Signal(intbv(0, min=-m, max=m)) for i in range(2)]
      
      queue_inst = queue(clk, reset, shift, d_i, d_o, qlen)
 
      @always(delay(10))
      def clkgen():
        clk.next = not clk

      @instance
      def stimulus():
        # apply reset
        shift.next = False
        reset.next = True
        yield clk.negedge #1
        reset.next = False
        yield clk.negedge #2
        #print 'stim #2 ', now()

        ## Test the shift through
        #
        # fill in a different value for each register and expect the
        # output value to change, considering the 0 values from reset.
        # So when filling in value1, value2, value3, the expected
        # output is 0, 0, value1, value2, value3
        shift.next = True
        d_i.next = value1
        yield clk.negedge #3
        d_i.next = value2
        yield clk.negedge #4
        d_i.next = value3 
        yield clk.negedge #5
        #print 'stim #5 ', now()

        # needed to shift the values out for verification and fill in
        # value4, but only 2 times
        d_i.next = value4
        yield clk.negedge #6
        yield clk.negedge #7
        
        ## Hold values
        # now hold, should see value3 3 times 
        shift.next = False
        yield clk.negedge #8
        
        yield clk.negedge #9
        yield clk.negedge #10
        yield clk.negedge #11
        #print 'stim time sync: ', now()
        
        ## Shift out again
        # shifting out value4 vor verification and filling in value2
        d_i.next = value2
        shift.next = True
        yield clk.negedge #12
        #print 'stim #12 ', now()
        yield clk.negedge #13
        yield clk.negedge #14
        
        ## Reset and then shift
        # now reset and then shift, expecting qlen x 0 to come out
        reset.next = True
        yield clk.negedge #15
        reset.next = False
        yield clk.negedge #16
        yield clk.negedge #17
        yield clk.negedge #18

        raise StopSimulation


      @instance
      def verify():

        # verify that output is 0
        yield clk.negedge #1
        self.assertEqual(reset, True)
        yield clk.negedge #2
        #print 'veri #2 ', now()
        self.assertEqual(reset, False)
        self.assertEqual(shift, False)
        self.assertEqual(d_o, 0, '%d should be 0 at %d'%(d_o, now()))

        ## Test the shift through
        # expecting 0, 0, value1, value2, value3
        yield clk.negedge #3
        self.assertEqual(shift, True)
        self.assertEqual(d_o, 0, '%d should be 0 at %d'%(d_o, now()))
        yield clk.negedge #4
        self.assertEqual(d_o, 0, '%d should be 0 at %d'%(d_o, now()))
        yield clk.negedge #5
        #print 'verify #5 ', now()
        self.assertEqual(d_o, value1)
        yield clk.negedge #6
        self.assertEqual(d_o, value2)
        yield clk.negedge #7
        self.assertEqual(d_o, value3)
        
        ## Hold values (2 x value4, 1 x value3)
        # now expect 3x value3 -- always output from last register, as
        # no shifting is done
        yield clk.negedge #8
        self.assertEqual(d_o, value3)
        yield clk.negedge #9
        self.assertEqual(d_o, value3)
        yield clk.negedge #10
        self.assertEqual(d_o, value3)
        yield clk.negedge #11
        self.assertEqual(d_o, value3)

        ## Shift out again
        # should get 3x value4 -- this time shifting is active and
        # values from all registers should get shifted out
        #print 'verify time sync: ', now()
        #self.assertEqual(shift, True)
        yield clk.negedge #12
        #print 'verify #12 ', now()
        self.assertEqual(d_o, value4)
        yield clk.negedge #13
        self.assertEqual(d_o, value4)

        ## Expect value2 from #12
        yield clk.negedge #14
        self.assertEqual(d_o, value2, '%d should be %d at %d'%(d_o, value2, now()))
        #self.assertEqual(reset, True, 
        #    'reset is "%d" should be "True" at %d'%(reset, now()))
        
        ## Reset and shift
        # now expecting a reset and then qlen x 0
        
        yield clk.negedge #15
        self.assertEqual(d_o, 0, '%d should be 0 at %d'%(d_o, now()))
        yield clk.negedge #16
        self.assertEqual(d_o, 0, '%d should be 0 at %d'%(d_o, now()))
        yield clk.negedge #17
        self.assertEqual(d_o, 0, '%d should be 0 at %d'%(d_o, now()))

      return instances()

    tb = bench()
    #tb = traceSignals(bench)    
    sim = Simulation(tb)
    sim.run()
    

