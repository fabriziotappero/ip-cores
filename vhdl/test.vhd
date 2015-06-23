
-- VHDL Test Bench Created from source file cpu_engine.vhd -- 12:41:11 06/20/2003
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

use work.cpu_pack.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT cpu_engine
	PORT(
		clk_i : IN std_logic;
		dat_i : IN std_logic_vector(7 downto 0);
		rst_i : IN std_logic;
		ack_i : IN std_logic;
		int : IN std_logic;          
		dat_o : OUT std_logic_vector(7 downto 0);
		adr_o : OUT std_logic_vector(15 downto 0);
		cyc_o : OUT std_logic;
		stb_o : OUT std_logic;
		tga_o : OUT std_logic_vector(0 to 0);
		we_o : OUT std_logic;
		halt : OUT std_logic;
		q_pc : OUT std_logic_vector(15 downto 0);
		q_opc : OUT std_logic_vector(7 downto 0);
		q_cat : OUT op_category;
		q_imm : OUT std_logic_vector(15 downto 0);
		q_cyc : OUT cycle;
		q_sx : OUT std_logic_vector(1 downto 0);
		q_sy : OUT std_logic_vector(3 downto 0);
		q_op : OUT std_logic_vector(4 downto 0);
		q_sa : OUT std_logic_vector(4 downto 0);
		q_smq : OUT std_logic;
		q_we_rr : OUT std_logic;
		q_we_ll : OUT std_logic;
		q_we_sp : OUT SP_OP;
		q_rr : OUT std_logic_vector(15 downto 0);
		q_ll : OUT std_logic_vector(15 downto 0);
		q_sp : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	signal	CLK_I   : std_logic;
	signal	DAT_I   : std_logic_vector( 7 downto 0);
	signal	DAT_O   : std_logic_vector( 7 downto 0);
	signal	RST_I   : std_logic;
	signal	ACK_I   : std_logic;
	signal	ADR_O   : std_logic_vector(15 downto 0);
	signal	CYC_O   : std_logic;
	signal	STB_O   : std_logic;
	signal	TGA_O   : std_logic_vector( 0 downto 0);		-- '1' if I/O
	signal	WE_O    : std_logic;

	signal	INT     : std_logic;
	signal	HALT    : std_logic;

			-- debug signals
			--
	signal	Q_PC    : std_logic_vector(15 downto 0);
	signal	Q_OPC   : std_logic_vector( 7 downto 0);
	signal	Q_CAT   : op_category;
	signal	Q_IMM   : std_logic_vector(15 downto 0);
	signal	Q_CYC   : cycle;

			-- select signals
	signal	Q_SX    : std_logic_vector(1 downto 0);
	signal	Q_SY    : std_logic_vector(3 downto 0);
	signal	Q_OP    : std_logic_vector(4 downto 0);
	signal	Q_SA    : std_logic_vector(4 downto 0);
	signal	Q_SMQ   : std_logic;

			-- write enable/select signal
	signal	Q_WE_RR : std_logic;
	signal	Q_WE_LL : std_logic;
	signal	Q_WE_SP : SP_OP;

	signal	Q_RR    : std_logic_vector(15 downto 0);
	signal	Q_LL    : std_logic_vector(15 downto 0);
	signal	Q_SP    : std_logic_vector(15 downto 0);
	    
	signal	clk_counter : INTEGER := 0;

BEGIN

	uut: cpu_engine
	PORT MAP(
		clk_i => clk_i,
		dat_i => dat_i,
		dat_o => dat_o,
		rst_i => rst_i,
		ack_i => ack_i,
		adr_o => adr_o,
		cyc_o => cyc_o,
		stb_o => stb_o,
		tga_o => tga_o,
		we_o => we_o,
		int => int,
		halt => halt,
		q_pc => q_pc,
		q_opc => q_opc,
		q_cat => q_cat,
		q_imm => q_imm,
		q_cyc => q_cyc,
		q_sx => q_sx,
		q_sy => q_sy,
		q_op => q_op,
		q_sa => q_sa,
		q_smq => q_smq,
		q_we_rr => q_we_rr,
		q_we_ll => q_we_ll,
		q_we_sp => q_we_sp,
		q_rr => q_rr,
		q_ll => q_ll,
		q_sp => q_sp
	);

	ack_i <= stb_o;

-- *** Test Bench - User Defined Section ***
	PROCESS -- clock process for CLK_I,
	BEGIN
		CLOCK_LOOP : LOOP
			CLK_I <= transport '0';
			WAIT FOR 1 ns;
			CLK_I <= transport '1';
			WAIT FOR 1 ns;
			WAIT FOR 11 ns;
			CLK_I <= transport '0';
			WAIT FOR 12 ns;
		END LOOP CLOCK_LOOP;
	END PROCESS;

	PROCESS(CLK_I)
	BEGIN
		if (rising_edge(CLK_I)) then
			if (Q_CYC = M1) then
				CLK_COUNTER <= CLK_COUNTER + 1;
			end if;

			if (ADR_O(0) = '0') then		DAT_I <= X"44";	-- data
			else							DAT_I <= X"01";	-- control
			end if;

			case CLK_COUNTER is
				when 0		=>	RST_I <= '1';   INT <= '0';
				when 1		=>	RST_I <= '0';
--				when 20		=>	INT <= '1';


				when 1000	=>	CLK_COUNTER <= 0;
								ASSERT (FALSE) REPORT
									"simulation done (no error)"
									SEVERITY FAILURE;
				when others	=>
			end case;
		end if;
	END PROCESS;

END;
