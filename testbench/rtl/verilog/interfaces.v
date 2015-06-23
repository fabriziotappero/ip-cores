//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "interfaces.v"                                    ////
////                                                              ////
////  This file is part of the :                                  ////
////                                                              ////
//// "1000BASE-X IEEE 802.3-2008 Clause 36 - PCS project"         ////
////                                                              ////
////  http://opencores.org/project,1000base-x                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - D.W.Pegler Cambridge Broadband Networks Ltd           ////
////                                                              ////
////      { peglerd@gmail.com, dwp@cambridgebroadand.com }        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 AUTHORS. All rights reserved.             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "timescale_tb.v"

import ethernet_frame::EthernetFrame;
import ethernet_frame::FrameMailBox;
import ethernet_frame::ethernet_address_t;
import ethernet_frame::EthernetSpeed;

interface serial_model_if();
  modport testbench(
    import function string whoami(),
    import task write(int address, integer value),
    import task read(int address, output integer value)	    
  );
  modport model(
    export function string whoami(),
    export task write(),
    export task read()
  );
endinterface

interface gmii_tx_if();
  modport testbench(
    import function string whoami(),
    import function void queue_frame(EthernetFrame frame),
    import function void queue_delay(time delay),
    import task sleep(time timeout),
    import function void set_speed(EthernetSpeed m)    
  );
  modport model(
    export function string whoami(),
    export function void queue_frame(),
    export function void queue_delay(),
    export task sleep(),
    export function void set_speed()
  );
endinterface

interface gmii_rx_if();
  modport testbench(
    import function string whoami(),
    import function void register_mailbox(ethernet_address_t sa, FrameMailBox mbx),
    import function void unregister_mailbox(ethernet_address_t sa),
    import function void enable_loopback(virtual gmii_tx_if intf),
    import function void set_parity_errors(int parity, int errors),
    import function void set_speed(EthernetSpeed m)	    
  );
  modport model(
    export function string whoami(),
    export function void register_mailbox(),
    export function void unregister_mailbox(),
    export function void enable_loopback(virtual gmii_tx_if intf),
    export function void set_parity_errors(),
    export function void set_speed()
  );
endinterface

interface encoder_8b_tx_if();

  modport testbench(
    import function string whoami(),	    
    import function void push_8B_symbol(reg[7:0] value),
    import function void push_config(reg[15:0] value),
    import function void queue_frame(EthernetFrame frame),
    import task sleep(time timeout)
  );

  modport model(
    export function string whoami(),
    export function void push_8B_symbol(),
    export function void push_config(),
    export function void queue_frame(),
    export task sleep()
  );

endinterface

interface encoder_10b_rx_if();

  modport testbench(
    import function string whoami()
  );
  modport model(
    export function string whoami()
  );

endinterface


interface decoder_8b_rx_if();

  modport testbench(
    import function string whoami()	    
  );
  modport model(
    export function string whoami()
  );
endinterface

