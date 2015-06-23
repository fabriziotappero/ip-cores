--
--  Technology mapping library. ALTERA edition.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
library exemplar;
--use exemplar.exemplar_1164.all;
library synopsys;
--use synopsys.std_logic_arith.all;

package body technology is
	function to_std_logic_vector(ARG: INTEGER; SIZE: INTEGER) return STD_LOGIC_VECTOR is
	begin
		return std_logic_arith.CONV_STD_LOGIC_VECTOR(arg,size);
	end;

	function to_integer(arg:std_logic_vector) return integer is
	begin
		return CONV_INTEGER(arg);
	end;

--	function "+"(op_l, op_r: std_logic_vector) return std_logic_vector is
--	begin
--		return exemplar_1164."+"(op_l, op_r);
--	end;
--
--	function "-"(op_l, op_r: std_logic_vector) return std_logic_vector is
--	begin
--		return exemplar_1164."-"(op_l, op_r);
--	end;
--
--	function add_one(inp : std_logic_vector) return std_logic_vector is
--		variable one: std_logic_vector(inp'RANGE) := (others => '0');
--	begin
--		one(0) := '1';
--		return exemplar_1164."+"(inp,one);
--	end;
--
--	function sub_one(inp : std_logic_vector) return std_logic_vector is
--		variable minus_one: std_logic_vector(inp'RANGE) := (others => '1');
--	begin
--		return exemplar_1164."+"(inp,minus_one);
--	end;

	function is_zero(inp : std_logic_vector) return boolean is
		variable zero: std_logic_vector(inp'RANGE) := (others => '0');
	begin
		return (inp = zero);
	end;

	function sl(l: std_logic_vector; r: integer) return std_logic_vector is
	begin
		return exemplar_1164.sl(l,r);
	end;

	function sr(l: std_logic_vector; r: integer) return std_logic_vector is
	begin
		return sl(l,-r);
	end function;

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
		return (a = b_s);
	end;

end package body technology;

library IEEE;
use IEEE.std_logic_1164.all;

library altera;
use altera.maxplus2.all;
library alt_vtl;
use alt_vtl.all;

architecture altera of d_ff is
	signal clrn,prn: std_logic;
begin
	clrn <= not clr;
	prn <= not pre;
	ff: dffe port map (
		D => d,
		CLK => clk,
		ENA => ena,
		CLRN => clrn,
		PRN => prn,
		Q => q
	);
end altera;

library ieee;
use ieee.std_logic_1164.all;
library wb_tk;
use wb_tk.technology.all;
library lpm;
use lpm.all;

--  GENERIC usage
-------------------
--	default_out     : Not used in altera implementation
--	default_content : Not used in altera implementation
--	adr_width       : Correctly used
--	dat_width       : Correctly used
--	async_read      : Correctly used
architecture altera of dpmem is
	signal wren, rden: std_logic;

	COMPONENT lpm_ram_dp
		generic (LPM_WIDTH : positive;
			LPM_WIDTHAD : positive;
			LPM_NUMWORDS : natural := 0;
			LPM_INDATA : string := "REGISTERED";
			LPM_OUTDATA : string := "REGISTERED";
			LPM_RDADDRESS_CONTROL : string := "REGISTERED";
			LPM_WRADDRESS_CONTROL : string := "REGISTERED";
			LPM_FILE : string := "UNUSED";
			LPM_TYPE : string := "LPM_RAM_DP";
			LPM_HINT : string := "UNUSED"
		);
		port (RDCLOCK : in std_logic := '0';
			RDCLKEN : in std_logic := '1';
			RDADDRESS : in std_logic_vector(LPM_WIDTHad-1 downto 0);
			RDEN : in std_logic := '1';
			DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
			WRADDRESS : in std_logic_vector(LPM_WIDTHad-1 downto 0);
			WREN : in std_logic;
			WRCLOCK : in std_logic := '0';
			WRCLKEN : in std_logic := '1';
			Q : out std_logic_vector(LPM_WIDTH-1 downto 0)
		);
	END COMPONENT;
begin
	wren <= w_we_i and w_stb_i;
	rden <= not r_we_i and r_stb_i;

	w_ack_o <= '1'; -- 0-wait-state for writes
	r_ack_o <= '1'; -- 0-wait-state for reads
	sync_gen: if (not async_read) generate
		mem_core: lpm_ram_dp
			GENERIC MAP (
				lpm_width             => dat_width,
				lpm_widthad           => adr_width,
				lpm_indata            => "REGISTERED",
				lpm_wraddress_control => "REGISTERED",
				lpm_rdaddress_control => "REGISTERED",
				lpm_outdata           => "UNREGISTERED",
				lpm_hint              => "USE_EAB=ON"
			)
			PORT MAP (
				rdclock   => r_clk_i,
				wren      => wren,
				wrclock   => w_clk_i,
				q         => r_dat_o,
				rden      => rden,
				data      => w_dat_i,
				rdaddress => r_adr_i,
				wraddress => w_adr_i
			);
	end generate;
	async_gen: if (async_read) generate
		mem_core: lpm_ram_dp
			GENERIC MAP (
				lpm_width             => dat_width,
				lpm_widthad           => adr_width,
				lpm_indata            => "REGISTERED",
				lpm_wraddress_control => "REGISTERED",
				lpm_rdaddress_control => "UNREGISTERED",
				lpm_outdata           => "UNREGISTERED",
				lpm_hint              => "USE_EAB=ON"
			)
			PORT MAP (
				rdclock   => r_clk_i,
				wren      => wren,
				wrclock   => w_clk_i,
				q         => r_dat_o,
				rden      => rden,
				data      => w_dat_i,
				rdaddress => r_adr_i,
				wraddress => w_adr_i
			);
	end generate;
end altera;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library wb_tk;
use wb_tk.technology.all;

architecture altera of fifo is
	-- One additional bit is added to detect over and under-flow
	signal w_adr : std_logic_vector(adr_width downto 0);  -- internal write address
	signal r_adr : std_logic_vector(adr_width downto 0);  -- internal read address
begin
	read_proc : process (r_clk_i, reset)
	begin
		if reset = '1' then
			r_adr     <= (others => '0');
		elsif r_clk_i'event and r_clk_i = '1' then
			if (r_stb_i = '1' and r_we_i = '0') then
				r_adr <= r_adr+"1";
			end if;
		end if;
	end process read_proc;

	write_proc : process (w_clk_i, reset)
	begin
		if reset = '1' then
			w_adr     <= (others => '0');
		elsif w_clk_i'event and w_clk_i = '1' then
			if (w_stb_i = '1' and w_we_i = '1') then
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
		r_ack_o            => r_ack_o,
		-- signals for the write port
		w_clk_i            => w_clk_i,
		w_stb_i            => w_stb_i,
		w_we_i             => w_we_i,
		w_adr_i            => w_adr(adr_width-1 downto 0),
		w_dat_i            => w_dat_i,
		w_ack_o            => w_ack_o
	);
end altera;

library ieee;
use ieee.std_logic_1164.all;
library wb_tk;
use wb_tk.technology.all;

architecture altera of spmem is
	signal r_ack: std_logic;
	signal w_ack: std_logic;
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
	ack_o <= '1';
end altera;
