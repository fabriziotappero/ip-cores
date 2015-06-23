/*
    This file is part of Blue8.

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Blue8.  If not, see <http://www.gnu.org/licenses/>.

    Blue8 by Al Williams alw@al-williams.com
*/




`default_nettype none

   


module controlclk(input wire extstart, input wire extstop, input wire extexam, 
   input wire extdeposit, input wire ihlt, input wire aluov, output wire [8:1] cp,
	output wire [8:1] cpw,  input wire extreset, output wire reset,
	output reg sw2bus, output reg loadpc1, input wire extloadpc, output wire exout, output wire depout,
	output wire running, input wire clk, input wire wclk, input wire abortcycle);



//reg [2:0] counter;
wire xrun, xexam, xdep, pstop, cycle, start, stop, exam, deposit,lpc, treset;
//initial counter=0;					



// sync switches so that each positive edge just gives a clk pulse
// this might be redundant with the front panel debouncers?
// Note that the frontpanel reset switch is not debounced, so you still need
// swreset at least
switchsync swstart(clk,extstart,start);
switchsync swstop(clk,extstop,stop);
switchsync swexam(clk,extexam,exam);
switchsync swdeposit(clk,extdeposit,deposit);
switchsync swreset(clk,extreset,treset);
switchsync swlpc(clk,extloadpc,lpc);
   
assign reset=treset&&~xrun;

// handle "load PC"
/* this doesn't work with sync reset, but 2 flops below don't work either?
always @(posedge clk) begin
  if (reset) begin sw2bus<=1'b0; loadpc1<=1'b0; end
  if (lpc && ~sw2bus) begin
    sw2bus<=1'b1;
  end
  if (sw2bus) begin
    if (loadpc1==1'b0)  loadpc1<=1'b1;
	 else begin
		 sw2bus<=1'b0;
		 loadpc1<=1'b0;
    end
  end
end
*/
always @(posedge clk or posedge reset) begin
  if (reset) sw2bus<=1'b0;
  else begin
    if (lpc && ~sw2bus) sw2bus<=1'b1;
	 if (sw2bus && loadpc1!=1'b0) sw2bus<=1'b0;
  end
end

always @(posedge clk or posedge reset) begin
  if (reset) loadpc1<=1'b0;
  else begin
    if (sw2bus)
	   if (loadpc1==1'b0) loadpc1<=1'b1; else loadpc1<=1'b0;
   end
end
//

// Handle deposit -- Fetch cycle is OK until the end	(need to pass out xdep and xexam)
assign depout=xdep;
// Handle examine -- Examine cycle is OK until the end
assign exout=xexam;
assign running=xrun;


// this flop is set when a stop is pending
jkff pendstop(clk,stop|ihlt|aluov|xexam|xdep,cpw[8],pstop,treset);
// this flop is set when running	 -- the clear of this doesn't do right on single step when executing E inst.
// somehow step stops for the E cycle. However, changing !pende to !(pende|estate) doesn't do better
jkff RUN(clk,start, pstop &cpw[8] , xrun,treset);
// this flop sets when we are running at least one cycle
jkff CYCLE(clk, xrun | xexam | xdep, ((pstop)||xexam||xdep)&cpw[8],cycle,treset);
// examine state
jkff EXAM(clk,exam,cycle && cpw[8],xexam,treset);
// deposit state
jkff DEP(clk,deposit,cycle && cpw[8],xdep,treset);

// I'm trying not to use cp[n] in the cpw expressions to reduce logic levels
// I wonder if I'd have been better off coding this as a one hot?
/*
assign cp[1]=((counter==0)&&(xrun|xdep|xexam))?1'b1:1'b0;
assign cp[2]=(counter==1)?1'b1:1'b0;
assign cp[3]=(counter==2)?1'b1:1'b0; 	 	 	   
assign cp[4]=(counter==3)?1'b1:1'b0;  
assign cp[5]=(counter==4)?1'b1:1'b0; 	 
assign cp[6]=(counter==5)?1'b1:1'b0;
assign cp[7]=(counter==6)?1'b1:1'b0;
assign cp[8]=((counter==7)&&cycle)?1'b1:1'b0;
assign cpw[1]=(((counter==0)&&(xrun|xdep|xexam))?1'b1:1'b0)&wclk;
assign cpw[2]=((counter==1)?1'b1:1'b0)&wclk;
assign cpw[3]=((counter==2)?1'b1:1'b0)&wclk;
assign cpw[4]=((counter==3)?1'b1:1'b0)&wclk;
assign cpw[5]=((counter==4)?1'b1:1'b0)&wclk;
assign cpw[6]=((counter==5)?1'b1:1'b0)&wclk;
assign cpw[7]=((counter==6)?1'b1:1'b0)&wclk;
assign cpw[8]=((counter==7)?1'b1:1'b0)&wclk;

// prime counter if starting -- note start/exam/deposit must be pulsed
always @(posedge clk or posedge reset)  begin
  if (reset) begin counter<=0; end
  else begin
    if (start||exam||deposit||abortcycle) counter<=7; else
    if (xrun || xexam || xdep ) begin
      counter<=counter+1;
    end
  end
end
*/
reg [7:0] onehot;
reg wclks;
assign cp[1]=onehot[0] && (xrun|xdep|xexam);
assign cp[2]=onehot[1];
assign cp[3]=onehot[2];
assign cp[4]=onehot[3];
assign cp[5]=onehot[4];
assign cp[6]=onehot[5];
assign cp[7]=onehot[6];
assign cp[8]=onehot[7] && cycle;
assign cpw[1]=wclks && onehot[0] && (xrun|xdep|xexam);
assign cpw[2]=wclks&onehot[1];
assign cpw[3]=wclks&onehot[2];
assign cpw[4]=wclks&onehot[3];
assign cpw[5]=wclks&onehot[4];
assign cpw[6]=wclks&onehot[5];
assign cpw[7]=wclks&onehot[6];
assign cpw[8]=wclks&&onehot[7] && cycle;

always @(posedge wclk or posedge clk) begin
  if (wclk) wclks<=1'b1; else wclks<=1'b0;
end

always @(posedge clk or posedge reset) begin
  if (reset) onehot<=8'b1;
  else begin
    if (start || exam || deposit || abortcycle) onehot<=8'b10000000;
	 else if (xrun||xexam || xdep) onehot<={onehot[6:0], onehot[7]};
  end
 end
 
endmodule

