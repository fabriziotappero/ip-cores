/* processor timer controller 
   Can be used to trigger halt signal 
   to regulate MIPS and power consumption

   255 will cause a solid timer signal
   127 is the center and will cause a signal every other cycle
   0 will stop all signaling 

   Extend the bit count to give finer control
*/

module timer_cont (
		  clk,			// System clock
		  reset_b,		// system reset
		  set_reg,		// signal to set regulator value
		  reg_num,		// value to set regulator to
		  
		  signal);	// timer signal that goes to processor

input clk;
input reset_b;
input set_reg;
input [7:0] reg_num;

output signal;
reg signal;

// Internal signals and regs

reg [7:0] regulator;

reg [7:0] timer_int;
reg [7:0] timer_dur;

reg [7:0] dur_count;
reg [7:0] int_count;

always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      regulator <= 'b 0;
    else
      if (set_reg)
        regulator <= reg_num;
  end

always @(regulator)
  begin
    if (regulator < 8'd 128)
      begin
        timer_int = 8'd 128 - regulator;
        timer_dur = 8'd 1;
      end
    else
      begin
        timer_int = 8'b 1;
        timer_dur = regulator - 8'd 127;
      end
  end

always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      begin
        dur_count <= 'b 0;
        int_count <= 'b 0;
      end
    else
      begin
        if (int_count < timer_int)
          begin
            int_count <= int_count + 1'b 1;
            dur_count <= 'b 0;
          end
        else
          if (dur_count < timer_dur)
            begin
              dur_count <= dur_count + 1'b 1;
              if ((dur_count + 1'b 1) == timer_dur)
                int_count <= 'b 0;
            end
      end
  end

always @(int_count or timer_int or regulator)
  begin
    if (&regulator)
      signal = 1'b 1;
    else
      if (!(|regulator))
        signal = 1'b 0;
      else
        if (int_count < timer_int)
          signal = 1'b 0;
        else
          signal = 1'b 1;
  end

endmodule


/*  $Id: timer_cont.v,v 1.1 2001-10-29 06:12:05 samg Exp $ 
 *  Module : timer_cont 
 *  Author : Sam Gladstone
 *  Function : Programable timer circuit
 *  $Log: not supported by cvs2svn $
 */
