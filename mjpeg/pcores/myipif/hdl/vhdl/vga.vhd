---------------------------------------------------------------
-- This code is a simplified port from the Verilog sources that can be found here:
-- http://embedded.olin.edu/xilinx_docs/projects/bitvga-v2p.php
-- The Verilog sources are based on code from Xilinx and released under 
-- "Creative Commons Attribution-NonCommercial-ShareAlike 2.5 License"
-- with the note, that Xilinx claims the following copyright:
--  XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
--  SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR
--  XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION
--  AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION
--  OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS
--  IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
--  AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
--  FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
--  WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
--  IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
--  REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
--  INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--  FOR A PARTICULAR PURPOSE.  
-- 
--  (c) Copyright 2004 Xilinx, Inc.
--  All rights reserved.
---------------------------------------------------------------



------------------------------
-- Suffix vga for 25MHz-clock-domain 
------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity vga is
	generic(
		MAX_LINE_COUNT : integer := 479
	);
	port(
		Clk			: in std_logic;
		reset_i		: in std_logic;	
		eoi_i			: in std_logic;	
		
		red_i 		: in STD_LOGIC_VECTOR (7 downto 0);
		green_i		: in  STD_LOGIC_VECTOR (7 downto 0);
		blue_i		: in  STD_LOGIC_VECTOR (7 downto 0);
		width_i		: in  std_logic_vector(15 downto 0);
		height_i		: in  std_logic_vector(15 downto 0);	
		sampling_i	: in  std_logic_vector( 1 downto 0);

		VGA_OUT_PIXEL_CLOCK: 	out STD_LOGIC;
		VGA_COMP_SYNCH: 			out STD_LOGIC;
		VGA_OUT_BLANK_Z: 			out STD_LOGIC;
		VGA_HSYNCH: 				out STD_LOGIC;
		VGA_VSYNCH: 				out STD_LOGIC;
		VGA_OUT_RED: 				out STD_LOGIC_VECTOR (7 downto 0);
		VGA_OUT_GREEN: 			out STD_LOGIC_VECTOR (7 downto 0);
		VGA_OUT_BLUE: 				out STD_LOGIC_VECTOR (7 downto 0);

--		-- chipscope-debugging
--		chipscope_o	: out std_logic_vector(127 downto 0);

		-- flow controll
		datavalid_i :  in std_logic;
		ready_o		: out std_logic
	);
end entity vga;





architecture IMP of vga is


------------------------------------------------------------
-- VGA output
------------------------------------------------------------
  component vga_signals is
	port (
		SYSTEM_CLOCK:     in STD_LOGIC;
		
		VGA_OUT_PIXEL_CLOCK: out STD_LOGIC;
		VGA_COMP_SYNCH: out STD_LOGIC;
		VGA_OUT_BLANK_Z: out STD_LOGIC;
		VGA_HSYNCH: out STD_LOGIC;
		VGA_VSYNCH: out STD_LOGIC;
		
		o_pixel_clock: out STD_LOGIC;
		o_pixel_count: out STD_LOGIC_VECTOR (10 downto 0);
		o_line_count:  out STD_LOGIC_VECTOR (9 downto 0)
	);
  end component vga_signals;
------------------------------------------------------------ 





------------------------------------------------------------ 
-- VGA Memory Buffer
------------------------------------------------------------ 
	component vga_memory
		port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(7 downto 0);
		addra: IN std_logic_VECTOR(14 downto 0);
		wea: IN std_logic_VECTOR(0 downto 0);
		clkb: IN std_logic;
		addrb: IN std_logic_VECTOR(14 downto 0);
		doutb: OUT std_logic_VECTOR(7 downto 0));
	end component;
------------------------------------------------------------ 





	-- Clock domain crossing
	signal eoi, vga_eoi, vga_eoi_D : std_logic :='0';														-- opb-Clk -> vga-clk
	signal reset, vga_reset, vga_reset_D : std_logic :='0';												-- opb-Clk -> vga-clk
	signal reset_hold, reset_hold_D : std_logic_vector(3 downto 0) :=(others=>'0');
	signal width, vga_width, vga_width_D : std_logic_vector(15 downto 0) :=(others=>'0');		-- opb-Clk -> vga-clk
	signal height, vga_height, vga_height_D : std_logic_vector(15 downto 0) :=(others=>'0');	-- opb-Clk -> vga-clk
	signal sampling, vga_sampling, vga_sampling_D : std_logic_vector(1 downto 0) := (others=>'0');			-- opb-Clk -> vga-clk
	signal vga_pixel_count : std_logic_vector(10 downto 0) := (others=>'0');	-- vga-clk -> OPB-clk
	signal line_count,  line_count_D,  vga_line_count  : std_logic_vector(9 downto 0) := (others=>'0');	-- vga-clk -> OPB-clk

	signal memory_select, memory_select_D : std_logic :='0'; 											-- vga-clk -> OPB-clk
	signal vga_memory_select, vga_memory_select_D : std_logic :='0';
	
	signal vga_out_of_picture, vga_out_of_picture_D : std_logic :='0';

	signal blocks_per_line, blocks_per_line_D : std_logic_vector(7 downto 0); 						-- opb-Clk -> vga-clk
	signal vga_blocks_per_line, vga_blocks_per_line_D : std_logic_vector(7 downto 0);

	-- OPB-Clk 
	signal stop_writing, stop_writing_D : std_logic :='1';
	signal ready, ready_D : std_logic :='0';
	signal last_memory_select, last_memory_select_D : std_logic :='0';
	signal memory_addra, memory_addra_D : std_logic_vector(13 downto 0) :=(others=>'0');
	signal memory_addra_final : std_logic_vector(14 downto 0) :=(others=>'0');

	-- vga-clk
	signal vga_pixel_clock : std_logic :='0';
	signal vga_out_blank_z_intern : std_logic :='0';
	signal vga_memory_red, vga_memory_green, vga_memory_blue : std_logic_vector(7 downto 0) :=(others=>'0');
	signal vga_memory_addrb, vga_memory_addrb_D : std_logic_vector(13 downto 0) :=(others=>'0');
	signal vga_memory_addrb_final : std_logic_vector(14 downto 0) :=(others=>'0');
	signal vga_last_line_count, vga_last_line_count_D : std_logic :='0';



begin



-- **********************************************************************************************
-- * Wires
-- **********************************************************************************************
--chipscope_o	<= red_i & green_i & blue_i & sampling_i & eoi_i & reset_i & datavalid_i & '0' & ready & vga_out_of_picture &
--					vga_memory_red & vga_memory_green & vga_memory_blue & vga_out_blank_z_intern & (vga_out_blank_z_intern and not vga_out_of_picture and not vga_reset) & "000000" &
--					X"0" & blocks_per_line & memory_addra_final & vga_memory_addrb_final &
--					"0" & vga_pixel_count & vga_line_count;

--VGA_OUT_RED 	<= vga_memory_red;
--VGA_OUT_GREEN	<= memory_addra_final(14 downto 7);
--VGA_OUT_BLUE	<= vga_memory_addrb(7 downto 0);
VGA_OUT_RED 	<= vga_memory_red;
VGA_OUT_GREEN	<= vga_memory_green;
VGA_OUT_BLUE	<= vga_memory_blue;

VGA_OUT_BLANK_Z <= vga_out_blank_z_intern and not vga_out_of_picture and not vga_reset;

eoi 		<= eoi_i;
width 	<= width_i;
height	<= height_i;
sampling	<= sampling_i;
ready_o	<= ready;
reset		<= reset_i;





-- **********************************************************************************************
-- * OPB-Clk domain (100 MHz)
-- **********************************************************************************************
-- to control writing
process(line_count, eoi, stop_writing, height)
begin
	stop_writing_D <= stop_writing;
	if (line_count=0) then
		stop_writing_D <= '0';
	end if;
	if (line_count= MAX_LINE_COUNT or line_count=height-1) then		-- maybe height-1
		stop_writing_D <='1';
	end if;
end process;
process(Clk)
begin
	if rising_edge(Clk) then
		if (reset='1' or eoi='1') then
			stop_writing <= '1';
		else
			stop_writing <= stop_writing_D;
		end if;
	end if;
end process;


--------------------------------------------------------------
-- Calc blocks per line - this is necessary because jpeg fills
-- the picture on the right (and bottom) side to have a width 
-- (and height) that is a multiple of 8
--------------------------------------------------------------
process(width, sampling)
begin
	case sampling is

	when "01" | "10" => 												-- 4:2:2 and 4:2:0
		if width(3 downto 0)="0000" then
			blocks_per_line_D <= width(11 downto 4);
		else
			blocks_per_line_D <= width(11 downto 4) + 1;
		end if;

	when others =>														-- 4:4:4 and gray
		if width(2 downto 0)="000" then
			blocks_per_line_D <= width(10 downto 3);
		else
			blocks_per_line_D <= width(10 downto 3) + 1;
		end if;

	end case;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
		blocks_per_line	<= blocks_per_line_D; 
	end if;
end process;
--------------------------------------------------------------


--------------------------------------------------------------
-- Calc the write-address for vga_memory
--------------------------------------------------------------

process(memory_addra, datavalid_i, ready, memory_select, last_memory_select)
begin
	last_memory_select_D <= memory_select;
	memory_addra_D <= memory_addra;
	
	if(memory_select /= last_memory_select) then
		memory_addra_D <= (others=>'0');
	elsif (datavalid_i='1' and ready='1') then
		memory_addra_D <= memory_addra + 1;
	end if;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
		last_memory_select <= last_memory_select_D;
		if reset='1' or eoi='1' then
			memory_addra <= (others=>'0');
		else 
			memory_addra <= memory_addra_D;
		end if;
	end if;
end process;
--------------------------------------------------------------

--------------------------------------------------------------
-- calc vga-ready
--------------------------------------------------------------
process(memory_addra, ready, blocks_per_line, sampling, stop_writing)
begin
	ready_D <= ready;
	
	case sampling is
	when "01" =>
		if( (memory_addra = (blocks_per_line & "00000000") ) or
			 (stop_writing='1') ) then
			ready_D <= '0';
		end if;
	when "10" =>
		if( (memory_addra = (blocks_per_line & "0000000") ) or
			 (stop_writing='1') ) then
			ready_D <= '0';
		end if;
	when others =>
		if( (memory_addra = (blocks_per_line & "000000") ) or
			 (stop_writing='1') ) then
			ready_D <= '0';
		end if;
	end case;
	
	if(memory_addra = 0 and stop_writing='0') then
		ready_D <= '1';
	end if;
end process;

process(Clk)
begin
	if rising_edge(Clk) then
		if reset='1' or eoi='1'then
			ready <= '0';
		else
			ready <= ready_D;
		end if;
	end if;
end process;
--------------------------------------------------------------







-- **********************************************************************************************
-- * Clock Domain Crossing
-- **********************************************************************************************

------------------------------------------------------------
-- Dual port bram for data   (opb-clk -> vga-clk)
------------------------------------------------------------
vga_memory_red_p:vga_memory
	port map (
		clka	=> Clk,
		dina	=> red_i,
		addra	=> memory_addra_final,
		wea(0)=> datavalid_i,
		clkb	=> vga_pixel_clock,
		addrb	=> vga_memory_addrb_final,
		doutb	=> vga_memory_red
	);
vga_memory_green_p:vga_memory
	port map (
		clka	=> Clk,
		dina	=> green_i,
		addra	=> memory_addra_final,
		wea(0)=> datavalid_i,
		clkb	=> vga_pixel_clock,
		addrb	=> vga_memory_addrb_final,
		doutb	=> vga_memory_green
	);
vga_memory_blue_p:vga_memory
	port map (
		clka	=> Clk,
		dina	=> blue_i,
		addra	=> memory_addra_final,
		wea(0)=> datavalid_i,
		clkb	=> vga_pixel_clock,
		addrb	=> vga_memory_addrb_final,
		doutb	=> vga_memory_blue
	);

memory_addra_final 	  <=     memory_select 		& (memory_addra);
vga_memory_addrb_final <= not vga_memory_select & vga_memory_addrb;
------------------------------------------------------------



------------------------------------------------------------
-- vga-clk -> opb-clk
------------------------------------------------------------
process(Clk)
begin
	if rising_edge(Clk) then

		line_count_D			<= vga_line_count;
		line_count 				<= line_count_D;

		memory_select_D		<= vga_memory_select;
		memory_select			<= memory_select_D;

	end if;
end process;
------------------------------------------------------------



------------------------------------------------------------
-- opb-clk -> vga-clk
------------------------------------------------------------
process(vga_pixel_clock)
begin
	if rising_edge(Clk) then

		vga_sampling_D	<= sampling;
		vga_sampling	<= vga_sampling_D;

		vga_width_D	<= width;
		vga_width	<= vga_width_D;

		vga_height_D<= height;
		vga_height	<= vga_height_D;

	end if;	
end process;
------------------------------------------------------------








-- **********************************************************************************************
-- * VGA-Clock-Domain (25 MHz)
-- **********************************************************************************************

------------------------------------------------------------
-- Generate VGA-Signals and VGA-Clock
------------------------------------------------------------
vgacard:vga_signals
	Port map (
		SYSTEM_CLOCK 			=> Clk,
	
		VGA_OUT_PIXEL_CLOCK 	=> VGA_OUT_PIXEL_CLOCK,	
		VGA_COMP_SYNCH 		=> VGA_COMP_SYNCH,
		VGA_OUT_BLANK_Z 		=> vga_out_blank_z_intern,
		VGA_HSYNCH 				=> VGA_HSYNCH,
		VGA_VSYNCH 				=> VGA_VSYNCH,
		o_pixel_clock			=> vga_pixel_clock,
		o_pixel_count			=> vga_pixel_count,
		o_line_count			=> vga_line_count
	);
------------------------------------------------------------

--------------------------------------------------------------
-- is VGA-Coordinate "outside of the picture"?
--------------------------------------------------------------
process(vga_pixel_count, vga_line_count, vga_height, vga_width)
begin
	if( (vga_pixel_count-1 >= vga_width) or (vga_line_count-16 >= vga_height) ) then					-- TODO
		vga_out_of_picture_D <= '1';
	else
		vga_out_of_picture_D <= '0';
	end if;
end process;

process(vga_pixel_clock)
begin
	if rising_edge(vga_pixel_clock) then
		vga_out_of_picture <= vga_out_of_picture_D;
	end if;
end process;
--------------------------------------------------------------


--------------------------------------------------------------
-- Calc the read-address for vga_memory 
--------------------------------------------------------------
process(vga_memory_addrb, vga_memory_select, vga_pixel_count, vga_line_count, vga_sampling)
begin

	vga_last_line_count_D <= vga_line_count(0);
	vga_memory_select_D <= vga_memory_select; 
	vga_memory_addrb_D	<= vga_memory_addrb;
	
	case vga_sampling is
	when "01" =>		-- 4:2:0
		if ( vga_line_count(3 downto 0) = "0000" and vga_last_line_count /= vga_line_count(0)) then
			vga_memory_select_D	<= not vga_memory_select; 
			vga_memory_addrb_D	<= (others=>'0');
		elsif (vga_last_line_count /= vga_line_count(0)) then
			vga_memory_addrb_D	<= "000000" & (vga_line_count(3 downto 0)) & "0000";
		elsif ( vga_pixel_count(3 downto 0)="0000" ) then
			vga_memory_addrb_D	<= vga_memory_addrb + 241;
		else
			vga_memory_addrb_D	<= vga_memory_addrb + 1;
		end if;
	when "10" =>		-- 4:2:2
		if ( vga_line_count(2 downto 0) = "000" and vga_last_line_count /= vga_line_count(0)) then
			vga_memory_select_D	<= not vga_memory_select; 
			vga_memory_addrb_D	<= (others=>'0');
		elsif (vga_last_line_count /= vga_line_count(0)) then
			vga_memory_addrb_D	<= "0000000" & (vga_line_count(2 downto 0)) & "0000";
		elsif ( vga_pixel_count(3 downto 0)="0000" ) then
			vga_memory_addrb_D	<= vga_memory_addrb + 113;
		else
			vga_memory_addrb_D	<= vga_memory_addrb + 1;
		end if;
	when others=>		-- gray or 4:4:4
		if ( vga_line_count(2 downto 0) = "000" and vga_last_line_count /= vga_line_count(0)) then
			vga_memory_select_D	<= not vga_memory_select; 
			vga_memory_addrb_D	<= (others=>'0');
		elsif (vga_last_line_count /= vga_line_count(0)) then
			vga_memory_addrb_D	<= "00000000" & (vga_line_count(2 downto 0)) & "000";
		elsif ( vga_pixel_count(2 downto 0)="000" ) then
			vga_memory_addrb_D	<= vga_memory_addrb + 57;
		else
			vga_memory_addrb_D	<= vga_memory_addrb + 1;
		end if;
	end case;

end process;

process(vga_pixel_clock)
begin
	if rising_edge(vga_pixel_clock) then
			vga_last_line_count <= vga_last_line_count_D;
			vga_memory_select	<= vga_memory_select_D; 
			vga_memory_addrb	<= vga_memory_addrb_D;
	end if;
end process;
--------------------------------------------------------------



end IMP;
