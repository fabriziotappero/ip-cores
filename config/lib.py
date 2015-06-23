#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#

def conv_hex(val):
    hexval = hex(val)
    if hexval[-1:] == 'L':
        hexval = hexval[:-1]
    return hexval

