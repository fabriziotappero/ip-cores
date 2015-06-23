-------------------------------
-- HIBI has a genric called
--    fifo_sel_g 
-- which affects which fifo and synchroniaztion are implemented
--
-- Ari Kulmala (a long long time ago :)
-------------------------------

mostly  changes things in double_fifo... vhds

Clock goes in the following way:

-- 0 synch multiclk
* uses multiclk_fifo
*ps (synch) clocks not used

-- 1 basic GALS 2FF synchronizer
pulsed clocks used in the synchronizer interface.
pulsed clock should be integer multiples of the actual clock,
period 50/50
(1 is ok, i.e. using the same clock for pulsed and regular)
HIBI is always in the synchronous side of the FIFO, IP writes through
asnchronous links

pulsed clocks should always be assigned!

-- 2 Gray FIFO (depth=2^n!),
pulsed clocks not used
uses cdc_fifo

-- 3 mixed clock pausible
pulsed clocks have to be clock that implement a pulse that is around
the rising edge corner of the corresponding regular clock.

i.e. (use courier font)

bus_clk          _______|^^^^^^^^^^|________|^^^^^^^^^^|
bus_pulsed    ________|^^^|_______________|^^^|______
