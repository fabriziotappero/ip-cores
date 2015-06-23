-----------------------------------------------------------------------------
-- On-chip logic analyzer with wishbone bus for control and data export.
-- Waveforms are stored in local BlockRAM which size (depth) can be
-- configured via a generic.
--
-- (c) 2006 by Joerg Bornschein  (jb@capsec.org)
-- All files under GPLv2   
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

-----------------------------------------------------------------------------
-- Wishbone LogicAnalyzer ---------------------------------------------------
entity wb_scope is
	generic (
		depth      : natural := 4096 );
	port (
		clk        : in  std_logic;
		reset      : in  std_logic;
		-- 32 Bit Wishbone Slave
		wb_adr_i   : in  std_logic_vector(31 downto 0);
		wb_dat_i   : in  std_logic_vector(31 downto 0);
		wb_dat_o   : out std_logic_vector(31 downto 0);
		wb_sel_i   : in  std_logic_vector( 3 downto 0);
		wb_cyc_i   : in  std_logic;
		wb_stb_i   : in  std_logic;
		wb_ack_o   : out std_logic;
		wb_we_i    : in  std_logic;
		wb_irq_o   : out std_logic;
		-- I/O ports
		probe      : in  std_logic_vector(31 downto 0) );
end wb_scope;

-----------------------------------------------------------------------------
-- 0x00000 Status Register:
--      +-----------------+-------+-------+-------+
--      |    ... 0 ...    | SDONE | IRQEN | SPLEN |
--      +-----------------+-------+-------+-------+
--
-- 0x00004 Sample Pointer -- (0x0000 : 0xFFFF)
-- 0x00008 Sample Counter -- (Stop when 0)
-- 0x00010 Channel 0
-- 0x00011 Channel 1
-- 0x00012 Channel 2
-- 0x00013 Channel 3
-- 0x1???? Data 
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Implementation -----------------------------------------------------------
architecture rtl of wb_scope is

-----------------------------------------------------------------------------
-- Components ---------------------------------------------------------------
component bram_dp is
	generic (
		depth     : natural );
	port (
		clk       : in  std_logic;
		reset     : in  std_logic;
		-- Port 1
		we1       : in  std_logic;
		addr1     : in  std_logic_vector(11 downto 0);
		wdata1    : in  std_logic_vector(31 downto 0);
		-- Port 2
		oe2       : in  std_logic;
		addr2     : in  std_logic_vector(11 downto 0);
		rdata2    : out std_logic_vector(31 downto 0) );
end component;

component mux32 is
	port (
		input     : in  std_logic_vector(31 downto 0);
		output    : out std_logic;
		sel       : in  std_logic_vector(4 downto 0) );
end component;

-----------------------------------------------------------------------------
-- Local Signals ------------------------------------------------------------
constant ZEROS  : std_logic_vector(31 downto 0) := (others => '0');

signal wbactive : std_logic;

signal status_reg : std_logic_vector(31 downto 0);

signal sp      : std_logic_vector(15 downto 0); -- SamplePointer
signal sc      : std_logic_vector(15 downto 0); -- SampleCounter
signal spen    : std_logic;                     -- Sample Enable
signal irqen   : std_logic;                     -- IRQ Enable
signal sdone   : std_logic;                     -- Sampling Done

signal sreg    : std_logic_vector(27 downto 0); -- sample register
signal chan    : std_logic_vector( 3 downto 0); -- actual data to be sampled
signal probe_b : std_logic_vector(31 downto 0); -- buffered probes

signal csel0 : std_logic_vector(4 downto 0);
signal csel1 : std_logic_vector(4 downto 0);
signal csel2 : std_logic_vector(4 downto 0);
signal csel3 : std_logic_vector(4 downto 0);

signal we1   : std_logic;
signal addr1 : std_logic_vector(11 downto 0);
signal wdata1: std_logic_vector(31 downto 0);

signal oe2   : std_logic;
signal addr2 : std_logic_vector(11 downto 0);
signal rdata2: std_logic_vector(31 downto 0);

signal ram_ack : std_logic; 


begin

-- Sample RAM ---------------------------------------------------------------
ram0: bram_dp 
	generic map (
		depth  => depth )
	port map (
		clk    => clk,
		reset  => reset,
		-- Port 1  (probe & sample engine (write only))
		we1    => we1,
		addr1  => addr1,
		wdata1 => wdata1,
		-- Port 2  (Wishbone Access (read only))
		oe2    => oe2,
		addr2  => addr2,
		rdata2 => rdata2 );

wbactive <= wb_stb_i and wb_cyc_i;

addr2 <= wb_adr_i(13 downto 2);
oe2   <= '1' when wbactive='1' and wb_adr_i(19 downto 16)=x"1" else
         '0';

wb_dat_o <= status_reg               when wbactive='1' and wb_adr_i(19 downto 16)=x"0" and wb_adr_i( 7 downto 0)=x"00" else
            ZEROS(31 downto 16) & sp when wbactive='1' and wb_adr_i(19 downto 16)=x"0" and wb_adr_i( 7 downto 0)=x"04" else
            ZEROS(31 downto 16) & sc when wbactive='1' and wb_adr_i(19 downto 16)=x"0" and wb_adr_i( 7 downto 0)=x"08" else
            ZEROS(2 downto 0)&csel3 & 
            ZEROS(2 downto 0)&csel2 & 
            ZEROS(2 downto 0)&csel1 & 
            ZEROS(2 downto 0)&csel0  when wbactive='1' and wb_adr_i(19 downto 16)=x"0" and wb_adr_i( 7 downto 0)=x"10" else
            rdata2                   when wbactive='1' and wb_adr_i(19 downto 16)=x"1" else 
            (others => '-');

wb_ack_o <= wbactive and ram_ack when wb_adr_i(19 downto 16)=x"1" else
			wbactive;
			
wb_irq_o <= sdone and irqen;

status_reg <= ZEROS(31 downto 3) & sdone & irqen & spen;

wbproc: process(reset, clk) is
variable scv : unsigned(15 downto 0);
variable spv : unsigned(15 downto 0);
begin
	if reset='1' then
		spen  <= '0';
		irqen <= '0';
		sdone <= '0';
		sp    <= (others => '0');
		sc    <= (others => '0');

		csel0 <= (others => '0');
		csel1 <= (others => '0');
		csel2 <= (others => '0');
		csel3 <= (others => '0');

		sreg  <= (others => '0');
		we1   <= '0';
		ram_ack <= '0';
	elsif clk'event and clk='1' then
		-- Sample Data
		if spen='1' then
			-- sampling done?
			if sc=ZEROS(15 downto 0) then 
				spen  <= '0';
				sdone <= '1';
			end if;

			-- sample into sreg 
			if sp(2 downto 0)="111" then
				addr1  <= sp(14 downto 3);
				wdata1 <= sreg & chan;
				we1    <= '1';
			else
				sreg   <= sreg(23 downto 0) & chan;
				we1    <= '0';
			end if;

			-- increase pointer; decrease counter
			scv := unsigned(sc);
			scv := scv - 1;
			sc <= std_logic_vector(scv);

			spv := unsigned(sp);
			spv := spv + 1;
			sp <= std_logic_vector(spv);
		end if;

		-- WB register write request
		if wbactive='1' and wb_we_i='1' and wb_adr_i(19 downto 16)=x"0" then
			if wb_adr_i(7 downto 0)=x"00" then -- StatusRegister
				spen  <= wb_dat_i(0);
				irqen <= wb_dat_i(1);
				sdone <= '0';
			end if;

			if wb_adr_i(7 downto 0)=x"04" then -- SamplePointer
				sp <= wb_dat_i(15 downto 0);
			end if;

			if wb_adr_i(7 downto 0)=x"08" then -- SampleCounter
				sc <= wb_dat_i(15 downto 0);
			end if;

			if wb_adr_i(7 downto 0)=x"10" then -- Channel Sel
				if wb_sel_i(0)='1' then 
					csel3 <= wb_dat_i( 4 downto  0);
				end if;

				if wb_sel_i(1)='1' then 
					csel2 <= wb_dat_i(12 downto  8);
				end if;

				if wb_sel_i(2)='1' then 
					csel1 <= wb_dat_i(20 downto 16);
				end if;

				if wb_sel_i(3)='1' then 
					csel0 <= wb_dat_i(28 downto 24);
				end if;
			end if;
		end if;

		-- Buffer read request
		if wbactive='1' and wb_adr_i(19 downto 16)=x"1" then
			ram_ack <= '1' and not ram_ack;
		else
			ram_ack <= '0';
		end if;
	end if;
end process;

-- Probe buffering and muxing -----------------------------------------------
bufproc: process(clk, reset) is -- buffer probes BEFORE mux (timing)
begin
	if reset='1' then
		probe_b <= (others => '0');
	elsif clk'event and clk='1' then
		probe_b <= probe;
	end if;
end process;


mux0: mux32           -- Channel 0
	port map (
		input    => probe_b,
		output   => chan(0),
		sel      => csel0 );

mux1: mux32           -- Channel 1
	port map (
		input    => probe_b,
		output   => chan(1),
		sel      => csel1 );

mux2: mux32           -- Channel 2
	port map (
		input    => probe_b,
		output   => chan(2),
		sel      => csel2 );

mux3: mux32           -- Channel 3
	port map (
		input    => probe_b,
		output   => chan(3),
		sel      => csel3 );

end rtl;

