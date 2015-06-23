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
// Workfile     : message_class.sv
// 
// Description  : simple message service class
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



`ifndef __MESSAGE_CLASS__

  `define __MESSAGE_CLASS__

  class message_class; 
  
    static int fp; 
  
    static int err_cnt; 

    //
    //
    //

    function new (string file_name = "");
      if (file_name.len() != 0)
        fp = $fopen(file_name, "w");
      else 
        fp = 0;
    endfunction

    //
    //
    //
  
    function void stop(); 
      $fclose(fp);
    endfunction
  
    //
    //
    //
    
    function void note (string str);
      string io_str; 
  
      io_str = $psprintf("**NOTE** at %0t : ", $time);
  
      io_str = {io_str, str}; 
  
      $display (io_str);
      if (fp)
        $fdisplay (fp, io_str);
    endfunction

    //
    //
    //

    function void err (string str);
      string io_str; 
  
      err_cnt++; 
  
      io_str = $psprintf("**ERROR** at %0t : ", $time);
  
      io_str = {io_str, str};
  
      $display (io_str);
      if (fp)
        $fdisplay (fp, io_str);
  
    endfunction
  
  endclass 

`endif 
