--
--	cycore12_top.vhd
--
--	top level for cycore borad
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cycore12 is

generic (
	exta_width	: integer := 3;		-- length of exta part in JOP microcode
	io_addr_bits	: integer := 7;	-- address bits of internal io
	ram_cnt		: integer := 2;		-- clock cycles for external ram
--	rom_cnt		: integer := 3;		-- clock cycles for external rom OK for 20 MHz
	rom_cnt		: integer := 15;	-- clock cycles for external rom for 100 MHz
	jpc_width	: integer := 12;	-- address bits of java bytecode pc = cache size
	block_bits	: integer := 4		-- 2*block_bits is number of cache blocks
);

port (
	clk		: in std_logic;
--
--	serial interface
--
	ser_txd			: out std_logic;
	ser_rxd			: in std_logic;
	ser_ncts		: in std_logic;
	ser_nrts		: out std_logic;

--
--	watchdog
--
	wd		: out std_logic;
	freeio	: out std_logic;

--
--	two ram banks
--
	rama_a		: out std_logic_vector(17 downto 0);
	rama_d		: inout std_logic_vector(15 downto 0);
	rama_ncs	: out std_logic;
	rama_noe	: out std_logic;
	rama_nlb	: out std_logic;
	rama_nub	: out std_logic;
	rama_nwe	: out std_logic;
	ramb_a		: out std_logic_vector(17 downto 0);
	ramb_d		: inout std_logic_vector(15 downto 0);
	ramb_ncs	: out std_logic;
	ramb_noe	: out std_logic;
	ramb_nlb	: out std_logic;
	ramb_nub	: out std_logic;
	ramb_nwe	: out std_logic;

--
--	config/program flash and big nand flash
--
	fl_a	: out std_logic_vector(18 downto 0);
	fl_d	: inout std_logic_vector(7 downto 0);
	fl_ncs	: out std_logic;
	fl_ncsb	: out std_logic;
	fl_noe	: out std_logic;
	fl_nwe	: out std_logic;
	fl_rdy	: in std_logic;

--
--	I/O pins of board
--
	io_b	: inout std_logic_vector(10 downto 1);
	io_l	: inout std_logic_vector(20 downto 1);
	io_r	: inout std_logic_vector(20 downto 1);
	io_t	: inout std_logic_vector(6 downto 1)
);
end cycore12;

architecture rtl of cycore12 is

--
--	components:
--

component pll is
generic (multiply_by : natural; divide_by : natural);
port (
	inclk0		: in std_logic;
	c0			: out std_logic
);
end component;


component leon3mp is
  port (
    resetn	: in  std_ulogic;
    clk		: in  std_ulogic;
    pllref 	: in  std_ulogic; 
    errorn	: out std_ulogic;
    address 	: out std_logic_vector(27 downto 0);
    data	: inout std_logic_vector(31 downto 0);
    sa      	: out std_logic_vector(14 downto 0);
    sd   	: inout std_logic_vector(63 downto 0);
    sdclk  	: out std_ulogic;
    sdcke  	: out std_logic_vector (1 downto 0);    -- sdram clock enable
    sdcsn  	: out std_logic_vector (1 downto 0);    -- sdram chip select
    sdwen  	: out std_ulogic;                       -- sdram write enable
    sdrasn  	: out std_ulogic;                       -- sdram ras
    sdcasn  	: out std_ulogic;                       -- sdram cas
    sddqm   	: out std_logic_vector (7 downto 0);    -- sdram dqm
    dsutx  	: out std_ulogic; 			-- DSU tx data
    dsurx  	: in  std_ulogic;  			-- DSU rx data
    dsuen   	: in std_ulogic;
    dsubre  	: in std_ulogic;
    dsuact  	: out std_ulogic;
    txd1   	: out std_ulogic; 			-- UART1 tx data
    rxd1   	: in  std_ulogic;  			-- UART1 rx data
    txd2   	: out std_ulogic; 			-- UART2 tx data
    rxd2   	: in  std_ulogic;  			-- UART2 rx data
    ramsn  	: out std_logic_vector (4 downto 0);
    ramoen 	: out std_logic_vector (4 downto 0);
    rwen   	: out std_logic_vector (3 downto 0);
    oen    	: out std_ulogic;
    writen 	: out std_ulogic;
    read   	: out std_ulogic;
    iosn   	: out std_ulogic;
    romsn  	: out std_logic_vector (1 downto 0);
    gpio        : inout std_logic_vector(7 downto 0); 	-- I/O port

    emdio     	: inout std_logic;		-- ethernet PHY interface
    etx_clk 	: in std_ulogic;
    erx_clk 	: in std_ulogic;
    erxd    	: in std_logic_vector(3 downto 0);   
    erx_dv  	: in std_ulogic; 
    erx_er  	: in std_ulogic; 
    erx_col 	: in std_ulogic;
    erx_crs 	: in std_ulogic;
    etxd 	: out std_logic_vector(3 downto 0);   
    etx_en 	: out std_ulogic; 
    etx_er 	: out std_ulogic; 
    emdc 	: out std_ulogic;

    emddis 	: out std_logic;    
    epwrdwn 	: out std_ulogic;
    ereset 	: out std_ulogic;
    esleep 	: out std_ulogic;
    epause 	: out std_ulogic;

    pci_rst     : inout std_ulogic;		-- PCI bus
    pci_clk 	: in std_ulogic;
    pci_gnt     : in std_ulogic;
    pci_idsel   : in std_ulogic; 
    pci_lock    : inout std_ulogic;
    pci_ad 	: inout std_logic_vector(31 downto 0);
    pci_cbe 	: inout std_logic_vector(3 downto 0);
    pci_frame   : inout std_ulogic;
    pci_irdy 	: inout std_ulogic;
    pci_trdy 	: inout std_ulogic;
    pci_devsel  : inout std_ulogic;
    pci_stop 	: inout std_ulogic;
    pci_perr 	: inout std_ulogic;
    pci_par 	: inout std_ulogic;    
    pci_req 	: inout std_ulogic;
    pci_serr    : inout std_ulogic;
    pci_host   	: in std_ulogic;
    pci_66	: in std_ulogic;
    pci_arb_req	: in  std_logic_vector(0 to 3);
    pci_arb_gnt	: out std_logic_vector(0 to 3);

    can_txd	: out std_ulogic;
    can_rxd	: in  std_ulogic;
    can_stb	: out std_ulogic;

    spw_clk	: in  std_ulogic;
    spw_rxd     : in  std_logic_vector(0 to 2);
    spw_rxdn    : in  std_logic_vector(0 to 2);
    spw_rxs     : in  std_logic_vector(0 to 2);
    spw_rxsn    : in  std_logic_vector(0 to 2);
    spw_txd     : out std_logic_vector(0 to 2);
    spw_txdn    : out std_logic_vector(0 to 2);
    spw_txs     : out std_logic_vector(0 to 2);
    spw_txsn    : out std_logic_vector(0 to 2)

	);
end component;

--
--	Signals
--
	signal clk_int			: std_logic;

	signal int_res			: std_logic;
	signal not_int_res		: std_logic;
	signal res_cnt			: unsigned(2 downto 0) := "000";	-- for the simulation
	signal ramsn, ramoen		: std_logic_vector(4 downto 0);

	signal wd_out			: std_logic;

	-- for generation of internal reset
	attribute altera_attribute : string;
	attribute altera_attribute of res_cnt : signal is "POWER_UP_LEVEL=LOW";

--
--	LEON3 signals
--
    signal address 	: std_logic_vector(27 downto 0);
    signal data	: std_logic_vector(31 downto 0);

	signal ram_dout_en	: std_logic;
	signal ram_ncs	: std_logic;
	signal ram_nwe	: std_logic;
	signal ram_noe	: std_logic;

    signal	oen    	: std_logic;
    signal	writen 	: std_logic;
begin

--
--	intern reset
--	no extern reset, epm7064 has too less pins
--

process(clk_int)
begin
	if rising_edge(clk_int) then
		if (res_cnt/="111") then
			res_cnt <= res_cnt+1;
		end if;

		int_res <= not res_cnt(0) or not res_cnt(1) or not res_cnt(2);
	end if;
end process;

  not_int_res <= not int_res;
--
--	components
--
--	pll_inst : pll generic map(
--		multiply_by => pll_mult,
--		divide_by => pll_div
--	)
--	port map (
--		inclk0	 => clk,
--		c0	 => clk_int
--	);
 clk_int <= clk;

	-- sp_ov indicates stack overflow
	-- We can use the wd LED
	-- wd <= sp_ov;

	cmp_leon: leon3mp
		port map (

    resetn	=> not_int_res,
    clk		=> clk_int,
    pllref 	=> '0',
    errorn	=> open,
    address 	=> address,
    data(15 downto 0)	=> rama_d,
    data(31 downto 16)	=> ramb_d,
    sa      	=> open,
    sd   	=> open,
    sdclk  	=> open,
    sdcke  	=> open,
    sdcsn  	=> open,
    sdwen  	=> open,
    sdrasn  	=> open,
    sdcasn  	=> open,
    sddqm   	=> open,
    dsutx  	=> ser_txd,
    dsurx  	=> ser_rxd,
    dsuen   	=> '1',
    dsubre  	=> '0',
    dsuact  	=> open,
-- unused pins to not optimize serial line away
    txd1   	=> wd,
    rxd1   	=> fl_rdy,

    txd2   	=> open,
    rxd2   	=> '0',
    ramsn  	=> ramsn,
    ramoen 	=> ramoen,
    rwen   	=> open,
    oen    	=> open,
    writen 	=> ram_nwe,
    read   	=> open,
    iosn   	=> open,
    romsn  	=> open,
    gpio        => open,

    emdio     	=> open,
    etx_clk 	=> '0',
    erx_clk 	=> '0',
    erxd    	=> (others => '0'),
    erx_dv  	=> '0',
    erx_er  	=> '0',
    erx_col 	=> '0',
    erx_crs 	=> '0',
    etxd 	=> open,
    etx_en 	=> open,
    etx_er 	=> open,
    emdc 	=> open,

    emddis 	=> open,
    epwrdwn 	=> open,
    ereset 	=> open,
    esleep 	=> open,
    epause 	=> open,

    pci_rst     => open,
    pci_clk 	=> '0',
    pci_gnt     => '0',
    pci_idsel   => '0',
    pci_lock    => open,
    pci_ad 	=> open,
    pci_cbe 	=> open,
    pci_frame   => open,
    pci_irdy 	=> open,
    pci_trdy 	=> open,
    pci_devsel  => open,
    pci_stop 	=> open,
    pci_perr 	=> open,
    pci_par 	=> open,
    pci_req 	=> open,
    pci_serr    => open,
    pci_host   	=> '0',
    pci_66	=> '0',
    pci_arb_req	=> (others => '0'),
    pci_arb_gnt	=> open,

    can_txd	=> open,
    can_rxd	=> '0',
    can_stb	=> open,

    spw_clk	=> '0',
    spw_rxd     => (others => '0'),
    spw_rxdn    => (others => '0'),
    spw_rxs     => (others => '0'),
    spw_rxsn    => (others => '0'),
    spw_txd     => open,
    spw_txdn    => open,
    spw_txs     => open,
    spw_txsn    => open

	);

	ser_nrts <= '0';
        ram_ncs <= ramsn(0);
        ram_noe <= ramoen(0);

	rama_a <= address(19 downto 2);
	rama_ncs <= ram_ncs;
	rama_noe <= ram_noe;
	rama_nwe <= ram_nwe;
	rama_nlb <= '0';
	rama_nub <= '0';

	ramb_a <= address(19 downto 2);
	ramb_ncs <= ram_ncs;
	ramb_noe <= ram_noe;
	ramb_nwe <= ram_nwe;
	ramb_nlb <= '0';
	ramb_nub <= '0';

	freeio <= 'Z';

	fl_ncs <= '1';
	fl_ncsb <= '1';
end rtl;
