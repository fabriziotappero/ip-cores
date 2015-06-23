----------------------------------------------------------------------------
--  This file is a part of the LM VHDL IP LIBRARY
--  Copyright (C) 2009 Jose Nunez-Yanez
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
--  The license allows free and unlimited use of the library and tools for research and education purposes. 
--  The full LM core supports many more advanced motion estimation features and it is available under a 
--  low-cost commercial license. See the readme file to learn more or contact us at 
--  eejlny@byacom.co.uk or www.byacom.co.uk
-----------------------------------------------------------------------------
-- Entity: 	register_file
-- File:	register_file.vhd
-- Author:	Jose Luis Nunez 
-- Description:	register file that holds the command and the first mv
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use work.config.all;

entity register_file is
generic (integer_pipeline_count : integer);
	port(
	clk : in std_logic;
	clear : in std_logic;
	reset : in std_logic;
	addr : in std_logic_vector(4 downto 0);
	write : in std_logic;
	data_in : in std_logic_vector(31 downto 0);
   data_out : out std_logic_vector(31 downto 0);
	start : out std_logic;
	start_row : out std_logic;
   all_done_qp : in std_logic; -- program completes
      mvc_done : out std_logic; -- all motion vector candidates evaluated
	mvc_to_do : out std_logic_vector(3 downto 0); --mvcs left to do
	all_done_fp : in std_logic; -- fp part completes
	instruction_zero : in std_logic;
	partition_done_fp : in std_logic; -- fp partition terminates
	partition_done_qp : in std_logic; -- qp partition terminates
	done_interrupt : out std_logic;
	mv_cost_on : out std_logic; -- activate the costing of mvs
      mode_out : out mode_type;
	update_fp : in std_logic; -- update mv and sad
      load_mv : in std_logic; -- force the mvc to move foward
	best_sad_fp : in std_logic_vector(15 downto 0);
   best_mv_fp : in std_logic_vector(15 downto 0);
   first_mv_fp : out std_logic_vector(15 downto 0);
	rest_first_mv_fp : out rest_type_displacement;
	mbx_coordinate : out std_logic_vector(7 downto 0);
	mby_coordinate : out std_logic_vector(7 downto 0);
	mvp_x : out std_logic_vector(7 downto 0);
	mvp_y : out std_logic_vector(7 downto 0);
      quant_parameter : out std_logic_vector(5 downto 0);
frame_dimension_x : out std_logic_vector(7 downto 0);
frame_dimension_y : out std_logic_vector(7 downto 0);
partition_count : in std_logic_vector(3 downto 0); --identify the subpartition active
 	update_qp : in std_logic; 
	best_sad_qp : in std_logic_vector(15 downto 0);
   best_mv_qp : in std_logic_vector(15 downto 0);
   first_mv_qp : out std_logic_vector(15 downto 0));
end;

architecture behav of register_file is

component reg_memory_dp
	port (
	addra: in std_logic_vector(4 downto 0);
	addrb: in std_logic_vector(4 downto 0);
	clka: in std_logic;
	clkb: in std_logic;
	dina: in std_logic_vector(31 downto 0);
	doutb: out std_logic_vector(31 downto 0);
	wea: in std_logic);
end component;

type type_register_file is array(4 downto 0) of std_logic_vector(31 downto 0);
type type_register_file_mvc is array(7 downto 0) of std_logic_vector(15 downto 0);
type type_working_register_file is array(1 downto 0) of std_logic_vector(31 downto 0); --one fp wr and one qp wr

signal r,r_in : type_register_file;
signal mvc_r, mvc_r_in : type_register_file_mvc;
signal w_r,w_r_in : type_working_register_file; -- mv and sad change here
signal count_enable_fp,count_enable_fp_in,count_enable_qp,count_enable_qp_in,mem_we,mvc_done_r,mvc_done_r_in : std_logic; -- to enable the profiling counter
signal mem_data_in,mem_data_out : std_logic_vector(31 downto 0);
signal mem_address_a, mem_address_b : std_logic_vector(4 downto 0);
signal mvc_to_do_r, mvc_to_do_r_in, mvc_next, mvc_next_in : std_logic_vector(3 downto 0); -- how many mvcs


begin

mbx_coordinate <= (others => '0');
mby_coordinate <= (others => '0');


frame_dimension_x <= r(1)(15 downto 8);
frame_dimension_y <= r(1)(7 downto 0);
mvp_x <= mvc_r(0)(15 downto 8);
mvp_y <= mvc_r(0)(7 downto 0);

mode_process : process(r(0))

begin

case r(0)(19 downto 16) is

	when "0000" => mode_out <= m16x16;
	when "0001" => mode_out <= m8x8;
	when "0010" => mode_out <= m8x16;
	when "0011" => mode_out <= m16x8;
	when others => mode_out <= m16x16;

end case;

end process;

quant_parameter <= r(0)(26 downto 21);
mv_cost_on <= r(0)(20); -- activate the costing of mv

reg_memory_dp1 : reg_memory_dp
	port map(
	addra => mem_address_a,
	addrb => mem_address_b,
	clka => clk,
	clkb => clk,
	dina => mem_data_in,
	doutb => mem_data_out,
	wea => mem_we
);


read_process: process(addr,w_r,r,mem_data_out,mvc_next)
variable vmem_address_b : std_logic_vector(4 downto 0);
variable vfirst_mv_fp : std_logic_vector(15 downto 0); -- search initial MV
variable vrest_first_mv_fp : rest_type_displacement; -- other initial MV for the rest of the pipelines

begin

vfirst_mv_fp := w_r(0)(31 downto 16); -- normal mode
vmem_address_b := addr;

case mvc_next is -- next_mvc
	when "0000" => vfirst_mv_fp := w_r(0)(31 downto 16); -- normal mode
 			   for i in 1 to (integer_pipeline_count-1) loop
				vrest_first_mv_fp(i) := w_r(0)(31 downto 16); -- normal mode
			   end loop;
	when others => null;
end case;



case addr is

when "00000" =>   data_out <= r(0);  --command register r(0)
when "00001" =>   data_out <= r(1);  -- frame dimensions    
when "00010" =>   data_out <= r(2);  -- profiling register  fp
when "00011" =>   
	if  (CFG_PIPELINE_COUNT_QP = 0) then
		data_out <= (others => '0');
	else
		data_out <= r(3);  -- profiling register  qp
	end if;
when "00100" =>   data_out <= r(4);  -- configuration register: frame number and mv candidate configuration
when others =>   data_out <= mem_data_out;  -- result registers and SAD
end case;

mem_address_b <= vmem_address_b;
first_mv_fp <= vfirst_mv_fp;
rest_first_mv_fp <= vrest_first_mv_fp;
		
end process;

write_process : process(load_mv,mvc_done_r,mvc_next,partition_done_fp,partition_count,count_enable_fp,addr,write,r,data_in,update_fp,best_mv_fp,best_sad_fp,instruction_zero,all_done_fp,update_qp,best_mv_qp,best_sad_qp,all_done_qp)

variable v : type_register_file;
variable mvc_v : type_register_file_mvc;
variable w_v : type_working_register_file; 
variable vimproved_sad,vcount_enable_fp,vcount_enable_qp,vmem_we,vmvc_done : std_logic;
variable vmvc_next,vmvc_to_do : std_logic_vector(3 downto 0);
variable vmem_data_in : std_logic_vector(31 downto 0); 
variable vmem_address_a : std_logic_vector(4 downto 0);

begin

vimproved_sad := '0';
vcount_enable_fp := count_enable_fp;
vcount_enable_qp := count_enable_qp;
vmem_data_in := data_in;
vmem_address_a := addr;
vmem_we := '0';
vmvc_next := mvc_next;
vmvc_done := mvc_done_r;

for i in 7 downto 0 loop 
			mvc_v(i) := mvc_r(i);
end loop;

for i in 4 downto 0 loop 
			v(i) := r(i);
end loop;

for i in 1 downto 0 loop 
	w_v(i) := w_r(i);
end loop;

case addr is

when "00000" => if (write = '1') then -- command register
			v(0) := data_in;
		end if;				
when "00001" => if (write = '1') then  -- frame dimensions
			v(1) := data_in;
		end if;
when "00010" => if (write = '1') then -- profiling register  fp
			v(2) := data_in;
			end if;	
when "00011" => if (write = '1') then    -- profiling register qp
			v(3) := data_in;	
			end if;
when "00100" => if (write = '1') then -- configuration register
			v(4) := data_in;		
		end if;	
when others => null;
    
end case;

if (r(0)(30) = '1') then --reset row start only last one cycle
    v(0)(30) := '0';
end if;


if (r(0)(31) = '1') then --reset start only last one cycle
    	vcount_enable_fp := '1';
	vmvc_done := '0';
	vmvc_next := "0001"; -- pointing to first mvc
	v(2) := (others => '0'); -- reset fp profile register
      v(0)(31) := '0'; 
    -- mv candidates to working registers
      w_v(0) := (others => '0'); -- reset working register
  --  v(1)(15 downto 0) := x"FFFF"; -- reset result register at the start of each macroblock processing
end if;

if (load_mv = '1') then
  		vmvc_next := (others => '0');
end if;    

if (update_fp = '1')  then -- update is used after each instruciton to update mv and sad
	  w_v(0) := best_mv_fp & best_sad_fp;
	
end if;  


vmvc_done := '1';
vmvc_to_do := r(0)(3 downto 0) - (vmvc_next - 1); 

if (partition_done_fp = '1') then
	  vmem_data_in := w_v(0); --results register
	  vmem_we := '1'; 
	  case partition_count is --update results register
	  	when "0000" =>   vmem_address_a := "01110";  -- register 14 result 16x16 (8x8 up-left result) (8x16 left result) (16x8 up result)fp
	  	when "0010" =>   vmem_address_a := "01111";  -- register 15 result 16x16 (8x8 up-right result) (8x16 right result) fp
	  	when "1000" =>   vmem_address_a := "10000";  -- register 16 result 16x16 (8x8 down-left result) (16x8 down result) fp
	  	when "1010" =>   vmem_address_a := "10001";  -- register 17 result 16x16 (8x8 down-right result) fp
		when others => null; 
	  end case;
	  w_v(0) := (others => '0'); -- reset working register for the next subpartition
end if;

if  (CFG_PIPELINE_COUNT_QP = 1) then
if (update_qp = '1') then
     w_v(1) := best_mv_qp & best_sad_qp;
end if;
end if;

if(instruction_zero = '1') then
    v(0)(27) := '1';
end if;    

if(all_done_fp = '1') then
    v(0)(29) := '1';
    w_v(1) := (others => '0'); -- search should start center at zero for qp w_r(0); --move the fp mv,sad to the qp working register
	v(3) := (others => '0'); -- reset qp profile register
    vcount_enable_fp := '0';
    if (instruction_zero = '0') then
    	vcount_enable_qp := '1';
    end if;
end if;

if(all_done_qp = '1') then
    v(0)(28) := '1';
    -- temporal until partition_done_qp is available
    vmem_data_in := w_v(1); --results register
    vmem_we := '1'; 
    vmem_address_a := "10110"; --register 22 stores qp result  
    vcount_enable_qp := '0';
end if;

if (vcount_enable_fp = '1') then
    v(2):= v(2) + 1;
end if;

if  (CFG_PIPELINE_COUNT_QP = 1) then
	if (vcount_enable_qp = '1') then
    	v(3):= v(3) + 1;
	end if;
end if;

if (CFG_USE_MVC = 1) then
	for i in 7 downto 0 loop 
			mvc_r_in(i) <= mvc_v(i);
	end loop;
	mvc_to_do <= vmvc_to_do; -- how many mvcs still to do
	mvc_done_r_in <= vmvc_done;
	mvc_next_in <= vmvc_next;

else
	for i in 7 downto 0 loop 
			mvc_r_in(i) <= (others => '0'); --disable
	end loop;
	mvc_to_do <= (others => '0'); -- how many mvcs still to do
	mvc_done_r_in <= '1';
	mvc_next_in <= (others => '0');
end if;

for i in 4 downto 0 loop 
			r_in(i) <= v(i);
end loop;

for i in 1 downto 0 loop 
			w_r_in(i) <= w_v(i);
end loop;


mem_data_in <= vmem_data_in;
count_enable_fp_in <= vcount_enable_fp;
count_enable_qp_in <= vcount_enable_qp;
mem_address_a <= vmem_address_a;
mem_we <= vmem_we;



end process;
						 

start <= r(0)(31); -- bit 31 activates the me
start_row <= r(0)(30); -- bit 30 indicates starting the row. reset the memory map

first_mv_qp <= w_r(1)(31 downto 16); -- first motion vector for qp
mvc_done <= mvc_done_r_in;


-- the control processor should read the register to know what has happen
--done_interrupt <= r(0)(29) or r(0)(28); -- bit 29 high when fp process completes  or bit 28 high when qp process completes

done0 : if CFG_PIPELINE_COUNT_QP = 1 generate
done_interrupt <= r(0)(28) or (r(0)(29) and r(0)(27)); --instruction zero hit then interrupt high with only fp part 
end generate;

done1 : if CFG_PIPELINE_COUNT_QP = 0 generate
done_interrupt <= r(0)(29);
end generate; 

regs : process(clk,clear)

begin

 if (clear = '1') then
	for i in 4 downto 0 loop 
			r(i) <= (others => '0');
	end loop;
	for i in 7 downto 0 loop 
			mvc_r(i) <= (others => '0');
	end loop;
	for i in 1 downto 0 loop 
			w_r(i) <= (others => '0');
	end loop;
	count_enable_fp <= '0';
	count_enable_qp <= '0';
	mvc_done_r <= '0';
      mvc_next <= (others => '0');
 elsif rising_edge(clk) then 
		if (reset = '1') then -- general enable
			      for i in 4 downto 0 loop 
						r(i) <= (others => '0');
				end loop;
				for i in 7 downto 0 loop 
					mvc_r(i) <= (others => '0');
				end loop;
				for i in 1 downto 0 loop 
						w_r(i) <= (others => '0');
				end loop;
				count_enable_fp <= '0';
				count_enable_qp <= '0';
				mvc_done_r <= '0'; --remember when you have finish with mvc
   			      mvc_next <= (others => '0');
		else
				for i in 4 downto 0 loop 
						r(i) <= r_in(i);
				end loop;
				for i in 7 downto 0 loop 
					mvc_r(i) <= mvc_r_in(i);
				end loop;
				for i in 1 downto 0 loop 
						w_r(i) <= w_r_in(i);
				end loop;
				mvc_done_r <= mvc_done_r_in;
				count_enable_fp <= count_enable_fp_in;
				count_enable_qp <= count_enable_qp_in;
 			      mvc_next <= mvc_next_in;
		end if;
 end if;

end process regs; 

end behav;
