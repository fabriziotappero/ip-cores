---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  Wishbone Slave (common for all OCIDEC cores)               ----
----                                                             ----
----  Author: Richard Herveille                                  ----
----          richard@asics.ws                                   ----
----          www.asics.ws                                       ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2002 Richard Herveille                        ----
----                    richard@asics.ws                         ----
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

--
--  CVS Log
--
--  $Id: atahost_wb_slave.vhd,v 1.1 2002-02-18 14:32:12 rherveille Exp $
--
--  $Date: 2002-02-18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: not supported by cvs2svn $
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity atahost_wb_slave is
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
end entity atahost_wb_slave;

architecture structural of atahost_wb_slave is
	--
	-- constants
	--

	-- addresses
	alias    ATA_DEV_ADR  : std_logic is adr_i(6);
	alias    ATA_ADR      : unsigned(3 downto 0) is adr_i(5 downto 2);

	constant ATA_CTRL_REG : unsigned(3 downto 0) := "0000";
	constant ATA_STAT_REG : unsigned(3 downto 0) := "0001";
	constant ATA_PIO_CMD  : unsigned(3 downto 0) := "0010";
	constant ATA_PIO_DP0  : unsigned(3 downto 0) := "0011";
	constant ATA_PIO_DP1  : unsigned(3 downto 0) := "0100";
	constant ATA_DMA_DEV0 : unsigned(3 downto 0) := "0101";
	constant ATA_DMA_DEV1 : unsigned(3 downto 0) := "0110";
	-- reserved --
	constant ATA_DMA_PORT : unsigned(3 downto 0) := "1111";

	--
	-- function declarations
	--
	-- overload '=' to compare two unsigned numbers
	function "=" (a, b : unsigned) return std_logic is	
		alias la: unsigned(1 to a'length) is a;
		alias lb: unsigned(1 to b'length) is b;
		variable result : std_logic;
	begin
		-- check vector length
      assert a'length = b'length
             report "std_logic_vector comparison: operands of unequal lengths"
             severity FAILURE;

		result := '1';
		for n in 1 to a'length loop
			result := result and not (la(n) xor lb(n));
		end loop;

		return result;
	end;

	-- primary address decoder
	signal CONsel : std_logic;                        -- controller select, IDE devices select
	signal berr, brty : std_logic;                    -- bus error, bus retry

	-- registers
	signal CtrlReg, StatReg : std_logic_vector(31 downto 0); -- control and status registers

begin
	--
	-- generate bus cycle / address decoder
	--
	gen_bc_dec: block
		signal w_acc, dw_acc : std_logic;      -- word access, double word access
		signal store_pp_full : std_logic;
	begin
		-- word / double word
		w_acc  <= sel_i(1) and sel_i(0);
		dw_acc <= sel_i(3) and sel_i(2) and sel_i(1) and sel_i(0);

		-- bus error
		berr  <= not w_acc when (ATA_DEV_ADR = '1') else not dw_acc;

	   -- PIO accesses at least 16bit wide, no PIO access during DMAtip or pingpong full
		PIOsel <= cyc_i and stb_i and ATA_DEV_ADR and w_acc and not (DMAtip or store_pp_full);

		-- CON accesses only 32bit wide
		CONsel <= cyc_i and stb_i and not ATA_DEV_ADR and dw_acc;
		DMAsel <= CONsel and (ATA_ADR = ATA_DMA_PORT);

		-- bus retry (OCIDEC-3 and above)
		-- store PIOpp_full, we don't want a PPfull based retry initiated by the current bus-cycle
		process(clk_i)
		begin
			if (clk_i'event and clk_i = '1') then
				if (PIOsel = '0') then
					store_pp_full <= PIOpp_full;
				end if;
			end if;
		end process;
		brty <= (ATA_DEV_ADR and w_acc) and (DMAtip or store_pp_full);
	end block gen_bc_dec;

	--
	-- generate registers
	--
	register_block : block
		signal sel_PIO_cmdport, sel_PIO_dport0, sel_PIO_dport1 : std_logic; -- PIO timing registers
		signal sel_DMA_dev0, sel_DMA_dev1 : std_logic;                      -- DMA timing registers
		signal sel_ctrl, sel_stat : std_logic;                              -- control / status register
	begin
		-- generate register select signals
		sel_ctrl        <= CONsel and we_i and (ATA_ADR = ATA_CTRL_REG);
		sel_stat        <= CONsel and we_i and (ATA_ADR = ATA_STAT_REG);
		sel_PIO_cmdport <= CONsel and we_i and (ATA_ADR = ATA_PIO_CMD);
		sel_PIO_dport0  <= CONsel and we_i and (ATA_ADR = ATA_PIO_DP0);
		sel_PIO_dport1  <= CONsel and we_i and (ATA_ADR = ATA_PIO_DP1);
		sel_DMA_dev0    <= CONsel and we_i and (ATA_ADR = ATA_DMA_DEV0);
		sel_DMA_dev1    <= CONsel and we_i and (ATA_ADR = ATA_DMA_DEV1);
		-- reserved 0x1C-0x38 --
		-- reserved 0x3C : DMA port --

		-- generate control register
		gen_ctrl_reg: process(clk_i, arst_i)
		begin
			if (arst_i = '0') then
				CtrlReg(31 downto 1) <= (others => '0');
				CtrlReg(0)           <= '1';                -- set reset bit
			elsif (clk_i'event and clk_i = '1') then
				if (rst_i = '1') then
					CtrlReg(31 downto 1) <= (others => '0');
					CtrlReg(0)           <= '1';                -- set reset bit
				elsif (sel_ctrl = '1') then
					CtrlReg <= dat_i;
				end if;
			end if;
		end process gen_ctrl_reg;
		-- assign bits
		DMActrl_DMAen        <= CtrlReg(15);
		DMActrl_dir          <= CtrlReg(13);
		DMActrl_BeLeC1       <= CtrlReg(9);
		DMActrl_BeLeC0       <= CtrlReg(8);
		IDEctrl_IDEen        <= CtrlReg(7);
		IDEctrl_FATR1        <= CtrlReg(6);
		IDEctrl_FATR0        <= CtrlReg(5);
		IDEctrl_ppen         <= CtrlReg(4);
		PIO_dport1_IORDYen   <= CtrlReg(3);
		PIO_dport0_IORDYen   <= CtrlReg(2);
		PIO_cmdport_IORDYen  <= CtrlReg(1);
		IDEctrl_rst          <= CtrlReg(0);

		-- generate status register clearable bits
		gen_stat_reg: block
			signal dirq, int : std_logic;
		begin
			gen_irq: process(clk_i, arst_i)
			begin
				if (arst_i = '0') then
					int  <= '0';
					dirq <= '0';
				elsif (clk_i'event and clk_i = '1') then
					if (rst_i = '1') then
						int  <= '0';
						dirq <= '0';
					else
						int  <= (int or (irq and not dirq)) and not (sel_stat and not dat_i(0));
						dirq <= irq;
					end if;
				end if;
			end process gen_irq;

			gen_stat: process(DMAtip, DMARxEmpty, DMATxFull, DMA_dmarq, PIOtip, int, PIOpp_full)
			begin
				StatReg(31 downto 0) <= (others => '0');                -- clear all bits (read unused bits as '0')

				StatReg(31 downto 28) <= std_logic_vector(DeviceId);    -- set Device ID
				StatReg(27 downto 24) <= std_logic_vector(RevisionNo);  -- set revision number
				StatReg(15) <= DMAtip;
				StatReg(10) <= DMARxEmpty;
				StatReg(9)  <= DMATxFull;
				StatReg(8)  <= DMA_dmarq;
				StatReg(7)  <= PIOtip;
				StatReg(6)  <= PIOpp_full;
				StatReg(0)  <= int;
			end process;
		end block gen_stat_reg;

		-- generate PIO compatible / command-port timing register
		gen_PIO_cmdport_reg: process(clk_i, arst_i)
		begin
			if (arst_i = '0') then
				PIO_cmdport_T1   <= conv_unsigned(PIO_mode0_T1, 8);
				PIO_cmdport_T2   <= conv_unsigned(PIO_mode0_T2, 8);
				PIO_cmdport_T4   <= conv_unsigned(PIO_mode0_T4, 8);
				PIO_cmdport_Teoc <= conv_unsigned(PIO_mode0_Teoc, 8);
			elsif (clk_i'event and clk_i = '1') then
				if (rst_i = '1') then
					PIO_cmdport_T1   <= conv_unsigned(PIO_mode0_T1, 8);
					PIO_cmdport_T2   <= conv_unsigned(PIO_mode0_T2, 8);
					PIO_cmdport_T4   <= conv_unsigned(PIO_mode0_T4, 8);
					PIO_cmdport_Teoc <= conv_unsigned(PIO_mode0_Teoc, 8);
				elsif (sel_PIO_cmdport = '1') then
					PIO_cmdport_T1   <= unsigned(dat_i( 7 downto  0));
					PIO_cmdport_T2   <= unsigned(dat_i(15 downto  8));
					PIO_cmdport_T4   <= unsigned(dat_i(23 downto 16));
					PIO_cmdport_Teoc <= unsigned(dat_i(31 downto 24));
				end if;
			end if;
		end process gen_PIO_cmdport_reg;

		-- generate PIO device0 timing register
		gen_PIO_dport0_reg: process(clk_i, arst_i)
		begin
			if (arst_i = '0') then
				PIO_dport0_T1   <= conv_unsigned(PIO_mode0_T1, 8);
				PIO_dport0_T2   <= conv_unsigned(PIO_mode0_T2, 8);
				PIO_dport0_T4   <= conv_unsigned(PIO_mode0_T4, 8);
				PIO_dport0_Teoc <= conv_unsigned(PIO_mode0_Teoc, 8);
			elsif (clk_i'event and clk_i = '1') then
				if (rst_i = '1') then
					PIO_dport0_T1   <= conv_unsigned(PIO_mode0_T1, 8);
					PIO_dport0_T2   <= conv_unsigned(PIO_mode0_T2, 8);
					PIO_dport0_T4   <= conv_unsigned(PIO_mode0_T4, 8);
					PIO_dport0_Teoc <= conv_unsigned(PIO_mode0_Teoc, 8);
				elsif (sel_PIO_dport0 = '1') then
					PIO_dport0_T1   <= unsigned(dat_i( 7 downto  0));
					PIO_dport0_T2   <= unsigned(dat_i(15 downto  8));
					PIO_dport0_T4   <= unsigned(dat_i(23 downto 16));
					PIO_dport0_Teoc <= unsigned(dat_i(31 downto 24));
				end if;
			end if;
		end process gen_PIO_dport0_reg;

		-- generate PIO device1 timing register
		gen_PIO_dport1_reg: process(clk_i, arst_i)
		begin
			if (arst_i = '0') then
				PIO_dport1_T1   <= conv_unsigned(PIO_mode0_T1, 8);
				PIO_dport1_T2   <= conv_unsigned(PIO_mode0_T2, 8);
				PIO_dport1_T4   <= conv_unsigned(PIO_mode0_T4, 8);
				PIO_dport1_Teoc <= conv_unsigned(PIO_mode0_Teoc, 8);
			elsif (clk_i'event and clk_i = '1') then
				if (rst_i = '1') then
					PIO_dport1_T1   <= conv_unsigned(PIO_mode0_T1, 8);
					PIO_dport1_T2   <= conv_unsigned(PIO_mode0_T2, 8);
					PIO_dport1_T4   <= conv_unsigned(PIO_mode0_T4, 8);
					PIO_dport1_Teoc <= conv_unsigned(PIO_mode0_Teoc, 8);
				elsif (sel_PIO_dport1 = '1') then
					PIO_dport1_T1   <= unsigned(dat_i( 7 downto  0));
					PIO_dport1_T2   <= unsigned(dat_i(15 downto  8));
					PIO_dport1_T4   <= unsigned(dat_i(23 downto 16));
					PIO_dport1_Teoc <= unsigned(dat_i(31 downto 24));
				end if;
			end if;
		end process gen_PIO_dport1_reg;

		-- generate DMA device0 timing register
		gen_DMA_dev0_reg: process(clk_i, arst_i)
		begin
			if (arst_i = '0') then
				DMA_dev0_Tm   <= conv_unsigned(DMA_mode0_Tm, 8);
				DMA_dev0_Td   <= conv_unsigned(DMA_mode0_Td, 8);
				DMA_dev0_Teoc <= conv_unsigned(DMA_mode0_Teoc, 8);
			elsif (clk_i'event and clk_i = '1') then
				if (rst_i = '1') then
					DMA_dev0_Tm   <= conv_unsigned(DMA_mode0_Tm, 8);
					DMA_dev0_Td   <= conv_unsigned(DMA_mode0_Td, 8);
					DMA_dev0_Teoc <= conv_unsigned(DMA_mode0_Teoc, 8);
				elsif (sel_DMA_dev0 = '1') then
					DMA_dev0_Tm   <= unsigned(dat_i( 7 downto  0));
					DMA_dev0_Td   <= unsigned(dat_i(15 downto  8));
					DMA_dev0_Teoc <= unsigned(dat_i(31 downto 24));
				end if;
			end if;
		end process gen_DMA_dev0_reg;

		-- generate DMA device1 timing register
		gen_DMA_dev1_reg: process(clk_i, arst_i)
		begin
			if (arst_i = '0') then
				DMA_dev1_Tm   <= conv_unsigned(DMA_mode0_Tm, 8);
				DMA_dev1_Td   <= conv_unsigned(DMA_mode0_Td, 8);
				DMA_dev1_Teoc <= conv_unsigned(DMA_mode0_Teoc, 8);
			elsif (clk_i'event and clk_i = '1') then
				if (rst_i = '1') then
					DMA_dev1_Tm   <= conv_unsigned(DMA_mode0_Tm, 8);
					DMA_dev1_Td   <= conv_unsigned(DMA_mode0_Td, 8);
					DMA_dev1_Teoc <= conv_unsigned(DMA_mode0_Teoc, 8);
				elsif (sel_DMA_dev1 = '1') then
					DMA_dev1_Tm   <= unsigned(dat_i( 7 downto  0));
					DMA_dev1_Td   <= unsigned(dat_i(15 downto  8));
					DMA_dev1_Teoc <= unsigned(dat_i(31 downto 24));
				end if;
			end if;
		end process gen_DMA_dev1_reg;

	end block register_block;

	--
	-- generate WISHBONE interconnect signals
	--
	gen_WB_sigs: block
		signal Q : std_logic_vector(31 downto 0);
	begin
		-- generate acknowledge signal
		ack_o <= PIOack or CONsel; -- or DMAack; -- since DMAack is derived from CONsel this is OK

		-- generate error signal
		err_o <= cyc_i and stb_i and berr;

		-- generate retry signal
		rty_o <= cyc_i and stb_i and brty;

		-- assign interrupt signal
		inta_o <= StatReg(0);
	
		-- generate output multiplexor
		with ATA_ADR select
			Q <= CtrlReg when ATA_CTRL_REG, -- control register
			     StatReg when ATA_STAT_REG, -- status register
			     std_logic_vector(PIO_cmdport_Teoc & PIO_cmdport_T4 & PIO_cmdport_T2 & PIO_cmdport_T1) when ATA_PIO_CMD,  -- PIO compatible / cmd-port timing register
			     std_logic_vector(PIO_dport0_Teoc & PIO_dport0_T4 & PIO_dport0_T2 & PIO_dport0_T1)     when ATA_PIO_DP0,  -- PIO fast timing register device0
			     std_logic_vector(PIO_dport1_Teoc & PIO_dport1_T4 & PIO_dport1_T2 & PIO_dport1_T1)     when ATA_PIO_DP1,  -- PIO fast timing register device1
			     std_logic_vector(DMA_dev0_Teoc & x"00" & DMA_dev0_Td & DMA_dev0_Tm)                   when ATA_DMA_DEV0, -- DMA timing register device0
			     std_logic_vector(DMA_dev1_Teoc & x"00" & DMA_dev1_Td & DMA_dev1_Tm)                   when ATA_DMA_DEV1, -- DMA timing register device1
			     DMAq    when ATA_DMA_PORT, -- DMA port, DMA receive register
		       (others => '0') when others;

		dat_o <= (x"0000" & PIOq) when (ATA_DEV_ADR = '1') else Q;
	end block gen_WB_sigs;

end architecture structural;