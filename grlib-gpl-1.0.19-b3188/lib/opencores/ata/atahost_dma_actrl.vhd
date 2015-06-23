---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  DMA (single- and multiword) mode access controller         ----
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

-- rev.: 1.0 march 9th, 2001. Initial release
--
--  CVS Log
--
--  $Id: atahost_dma_actrl.vhd,v 1.1 2002/02/18 14:32:12 rherveille Exp $
--
--  $Date: 2002/02/18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: atahost_dma_actrl.vhd,v $
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
--


-- Host accesses to DMA ports are 32bit wide. Accesses are made by 2 consecutive 16bit accesses to the ATA
-- device's DataPort. The MSB HostData(31:16) is transfered first, then the LSB HostData(15:0) is transfered.

--
---------------------------
-- DMA Access Controller --
---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
library grlib;
use grlib.stdlib.all;

entity atahost_dma_actrl is
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
                DMActrl_Bytesw, --Jagre 2006-12-04, byte swap ATA data
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
end entity atahost_dma_actrl;
 
architecture structural of atahost_dma_actrl is
	--
	-- component declarations
	--
	component atahost_dma_tctrl is
	generic(
		TWIDTH : natural := 8;            -- counter width

		-- DMA mode 0 settings (@100MHz clock)
		DMA_mode0_Tm : natural := 6;     -- 70ns
		DMA_mode0_Td : natural := 28;    -- 290ns
		DMA_mode0_Teoc : natural := 23   -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		clk : in std_logic;                      -- master clock
		nReset : in std_logic;                   -- asynchronous active low reset
		rst : in std_logic;                      -- synchronous active high reset

		-- timing register settings
		Tm : in std_logic_vector(TWIDTH -1 downto 0);    -- Tm time (in clk-ticks)
		Td : in std_logic_vector(TWIDTH -1 downto 0);    -- Td time (in clk-ticks)
		Teoc : in std_logic_vector(TWIDTH -1 downto 0);  -- end of cycle time

		-- control signals
		go : in std_logic;                       -- DMA controller selected (strobe signal)
		we : in std_logic;                       -- DMA direction '1' = write, '0' = read

		-- return signals
		done : out std_logic;                    -- finished cycle
		dstrb : out std_logic;                   -- data strobe

		-- ATA signals
		DIOR,                                    -- IOread signal, active high
		DIOW : out std_logic                  -- IOwrite signal, active high
	);
	end component atahost_dma_tctrl;

	component atahost_reg_buf is
	generic (
		WIDTH : natural := 8
	);
	port(
		clk : in std_logic;
		nReset : in std_logic;
		rst : in std_logic;

		D : in std_logic_vector(WIDTH -1 downto 0);
		Q : out std_logic_vector(WIDTH -1 downto 0);
		rd : in std_logic;
		wr : in std_logic;
		valid : out std_logic
	);
	end component atahost_reg_buf;

	component atahost_dma_fifo is
        generic(tech  : integer:=0;  
                abits : integer:=3;
                dbits : integer:=32; 
                depth : integer:=8); 

        port( clk          : in std_logic; 
              reset        : in std_logic; 

              write_enable : in std_logic; 
              read_enable  : in std_logic; 

              data_in      : in std_logic_vector(dbits-1 downto 0);
              data_out     : out std_logic_vector(dbits-1 downto 0);

              write_error  : out std_logic:='0'; 
              read_error   : out std_logic:='0'; 

              level        : out natural range 0 to depth; 
              empty        : out std_logic:='1'; 
              full         : out std_logic:='0' 
	);
	end component atahost_dma_fifo;

	signal Tdone, Tfw : std_logic;
	signal RxWr, TxRd : std_logic;
        signal assync_TxRd, s_TxFull : std_logic; -----------------------Erik Jagre 2006-10-27
	signal dstrb, rd_dstrb, wr_dstrb : std_logic;
	signal TxbufQ, RxbufD : std_logic_vector(31 downto 0);
	signal iRxEmpty : std_logic;
        
        constant abits : integer := Log2(fdepth);

begin

	-- note: *fw = *first_word, *lw = *last_word
	

	--
	-- generate DDi/DDo controls
	--
	gen_DMA_sigs: block
		signal writeDfw, writeDlw : std_logic_vector(15 downto 0);
		signal readDfw, readDlw : std_logic_vector(15 downto 0);
		signal BeLeC : std_logic; -- BigEndian <-> LittleEndian conversion
	begin
		-- generate byte_swap signal
		BeLeC <=	(not SelDev and DMActrl_BeLeC0) or (SelDev and DMActrl_BeLeC1);

		-- generate Tfw (Transfering first word)
		gen_Tfw: process(clk, nReset)
		begin
			if (nReset = '0') then
				Tfw <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					Tfw <= '0';
				else
					Tfw <= go or (Tfw and not Tdone);
				end if;
			end if;
		end process gen_Tfw;

		-- transmit data part
		gen_writed_pipe:process(clk)
		begin
			if (clk'event and clk = '1') then
				if (TxRd = '1') then                              -- reload registers
					if (BeLeC = '1') then                           -- Do big<->little endian conversion
						writeDfw(15 downto 8) <= TxbufQ( 7 downto  0); -- TxbufQ = data from transmit buffer
						writeDfw( 7 downto 0) <= TxbufQ(15 downto  8);
						writeDlw(15 downto 8) <= TxbufQ(23 downto 16);
						writeDlw( 7 downto 0) <= TxbufQ(31 downto 24);
					else                                              -- don't do big<->little endian conversion
						writeDfw <= TxbufQ(31 downto 16);
						writeDlw <= TxbufQ(15 downto 0);
					end if;
				elsif (wr_dstrb = '1') then                          -- next word to transfer
					writeDfw <= writeDlw;
				end if;
			end if;
		end process gen_writed_pipe;

                --Jagre 2006-12-04
                --swap byte orderD when MActrl_Bytesw is set to '1'
                DDo(15 downto 8) <= writeDfw(15 downto 8) when DMActrl_Bytesw='0' else
                                    writeDfw(7 downto 0);
                                    
                DDo(7 downto 0)  <= writeDfw(7 downto 0) when DMActrl_Bytesw='0' else
                                    writeDfw(15 downto 8);

		--DDo <= writeDfw;                                       -- assign DMA data out

		-- generate transmit register read request
		gen_Tx_rreq: process(clk, nReset)
		begin
			if (nReset = '0') then
				TxRd <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					TxRd <= '0';
				else
					TxRd <= go and DMActrl_dir;
				end if;
			end if;
		end process gen_Tx_rreq;
                assync_TxRd <= go and DMActrl_dir; --Jagre 2006-12-14
		
		-- receive
		gen_readd_pipe:process(clk)
		begin
			if (clk'event and clk = '1') then
				if (rd_dstrb = '1') then

					readDfw <= readDlw;                   -- shift previous read word to msb
					if (BeLeC = '1' xor DMActrl_Bytesw = '1') then -- swap bytes, DMActrl_Bytesw added 2006-12-04, Jagre
						readDlw(15 downto 8) <= DDi( 7 downto 0);
						readDlw( 7 downto 0) <= DDi(15 downto 8);
					else                                  -- don't swap bytes
						readDlw <= DDi;
					end if;
				end if;
			end if;
		end process gen_readd_pipe;
		-- RxD = data to receive buffer
		RxbufD <= (readDfw & readDlw) when (BeLeC = '0') else (readDlw & readDfw);

		-- generate receive register write request
		gen_Rx_wreq: process(clk, nReset)
		begin
			if (nReset = '0') then
				RxWr <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					RxWr <= '0';
				else
					RxWr <= not Tfw and rd_dstrb;
				end if;
			end if;
		end process gen_Rx_wreq;
	end block gen_DMA_sigs;


	--
	-- Hookup DMA read / write buffers
	--
	gen_DMAbuf: block
		signal DMArst : std_logic;
		signal RxRd, TxWr : std_logic;
	begin
		-- generate DMA reset signal
		DMArst <= rst or IDEctrl_rst;

		Txfifo: atahost_dma_fifo
                generic map(dbits=>32,depth=>fdepth,tech=>tech,abits=>abits)
                port map( clk          => clk,
                      reset        => DMArst,
                      write_enable => TxWr,
                      read_enable  => assync_TxRd,
                      data_in      => TxD,
                      data_out     => TxbufQ, 
                      write_error  => open, 
                      read_error   => open,
                      level        => open,
                      empty        => TxEmpty, 
                      full         => s_TxFull
		);

		Rxfifo: atahost_dma_fifo
                generic map(dbits=>32,depth=>fdepth,tech=>tech,abits=>abits)
                port map( clk          => clk,
                      reset        => DMArst,
                      write_enable => RxWr,
                      read_enable  => RxRd,
                      data_in      => RxbufD,
                      data_out     => RxQ, 
                      write_error  => open, 
                      read_error   => open,
                      level        => open,
                      empty        => iRxEmpty,
                      full         => RxFull
		);

		RxEmpty <= iRxEmpty; -- avoid 'cannot associate OUT port with BUFFER port' error

		--
		-- generate DMA buffer access signals
		--
		RxRd <= sel and not we and not iRxEmpty;
		TxWr <= sel and     we and not s_TxFull;

		ack  <= RxRd or TxWr; -- DMA buffer access acknowledge
	end block gen_DMAbuf;

	--
	-- generate request signal for external DMA engine
	--
	gen_DMA_req: block
		signal hgo : std_logic;
		signal iDMA_req : std_logic;
		signal request : std_logic;
	begin
		-- generate hold-go
		gen_hgo : process(clk, nReset)
		begin
			if (nReset = '0') then
				hgo <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					hgo <= '0';
				else
					hgo <= go or (hgo and not (wr_dstrb and not Tfw) and DMActrl_dir);
				end if;
			end if;
		end process gen_hgo;

		request <= (DMActrl_dir and DMARQ and not s_TxFull and not hgo) or not iRxEmpty;
		process(clk, nReset)
		begin
			if (nReset = '0') then
				iDMA_req <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					iDMA_req <= '0';
				else
					iDMA_req <= DMActrl_DMAen and not DMA_ack and (request or iDMA_req);
--				DMA_req <= (DMActrl_DMAen and DMActrl_dir and DMARQ and not TxFull and not hgo) or not iRxEmpty;
				end if;
			end if;
		end process;
		DMA_req <= iDMA_req;
	end block gen_DMA_req;


	--
	-- DMA timing controller
	--
	DMA_timing_ctrl: block
		signal Tm, Td, Teoc, Tdmack_ext : std_logic_vector(TWIDTH -1 downto 0);
		signal dTfw, igo : std_logic;
	begin
		--
		-- generate internal GO signal
		--
		gen_igo : process(clk, nReset)
		begin
			if (nReset = '0') then
				igo  <= '0';
				dTfw <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					igo  <= '0';
					dTfw <= '0';
				else
					igo  <= go or (not Tfw and dTfw);
					dTfw <= Tfw;
				end if;
			end if;
		end process gen_igo;

		--
		-- select timing settings for the addressed device
		--
		sel_dev_t: process(clk)
		begin
			if (clk'event and clk = '1') then
				if (SelDev = '1') then                      -- device1 selected
					Tm   <= dev1_Tm;
					Td   <= dev1_Td;
					Teoc <= dev1_Teoc;
				else                                        -- device0 selected
					Tm   <= dev0_Tm;
					Td   <= dev0_Td;
					Teoc <= dev0_Teoc;
				end if;
			end if;
		end process sel_dev_t;

		--
		-- hookup timing controller
		--
		DMA_timing_ctrl: atahost_dma_tctrl 
			generic map (
				TWIDTH => TWIDTH, 
				DMA_mode0_Tm   => DMA_mode0_Tm,
				DMA_mode0_Td   => DMA_mode0_Td,
				DMA_mode0_Teoc => DMA_mode0_Teoc
			)
			port map (
				clk    => clk,
				nReset => nReset,
				rst    => rst,
				Tm     => Tm,
				Td     => Td,
				Teoc   => Teoc, 
				go     => igo,
				we     => DMActrl_dir,
				done   => Tdone,
				dstrb  => dstrb,
				DIOR   => dior,
				DIOW   => diow
			);

		done <= Tdone and not Tfw;             -- done transfering last word
		rd_dstrb <= dstrb and not DMActrl_dir; -- read data strobe
		wr_dstrb <= dstrb and     DMActrl_dir; -- write data strobe
                TxFull <= s_TxFull;
	end block DMA_timing_ctrl;
		
end architecture structural;

