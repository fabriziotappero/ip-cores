--
--	jop_ml401.vhd
--
--	top level for ML401 Virtex-4
--
--		use iocore.vhd for all io-pins
--
--	2002-06-27:	2088 LCs, 23.6 MHz
--	2002-07-27:	2308 LCs, 23.1 MHz	with some changes in jvm and baseio
--	2002-08-02:	2463 LCs
--	2002-08-08:	2431 LCs simpler sigdel
--
--	2002-03-28	creation
--	2002-06-27	isa bus for CS8900
--	2002-07-27	io for baseio
--	2002-08-02	second uart (use first for download and debug)
--	2002-11-01	removed second uart
--	2002-12-01	split memio
--	2002-12-07	disable clkout
--	2003-02-21	adapt for new Cyclone board with EP1C6
--	2003-07-08	invertion of cts, rts to uart
--	2004-09-11	new extension module
--	2004-10-01	version for Xilinx
--	2004-10-08	mul operands from a and b, single instruction
--	2005-06-09	added the bsy routing through extension
--	2005-08-15	sp_ov can be used to show a stoack overflow on the wd pin
--	2005-11-24	use mem_sc for the memory interface and xs3_jbc for the
--				bc cache. Now a real block cache (+40% performance with KFL)
-- 2007-03-15  adapt for ML401 Virtex-4 FPGA board. (S. Calloway)
--	2007-03-21	Use jopcpu and change component interface to records
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;
use work.sc_pack.all;
use work.jop_config.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;



entity jop is

generic (
	ram_cnt		: integer := 4;		-- clock cycles for external ram
	rom_cnt		: integer := 15;	-- not used for S3K
	jpc_width	: integer := 11;	-- address bits of java bytecode pc = cache size
	block_bits	: integer := 4;		-- 2*block_bits is number of cache blocks
	spm_width	: integer := 0		-- size of scratchpad RAM (in number of address bits for 32-bit words)
);

port (
	clk		: in std_logic;
	
--
---- serial interface
--
	ser_txd			: out std_logic;
	ser_rxd			: in std_logic;
--
--
--	watchdog
--
	wd		: out std_logic;
	
--  Control Signals from JOP
--	configuration_trigger : out std_logic_vector(7 downto 0);	
	eRCP_trigger_reg : out std_logic;
	
--
---==========================================================--
----===========Virtex-4 SRAM Port============================--
	sram_clk : out std_logic;
	sram_feedback_clk : out std_logic;
	
	sram_addr : out std_logic_vector(22 downto 0);
	
	sram_we_n : out std_logic;
	sram_oe_n : out std_logic;

	sram_data : inout std_logic_vector(31 downto 0);
	
	sram_bw0: out std_logic;
	sram_bw1 : out std_logic;
	
	sram_bw2 : out std_Logic;
	sram_bw3 : out std_logic;
	
	sram_adv_ld_n : out std_logic;
	sram_mode : out std_logic;
	sram_cen : out std_logic;
	sram_cen_test : out std_logic;
	sram_zz : out std_logic;

---=========================================================---
---=========================================================---

--
--	I/O pins of board TODO: change this and io for xilinx board!
--
--	io_b	: inout std_logic_vector(10 downto 1);
--	io_l	: inout std_logic_vector(20 downto 1);
--	io_r	: inout std_logic_vector(20 downto 1);
--	io_t	: inout std_logic_vector(6 downto 1)

-- Wizardry Interface
	ack_i : in std_logic;
	err_i : in std_logic;
	dat_i : in std_logic_vector(31 downto 0);
	cyc_o : out std_logic;
	stb_o : out std_logic;
	we_o : out std_logic;
	dat_o : out std_logic_vector(31 downto 0);
	adr_o : out std_logic_Vector(21 downto 0);
	lock_o : out std_logic;
--	id_o : out std_logic_Vector(4 downto 0);
	priority_o : out std_logic_Vector(7 downto 0)
);
end jop;

architecture rtl of jop is
--=======================================================================
--Create alias for simple naming convention for Virtex-4 SRAM============
--======================================================================
alias virtex_ram_addr : std_logic_vector(22 downto 0) is sram_addr;
alias	ram_nwe		: std_logic is sram_we_n;
alias	ram_noe		: std_logic is sram_oe_n;
alias	rama_d		: std_logic_vector(15 downto 0) is sram_data(15 downto 0);
alias	rama_nlb	: std_logic is sram_bw0;
alias	rama_nub	: std_logic is sram_bw1;
alias	ramb_d		: std_logic_vector(15 downto 0) is sram_data(31 downto 16);
alias	ramb_nlb	: std_logic is sram_bw2;
alias	ramb_nub	: std_logic is sram_bw3;
signal rama_ncs : std_logic;
signal ramb_ncs : std_logic;
--=========================================================================


---------original JOP ram address port used to----------------
----generate 23 bit address width for Virtex-4 SRAM-----------
signal ram_addr 		: std_logic_vector(17 downto 0);
--------------------------------------------------------------
--------------------------------------------------------------


--signal ser_txd			: std_logic;
--signal ser_rxd			: std_logic;

--
--	Signals
--
	signal clk_int, clk2    : std_logic;

	signal int_res			: std_logic;
	signal res_cnt			: unsigned(2 downto 0) := "000";	-- for the simulation

	-- attribute altera_attribute : string;
	-- attribute altera_attribute of res_cnt : signal is "POWER_UP_LEVEL=LOW";

--
--	jopcpu connections
--
	signal sc_mem_out		: sc_out_type;
	signal sc_mem_in		: sc_in_type;
	signal sc_io_out		: sc_out_type;
	signal sc_io_in			: sc_in_type;
	signal irq_in			: irq_bcf_type;
	signal irq_out			: irq_ack_type;
	signal exc_req			: exception_type;

--
--	IO interface
--
	signal ser_in			: ser_in_type;
	signal ser_out			: ser_out_type;
	signal wd_out			: std_logic;

	-- for generation of internal reset

-- memory interface

	signal ram_dout			: std_logic_vector(31 downto 0);
	signal ram_din			: std_logic_vector(31 downto 0);
	signal ram_dout_en		: std_logic;
	signal ram_ncs			: std_logic;

-- not available at this board:
	signal ser_ncts			: std_logic;
	signal ser_nrts			: std_logic;
	signal sram_feedback_clk_r1,sram_feedback_clk_r2 : std_logic;
	signal sram_clk_r1,sram_clk_r2 : std_logic;

begin

--================================================--
--============VIRTEX 4 SRAM SIGNALS===============--
--process(clk)
--begin
--if(rising_edge(clk)) then
	sram_feedback_clk <= clk; --not clk;--not clk2; --clk is 100MHz clk2 is 50 MHz
	sram_clk <= clk; --not clk;--not clk2; --clk is 100MHz clk2 is 50 MHz
--end if;
--end process;



sram_adv_ld_n <= '0';
sram_mode <= '0';
sram_cen <= '0';
virtex_ram_addr <= "00000" & ram_addr;
sram_zz <= '0';

--================================================--
--================================================-- 


	ser_ncts <= '0';
--
--	intern reset
--

process(clk)--_int)--clk is 
begin
	if rising_edge(clk) then --was clk_int
		if (res_cnt/="111") then
			res_cnt <= res_cnt+1;
		end if;

		int_res <= not res_cnt(0) or not res_cnt(1) or not res_cnt(2);
	end if;
end process;
process(clk)
begin
	if rising_edge(clk) then
        clk2 <= not clk2;
	end if;
end process;

--
--	components of jop
--
	clk_int <= clk2;

	wd <= wd_out;

	cpm_cpu: entity work.jopcpu
		generic map(
			jpc_width => jpc_width,
			block_bits => block_bits,
			spm_width => spm_width
		)
		port map(clk, int_res, --was clk_int
			sc_mem_out, sc_mem_in,
			sc_io_out, sc_io_in,
			irq_in, irq_out, exc_req);

	cmp_io: entity work.scio 
		port map (clk, int_res, --was clk_int
			sc_io_out, sc_io_in,
			irq_in, irq_out, exc_req,
			
			--  Control Signals from JOP
--	configuration_trigger => configuration_trigger, 
	eRCP_trigger_reg => eRCP_trigger_reg,

			txd => ser_txd,
			rxd => ser_rxd,
			ncts => ser_ncts,
			nrts => ser_nrts,
			wd => wd_out,
			l => open,
			r => open,
			t => open,
			b => open,
			-- Wizardry Interface
			ack_i => ack_i,
			err_i => err_i,
			dat_i => dat_i,
			cyc_o => cyc_o,
			stb_o => stb_o,
			we_o => we_o,
			dat_o => dat_o,
			adr_o => adr_o,
			lock_o => lock_o,
--			id_o => id_o,
			priority_o => priority_o
		);

	cmp_scm: entity work.sc_mem_if
		generic map (
			ram_ws => ram_cnt-1,
			addr_bits => 18
		)
		port map (clk, int_res, --was clk_int
			sc_mem_out, sc_mem_in,

			ram_addr => ram_addr,
			ram_dout => ram_dout,
			ram_din => ram_din,
			ram_dout_en	=> ram_dout_en,
			ram_ncs => ram_ncs,
			ram_noe => ram_noe,
			ram_nwe => ram_nwe
		);

	process(ram_dout_en, ram_dout)
	begin
		if ram_dout_en='1' then
			rama_d <= ram_dout(15 downto 0);
			ramb_d <= ram_dout(31 downto 16);
		else
			rama_d <= (others => 'Z');
			ramb_d <= (others => 'Z');
		end if;
	end process;

	ram_din <= ramb_d & rama_d;

--
--	To put this RAM address in an output register
--	we have to make an assignment (FAST_OUTPUT_REGISTER)
--
	rama_ncs <= ram_ncs;
	rama_nlb <= '0';
	rama_nub <= '0';

	ramb_ncs <= ram_ncs;
	ramb_nlb <= '0';
	ramb_nub <= '0';

end rtl;
