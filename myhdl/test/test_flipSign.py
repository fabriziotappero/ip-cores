#!/usr/bin/env python

import unittest

from myhdl import *

from rtl.flipSign import flipSign

######################################################################
#
# Test bench
#
def bench(tc):
  width = 4
  max = 2**(width-1)
  i_data = Signal(intbv(0, min=-max,max=max))
  o_data = Signal(intbv(0, min=-max,max=max))
  ovfl = Signal(bool(0))

  dut = flipSign(i_data, o_data, ovfl, width)

  @instance
  def check():

    for v in range(-max,max):
      i_data.next = v
      yield delay(1)
      #print 'input: %d output: %d, ovflw: %d'%(i_data, o_data, ovfl)

      if v == -max:
        tc.assertEqual(o_data, max-1)
        tc.failUnless(ovfl)
      else:
        tc.assertEqual(o_data, -i_data)

    raise StopSimulation

  return check, dut


########################################################################
#
# Test cases
#
class TestFlipSign(unittest.TestCase):

  def test_flip_sign(self):
    '''Verify the sign flip'''
    tb = bench(self)
    sim = Simulation(tb)
    sim.run()



########################################################################
# main
#
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(TestFlipSign)
  unittest.TextTestRunner(verbosity=2).run(suite)
