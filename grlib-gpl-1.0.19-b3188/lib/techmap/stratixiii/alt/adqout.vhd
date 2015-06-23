library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library stratixiii;
use stratixiii.all;
library altera;
use altera.all;

entity adqout is
  port(
    clk       : in  std_logic; -- clk0
    clk_oct   : in  std_logic; -- clk90
    dq_h      : in  std_logic;
    dq_l      : in  std_logic;
    dq_oe     : in  std_logic;
    dq_oct    : in  std_logic; -- gnd = disable
    dq_pad    : out std_logic  -- DQ pad
  );
end;
architecture rtl of adqout is

component stratixiii_ddio_out 
  generic(
    power_up                           :  string := "low";          
    async_mode                         :  string := "none";       
    sync_mode                          :  string := "none";
    half_rate_mode                     :  string := "false";       
    use_new_clocking_model             :  string := "false";
    lpm_type                           :  string := "stratixiii_ddio_out"
  );
  port (
    datainlo                : in std_logic := '0';   
    datainhi                : in std_logic := '0';   
    clk                     : in std_logic := '0'; 
    clkhi                   : in std_logic := '0'; 
    clklo                   : in std_logic := '0'; 
    muxsel                  : in std_logic := '0';   
    ena                     : in std_logic := '1';   
    areset                  : in std_logic := '0';   
    sreset                  : in std_logic := '0';   
    dataout                 : out std_logic--;         
    --dfflo                   : out std_logic;         
    --dffhi                   : out std_logic;         
    --devclrn                 : in std_logic := '1';   
    --devpor                  : in std_logic := '1'   
  );   
end component;

component stratixiii_ddio_oe is
  generic(
    power_up              :  string := "low";    
    async_mode            :  string := "none";    
    sync_mode             :  string := "none";
    lpm_type              :  string := "stratixiii_ddio_oe"
  );    
  port (
    oe                      : IN std_logic := '1';   
    clk                     : IN std_logic := '0';   
    ena                     : IN std_logic := '1';   
    areset                  : IN std_logic := '0';   
    sreset                  : IN std_logic := '0';   
    dataout                 : OUT std_logic--;         
    --dfflo                   : OUT std_logic;         
    --dffhi                   : OUT std_logic;         
    --devclrn                 : IN std_logic := '1';               
    --devpor                  : IN std_logic := '1'
  );             
end component;

component  stratixiii_io_obuf
  generic(
    bus_hold	:	string := "false";
    open_drain_output	:	string := "false";
    shift_series_termination_control	:	string := "false";
    lpm_type	:	string := "stratixiii_io_obuf"
  );
  port( 
    dynamicterminationcontrol	:	in std_logic := '0';
    i	:	in std_logic := '0';
    o	:	out std_logic;
    obar	:	out std_logic;
    oe	:	in std_logic := '1'--;
    --parallelterminationcontrol	:	in std_logic_vector(13 downto 0) := (others => '0');
    --seriesterminationcontrol	:	in std_logic_vector(13 downto 0) := (others => '0')
  ); 
end component;

component DFF is
  port(
    d, clk, clrn, prn :  in  std_logic;
    q                 :  out std_logic);
end component;

signal vcc      : std_logic;
signal gnd      : std_logic_vector(13 downto 0);
signal dq_reg   : std_logic;
signal dq_oe_reg, dq_oe_reg_n, dq_oct_reg : std_logic; 

attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of dq_oe_reg : signal is true;
attribute syn_preserve of dq_oe_reg : signal is true;
attribute syn_keep of dq_oe_reg_n : signal is true;
attribute syn_preserve of dq_oe_reg_n : signal is true;

begin
  vcc <= '1'; gnd <= (others => '0');

-- DQ output register --------------------------------------------------------------

  dq_reg0 : stratixiii_ddio_out
    generic map(
      power_up               => "high",          
      async_mode             => "none",       
      sync_mode              => "none",
      half_rate_mode         => "false",      
      use_new_clocking_model => "true",
      lpm_type               => "stratixiii_ddio_out"
    )
    port map(
      datainlo => dq_l,   
      datainhi => dq_h,   
      clk      => clk, 
      clkhi    => clk, 
      clklo    => clk, 
      muxsel   => clk,   
      ena      => vcc,   
      areset   => gnd(0),   
      sreset   => gnd(0),   
      dataout  => dq_reg--,   
      --dfflo    => open,   
      --dffhi    => open,    
      --devclrn  => vcc,   
      --devpor   => vcc  
    );

-- Outout enable and oct for DQ -----------------------------------------------------
  
--  dq_oe_reg0 : stratixiii_ddio_oe
--    generic map(
--      power_up    => "low",    
--      async_mode  => "none",    
--      sync_mode   => "none",
--      lpm_type    => "stratixiii_ddio_oe"
--    )
--    port map(
--      oe        => dq_oe,
--      clk       => clk,
--      ena       => vcc,
--      areset    => gnd(0),
--      sreset    => gnd(0),
--      dataout   => dq_oe_reg--,
--      --dfflo   => open,
--      --dffhi   => open,
--      --devclrn => vcc,
--      --devpor  => vcc
--    );

--  dq_oe_reg0 : dff
--    port map(
--      d         => dq_oe,
--      clk       => clk,
--      clrn      => vcc,
--      prn       => vcc,
--      q         => dq_oe_reg
--    );

  dq_oe_reg0 : process(clk)
  begin if rising_edge(clk) then dq_oe_reg <= dq_oe; end if; end process;

  dq_oe_reg_n <= not dq_oe_reg;

  dq_oct_reg0 : stratixiii_ddio_oe
    generic map(
      power_up    => "low",    
      async_mode  => "none",    
      sync_mode   => "none",
      lpm_type    => "stratixiii_ddio_oe"
    )
    port map(
      oe        => dq_oct,
      clk       => clk_oct,
      ena       => vcc,
      areset    => gnd(0),
      sreset    => gnd(0),
      dataout   => dq_oct_reg--,
      --dfflo   => open,
      --dffhi   => open,
      --devclrn => vcc,
      --devpor  => vcc
    );
  
-- Out buffer (DQ) ------------------------------------------------------------------

  dq_buf0 : stratixiii_io_obuf 
    generic map(
      open_drain_output                => "false",              
      shift_series_termination_control => "false",  
      bus_hold                         => "false",              
      lpm_type                         => "stratixiii_io_obuf"
    )               
    port map(
      i                          => dq_reg,                                                 
      oe                         => dq_oe_reg_n,                                                 
      dynamicterminationcontrol  => gnd(0),--dq_oct_reg,                                 
      --seriesterminationcontrol   => gnd, 
      --parallelterminationcontrol => gnd, 
      o                          => dq_pad,                                                       
      obar                       => open
    );                                                      
end;
