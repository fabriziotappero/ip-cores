
from myhdl import *

def cadd(a_re, a_im, b_re, b_im, y_re, y_im, overflow, width=8):
  '''Complex add

  I/O pins:
  =========
  a         : input a
  b         : input b
  y         : output a + b
  overflow  : signal overflow

  parameter:
  ==========
  width : data width for input and output
  '''
  @always_comb
  def logic():
    m = 2**(width-1)

    #
    # Real value calculation
    if (a_re + b_re) >= m:
      y_re.next = m-1
      ovfl_re = True

    elif (a_re + b_re) < -m:
      y_re.next = -m
      ovfl_re = True

    else:
      y_re.next = a_re + b_re
      ovfl_re = False

    #
    # Imaginary add
    if (a_im + b_im) >= m:
      y_im.next = m-1
      ovfl_im = True

    elif (a_im + b_im) < -m:
      y_im.next = -m
      ovfl_im = True

    else:
      y_im.next = a_im + b_im
      ovfl_im = False

    overflow.next = ovfl_re or ovfl_im

  return instances()


def csub(a_re, a_im, b_re, b_im, y_re, y_im, overflow, width=8):
  
  @always_comb
  def logic():
    m = 2**(width-1)

    #
    # Real value calculation
    if (a_re - b_re) >= m:
      y_re.next = m-1
      ovfl_re = True

    elif (a_re - b_re) < -m:
      y_re.next = -m
      ovfl_re = True

    else:
      y_re.next = a_re - b_re
      ovfl_re = False

    #
    # Imaginary add
    if (a_im - b_im) >= m:
      y_im.next = m-1
      ovfl_im = True

    elif (a_im - b_im) < -m:
      y_im.next = -m
      ovfl_im = True

    else:
      y_im.next = a_im - b_im
      ovfl_im = False

    overflow.next = ovfl_re or ovfl_im

  return instances()


def cmult(a_re, a_im, b_re, b_im, y_re, y_im, overflow):
  ''' Perform the complex multiplication of a * b = y

  This turns out to be:

  y_re = a_re * b_re - a_im * b_im
  y_im = a_re * b_im + a_im * b_re

  The output is expected to have at least the same width as the input.
  The products are scaled back to the input width and in case an extra
  bit would be needed due to the addition or subtraction, an overflow
  is signaled.

  At the moment the overflowing output is saturated to the respective
  limit, based on the input width. So a wider output width is not used
  with the current implementation.

  I/O pins:
  =========
  a         : input a
  b         : input b
  y         : output a * b
  overflow  : signal overflow

  '''

  @always_comb
  def logic():
    
    # use input width of a_re, assume a_im, b_re and b_im are the same
    width = len(a_re)

    # calculate min and max value range
    smin = -2**(width-1)
    smax = 2**(width-1)

    #print 'cmult input width: ', width

    prod_a = a_re * b_re
    prod_b = a_im * b_im
    prod_c = a_re * b_im
    prod_d = a_im * b_re

    # scaling back the product to stay on input width
    prod_a = prod_a >> width
    prod_b = prod_b >> width
    prod_c = prod_c >> width
    prod_d = prod_d >> width

    #print 'cmult in: ', a_re, a_im, b_re, b_im
    #print 'cmult prod: ', prod_a, prod_b, prod_c, prod_d

    prod_diff = prod_a - prod_b
    prod_sum = prod_c + prod_d

    ovfl = False

    if prod_sum >= smax:
      prod_sum = smax-1
      ovfl = True

    elif prod_sum < smin:
      prod_sum = smin
      ovfl = True

    if prod_diff >= smax:
      prod_diff = smax-1
      ovfl = True
    elif prod_diff < smin:
      prod_diff = smin
      ovfl = True

     # here we would need a bit growth, but only signal it as overflow
    y_re.next = prod_diff
    y_im.next = prod_sum
    overflow.next = ovfl

    #print 'cmult: a_re: %d, a_im: %d, b_re: %d, b_im: %d'%(
    #        a_re, a_im, b_re, b_im)
    #print 'cmult: y_re: %d, y_im: %d, overflow: %d'%(y_re, y_im,
    #    overflow)

  return instances()
