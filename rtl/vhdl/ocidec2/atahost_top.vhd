---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  ATA/ATAPI-5 Controller (OCIDEC-2)                          ----
----                                                             ----
----  Author: Richard Herveille                                  ----
----          richard@asics.ws                                   ----
----          www.asics.ws                                       ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2001, 2002 Richard Herveille                  ----
----                          richard@asics.ws                   ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
----     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ----
---- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ----
---- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ----
---- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ----
---- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ----
---- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ----
---- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ----
---- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ----
---- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ----
---- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ----
---- POSSIBILITY OF SUCH DAMAGE.                                 ----
----                                                             ----
---------------------------------------------------------------------

-- rev.: 1.0a Removed references to records.vhd, make core compatible with VHDL to Verilog translator tools
-- rev.: 1.1  june 18th, 2001. Changed wishbone address input from ADR_I(4 downto 0) to ADR_I(6 downto 2)
-- rev.: 1.1a june 19th, 2001. Simplified DAT_O output multiplexor.
--
--  CVS Log
--
--  $Id: atahost_top.vhd,v 1.1 2002-02-18 14:30:48 rherveille Exp $
--
--  $Date: 2002-02-18 14:30:48 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: not supported by cvs2svn $
--


--
-- DeviceType: OCIDEC-2: OpenCores IDE Controller type2
-- Features: PIO Compatible Timing, PIO Fast Timing 0/1
-- DeviceID: 0x02
-- RevNo : 0x00

--
-- Host signals:
-- Reset
-- DIOR-		read strobe. The falling edge enables data from device onto DD. The rising edge latches data at the host.
-- DIOW-		write strobe. The rising edge latches data from DD into the device.
-- DA(2:0)		3bit binary coded adress
-- CS0-		select command block registers
-- CS1-		select control block registers

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity atahost_top is
	generic(
		ARST_LVL : std_logic := '0';                -- asynchronous reset level

		TWIDTH : natural := 8;                      -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;                -- 70ns
		PIO_mode0_T2 : natural := 28;               -- 290ns
		PIO_mode0_T4 : natural := 2;                -- 30ns
		PIO_mode0_Teoc : natural := 23              -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		-- WISHBONE SYSCON signals
		wb_clk_i  : in std_logic;                       -- master clock in
		arst_i    : in std_logic := '1';                -- asynchronous active low reset
		wb_rst_i  : in std_logic := '0';                -- synchronous active high reset

		-- WISHBONE SLAVE signals
		wb_cyc_i  : in std_logic;                       -- valid bus cycle input
		wb_stb_i  : in std_logic;                       -- strobe/core select input
		wb_ack_o  : out std_logic;                      -- strobe acknowledge output
		wb_err_o  : out std_logic;                      -- error output
		wb_adr_i  : in unsigned(6 downto 2);            -- A6 = '1' ATA devices selected
		                                                --          A5 = '1' CS1- asserted, '0' CS0- asserted
		                                                --          A4..A2 ATA address lines
		                                                -- A6 = '0' ATA controller selected
		wb_dat_i  : in std_logic_vector(31 downto 0);   -- Databus in
		wb_dat_o  : out std_logic_vector(31 downto 0);  -- Databus out
		wb_sel_i  : in std_logic_vector(3 downto 0);    -- Byte select signals
		wb_we_i   : in std_logic;                       -- Write enable input
		wb_inta_o : out std_logic;                      -- interrupt request signal IDE0

		-- ATA signals
		resetn_pad_o : out std_logic;
		dd_pad_i     : in  std_logic_vector(15 downto 0);
		dd_pad_o     : out std_logic_vector(15 downto 0);
		dd_padoe_o   : out std_logic;
		da_pad_o     : out unsigned(2 downto 0);
		cs0n_pad_o   : out std_logic;
		cs1n_pad_o   : out std_logic;

		diorn_pad_o	: out std_logic;
		diown_pad_o	: out std_logic;
		iordy_pad_i	: in  std_logic;
		intrq_pad_i	: in  std_logic
	);
end entity atahost_top;

architecture structural of atahost_top is
	--
	-- constants
	--

	-- Device ID
	constant DeviceId : unsigned(3 downto 0) := x"2";
	constant RevisionNo : unsigned(3 downto 0) := x"0";

	--
	-- component declarations
	--
	component atahost_wb_slave is
	generic(
		DeviceID   : unsigned(3 downto 0) := x"0";
		RevisionNo : unsigned(3 downto 0) := x"0";

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;                -- 70ns
		PIO_mode0_T2 : natural := 28;               -- 290ns
		PIO_mode0_T4 : natural := 2;                -- 30ns
		PIO_mode0_Teoc : natural := 23;             -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240

		-- Multiword DMA mode 0 settings (@100MHz clock)
		DMA_mode0_Tm : natural := 4;                -- 50ns
		DMA_mode0_Td : natural := 21;               -- 215ns
		DMA_mode0_Teoc : natural := 21              -- 215ns ==> T0 - Td - Tm = 480 - 50 - 215 = 215
	);
	port(
		-- WISHBONE SYSCON signals
		clk_i  : in std_logic;                      -- master clock in
		arst_i : in std_logic := '1';               -- asynchronous active low reset
		rst_i  : in std_logic := '0';               -- synchronous active high reset

		-- WISHBONE SLAVE signals
		cyc_i : in std_logic;                       -- valid bus cycle input
		stb_i : in std_logic;                       -- strobe/core select input
		ack_o : out std_logic;                      -- strobe acknowledge output
		rty_o : out std_logic;                      -- retry output
		err_o : out std_logic;                      -- error output
		adr_i : in unsigned(6 downto 2);            -- A6 = '1' ATA devices selected
		                                            --          A5 = '1' CS1- asserted, '0' CS0- asserted
		                                            --          A4..A2 ATA address lines
		                                            -- A6 = '0' ATA controller selected
		dat_i  : in std_logic_vector(31 downto 0);  -- Databus in
		dat_o  : out std_logic_vector(31 downto 0); -- Databus out
		sel_i  : in std_logic_vector(3 downto 0);   -- Byte select signals
		we_i   : in std_logic;                      -- Write enable input
		inta_o : out std_logic;                     -- interrupt request signal IDE0

		-- PIO control input
		PIOsel     : buffer std_logic;
		PIOtip,                                         -- PIO transfer in progress
		PIOack     : in std_logic;                      -- PIO acknowledge signal
		PIOq       : in std_logic_vector(15 downto 0);  -- PIO data input
		PIOpp_full : in std_logic;                      -- PIO write-ping-pong buffers full
		irq        : in std_logic;                      -- interrupt signal input

		-- DMA control inputs
		DMAsel    : out std_logic;
		DMAtip,                                     -- DMA transfer in progress
		DMAack,                                     -- DMA transfer acknowledge
		DMARxEmpty,                                 -- DMA receive buffer empty
		DMATxFull,                                  -- DMA transmit buffer full
		DMA_dmarq : in std_logic;                   -- wishbone DMA request
		DMAq      : in std_logic_vector(31 downto 0);

		-- outputs
		-- control register outputs
		IDEctrl_rst,
		IDEctrl_IDEen,
		IDEctrl_FATR1,
		IDEctrl_FATR0,
		IDEctrl_ppen,
		DMActrl_DMAen,
		DMActrl_dir,
		DMActrl_BeLeC0,
		DMActrl_BeLeC1 : out std_logic;

		-- CMD port timing registers
		PIO_cmdport_T1,
		PIO_cmdport_T2,
		PIO_cmdport_T4,
		PIO_cmdport_Teoc    : buffer unsigned(7 downto 0);
		PIO_cmdport_IORDYen : out std_logic;

		-- data-port0 timing registers
		PIO_dport0_T1,
		PIO_dport0_T2,
		PIO_dport0_T4,
		PIO_dport0_Teoc    : buffer unsigned(7 downto 0);
		PIO_dport0_IORDYen : out std_logic;

		-- data-port1 timing registers
		PIO_dport1_T1,
		PIO_dport1_T2,
		PIO_dport1_T4,
		PIO_dport1_Teoc    : buffer unsigned(7 downto 0);
		PIO_dport1_IORDYen : out std_logic;

		-- DMA device0 timing registers
		DMA_dev0_Tm,
		DMA_dev0_Td,
		DMA_dev0_Teoc    : buffer unsigned(7 downto 0);

		-- DMA device1 timing registers
		DMA_dev1_Tm,
		DMA_dev1_Td,
		DMA_dev1_Teoc    : buffer unsigned(7 downto 0)
	);
	end component atahost_wb_slave;


	component atahost_controller is
	generic(
		TWIDTH : natural := 8;                   -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;             -- 70ns
		PIO_mode0_T2 : natural := 28;            -- 290ns
		PIO_mode0_T4 : natural := 2;             -- 30ns
		PIO_mode0_Teoc : natural := 23           -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		clk : in std_logic;  		                    	  -- master clock in
		nReset : in std_logic := '1';                 -- asynchronous active low reset
		rst : in std_logic := '0';                    -- synchronous active high reset
		
		irq : out std_logic;                          -- interrupt request signal

		-- control / registers
		IDEctrl_rst,
		IDEctrl_IDEen,
		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;

		-- PIO registers
		cmdport_T1,
		cmdport_T2,
		cmdport_T4,
		cmdport_Teoc : in unsigned(7 downto 0);
		cmdport_IORDYen : in std_logic;            -- PIO command port / non-fast timing

		dport0_T1,
		dport0_T2,
		dport0_T4,
		dport0_Teoc : in unsigned(7 downto 0);
		dport0_IORDYen : in std_logic;             -- PIO mode data-port / fast timing device 0

		dport1_T1,
		dport1_T2,
		dport1_T4,
		dport1_Teoc : in unsigned(7 downto 0);
		dport1_IORDYen : in std_logic;             -- PIO mode data-port / fast timing device 1

		PIOreq : in std_logic;                        -- PIO transfer request
		PIOack : buffer std_logic;                    -- PIO transfer ended
		PIOa : in unsigned(3 downto 0);               -- PIO address
		PIOd : in std_logic_vector(15 downto 0);      -- PIO data in
		PIOq : out std_logic_vector(15 downto 0);     -- PIO data out
		PIOwe : in std_logic;                         -- PIO direction bit '1'=write, '0'=read

		-- ATA signals
		RESETn	: out std_logic;
		DDi	: in std_logic_vector(15 downto 0);
		DDo : out std_logic_vector(15 downto 0);
		DDoe : out std_logic;
		DA	: out unsigned(2 downto 0);
		CS0n	: out std_logic;
		CS1n	: out std_logic;

		DIORn	: out std_logic;
		DIOWn	: out std_logic;
		IORDY	: in std_logic;
		INTRQ	: in std_logic
	);
	end component atahost_controller;

	-- asynchronous reset signal
	signal arst_signal : std_logic;

	-- primary address decoder
	signal PIOsel  : std_logic;  -- controller select, IDE devices select
	
	-- registers
	-- control register
	signal IDEctrl_rst, IDEctrl_IDEen, IDEctrl_FATR0, IDEctrl_FATR1 : std_logic;
	-- compatible mode timing register
	signal PIO_cmdport_T1, PIO_cmdport_T2, PIO_cmdport_T4, PIO_cmdport_Teoc : unsigned(7 downto 0);
	signal PIO_cmdport_IORDYen : std_logic;
	-- data port0 timing register
	signal PIO_dport0_T1, PIO_dport0_T2, PIO_dport0_T4, PIO_dport0_Teoc : unsigned(7 downto 0);
	signal PIO_dport0_IORDYen : std_logic;
	-- data port1 timing register
	signal PIO_dport1_T1, PIO_dport1_T2, PIO_dport1_T4, PIO_dport1_Teoc : unsigned(7 downto 0);
	signal PIO_dport1_IORDYen : std_logic;

	signal PIOack : std_logic;
	signal PIOq : std_logic_vector(15 downto 0);

	signal irq : std_logic; -- ATA bus IRQ signal

begin
	-- generate asynchronous reset level
	arst_signal <= arst_i xor ARST_LVL;

	--
	-- hookup wishbone slave
	--
	u0: atahost_wb_slave 
		generic map(
			DeviceID   => DeviceID,
			RevisionNo => RevisionNo,

			-- PIO mode 0 settings
			PIO_mode0_T1 => PIO_mode0_T1,
			PIO_mode0_T2 => PIO_mode0_T2,
			PIO_mode0_T4 => PIO_mode0_T4,
			PIO_mode0_Teoc => PIO_mode0_Teoc,

			-- Multiword DMA mode 0 settings
			-- OCIDEC-1 does not support DMA, set registers to zero
			DMA_mode0_Tm   => 0,
			DMA_mode0_Td   => 0,
			DMA_mode0_Teoc => 0
		)
		port map(
			-- WISHBONE SYSCON signals
			clk_i => wb_clk_i,
			arst_i => arst_signal,
			rst_i  => wb_rst_i,

			-- WISHBONE SLAVE signals
			cyc_i => wb_cyc_i,
			stb_i => wb_stb_i,
			ack_o => wb_ack_o,
			err_o => wb_err_o,
			adr_i => wb_adr_i,
			dat_i => wb_dat_i,
			dat_o => wb_dat_o,
			sel_i => wb_sel_i,
			we_i  => wb_we_i,
			inta_o => wb_inta_o,

			-- PIO control input
			--	PIOtip is only asserted during a PIO transfer (No shit! ;)
			--	Since it is impossible to read the status register and access the PIO registers at the same time
			--	this bit is useless (besides using-up resources)
			PIOtip     => '0',
			PIOack     => PIOack,
			PIOq       => PIOq,
			PIOsel     => PIOsel,
			PIOpp_full => '0', -- OCIDEC-1 does not support PIO-write PingPong, negate signal
			irq        => irq,

			-- DMA control inputs (negate all of them)
			DMAtip     => '0',
			DMAack     => '0',
			DMARxEmpty => '0',
			DMATxFull  => '0',
			DMA_dmarq  => '0',
			DMAq       => x"00000000",

			-- outputs
			-- control register outputs
			IDEctrl_rst   => IDEctrl_rst,
			IDEctrl_IDEen => IDEctrl_IDEen,
			IDEctrl_FATR0 => IDEctrl_FATR0,
			IDEctrl_FATR1 => IDEctrl_FATR1,

			-- CMD port timing registers
			PIO_cmdport_T1 => PIO_cmdport_T1,
			PIO_cmdport_T2 => PIO_cmdport_T2,
			PIO_cmdport_T4 => PIO_cmdport_T4,
			PIO_cmdport_Teoc => PIO_cmdport_Teoc,
			PIO_cmdport_IORDYen => PIO_cmdport_IORDYen,

			-- data-port0 timing registers
			PIO_dport0_T1 => PIO_dport0_T1,
			PIO_dport0_T2 => PIO_dport0_T2,
			PIO_dport0_T4 => PIO_dport0_T4,
			PIO_dport0_Teoc => PIO_dport0_Teoc,
			PIO_dport0_IORDYen => PIO_dport0_IORDYen,

			-- data-port1 timing registers
			PIO_dport1_T1 => PIO_dport1_T1,
			PIO_dport1_T2 => PIO_dport1_T2,
			PIO_dport1_T4 => PIO_dport1_T4,
			PIO_dport1_Teoc => PIO_dport1_Teoc,
			PIO_dport1_IORDYen => PIO_dport1_IORDYen
		);

	--
	-- hookup controller section
	--
	u1: atahost_controller
		generic map(
			TWIDTH => TWIDTH,
			PIO_mode0_T1 => PIO_mode0_T1,
			PIO_mode0_T2 => PIO_mode0_T2,
			PIO_mode0_T4 => PIO_mode0_T4,
			PIO_mode0_Teoc => PIO_mode0_Teoc
		)
		port map(
			clk => wb_clk_i,
			nReset => arst_signal,
			rst => wb_rst_i,
			irq => irq,
			IDEctrl_rst => IDEctrl_rst,
			IDEctrl_IDEen => IDEctrl_IDEen,
			IDEctrl_FATR0 => IDEctrl_FATR0,
			IDEctrl_FATR1 => IDEctrl_FATR1,
			cmdport_T1 => PIO_cmdport_T1,
			cmdport_T2 => PIO_cmdport_T2,
			cmdport_T4 => PIO_cmdport_T4,
			cmdport_Teoc => PIO_cmdport_Teoc,
			cmdport_IORDYen => PIO_cmdport_IORDYen,
			dport0_T1 => PIO_dport0_T1,
			dport0_T2 => PIO_dport0_T2,
			dport0_T4 => PIO_dport0_T4,
			dport0_Teoc => PIO_dport0_Teoc,
			dport0_IORDYen => PIO_dport0_IORDYen,
			dport1_T1 => PIO_dport1_T1,
			dport1_T2 => PIO_dport1_T2,
			dport1_T4 => PIO_dport1_T4,
			dport1_Teoc => PIO_dport1_Teoc,
			dport1_IORDYen => PIO_dport1_IORDYen,
			PIOreq => PIOsel,
			PIOack => PIOack,
			PIOa => wb_adr_i(5 downto 2),
			PIOd => wb_dat_i(15 downto 0),
			PIOq => PIOq,
			PIOwe => wb_we_i,
			RESETn => resetn_pad_o,
			DDi    => dd_pad_i,
			DDo    => dd_pad_o,
			DDoe   => dd_padoe_o,
			DA     => da_pad_o,
			CS0n   => cs0n_pad_o,
			CS1n   => cs1n_pad_o,
			DIORn  => diorn_pad_o,
			DIOWn  => diown_pad_o,
			IORDY  => iordy_pad_i,
			INTRQ  => intrq_pad_i
		);
end architecture structural;

