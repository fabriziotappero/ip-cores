`timescale 1ns / 1ps
//=============================================================================
//	(C) 2007,2012  Robert T Finch
//	All rights reserved.
//	robfinch<remove>@opencores.org
//
//	Datetime.v
//	
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//
//	BCD representations are used
//	- BCD allows direct visual indication of values without
//	needing to convert hexidecimal values
//
//
//	Address  Reg
//		
//	DC0400    0	DT - Date/Time register
//		      	[ 7: 0]	read / write jiffies
//	    		[15: 8] read / write seconds
//	    		[23:16] read / write minutes
//      		[31:24] read / write hours
//				[39:32] read/write day
//				[47:40] read/write month
//				[63:48] read/write year
//
//	DC0408	  1 ALM - alarm register same format as 0, but contain alarm setting
//
//  DC0410	  2	CR - control register
//      		[ 7: 0] write - which bytes to match for alarm
//      		[8] - time of day enable
//      		[10: 9] - 00=100 Hz, 01=60Hz, 10=50Hz
//     			[16] - mars timekeeping
//
//	DC0418	 3 SN
//				writing this register triggers a snapshot
//				- trigger a snapshot before reading the date / time
//				registers
//				- the snapshot allows the date / time value to be
//				read without having to worry about an update occuring
//				during the read
//				- a copy of the current date and time is stored in
//				the output registers
//
//=============================================================================
//
module Datetime
#(
	parameter pIOAddress = 24'hDC0400,
	parameter pMars = 1'b0
)
(
// Syscon
input rst_i,		// reset
input clk_i,		// system clock

// System bus
input cyc_i,		// valid bus cycle
input stb_i,		// data transfer strobe
output ack_o,		// transfer acknowledge
input we_i,			// 1=write
input [7:0] sel_i,	// byte select
input [23:0] adr_i,	// address
input [63:0] dat_i,	// data input
output reg [63:0] dat_o,	// data output

input tod,			// tod pulse (eg 60 Hz)
output reg alarm		// alarm match
);

reg [1:0] tod_freq;
wire [7:0] max_jcnt = tod_freq==2'b00 ? 8'h99 : tod_freq==2'b01 ? 8'h59 : tod_freq==2'b10 ? 8'h49 : 8'h99;
reg tod_en;
reg mars;
reg snapshot;
wire IsLeapYear;
wire IsDuckYear;

// internal counters
reg [3:0] dayL, dayH;		// 1-99
reg [3:0] monthL, monthH;	// 1-99
reg [3:0] yearN0, yearN1, yearN2, yearN3;	// 
reg [3:0] jiffyL, secL, minL, hourL;
reg [3:0] jiffyH, secH, minH, hourH;

// output latches
reg [3:0] dayLo, dayHo;		// 1-99
reg [3:0] monthLo, monthHo;	// 1-99
reg [3:0] yearN0o, yearN1o, yearN2o, yearN3o;	// 
reg [3:0] jiffyLo, secLo, minLo, hourLo;
reg [3:0] jiffyHo, secHo, minHo, hourHo;

// alarm
reg [7:0] alarm_care;
wire [63:0] alarm_carex = {
	{8{alarm_care[7]}},
	{8{alarm_care[6]}},
	{8{alarm_care[5]}},
	{8{alarm_care[4]}},
	{8{alarm_care[3]}},
	{8{alarm_care[2]}},
	{8{alarm_care[1]}},
	{8{alarm_care[0]}}
};
reg [3:0] alm_dayL, alm_dayH;		// 1-99
reg [3:0] alm_monthL, alm_monthH;	// 1-99
reg [3:0] alm_yearN0, alm_yearN1, alm_yearN2, alm_yearN3;	// 
reg [3:0] alm_jiffyL, alm_secL, alm_minL, alm_hourL;
reg [3:0] alm_jiffyH, alm_secH, alm_minH, alm_hourH;


// update detects
wire incJiffyH = jiffyL == 4'd9;
wire incSecL = {jiffyH,jiffyL}==max_jcnt;
wire incSecH = incSecL && secL==4'h9;
wire incMinL = incSecH && secH==4'h5;
wire incMinH = incMinL && minL==4'h9;
wire incHourL = incMinH && minH==4'h5;
wire incHourH = incHourL && hourL==4'h9;

wire incDayL    = mars ?
					{hourH,hourL,minH,minL,secH,secL,jiffyH,jiffyL} == {24'h243721,max_jcnt} :
					{hourH,hourL,minH,minL,secH,secL,jiffyH,jiffyL} == {24'h235959,max_jcnt}
					;
wire incDayH = incDayL && dayL==4'h9;

// 668.5991	
reg incMarsMonth;
always @(monthH,monthL,dayH,dayL)
	begin
	case({monthH,monthL})	// synopsys full_case parallel_case
	8'h01:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h02:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h03:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h04:	incMarsMonth = {dayH,dayL}==8'h34;
	8'h05:	incMarsMonth = {dayH,dayL}==8'h34;
	8'h06:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h07:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h08:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h09:	incMarsMonth = {dayH,dayL}==8'h34;
	8'h10:	incMarsMonth = {dayH,dayL}==8'h34;
	8'h11:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h12:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h13:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h14:	incMarsMonth = {dayH,dayL}==8'h34;
	8'h15:	incMarsMonth = {dayH,dayL}==8'h34;
	8'h16:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h17:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h18:	incMarsMonth = {dayH,dayL}==8'h33;
	8'h19:	incMarsMonth = {dayH,dayL}==8'h34;
	8'h20:	incMarsMonth = IsDuckYear ? {dayH,dayL}==8'h34 : {dayH,dayL}==8'h35;
	endcase
	end

reg incEarthMonth;
always @(monthH,monthL,dayH,dayL)
	begin
	case({monthH,monthL})	// synopsys full_case parallel_case
	8'h01:	incEarthMonth = {dayH,dayL}==8'h31;
	8'h02:	incEarthMonth = IsLeapYear ? {dayH,dayL}==8'h29 : {dayH,dayL}==8'h28;
	8'h03:	incEarthMonth = {dayH,dayL}==8'h31;
	8'h04:	incEarthMonth = {dayH,dayL}==8'h30;
	8'h05:	incEarthMonth = {dayH,dayL}==8'h31;
	8'h06:	incEarthMonth = {dayH,dayL}==8'h30;
	8'h07:	incEarthMonth = {dayH,dayL}==8'h31;
	8'h08:	incEarthMonth = {dayH,dayL}==8'h31;
	8'h09:	incEarthMonth = {dayH,dayL}==8'h30;
	8'h10:	incEarthMonth = {dayH,dayL}==8'h31;
	8'h11:	incEarthMonth = {dayH,dayL}==8'h30;
	8'h12:	incEarthMonth = {dayH,dayL}==8'h31;
	endcase
	end

wire incMonthL  = incDayL && (mars ? incMarsMonth : incEarthMonth);
wire incMonthH  = incMonthL && monthL==4'd9;
wire incYearN0	= incMonthL && (mars ? {monthH,monthL} == 8'h20 : {monthH,monthL} == 8'h12);
wire incYearN1  = incYearN0 && yearN0 == 4'h9;
wire incYearN2  = incYearN1 && yearN1 == 4'h9;
wire incYearN3  = incYearN2 && yearN2 == 4'h9;


wire cs = cyc_i && stb_i && (adr_i[23:5]==pIOAddress[23:5]);

reg ack1;
always @(posedge clk_i)
	ack1 <= cs;
assign ack_o = cs ? (we_i ? 1'b1 : ack1) : 1'b0;

// Synchronize external tod signal
wire tods;
sync2s sync0(.rst(rst_i), .clk(clk_i), .i(tod), .o(tods));

// Edge detect the incoming tod signal.
wire tod_edge;
edge_det ed_tod(.rst(rst_i), .clk(clk_i), .ce(1'b1), .i(tods), .pe(tod_edge), .ne(), .ee());

// Output alarm pulse on match
wire isAlarm =
		{
			alm_jiffyH,alm_jiffyL,
			alm_secH,alm_secL,
			alm_minH,alm_minL,
			alm_hourH, alm_hourL,
			alm_dayH,alm_dayL,
			alm_monthH,alm_monthL,
			alm_yearN1,alm_yearN0,
			alm_yearN3,alm_yearN2
		} & alarm_carex ==
		{
			jiffyH,jiffyL,
			secH,secL,
			minH,minL,
			hourH,hourL,
			dayH,dayL,
			monthH,monthL,
			yearN1,yearN0,
			yearN3,yearN3
		} & alarm_carex;


reg oalarm;

always @(posedge clk_i)
	if (rst_i) begin
		oalarm <= 1'b0;
		mars <= pMars;
		tod_en <= 1'b1;
		tod_freq = 2'b00;

		jiffyL <= 4'h0;
		jiffyH <= 4'h0;
		secL <= 4'h0;
		secH <= 4'h0;
		minL <= 4'h6;
		minH <= 4'h0;
		hourL <= 4'h3;
		hourH <= 4'h1;

		dayL <= 4'h0;
		dayH <= 4'h1;
		monthL <= 4'h6;
		monthH <= 4'h0;
		yearN0 <= 4'h2;
		yearN1 <= 4'h1;
		yearN2 <= 4'h0;
		yearN3 <= 4'h2;

		alarm_care <= 8'hFF;
		alm_jiffyL <= 4'h0;
		alm_jiffyH <= 4'h0;
		alm_secL <= 4'h0;
		alm_secH <= 4'h0;
		alm_minL <= 4'h0;
		alm_minH <= 4'h0;
		alm_hourL <= 4'h0;
		alm_hourH <= 4'h0;

		alm_dayL <= 4'h0;
		alm_dayH <= 4'h0;
		alm_monthL <= 4'h0;
		alm_monthH <= 4'h0;
		alm_yearN0 <= 4'h0;
		alm_yearN1 <= 4'h0;
		alm_yearN2 <= 4'h0;
		alm_yearN3 <= 4'h0;
		
		snapshot <= 1'b0;

	end
	else begin

		oalarm <= isAlarm;
		snapshot <= 1'b0;	// ensure it only pulses

		if (isAlarm & !oalarm)
			alarm <= 1'b1;

		// Handle register updates
		if (cs & we_i) begin
			case(adr_i[4:3])

			2'd0:	begin
					if (sel_i[0]) begin jiffyL <= dat_i[3:0]; jiffyH <= dat_i[7:4]; end
					if (sel_i[1]) begin secL <= dat_i[3:0]; secH <= dat_i[7:4]; end
					if (sel_i[2]) begin minL <= dat_i[3:0]; minH <= dat_i[7:4]; end
					if (sel_i[3]) begin hourL <= dat_i[3:0]; hourH <= dat_i[7:4]; end
					if (sel_i[4]) begin dayL <= dat_i[3:0]; dayH <= dat_i[7:4]; end
					if (sel_i[5]) begin monthL <= dat_i[3:0]; monthH <= dat_i[7:4]; end
					if (sel_i[6]) begin yearN0 <= dat_i[3:0]; yearN1 <= dat_i[7:4]; end
					if (sel_i[7]) begin yearN2 <= dat_i[3:0]; yearN3 <= dat_i[7:4]; end
					end

			2'd1:	begin
					if (sel_i[0]) begin alm_jiffyL <= dat_i[3:0]; alm_jiffyH <= dat_i[7:4]; end
					if (sel_i[1]) begin alm_secL <= dat_i[3:0]; alm_secH <= dat_i[7:4]; end
					if (sel_i[2]) begin alm_minL <= dat_i[3:0]; alm_minH <= dat_i[7:4]; end
					if (sel_i[3]) begin alm_hourL <= dat_i[3:0]; alm_hourH <= dat_i[7:4]; end
					if (sel_i[4]) begin alm_dayL <= dat_i[3:0]; alm_dayH <= dat_i[7:4]; end
					if (sel_i[5]) begin alm_monthL <= dat_i[3:0]; alm_monthH <= dat_i[7:4]; end
					if (sel_i[6]) begin alm_yearN0 <= dat_i[3:0]; alm_yearN1 <= dat_i[7:4]; end
					if (sel_i[7]) begin alm_yearN2 <= dat_i[3:0]; alm_yearN3 <= dat_i[7:4]; end
					end

			2'd2:	begin
					if (sel_i[0]) alarm_care <= dat_i[7:0];
					if (sel_i[1]) 	begin
									tod_en <= dat_i[8];
									tod_freq <= dat_i[10:9];
									end
					if (sel_i[2]) mars <= dat_i[16];
					end

			// writing to register 3 triggers a snapshot
			2'd3:	snapshot <= 1'b1;

			endcase
		end
		if (cs) begin
			case(adr_i[4:3])
			2'd0:	dat_o <= {yearN3o,yearN2o,yearN1o,yearN0o,monthHo,monthLo,dayHo,dayLo,hourHo,hourLo,minHo,minLo,secHo,secLo,jiffyHo,jiffyLo};
			2'd1:	begin
						dat_o <= {alm_yearN3,alm_yearN2,alm_yearN1,alm_yearN0,alm_monthH,alm_monthL,alm_dayH,alm_dayL,alm_hourH,alm_hourL,alm_minH,alm_minL,alm_secH,alm_secL,alm_jiffyH,alm_jiffyL};
						alarm <= 1'b0;
					end
			2'd2:	dat_o <= {mars,5'b0,tod_freq,tod_en,alarm_care}; 
			2'd3:	dat_o <= 0;
			endcase
		end
		else
			dat_o <= 64'd0;


		// Clock updates
		if (tod_en & tod_edge) begin

			jiffyL <= jiffyL + 4'h1;

			if (incJiffyH) begin
				jiffyL <= 4'h0;
				jiffyH <= jiffyH + 4'h1;
			end

			// Seconds
			if (incSecL) begin
				jiffyH <= 4'h0;
				secL <= secL + 4'h1;
			end
			if (incSecH) begin
				secL <= 4'h0;
				secH <= secH + 4'h1;
			end

			if (incMinL) begin
				minL <= minL + 4'h1;
				secH <= 4'h0;
			end
			if (incMinH) begin
				minL <= 4'h0;
				minH <= minH + 4'h1;
			end

			if (incHourL) begin
				minH <= 4'h0;
				hourL <= hourL + 4'h1;
			end
			if (incHourH) begin
				hourL <= 4'h0;
				hourH <= hourH + 4'h1;
			end

			// day increment
			// reset the entire time when the day increments
			// - the day may not be exactly 24 hours long
			if (incDayL) begin
				dayL <= dayL + 4'h1;
				jiffyL <= 4'h0;
				jiffyH <= 4'h0;
				secL <= 4'h0;
				secH <= 4'h0;
				minL <= 4'h0;
				minH <= 4'h0;
				hourL <= 4'h0;
				hourH <= 4'h0;
			end
			if (incDayH) begin
				dayL <= 4'h0;
				dayH <= dayH + 4'h1;
			end

			if (incMonthL) begin
				dayL <= 4'h1;
				dayH <= 4'h0;
				monthL <= monthL + 4'h1;
			end
			if (incMonthH) begin
				monthL <= 4'h0;
				monthH <= monthH + 4'h1;
			end

			if (incYearN0) begin
				monthL <= 4'h1;
				monthH <= 4'h0;
			end
			if (incYearN1) begin
				yearN0 <= 4'h0;
				yearN1 <= yearN1 + 4'h1;
			end
			if (incYearN2) begin
				yearN1 <= 4'h0;
				yearN2 <= yearN2 + 4'h1;
			end
			if (incYearN3) begin
				yearN2 <= 4'h0;
				yearN3 <= yearN3 + 4'h1;
			end
		end
	end


// Take snapshot of date / time
always @(posedge clk_i)
	if (rst_i) begin
		jiffyLo <= 4'h0;
		jiffyHo <= 4'h0;
		secLo <= 4'h0;
		secHo <= 4'h0;
		minLo <= 4'h0;
		minHo <= 4'h0;
		hourLo <= 4'h0;
		hourHo <= 4'h0;
		dayLo <= 4'h0;
		dayHo <= 4'h0;
		monthLo <= 4'h0;
		monthHo <= 4'h0;
		yearN0o <= 4'h0;
		yearN1o <= 4'h0;
		yearN2o <= 4'h0;
		yearN3o <= 4'h0;
	end
	else if (snapshot) begin
		jiffyLo <= jiffyL;
		jiffyHo <= jiffyH;
		secLo <= secL;
		secHo <= secH;
		minLo <= minL;
		minHo <= minH;
		hourLo <= hourL;
		hourHo <= hourH;
		dayLo <= dayL;
		dayHo <= dayH;
		monthLo <= monthL;
		monthHo <= monthH;
		yearN0o <= yearN0;
		yearN1o <= yearN1;
		yearN2o <= yearN2;
		yearN3o <= yearN3;
	end

//   int IsLeapYear() const {
//      return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
//   };
//
// We don't need to convert the whole year to binary to determine if it's divisble by four,
// only the lowest two order nybbles need be converted.
wire [7:0] binyear = 
			yearN0
			+ {yearN1,3'b0} + {yearN1,1'b0}	// yearN1 * 10
//			+ {yearN2,6'b0} + {yearN2,5'b0} + {yearN2,2'b0}	// yearN2 * 100
//			+ {yearN3,9'b0} + {yearN3,8'b0} + {yearN3,7'b0} + {yearN3,6'b0} + {yearN3,5'b0} + {yearN3,3'b0}
			;

// convert century to binary to see if it's divisible by four
wire [7:0] bincent = {yearN3,3'b0} + {yearN3,1'b0} + yearN2;

assign IsLeapYear = binyear[1:0]==2'b00 && ({yearN1,yearN0}!=8'h00 || (bincent[1:0]==2'b00 && {yearN1,yearN0}==8'h00));

assign IsDuckYear = yearN0==4'h1 || yearN0==4'h3 || yearN0==4'h6 || yearN0==4'h8;

endmodule

