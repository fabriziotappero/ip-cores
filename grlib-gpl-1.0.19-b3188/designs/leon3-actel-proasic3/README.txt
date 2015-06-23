
LEON3 on Actel CoreMP7 board, README file v1.0
==============================================

* Clocking

The leon3 design uses the Proasic3 PLL to divide the 48 MHz
clock to a lower frequency. For this to work, jumper JP42
must be set to enable the power to the VCCPLF. The board
is shipped with this jumper in 'off' mode, thereby inhibiting
the PLL.

Some useful PLL parameters:

FREQ    MUL   DIV   ODIV
 20      15    9     4
 25      25   12     4
 30      45    9     8
 32       6    9     1
 34      51    9     8
 35      35    12    4

* Serial ports

The DSU UART is connected to serial port 1 (P3 connector)
while the console UART (APB) is connected to P2.

* SSRAM

The SSRAM can be interfaced with the SSRCTRL sync-ram controller,
or the leon2 async-sram MCTRL memory controller. If SSRCTRL is
used, the J49 must be open to run the SSRAM in pipeline mode.
If the MCTRL is used, J49 should be closed and zero-waitstates
should be used in MCTRL.

* Synthesis

Synthesis has been done with Synplify-9.2. It is IMPERATIVE
that retiming is NOT enabled, or a corrupt netlist will be created.
Maximum frequency is in the range of 30 - 35 MHz, depending on
the processor configuartion (using STD device timing).

* Simulation

It is not possible to simulate the test bench since the GSI SSRAM models
do not support data pre-loading.

