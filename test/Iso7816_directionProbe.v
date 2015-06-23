`timescale 1ns / 1ps
`default_nettype none
/*
Author: Sebastien Riou (acapola)
Creation date: 17:14:04 01/29/2011 

$LastChangedDate: 2011-01-29 13:16:17 +0100 (Sat, 29 Jan 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 11 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/Iso7816_directionProbe.v $				 

This file is under the BSD licence:
Copyright (c) 2011, Sebastien Riou

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
The names of contributors may not be used to endorse or promote products derived from this software without specific prior written permission. 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
`default_nettype none
/*
Models a probe which consist only of wires. Propagation delay over the sio line
is used to determined the direction of the communication:
If the terminal send a start bit, the termMon output will go low before cardMon and viceversa:

                   sio line
Terminal ---------------------------------- Card
           |                            |
			  |                            |
			  termMon                      cardMon

Note for a physical implementation:
The difference between the delay "Terminal to termMon" and the delay "Card to cardMon"
should be kept small in comparison to the delay "Terminal to/from Card" (considering falling edge delay)

In this model, delays are 0 except the delay over the sio line. 
*/
module Iso7816_directionProbe(
    inout wire isoSioTerm,
    inout wire isoSioCard,
    output wire termMon,
    output wire cardMon
    );

TriWirePullup sioLine(.a(isoSioTerm), .b(isoSioCard));
assign termMon = isoSioTerm;
assign cardMon = isoSioCard;

endmodule
`default_nettype wire
