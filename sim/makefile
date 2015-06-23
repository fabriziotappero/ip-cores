#/* *****************************************************************************
#   * title:         uart_16550_rll module                                      *
#   * description:   RS232 Protocol 16550D uart (mostly supported)              *
#   * languages:     systemVerilog                                              *
#   *                                                                           *
#   * Copyright (C) 2010 miyagi.hiroshi                                         *
#   *                                                                           *
#   * This library is free software; you can redistribute it and/or             *
#   * modify it under the terms of the GNU Lesser General Public                *
#   * License as published by the Free Software Foundation; either              *
#   * version 2.1 of the License, or (at your option) any later version.        *
#   *                                                                           *
#   * This library is distributed in the hope that it will be useful,           *
#   * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
#   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU         *
#   * Lesser General Public License for more details.                           *
#   *                                                                           *
#   * You should have received a copy of the GNU Lesser General Public          *
#   * License along with this library; if not, write to the Free Software       *
#   * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111*1307  USA *
#   *                                                                           *
#   *         ***  GNU LESSER GENERAL PUBLIC LICENSE  ***                       *
#   *           from http://www.gnu.org/licenses/lgpl.txt                       *
#   *****************************************************************************
#   *                            redleaflogic,ltd                               *
#   *                    miyagi.hiroshi@redleaflogic.biz                        *
#   *          $Id: uart_test.sv 108 2010-03-30 02:56:26Z hiroshi $         *
#   ***************************************************************************** */

.SUFFIXES :
.SUFFIXES : .v .sv .vcd .log

all: uart_test.log

align = ALIGN_4B

.sv.log:
	vlog  -f uart_rtl.list -sv +acc=rn +define+${align}+
	vlog  -f uart_be.list  -sv +acc=rn +define+${align}+
	vsim  -i top < modelSim.in
	mv   transcript  uart_test_${align}.log
	mv   uart_16550_rll.dump uart_test_a_${align}.dump

work:
	vlib work

clean:
	- \rm -rf  ./work   *.vcd  *.wlf *.dump *.log


