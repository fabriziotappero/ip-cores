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

