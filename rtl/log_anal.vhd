-- logic analyser (LA) for FPGAs
-- ver 1.0
-- Author: Ernest Jamro

--//////////////////////////////////////////////////////////////////////
--//// Copyright (C) 2001 Authors and OPENCORES.ORG                 ////
--////                                                              ////
--//// This source file may be used and distributed without         ////
--/// restriction provided that this copyright statement is not    ////
--//// removed from the file and that any derivative work contains  ////
--//// the original copyright notice and the associated disclaimer. ////
--////                                                              ////
--//// This source file is free software; you can redistribute it   ////
--//// and/or modify it under the terms of the GNU Lesser General   ////
--//// Public License as published by the Free Software Foundation; ////
--//// either version 2.1 of the License, or (at your option) any   ////
--//// later version.                                               ////
--////                                                              ////
--//// This source is distributed in the hope that it will be       ////
--//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
--//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
--//// PURPOSE. See the GNU Lesser General Public License for more  ////
--//// details.                                                     ////
--////                                                              ////
--//// You should have received a copy of the GNU Lesser General    ////
--//// Public License along with this source; if not, download it   ////
--//// from <http://www.opencores.org/lgpl.shtml>                   ////


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- logic analyser (LA) - probes signals states every rising clk, before/after the triger sequence

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity log_anal is
  generic(data_width: integer:= 16; -- width of the data that are analysed (must be power of 2)
      mem_adr_width: integer:= 9; -- internal memory address width
	  adr_width: integer:= 11; -- adr_I address width
      trig_width: integer:= 8; -- width of the triger logic
	  two_clocks: integer:= 0); -- two seperate clocks for control interface and logic analyser
  -- the following rules must!!! be satysfied for generic:
  -- data_width= 8, 16 or  32
  -- adr_width= mem_adr_width + 1 + log2(data_width/8); 4<=mem_adr_width<=16
  -- mem_adr_width<=16
  -- trig_width<= 32
  -- two_clocks= 0 (only wb_clk_I clock is used) 1- f_clk= k*f_wb_clk_I, 2- two asynchronous clocks
  
  -- mem_adr_width optimal selection for 4kb BRAM (Virtex): 
  --  mem_adr_width<= 9 then number of BRAM block used= data_width/8
    
  port (arst: in std_logic; -- global asynchronous set reset signal (mainly for simulation purposes)
	  -- interface for logic analyser 
	  clk: in std_logic; -- seperate clock for logic analyzer (the same as wb_clk_I when two_clocks= 0)
	  data: in std_logic_vector(data_width-1 downto 0); -- data that are analysied
	  ce_data: in std_logic; -- clock enable -- should be used if data are recorded e.g. every second la_clk
      trig: in std_logic_vector(trig_width-1 downto 0); -- triger bus (can be different that data bus
	  ce_trig: in std_logic; -- clock enable for triger bus
	  -- control WISHBOBE slave interface - interface for setting logic analyser options and transfering analysed data to computer
      wb_clk_I: in STD_LOGIC; -- clock (common for every logic every logic analyser signals) - common for loagic analyser and WISHBONE control interface
	  wb_adr_I: in std_logic_vector(adr_width-1 downto 0); -- address bus (one bit wider than mem_adr_width)
	  wb_dat_I: in std_logic_vector(7 downto 0);
	  wb_dat_O: out std_logic_vector(7 downto 0);
	  wb_stb_I, wb_we_I: in std_logic; 
	  -- wb_cyc_I: in std_logic; -- signal is ignored
	  -- wb_rst_I: in std_logic; -- the WISHBONE interface need not be reseted
	  wb_ack_O: buffer std_logic); 
end log_anal;

architecture LA of log_anal is
 -- TECHNOLOGY DEPENDENT MEMORY
 component la_mem				  
  generic ( data_width: integer:= 8; -- width of the data (la interface)
    mem_adr_width: integer:= 9; -- width of the address (address width cannot be greater than max_address width (for data_width=1)
  	c_adr_width: integer:= 9; -- control interface address width = adr_width + log2(data_width/8)
	two_clocks: integer:= 0 -- one or two seperate clocks are used
	); 
  port (arst: in std_logic; -- asynchronous reset (mainly for simulation purposes
    -- first port interface (for control and data read)
	c_clk: in std_logic; -- clock
	c_do: out std_logic_vector(7 downto 0); -- control interface signals
	c_adr: in std_logic_vector(c_adr_width-1 downto 0);
    -- second port for logic analyser data write
	la_clk: in std_logic; -- clock (ignored when two_clocks=0)
	la_we: in std_logic; -- write enable
    la_di: in std_logic_vector(data_width-1 downto 0); 
  	la_adr: in std_logic_vector(mem_adr_width-1 downto 0));
  end component;
 
  component la_trigger
	generic (trig_width: integer); -- width of the trig data 1<=trig_width<=32
	port (clk, arst: in std_logic;
	-- LA interface
	trig_data: in std_logic_vector(trig_width-1 downto 0); -- data that are alasysed for triger
	trig_now: out std_logic; -- triger data is now presented on the trig_data bus
	-- Control interface (to set and read triger values)
	wr: in std_logic; -- when 1 writes din to triger configuration registers
	adr: in std_logic_vector(3 downto 0);
	dout: out std_logic_vector(7 downto 0);
	din: in std_logic_vector(7 downto 0) );
  end component;
  
  signal ackR: std_logic; -- ack_O for (mainly for memory access)
  signal data_q: std_logic_vector(data_width-1 downto 0); -- flip-flop to allow better routing of the data bus (the LA less influences Place&Route program)
  signal trig_q: std_logic_vector(trig_width-1 downto 0); -- similar like data_q but for triger
  signal ce_data_q: std_logic; -- flip-flop for clock enable signal
  -- control signals
  signal run: std_logic; -- LA is now acquiring new data (after triger has been found)
  signal status_reg: std_logic_vector(7 downto 0); -- status register that will be read 
  signal trig_now: std_logic; -- proper triger is now presented at the trig input
  signal trig_wr: std_logic; -- write to the triger configuration register
  signal trig_datR: std_logic_vector(7 downto 0); -- read data form configuration register
  signal wr_trig_counter: std_logic; -- a write to trig counter is done by the control interface
  signal mem_we: std_logic; -- memory write enable
  -- signals read/written by control interace
  signal wb_reg_wr, wb_reg_wr_q: std_logic; -- wishbone writes to an internal control register (clock sinchronisation is considered)
  signal reg_do, reg_do_q: std_logic_vector(7 downto 0); -- internal registers data out (according to the wb_adr_I
  signal mem_do: std_logic_vector(7 downto 0); -- memory output data
  signal counter: std_logic_vector(mem_adr_width-1 downto 0); -- counter which runs continuosly untill the LA finishes data acquisition
  -- this counter point to the current data write possition, should be read to show the start (end) point for data reading
  signal counter_rd: std_logic_vector(15 downto 0); -- like counter but MSBs are fill with zeros
  signal trig_counter: std_logic_vector(mem_adr_width downto 0); -- counter which shows how much 
  -- data is still to be acquired, "10000..0"- full, "00..0"-empty
  -- this counter can be written to point the triger position: "100..0" - do not triger
  -- "011..1"- triger at the end, "00..0"- triger at the beginning, "0100..0"- triger at the half, "0XXXXX" - somewhere between
  signal trig_counter_down: std_logic_vector(mem_adr_width downto 0); -- this counter checkes that
    -- the proper number of data before the triger have been already recorded
    -- this counter is especially importent when triger is at the end of the recorded data
	-- therefore the data before the triger has to be written just before the triger (not a random data from the previous record)
  type sel_type is (s_mem_data, s_status_reg, s_counter, s_triger, s_none); -- which device is selected
  signal sel_dev: sel_type;
begin
-----------------------------------------------------------
-- clock synchronisation region
	-- la_clk and stb_i_q selection
  clk_g0: if two_clocks=0 generate
	  reg_do_q<= reg_do;
	  wb_reg_wr<= wb_we_i and wb_stb_i;
  	  wb_ack_O<= wb_stb_i and ackR; 
    end generate;

  clk_g1: if two_clocks>0 generate
	  -- wb_reg_wr flip-flop
	  process(clk, arst) begin
		if arst='1' then wb_reg_wr<= '0';
		elsif clk'event and clk='1' then
		  if wb_we_i='1' and -- write
			 ackR='1' and -- wait for one whole wb_clk_I cycle
			 wb_reg_wr='0' and wb_reg_wr_q='0' then-- wb_reg_wr is active only for one clk cycle
			    wb_reg_wr<= '1'; 
		  else 
			    wb_reg_wr<= '0';
		  end if;
		end if;
	  end process;

	  -- wb_reg_wr_q flip-flop
	  process(clk, arst, ackR) begin
		if arst='1' or ackR='0' then -- ackR='0' if stb_i=0 or in the previous wb_clk a data transfer took place
			wb_reg_wr_q<= '0';
		elsif clk'event and clk='1' then
		   if wb_reg_wr='1' then
			 wb_reg_wr_q<= '1'; -- wait for asynchronous reset
		   end if;	
		end if;
	  end process;
	  -- reg_do_q flip-flops
	  process(wb_clk_I, arst) begin
		 if arst='1' then reg_do_q<="00000000";
		 elsif wb_clk_i='1' and wb_clk_i'event then
			 reg_do_q<= reg_do;
		 end if;
	  end process;

     
	wb_ack_O<= wb_stb_i and ackR when wb_we_i='0'   -- for control register read and memory read
	  else wb_stb_i and wb_reg_wr_q; -- for control register write
	  
  end generate; -- two_clocks>1

--------------------------------------------------------------
-- logic analyzer data region 
  -- data flip-flops
  process(arst, clk) begin
	if arst='1' then data_q<= (others=>'0');
	elsif clk'event and clk='1' then
	  data_q<= data;
	end if;
  end process;
  -- triger flip-flops
  process(arst, clk) begin
	if arst='1' then trig_q<= (others=> '0');
	elsif clk'event and clk='1' then
	  if ce_trig='1' then
		trig_q<= trig;
	  end if;
	end if;
  end process;
  -- clock enable for data
  process(arst, clk) begin
	if arst='1' then ce_data_q<= '0';
	elsif clk'event and clk='1' then 
		ce_data_q<= ce_data;
	end if;
  end process;
  -- counter (increased every clk when analysed data are writen to memory)
  process(arst, clk) begin
	if arst='1' then counter<= (others=>'0');
	elsif clk'event and clk='1' then
	  if trig_counter(mem_adr_width)='0' and ce_data_q='1' then -- when data acquisition has not been finished
		 counter<= counter + 1;
	  end if;
	end if;
  end process;

  -- trig_counter (shows how many analysed data are still to be recorded) recording stops if the counter is overflowed
  process(arst, clk) begin
	if arst='1' then trig_counter<= (others=>'0');
	elsif clk'event and clk='1' then
      if wr_trig_counter='1' then
		  if mem_adr_width>=6 then
		    trig_counter(mem_adr_width downto mem_adr_width-6)<= wb_dat_i(6 downto 0); -- write only 7 MSBs of the trig_counter 
		    trig_counter(mem_adr_width-7 downto 0)<= (others=> '0');
		  else 
			trig_counter<= wb_dat_i(6 downto 6-mem_adr_width);
		  end if;
	  elsif run='1' and ce_data_q='1' then -- acquisition is not finished
		  trig_counter<= trig_counter + 1;
	  end if;
	end if;
  end process;
  -- trig counter down - triger is enable when a proper number of data before triger has been recorded
  process(arst, clk) begin
	if arst='1' then trig_counter_down<= (others=>'0');
	elsif clk'event and clk='1' then
	  if wr_trig_counter='1' then
		  if mem_adr_width>=6 then 
		    trig_counter_down(mem_adr_width downto mem_adr_width-6)<= wb_dat_i(6 downto 0); -- write only 7 MSBs of the trig_counter 
		    trig_counter_down(mem_adr_width-7 downto 0)<= (others=> '0');
		  else --mem_adr_width< 6
			trig_counter_down<= wb_dat_i(6 downto 6-mem_adr_width);
		  end if;
	  elsif trig_counter_down(mem_adr_width)='0' and ce_data_q='1' then -- not enought data has been written to the memory before the triger
		  trig_counter_down<= trig_counter_down - 1;
	  end if;
	end if;
  end process;
  -- run logic
  process(arst, clk) begin
	if arst='1' then run<='0';
	elsif clk'event and clk='1' then
	  if wr_trig_counter='1' then
		  run<= wb_dat_i(7); -- remember that if datW(7)=1 then datW(6 downto 0) should be "00..0"
	  elsif trig_counter(mem_adr_width)='1' then
		  run<= '0'; -- whole memory have been written
	  elsif trig_now='1' and trig_counter_down(mem_adr_width)='1' then -- activate run only if proper number of data has been recorded before the triger
		  run<= '1';
	  end if;
	end if;
  end process;	
  wr_trig_counter<= '1' when sel_dev = s_status_reg and wb_reg_wr='1' else '0';
  
		  
  ----- triger logic
  trigger: la_trigger
	generic map (trig_width=>trig_width)
	port map (clk=>clk, arst=> arst, trig_data=> trig_q, trig_now=> trig_now, 
	-- Control interface (to set and read triger values)
	wr=> trig_wr, adr=> wb_adr_I(3 downto 0), dout=> trig_datR, din=> wb_dat_I);
	
  trig_wr<= '1' when wb_reg_wr='1' and sel_dev=s_triger else '0';
  

  -- addrss space
  -- 0-1FF - main LA memory (for a single BRAM 4kb)
  -- 200 control registers based address
  -- 200 - status (b7=run, b6= finish, b5-b0 - triger start, 111111- at the end, 000001- at the beginning
  -- 204 - stop counter - points where the last recorded data is in the LA main memory
  -- 208-20B - trigger value (0- triger when 0, 1- triger when the trig data is 1)
  -- 20C-20F - trigger consider (0- do not care about the input (X), 1- consider the input bit)
  
  sel_dev<= s_mem_data when wb_adr_I(adr_width-1)='0' else -- data memory
      s_triger when wb_adr_I(3)='1' else
	  s_counter when wb_adr_I(2 downto 1)= "10" else
      s_status_reg when wb_adr_I(2 downto 0)= "000" else
	  s_none;
	  
	    
  mem_we<= ce_data_q and not trig_counter(mem_adr_width); -- when valid data and not whole buffer written
  -- memory block
  mem:  la_mem				  
  generic map (data_width=> data_width, mem_adr_width=> mem_adr_width, 
      c_adr_width=> adr_width-1, two_clocks=> two_clocks)
	port map (arst=> arst, c_clk=> wb_clk_I, c_do=> mem_do, 
	   c_adr=> wb_adr_I(adr_width-2 downto 0), 
      -- second port for logic analyser data write
	  la_clk=> clk, la_we=> mem_we, la_di=> data_q, la_adr=> counter);
  
  -- read registers
  counter_rd(mem_adr_width-1 downto 0)<= counter;
  gc15: if mem_adr_width<=15 generate -- fill MSB of counter width 0s
	  counter_rd(15 downto mem_adr_width)<= (others=> '0');
  end generate;
  -- status register
  gs8: if mem_adr_width>=6 generate
    status_reg<= run & trig_counter(mem_adr_width downto mem_adr_width-6);
  end generate;
  gs7: if mem_adr_width<= 5 generate
	status_reg(7 downto 6-mem_adr_width)<= run & trig_counter;
	status_reg(5-mem_adr_width downto 0)<= (others=>'0');
  end generate;
  
  -- data out multiplexer
  wb_dat_o<= mem_do when sel_dev=s_mem_data else -- memory is clocked by wb_clk_I so need not additional register
	  reg_do_q; -- reg_out is registered only when two_clocks=1
  
  reg_do<= trig_datR when sel_dev= s_triger else
	counter_rd(15 downto 8) when sel_dev= s_counter and wb_adr_I(0)='1' else
	counter_rd(7 downto 0) when sel_dev= s_counter and wb_adr_I(0)='0' else
	status_reg when sel_dev = s_status_reg else
	"00000000";
	  
  -- ackR logic (ack_O for reading)	 BRAM needs 2 clock cycles for reading
  process(arst, wb_clk_I) begin
	if arst='1' then ackR<= '0';
	elsif wb_clk_I'event and wb_clk_I='1' then
	  ackR<= not wb_ack_O and wb_stb_I; -- strobe is active (valid address) and not data transfer
	end if;
  end process;
		  
-- check generic values:
  	assert data_width=32 or data_width=16 or data_width=8
	  report "Error in log_anal: data_width must be: 8, 16 or 32"
 		severity failure; 
   	assert mem_adr_width<=16 and mem_adr_width>=4
	   report "Error in log_anal: mem_adr_width must not be in range 4 to 16"
   		severity failure; 
   	assert (adr_width = mem_adr_width+1 and data_width=8) or
	   (adr_width = mem_adr_width+2 and data_width=16) or
	   (adr_width = mem_adr_width+3 and data_width=32)
	   report "Error in log_anal: c_adr_width should be: adr_width + 1 + log2(data_width/8)"
   	   severity failure; 
	assert trig_width<=32 
	  report "Error in log_anal: trig_width must not be greater than 32"
	  severity failure; 
end LA;		
