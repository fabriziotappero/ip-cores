---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  ATA/ATAPI-5 Host controller (OCIDEC-3)                     ----
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

-- rev.: 1.0 march 8th, 2001. Initial release
--
--  CVS Log
--
--  $Id: atahost_controller.vhd,v 1.1 2002/02/18 14:32:12 rherveille Exp $
--
--  $Date: 2002/02/18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: atahost_controller.vhd,v $
--               Revision 1.1  2002/02/18 14:32:12  rherveille
--               renamed all files to 'atahost_***.vhd'
--               broke-up 'counter.vhd' into 'ud_cnt.vhd' and 'ro_cnt.vhd'
--               changed resD input to generic RESD in ud_cnt.vhd
--               changed ID input to generic ID in ro_cnt.vhd
--               changed core to reflect changes in ro_cnt.vhd
--               removed references to 'count' library
--               changed IO names
--               added disclaimer
--               added CVS log
--               moved registers and wishbone signals into 'atahost_wb_slave.vhd'
--
--

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;

entity atahost_controller is
	generic(
                tech   : integer := 0;                   -- fifo mem technology
                fdepth : integer := 8;                   -- DMA fifo depth
		TWIDTH : natural := 8;                   -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;             -- 70ns
		PIO_mode0_T2 : natural := 28;            -- 290ns
		PIO_mode0_T4 : natural := 2;             -- 30ns
		PIO_mode0_Teoc : natural := 23;          -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240

		-- Multiword DMA mode 0 settings (@100MHz clock)
		DMA_mode0_Tm : natural := 4;             -- 50ns
		DMA_mode0_Td : natural := 21;            -- 215ns
		DMA_mode0_Teoc : natural := 21           -- 215ns ==> T0 - Td - Tm = 480 - 50 - 215 = 215
	);
	port(
		clk : in std_logic;  		                    	  -- master clock in
		nReset	: in std_logic := '1';                 -- asynchronous active low reset
		rst : in std_logic := '0';                    -- synchronous active high reset
		
		irq : out std_logic;                          -- interrupt request signal

		-- control / registers
		IDEctrl_IDEen,
		IDEctrl_rst,
		IDEctrl_ppen,
		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;                 -- control register settings

		a : in std_logic_vector(3 downto 0);                  -- address input
		d : in std_logic_vector(31 downto 0);         -- data input
		we : in std_logic;                            -- write enable input '1'=write, '0'=read

		-- PIO registers
		PIO_cmdport_T1,
		PIO_cmdport_T2,
		PIO_cmdport_T4,
		PIO_cmdport_Teoc : in std_logic_vector(7 downto 0);
		PIO_cmdport_IORDYen : in std_logic;           -- PIO compatible timing settings
	
		PIO_dport0_T1,
		PIO_dport0_T2,
		PIO_dport0_T4,
		PIO_dport0_Teoc : in std_logic_vector(7 downto 0);
		PIO_dport0_IORDYen : in std_logic;            -- PIO data-port device0 timing settings

		PIO_dport1_T1,
		PIO_dport1_T2,
		PIO_dport1_T4,
		PIO_dport1_Teoc : in std_logic_vector(7 downto 0);
		PIO_dport1_IORDYen : in std_logic;            -- PIO data-port device1 timing settings

		PIOsel : in std_logic;                        -- PIO controller select
		PIOack : out std_logic;                       -- PIO controller acknowledge
		PIOq : out std_logic_vector(15 downto 0);     -- PIO data out
		PIOtip : out std_logic;              -- PIO transfer in progress
		PIOpp_full : out std_logic;                   -- PIO Write PingPong full

		-- DMA registers
		DMA_dev0_Td,
		DMA_dev0_Tm,
		DMA_dev0_Teoc : in std_logic_vector(7 downto 0);      -- DMA timing settings for device0

		DMA_dev1_Td,
		DMA_dev1_Tm,
		DMA_dev1_Teoc : in std_logic_vector(7 downto 0);      -- DMA timing settings for device1

		DMActrl_DMAen,
		DMActrl_dir,
                DMActrl_Bytesw,     --Jagre 2006-12-04 byte swap ATA data
		DMActrl_BeLeC0,
		DMActrl_BeLeC1 : in std_logic;                -- DMA settings

		DMAsel : in std_logic;                        -- DMA controller select
		DMAack : out std_logic;                       -- DMA controller acknowledge
		DMAq : out std_logic_vector(31 downto 0);     -- DMA data out
		DMAtip_out : out std_logic;                    -- DMA transfer in progress --Erik Jagre 2006-11-15
		DMA_dmarq : out std_logic;                    -- Synchronized ATA DMARQ line

                force_rdy : in std_logic;                     -- DMA transmit fifo filled up partly --Erik Jagre 2006-10-31
		fifo_rdy : out std_logic;                     -- DMA transmit fifo filled up --Erik Jagre 2006-10-30
		DMARxEmpty : out std_logic;                   -- DMA receive buffer empty
		DMARxFull : out std_logic;                    -- DMA receive fifo full Erik Jagre 2006-10-31

		DMA_req : out std_logic;                      -- DMA request to external DMA engine
		DMA_ack : in std_logic;                       -- DMA acknowledge from external DMA engine
                BM_en   : in std_logic;                       -- Bus mater enabled, for DMA reset Erik Jagre 2006-10-24

		-- ATA signals
		RESETn	: out std_logic;
		DDi	: in std_logic_vector(15 downto 0);
		DDo : out std_logic_vector(15 downto 0);
		DDoe : out std_logic;
		DA	: out std_logic_vector(2 downto 0) := "000";
		CS0n	: out std_logic;
		CS1n	: out std_logic;

		DMARQ	: in std_logic;
		DMACKn	: out std_logic;
		DIORn	: out std_logic;
		DIOWn	: out std_logic;
		IORDY	: in std_logic;
		INTRQ	: in std_logic
	);
end entity atahost_controller;

architecture structural of atahost_controller is
	--
	-- component declarations
	--
	component atahost_pio_controller is
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
		nReset	: in std_logic := '1';                 -- asynchronous active low reset
		rst : in std_logic := '0';                    -- synchronous active high reset
		
		-- control / registers
		IDEctrl_IDEen,
		IDEctrl_ppen,
		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;

		-- PIO registers
		cmdport_T1,
		cmdport_T2,
		cmdport_T4,
		cmdport_Teoc : in std_logic_vector(7 downto 0);
		cmdport_IORDYen : in std_logic;            -- PIO command port / non-fast timing

		dport0_T1,
		dport0_T2,
		dport0_T4,
		dport0_Teoc : in std_logic_vector(7 downto 0);
		dport0_IORDYen : in std_logic;             -- PIO mode data-port / fast timing device 0

		dport1_T1,
		dport1_T2,
		dport1_T4,
		dport1_Teoc : in std_logic_vector(7 downto 0);
		dport1_IORDYen : in std_logic;             -- PIO mode data-port / fast timing device 1

		sel : in std_logic;                           -- PIO controller selected
		ack : out std_logic;                          -- PIO controller acknowledge
		a : in std_logic_vector(3 downto 0);                  -- lower address bits
		we : in std_logic;                            -- write enable input
		d : in std_logic_vector(15 downto 0);
		q : out std_logic_vector(15 downto 0);

		PIOreq : out std_logic;                       -- PIO transfer request
		PPFull : out std_logic;                       -- PIO Write PingPong Full
		go : in std_logic;                            -- start PIO transfer
		done : out std_logic;                      -- done with PIO transfer

		PIOa : out std_logic_vector(3 downto 0);              -- PIO address, address lines towards ATA devices
		PIOd : out std_logic_vector(15 downto 0);     -- PIO data, data towards ATA devices

		SelDev : out std_logic;                    -- Selected Device, Dev-bit in ATA Device/Head register

		DDi	: in std_logic_vector(15 downto 0);
		DDoe : out std_logic;

		DIOR	: out std_logic;
		DIOW	: out std_logic;
		IORDY	: in std_logic
	);
	end component atahost_pio_controller;

	component atahost_dma_actrl is
	generic(
                tech   : integer := 0;                     -- fifo mem technology
                fdepth : integer := 8;                     -- DMA fifo depth
		TWIDTH : natural := 8;                     -- counter width

		-- DMA mode 0 settings (@100MHz clock)
		DMA_mode0_Tm : natural := 4;               -- 50ns
		DMA_mode0_Td : natural := 21;              -- 215ns
		DMA_mode0_Teoc : natural := 21             -- 215ns ==> T0 - Td - Tm = 480 - 50 - 215 = 215
	);
	port(
		clk : in std_logic;                           -- master clock
		nReset : in std_logic;                        -- asynchronous active low reset
		rst : in std_logic;                           -- synchronous active high reset

		IDEctrl_rst : in std_logic;                   -- IDE control register bit0, 'rst'

		sel : in std_logic;                           -- DMA buffers selected
		we : in std_logic;                            -- write enable input
		ack : out std_logic;		                        -- acknowledge output

		dev0_Tm,
		dev0_Td,
		dev0_Teoc : in std_logic_vector(7 downto 0);          -- DMA mode timing device 0
		dev1_Tm,
		dev1_Td,
		dev1_Teoc : in std_logic_vector(7 downto 0);          -- DMA mode timing device 1

		DMActrl_DMAen,
		DMActrl_dir,
                DMActrl_Bytesw,
		DMActrl_BeLeC0,
		DMActrl_BeLeC1 : in std_logic;                -- control register settings

		TxD : in std_logic_vector(31 downto 0);       -- DMA transmit data
		TxFull : out std_logic;                    -- DMA transmit buffer full
                TxEmpty : out std_logic;
		RxQ : out std_logic_vector(31 downto 0);      -- DMA receive data
		RxEmpty : out std_logic;                   -- DMA receive buffer empty
		RxFull : out std_logic;                       -- DMA receive buffer full
		DMA_req : out std_logic;                      -- DMA request to external DMA engine
		DMA_ack : in std_logic;                       -- DMA acknowledge from external DMA engine

		DMARQ : in std_logic;                         -- ATA devices request DMA transfer

		SelDev : in std_logic;                        -- Selected device	

		Go : in std_logic;                            -- Start transfer sequence
		Done : out std_logic;                         -- Transfer sequence done

		DDi : in std_logic_vector(15 downto 0);       -- Data from ATA DD bus
		DDo : out std_logic_vector(15 downto 0);      -- Data towards ATA DD bus

		DIOR,
		DIOW : out std_logic 
	);
	end component atahost_dma_actrl;

        type reg_type is record
          force_rdy : std_logic;
          fifo_rdy : std_logic;
          s_DMATxEmpty : std_logic;
          s_DMATxFull : std_logic;
          s_DMARxEmpty : std_logic;
          s_DMARxFull : std_logic;
        end record;

        constant RESET_VECTOR : reg_type := ('0','0','0','0','0','0');
        
        signal r,ri : reg_type;

	--
	-- signals
	--
	signal SelDev : std_logic;                       -- selected device
	signal s_DMARxFull : std_logic;                    -- DMA receive buffer full

	-- PIO / DMA signals
	signal PIOgo, DMAgo : std_logic :='0';                 -- start PIO / DMA timing controller
	signal PIOdone, DMAdone : std_logic :='0';             -- PIO / DMA timing controller done

	-- PIO signals
	signal PIOdior, PIOdiow : std_logic;
	signal PIOoe : std_logic;

	-- PIO pingpong signals
	signal PIOd : std_logic_vector(15 downto 0);
	signal PIOa : std_logic_vector(3 downto 0):="0000";
	signal PIOreq : std_logic;

	-- DMA signals
	signal DMAd : std_logic_vector(15 downto 0);
	signal DMAtip, s_fifo_rdy, s_DMARxEmpty, s_DMATxFull,s_DMATxEmpty, DMAdior, DMAdiow, s_DMArst: std_logic; --Erik Jagre 2006-10-24 new s_DMArst signal
	-- synchronized ATA inputs
	signal sDMARQ, sIORDY, iPIOtip, iDMAtip_out : std_logic;

begin

	--
	-- synchronize incoming signals
	--
	synch_incoming: block
		signal cDMARQ : std_logic;                   -- capture DMARQ
		signal cIORDY : std_logic;                   -- capture IORDY
		signal cINTRQ : std_logic;                   -- capture INTRQ
	begin
		process(clk)
		begin
			if (clk'event and clk = '1') then
				cDMARQ <= DMARQ;
				cIORDY <= IORDY;
				cINTRQ <= INTRQ;

				sDMARQ <= cDMARQ;
				sIORDY <= cIORDY;
				irq    <= cINTRQ;
			end if;
		end process;

		DMA_dmarq <= sDMARQ;
	end block synch_incoming;

	--
	-- generate ATA signals
	--
	gen_ata_sigs: block
		signal iDDo : std_logic_vector(15 downto 0);
	begin
		-- generate registers for ATA signals
		gen_regs: process(clk, nReset)
		begin
			if (nReset = '0') then
				RESETn <= '0';
				DIORn  <= '1';
				DIOWn  <= '1';
				DA     <= (others => '0');
				CS0n	  <= '1';
				CS1n	  <= '1';
				DDo    <= (others => '0');
				DDoe   <= '0';
				DMACKn <= '1';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					RESETn <= '0';
					DIORn  <= '1';
					DIOWn  <= '1';
					DA     <= (others => '0');
					CS0n   <= '1';
					CS1n  	<= '1';
					DDo    <= (others => '0');
					DDoe   <= '0';
					DMACKn <= '1';
				else
					RESETn <= not IDEctrl_rst;
					DA     <= PIOa(2 downto 0);
					CS0n	  <= not (not PIOa(3) and iPIOtip); -- CS0 asserted when A(3) = '0', negate during DMA transfers
					CS1n	  <= not (    PIOa(3) and iPIOtip); -- CS1 asserted when A(3) = '1', negate during DMA transfers

					if (iPIOtip = '1') then
						DDo   <= PIOd;
						DDoe  <= PIOoe;
						DIORn <= not PIOdior;
						DIOWn <= not PIOdiow;
					else
						DDo   <= DMAd;
						DDoe  <= DMActrl_dir and DMAtip;
						DIORn <= not DMAdior;
						DIOWn <= not DMAdiow;
					end if;

					DMACKn <= not DMAtip;
				end if;
			end if;
		end process gen_regs;
	end block gen_ata_sigs;
	
	--
	-- generate bus controller statemachine
	--
	statemachine: block
		type states is (idle, PIO_state, DMA_state);
		signal nxt_state, c_state : states; -- next_state, current_state

		signal iPIOgo, iDMAgo : std_logic :='0';
	begin
                gen_fifo_rdy : process(r,s_DMATxEmpty,s_DMATxFull,s_DMARxFull,s_DMARxEmpty,force_rdy,s_DMArst,DMActrl_dir) --Erik Jagre 2006-10-30
                variable v : reg_type;
                begin
                  v:=r;
                  v.s_DMATxFull:=s_DMATxFull;
                  v.s_DMATxEmpty:=s_DMATxEmpty;
                  v.s_DMARxFull:=s_DMARxFull;
                  v.s_DMARxEmpty:=s_DMARxEmpty;
                  v.force_rdy:=force_rdy;
                  case DMActrl_dir is
                    when '1' => --Tx action mem_to_ata
                      if (r.s_DMATxFull='0' and s_DMATxFull='1') or 
                        (r.force_rdy='0' and force_rdy='1') then
                        v.fifo_rdy:='1';
                      elsif (r.s_DMATxEmpty='0' and s_DMATxEmpty='1') then
                        v.fifo_rdy:='0';
                      else
                        v.fifo_rdy:=r.fifo_rdy;
                      end if;
                      if s_DMArst='1' then
                        v.fifo_rdy:='0';
                      end if;
                    when '0' => --Rx action ata_to_mem
                      if (s_DMARxEmpty='1') or  --r.s_DMARxEmpty='0' and Jagre 2006-12-04
                        (r.force_rdy='0' and force_rdy='1') then --Erik Jagre 2006-11-07
                        v.fifo_rdy:='1';
                      elsif (r.s_DMARxFull='0' and s_DMARxFull='1') then
                        v.fifo_rdy:='0';
                      else
                        v.fifo_rdy:=r.fifo_rdy;
                      end if;
                      if s_DMArst='1' then
                        v.fifo_rdy:='1';
                      end if;
                    when others =>
                      v.fifo_rdy:=r.fifo_rdy;
                  end case;
                  
                  ri<=v;
                  s_fifo_rdy<=v.fifo_rdy; --Jagre 2006-12-04
                  fifo_rdy<=r.fifo_rdy;
                end process gen_fifo_rdy;
        
		-- generate next state decoder + output decoder
--		gen_nxt_state: process(c_state, DMActrl_DMAen, DMActrl_dir, PIOreq, sDMARQ, s_fifo_rdy, s_DMARxFull, PIOdone, DMAdone) --Erik Jagre 2006-10-30
		gen_nxt_state: process(c_state, DMActrl_DMAen, PIOreq, sDMARQ, s_fifo_rdy, PIOdone, DMAdone) --Erik Jagre 2007-02-08
		begin
			nxt_state <= c_state; -- initialy stay in current state

			iPIOgo <= '0';
			iDMAgo <= '0';

			case c_state is
				-- idle
				when idle =>
					-- DMA transfer pending ?
					if ( (sDMARQ = '1') and (DMActrl_DMAen = '1') ) then
						if (s_fifo_rdy='1') then --Erik Jagre 2006-10-30
							nxt_state <= DMA_state;                        -- DMA transfer
                					iDMAgo    <= '1'; -- start DMA timing controller
						end if;
					-- PIO transfer pending ?
					elsif (PIOreq = '1') then
						nxt_state <= PIO_state;                            -- PIO transfer
						iPIOgo    <= '1';
					end if;
				
				-- PIO transfer
				when PIO_state =>
					if (PIOdone = '1') then
							nxt_state <= idle;
					end if;

				-- DMA transfer
				when DMA_state =>
					if (DMAdone = '1') then
	 					nxt_state <= idle;
					end if;

				when others =>
					nxt_state <= idle;                                   -- go to idle state

			end case;
		end process gen_nxt_state;

		-- generate registers
		gen_regs: process(clk, nReset)
		begin
			if (nReset = '0') then
				c_state <= idle;
				PIOgo <= '0';
				DMAgo <= '0';
                                r<=RESET_VECTOR;
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					c_state <= idle;
					PIOgo <= '0';
					DMAgo <= '0';
                                        r<=RESET_VECTOR;
				else
					c_state <= nxt_state;
					PIOgo <= iPIOgo;
					DMAgo <= iDMAgo;
                                        r<=ri;
				end if;
			end if;
		end process gen_regs;

		-- generate PIOtip / DMAtip
		gen_tip: process(clk, nReset)
		begin
			if (nReset = '0') then
				iPIOtip <= '0';
				DMAtip <= '0';
                                iDMAtip_out <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					iPIOtip <= '0';
					DMAtip <= '0';
                                        iDMAtip_out <= '0';
				else
					iPIOtip     <= iPIOgo or (iPIOtip and not PIOdone);
					DMAtip     <= iDMAgo                       or (DMAtip     and not ((DMAdone and DMActrl_dir) or (DMAdone and not sDMARQ and not DMActrl_dir)) );
					iDMAtip_out <= iDMAgo or (not s_DMATxEmpty) or (iDMAtip_out and not ((DMAdone and DMActrl_dir) or (DMAdone and not sDMARQ and not DMActrl_dir)) );
				end if;
			end if;
		end process gen_tip;
	end block statemachine;

        PIOtip <= iPIOtip; DMAtip_out <= iDMAtip_out;
        DMARxEmpty <= s_DMARxEmpty; --Erik Jagre 2006-11-01
        DMARxFull <= s_DMARxFull; --Erik Jagre 2006-10-31
        s_DMArst <=IDEctrl_rst or (not BM_en); --reset DMA controller when BM not active

	--
	-- Hookup PIO controller
	--
	PIO_control: atahost_pio_controller
		generic map(
			TWIDTH => TWIDTH,
			PIO_mode0_T1 => PIO_mode0_T1,
			PIO_mode0_T2 => PIO_mode0_T2,
			PIO_mode0_T4 => PIO_mode0_T4,
			PIO_mode0_Teoc => PIO_mode0_Teoc
		)
		port map(
			clk    => clk,
			nReset => nReset,
			rst    => rst,
			IDEctrl_IDEen => IDEctrl_IDEen,
			IDEctrl_ppen  => IDEctrl_ppen,
			IDEctrl_FATR0 => IDEctrl_FATR0,
			IDEctrl_FATR1 => IDEctrl_FATR1,
			cmdport_T1    => PIO_cmdport_T1,
			cmdport_T2    => PIO_cmdport_T2,
			cmdport_T4    => PIO_cmdport_T4,
			cmdport_Teoc  => PIO_cmdport_Teoc,
			cmdport_IORDYen => PIO_cmdport_IORDYen,
			dport0_T1     => PIO_dport0_T1,
			dport0_T2     => PIO_dport0_T2,
			dport0_T4     => PIO_dport0_T4,
			dport0_Teoc   => PIO_dport0_Teoc,
			dport0_IORDYen => PIO_dport0_IORDYen,
			dport1_T1     => PIO_dport1_T1,
			dport1_T2     => PIO_dport1_T2,
			dport1_T4     => PIO_dport1_T4,
			dport1_Teoc   => PIO_dport1_Teoc,
			dport1_IORDYen => PIO_dport1_IORDYen,
			sel    => PIOsel,
			ack    => PIOack,
			a      => a,
			we     => we,
			d      => d(15 downto 0),
			q      => PIOq, 
			PIOreq => PIOreq,
			PPFull => PIOpp_full,
			go     => PIOgo,
			done   => PIOdone,
			PIOa   => PIOa,
			PIOd   => PIOd,
			SelDev => SelDev,
			DDi    => DDi,
			DDoe   => PIOoe,
			DIOR   => PIOdior,
			DIOW   => PIOdiow,
			IORDY  => sIORDY
		);

	--
	-- Hookup DMA access controller
	--
	DMA_control: atahost_dma_actrl
		generic map(
                        tech => tech,
                        fdepth => fdepth,
			TWIDTH => TWIDTH,
			DMA_mode0_Tm => DMA_mode0_Tm,
			DMA_mode0_Td => DMA_mode0_Td,
			DMA_mode0_Teoc => DMA_mode0_Teoc
		)
		port map(
			clk    => clk,
			nReset => nReset,
			rst    => rst,
			IDEctrl_rst => s_DMArst,--IDEctrl_rst,
			DMActrl_DMAen  => DMActrl_DMAen, 
			DMActrl_dir    => DMActrl_dir,
                        DMActrl_Bytesw => DMActrl_Bytesw,
			DMActrl_BeLeC0 => DMActrl_BeLeC0,
			DMActrl_BeLeC1 => DMActrl_BeLeC1, 
			dev0_Td   => DMA_dev0_Td,
			dev0_Tm   => DMA_dev0_Tm,
			dev0_Teoc => DMA_dev0_Teoc, 
			dev1_Td   => DMA_dev1_Td,
			dev1_Tm   => DMA_dev1_Tm,
			dev1_Teoc => DMA_dev1_Teoc,
			sel     => DMAsel,
			ack     => DMAack,
			we      => we,
			TxD     => d,
			TxFull  => s_DMATxFull,
                        TxEmpty => s_DMATxEmpty,
			RxQ     => DMAq,
			RxFull  => s_DMARxFull,
			RxEmpty => s_DMARxEmpty,
			DMA_req => DMA_req,
			DMA_ack => DMA_ack,
			SelDev  => SelDev,
			Go      => DMAgo,
			Done    => DMAdone,
			DDi     => DDi,
			DDo     => DMAd,
			DIOR    => DMAdior,
			DIOW    => DMAdiow,
			DMARQ   => sDMARQ
		);
end architecture structural;
