#!/usr/bin/env python

########################################################################
#
# Main program that runs all the test
#
#
#
#
########################################################################

import unittest


import test.test_flipSign, \
        test.test_cmath,    \
        test.test_const_encoder,    \
        test.test_fifo_sync, \
        test.test_bit_order

mL = [test.test_flipSign]
mL.append(test.test_cmath)
mL.append(test.test_const_encoder)
mL.append(test.test_fifo_sync)
mL.append(test.test_bit_order)

tl = unittest.defaultTestLoader
def suite():
    alltests = unittest.TestSuite()
    for m in mL:
        alltests.addTest(tl.loadTestsFromModule(m))
    return alltests

def main():
    unittest.main(defaultTest='suite',
                  testRunner=unittest.TextTestRunner(verbosity=2))





########################################################################
# main
#
if __name__ == '__main__':
    main()
