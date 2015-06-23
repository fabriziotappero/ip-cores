library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
-- pragma translate_off
-- pragma translate_on

library techmap;
use techmap.gencomp.all;
------------------------------------------------------------------
-- Virtex5 DDR2 PHY ----------------------------------------------
------------------------------------------------------------------

entity stratixiii_ddr2_phy is
  generic (MHz : integer := 100; rstdelay : integer := 200;
           dbits : integer := 16; clk_mul : integer := 2; clk_div : integer := 2;
           ddelayb0 : integer := 0; ddelayb1 : integer := 0; ddelayb2 : integer := 0;
           ddelayb3 : integer := 0; ddelayb4 : integer := 0; ddelayb5 : integer := 0;
           ddelayb6 : integer := 0; ddelayb7 : integer := 0; 
           numidelctrl : integer := 4; norefclk : integer := 0; 
           tech : integer := stratix3; odten : integer := 0; rskew : integer := 0);

  port (
    rst        : in  std_ulogic;
    clk        : in  std_logic;        -- input clock
    clkref200  : in  std_logic;        -- input 200MHz clock
    clkout     : out std_ulogic;       -- system clock
    lock       : out std_ulogic;       -- DCM locked

    ddr_clk    : out std_logic_vector(2 downto 0);
    ddr_clkb   : out std_logic_vector(2 downto 0);
    ddr_cke    : out std_logic_vector(1 downto 0);
    ddr_csb    : out std_logic_vector(1 downto 0);
    ddr_web    : out std_ulogic;                       -- ddr write enable
    ddr_rasb   : out std_ulogic;                       -- ddr ras
    ddr_casb   : out std_ulogic;                       -- ddr cas
    ddr_dm     : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs    : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqsn   : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqsn
    ddr_ad     : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba     : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq     : inout  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_odt    : out std_logic_vector(1 downto 0);

    addr       : in  std_logic_vector (13 downto 0); -- data mask
    ba         : in  std_logic_vector ( 1 downto 0); -- data mask
    dqin       : out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout      : in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm         : in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen        : in  std_ulogic;
    dqs        : in  std_ulogic;
    dqsoen     : in  std_ulogic;
    rasn       : in  std_ulogic;
    casn       : in  std_ulogic;
    wen        : in  std_ulogic;
    csn        : in  std_logic_vector(1 downto 0);
    cke        : in  std_logic_vector(1 downto 0);
    cal_en     : in  std_logic_vector(dbits/8-1 downto 0);
    cal_inc    : in  std_logic_vector(dbits/8-1 downto 0);
    cal_pll    : in  std_logic_vector(1 downto 0);
    cal_rst    : in  std_logic;
    odt        : in  std_logic_vector(1 downto 0)
  );

end;

architecture rtl of stratixiii_ddr2_phy is

  component apll IS
  generic (
    freq    : integer := 200;
    mult    : integer := 8;
    div     : integer := 5;
    rskew   : integer := 0
  );
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
    phasestep   : IN STD_LOGIC  := '0';
    phaseupdown : IN STD_LOGIC  := '0';
    scanclk     : IN STD_LOGIC  := '1';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		c2		: OUT STD_LOGIC ;
		c3		: OUT STD_LOGIC ;
		c4		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC;
    phasedone : out std_logic
	);
  END component;

  component aclkout is
  port(
    clk     : in  std_logic;
    ddr_clk : out std_logic;
    ddr_clkn: out std_logic
  );
  end component;

  component actrlout is
  generic(
    power_up  : string := "high"
  );
  port(
    clk     : in  std_logic;
    i       : in  std_logic;
    o       : out std_logic
  );
  end component;

  component adqsout is
  port(
    clk       : in  std_logic; -- clk90
    dqs       : in  std_logic;
    dqs_oe    : in  std_logic;
    dqs_oct   : in  std_logic; -- gnd = disable
    dqs_pad   : out std_logic; -- DQS pad
    dqsn_pad  : out std_logic  -- DQSN pad
  );
  end component;

  component adqsin is
  port(
    dqs_pad   : in  std_logic; -- DQS pad
    dqsn_pad  : in  std_logic; -- DQSN pad
    dqs       : out std_logic
  );
  end component;

  component admout is
  port(
    clk       : in  std_logic; -- clk0
    dm_h      : in  std_logic;
    dm_l      : in  std_logic;
    dm_pad    : out std_logic  -- DQ pad
  );
  end component;

  component adqin is
  port(
    clk     : in  std_logic;
    dq_pad  : in  std_logic; -- DQ pad
    dq_h    : out std_logic;
    dq_l    : out std_logic;
    config_clk    : in  std_logic;
    config_clken  : in  std_logic;
    config_datain : in  std_logic;
    config_update : in  std_logic
  );
  end component;

  component adqout is
  port(
    clk       : in  std_logic; -- clk0
    clk_oct   : in  std_logic; -- clk90
    dq_h      : in  std_logic;
    dq_l      : in  std_logic;
    dq_oe     : in  std_logic;
    dq_oct    : in  std_logic; -- gnd = disable
    dq_pad    : out std_logic  -- DQ pad
  );
  end component;

signal reset                : std_logic;
signal vcc, gnd, oe         : std_ulogic;
signal locked, vlockl, lockl  : std_ulogic;
signal clk0r, clk90r, clk180r, clk270r, rclk  : std_ulogic;
signal ckel, ckel2          : std_logic_vector(1 downto 0);
signal odtl                 : std_logic_vector(1 downto 0);
signal dqsin, dqsin_reg     : std_logic_vector (7 downto 0);    -- ddr dqs
signal dqsn                 : std_logic_vector(dbits/8-1 downto 0);
signal dqsoenr              : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal delayrst             : std_logic_vector(3 downto 0);
signal phasedone            : std_logic;
signal dqinl                : std_logic_vector (dbits-1 downto 0); -- ddr data

signal dqsin_tmp : std_logic;

type phy_r_type is record
  delay   : std_logic_vector(3 downto 0);
  count   : std_logic_vector(3 downto 0);
  update  : std_logic; 
  sdata   : std_logic;
  enable  : std_logic;
  update_delay   : std_logic;
end record;
type phy_r_type_arr is array (7 downto 0) of phy_r_type;
signal r,rin : phy_r_type_arr;
signal rp : std_logic_vector(3 downto 0);

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

attribute keep : boolean;
attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of dqsn : signal is true;
attribute syn_preserve of dqsn : signal is true;
attribute syn_keep of dqsoenr : signal is true;
attribute syn_preserve of dqsoenr : signal is true;
attribute syn_keep of dqsin_reg : signal is true;
attribute syn_preserve of dqsin_reg : signal is true;

begin

  -----------------------------------------------------------------------------------
  -- Clock generation 
  -----------------------------------------------------------------------------------
  oe <= not oen;
  vcc <= '1'; gnd <= '0';
  reset <= not rst;
  
  -- Optional DDR clock multiplication

  pll0 : apll 
  generic map(
      freq   => MHz,
      mult   => clk_mul,
      div    => clk_div,
      rskew  => rskew
    )
  port map(
		areset  => reset,
		inclk0  => clk,
    phasestep   => rp(1),
    phaseupdown => rp(3),
    scanclk     => clk0r,
		c0      => clk0r,
		c1      => clk90r,
		c2      => open, --clk180r,
		c3      => open, --clk270r,
		c4      => rclk,
		locked  => lockl,
    phasedone => phasedone
  );

  clk180r <= not clk0r;
  clk270r <= not clk90r;
  clkout <= clk0r;

  -----------------------------------------------------------------------------------
  -- Lock delay
  -----------------------------------------------------------------------------------
  rdel : if rstdelay /= 0 generate
    rcnt : process (clk0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
          cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16); vlock := '0';
          cnt(0) := dqsin_reg(7) or dqsin_reg(6) or dqsin_reg(5) or dqsin_reg(4) or  -- dummy use of dqsin
                    dqsin_reg(3) or dqsin_reg(2) or dqsin_reg(1) or dqsin_reg(0);
        else
          if vlock = '0' then
            cnt := cnt -1;  vlock := cnt(15) and not co;
          end if;
        end if;
      end if;
      if lockl = '0' then
        vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock <= locked;

  -----------------------------------------------------------------------------------
  -- Generate external DDR clock
  -----------------------------------------------------------------------------------
  ddrclocks : for i in 0 to 2 generate
    ddrclk_pad : aclkout port map(clk => clk90r, ddr_clk => ddr_clk(i), ddr_clkn => ddr_clkb(i));
  end generate;

  -----------------------------------------------------------------------------------
  --  DDR single-edge control signals
  -----------------------------------------------------------------------------------
  -- ODT pads
  odtgen : for i in 0 to 1 generate
    odtl(i) <= locked and odt(i);
    ddr_odt_pad : actrlout generic map(power_up => "low")
      port map(clk =>clk180r , i => odtl(i), o => ddr_odt(i));
  end generate;

  -- CSN and CKE
  ddrbanks : for i in 0 to 1 generate
    ddr_csn_pad : actrlout port map(clk =>clk180r , i => csn(i), o => ddr_csb(i));

    ckel(i) <= cke(i) and locked;
    ddr_cke_pad : actrlout generic map(power_up => "low")
      port map(clk =>clk0r , i => ckel(i), o => ddr_cke(i));
  end generate;

  -- RAS
    ddr_rasn_pad : actrlout port map(clk =>clk180r , i => rasn, o => ddr_rasb);

  -- CAS
    ddr_casn_pad : actrlout port map(clk =>clk180r , i => casn, o => ddr_casb);

  -- WEN
    ddr_wen_pad : actrlout port map(clk =>clk180r , i => wen, o => ddr_web);

  -- BA
  bagen : for i in 0 to 1 generate
    ddr_ba_pad : actrlout port map(clk =>clk180r , i => ba(i), o => ddr_ba(i));
  end generate;

  -- ADDRESS
  dagen : for i in 0 to 13 generate
    ddr_ad_pad : actrlout port map(clk =>clk180r , i => addr(i), o => ddr_ad(i));
  end generate;

  -----------------------------------------------------------------------------------
  -- DQS generation
  -----------------------------------------------------------------------------------

  dqsgen : for i in 0 to dbits/8-1 generate

    doen : process(clk180r)
    begin if rising_edge(clk180r) then dqsoenr(i) <= dqsoen; end if; end process;

    dsqreg : process(clk180r)
    begin if rising_edge(clk180r) then dqsn(i) <= oe; end if; end process;

    dqs_out_pad : adqsout port map(
      clk       => clk90r,     -- clk90
      dqs       => dqsn(i),
      dqs_oe    => dqsoenr(i),
      dqs_oct   => gnd,        -- gnd = disable
      dqs_pad   => ddr_dqs(i), -- DQS pad
      dqsn_pad  => ddr_dqsn(i) -- DQSN pad
    );
    
    dqs_in_pad : adqsin port map(
      dqs_pad   => ddr_dqs(i),
      dqsn_pad  => ddr_dqsn(i),
      dqs       => dqsin(i)
    );
    -- Dummy procces to sample dqsin
    process(clk0r) 
    begin 
      if rising_edge(clk0r) then 
          dqsin_reg(i) <= dqsin(i); 
      end if; 
    end process;

  end generate;
  
  -----------------------------------------------------------------------------------
  -- DQM generation
  -----------------------------------------------------------------------------------
  dmgen : for i in 0 to dbits/8-1 generate
    
    ddr_dm_pad : admout port map(
      clk       => clk0r, -- clk0
      dm_h      => dm(i+dbits/8),
      dm_l      => dm(i),
      dm_pad    => ddr_dm(i)  -- DQ pad
    );
  end generate;

  -----------------------------------------------------------------------------------
  -- Data bus
  -----------------------------------------------------------------------------------
    ddgen : for i in 0 to dbits-1 generate
      -- DQ Input
      dq_in_pad : adqin port map(
        clk     => rclk,--clk0r,
        dq_pad  => ddr_dq(i), -- DQ pad
        dq_h    => dqin(i), --dqinl(i),
        dq_l    => dqin(i+dbits),--dqin(i),
        config_clk    => clk0r,
        config_clken  => r(i/8).enable,--io_config_clkena,
        config_datain => r(i/8).sdata,--io_config_datain,
        config_update => r(i/8).update_delay--io_config_update
      );
      --dinq1 : process (clk0r)
      --begin if rising_edge(clk0r) then dqin(i+dbits) <= dqinl(i); end if; end process;

      -- DQ Output  
      dq_out_pad : adqout port map(
        clk       => clk0r, -- clk0
        clk_oct   => clk90r, -- clk90
        dq_h      => dqout(i+dbits),
        dq_l      => dqout(i),
        dq_oe     => oen,
        dq_oct    => gnd, -- gnd = disable
        dq_pad    => ddr_dq(i)  -- DQ pad
      );
    end generate;
  
  -----------------------------------------------------------------------------------
  -- Delay control
  -----------------------------------------------------------------------------------
  
    delay_control : for i in 0 to dbits/8-1 generate

      process(r(i),cal_en(i), cal_inc(i), delayrst(3))
      variable v : phy_r_type;
      variable data : std_logic_vector(0 to 3);
      begin
        v := r(i);
        data := r(i).delay;
        v.update_delay := '0';
        if cal_en(i) = '1' then
          if cal_inc(i) = '1' then
            v.delay := r(i).delay + 1; 
          else
            v.delay := r(i).delay - 1; 
          end if;
          v.update := '1';
          v.count := (others => '0');
        end if;
      
        if r(i).update = '1' then
          v.enable := '1';
          v.sdata := '0';
          
          if r(i).count <= "1011" then
            v.count := r(i).count + 1;
          end if;
  
          if r(i).count <= "0011" then
            v.sdata := data(conv_integer(r(i).count));
          end if;
  
          if r(i).count = "1011" then
            v.update_delay := '1';
            v.enable := '0';
            v.update := '0';
          end if;
        end if;
  
        if delayrst(3) = '0' then
          v.delay := (others => '0');
          v.count := (others => '0');
          v.update := '0';
          v.enable := '0';
        end if;
  
        rin(i) <= v;
      end process;
  
    end generate;

      process(clk0r)
      begin 
        if locked = '0' then
          delayrst <= (others => '0');
        elsif rising_edge(clk0r) then
          delayrst <= delayrst(2 downto 0) & '1';
          r <= rin;
          -- PLL phase config
          rp(0) <= cal_pll(0); rp(1) <= cal_pll(0) or rp(0); 
          rp(2) <= cal_pll(1); rp(3) <= cal_pll(1) or rp(2);
        end if; 
      end process;

end;



