#!/usr/bin/perl

use strict;

# Create stimulus/test file for 16550/16750 compatible UART cores
#
# Author:   Sebastian Witt
# Date:     06.02.2008
# Version:  1.4
# License:  GPL
#
# History:  1.0 - Initial version
#           1.1 - Update
#           1.2 - FIFO test update
#           1.3 - Automatic flow control tests
#           1.4 - FIFO 64 tests
#


#
# Global control settings
#
use constant CYCLE => 30e-9;            # Cycle time
#use constant CYCLE => 1e-9;             # Cycle time
use constant LOCAL_LOOP     => 1;       # Use UART local loopback
use constant INITREGS       => 1;       # Initialize registers
use constant TEST_CONTROL   => 1;       # Test control lines
use constant TEST_INTERRUPT => 1;       # Test interrupts
use constant TEST_DEFAULT   => 1;       # Test standard modes
use constant TEST_FIFO      => 1;       # Test 64 byte FIFO mode
use constant TEST_FIFO64    => 1;       # Test 64 byte FIFO mode
use constant TEST_AFC       => 1;       # Test automatic flow control
use constant UART_ADDRESS   => 0x3f8;   # UART base address

# Prototypes
sub logmessage($);          # Message
sub uart_write($$);         # Address, Data
sub uart_read($$);          # Address, Expected data
sub uart_setbaudrate($);    # Baudrate
sub uart_eu_send($);        # Send serial data from external UART

##################################################################
# Main process
##################################################################
# Register addresses
use constant {
    RBR => 0x00,
    DLL => 0x00,
    THR => 0x00,
    DLM => 0x01,
    IER => 0x01,
    IIR => 0x02,
    FCR => 0x02,
    LCR => 0x03,
    MCR => 0x04,
    LSR => 0x05,
    MSR => 0x06,
    SCR => 0x07,
};
# Register settings
use constant {
    IER_ERBI    => 0x01,
    IER_ETBEI   => 0x02,
    IER_ELSI    => 0x04,
    IER_EDSSI   => 0x08,
    IIR_IP      => 0x01,
    IIR_NONE    => 0x01,
    IIR_RLSI    => 0x06,
    IIR_RDAI    => 0x04,
    IIR_CTOI    => 0x0C,
    IIR_THRI    => 0x02,
    IIR_MSRI    => 0x00,
    IIR_F64E    => 0x20,
    IIR_FE      => 0xC0,
    FCR_FE      => 0x01,
    FCR_RXFR    => 0x02,
    FCR_TXFR    => 0x04,
    FCR_DMS     => 0x08,
    FCR_F64E    => 0x20,
    FCR_RT1     => 0x00,
    FCR_RT4     => 0x40,
    FCR_RT8     => 0x80,
    FCR_RT14    => 0xC0,
    FCR_RT16    => 0x40,
    FCR_RT32    => 0x80,
    FCR_RT56    => 0xC0,
    LCR_WLS5    => 0x00,
    LCR_WLS6    => 0x01,
    LCR_WLS7    => 0x02,
    LCR_WLS8    => 0x03,
    LCR_STB     => 0x04,
    LCR_PEN     => 0x08,
    LCR_EPS     => 0x10,
    LCR_SP      => 0x20,
    LCR_BC      => 0x40,
    LCR_DLAB    => 0x80,
    MCR_DTR     => 0x01,
    MCR_RTS     => 0x02,
    MCR_OUT1    => 0x04,
    MCR_OUT2    => 0x08,
    MCR_LOOP    => 0x10,
    MCR_AFE     => 0x20,
    LSR_DR      => 0x01,
    LSR_OE      => 0x02,
    LSR_PE      => 0x04,
    LSR_FE      => 0x08,
    LSR_BI      => 0x10,
    LSR_THRE    => 0x20,
    LSR_TEMT    => 0x40,
    LSR_RXFE    => 0x80,
    MSR_DCTS    => 0x01,
    MSR_DDSR    => 0x02,
    MSR_TERI    => 0x04,
    MSR_DDCD    => 0x08,
    MSR_CTS     => 0x10,
    MSR_DSR     => 0x20,
    MSR_RI      => 0x40,
    MSR_DCD     => 0x80,
};

# Baudrate generator clock input period
use constant BAUDGENCLK => 1.8432e6;
# Current DLM/DLL register
my $divisor = 0x0000;

# Shadow registers with default values after reset
my $RBR = 0x00;
my $IER = 0x00;
my $IIR = IIR_IP;
my $FCR = 0x00;
my $LCR = 0x00;
my $MCR = 0x00;
my $LSR = LSR_THRE | LSR_TEMT;
#my $MSR = 0x00;
my $MSR = 0x0F;
my $SCR = 0x00;


# De-assert reset (if available)
waitcycle (10);
print ("#SET 0 1 1 1 1\n");

if (INITREGS) {
    logmessage ("UART: Initializing...");
    uart_write (IER, $IER);
    uart_write (FCR, $FCR);
    uart_write (LCR, $LCR);
    uart_write (MCR, $MCR);
    uart_write (SCR, $SCR);
}

logmessage ("UART: Checking registers after reset...");
uart_read (RBR, $RBR);
uart_read (RBR, $RBR);
uart_read (IER, $IER);
uart_read (IIR, $IIR);
uart_read (LCR, $LCR);
uart_read (MCR, $MCR);
uart_read (LSR, $LSR);
uart_read (MSR, $MSR);
uart_read (SCR, $SCR);

#logmessage ("UART: Checking SCR write/read...");
#for (my $i = 0; $i <= 0x10; $i++) {
#    uart_write (SCR, $i);
#    uart_read (SCR, $i);
#}

if (LOCAL_LOOP) {
    logmessage ("UART: Enabling local LOOP mode...");
    uart_write (MCR, MCR_LOOP);
    uart_read (MCR, MCR_LOOP);
}

uart_setbaudrate (115200);

logmessage ("UART: Enabling interrupts...");
uart_write (IER, IER_ERBI | IER_ETBEI | IER_ELSI | IER_EDSSI);
uart_read  (IER, IER_ERBI | IER_ETBEI | IER_ELSI | IER_EDSSI);
uart_read  (IIR, IIR_THRI);
uart_read  (IIR, IIR_NONE);

sub uart_check_control_lines ()
{
    logmessage ("UART: Checking control lines...");
    uart_write (MCR, $MCR | MCR_DTR);
    uart_read  (MCR, $MCR);
    uart_read  (IIR, IIR_MSRI);
    uart_read  (MSR, MSR_DSR | MSR_DDSR);
    uart_read  (MSR, MSR_DSR);
    uart_read  (IIR, IIR_NONE);
    uart_write (MCR, $MCR | MCR_RTS);
    uart_read  (MCR, $MCR);
    uart_read  (IIR, IIR_MSRI);
    uart_read  (MSR, MSR_CTS | MSR_DSR | MSR_DCTS);
    uart_read  (MSR, MSR_CTS | MSR_DSR);
    uart_read  (IIR, IIR_NONE);
    uart_write (MCR, $MCR | MCR_OUT1);
    uart_read  (MCR, $MCR);
    uart_read  (MSR, MSR_CTS | MSR_DSR | MSR_RI);
    uart_read  (IIR, IIR_NONE);
    uart_write (MCR, $MCR & ~MCR_OUT1);
    uart_read  (MCR, $MCR);
    uart_read  (IIR, IIR_MSRI);
    uart_read  (MSR, MSR_CTS | MSR_DSR | MSR_TERI);
    uart_read  (IIR, IIR_NONE);
    uart_read  (MSR, MSR_CTS | MSR_DSR);
    uart_write (MCR, $MCR | MCR_OUT2);
    uart_read  (MCR, $MCR);
    uart_read  (IIR, IIR_MSRI);
    uart_read  (MSR, MSR_CTS | MSR_DSR | MSR_DCD | MSR_DDCD);
    uart_read  (MSR, MSR_CTS | MSR_DSR | MSR_DCD);
    uart_read  (IIR, IIR_NONE);
    uart_write (MCR, $MCR & ~(MCR_DTR | MCR_RTS | MCR_OUT1 | MCR_OUT2));
    uart_read  (MCR, $MCR);
    uart_read  (IIR, IIR_MSRI);
    uart_read  (MSR, MSR_DDSR | MSR_DCTS | MSR_DDCD);
    uart_read  (IIR, IIR_NONE);
}

sub uart_check_interrupt_control ()
{
    logmessage ("UART: Checking interrupt priority control...");
    uart_write (MCR, $MCR | MCR_DTR);
    uart_write (MCR, $MCR & ~MCR_DTR);
    uart_write (THR, 0x12);
    uart_wait (1);
    uart_write (LCR, $LCR | LCR_BC);
    uart_wait (1);
    uart_write (LCR, $LCR & ~LCR_BC);
    uart_read  (IIR, IIR_RLSI);
    uart_read  (LSR, LSR_DR | LSR_OE | LSR_BI | LSR_FE | LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_RDAI);
    uart_read  (IIR, IIR_RDAI);
    uart_rrbr  (0x00);
    uart_write (THR, 0x34);
    uart_wait (1);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_write (THR, 0x56);
    uart_read  (IIR, IIR_RDAI);
    uart_wait (1);
    uart_read  (IIR, IIR_RLSI);
    uart_read  (LSR, LSR_DR | LSR_OE | LSR_THRE | LSR_TEMT);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_RDAI);
    uart_rrbr  (0x56);
    uart_read  (IIR, IIR_THRI);
    uart_read  (IIR, IIR_MSRI);
    uart_read  (IIR, IIR_MSRI);
    uart_read  (MSR, MSR_DDSR);
    uart_read  (IIR, IIR_NONE);
    uart_write (THR, 0x78);
    uart_wait (1);
    uart_read  (IIR, IIR_RDAI);
    uart_rrbr  (0x78);
    uart_read  (IIR, IIR_THRI);
    uart_read  (IIR, IIR_NONE);
}

sub uart_check_default ()
{
    for (my $mode = 0; $mode < 0x40; $mode++) {
        logmessage (sprintf ("UART: Setting LCR to 0x%02X", $mode));
        uart_write (LCR, $mode);

        logmessage ("UART: Transmission test single byte (FIFO disabled)");
        uart_wait (1);
        uart_write (THR, 0x55);
        uart_wait (1);
        uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
        uart_read  (IIR, IIR_RDAI);
        uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
        uart_rrbr  (0x55);
        uart_read  (LSR, LSR_THRE | LSR_TEMT);
        uart_read  (IIR, IIR_THRI);
        uart_read  (IIR, IIR_NONE);

        logmessage ("UART: Transmission test multiple bytes (FIFO disabled)");
        for (my $i = 0; $i < 10; $i++) {
            uart_read  (IIR, IIR_NONE);
            uart_write (THR, $i);
            uart_wait (1);
            uart_read  (IIR, IIR_RDAI);
            uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
            uart_rrbr  ($i);
            uart_read  (IIR, IIR_THRI);
            uart_read  (LSR, LSR_THRE | LSR_TEMT);
        }

        #logmessage ("UART: Transmission test loop (FIFO disabled)");
        #for (my $i = 0; $i < 1000; $i++) {
        #    if (!($i % 100)) {
        #        logmessage ("UART:   Loop " . $i);
        #    }
        #    uart_write (THR, $i);
        #    uart_read  (IIR, IIR_THRI);
        #    uart_wait (1);
        #    uart_read  (IIR, IIR_RDAI);
        #    uart_rrbr  ($i);
        #    uart_read  (IIR, IIR_NONE);
        #}

        logmessage ("UART: Transmission test overflow (FIFO disabled)");
        uart_write (THR, 0x55);
        uart_wait (1);
        uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
        uart_read  (IIR, IIR_RDAI);
        uart_write (THR, 0xAA);
        uart_wait (1);
        uart_read  (IIR, IIR_RLSI);
        uart_read  (LSR, LSR_DR | LSR_OE | LSR_THRE | LSR_TEMT);
        uart_read  (IIR, IIR_RDAI);
        uart_wait (1);
        uart_read  (IIR, IIR_RDAI);
        uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
        uart_rrbr  (0xAA);
        uart_read  (LSR, LSR_THRE | LSR_TEMT);
        uart_read  (IIR, IIR_THRI);
        uart_read  (IIR, IIR_NONE);

        logmessage ("UART: Break control test");
        uart_write (LCR, $LCR | LCR_BC);
        uart_read  (LCR, $LCR);
        uart_wait (2);
        uart_read  (IIR, IIR_RLSI);
        if (($LCR & LCR_PEN) && !($LCR & LCR_EPS)) {
            uart_read (LSR, LSR_DR | LSR_PE | LSR_FE | LSR_BI | LSR_THRE | LSR_TEMT);
        } else {
            uart_read (LSR, LSR_DR |          LSR_FE | LSR_BI | LSR_THRE | LSR_TEMT);
        }
        uart_read  (IIR, IIR_RDAI);
        uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
        uart_read  (RBR, 0x00);
        uart_read  (IIR, IIR_NONE);
        uart_read  (LSR, LSR_THRE | LSR_TEMT);
        uart_write (LCR, $LCR & ~LCR_BC);
        uart_read  (LCR, $LCR);
        uart_wait (2);
        uart_read  (LSR, LSR_THRE | LSR_TEMT);
        uart_read  (IIR, IIR_NONE);
    }

    uart_write (LCR, 0x00);
}

sub uart_check_fifo ()
{
    logmessage ("UART: Enabling FIFO...");
    uart_write (FCR, FCR_FE);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (IIR, IIR_NONE | IIR_FE);

    logmessage ("UART: Testing FIFO trigger level 1 byte...");
    uart_write (FCR, FCR_FE | FCR_RT1);
    uart_send  (1);
    uart_wait  (4);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE);

    logmessage ("UART: Testing FIFO trigger level 4 byte...");
    uart_write (FCR, FCR_FE | FCR_RT4);
    uart_send  (3);
    uart_wait  (7);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_send  (2);
    uart_wait  (6);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_wait  (2);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (1);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_rrbr  (2);
    uart_rrbr  (0);
    uart_rrbr  (1);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE);

    logmessage ("UART: Testing FIFO trigger level 8 byte...");
    uart_write (FCR, FCR_FE | FCR_RT8);
    uart_send  (7);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_wait  (11);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_send  (2);
    uart_wait  (6);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_wait  (2);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (1);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_rrbr  (2);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (3);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (4);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (5);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (6);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (1);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE);

    logmessage ("UART: Testing FIFO trigger level 14 byte...");
    uart_write (FCR, FCR_FE | FCR_RT14);
    uart_send  (13);
    uart_wait  (17);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_send  (2);
    uart_wait  (6);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (1);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_rrbr  (2);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (3);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (4);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (5);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (6);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (7);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (8);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (9);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (10);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (11);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (12);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (1);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE);

    logmessage ("UART: Testing FIFO overrun...");
    uart_write (FCR, FCR_FE | FCR_RT1);
    uart_send  (17);
    uart_wait  (17);
    uart_read  (IIR, IIR_RLSI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_OE | LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_RDAI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_write (FCR, FCR_FE | FCR_RXFR);
    uart_wait  (1);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (IIR, IIR_NONE | IIR_FE);

    logmessage ("UART: Miscellaneous FIFO tests...");
    uart_write (LCR, 0x03);
    uart_write (IER, IER_ERBI);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_write (FCR, FCR_FE | FCR_RT14);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    logmessage ("UART: Sending 8 words");
    uart_send  (8);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_wait  (12);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    logmessage ("UART: Receiving 8 words");
    uart_recv  (8, 0);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    logmessage ("UART: Sending 16 words");
    uart_send  (16);
    uart_wait  (4);
    logmessage ("UART: Receiving 4 words");
    uart_recv  (4, 0);
    logmessage ("UART: Sending 4 words");
    uart_send  (4);
    uart_wait  (12);
    logmessage ("UART: Receiving 12 words");
    uart_recv  (12, 4);
    uart_wait  (8);
    logmessage ("UART: Receiving 2 words");
    uart_recv  (2, 0);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    logmessage ("UART: Sending 40 words");
    uart_send  (40);
    uart_wait  (4);
    uart_read  (LSR, LSR_DR);
    uart_wait  (20);
    uart_read  (LSR, LSR_DR | LSR_OE | LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    logmessage ("UART: Receiving 3 words");
    uart_recv  (2, 2);
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    logmessage ("UART: Receiving 13 words");
    uart_recv  (13, 1);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE);

    logmessage ("UART: Testing FIFO error counter...");
    uart_write (IER, IER_ERBI | IER_ELSI);
    logmessage ("UART: Sending 2 words");
    uart_send  (2);
    uart_wait  (2);
    logmessage ("UART: Sending break");
    uart_write (LCR, $LCR | LCR_BC);
    uart_wait  (1);
    uart_write (LCR, $LCR & ~LCR_BC);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    logmessage ("UART: Sending 4 words");
    uart_send  (4);
    uart_wait  (4);
    logmessage ("UART: Sending break");
    uart_write (LCR, $LCR | LCR_BC);
    uart_wait  (1);
    uart_write (LCR, $LCR & ~LCR_BC);
    logmessage ("UART: Sending 2 words");
    uart_send  (2);
    uart_wait  (6);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    logmessage ("UART: Reading 2 words");
    uart_rrbr  (0x00);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_rrbr  (0x01);
    uart_wait  (1);
    uart_read  (IIR, IIR_RLSI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_FE | LSR_BI | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    logmessage ("UART: Reading break word");
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    logmessage ("UART: Reading 4 words");
    uart_rrbr  (0x00);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_rrbr  (0x01);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_rrbr  (0x02);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_rrbr  (0x03);
    uart_wait  (1);
    uart_read  (IIR, IIR_RLSI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_FE | LSR_BI | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    logmessage ("UART: Reading break word");
    uart_rrbr  (0x00);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x01);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);

    logmessage ("UART: Sending break");
    uart_write (LCR, $LCR | LCR_BC);
    uart_wait  (1);
    uart_write (LCR, $LCR & ~LCR_BC);
    uart_read  (IIR, IIR_RLSI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_FE | LSR_BI | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT | LSR_RXFE);
    logmessage ("UART: Reading break word");
    uart_rrbr  (0x00);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);

    logmessage ("UART: FIFO test end");
}

sub uart_check_fifo64 ()
{
    logmessage ("UART: Testing FIFO in 64 byte mode...");
    uart_write (IER, IER_ERBI | IER_ETBEI | IER_ELSI | IER_EDSSI);
    uart_write (FCR, FCR_F64E | FCR_FE | FCR_RXFR | FCR_TXFR);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_write (LCR, $LCR | LCR_DLAB);
    uart_write (FCR, FCR_F64E | FCR_FE);
    uart_write (LCR, $LCR & ~LCR_DLAB);
    uart_read  (IIR, IIR_NONE | IIR_FE | IIR_F64E);

    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    logmessage ("UART: Testing FIFO trigger level 1 byte...");
    uart_write (FCR, FCR_FE | FCR_RT1);
    uart_read  (IIR, IIR_NONE | IIR_FE | IIR_F64E);
    uart_send  (1);
    uart_wait  (4);
    uart_read  (IIR, IIR_CTOI | IIR_FE | IIR_F64E);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_THRI | IIR_FE | IIR_F64E);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE | IIR_F64E);

    logmessage ("UART: Testing FIFO trigger level 16 byte...");
    uart_write (FCR, FCR_FE | FCR_RT16);
    uart_send  (15);
    uart_wait  (15);
    uart_read  (IIR, IIR_CTOI | IIR_FE | IIR_F64E);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_THRI | IIR_FE | IIR_F64E);
    uart_read  (IIR, IIR_NONE | IIR_FE | IIR_F64E);
    uart_send  (3);
    uart_wait  (3);
    uart_read  (IIR, IIR_RDAI | IIR_FE | IIR_F64E);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x01);
    uart_read  (IIR, IIR_RDAI | IIR_FE | IIR_F64E);
    uart_rrbr  (0x02);
    uart_read  (IIR, IIR_THRI | IIR_FE | IIR_F64E);
    uart_recv  (12, 3);
    uart_recv  (3);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE | IIR_F64E);

    logmessage ("UART: Testing FIFO trigger level 32 byte...");
    uart_write (FCR, FCR_FE | FCR_RT32);
    uart_send  (31);
    uart_wait  (31);
    uart_read  (IIR, IIR_CTOI | IIR_FE | IIR_F64E);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_THRI | IIR_FE | IIR_F64E);
    uart_read  (IIR, IIR_NONE | IIR_FE | IIR_F64E);
    uart_send  (3);
    uart_wait  (3);
    uart_read  (IIR, IIR_RDAI | IIR_FE | IIR_F64E);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x01);
    uart_read  (IIR, IIR_RDAI | IIR_FE | IIR_F64E);
    uart_rrbr  (0x02);
    uart_read  (IIR, IIR_THRI | IIR_FE | IIR_F64E);
    uart_recv  (28, 3);
    uart_recv  (3);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE | IIR_F64E);

    logmessage ("UART: Testing FIFO trigger level 56 byte...");
    uart_write (FCR, FCR_FE | FCR_RT56);
    uart_send  (55);
    uart_wait  (55);
    uart_read  (IIR, IIR_CTOI | IIR_FE | IIR_F64E);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x00);
    uart_read  (IIR, IIR_THRI | IIR_FE | IIR_F64E);
    uart_read  (IIR, IIR_NONE | IIR_FE | IIR_F64E);
    uart_send  (3);
    uart_wait  (3);
    uart_read  (IIR, IIR_RDAI | IIR_FE | IIR_F64E);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_rrbr  (0x01);
    uart_read  (IIR, IIR_RDAI | IIR_FE | IIR_F64E);
    uart_rrbr  (0x02);
    uart_read  (IIR, IIR_THRI | IIR_FE | IIR_F64E);
    uart_recv  (52, 3);
    uart_recv  (3);
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_NONE | IIR_FE | IIR_F64E);

    uart_write (LCR, $LCR | LCR_DLAB);
    uart_write (FCR, $FCR & ~FCR_F64E);
    uart_write (LCR, $LCR & ~LCR_DLAB);
    uart_read  (IIR, IIR_NONE | IIR_FE);

    logmessage ("UART: FIFO64 test end");
}

sub uart_check_afc ()
{
    logmessage ("UART: Automatic flow control test");
    uart_write (LCR, LCR_WLS8);
    uart_read  (LCR, LCR_WLS8);
    uart_write (IER, IER_ERBI | IER_ETBEI | IER_ELSI | IER_EDSSI);
    uart_read  (IER, IER_ERBI | IER_ETBEI | IER_ELSI | IER_EDSSI);
    logmessage ("UART: Setting FIFO trigger level to 4 bytes");
    uart_write (FCR, FCR_FE | FCR_RT4);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    logmessage ("UART: Enabling Auto-CTS");
    uart_write (MCR, ($MCR & ~(MCR_DTR | MCR_RTS | MCR_OUT1 | MCR_OUT2)) | MCR_AFE);
    uart_read  (MSR, 0);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    logmessage ("UART: Send 3 words");
    uart_send  (3);
    uart_wait  (6);
    logmessage ("UART: Expecting no data was sent");
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_read  (LSR, 0);
    logmessage ("UART: Enabling Auto-RTS");
    uart_write (MCR, $MCR | MCR_RTS);
    logmessage ("UART: Check if CTS is enabled");
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_read  (MSR, MSR_DCTS | MSR_CTS);
    uart_wait  (8);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    logmessage ("UART: Check if CTS is enabled");
    uart_read  (MSR, MSR_CTS);
    logmessage ("UART: Send 1 word");
    uart_send  (1);
    uart_wait  (2);
    logmessage ("UART: Check if CTS is disabled");
    uart_read  (MSR, MSR_DCTS);
    logmessage ("UART: Check LSR");
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_CTOI | IIR_FE);
    logmessage ("UART: Receive 3 words");
    uart_recv  (3);
    logmessage ("UART: Check if CTS is disabled");
    uart_read  (MSR, 0);
    logmessage ("UART: Receive 1 word");
    uart_recv  (1);
    logmessage ("UART: Check LSR");
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    logmessage ("UART: Check if CTS is enabled again");
    uart_read  (MSR, MSR_DCTS | MSR_CTS);
    logmessage ("UART: Send 6 words");
    uart_send  (5);
    uart_send  (1);
    uart_wait  (4);
    logmessage ("UART: Check if CTS is disabled");
    uart_read  (MSR, MSR_DCTS);
    logmessage ("UART: Check LSR");
    uart_read  (LSR, LSR_DR);
    uart_wait  (1);
    logmessage ("UART: Receive 5 words");
    uart_recv  (5);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_wait  (2);
    logmessage ("UART: Check LSR");
    uart_read  (LSR, LSR_DR | LSR_THRE | LSR_TEMT);
    logmessage ("UART: Check if CTS is enabled again");
    uart_read  (MSR, MSR_DCTS | MSR_CTS);
    logmessage ("UART: Receive 1 words");
    uart_recv  (1);
    logmessage ("UART: Check LSR");
    uart_read  (LSR, LSR_THRE | LSR_TEMT);
    uart_read  (IIR, IIR_THRI | IIR_FE);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    logmessage ("UART: Check if CTS is enabled");
    uart_read  (MSR, MSR_CTS);
    logmessage ("UART: Disable Automatic flow control");
    uart_write (MCR, $MCR & ~(MCR_DTR | MCR_RTS | MCR_OUT1 | MCR_OUT2 | MCR_AFE));
    uart_read  (MSR, MSR_DCTS);
    uart_read  (IIR, IIR_NONE | IIR_FE);
    uart_read  (MCR, $MCR);
    logmessage ("UART: Automatic flow control test finished");
}

if (TEST_CONTROL) {
    uart_check_control_lines ();
}
if (TEST_INTERRUPT) {
    uart_check_interrupt_control ();
}
if (TEST_DEFAULT) {
    uart_check_default ();
}
if (TEST_FIFO) {
    uart_check_fifo ();
}
if (TEST_FIFO64) {
    uart_check_fifo64 ();
}
if (TEST_AFC) {
    uart_check_afc ();
}

##################################################################
# End main process
##################################################################



##################################################################
# Sub functions
##################################################################

# Convert number to binary string
sub num2binary($$)
{
  my($num) = @_;
  my $binary = $num ? '' : '0';    # in case $num is zero
  my $len = $_[1];
  my $result;

  while ($num) {
    $binary .= $num & 1 ? 1 : 0;  # do the LSB
    $num >>= 1;                   # on to the next bit
  }

  $result = scalar reverse $binary;
  while (length($result)<$len) {
    $result = "0".$result;
  }

  return $result;
}


# Insert wait cycles
sub waitcycle($)
{
    printf ("#WAIT %d\n", $_[0]);
    #printf ("DE %d\n", $_[0]+5);
}

# Log message
sub logmessage($)
{
    print "#LOG $_[0]\n";
    #print "LO $_[0]\n";
}

# Read from UART
sub uart_read($$)
{
    printf ("#RD %s %s\n", num2binary ($_[0] & 7, 3), num2binary ($_[1] & 0xFF, 8));
    #printf ("IR 0x%04X 0x%02X\n", UART_ADDRESS + ($_[0] & 7), $_[1] & 0xFF);
}

# Filter read from RBR (mask word length)
sub uart_rrbr($)
{
    my $wls  = $LCR & 0x03;
    my $data = $_[0];

    if ($wls == 0x00) { $data &= 0x1F; }
    if ($wls == 0x01) { $data &= 0x3F; }
    if ($wls == 0x02) { $data &= 0x7F; }
    uart_read (RBR, $data);
}

# Write to UART
sub uart_write($$)
{
    # Shadow register writes to local copy
    SWITCH: {
        if ($_[0] == THR) { $RBR = $_[1]; last SWITCH; }
        if ($_[0] == IER) { $IER = $_[1]; last SWITCH; }
        if ($_[0] == FCR) { $FCR = $_[1]; last SWITCH; }
        if ($_[0] == LCR) { $LCR = $_[1]; last SWITCH; }
        if ($_[0] == MCR) { $MCR = $_[1]; last SWITCH; }
        if ($_[0] == SCR) { $SCR = $_[1]; last SWITCH; }
    }

    printf ("#WR %s %s\n", num2binary ($_[0] & 7, 3), num2binary ($_[1] & 0xFF, 8));
    #printf ("IW 0x%04X 0x%02X\n", UART_ADDRESS + ($_[0] & 7), $_[1] & 0xFF);
}

# Set UART baudrate
sub uart_setbaudrate($)
{
    logmessage ("UART: Setting baudrate to $_[0]");
    $divisor = BAUDGENCLK / (16 * $_[0]);
    uart_write (LCR, $LCR | LCR_DLAB);
    uart_write (DLL, $divisor);
    uart_write (DLM, $divisor >> 8);
    uart_read  (LCR, $LCR);
    uart_read  (DLL, $divisor);
    uart_read  (DLM, $divisor >> 8);
    uart_write (LCR, $LCR & ~LCR_DLAB);
    uart_read  (LCR, $LCR);
}

# Wait until n words are transmitted/received
sub uart_wait ($)
{
    my $steps  = 1;                         # Start bit
       $steps += 5 + ($LCR & 0x03);         # Data
       $steps += $LCR & LCR_PEN ? 1 : 0;    # Parity
       $steps += $LCR & LCR_STB ? 2 : 1;    # Stop bit
       $steps += 2;                         # Extra delay

    my $txtime = $_[0]*$steps*($divisor*16)/BAUDGENCLK;
    waitcycle ($txtime/CYCLE);
}

# Send n bytes
sub uart_send ($)
{
    for (my $i = 0; $i < $_[0]; $i++) {
        uart_write (THR, $i);
        if (!($FCR & FCR_FE)) {
            uart_wait  (1);
        }
    }
}

# Receive n bytes
sub uart_recv ($$)
{
    for (my $i = 0; $i < $_[0]; $i++) {
        uart_rrbr ($i + $_[1]);
    }
}

# Send serial data from external UART
sub uart_eu_send($)
{
    printf ("#EUS  8 %d\n", $_[0]);
}

