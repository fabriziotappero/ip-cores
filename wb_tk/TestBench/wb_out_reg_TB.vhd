--
-- A test bench for 32-bit access
--

library ieee,wb_tk;
use ieee.std_logic_1164.all;
use wb_tk.technology.all;
use wb_tk.wb_test.all;

entity wb_out_reg_tb_32 is
	-- Generic declarations of the tested unit
	generic(
		width : POSITIVE := 16;
		bus_width : POSITIVE := 32;
		offset : INTEGER := 4 );
end wb_out_reg_tb_32;

architecture TB of wb_out_reg_tb_32 is
	-- Component declaration of the tested unit
	component wb_out_reg
		generic(
			width : POSITIVE := width;
			bus_width : POSITIVE := bus_width;
			offset : INTEGER := offset );
		port (
			clk_i: in std_logic;
			rst_i: in std_logic;
			rst_val: std_logic_vector(width-1 downto 0) := (others => '0');
	
	        cyc_i: in std_logic := '1';
			stb_i: in std_logic;
	        sel_i: in std_logic_vector ((bus_width/8)-1 downto 0) := (others => '1');
			we_i: in std_logic;
			ack_o: out std_logic;
			ack_oi: in std_logic := '-';
    		adr_i: in std_logic_vector (size2bits((width+offset+bus_width-1)/bus_width)-1 downto 0) := (others => '0');
			dat_i: in std_logic_vector (bus_width-1 downto 0);
			dat_oi: in std_logic_vector (bus_width-1 downto 0) := (others => '-');
			dat_o: out std_logic_vector (bus_width-1 downto 0);
			q: out std_logic_vector (width-1 downto 0)
		);
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal adr_i : std_logic_vector (size2bits((width+offset+bus_width-1)/bus_width)-1 downto 0) := (others => '0');
	signal clk_i : std_logic;
	signal rst_i : std_logic;
	signal rst_val : std_logic_vector((width-1) downto 0) := (others => '0');
	signal cyc_i : std_logic;
	signal stb_i : std_logic;
	signal sel_i : std_logic_vector(((bus_width/8)-1) downto 0) := (others => '1');
	signal we_i : std_logic;
	signal ack_oi : std_logic;
	signal dat_i : std_logic_vector((bus_width-1) downto 0);
	signal dat_oi : std_logic_vector((bus_width-1) downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal ack_o : std_logic;
	signal dat_o : std_logic_vector((bus_width-1) downto 0);
	signal q : std_logic_vector((width-1) downto 0);

	-- Add your code here ...

begin
	rst_val <= (others => '0');
	ack_oi <= 'U';
	dat_oi <= (others => 'U');

	-- Unit Under Test port map
	UUT : wb_out_reg
		port map
			(clk_i => clk_i,
			rst_i => rst_i,
			rst_val => rst_val,
			cyc_i => cyc_i,
			stb_i => stb_i,
			sel_i => sel_i,
			we_i => we_i,
			ack_o => ack_o,
			ack_oi => ack_oi,
			adr_i => adr_i,
			dat_i => dat_i,
			dat_oi => dat_oi,
			dat_o => dat_o,
			q => q );

	clk: process is
	begin
		clk_i <= '0';
		wait for 25ns;
		clk_i <= '1';
		wait for 25ns;
	end process;
	
	reset: process is
	begin
		rst_i <= '1';
		wait for 150ns;
		rst_i <= '0';
		wait;
	end process;
	
	master: process is
	begin
		we_i <= '0';
		cyc_i <= '0';
		stb_i <= '0';
		adr_i <= (others => '0');
		dat_i <= (others => '0');
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';

		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","00000000000000000000000000000000");
		rd_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","00000000000000000000000000000000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","11111111111111111111111111111111");
		rd_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","11111111111111111111111111111111");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","01110110010101000011001000010000");
		rd_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","01110110010101000011001000010000");

		sel_i <= add_one(sel_i);
--		if (sel_i = "1111") then wait; end if;
	end process;
end TB;

configuration TB_wb_out_reg_32 of wb_out_reg_tb_32 is
	for TB
		for UUT : wb_out_reg
			use entity work.wb_out_reg(wb_out_reg);
		end for;
	end for;
end TB_wb_out_reg_32;



--
-- A test bench for 16-bit access
--


library ieee,wb_tk;
use ieee.std_logic_1164.all;
use wb_tk.technology.all;
use wb_tk.wb_test.all;

entity wb_out_reg_tb_16 is
	-- Generic declarations of the tested unit
	generic(
		width : POSITIVE := 16;
		bus_width : POSITIVE := 16;
		offset : INTEGER := 4 );
end wb_out_reg_tb_16;

architecture TB of wb_out_reg_tb_16 is
	-- Component declaration of the tested unit
	component wb_out_reg
		generic(
			width : POSITIVE := width;
			bus_width : POSITIVE := bus_width;
			offset : INTEGER := offset );
		port (
			clk_i: in std_logic;
			rst_i: in std_logic;
			rst_val: std_logic_vector(width-1 downto 0) := (others => '0');
	
	        cyc_i: in std_logic := '1';
			stb_i: in std_logic;
	        sel_i: in std_logic_vector ((bus_width/8)-1 downto 0) := (others => '1');
			we_i: in std_logic;
			ack_o: out std_logic;
			ack_oi: in std_logic := '-';
			adr_i: in std_logic_vector (max(log2((width+offset+bus_width-1)/bus_width)-1,0) downto 0) := (others => '0');
			dat_i: in std_logic_vector (bus_width-1 downto 0);
			dat_oi: in std_logic_vector (bus_width-1 downto 0) := (others => '-');
			dat_o: out std_logic_vector (bus_width-1 downto 0);
			q: out std_logic_vector (width-1 downto 0)
		);
	end component;

	signal adr_i : std_logic_vector (max(log2((width+offset+bus_width-1)/bus_width)-1,0) downto 0) := (others => '0');
	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk_i : std_logic;
	signal rst_i : std_logic;
	signal rst_val : std_logic_vector((width-1) downto 0) := (others => '0');
	signal cyc_i : std_logic;
	signal stb_i : std_logic;
	signal sel_i : std_logic_vector(((bus_width/8)-1) downto 0) := (others => '1');
	signal we_i : std_logic;
	signal ack_oi : std_logic;
	signal dat_i : std_logic_vector((bus_width-1) downto 0);
	signal dat_oi : std_logic_vector((bus_width-1) downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal ack_o : std_logic;
	signal dat_o : std_logic_vector((bus_width-1) downto 0);
	signal q : std_logic_vector((width-1) downto 0);

	-- Add your code here ...

begin
	rst_val <= (others => '0');
	ack_oi <= 'U';
	dat_oi <= (others => 'U');

	-- Unit Under Test port map
	UUT : wb_out_reg
		port map
			(clk_i => clk_i,
			rst_i => rst_i,
			rst_val => rst_val,
			cyc_i => cyc_i,
			stb_i => stb_i,
			sel_i => sel_i,
			we_i => we_i,
			ack_o => ack_o,
			ack_oi => ack_oi,
			adr_i => adr_i,
			dat_i => dat_i,
			dat_oi => dat_oi,
			dat_o => dat_o,
			q => q );

	clk: process is
	begin
		clk_i <= '0';
		wait for 25ns;
		clk_i <= '1';
		wait for 25ns;
	end process;
	
	reset: process is
	begin
		rst_i <= '1';
		wait for 150ns;
		rst_i <= '0';
		wait;
	end process;
	
	master: process is
	begin
		we_i <= '0';
		cyc_i <= '0';
		stb_i <= '0';
		adr_i <= (others => '0');
		dat_i <= (others => '0');
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';

		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"1","0000000000000000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","0000000000000000");
		rd_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"1","0000000000000000");
		rd_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","0000000000000000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"1","1111111111111111");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","1111111111111111");
		rd_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"1","1111111111111111");
		rd_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","1111111111111111");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"1","0111011001010100");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","0011001000010000");
		rd_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"1","0111011001010100");
		rd_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,"0","0011001000010000");

		sel_i <= add_one(sel_i);
	end process;
end TB;

configuration TB_wb_out_reg_16 of wb_out_reg_tb_16 is
	for TB
		for UUT : wb_out_reg
			use entity work.wb_out_reg(wb_out_reg);
		end for;
	end for;
end TB_wb_out_reg_16;
