//////////////////////////////////////////////////////////////////////////////////////////////
//    Project Qrisc32 is risc cpu implementation, purpose is studying
//    Digital System Design course at Kyoung Hee University during my PhD earning
//    Copyright (C) 2010  Vinogradov Viacheslav
// 
//    This library is free software; you can redistribute it and/or
//   modify it under the terms of the GNU Lesser General Public
//    License as published by the Free Software Foundation; either
//    version 2.1 of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//
//////////////////////////////////////////////////////////////////////////////////////////////



`timescale 1ns / 1ns

module qrisc32_tb;
//Parameters declaration: 
	import risc_pack::*;
	
	//Internal signals declarations:
	bit reset,clk;
	//I data	
	logic[31:0]	idata;
	logic[31:0]	iaddr;
	logic		ird;
	logic		ireq;
	
	//D read
	logic[31:0]	rdata;
	logic[31:0]	raddr;
	logic		rrd;
	logic		rreq=0;
	
	//D write
	logic[31:0]	wdata;
	logic[31:0]	waddr;
	logic		wwr;
	logic		wreq=0;
	logic		Istop_active,Dstop_active;
	bit			Istop_enable,Dstop_enable;
	bit			verbose;
		
	//emulates Instruction ram
	mem		Iram(
		.clk(clk),
		.add_r(iaddr),
		.add_w(32'h0),
		.data_w(32'h0),
		.rd(ird),
		.wr(1'b0),
		.data_r(idata),
		.req(ireq),
		.stop_enable(Istop_enable),
		.stop_active(Istop_active),
		.verbose(verbose)
	);
	defparam Iram.size=256;
	defparam Iram.adr_limit=93;
	
	//emulates Data ram
	mem		Dram(
		.clk(clk),
		.add_r(raddr),
		.add_w(waddr),
		.data_w(wdata),
		.rd(rrd),
		.wr(wwr),
		.data_r(rdata),
		.req(),
		.stop_enable(Dstop_enable),
		.stop_active(Dstop_active),
		.verbose(verbose)
	);
	defparam Dram.size=10;
	defparam Dram.adr_limit=10;
	
	// Unit Under Test port map
	qrisc32 UUT(
		.reset(reset),
		.clk(clk),
		//avalon master port only for  reading instructions
		.avm_instructions_data(idata),
		.avm_instructions_addr(iaddr),
		.avm_instructions_rd(ird),
		.avm_instructions_wait_req(ireq),
	
		//avalon master port only for  reading data
		.avm_datar_data(rdata),
		.avm_datar_addr(raddr),
		.avm_datar_rd(rrd),
		.avm_datar_wait_req(rreq),

		//avalon master port only for  writing data
		.avm_dataw_data(wdata),
		.avm_dataw_addr(waddr),
		.avm_dataw_wr(wwr),
		.avm_dataw_wait_req(wreq),
		.verbose(verbose)
	);

	int address;
	bit signed[14:0] jmpr_label0,jmpr_label1;
	bit [25:0] ilabel,jlabel,inclabel,jmp_label1;
	
	function	void loadIram;
		input[31:0]	data;
		begin
			Iram.sram[address] = data;
			address=address+1;
		end
	endfunction

	task	load_buble_sort;
	/*buble algorithm
		R0=mem[00],R1=mem[04],R2=mem[08],R3=mem[c],R4=mem[10]
		R5=mem[14],R6=mem[18],R7=mem[1c],R8=mem[20],R9=mem[24]
		R10=R0;
		R11=R0;//minimum
		if R1<R11
			R11=R1
		if R2<R11
			R11=R2
		if R3<R11
			R11=R3
		if R4<R11
			R11=R4
		if R5<R11
			R11=R5
		if R6<R11
			R11=R6
		if R7<R11
			R11=R7
		if R8<R11
			R11=R8
		if R9<R11
			R11=R9
		mem[0]=R11;
					 
		for (i = 36; i > 0; i-=4)//36,32,28,24,20,16,12,8,4
		{
			if R0>R10
				R10=R0
			if R1>R10
				R10=R1
			if R2>R10
				R10=R2
			if R3>R10
				R10=R3
			if R4>R10
				R10=R4
			if R5>R10
				R10=R5
			if R6>R10
				R10=R6
			if R7>R10
				R10=R7
			if R8>R10
				R10=R8
			if R9>R10
				R10=R9
				
			mem[i]=R10;

			//substitute maximum by minimum
			if R10=R0
				R0=R11
			if R10=R1
				R1=R11
			if R10=R2
				R2=R11
			if R10=R3
				R3=R11
			if R10=R4
				R4=R11
			if R10=R5
				R5=R11
			if R10=R6
				R6=R11
			if R10=R7
				R7=R11
			if R10=R8
				R8=R11
			if R10=R9
				R9=R11
				
		}*/
	//loading instructions
		address=0;
		//verbose=1;
		//Istop_enable=1;
		
		loadIram({LDRH,16'h0000,R12});//R12 is 36
		loadIram({XOR,DECR_0,7'h0,R13,R13,R13});//R13 is 0
		loadIram({LDRH,16'hFFFF,R14});//R14 is -4
		loadIram({LDRL,16'h0024,R12});//R12 is 36
		
		loadIram({LDRP,OFFSET_CODE,15'd00,R13,R0});//ldr R0,[R13+0]
		loadIram({LDRP,OFFSET_CODE,15'd04,R13,R1});//ldr R1,[R13+4]
		loadIram({LDRP,OFFSET_CODE,15'd08,R13,R2});//ldr R2,[R13+8]
		loadIram({LDRP,OFFSET_CODE,15'd12,R13,R3});//ldr R3,[R13+12]
		loadIram({LDRP,OFFSET_CODE,15'd16,R13,R4});//ldr R4,[R13+16]

		loadIram({LDRP,OFFSET_CODE,15'd20,R13,R5});//ldr R5,[R13+20]
		loadIram({LDRP,OFFSET_CODE,15'd24,R13,R6});//ldr R6,[R13+24]
		loadIram({LDRP,OFFSET_CODE,15'd28,R13,R7});//ldr R7,[R13+28]
		loadIram({LDRP,OFFSET_CODE,15'd32,R13,R8});//ldr R8,[R13+32]
		loadIram({LDRP,OFFSET_CODE,15'd36,R13,R9});//ldr R9,[R13+36]

		loadIram({LDRL,-16'd4,R14});//R14 is -4
		
		//search for minimum
		loadIram({CMP,INCR_0,7'h0,R0,R1,R1});
		loadIram({LDRC,INCR_0,7'h0,R0,R1,R16});
		
		loadIram({CMP,INCR_0,7'h0,R3,R2,R2});
		loadIram({LDRC,INCR_0,7'h0,R3,R2,R17});
		
		loadIram({CMP,INCR_0,7'h0,R5,R4,R4});
		loadIram({LDRC,INCR_0,7'h0,R5,R4,R18});
		
		loadIram({CMP,INCR_0,7'h0,R7,R6,R6});
		loadIram({LDRC,INCR_0,7'h0,R7,R6,R19});

		loadIram({CMP,INCR_0,7'h0,R9,R8,R8});
		loadIram({LDRC,INCR_0,7'h0,R9,R8,R20});

		loadIram({CMP,INCR_0,7'h0,R17,R16,R16});
		loadIram({LDRC,INCR_0,7'h0,R17,R16,R21});

		loadIram({CMP,INCR_0,7'h0,R19,R18,R18});
		loadIram({LDRC,INCR_0,7'h0,R19,R18,R22});

		loadIram({CMP,INCR_0,7'h0,R21,R20,R20});
		loadIram({LDRC,INCR_0,7'h0,R21,R20,R23});
		loadIram({NOP});

		loadIram({CMP,INCR_0,7'h0,R23,R22,R22});
		loadIram({LDRC,INCR_0,7'h0,R23,R22,R11});

		loadIram({NOP});
		//minimum write
		loadIram({STRP,OFFSET_CODE,15'd0,R13,R11});//str R10,[R13+0]

		//
		//search for maximum
		loadIram({CMP,INCR_0,7'h0,R0,R1,R1});
		loadIram({LDRNC,INCR_0,7'h0,R0,R1,R16});
		
		loadIram({CMP,INCR_0,7'h0,R3,R2,R2});
		jmpr_label0=4*address;
		loadIram({LDRNC,INCR_0,7'h0,R3,R2,R17});
		
		loadIram({CMP,INCR_0,7'h0,R5,R4,R4});
		loadIram({LDRNC,INCR_0,7'h0,R5,R4,R18});
		
		loadIram({CMP,INCR_0,7'h0,R7,R6,R6});
		loadIram({LDRNC,INCR_0,7'h0,R7,R6,R19});

		loadIram({CMP,INCR_0,7'h0,R9,R8,R8});
		loadIram({LDRNC,INCR_0,7'h0,R9,R8,R20});

		loadIram({CMP,INCR_0,7'h0,R17,R16,R16});
		loadIram({LDRNC,INCR_0,7'h0,R17,R16,R21});

		loadIram({CMP,INCR_0,7'h0,R19,R18,R18});
		loadIram({LDRNC,INCR_0,7'h0,R19,R18,R22});

		loadIram({CMP,INCR_0,7'h0,R21,R20,R20});
		loadIram({LDRNC,INCR_0,7'h0,R21,R20,R23});
		loadIram({NOP});

		loadIram({CMP,INCR_0,7'h0,R23,R22,R22});
		loadIram({LDRNC,INCR_0,7'h0,R23,R22,R10});
		loadIram({NOP});
		
		loadIram({STRP,OFFSET_CODE,15'd0,R12,R10});//str R10,[R12+0]

		loadIram({ADD,DECR_0,7'h0,R14,R12,R12});//R12 = R12 + R12( -4)
		
		loadIram({CMP,INCR_0,7'h0,R0,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R0,R11,R0});
		loadIram({CMP,INCR_0,7'h0,R1,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R1,R11,R1});
		loadIram({CMP,INCR_0,7'h0,R2,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R2,R11,R2});
		loadIram({CMP,INCR_0,7'h0,R3,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R3,R11,R3});
		loadIram({CMP,INCR_0,7'h0,R4,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R4,R11,R4});
		loadIram({CMP,INCR_0,7'h0,R5,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R5,R11,R5});
		loadIram({CMP,INCR_0,7'h0,R6,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R6,R11,R6});
		loadIram({CMP,INCR_0,7'h0,R7,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R7,R11,R7});
		loadIram({CMP,INCR_0,7'h0,R8,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R8,R11,R8});
		loadIram({CMP,INCR_0,7'h0,R9,R10,R10});
		loadIram({LDRZ,INCR_0,7'h0,R9,R11,R9});
		
		loadIram({CMP,INCR_0,7'h0,R13,R12,R12});//cmp R12 with R13(0)
		 
		jmpr_label1=jmpr_label0-4*address-8;
		loadIram({JMPNZ,OFFSET_CODE,jmpr_label1,10'h0});
		loadIram({LDRR,DECR_0,7'h0,R11,R11,R10});//R10 =R11
		
		loadIram({CMP,INCR_0,7'h0,R0,R1,R1});
		loadIram({LDRNC,INCR_0,7'h0,R0,R1,R16});
		loadIram({CMP,INCR_0,7'h0,R3,R2,R2});
		
		
	endtask;


	task	load_shell_sort_mdf;
	/*new algorithm
		for(inc = 20;inc>0;inc=inc/2)//20, 8 and 4 (5,2,1)
		{
			for (i = inc; i < 40; i+=4)//0..4..8..c and etc
			{
				temp = a[i];
				for (j = i; (j >= inc) && (a[j-inc] > temp); j =j-inc)
				{
					a[j] = a[j-inc];
				}	
			a[j] = temp;
			}
		}*/
	//---------------------	 reverse(709) random(714) sorted(516)
	//loading instructions
		address=0;
		loadIram({LDRH,16'h0000,R5});//R5 inc = 5
		loadIram({LDRH,16'h0000,R8});//R8 =1
		loadIram({LDRH,16'h0000,R9});//R9 =2
		loadIram({LDRH,16'h0000,R10});//R10 is 4
		loadIram({LDRH,16'h0000,R12});//R12 is 40
		loadIram({LDRH,16'hFFFF,R13});//R13 is mask 0xffff_ffff
		loadIram({LDRH,16'h0000,R14});//R14 is 3

		loadIram({LDRL,16'h0005,R5});//R5 inc = 5		
		loadIram({LDRL,16'h0001,R8});//R8 =1
		loadIram({LDRL,16'h0002,R9});//R9 =2
		loadIram({LDRL,16'h0004,R10});//R10 is 4
		loadIram({LDRL,16'h0028,R12});//R12 is 40
		loadIram({LDRL,16'hFFFF,R13});//R13 is mask 0xffff_ffff
		loadIram({LDRL,16'h0003,R14});//R14 is 3
				
		//R5 - inc
		//R6 - -inc
		//R7 - j-inc
		//R4 - i
		//R3 - J
		//for (inc...
		inclabel = 4*address;
		jmpr_label0 = 4*address;
		loadIram({SHL,INCR_0,7'h0,R9,R5,R5});//R5 = R5<<R9( R5<<2)
				
		jmpr_label1=1000*4;//out of code
		loadIram({JMPZ,OFFSET_CODE,jmpr_label1,10'h0});//R5>0?

		loadIram({XOR,DECR_0,7'h0,R13,R5,R6});//R6 = R5 xor R13
		loadIram({LDRR,DECR_0,7'h0,R5,R5,R4});//i(R4)=inc (R5)
		loadIram({ADD,DECR_0,7'h0,R8,R6,R6});//R6 = R6 + R8( +1)
		loadIram({SHR,INCR_0,7'h0,R14,R5,R5});//R5 = R5>>R14( R5>>3))
		
		loadIram({CMP,INCR_0,7'h0,R12,R4,R4});//compare R4 with R12(i == 40) if 0 then reached maximum-> stop
		ilabel=4*address;

		jmpr_label1=jmpr_label0-4*address-8;
		loadIram({JMPZ,OFFSET_CODE,jmpr_label1,10'h0});//if =40 then goto inc
		
		//temp  - r1
		loadIram({LDRP,OFFSET_CODE,15'd0,R4,R1});//ldr R1,[R4]
		
		//for (j = i;..
		loadIram({LDRR,DECR_0,7'h0,R4,R4,R3});//j(R3)=i(R4)
		loadIram({ADD,DECR_0,7'h0,R4,R6,R7});//R7 = R4+R6=(i)j-inc
		
		loadIram({CMP,INCR_0,7'h0,R5,R3,R3});//cmp R3 j with R5 inc
		jlabel=4*address;
		//a[j-inc]  - r0
		loadIram({LDRP,OFFSET_CODE,15'd0,R7,R0});//ldrp R0,[R7]
		
		jmpr_label1=13*4;
		loadIram({JMPC,OFFSET_CODE,jmpr_label1,10'h0});//c=1 then R3 j < R5 inc 
		loadIram({NOP});loadIram({NOP});loadIram({NOP});
		
		//a[j-inc] > temp?
		loadIram({CMP,INCR_0,7'h0,R1,R0,R0});//cmp R0 a[j-inc] with R1 temp

		jmpr_label1=8*4;
		loadIram({JMPC,OFFSET_CODE,jmpr_label1,10'h0});//c=1 then R0>R1 
		loadIram({NOP});loadIram({NOP});loadIram({NOP});loadIram({NOP});

		loadIram({JMP,jlabel});//goto next cycle of J
		loadIram({LDRR,DECR_0,7'h0,R7,R7,R3});//j=j-inc,  R3=R7
		//a[j] = a[j-inc];
		loadIram({STRP,OFFSET_CODE,15'd0,R3,R0});//str R0,[R3+0]
		loadIram({ADD,DECR_0,7'h0,R3,R6,R7});//R7 = R3+R6=j-inc
		loadIram({CMP,INCR_0,7'h0,R5,R3,R3});//cmp R3 j with R5 inc
		
		//
		loadIram({JMP,ilabel});//goto next cycle of i
		loadIram({ADD,DECR_0,7'h0,R10,R4,R4});//R4=R4+R10...i+=4
		//a[j] = temp;
		loadIram({STRP,OFFSET_CODE,15'd0,R3,R1});//str R3,[R7+0]
		loadIram({CMP,INCR_0,7'h0,R12,R4,R4});//compare R4 with R12(i == 40) if 0 then reached maximum-> stop
		loadIram({NOP});
	endtask;


	task	shell_first;

	//old
	// for (i = 0; i < 36; i+=4) {
	// temp = a[i+4];
	// for (j = i; (j >= 0) && (a[j] > temp); j -= 4)a[j+4] = a[j];
	// a[j+4] = temp;
		
	//loading instructions
		address=0;
		loadIram({LDRH,16'h0000,R10});//R10 is 4
		loadIram({LDRH,16'hffff,R11});//R11 is -4
		loadIram({LDRH,16'h0000,R12});//R12 is 36
		jmp_label1 = 4*address+4*8;
		loadIram({JMP,jmp_label1});//goto entry point
		
		loadIram({XOR,INCR_0,7'h0,R4,R4,R4});//i base of data
		loadIram({LDRL,16'h0004,R10});//R10 is 4
		loadIram({LDRL,16'hFFFC,R11});//R11 is -4
		loadIram({LDRL,16'h0024,R12});//R12 is 36
		//R4  is i=0 base of data
		//R7  is J
		
		//end of main cycle
		jmpr_label0=4*address;
		jmpr_label1=4*address+32*8;
		
		loadIram({JMPZ,OFFSET_CODE,jmpr_label1,10'h0});//goto to out of main cycle
		loadIram({LDRR,DECR_0,7'h0,R5,R4,R7});//R7 = R4   ->R7 is J		
		//a[j+4] = temp;
		loadIram({STRP,OFFSET_CODE,15'd4,R7,R0});//str R0,[R7+4]
		//main cycle here (I)-------------------------------------------------
		//entry point
		//temp=a[i],  R0 is temp
		loadIram({LDRP,OFFSET_CODE,15'd0,R4,R15});//ldr R0,[R4+0]

		//check j <0
		loadIram({XOR,DECR_0,7'h0,R7,R11,R2});//compare R7 with -4
		loadIram({LDRP,OFFSET_CODE,15'd4,R4,R0});//ldr R0,[R4+4]
		//
		jmp_label1=4*address;
		jmpr_label1=jmpr_label0-4*address-8;
		loadIram({JMPZ,OFFSET_CODE,jmpr_label1,10'h0});//Z=1 when J<0 goto end of main cycle a[j+4] = temp;
		//i+=4
		loadIram({ADD,DECR_0,7'h0,R10,R4,R4});//R4 = R4+4
		loadIram({LDRR,DECR_0,7'h0,R15,R15,R1});//R1=R15
		//check i =36?
		loadIram({XOR,INCR_0,7'h0,R12,R4,R2});//R2=R4^R12(i xor 36) if 0 then reached maximum-> stop		
		//a[j] read
		loadIram({LDRP,OFFSET_CODE,-15'd4,R7,R15});//ldr R15,[R7-4]		
		
		//compare R1(a[j]) with R0(temp)
		loadIram({CMP,INCR_0,7'h0,R0,R1,R2});
		jmpr_label1=jmpr_label0-4*address-8;
		loadIram({JMPC,OFFSET_CODE,jmpr_label1,10'h0});//c=1 then R1<=R0   - (a[j] > temp) is false goto end of subcycle (A[j+4]=temp)
		loadIram({NOP});loadIram({NOP});loadIram({NOP});
		//check i =36?
		loadIram({XOR,INCR_0,7'h0,R12,R4,R2});//R2=R4^R12(i xor 36) if 0 then reached maximum-> stop	
		
		loadIram({JMP,jmp_label1});//goto subcycle
		//j-=4
		loadIram({ADD,DECR_0,7'h0,R7,R11,R7});//R7 = R7-4
		//i-=4
		loadIram({ADD,DECR_0,7'h0,R11,R4,R4});//R4 = R4-4		
		//a[j+4] = a[j](R1);
		loadIram({STRP,OFFSET_CODE,15'd8,R7,R1});//str R1,[R7+4]		A[j+4]=temp
		loadIram({XOR,DECR_0,7'h0,R7,R11,R2});//compare R7 with -4
	
	endtask;

	task	load_unsorted_data(bit[1:0] kind);
	//loading  unsorted data in Dram
		for(int i=0;i<10;i++)
			Dram.sram[i]=(kind==0)?	10-i:			//reverse unsorted
						(kind==1)?	100+$random%100://randomly unsorted
									i+1;			//already sorted
	endtask;
	
	task	start;
		reset=1;
		$display("Programm size is %d Words",address);
		#100;
		reset=0;
		#1us;
		@(posedge	Istop_active);
		$display("Sort finished");
		$display("Cycles for sorting -->%0d<--",cycles);
	endtask;
		
	initial
	begin
		Istop_enable=0;
		Dstop_enable=0;
		verbose=0;
		for(int i=0;i<3;i++)
		begin
			$display("------------------Start round %d------------------",i);
			load_unsorted_data(i);
			$display("Load buble sort...");
			load_buble_sort;
			start;
			
			load_unsorted_data(i);
			$display("Load shell modified...");
			load_shell_sort_mdf;
			start;
			
			load_unsorted_data(i);
			$display("Load shell first...");
			shell_first;
			start;
		
		end
		$finish;
	end
	
	initial
	begin
		clk=0;
		forever #10 clk<=!clk;
	end

	int cycles;
	
	always@(posedge clk or posedge reset)
	if(reset)
		cycles=0;
	else
		cycles=cycles+1;
	
endmodule
