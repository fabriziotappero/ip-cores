from myhdl import toVHDL, Signal
from misc import delayer

clk = Signal(bool(0))
rst = Signal(bool(0))
d = Signal(bool(0))
q = Signal(bool(0))

synthesis_i0 = toVHDL(delayer, clk, rst, d, q)
