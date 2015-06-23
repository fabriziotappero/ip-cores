--
--  Technology mapping library. ALTERA edition.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;
library exemplar;
use exemplar.exemplar_1164.all;

package technology is
	function add_one(inp : std_logic_vector) return std_logic_vector;
	function is_zero(inp : std_logic_vector) return boolean;
    function sl(l: std_logic_vector; r: integer) return std_logic_vector;
--	procedure inc(data : inout std_logic_vector);
    function "+"(op_l, op_r: std_logic_vector) return std_logic_vector;
	function log2(inp : integer) return integer;
	function bus_resize2adr_bits(in_bus : integer; out_bus: integer) return integer;
	function size2bits(inp : integer) return integer;
	function max(a : integer; b: integer) return integer;
	function min2(a : integer; b: integer) return integer;
	function equ(a : std_logic_vector; b : integer) return boolean;

	component d_ff is
		port (  d  :  in STD_LOGIC;
				clk:  in STD_LOGIC;
		        ena:  in STD_LOGIC := '1';
		        clr:  in STD_LOGIC := '0';
		        pre:  in STD_LOGIC := '0';
				q  :  out STD_LOGIC
		);
	end component;
	component fifo is
		generic (fifo_width : positive;
				 used_width : positive;
				 fifo_depth : positive
		);
		port (d_in : in std_logic_vector(fifo_width-1 downto 0);
			  clk : in std_logic;
			  wr : in std_logic;
			  rd : in std_logic;
			  a_clr : in std_logic := '0';
			  s_clr : in std_logic := '0';
			  d_out : out std_logic_vector(fifo_width-1 downto 0);
			  used : out std_logic_vector(used_width-1 downto 0);
			  full : out std_logic;
			  empty : out std_logic
		);
	end component;
end technology;
  
library IEEE;
use IEEE.std_logic_1164.all;
library exemplar;
use exemplar.exemplar_1164.all;
library synopsys;
use synopsys.std_logic_arith.all;

package body technology is
    function "+"(op_l, op_r: std_logic_vector) return std_logic_vector is
	begin
		return exemplar_1164."+"(op_l, op_r);
	end;
	
	function add_one(inp : std_logic_vector) return std_logic_vector is
		variable one: std_logic_vector(inp'RANGE) := (others => '0');
	begin
		one(0) := '1';
		return exemplar_1164."+"(inp,one);
	end;

	function is_zero(inp : std_logic_vector) return boolean is
		variable zero: std_logic_vector(inp'RANGE) := (others => '0');
	begin
		return (inp = zero);
	end;

    function sl(l: std_logic_vector; r: integer) return std_logic_vector is
    begin
    	return exemplar_1164.sl(l,r);
    end;
--	procedure inc(data : inout std_logic_vector) is
--	begin
--		data := addone(data);
--	end;
	function max(a : integer; b: integer) return integer is
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
		if (inp < 65538) then return 15; end if;
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
		if (inp < 1) then return 1; end if;
		if (inp < 2) then return 1; end if;
		if (inp < 4) then return 2; end if;
		if (inp < 8) then return 3; end if;
		if (inp < 16) then return 4; end if;
		if (inp < 32) then return 5; end if;
		if (inp < 64) then return 6; end if;
		if (inp < 128) then return 7; end if;
		if (inp < 256) then return 8; end if;
		if (inp < 512) then return 9; end if;
		if (inp < 1024) then return 10; end if;
		if (inp < 2048) then return 11; end if;
		if (inp < 4096) then return 12; end if;
		if (inp < 8192) then return 13; end if;
		if (inp < 16384) then return 14; end if;
		if (inp < 32768) then return 15; end if;
		if (inp < 65538) then return 16; end if;
		return 17;
	end;

	function equ(a : std_logic_vector; b : integer) return boolean is
		variable b_s : std_logic_vector(a'RANGE);
	begin
		b_s := CONV_STD_LOGIC_VECTOR(b,a'HIGH+1);
		return (a = b_s);
	end;

end package body technology;
  

library IEEE;
use IEEE.std_logic_1164.all;

library exemplar;
use exemplar.exemplar_1164.all;

library lpm;
use lpm.all;

entity fifo is
	generic (fifo_width : positive;
			 used_width : positive;
			 fifo_depth : positive
	);
	port (d_in : in std_logic_vector(fifo_width-1 downto 0);
		  clk : in std_logic;
		  wr : in std_logic;
		  rd : in std_logic;
		  a_clr : in std_logic := '0';
		  s_clr : in std_logic := '0';
		  d_out : out std_logic_vector(fifo_width-1 downto 0);
		  used : out std_logic_vector(used_width-1 downto 0);
		  full : out std_logic;
		  empty : out std_logic
	);
end fifo;

architecture altera of fifo is
	component lpm_fifo
		generic (LPM_WIDTH : positive;
				 LPM_WIDTHU : positive;
				 LPM_NUMWORDS : positive;
				 LPM_SHOWAHEAD : string := "OFF";
				 LPM_TYPE : string := "LPM_FIFO";
				 LPM_HINT : string := "UNUSED");
		port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
			  CLOCK : in std_logic;
			  WRREQ : in std_logic;
			  RDREQ : in std_logic;
			  ACLR : in std_logic;
			  SCLR : in std_logic;
			  Q : out std_logic_vector(LPM_WIDTH-1 downto 0);
			  USEDW : out std_logic_vector(LPM_WIDTHU-1 downto 0);
			  FULL : out std_logic;
			  EMPTY : out std_logic);
	end component;
begin
	altera_fifo: lpm_fifo
		generic map (
			LPM_WIDTH => fifo_width,
			LPM_WIDTHU => used_width,
			LPM_NUMWORDS => fifo_depth,
			LPM_SHOWAHEAD => "OFF",
			LPM_TYPE => "LPM_FIFO",
			LPM_HINT => "UNUSED"
		)
		port map (
			DATA => d_in,
			CLOCK => clk,
			WRREQ => wr,
			RDREQ => rd,
			ACLR => a_clr,
			SCLR => s_clr,
			Q => d_out,
			USEDW => used,
			FULL => full,
			EMPTY => empty
		);
end altera;

library IEEE;
use IEEE.std_logic_1164.all;

library exemplar;
use exemplar.exemplar_1164.all;

library lpm;
use lpm.all;

entity ram is
	generic (
		data_width : positive;
		addr_width : positive
	);
	port (
		clk : in std_logic;
		we : in std_logic;
		addr : in std_logic_vector(addr_width-1 downto 0);
		d_in : in std_logic_vector(data_width-1 downto 0);
		d_out : out std_logic_vector(data_width-1 downto 0)
	);
end ram;

architecture altera of ram is
	component lpm_ram_dp
		generic (
			lpm_width: positive;
			lpm_widthad: positive;
			lpm_numwords: natural := 0;
			lpm_type: string := "lpm_ram_dp";
			lpm_indata: string := "REGISTERED";
			lpm_outdata: string := "UNREGISTERED";
			lpm_rdaddress_control: string := "REGISTERED";
			lpm_wraddress_control: string := "REGISTERED";
			lpm_file: string := "UNUSED";
			lpm_hint: string := "UNUSED"
		);
		port (
			rdaddress, wraddress: in std_logic_vector(lpm_widthad-1 downto 0);
			rdclock, wrclock: in std_logic := '0';
			rden, rdclken, wrclken: in std_logic := '1';
			wren: in std_logic; 
			data: in std_logic_vector(lpm_width-1 downto 0);
			q: out std_logic_vector(lpm_width-1 downto 0)
		);
	end component;
begin
	altera_ram: lpm_ram_dp
		generic map (
			lpm_width => data_width,
			lpm_widthad => addr_width,
			lpm_numwords => 2 ** addr_width,
			lpm_type => "lpm_ram_dp",
			lpm_indata => "REGISTERED",
			lpm_wraddress_control => "REGISTERED",
			lpm_outdata => "UNREGISTERED",
			lpm_rdaddress_control => "UNREGISTERED",
			lpm_file => "UNUSED",
			lpm_hint => "UNUSED"
		)
		port map (
--			rdclock => clk,
			rdclken => '1',
			rdaddress => addr, 
			q => d_out,
			rden => '1',

			wrclock => clk,
			wrclken => '1',
			wraddress => addr,
			data => d_in,
			wren => we
		);
end altera;





library IEEE;
use IEEE.std_logic_1164.all;

library exemplar;
use exemplar.exemplar_1164.all;

library lpm;
use lpm.all;

entity dpram is
	generic (
		data_width : positive;
		addr_width : positive
	);
	port (
		clk : in std_logic;

		r_d_out : out std_logic_vector(data_width-1 downto 0);
		r_rd : in std_logic;
		r_clk_en : in std_logic;
		r_addr : in std_logic_vector(addr_width-1 downto 0);

		w_d_in : in std_logic_vector(data_width-1 downto 0);
		w_wr : in std_logic;
		w_clk_en : in std_logic;
		w_addr : in std_logic_vector(addr_width-1 downto 0)
	);
end dpram;

architecture altera of dpram is
	component lpm_ram_dp
		generic (
			lpm_width: positive;
			lpm_widthad: positive;
			lpm_numwords: natural := 0;
			lpm_type: string := "lpm_ram_dp";
			lpm_indata: string := "REGISTERED";
			lpm_outdata: string := "UNREGISTERED";
			lpm_rdaddress_control: string := "REGISTERED";
			lpm_wraddress_control: string := "REGISTERED";
			lpm_file: string := "UNUSED";
			lpm_hint: string := "UNUSED"
		);
		port (
			rdaddress, wraddress: in std_logic_vector(lpm_widthad-1 downto 0);
			rdclock, wrclock: in std_logic := '0';
			rden, rdclken, wrclken: in std_logic := '1';
			wren: in std_logic; 
			data: in std_logic_vector(lpm_width-1 downto 0);
			q: out std_logic_vector(lpm_width-1 downto 0)
		);
	end component;
begin
	altera_ram: lpm_ram_dp
		generic map (
			lpm_width => data_width,
			lpm_widthad => addr_width,
			lpm_numwords => 2 ** addr_width,
			lpm_type => "lpm_ram_dp",
			lpm_indata => "REGISTERED",
			lpm_wraddress_control => "REGISTERED",
			lpm_outdata => "UNREGISTERED",
			lpm_rdaddress_control => "UNREGISTERED",
			lpm_file => "UNUSED",
			lpm_hint => "UNUSED"
		)
		port map (
--			rdclock => clk,
			rdclken => r_clk_en,
			rdaddress => r_addr, 
			q => r_d_out,
			rden => r_rd,

			wrclock => clk,
			wrclken => w_clk_en,
			wraddress => w_addr,
			data => w_d_in,
			wren => w_wr
		);
end altera;

library IEEE;
use IEEE.std_logic_1164.all;

library altera_exemplar;
use altera_exemplar.all;

entity d_ff is
	port (  d  :  in STD_LOGIC;
			clk:  in STD_LOGIC;
	        ena:  in STD_LOGIC := '1';
	        clr:  in STD_LOGIC := '0';
	        pre:  in STD_LOGIC := '0';
			q  :  out STD_LOGIC
	);
end d_ff;

architecture altera of d_ff is
	component dffe
	port (  D  :  in STD_LOGIC;
			CLK:  in STD_LOGIC;
	        ENA:  in STD_LOGIC;
	        CLRN: in STD_LOGIC;
	        PRN:  in STD_LOGIC;
			Q  :  out STD_LOGIC);
	end component;
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

-- Sythetizer library. Contains STD_LOGIC arithmetics

