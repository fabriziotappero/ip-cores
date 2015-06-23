
This core was written by Rudolf Usselmann and downloaded from:

http://opencores.org/project,usb_phy

This core has a bug fix applied related to bitstuffing prior to EOP.

====================================================================

Copyright (C) 2000-2002 Rudolf Usselmann                    
                        www.asics.ws                        
                        rudi@asics.ws                       
                                                            
This source file may be used and distributed without        
restriction provided that this copyright statement is not   
removed from the file and that any derivative work contains 
the original copyright notice and the associated disclaimer.
                                                            
    THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   
FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  
LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         
POSSIBILITY OF SUCH DAMAGE.                                 


USB 1.1 PHY
==========

Status
------
This core is done. It was tested with a USB 1.1 core I have written on
a XESS XCV800 board with a a Philips PDIUSBP11A transceiver.
I have NOT yet tested it with my USB 2.0 Function IP core.

Test Bench
----------
There is no test bench, period !  As I said above I have tested this core
in real hardware and it works just fine.

Documentation
-------------
Sorry, there is none. I just don't have the time to write it. I have tried
to follow the UTMI interface specification from USB 2.0.
'phy_mode' selects between single ended and differential tx_phy output. See
Philips ISP 1105 transceiver data sheet for an explanation of it's MODE
select pin (see Note below).
Currently this PHY only operates in Full-Speed mode. Required clock frequency
is 48MHz, from which the 12MHz USB transmit and receive clocks are derived.

RxError reports the following errors:
  - sync errors
    Could not synchronize to incoming bit stream
  - Bit Stuff Error
    Stuff bit had the wrong value (expected '0' got '1')
  - Byte Error
    Got a EOP (se0) before finished assembling a full byteAll of those errors
    are or'ed together and reported via RxError.

Note:
1) "phy_tx_mode" selects the PHY Transmit Mode:
When phy_tx_mode is '0' the outputs are encoded as:
	txdn, txdp
	 0	0	Differential Logic '0'
	 0	1	Differential Logic '1'
	 1	0	Single Ended '0'
	 1	1	Single Ended '0'

When phy_tx_mode is '1' the outputs are encoded as:
	txdn, txdp
	 0	0	Single Ended '0'
	 0	1	Differential Logic '1'
	 1	0	Differential Logic '0'
	 1	1	Illegal State

See PHILIPS Transceiver Data Sheet for: ISP1105, ISP1106 and ISP1107
for more details.

2) "usb_rst" Indicates a USB Bus Reset (this output is also or'ed with
   the reset input).

Misc
----
The USB 1.1 Phy Project Page is:
http://www.opencores.org/cores/usb_phy

To find out more about me (Rudolf Usselmann), please visit:
http://www.asics.ws

