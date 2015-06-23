#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
import os, sys, re

from projpaths import *
from lib import *

def get_conts_memory_regions(phys_virt, array_start, array_end):
    with open(join(PROJROOT, CONFIG_H), 'r')as file:
        for line in file:
            begin = line.rfind(" ")
            end = len(line)
            if re.search("(" + phys_virt + ")([0-9]){1,4}(_START)", line):
                array_start.append(int(line[begin : end], 16))
            elif re.search("(" + phys_virt + ")([0-9]){1,4}(_END)", line):
                array_end.append(int(line[begin : end], 16))

def check_memory_overlap(phys_virt,  array_start, array_end):
    length = len(array_start)
    # Brute force method
    for index, s1 in enumerate(array_start):
        e1 = array_end[index]
        iter = 0
        while iter < length:
            if index == iter:
                iter = iter + 1
                continue
            if ((s1 <= array_start[iter]) and \
                ((e1 >= array_end[iter]) or (array_start[iter] < e1 <= array_end[iter]))):
                print 'Memory overlap between containers!!!'
                print 'overlapping ranges: '+ \
                    conv_hex(s1) + '-' + conv_hex(e1) + ' and ' + \
                    conv_hex(array_start[iter]) + '-' + conv_hex(array_end[iter])
                print '\n'
                sys.exit()
            else:
                iter = iter + 1

def phys_region_sanity_check():
    phys_start = []
    phys_end = []
    get_conts_memory_regions('PHYS', phys_start, phys_end)
    check_memory_overlap('PHYS', phys_start, phys_end)

def virt_region_sanity_check():
    virt_start = []
    virt_end = []
    get_conts_memory_regions('VIRT', virt_start, virt_end)
    check_memory_overlap('VIRT', virt_start, virt_end)

def sanity_check_conts():
    phys_region_sanity_check()
    virt_region_sanity_check()

