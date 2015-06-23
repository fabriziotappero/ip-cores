--
--  Technology mapping library. Interface.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;

package technology is
	-- originaly in synopsys. Naming convention is changed to resolve potential name conflict.
	function to_std_logic_vector(ARG: INTEGER; SIZE: INTEGER) return STD_LOGIC_VECTOR;
	function to_integer(arg:std_logic_vector) return integer;

--	function add_one(inp : std_logic_vector) return std_logic_vector;
--	function sub_one(inp : std_logic_vector) return std_logic_vector;
	function is_zero(inp : std_logic_vector) return boolean;
	function sl(l: std_logic_vector; r: integer) return std_logic_vector;
	function sr(l: std_logic_vector; r: integer) return std_logic_vector;
--	function "+"(op_l, op_r: std_logic_vector) return std_logic_vector;
--	function "-"(op_l, op_r: std_logic_vector) return std_logic_vector;
	function log2(inp : integer) return integer;
	function bus_resize2adr_bits(in_bus : integer; out_bus: integer) return integer;
	function size2bits(inp : integer) return integer;
	function max2(a : integer; b: integer) return integer;
	function min2(a : integer; b: integer) return integer;
	function equ(a : std_logic_vector; b : integer) return boolean;

	component d_ff
		port (
			d  :  in STD_LOGIC;
			clk:  in STD_LOGIC;
			ena:  in STD_LOGIC := '1';
			clr:  in STD_LOGIC := '0';
			pre:  in STD_LOGIC := '0';
			q  :  out STD_LOGIC
		);
	end component;
	component spmem
		generic (
			default_out     : std_logic := 'X';  -- Default output
			default_content : std_logic := '0';  -- Simple initialization data
			adr_width       : integer   := 3;
			dat_width       : integer   := 8;
			async_read      : boolean   := true
		);
		port (
			stb_i :     std_logic;                                -- chip select
			clk_i : in  std_logic;                                -- write clock
			adr_i : in  std_logic_vector(adr_width -1 downto 0);  -- Address
			dat_i : in  std_logic_vector(dat_width -1 downto 0);  -- input data
			dat_o : out std_logic_vector(dat_width -1 downto 0);  -- Output Data
			we_i  : in  std_logic;                                -- Read Write Enable
			ack_o : out std_logic                                 -- Ready output
		);
	end component;
	component dpmem
	    generic (
	        default_out :     std_logic := 'X';  -- Default output
	        default_content : std_logic := '0';  -- Simple initialization data
	        adr_width   :     integer   := 3;
	        dat_width   :     integer   := 8;
	        async_read  :     boolean   := true
	    );
	    port (
	        -- Signals for the port A
	        a_clk_i : in  std_logic;                                -- Read clock
	        a_stb_i : in  std_logic;                                -- Read port select
	        a_we_i  : in  std_logic;                                -- Read port Write enable
	        a_adr_i : in  std_logic_vector(adr_width -1 downto 0);  -- Read Address
	        a_dat_i : in  std_logic_vector(dat_width -1 downto 0);  -- Input data
	        a_dat_o : out std_logic_vector(dat_width -1 downto 0);  -- Output data
	        a_ack_o : out std_logic;                                -- Read ready output
	
	        -- Signals for the port B
	        b_clk_i : in  std_logic;                                -- Write clock
	        b_stb_i : in  std_logic;                                -- Write port select
	        b_we_i  : in  std_logic;                                -- Write Enable
	        b_adr_i : in  std_logic_vector(adr_width -1 downto 0);  -- Write Address
	        b_dat_i : in  std_logic_vector(dat_width -1 downto 0);  -- Input data
	        b_dat_o : out std_logic_vector(dat_width -1 downto 0);  -- Output data
	        b_ack_o : out std_logic                                 -- Write ready output
	    );
	end component;
	component fifo
		generic (
			default_out :     std_logic := 'X';  -- Default output
			default_content : std_logic := '0';  -- Simple initialization data
			adr_width   :     integer   := 3;
			dat_width   :     integer   := 8;
			async_read  :     boolean   := true  -- Controls memory only. For FIFO logic clock is still needed.
		);
		port (
			reset   : in  std_logic;                              -- System reset

			r_clk_i : in  std_logic;                              -- Read clock
			r_stb_i : in  std_logic;                              -- Read port select
			r_we_i  : in  std_logic := '0';                       -- Read port Write enable (should be '0')
			r_dat_o : out std_logic_vector(dat_width-1 downto 0); -- Data out
			r_ack_o : out std_logic;                              -- Read ready output

			w_clk_i : in  std_logic;                              -- Write clock
			w_stb_i : in  std_logic;                              -- Write port select
			w_we_i  : in  std_logic := '1';                       -- Write port write enable
			w_dat_i : in  std_logic_vector(dat_width-1 downto 0); -- Data in
			w_ack_o : out std_logic;                              -- Write ready output

			full_o  : out std_logic;                              -- Full Flag (combinational)
			empty_o : out std_logic;                              -- Empty flag (combinational)
			used_o  : out std_logic_vector(adr_width downto 0)    -- number of data in the fifo (combinational)
		);
	end component;
end technology;

library IEEE;
use IEEE.std_logic_1164.all;

entity spmem is
	generic (
		default_out     : std_logic := 'X';  -- Default output
		default_content : std_logic := '0';  -- Simple initialization data
		adr_width       : integer   := 3;
		dat_width       : integer   := 8;
		async_read      : boolean   := true
	);
	port (
		stb_i :     std_logic;                                -- chip select
		clk_i : in  std_logic;                                -- write clock
		adr_i : in  std_logic_vector(adr_width -1 downto 0);  -- Address
		dat_i : in  std_logic_vector(dat_width -1 downto 0);  -- input data
		dat_o : out std_logic_vector(dat_width -1 downto 0);  -- Output Data
		we_i  : in  std_logic;                                -- Read Write Enable
		ack_o : out std_logic                                 -- Ready output
	);
end spmem;

library IEEE;
use IEEE.std_logic_1164.all;

entity dpmem is
    generic (
        default_out :     std_logic := 'X';  -- Default output
        default_content : std_logic := '0';  -- Simple initialization data
        adr_width   :     integer   := 3;
        dat_width   :     integer   := 8;
        async_read  :     boolean   := true
    );
    port (
        -- Signals for the port A
        a_clk_i : in  std_logic;                                -- Read clock
        a_stb_i : in  std_logic;                                -- Read port select
        a_we_i  : in  std_logic;                                -- Read port Write enable
        a_adr_i : in  std_logic_vector(adr_width -1 downto 0);  -- Read Address
        a_dat_i : in  std_logic_vector(dat_width -1 downto 0);  -- Input data
        a_dat_o : out std_logic_vector(dat_width -1 downto 0);  -- Output data
        a_ack_o : out std_logic;                                -- Read ready output

        -- Signals for the port B
        b_clk_i : in  std_logic;                                -- Write clock
        b_stb_i : in  std_logic;                                -- Write port select
        b_we_i  : in  std_logic;                                -- Write Enable
        b_adr_i : in  std_logic_vector(adr_width -1 downto 0);  -- Write Address
        b_dat_i : in  std_logic_vector(dat_width -1 downto 0);  -- Input data
        b_dat_o : out std_logic_vector(dat_width -1 downto 0);  -- Output data
        b_ack_o : out std_logic                                 -- Write ready output
    );
end dpmem;

library IEEE;
use IEEE.std_logic_1164.all;

entity fifo is
	generic (
		default_out :     std_logic := 'X';  -- Default output
		default_content : std_logic := '0';  -- Simple initialization data
		adr_width   :     integer   := 3;
		dat_width   :     integer   := 8;
		async_read  :     boolean   := true  -- Controls memory only. For FIFO logic clock is still needed.
	);
	port (
		reset   : in  std_logic;                              -- System reset

		r_clk_i : in  std_logic;                              -- Read clock
		r_stb_i : in  std_logic;                              -- Read port select
		r_we_i  : in  std_logic := '0';                       -- Read port Write enable (should be '0')
		r_dat_o : out std_logic_vector(dat_width-1 downto 0); -- Data out
		r_ack_o : out std_logic;                              -- Read ready output

		w_clk_i : in  std_logic;                              -- Write clock
		w_stb_i : in  std_logic;                              -- Write port select
		w_we_i  : in  std_logic := '1';                       -- Write port write enable
		w_dat_i : in  std_logic_vector(dat_width-1 downto 0); -- Data in
		w_ack_o : out std_logic;                              -- Write ready output

		full_o  : out std_logic;                              -- Full Flag (combinational)
		empty_o : out std_logic;                              -- Empty flag (combinational)
		used_o  : out std_logic_vector(adr_width downto 0)    -- number of data in the fifo (combinational)
	);
end fifo;


library IEEE;
use IEEE.std_logic_1164.all;

entity d_ff is
	port (
		d  :  in STD_LOGIC;
		clk:  in STD_LOGIC;
		ena:  in STD_LOGIC := '1';
		clr:  in STD_LOGIC := '0';
		pre:  in STD_LOGIC := '0';
		q  :  out STD_LOGIC
	);
end d_ff;

