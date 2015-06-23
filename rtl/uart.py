# -*- coding: utf-8 -*-
"""
    uart.py
    =======

    Simple 3-wire UART
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: uart.py 5 2010-11-21 10:59:30Z rockee $
"""

from myhdl import *

#def BaudGen(enable16, reset, clock, freq_hz=50000000, baud=115200):
    #):

def UART(rx_data, rx_avail, rx_error, read_en,
         tx_data, tx_busy, write_en,
         uart_rxd, uart_txd, reset, clock,
         freq_hz=50000000, baud=115200):
    """
    Universal asynchronous receiver/transmitter

    rx_data:    receive data register output
    rx_avail:   receive data available output
    rx_error:   receive error output
    read_en:    read enable pulse input
    tx_data:    transmit data register input
    tx_busy:    transmitter busy output
    write_en:   write ebable pulse input
    uart_rxd:   receive physical wire input
    uart_txd:   transmit physical wire output
    reset:      synchronous uart reset input
    clock:      host clock input
    freq_hz:    host clock frequancy
    baud:       baud rate
    """
    divisor = freq_hz / baud / 16
    enable16_counter = Signal(intbv(0)[16:]) # outer timer loop
    enable16 = Signal(False)

    @always_comb
    def enable16_gen():
        enable16.next = not bool(enable16_counter)

    @always(clock.posedge)
    def enable16_tick():
        if reset or enable16:
            enable16_counter.next = divisor - 1
        else:
            enable16_counter.next = enable16_counter - 1

    tx_bitcount = Signal(intbv(0)[4:])
    tx_count16 = Signal(intbv(0)[4:])
    txd_reg = Signal(intbv(0)[9:])
    tx_is_busy = Signal(False) # internal busy status

    @always_comb
    def tx_busy_out():
        tx_busy.next = tx_is_busy

    @always(clock.posedge)
    def trans():
        if reset:
            tx_is_busy.next = False
            uart_txd.next = 1
            tx_count16.next = 0
        else:
            if write_en and not tx_is_busy:
                # Load tx data
                txd_reg.next = concat(tx_data[8:], False) # data & start bit '0'
                tx_bitcount.next = 10
                tx_count16.next = 0
                tx_is_busy.next = True
            if enable16:
                # ticking inner timer
                tx_count16.next = (tx_count16 + 1) % 16

                if tx_count16 == 0 and tx_is_busy:
                    tx_bitcount.next = tx_bitcount - 1

                    if tx_bitcount == 0:
                        # transmit finished
                        tx_is_busy.next = False
                    else:
                        uart_txd.next = txd_reg[0]
                        txd_reg.next = concat(True, txd_reg[9:1]) # stop bit '1' & data

    uart_rxd1 = Signal(False)
    uart_rxd2 = Signal(False)
    rx_bitcount = Signal(intbv(0)[4:])
    rx_count16 = Signal(intbv(0)[4:])
    
    rxd_reg = Signal(intbv(0)[8:])
    rx_is_busy = Signal(False)

    @always(clock.posedge)
    def rxd_sync():
        uart_rxd1.next = uart_rxd
        uart_rxd2.next = uart_rxd1

    @always(clock.posedge)
    def recv():
        if reset:
            rx_count16.next = 0
            rx_avail.next = False
            rx_error.next = False
            rx_is_busy.next = False
        else:
            if read_en:
                rx_avail.next = False
                rx_error.next = False
            if enable16:
                if not rx_is_busy:          # look for start bit
                    if not uart_rxd2:       # start bit found
                        rx_is_busy.next = True
                        rx_count16.next = 7 # sample in the middle of the data
                        rx_bitcount.next = 0
                else:
                    rx_count16.next = (rx_count16 + 1) % 16

                    if rx_count16 == 0:     # sample
                        rx_bitcount.next = (rx_bitcount + 1) % 16
                        
                        if rx_bitcount == 0:
                            if uart_rxd2:   # start bit 
                                rx_is_busy.next = False # restart looking
                        elif rx_bitcount == 9:      # final check
                            rx_is_busy.next = False
                            if uart_rxd2:               # stop bit seems ok
                                rx_data.next = rxd_reg
                                rx_avail.next = True
                                rx_error.next = False
                            else:                       # not a stop bit
                                rx_error.next = True
                        else:
                            rxd_reg.next = concat(uart_rxd2, rxd_reg[8:1])

    return instances()

#from lut import ROM
from bram import *
from defines import *
from functions import *

filename_pattern = 'uarttest%s.vmem'
def prepare(size):
    src = open('core.py').read()
    STR = src.replace('\n','\r\n')
    bank = open(filename_pattern % '_one', 'w')
    banks = [open(filename_pattern % i, 'w') for i in range(4)]
    try:
        for i in range((2**size)):
            print >>banks[3-(i%4)], '%02x' % ord(STR[i%(len(STR))])
    finally:
        [f.close() for f in banks]
        
def prepare_one():
    STR = "%16s" % "Hello World!\r\n"
    bank = open(filename_pattern % '_one', 'w')
    for i, c in enumerate(STR):
        print >>bank, '%02x' % ord(c)
    
def uart_test_top(txd_line, rxd_line, debug_txd_line, debug_rxd_line, leds, reset, clock, size=4):
    rx_data = Signal(intbv(0)[32:])
    rx_avail = Signal(False)
    rx_error = Signal(False)
    read_en = Signal(False)
    tx_data = Signal(intbv(0)[32:])
    tx_busy = Signal(False)
    write_en = Signal(False)
    uart_rxd = Signal(False)
    uart_txd = Signal(False)
    addr = Signal(intbv(0)[size:])
    uart = UART(rx_data, rx_avail, rx_error, read_en,
           tx_data, tx_busy, write_en,
           uart_rxd, uart_txd, reset, clock,
           freq_hz=50000000, baud=38400)
    led_reg = Signal(intbv(0)[8:])

    bank_sel = Signal(intbv(0)[4:])
    data_out = Signal(intbv(0)[32:])
    #ram = BRAM(tx_data, rx_data, addr, read_en, write_en, clock, size=4,
                     #filename=filename_pattern % '_one')
    ram = BankedBRAM(data_out, rx_data, addr, bank_sel, write_en, clock,
                     size=size, to_verilog=True,
                     filename_pattern=filename_pattern)
    @always(clock.posedge)
    def say_hello():
        if reset:
            addr.next = 0
            debug_txd_line.next = False
            led_reg.next = 0b10101010
            write_en.next = False
            bank_sel.next = 0
            read_en.next = False
        else:
            debug_txd_line.next = uart_txd
            if not tx_busy:
                write_en.next = True
                tx_data.next = align_mem_load(data_out,
                                              transfer_size_type.WORD,
                                              addr)
            else:
                write_en.next = False
            if write_en and not tx_busy:
                addr.next = (addr +1) % (2**size)
                led_reg.next = ~led_reg

    @always_comb
    def led_out():
        leds.next = led_reg
        txd_line.next = debug_txd_line

    #@always(clock.posedge)
    #def echo():
        #if reset:
            #addr.next = 0
            #txd_line.next = False
            #led_reg.next = 0b10101010
            #write_en.next = False
            #read_en.next = True
            #uart_rxd.next = 1
        #else:
            #txd_line.next = uart_txd
            #uart_rxd.next = rxd_line
            #read_en.next = False

            #if rx_avail:
                #tx_data.next = rx_data
                #write_en.next = True
                #read_en.next = True

            #if write_en and not tx_busy:
                #write_en.next = False
                #led_reg.next = ~led_reg

    return instances()

import sys
from numpy import log2
    
if __name__ == '__main__':
    #rx_data = Signal(intbv(0)[8:])
    #rx_avail = Signal(False)
    #rx_error = Signal(False)
    #read_en = Signal(False)
    #tx_data = Signal(intbv(0)[8:])
    #tx_busy = Signal(False)
    #write_en = Signal(False)
    #uart_rxd = Signal(False)
    #uart_txd = Signal(False)
    #reset = Signal(False)
    #clock = Signal(False)
    #toVHDL(UART, rx_data, rx_avail, rx_error, read_en,
           #tx_data, tx_busy, write_en,
           #uart_rxd, uart_txd, reset, clock,
           #freq_hz=50000000, baud=115200)
    #toVerilog(UART, rx_data, rx_avail, rx_error, read_en,
           #tx_data, tx_busy, write_en,
           #uart_rxd, uart_txd, reset, clock,
           #freq_hz=50000000, baud=115200)
    size = int(log2(int(sys.argv[1]))) if len(sys.argv) > 1 else 4
    print 'size=%s' % size
    prepare(size)
    prepare_one()
    txd_line = Signal(False)
    rxd_line = Signal(False)
    debug_txd_line = Signal(False)
    debug_rxd_line = Signal(False)
    leds = Signal(intbv(0)[8:])
    reset = Signal(False)
    clock = Signal(False)
    #toVHDL(uart_test_top, debug_txd_line, debug_rxd_line, leds, reset, clock)
    toVerilog(uart_test_top, txd_line, rxd_line, debug_txd_line, debug_rxd_line, leds, reset, clock, size=size)


### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

