--
-- Wishbone compliant cycle shared memory, priority based selection
-- author: Richard Herveille
-- 
-- rev.: 1.0  july  12th, 2001. Initial release
--
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity csm_pb is
	generic(
		DWIDTH : natural := 32; -- databus width
		AWIDTH : natural := 8   -- addressbus width
	);
	port(
		-- SYSCON signals
		CLK_I   : in std_logic; -- wishbone clock input
		RST_I   : in std_logic; -- synchronous active high reset
		nRESET  : in std_logic; -- asynchronous active low reset

		-- wishbone slave0 connections
		ADR0_I : in unsigned(AWIDTH -1 downto 0);              -- address input
		DAT0_I : in std_logic_vector(DWIDTH -1 downto 0);      -- data input
		DAT0_O : out std_logic_vector(DWIDTH -1 downto 0);     -- data output
		SEL0_I : in std_logic_vector( (DWIDTH/8) -1 downto 0); -- byte select input
		WE0_I : in std_logic;                                  -- write enable input
		STB0_I : in std_logic;                                 -- strobe input
		CYC0_I : in std_logic;                                 -- valid bus cycle input
		ACK0_O : out std_logic;                                -- acknowledge output
		ERR0_O : out std_logic;                                -- error output

		-- wishbone slave1 connections
		ADR1_I : in unsigned(AWIDTH -1 downto 0);              -- address input
		DAT1_I : in std_logic_vector(DWIDTH -1 downto 0);      -- data input
		DAT1_O : out std_logic_vector(DWIDTH -1 downto 0);     -- data output
		SEL1_I : in std_logic_vector( (DWIDTH/8) -1 downto 0); -- byte select input
		WE1_I : in std_logic;                                  -- write enable input
		STB1_I : in std_logic;                                 -- strobe input
		CYC1_I : in std_logic;                                 -- valid bus cycle input
		ACK1_O : out std_logic;                                -- acknowledge output
		ERR1_O : out std_logic                                 -- error output
	);
end entity csm_pb;

architecture structural of csm_pb is
	-- function declarations
	function "and"(L: std_logic_vector; R : std_logic) return std_logic_vector is
		variable tmp : std_logic_vector(L'range);
	begin
		for n in L'range loop
			tmp(n) := L(n) and R;
		end loop;
		return tmp;
	end function "and";

	function "and"(L: std_logic; R : std_logic_vector) return std_logic_vector is
	begin
		return (R and L);
	end function "and";

	-- define memory array
	type mem_array is array(2**AWIDTH -1 downto 0) of std_logic_vector(DWIDTH -1 downto 0);
	signal mem : mem_array;

	-- multiplexor select signal
	signal wb0_acc, dwb0_acc : std_logic;
	signal wb1_acc, dwb1_acc : std_logic;
	signal sel_wb0 : std_logic;
	signal sel_wb1 : std_logic;
	signal ack0_pipe, ack1_pipe : std_logic_vector(3 downto 0);
	
	-- multiplexed memory busses / signals
	signal mem_adr, mem_radr : unsigned(AWIDTH -1 downto 0);
	signal mem_dati, mem_dato : std_logic_vector(DWIDTH -1 downto 0);
	signal mem_we : std_logic;

	-- acknowledge generation
	signal wb0_ack, wb1_ack : std_logic;

	-- error signal generation
	signal err0, err1 : std_logic_vector( (DWIDTH/8) -1 downto 0);

begin
	-- generate multiplexor select signal
	wb0_acc <= CYC0_I and STB0_I;
	wb1_acc <= CYC1_I and STB1_I and not sel_wb0;

	process(CLK_I)
	begin
		if (CLK_I'event and CLK_I = '1') then
			dwb0_acc <= wb0_acc and not wb0_ack;
			dwb1_acc <= wb1_acc and not wb1_ack;
		end if;
	end process;

	sel_wb0 <= wb0_acc and not dwb0_acc;
	sel_wb1 <= wb1_acc and not dwb1_acc;

	gen_ack_pipe: process(CLK_I, nRESET)
	begin
		if (nRESET = '0') then
			ack0_pipe <= (others => '0');
			ack1_pipe <= (others => '0');
		elsif (CLK_I'event and CLK_I = '1') then
			if (RST_I = '1') then
				ack0_pipe <= (others => '0');
				ack1_pipe <= (others => '0');
			else
				ack0_pipe <= (ack0_pipe(2 downto 0) & sel_wb0) and not wb0_ack;
				ack1_pipe <= (ack1_pipe(2 downto 0) & sel_wb1) and not wb1_ack;
			end if;
		end if;
	end process gen_ack_pipe;

	-- multiplex memory bus
--	gen_muxs: process(CLK_I)
--	begin
--		if (CLK_I'event and CLK_I = '1') then
--			if (sel_wb0 = '1') then
--				mem_adr  <= adr0_i;
--				mem_dati <= dat0_i;
--				mem_we   <= we0_i and cyc0_i and stb0_i and not wb0_ack;
--			else
--				mem_adr  <= adr1_i;
--				mem_dati <= dat1_i;
--				mem_we   <= we1_i and cyc1_i and stb1_i and not wb1_ack;
--			end if;
--		end if;
--	end process gen_muxs;

	mem_adr  <= adr0_i when (sel_wb0 = '1') else adr1_i;
	mem_dati <= dat0_i when (sel_wb0 = '1') else dat1_i;
	mem_we   <= (we0_i and cyc0_i and stb0_i) when (sel_wb0 = '1') else (we1_i and cyc1_i and stb1_i);

	-- memory access
	gen_mem: process(CLK_I)
	begin
		if (CLK_I'event and CLK_I = '1') then
			-- write operation
			if (mem_we = '1') then
				mem(conv_integer(mem_adr)) <= mem_dati;
			end if;

			-- read operation
			mem_radr <= mem_adr; -- FLEX RAMs require address to be registered with inclock for read operation.
			mem_dato <= mem(conv_integer(mem_radr));
		end if;		
	end process gen_mem;

	-- assign DAT_O outputs
	DAT1_O <= mem_dato;
	DAT0_O <= mem_dato;

	-- assign ACK_O outputs
--	gen_ack: process(CLK_I)
--	begin
--		if (CLK_I'event and CLK_I = '1') then
			wb0_ack <= ( (sel_wb0 and WE0_I) or (ack0_pipe(1)) );-- and not wb0_ack;
			wb1_ack <= ( (sel_wb1 and WE1_I) or (ack1_pipe(1)) );-- and not wb1_ack;
--		end if;
--	end process gen_ack;
	-- ACK outputs
	ACK0_O <= wb0_ack;
	ACK1_O <= wb1_ack;

	-- ERR outputs
	err0 <= (others => '1');
	ERR0_O <= '1' when ( (SEL0_I /= err0) and (CYC0_I = '1') and (STB0_I = '1') ) else '0';

	err1 <= (others => '1');
	ERR1_O <= '1' when ( (SEL1_I /= err1) and (CYC1_I = '1') and (STB1_I = '1') ) else '0';
end architecture;




