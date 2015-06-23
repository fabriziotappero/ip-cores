-- High load test project. ***** TOP level file *****
-- Alexey Fedorov, 2014
-- email: FPGA@nerudo.com
--
-- It is intended for checking device 
-- for high consumption power.
-- Number of parameter gives possibility
-- to change number of used LC/DFF, DSP, RAM and I/O.
--
-- It can operate at 200 MHz in Cyclone 5E FPGA
--
--	1 LC core is about 1500 LUT4/FF (with default parameters)
--  1 DSP core is 7 DSP 18*18.
--  Each LC core also demands 4*N RAM block (32 bits width)

--To maximize power consumption:
--1) Find parameters for maximum FPGA resource usage
--2) Fed maximum frequency clock to CLK input (directly or via PLL instantiated in top level)
--3) Fed random data to inputs (lower ADC bits or data from PRBS generator)
--4) Connect maximal count of outputs. Be careful: They are switching simultaneously.
--
-- **** USE HIGH LOAD PROJECT AT YOUR OWN RISK ****
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity high_load is
	generic (
		NUM_IN  : positive := 3*14;	-- Input pins
		NUM_OUT : positive := 1;		-- Output pins
		NUM_LC : positive := 16;		-- Number of LC cores
		NUM_DSP : positive := 9;		-- Number of DSP cores
		RAM_DEPTH_LOG2 : integer range 4 to 30 := 10	-- RAM depth
		);
	port
	(
		-- Input ports
		clk	: in  std_logic;
		inputs: in std_logic_vector(NUM_IN-1 downto 0);

		-- Output ports
		dataout: out std_logic_vector(NUM_OUT-1 downto 0)
	);
end high_load;



architecture rtl of high_load is

--component aes_test_wrap is
--port(
--		clk	: in  std_logic;
--		datain: in std_logic_vector(127 downto 0);
--		key		: in std_logic_vector(127 downto 0);
--		dataout: out std_logic_vector(127 downto 0)
--	);
--end component;

component lc_use is
	generic (
		DATA_WIDTH : positive := 128; 
		ARITH_SIZE : positive := 16; -- Should be divider of DATA_WIDTH
		NUM_ROWS: positive := 6;	-- Input pins
        ADD_PIPL_FF : boolean := false
		);
	port
	(
		clk	: in  std_logic;
		inputs: in std_logic_vector(DATA_WIDTH-1 downto 0);
		dataout: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end component;

component dsp_use is
	generic (
		DATA_WIDTH  : positive := 16
		);
	port
	(
		clk	: in  std_logic;
		datain: in std_logic_vector(DATA_WIDTH-1 downto 0);
		dataout: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end component;

component ram_buf IS
	generic (
		DATA_WIDTH: positive := 12;
		DEPTH_LOG2: positive := 10
		);
  port(
    clk    : in  std_logic;         -- input data clock
--    ena    : in  std_logic;         -- input data enable
    din    : in  std_logic_vector(DATA_WIDTH-1 downto 0);  
    delay  : in  std_logic_vector(DEPTH_LOG2-1 downto 0);	
    dout   : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
END component;

constant DSP_WIDTH : integer := 15;	-- Data width of DSP multipliers

constant LC_W : integer := 128*NUM_LC;
constant DSP_W : integer := DSP_WIDTH*NUM_DSP;

--constant key : bit_vector(127 downto 0) := X"2BAC93F18E4797830BD476554BBE27A5";

signal lc_in, lc_out, ram_in, ram_out : std_logic_vector(LC_W-1 downto 0);
signal dsp_in, dsp_out : std_logic_vector(DSP_W-1 downto 0);

signal xor_result : std_logic;

procedure assign_bus(
	signal inp  : in  std_logic_vector;
	signal outp : out std_logic_vector) is

	constant IN_W : integer := inp'length(1);
	constant OUT_W: integer	:= outp'length(1);

	begin
	for i in 1 to OUT_W/IN_W loop
		if i = 1 then
			outp((i-1)*IN_W+IN_W-1 downto (i-1)*IN_W) <= inp;
		else
			outp((i-1)*IN_W+IN_W-1 downto (i-1)*IN_W) <= inp xor to_stdlogicvector(to_bitvector(inp) rol (i-1));
		end if;
	end loop;
	if OUT_W mod IN_W > 0 then
		outp(OUT_W-1 downto (OUT_W/IN_W)*IN_W) <= inp(OUT_W mod IN_W - 1 downto 0);
	end if;
end procedure;

procedure xorbus(
	signal inp  : in  std_logic_vector;
	signal outp : out std_logic
) is
variable tmp : std_logic := '0';
begin

	for i in inp'range loop
		tmp := tmp xor inp(i);
	end loop;
	
	outp <= tmp;

end procedure;


procedure resultbus(
	signal inp  : in  std_logic_vector;
	signal outp : out std_logic
) is
variable tmp : integer := 0;
begin
	for i in inp'range loop
		if inp(i) = '1' then
			tmp := tmp + 1;
		end if;
	end loop;
	
	if tmp >= inp'length(1) then
		outp <= '1';
	else
		outp <= '0';
	end if;
	
end procedure;


begin

assert lc_in'length(1) <  dsp_in'length(1) report "Implementing Input => DSP => RAM => LC => Output" severity warning; 
assert lc_in'length(1) >= dsp_in'length(1) report "Implementing Input => LC => RAM => DSP => Output" severity warning;

process(clk) --inputs, lc_in, lc_out, ram_in, ram_out, dsp_in, dsp_out, xor_result)
begin
if rising_edge(clk) then
	if(lc_in'length(1) < dsp_in'length(1)) then
		assign_bus(inputs, lc_in); 	-- Input => LC => RAM => DSP => Output
		assign_bus(lc_out, ram_in);
		assign_bus(ram_out, dsp_in);
--		resultbus(dsp_out, xor_result);
		xorbus(dsp_out, xor_result);
		dataout <= (others => xor_result);
	else	
		assign_bus(inputs, dsp_in); 	-- Input => DSP => RAM => LC => Output
		assign_bus(dsp_out, ram_in);
		assign_bus(ram_out, lc_in);
--		resultbus(lc_out, xor_result);
		xorbus(lc_out, xor_result);
		dataout <= (others => xor_result);
	end if;
end if;

end process;


LC_GEN: for i in 0 to NUM_LC-1 generate
--	aes_i : aes_test_wrap 
--	port map(
--		clk		=> clk,
--		datain => aes_in(128*i+127 downto 128*i),
--		key 	 => to_stdlogicvector(key rol i),
--		dataout=> aes_out(128*i+127 downto 128*i)
--	);
	lc_i: lc_use
	generic map (
		DATA_WIDTH => 128,
		ARITH_SIZE => 16, -- Should be divider of DATA_WIDTH
		NUM_ROWS	 => 6,	-- Input pins
		ADD_PIPL_FF => true
		)
	port map
	(
		clk		 => clk,
		inputs => lc_in(128*i+127 downto 128*i),
		dataout=> lc_out(128*i+127 downto 128*i)
	);
	
end generate;

DSP_GEN: for i in 0 to NUM_DSP-1 generate
		
	dsp_i : dsp_use 
	generic map(
		DATA_WIDTH  => DSP_WIDTH)
	port map
	(
		clk			=> clk,
		datain	=> dsp_in(DSP_WIDTH*i+DSP_WIDTH-1 downto DSP_WIDTH*i),
		dataout	=> dsp_out(DSP_WIDTH*i+DSP_WIDTH-1 downto DSP_WIDTH*i)
	);
		
end generate;

RAM_GEN: for i in 0 to NUM_LC-1 generate
	ram_i: ram_buf 
		generic map(
		DATA_WIDTH => 128,
		DEPTH_LOG2 => RAM_DEPTH_LOG2
		)
		port map(
			clk   => clk,
			din   => ram_in(128*i+127 downto 128*i),
			delay => std_logic_vector(to_unsigned(2**RAM_DEPTH_LOG2-10, RAM_DEPTH_LOG2)),
			dout  => ram_out(128*i+127 downto 128*i)
    );
end generate;

end rtl;
