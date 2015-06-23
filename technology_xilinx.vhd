--
--  Technology mapping library. XILINX edition.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
--library xul;

package body technology is
	function to_std_logic_vector(ARG: INTEGER; SIZE: INTEGER) return STD_LOGIC_VECTOR is
		variable RetVal: std_logic_vector(size-1 downto 0) := (others => '0');
		variable L_Arg: integer;
	begin
--		return ul_utils.int_2_std_logic_vector(ARG,SIZE);
		L_Arg := ARG;
		if (L_Arg < 0) then L_Arg := -L_Arg; end if;
		for i in 0 to SIZE-1 loop
			if (L_Arg mod 2) = 1 then
				RetVal(i) := '1';
			end if;
			L_Arg := L_Arg/2;
		end loop;
		-- Compute two's complement if arg was negative
		if (ARG < 0) then
			RetVal := not RetVal;
			RetVal := RetVal+"1";
		end if;
		return RetVal;
	end;

	function to_integer(arg:std_logic_vector) return integer is
	begin
		return CONV_INTEGER(arg);
	end;

--	function add_one(inp : std_logic_vector) return std_logic_vector is
--	begin
--		return inp+"1";
--	end;
--
--	function sub_one(inp : std_logic_vector) return std_logic_vector is
--		variable minus_one: std_logic_vector(inp'RANGE) := (others => '1');
--	begin
--		return inp+minus_one;
--	end;

	function is_zero(inp : std_logic_vector) return boolean is
		variable zero: std_logic_vector(inp'RANGE) := (others => '0');
	begin
		return (inp = zero);
	end;

	function sl(l: std_logic_vector; r: integer) return std_logic_vector is
		variable RetVal : std_logic_vector (l'length-1 downto 0) ;
		variable LL: std_logic_vector(l'length-1 downto 0) := l;
	begin
		RetVal := (others => '0');
		if (ABS(r) < l'length) then
			if (r >= 0) then
				RetVal(l'length-1 downto r) :=  ll(l'length-1-r downto 0);
			else -- (r < 0)
				RetVal(l'length-1+r downto 0) := ll(l'length-1 downto -r);
			end if ;
		end if;
		return RetVal ;
	end sl ;

	function sr(l: std_logic_vector; r: integer) return std_logic_vector is
	begin
		return sl(l,-r);
	end sr;

	function max2(a : integer; b: integer) return integer is
	begin
		if (a > b) then return a; end if;
		return b;
	end max2;

	function min2(a : integer; b: integer) return integer is
	begin
		if (a < b) then return a; end if;
		return b;
	end min2;

	function log2(inp : integer) return integer is
	begin
		if (inp < 1) then return 0; end if;
		if (inp < 2) then return 0; end if;
		if (inp < 4) then return 1; end if;
		if (inp < 8) then return 2; end if;
		if (inp < 16) then return 3; end if;
		if (inp < 32) then return 4; end if;
		if (inp < 64) then return 5; end if;
		if (inp < 128) then return 6; end if;
		if (inp < 256) then return 7; end if;
		if (inp < 512) then return 8; end if;
		if (inp < 1024) then return 9; end if;
		if (inp < 2048) then return 10; end if;
		if (inp < 4096) then return 11; end if;
		if (inp < 8192) then return 12; end if;
		if (inp < 16384) then return 13; end if;
		if (inp < 32768) then return 14; end if;
		if (inp < 65536) then return 15; end if;
		return 16;
	end log2;

	function bus_resize2adr_bits(in_bus : integer; out_bus: integer) return integer is
	begin
		if (in_bus = out_bus) then return 0; end if;
		if (in_bus < out_bus) then return -log2(out_bus/in_bus); end if;
		if (in_bus > out_bus) then return log2(in_bus/out_bus); end if;
	end bus_resize2adr_bits;

	function size2bits(inp : integer) return integer is
	begin
		if (inp <= 1) then return 1; end if;
		if (inp <= 2) then return 1; end if;
		if (inp <= 4) then return 2; end if;
		if (inp <= 8) then return 3; end if;
		if (inp <= 16) then return 4; end if;
		if (inp <= 32) then return 5; end if;
		if (inp <= 64) then return 6; end if;
		if (inp <= 128) then return 7; end if;
		if (inp <= 256) then return 8; end if;
		if (inp <= 512) then return 9; end if;
		if (inp <= 1024) then return 10; end if;
		if (inp <= 2048) then return 11; end if;
		if (inp <= 4096) then return 12; end if;
		if (inp <= 8192) then return 13; end if;
		if (inp <= 16384) then return 14; end if;
		if (inp <= 32768) then return 15; end if;
		if (inp <= 65536) then return 16; end if;
		return 17;
	end size2bits;

	function equ(a : std_logic_vector; b : integer) return boolean is
		variable b_s : std_logic_vector(a'RANGE);
	begin
		b_s := to_std_logic_vector(b,a'HIGH+1);
		return (a = b_s);
	end equ;

end technology;

library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of d_ff is
--	signal clrn,pren: std_logic;
begin
--	clrn <= not clr;
--	pren <= not pre;
	ff: FDCPE port map (
		D => d,
		C => clk,
		CE => ena,
		CLR => clr,
		PRE => pre,
		Q => q
	);
end xilinx;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library wb_tk;
use wb_tk.technology.all;

architecture xilinx of fifo is
	-- One additional bit is added to detect over and under-flow
	signal w_adr : std_logic_vector(adr_width downto 0);  -- internal write address
	signal r_adr : std_logic_vector(adr_width downto 0);  -- internal read address
	signal dont_care : std_logic_vector(dat_width downto 0) := (others => '-');
	signal w_ack, r_ack: std_logic;
begin
	dont_care <= (others => '-');
	
	read_proc : process (r_clk_i, reset)
	begin
		if reset = '1' then
			r_adr     <= (others => '0');
		elsif r_clk_i'event and r_clk_i = '1' then
			if (r_stb_i = '1' and r_we_i = '0' and r_ack = '1') then
				r_adr <= r_adr+"1";
			end if;
		end if;
	end process read_proc;

	write_proc : process (w_clk_i, reset)
	begin
		if reset = '1' then
			w_adr     <= (others => '0');
		elsif w_clk_i'event and w_clk_i = '1' then
			if (w_stb_i = '1' and w_we_i = '1' and w_ack = '1') then
				w_adr <= w_adr+"1";
			end if;
		end if;
	end process write_proc;

	empty_o <= '1' when r_adr = w_adr else '0';
	full_o  <= '1' when (w_adr(adr_width-1 downto 0) = r_adr(adr_width-1 downto 0)) and (w_adr(adr_width) /= r_adr(adr_width)) else '0';
	used_o <= w_adr - r_adr;

	mem_core: dpmem
	generic map (default_out,default_content,adr_width,dat_width,async_read)
	port map (
		a_clk_i   => r_clk_i,
		a_stb_i   => r_stb_i,
		a_we_i    => r_we_i,
		a_adr_i   => r_adr(adr_width-1 downto 0),
		a_dat_i   => dont_care,
		a_dat_o   => r_dat_o,
		a_ack_o   => r_ack,

		b_clk_i   => w_clk_i,
		b_stb_i   => w_stb_i,
		b_we_i    => w_we_i,
		b_adr_i   => w_adr(adr_width-1 downto 0),
		b_dat_i   => w_dat_i,
--		b_dat_o
		b_ack_o   => w_ack
	);
end xilinx;

library ieee;
use ieee.std_logic_1164.all;
library wb_tk;
use wb_tk.technology.all;

architecture xilinx of spmem is
	signal w_ack, r_ack: std_logic;
	signal dont_care : std_logic_vector(dat_width downto 0) := (others => '-');
begin
	dont_care <= (others => '-');

	mem_core: dpmem generic map (default_out,default_content,adr_width,dat_width,async_read)
	port map (
		a_clk_i   => clk_i,
		a_stb_i   => stb_i,
		a_we_i    => we_i,
		a_adr_i   => adr_i,
		a_dat_i   => dont_care,
		a_dat_o   => dat_o,
		a_ack_o   => r_ack,

		b_clk_i   => clk_i,
		b_stb_i   => stb_i,
		b_we_i    => we_i,
		b_adr_i   => adr_i,
		b_dat_i   => dat_i,
--		b_dat_o
		b_ack_o   => w_ack
	);
	ack_o <= ('0' and not stb_i) or (r_ack and (stb_i and not we_i)) or (w_ack and (stb_i and we_i));
end xilinx;
