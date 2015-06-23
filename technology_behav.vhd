--
--  Technology mapping library. Behavioral edition.
--  Contains technology primitive implementations in a behavioral,
--  thus not 100% synthetizable form. Use this library to functional verification
--  and as a specification of thecnology primitives when porting to a particular
--  technology.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

package body technology is
	function to_std_logic_vector(ARG: INTEGER; SIZE: INTEGER) return STD_LOGIC_VECTOR is
		variable RetVal: std_logic_vector(size-1 downto 0) := (others => '0');
		variable L_Arg: integer;
	begin
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


--	function "+"(op_l, op_r: std_logic_vector) return std_logic_vector is
--	begin
--	 	return to_std_logic_vector(to_integer(op_l)+to_integer(op_r),max2(op_l'length, op_r'length));
--	end;
--
--	function "-"(op_l, op_r: std_logic_vector) return std_logic_vector is
--	begin
--	 	return to_std_logic_vector(to_integer(op_l)-to_integer(op_r),max2(op_l'length, op_r'length));
--	end;
--
--	function add_one(inp : std_logic_vector) return std_logic_vector is
--	begin
--		return to_std_logic_vector(to_integer(inp)+1,inp'length);
--	end;
--
--	function sub_one(inp : std_logic_vector) return std_logic_vector is
--	begin
--		return to_std_logic_vector(to_integer(inp)-1,inp'length);
--	end;

	function is_zero(inp : std_logic_vector) return boolean is
		variable zero: std_logic_vector(inp'RANGE) := (others => '0');
	begin
--		return std_logic_unsigned."="(inp,zero);
		return inp = zero;
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
	end;

	function min2(a : integer; b: integer) return integer is
	begin
		if (a < b) then return a; end if;
		return b;
	end;

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
	end;

	function bus_resize2adr_bits(in_bus : integer; out_bus: integer) return integer is
	begin
		if (in_bus = out_bus) then return 0; end if;
		if (in_bus < out_bus) then return -log2(out_bus/in_bus); end if;
		if (in_bus > out_bus) then return log2(in_bus/out_bus); end if;
	end;

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
	end;

	function equ(a : std_logic_vector; b : integer) return boolean is
		variable b_s : std_logic_vector(a'RANGE);
	begin
		b_s := to_std_logic_vector(b,a'HIGH+1);
		return a = b_s;
	end;

end technology;

library IEEE;
use IEEE.std_logic_1164.all;

architecture behavioral of d_ff is
	signal l_q: STD_LOGIC := 'X';
begin
	d_ff: process 
		variable clrpre: std_logic_vector(1 downto 0);
	begin
		wait until clk'EVENT or clr'EVENT or pre'EVENT;
		clrpre := clr & pre;
		case clrpre is
			when "10" =>
				l_q <= '0';
			when "01" =>
				l_q <= '1';
			when "11" =>
				--assert true report "Set and preset cannot be active at the same time" severity error;
				l_q <= 'X';
			when "00" =>
				if (clk'EVENT) then
					if (clk = '1') then
						if (ena = '1') then
							l_q <= d;
						else
							if (ena /= '0') then
								l_q <= 'X';
							end if;
						end if;
					end if;
				end if;
			when others =>
				l_q <= 'X';
		end case;
	end process;
	q <= l_q;

end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library wb_tk;
use wb_tk.technology.all;

architecture behavioral of dpmem is
	type data_array is array (integer range <>) of std_logic_vector(dat_width-1 downto 0);         -- Memory Type
	signal data : data_array(0 to (2** adr_width-1) ) := (others => (others => default_content));  -- Local data
	signal r_clk: std_logic;
	signal l_r_ack: std_logic := '0';
begin
	async_clk: if (async_read) generate
		r_dat_o <= data(to_integer(r_adr_i)) when (r_stb_i = '1' and r_we_i = '0') else (others => default_out);
		r_ack_o <= '1'; -- async read is 0 wait-state
	end generate;
	sync_clk: if (not async_read) generate
		ReProc : process (r_clk_i)
		begin
			if r_clk_i'event and r_clk_i = '1' then
				if r_stb_i = '1' and r_we_i = '0' then
					r_dat_o <= data(to_integer(r_adr_i));
					l_r_ack <= not l_r_ack;
				else
					r_dat_o <= (others => default_out);
					l_r_ack <= '0';
				end if;
			end if;
		end process ReProc;
		r_ack_o <= l_r_ack;
	end generate;

	w_ack_o <= '1'; -- write is allways 0 wait-state
	WrProc : process (w_clk_i)
	begin
		if w_clk_i'event and w_clk_i = '1' then
			if w_stb_i = '1' and w_we_i = '1' then
				data(to_integer(w_adr_i)) <= w_dat_i;
			end if;
		end if;
	end process WrProc;
end behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library wb_tk;
use wb_tk.technology.all;

architecture behavioral of fifo is
	-- One additional bit is added to detect over and under-flow
	signal w_adr : std_logic_vector(adr_width downto 0);  -- internal write address
	signal r_adr : std_logic_vector(adr_width downto 0);  -- internal read address
	signal w_ack, r_ack: std_logic;
begin
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
		-- signals for the read port
		r_clk_i            => r_clk_i,
		r_stb_i            => r_stb_i,
		r_we_i             => r_we_i,
		r_adr_i            => r_adr(adr_width-1 downto 0),
		r_dat_o            => r_dat_o,
		r_ack_o            => r_ack,
		-- signals for the write port
		w_clk_i            => w_clk_i,
		w_stb_i            => w_stb_i,
		w_we_i             => w_we_i,
		w_adr_i            => w_adr(adr_width-1 downto 0),
		w_dat_i            => w_dat_i,
		w_ack_o            => w_ack
	);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library wb_tk;
use wb_tk.technology.all;

architecture behavioral of spmem is
	signal w_ack, r_ack: std_logic;
begin
	mem_core: dpmem generic map (default_out,default_content,adr_width,dat_width,async_read)
		port map(
			-- Signals for the read port
			clk_i,
			stb_i,
			we_i,
			adr_i,
			dat_o,
			r_ack,
			-- Signals for the write port
			clk_i,
			stb_i,
			we_i,
			adr_i,
			dat_i,
			w_ack
	);
	ack_o <= ('0' and not stb_i) or (r_ack and (stb_i and not we_i)) or (w_ack and (stb_i and we_i));
end behavioral;
