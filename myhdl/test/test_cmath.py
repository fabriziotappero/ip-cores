
import unittest

from myhdl import *


from rtl.cmath import cadd, csub, cmult

class TestCplxMath(unittest.TestCase):

  def test_cadd(self):
    
    def bench():
      width = 4
      m = 2**(width-1)
      a_re, a_im, b_re, b_im, y_re, y_im = [
          Signal(intbv(0,min=-m, max=m)) for i in range(6)]
      overflow = Signal(bool(0))

      cadd_inst = cadd(a_re,a_im,b_re,b_im,y_re,y_im, overflow, width)

      @instance
      def stimulus():
        a_im.next = 1
        b_re.next = 1
        b_im.next = 1
        overflow.next = False

        for ar in range(-m,m):
          for  br in range(-m,m):
            a_re.next = ar
            b_re.next = br
            yield delay(10)
        
        yield delay(10)

        raise StopSimulation


      @instance
      def verify():
        yield delay(5)

        while True:
          yre_exp = a_re + b_re
          yim_exp = a_im + b_im
          txt = "got: %s at: %d"%(overflow, now())
          if yre_exp >= m:
            ovfl_re = True
            yre_exp = m-1
          elif yre_exp < -m:
            ovfl_re = True
            yre_exp = -m
          else:
            ovfl_re = False

          self.assertEqual(y_re, yre_exp)

          if yim_exp >= m:
            ovfl_im = True
            yim_exp = m-1
          elif yim_exp < -m:
            ovfl_im = True
            yim_exp = -m
          else:
            ovfl_im = False
          
          self.assertEqual(y_im, yim_exp)

          ovfl_exp = ovfl_re or ovfl_im

          self.assertEqual(ovfl_exp, overflow, txt)

          yield delay(10)

      return instances()

    tb = bench()
    #tb = traceSignals(bench)
    sim = Simulation(tb)
    sim.run()


  def test_csub(self):
    
    def bench():
      width = 4
      m = 2**(width-1)
      a_re, a_im, b_re, b_im, y_re, y_im = [
          Signal(intbv(0,min=-m, max=m)) for i in range(6)]
      overflow = Signal(bool(0))

      csub_inst = csub(a_re,a_im,b_re,b_im,y_re,y_im, overflow, width)

      @instance
      def stimulus():
        a_im.next = 1
        b_im.next = 1
        overflow.next = False

        for ar in range(-m,m):
          for  br in range(-m,m):
            a_re.next = ar
            b_re.next = br
            yield delay(10)
        
        yield delay(10)

        raise StopSimulation


      @instance
      def verify():
        yield delay(5)

        while True:
          yre_exp = a_re - b_re
          yim_exp = a_im - b_im
          txt = "got: %s at: %d"%(overflow, now())
          if yre_exp >= m:
            ovfl_re = True
            yre_exp = m-1
          elif yre_exp < -m:
            ovfl_re = True
            yre_exp = -m
          else:
            ovfl_re = False

          self.assertEqual(y_re, yre_exp)

          if yim_exp >= m:
            ovfl_im = True
            yim_exp = m-1
          elif yim_exp < -m:
            ovfl_im = True
            yim_exp = -m
          else:
            ovfl_im = False
          
          self.assertEqual(y_im, yim_exp)

          ovfl_exp = ovfl_re or ovfl_im

          self.assertEqual(ovfl_exp, overflow, txt)

          yield delay(10)

      return instances()

    tb = bench()
    #tb = traceSignals(bench)
    sim = Simulation(tb)
    sim.run()


  def test_cmult(self):
    '''Verify complex multiplier'''

    def bench():
      width = 4
      owidth = width

      smax = 2**(width-1)   # Python oddnes; max value not include
      smin = -2**(width-1)
      #print 'cmult in value range: ', smin, smax-1
      
      osmax = 2**(owidth-1)
      osmin = -2**(owidth-1)
      #print 'cmult out value range: ', osmin, osmax-1

      a_re, a_im, b_re, b_im = [Signal(intbv(0, min=smin, max=smax)) \
                                  for i in range(4)]
      y_re, y_im = [Signal(intbv(0, min=osmin, max=osmax)) \
                                  for i in range(2)]
      overflow = Signal(bool(0))

      cmult_inst = cmult(a_re, a_im, b_re, b_im, y_re, y_im, overflow)

      #print 'input length: ', len(a_re)
 
      @instance
      def stimulus():
        a_re.next = 0
        a_im.next = 0
        b_re.next = 0
        b_im.next = 0
        yield delay(10)

        for ar in range(smin, smax):
          for ai in range(smin, smax):
            for br in range(smin, smax):
              for bi in range(smin, smax):

                # calculate expected values
                prod_a = (ar * br) >> width
                prod_b = (ai * bi) >> width
                prod_c = (ai * br) >> width
                prod_d = (ar * bi) >> width

                re = prod_a - prod_b
                im = prod_c + prod_d

                exp_ovfl = False

                # test expected overflow
                if re >= smax:
                  exp_ovfl = True
                elif re < smin:
                  exp_ovfl = True

                if im >= smax:
                  exp_ovfl = True
                elif im < smin:
                  exp_ovfl = True

                a_re.next = ar
                a_im.next = ai
                b_re.next = br
                b_im.next = bi
                       
                yield delay(1)

                self.assertEqual(overflow, exp_ovfl)

                if not overflow:
                  self.assertEqual(y_re, re)
                  self.assertEqual(y_im, im)

                yield delay(10)

        raise StopSimulation

      return instances()

    ###############################
    tb = bench()
    sim = Simulation(tb)
    sim.run()

