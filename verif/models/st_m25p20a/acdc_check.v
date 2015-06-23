// Author: Mehdi SEBBANE
// May 2002
// Verilog model
// project: M25P20 25 MHz,
// release: 1.4.1



// These Verilog HDL models are provided "as is" without warranty
// of any kind, included but not limited to, implied warranty
// of merchantability and fitness for a particular purpose.





`timescale 1ns/1ns
`ifdef SFLASH_SPDUP
`include "parameter_fast.v"
`else
`include "parameter.v"
`endif

module acdc_check (c, d, s, hold, write_op, read_op);

   input c; 
   input d; 
   input s; 
   input hold; 
   input write_op; 
   input read_op; 
   
   ////////////////
   // TIMING VALUES
   ////////////////
   time t_C_rise;
   time t_C_fall;
   time t_H_rise;
   time t_H_fall;
   time t_S_rise;
   time t_S_fall;
   time t_D_change;
   time high_time;
   time low_time;
   ////////////////
   
   reg toggle;
   
   initial
   begin
      high_time = 100000;
      low_time = 100000;
      toggle = 1'b0;
   end

   //--------------------------------------------
   // This process checks pulses length on pin /S
   //--------------------------------------------
   always 
   begin : shsl_watch
      @(posedge s); 
      begin
         if ($time != 0) 
         begin
            t_S_rise = $time; 
            @(negedge s); 
            t_S_fall = $time; 
            if ((t_S_fall - t_S_rise) < `TSHSL)
            begin
               $display("ERROR : tSHSL condition violated"); 
            end 
         end
      end 
   end 

   //----------------------------------------------------
   // This process checks select and deselect setup 
   // and hold timings 
   //----------------------------------------------------
   always 
   begin : s_watch
      @(s); 
      if ((s == 1'b0) && (hold != 1'b0))
      begin
         if ($time != 0) 
         begin
            t_S_fall = $time;
            if (c == 1'b1)
            begin
               if ( ($time - t_C_rise) < `TCHSL)
               begin
                  $display("ERROR :tCHSL condition violated"); 
               end 
            end
            else if (c == 1'b0)
            begin
               @(c);
               if ( ($time - t_S_fall) < `TSLCH)
               begin 
                  $display("ERROR :tSLCH condition violated");  
               end
            end 
         end
      end 
      if ((s == 1'b1) && (hold != 1'b0))
      begin
         if ($time != 0) 
         begin
            t_S_rise = $time;
            if (c == 1'b1)
            begin
               if ( ($time - t_C_rise) < `TCHSH)
               begin
                  $display("ERROR :tCHSH condition violated"); 
               end 
            end
            else if (c == 1'b0)
            begin
               @(c);
               if ( ($time - t_S_rise) < `TSHCH )
               begin
                  $display("ERROR :tSHCH condition violated");
               end
            end 
         end
      end 
   end 

   //---------------------------------
   // This process checks hold timings
   //---------------------------------
   always 
   begin : hold_watch
      @(hold); 
      if ((hold == 1'b0) && (s == 1'b0))
      begin
         if ($time != 0) 
         begin
            t_H_fall = $time ;
            if ( (t_H_fall - t_C_rise) < `TCHHL)
            begin
               $display("ERROR : tCHHL condition violated"); 
            end 
         
            @(posedge c);
            if( ($time - t_H_fall) < `THLCH)
            begin
               $display("ERROR : tHLCH condition violated");
            end
         end
      end 


      if ((hold == 1'b1) && (s == 1'b0))
      begin
         if ($time != 0) 
         begin
            t_H_rise = $time ;
            if ( (t_H_rise - t_C_rise) < `TCHHH)
            begin
               $display("ERROR : tCHHH condition violated"); 
            end 
            @(posedge c);
            if( ($time - t_H_fall) < `THHCH)
            begin
               $display("ERROR : tHHCH condition violated");
            end
         end
      end 
   end 

   //--------------------------------------------------
   // This process checks data hold and setup timings
   //--------------------------------------------------
   always 
   begin : d_watch
      @(d);
      if ($time != 0) 
      begin
         t_D_change = $time;
         if (c == 1'b1)
         begin
            if ( ($time - t_C_rise) < `TCHDX)
            begin
               $display("ERROR : tCHDX condition violated"); 
            end 
         end
         else if (c == 1'b0)
         begin
            @(c);
            if ( ($time - t_D_change) < `TDVCH) 
            begin
               $display("ERROR : tDVCH condition violated");
            end
         end 
      end
   end 

   //-------------------------------------
   // This process checks clock high time
   //-------------------------------------
   always 
   begin : c_high_watch
      @(c); 
      if ($time != 0) 
      begin
         if (c == 1'b1)
         begin
            t_C_rise = $time; 
            @(negedge c); 
            t_C_fall = $time; 
            high_time = t_C_fall - t_C_rise;
            toggle = ~toggle;
            if ((t_C_fall - t_C_rise) < `TCH)
            begin
               $display("ERROR : tCH condition violated"); 
            end 
         end 
      end
   end 

   //-------------------------------------
   // This process checks clock low time
   //-------------------------------------
   always 
   begin : c_low_watch
      @(c); 
      if ($time != 0) 
      begin
         if (c == 1'b0)
         begin
            t_C_fall = $time; 
            @(posedge c); 
            t_C_rise = $time; 
            low_time = t_C_rise - t_C_fall;
            toggle = ~toggle;
            if ((t_C_rise - t_C_fall) < `TCL)
            begin
               $display("ERROR : tCL condition violated"); 
            end 
         end 
      end
   end 

   //-----------------------------------------------
   // This process checks clock frequency
   //-----------------------------------------------
//   always @(high_time or low_time or read_op)
   always @(toggle or read_op)
   begin : freq_watch
      if ($time != 0) 
      begin
         if (s == 1'b0)
         begin
            if (read_op)
            begin
               if ((high_time + low_time) < `TR)
               begin
                  $display("ERROR : Clock frequency condition violated for READ instruction: fR>20MHz"); 
               end 
            end
            else if ((high_time + low_time) < `TC)
            begin
               $display("ERROR : Clock frequency condition violated: fC>25MHz"); 
            end 
         end
      end
   end 
endmodule
