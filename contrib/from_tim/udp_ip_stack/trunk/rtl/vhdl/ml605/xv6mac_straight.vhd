--------------------------------------------------------------------------------
-- Project    : low latency UDP
-- File       : xv6mac_straight
-- Version    : 0.0
-------------------------------------------------------------------------------
--
--
-- Description:  This is an adaptation of the Xilinx V6 MAC layer, but without the FIFOs
--
--
--
--    ---------------------------------------------------------------------
--    | EXAMPLE DESIGN WRAPPER                                            |
--    |           --------------------------------------------------------|
--    |           |FIFO BLOCK WRAPPER                                     |
--    |           |                                                       |
--    |           |                                                       |
--    |           |              -----------------------------------------|
--    |           |              | BLOCK LEVEL WRAPPER                    |
--    |           |              |    ---------------------               |
--    |           |              |    |   V6 EMAC CORE    |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    | |      |  |              |    |                   |  ---------    |
--    | |      |->|->----------->|--|--->| Tx            Tx  |--|       |--->|
--    | |      |  |              |    | AXI-S         PHY |  |       |    |
--    | |      |  |              |    | I/F           I/F |  |       |    |
--    | |      |  |              |    |                   |  | PHY   |    |
--    | |      |  |              |    |                   |  | I/F   |    |
--    | |      |  |              |    |                   |  |       |    |
--    | |      |  |              |    | Rx            Rx  |  |       |    |
--    | |      |  |              |    | AX)-S         PHY |  |       |    |
--    | |      |<-|<-------------|----| I/F           I/F |<-|       |<---|
--    | |      |  |              |    |                   |  ---------    |
--    | --------  |              |    ---------------------               |
--    |           |              |                                        |
--    |           |              -----------------------------------------|
--    |           --------------------------------------------------------|
--    ---------------------------------------------------------------------
--
--------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity xv6mac_straight is
  port (
    -- System controls
    ------------------
    glbl_rst  : in std_logic;           -- asynchronous reset
    mac_reset : in std_logic;           -- reset mac layer
    clk_in_p  : in std_logic;           -- 200MHz clock input from board
    clk_in_n  : in std_logic;

    -- MAC Transmitter (AXI-S) Interface
    ---------------------------------------------
    mac_tx_clock  : out std_logic;                     -- data sampled on rising edge
    mac_tx_tdata  : in  std_logic_vector(7 downto 0);  -- data byte to tx
    mac_tx_tvalid : in  std_logic;                     -- tdata is valid
    mac_tx_tready : out std_logic;                     -- mac is ready to accept data
    mac_tx_tlast  : in  std_logic;                     -- indicates last byte of frame

    -- MAC Receiver (AXI-S) Interface
    ------------------------------------------
    mac_rx_clock  : out std_logic;      -- data valid on rising edge
    mac_rx_tdata  : out std_logic_vector(7 downto 0);  -- data byte received
    mac_rx_tvalid : out std_logic;      -- indicates tdata is valid
    mac_rx_tready : in  std_logic;      -- tells mac that we are ready to take data
    mac_rx_tlast  : out std_logic;      -- indicates last byte of the trame

    -- GMII Interface
    -----------------     
    phy_resetn  : out std_logic;
    gmii_txd    : out std_logic_vector(7 downto 0);
    gmii_tx_en  : out std_logic;
    gmii_tx_er  : out std_logic;
    gmii_tx_clk : out std_logic;
    gmii_rxd    : in  std_logic_vector(7 downto 0);
    gmii_rx_dv  : in  std_logic;
    gmii_rx_er  : in  std_logic;
    gmii_rx_clk : in  std_logic;
    gmii_col    : in  std_logic;
    gmii_crs    : in  std_logic;
    mii_tx_clk  : in  std_logic
    );
end xv6mac_straight;

architecture wrapper of xv6mac_straight is

  ------------------------------------------------------------------------------
  -- Component declaration for the internal mac layer
  ------------------------------------------------------------------------------
  component mac_layer_v2_2_block
    port(
      gtx_clk : in std_logic;

      -- Receiver Interface
      ----------------------------
      rx_statistics_vector : out std_logic_vector(27 downto 0);
      rx_statistics_valid  : out std_logic;

      rx_mac_aclk        : out std_logic;
      rx_reset           : out std_logic;
      rx_axis_mac_tdata  : out std_logic_vector(7 downto 0);
      rx_axis_mac_tvalid : out std_logic;
      rx_axis_mac_tlast  : out std_logic;
      rx_axis_mac_tuser  : out std_logic;

      -- Transmitter Interface
      -------------------------------
      tx_ifg_delay         : in  std_logic_vector(7 downto 0);
      tx_statistics_vector : out std_logic_vector(31 downto 0);
      tx_statistics_valid  : out std_logic;

      tx_reset           : out std_logic;
      tx_axis_mac_tdata  : in  std_logic_vector(7 downto 0);
      tx_axis_mac_tvalid : in  std_logic;
      tx_axis_mac_tlast  : in  std_logic;
      tx_axis_mac_tuser  : in  std_logic;
      tx_axis_mac_tready : out std_logic;
      tx_collision       : out std_logic;
      tx_retransmit      : out std_logic;

      -- MAC Control Interface
      ------------------------
      pause_req : in std_logic;
      pause_val : in std_logic_vector(15 downto 0);

      -- Reference clock for IDELAYCTRL's
      refclk : in std_logic;

      -- GMII Interface
      -----------------
      gmii_txd    : out std_logic_vector(7 downto 0);
      gmii_tx_en  : out std_logic;
      gmii_tx_er  : out std_logic;
      gmii_tx_clk : out std_logic;
      gmii_rxd    : in  std_logic_vector(7 downto 0);
      gmii_rx_dv  : in  std_logic;
      gmii_rx_er  : in  std_logic;
      gmii_rx_clk : in  std_logic;

      -- asynchronous reset
      -----------------
      glbl_rstn   : in std_logic;
      rx_axi_rstn : in std_logic;
      tx_axi_rstn : in std_logic

      );
  end component;


  ------------------------------------------------------------------------------
  -- Component Declaration for the Clock generator
  ------------------------------------------------------------------------------

  component clk_wiz_v2_2
    port (
      -- Clock in ports
      CLK_IN1_P : in  std_logic;
      CLK_IN1_N : in  std_logic;
      -- Clock out ports
      CLK_OUT1  : out std_logic;
      CLK_OUT2  : out std_logic;
      CLK_OUT3  : out std_logic;
      -- Status and control signals
      RESET     : in  std_logic;
      LOCKED    : out std_logic
      );
  end component;


  ------------------------------------------------------------------------------
  -- Component declaration for the reset synchroniser
  ------------------------------------------------------------------------------
  component reset_sync_v2_2
    port (
      reset_in  : in  std_logic;        -- Active high asynchronous reset
      enable    : in  std_logic;
      clk       : in  std_logic;        -- clock to be sync'ed to
      reset_out : out std_logic         -- "Synchronised" reset signal
      );
  end component;

  ------------------------------------------------------------------------------
  -- Component declaration for the synchroniser
  ------------------------------------------------------------------------------
  component sync_block_v2_2
    port (
      clk      : in  std_logic;
      data_in  : in  std_logic;
      data_out : out std_logic
      );
  end component;

  ------------------------------------------------------------------------------
  -- Constants used in this top level wrapper.
  ------------------------------------------------------------------------------
  constant BOARD_PHY_ADDR : std_logic_vector(7 downto 0) := "00000111";


  ------------------------------------------------------------------------------
  -- internal signals used in this top level wrapper.
  ------------------------------------------------------------------------------

  -- example design clocks
  signal gtx_clk_bufg : std_logic;
  signal refclk_bufg  : std_logic;
  signal rx_mac_aclk  : std_logic;

  -- tx handshaking
  signal mac_tx_tready_int : std_logic;
  signal tx_full_reg       : std_logic;
  signal tx_full_val       : std_logic;
  signal tx_data_reg       : std_logic_vector(7 downto 0);
  signal tx_last_reg       : std_logic;
  signal set_tx_reg        : std_logic;

  signal phy_resetn_int : std_logic;

  -- resets (and reset generation)
  signal local_chk_reset : std_logic;
  signal chk_reset_int   : std_logic;
  signal chk_pre_resetn  : std_logic := '0';
  signal chk_resetn      : std_logic := '0';
  signal dcm_locked      : std_logic;

  signal glbl_rst_int    : std_logic;
  signal phy_reset_count : unsigned(5 downto 0);
  signal glbl_rst_intn   : std_logic;

  -- pipeline register for RX signals
  signal rx_data_val   : std_logic_vector(7 downto 0);
  signal rx_tvalid_val : std_logic;
  signal rx_tlast_val  : std_logic;
  signal rx_data_reg   : std_logic_vector(7 downto 0);
  signal rx_tvalid_reg : std_logic;
  signal rx_tlast_reg  : std_logic;

  attribute keep                      : string;
  attribute keep of gtx_clk_bufg      : signal is "true";
  attribute keep of refclk_bufg       : signal is "true";
  attribute keep of mac_tx_tready_int : signal is "true";
  attribute keep of tx_full_reg       : signal is "true";


  ------------------------------------------------------------------------------
  -- Begin architecture
  ------------------------------------------------------------------------------

begin

  combinatorial : process (
    rx_data_reg, rx_tvalid_reg, rx_tlast_reg,
    mac_tx_tvalid, mac_tx_tready_int, tx_full_reg, tx_full_val, set_tx_reg
    )
  begin
    -- output followers
    mac_rx_tdata  <= rx_data_reg;
    mac_rx_tvalid <= rx_tvalid_reg;
    mac_rx_tlast  <= rx_tlast_reg;
    mac_tx_tready <= not (tx_full_reg and not mac_tx_tready_int);  -- if not full, we are ready to accept

    -- control defaults
    tx_full_val <= tx_full_reg;
    set_tx_reg  <= '0';

    -- tx handshaking logic
    if mac_tx_tvalid = '1' then
      tx_full_val <= '1';
      set_tx_reg  <= '1';
    elsif mac_tx_tready_int = '1' then
      tx_full_val <= '0';
    end if;
    
  end process;

  sequential : process(gtx_clk_bufg)
  begin
    if rising_edge(gtx_clk_bufg) then
      if chk_resetn = '0' then
        -- reset state variables
        rx_data_reg   <= (others => '0');
        rx_tvalid_reg <= '0';
        rx_tlast_reg  <= '0';
        tx_full_reg   <= '0';
        tx_data_reg   <= (others => '0');
        tx_last_reg   <= '0';
      else
        -- register rx data
        rx_data_reg   <= rx_data_val;
        rx_tvalid_reg <= rx_tvalid_val;
        rx_tlast_reg  <= rx_tlast_val;

        -- process tx tvalid and tready
        tx_full_reg <= tx_full_val;
        if set_tx_reg = '1' then
          tx_data_reg <= mac_tx_tdata;
          tx_last_reg <= mac_tx_tlast;
        else
          tx_data_reg <= tx_data_reg;
          tx_last_reg <= tx_last_reg;
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Instantiate the Tri-Mode EMAC Block wrapper
  ------------------------------------------------------------------------------
  v6emac_block : mac_layer_v2_2_block
    port map(
      gtx_clk => gtx_clk_bufg,

      -- Client Receiver Interface
      rx_statistics_vector => open,
      rx_statistics_valid  => open,

      rx_mac_aclk        => open,
      rx_reset           => open,
      rx_axis_mac_tdata  => rx_data_val,
      rx_axis_mac_tvalid => rx_tvalid_val,
      rx_axis_mac_tlast  => rx_tlast_val,
      rx_axis_mac_tuser  => open,

      -- Client Transmitter Interface
      tx_ifg_delay         => x"00",
      tx_statistics_vector => open,
      tx_statistics_valid  => open,

      tx_reset           => open,
      tx_axis_mac_tdata  => tx_data_reg,
      tx_axis_mac_tvalid => tx_full_reg,
      tx_axis_mac_tlast  => tx_last_reg,
      tx_axis_mac_tuser  => '0',
      tx_axis_mac_tready => mac_tx_tready_int,
      tx_collision       => open,
      tx_retransmit      => open,

      -- Flow Control
      pause_req => '0',
      pause_val => x"0000",

      -- Reference clock for IDELAYCTRL's
      refclk => refclk_bufg,

      -- GMII Interface
      gmii_txd    => gmii_txd,
      gmii_tx_en  => gmii_tx_en,
      gmii_tx_er  => gmii_tx_er,
      gmii_tx_clk => gmii_tx_clk,
      gmii_rxd    => gmii_rxd,
      gmii_rx_dv  => gmii_rx_dv,
      gmii_rx_er  => gmii_rx_er,
      gmii_rx_clk => gmii_rx_clk,

      -- asynchronous reset
      glbl_rstn   => chk_resetn,
      rx_axi_rstn => '1',
      tx_axi_rstn => '1'
      );



  ------------------------------------------------------------------------------
  -- Clock logic to generate required clocks from the 200MHz on board
  -- if 125MHz is available directly this can be removed
  ------------------------------------------------------------------------------
  clock_generator : clk_wiz_v2_2
    port map (
      -- Clock in ports
      CLK_IN1_P => clk_in_p,
      CLK_IN1_N => clk_in_n,
      -- Clock out ports
      CLK_OUT1  => gtx_clk_bufg,
      CLK_OUT2  => open,
      CLK_OUT3  => refclk_bufg,
      -- Status and control signals
      RESET     => glbl_rst,
      LOCKED    => dcm_locked
      );

  -----------------
  -- global reset
  glbl_reset_gen : reset_sync_v2_2
    port map (
      clk       => gtx_clk_bufg,
      enable    => dcm_locked,
      reset_in  => glbl_rst,
      reset_out => glbl_rst_int
      );

  glbl_rst_intn <= not glbl_rst_int;

  -- generate the user side clocks
  mac_tx_clock <= gtx_clk_bufg;
  mac_rx_clock <= gtx_clk_bufg;

  ------------------------------------------------------------------------------
  -- Generate resets 
  ------------------------------------------------------------------------------
  -- in each case the async reset is first captured and then synchronised


  local_chk_reset <= glbl_rst or mac_reset;

  -----------------
  -- data check reset
  chk_reset_gen : reset_sync_v2_2
    port map (
      clk       => gtx_clk_bufg,
      enable    => dcm_locked,
      reset_in  => local_chk_reset,
      reset_out => chk_reset_int
      );

  -- Create fully synchronous reset in the gtx clock domain.
  gen_chk_reset : process (gtx_clk_bufg)
  begin
    if gtx_clk_bufg'event and gtx_clk_bufg = '1' then
      if chk_reset_int = '1' then
        chk_pre_resetn <= '0';
        chk_resetn     <= '0';
      else
        chk_pre_resetn <= '1';
        chk_resetn     <= chk_pre_resetn;
      end if;
    end if;
  end process gen_chk_reset;


  -----------------
  -- PHY reset
  -- the phy reset output (active low) needs to be held for at least 10x25MHZ cycles
  -- this is derived using the 125MHz available and a 6 bit counter
  gen_phy_reset : process (gtx_clk_bufg)
  begin
    if gtx_clk_bufg'event and gtx_clk_bufg = '1' then
      if glbl_rst_intn = '0' then
        phy_resetn_int  <= '0';
        phy_reset_count <= (others => '0');
      else
        if phy_reset_count /= "111111" then
          phy_reset_count <= phy_reset_count + "000001";
        else
          phy_resetn_int <= '1';
        end if;
      end if;
    end if;
  end process gen_phy_reset;

  phy_resetn <= phy_resetn_int;


end wrapper;
