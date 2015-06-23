# $Id: nexys4_pclk.xdc 640 2015-02-01 09:56:53Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Primary clocks for Nexys4
#
# Revision History: 
# Date         Rev Version  Comment
# 2015-01-25   639   1.0    Initial version
#

create_clock -name I_CLK100 -period 10 -waveform {0 5} [get_ports I_CLK100]
