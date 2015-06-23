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
// Workfile     : sdram_tread_class.sv
// 
// Description  : virtual sdram treads using for sdram chip testing
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




`include "tb_define.svh"

`ifndef __SDRAM_TREAD_CLASS_SV__

  `define __SDRAM_TREAD_CLASS_SV__
  
  class sdram_tread_class;
  
    sdram_tread_state_s_t active_tread_state [sdram_tread_ptr_t];
  
    rand sdram_tread_ptr_t curr_tread_num; // no need to constrant  
  
    sdram_tread_ptr_t disable_tread_num [$];
  
    constraint select_tread { !(curr_tread_num inside {disable_tread_num}); }

    //
    //
    //
  
    function void Init () ;
      int tread_num     = 0;
      const int shift   = clogb2(cBaMaxValue);
      sdram_tread_state_s_t tread_state;
  
      if (active_tread_state.num != 0)
        active_tread_state.delete;
  
      if (disable_tread_num.size != 0)
        disable_tread_num = {};
  
      for (int rowa = 0; rowa < cRowaMaxValue; rowa++) begin
        for (int ba = 0; ba < cBaMaxValue; ba++) begin
  
        tread_num = (rowa << shift) + ba;
  
        tread_state = '{ba : ba, rowa : rowa, cola : 0};
  
        active_tread_state[tread_num] = tread_state;
  
        end
      end
  
    endfunction
  
    //
    //
    // 
    
    function burst_t GetBurst (input sdram_tread_state_s_t tread_state);     
  
      int max_burst;
  
      max_burst = cColaMaxValue - tread_state.cola; 
  
      if (max_burst > cBurstMaxValue) max_burst = 16;
      
      assert (std::randomize(GetBurst) with {GetBurst inside {[1:max_burst]};}) 
        else $error ("burst generate error : max burst = %0d burst = %0d", max_burst, GetBurst );    
      
    endfunction
  
  endclass

`endif
