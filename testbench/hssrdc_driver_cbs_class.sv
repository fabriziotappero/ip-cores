//
// Project      : High-Speed SDRAM Controller with adaptive bank management and command pipeline
// 
// Project Nick : HSSDRC
// 
// Version      : 1.0-beta 
//  
// Revision     : $Revision: 1.1 $ 
// 
// Date         : $Date: 2008-03-06 13:54:00 $ 
// 
// Workfile     : hssrdc_driver_cbs_class.sv
// 
// Description  : base class for callbacks for API driver 
// 
// HSSDRC is licensed under MIT License
// 
// Copyright (c) 2007-2008, Denis V.Shekhalev (des00@opencores.org) 
// 
// Permission  is hereby granted, free of charge, to any person obtaining a copy of
// this  software  and  associated documentation files (the "Software"), to deal in
// the  Software  without  restriction,  including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the  Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR  A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT  HOLDERS  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//



`include "sdram_transaction_class.sv"

`ifndef __HSSDRC_DRIVER_CBS_CLASS__

  `define __HSSDRC_DRIVER_CBS_CLASS__

  class hssrdc_driver_cbs_class;        

    //
    // callback for command part of hssdrc_driver_class 
    // 

    virtual task post_Command(input realtime t);
    endtask 

    //
    // callback for write part of hssdrc_driver_class 
    // 

    virtual task post_WriteData (input realtime t, sdram_transaction_class tr);
    endtask   

    //
    // callback for read part of hssdrc_driver_class 
    // 

    virtual task post_ReadData (input realtime t, sdram_transaction_class tr); 
    endtask

  endclass

`endif 
