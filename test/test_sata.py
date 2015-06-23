# Simple tests for an adder module
import cocotb
from cocotb.result import TestFailure
#from cocotb.triggers import Timer, RisingEdge
from sata_model import SataController
#import random

CLK_PERIOD = 4

@cocotb.test(skip = True)
def bootup_test(dut):
    """
    Description:
        Bootup the SATA stack

    Test ID: 0

    Expected Results:
        The SATA stack should be ready and in the IDLE state
    """
    dut.test_id = 0
    sata = SataController(dut, CLK_PERIOD)
    yield(sata.reset())

    #yield(sata.wait_for_idle()0))
    yield(sata.wait_for_idle())
    if not sata.ready():
        dut.log.error("Sata Is not ready")
        TestFailure()
    else:
        dut.log.info("Sata is Ready")


@cocotb.test(skip = True)
def short_write_test(dut):
    """
    Description:
        Perform a single write to the SATA stack

    Test ID: 1

    Expected Results:
        Data and Addressed should be read from the
        fake hard drive
    """
    dut.test_id = 1
    sata = SataController(dut, CLK_PERIOD)
    yield(sata.reset())

    yield(sata.wait_for_idle())
    yield(sata.write_to_hard_drive(10, 0x00))
    yield(sata.wait_clocks(100))

    dut.log.info("Wrote 1 piece of data to SATA")


@cocotb.test(skip = True)
def short_read_test(dut):
    """
    Description:
        Perform a single read from the SATA stack
    Test ID: 2
    Expected Result:
        -Address should be seen on the fake hard drive side
        -Data should be read out of the hard drive
    """
    dut.test_id = 2
    sata = SataController(dut, CLK_PERIOD)
    yield(sata.reset())

    yield(sata.wait_for_idle())
    yield(sata.read_from_hard_drive(10, 0x00))
    yield(sata.wait_clocks(10))

    yield(sata.wait_for_idle())
    yield(sata.wait_clocks(200))


@cocotb.test(skip = True)
def long_write_test(dut):
    """
    Description:
        Perform a long write to the hard drive
    Test ID: 3
    Expected Result:
        -Address should be seen on the fake hard drive side
        -Data should be read out of the hard drive side
        -Number of data should be the same as the write amount
    """
    dut.test_id = 3
    data_count = 400
    sata = SataController(dut, CLK_PERIOD)
    yield(sata.reset())

    yield(sata.wait_for_idle())
    yield(sata.write_to_hard_drive(data_count, 0x00))
    yield(sata.wait_clocks(100))

    dut.log.info("Wrote %d piece of data to SATA" % data_count)


@cocotb.test(skip = True)
def long_read_test(dut):
    """
    Description:
        Perform a long read from the hard drive
    Test ID: 4
    Expected Result:
        -Address should be seen on the fake hard drive side
        -Data should be written in to the hard drive side
        -Data should be read out of the stack side
        -The length of data that is read should be the same as the
            data entered into the hard drive
    """
    dut.test_id = 4
    sata = SataController(dut, CLK_PERIOD)
    yield(sata.reset())

    yield(sata.wait_for_idle())
    yield(sata.read_from_hard_drive(0x900, 0x00))
    yield(sata.wait_clocks(10))

    yield(sata.wait_for_idle())
    yield(sata.wait_clocks(100))

@cocotb.test(skip = True)
def long_write_with_easy_back_preassure_test(dut):
    """
    Description:
        Perform a long write to the hard drive and simulate a stall condition
    Test ID: 5
    Expected Result:
        -Address should be seen on the fake hard drive side
        -Data should be read out of the hard drive side
        -Length of data read should be the same as the length of data written
    """
    dut.test_id = 5
    sata = SataController(dut, CLK_PERIOD)
    yield(sata.reset())
    yield(sata.wait_for_idle())

    length = 400
    address = 0x00

    dut.write_count = length
    dut.write_enable = 1
    dut.u2h_write_enable = 1
    dut.u2h_write_count = length
    #dut.h2u_read_enable = 1
    dut.sector_address = address
    #What does this do?
    dut.sector_count = 0
    dut.write_data_en = 1
    yield(sata.wait_clocks(1))
    dut.write_data_en = 0
    yield(sata.wait_clocks(200))
    dut.hold = 1
    yield(sata.wait_clocks(200))
    dut.hold = 0
    yield(sata.wait_clocks(400))
    dut.hold = 1
    yield(sata.wait_clocks(300))
    dut.hold = 0
    yield(sata.wait_for_idle())

    dut.write_enable = 0
    dut.write_count = 0
    yield(sata.wait_clocks(100))
    #dut.h2u_read_enable = 0
    dut.log.info("Wrote %d piece of data to SATA" % length)

@cocotb.test(skip = True)
def long_write_with_hard_back_preassure_test(dut):
    """
    Description:
        Perform a long write to the hard drive and simulate difficult
        stall condition
    Test ID: 7
    Expected Result:
        -Address should be seen on the fake hard drive side
        -Data should be read out of the hard drive
        -Length of data in should be equal to the length of data read
    """
    dut.test_id = 7
    sata = SataController(dut, CLK_PERIOD)
    yield(sata.reset())
    yield(sata.wait_for_idle())

    length = 9000
    address = 0x00

    dut.write_count = length
    dut.write_enable = 1
    dut.u2h_write_enable = 1
    dut.u2h_write_count = length
    #dut.h2u_read_enable = 1
    dut.sector_address = address
    #What does this do?
    dut.sector_count = 0
    dut.write_data_en = 1
    yield(sata.wait_clocks(1))
    dut.write_data_en = 0
    yield(sata.wait_clocks(2500))
    dut.hold = 1
    yield(sata.wait_clocks(1))
    dut.hold = 0
    yield(sata.wait_clocks(400))
    dut.hold = 1
    yield(sata.wait_clocks(10))
    dut.hold = 0
    yield(sata.wait_clocks(400))
    dut.hold = 1
    yield(sata.wait_clocks(20))
    dut.hold = 0
    yield(sata.wait_clocks(400))
    dut.hold = 1
    yield(sata.wait_clocks(1))
    dut.hold = 0

    yield(sata.wait_for_idle())

    dut.write_enable = 0
    dut.write_count = 0
    yield(sata.wait_clocks(100))
    #dut.h2u_read_enable = 0
    dut.log.info("Wrote %d piece of data to SATA" % length)

@cocotb.test(skip = False)
def long_write_long_read_back_preassure_test(dut):
    """
    Description:
        Perform a long write to the hard drive and simulate difficult
        stall condition, then start a new long read transaction
    Test ID: 8
    Expected Result:
        -Address should be seen on the fake hard drive side
        -Data should be read out of the hard drive
        -Length of data in should be equal to the length of data read
    """
    dut.test_id = 8
    sata = SataController(dut, CLK_PERIOD)
    yield(sata.reset())
    yield(sata.wait_for_idle())

    length = 9000
    address = 0x00

    dut.write_count = length
    dut.write_enable = 1
    dut.u2h_write_enable = 1
    dut.u2h_write_count = length
    #dut.h2u_read_enable = 1
    dut.sector_address = address
    #What does this do?
    dut.sector_count = 0
    dut.write_data_en = 1
    yield(sata.wait_clocks(1))
    dut.write_data_en = 0
    yield(sata.wait_clocks(2500))
    dut.hold = 1
    yield(sata.wait_clocks(1))
    dut.hold = 0
    yield(sata.wait_clocks(400))
    dut.hold = 1
    yield(sata.wait_clocks(10))
    dut.hold = 0
    yield(sata.wait_clocks(400))
    dut.hold = 1
    yield(sata.wait_clocks(20))
    dut.hold = 0
    yield(sata.wait_clocks(400))
    dut.hold = 1
    yield(sata.wait_clocks(1))
    dut.hold = 0

    yield(sata.wait_for_idle())

    dut.write_enable = 0
    dut.write_count = 0
    yield(sata.wait_clocks(100))
    #dut.h2u_read_enable = 0
    dut.log.info("Wrote %d piece of data to SATA" % length)

    data_count = 0x900
    yield(sata.read_from_hard_drive(data_count, 0x00))
    yield(sata.wait_clocks(10))

    yield(sata.wait_for_idle())
    yield(sata.wait_clocks(100))
    dut.log.info("Read %d words of data" % data_count)


    data_count = 400
    yield(sata.write_to_hard_drive(data_count, 0x00))
    yield(sata.wait_clocks(200))

    dut.log.info("Wrote %d piece of data to SATA" % data_count)



