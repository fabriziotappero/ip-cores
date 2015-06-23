library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library stratixiii;
use stratixiii.all;

entity adqsout is
  port(
    clk       : in  std_logic; -- clk90
    dqs       : in  std_logic;
    dqs_oe    : in  std_logic;
    dqs_oct   : in  std_logic; -- gnd = disable
    dqs_pad   : out std_logic; -- DQS pad
    dqsn_pad  : out std_logic  -- DQSN pad
  );
end;
architecture rtl of adqsout is

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

component stratixiii_pseudo_diff_out is
  generic (
    lpm_type        :  string := "stratixiii_pseudo_diff_out"
  );
  port (
    i                       : in std_logic := '0';
    o                       : out std_logic;
    obar                    : out std_logic
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

signal vcc      : std_logic;
signal gnd      : std_logic_vector(13 downto 0);
signal dqs_reg, dqs_buf, dqsn_buf : std_logic;
signal dqs_oe_reg, dqs_oe_reg_n, dqs_oct_reg : std_logic; 
signal dqsn_oe_reg, dqsn_oe_reg_n, dqsn_oct_reg : std_logic;
begin
  vcc <= '1'; gnd <= (others => '0');

-- DQS output register --------------------------------------------------------------

  dqs_reg0 : stratixiii_ddio_out
    generic map(
      power_up               => "high",          
      async_mode             => "none",       
      sync_mode              => "none",
      half_rate_mode         => "false",      
      use_new_clocking_model => "false",
      lpm_type               => "stratixiii_ddio_out"
    )
    port map(
      datainlo => gnd(0),   
      datainhi => dqs,   
      clk      => clk, 
      clkhi    => clk, 
      clklo    => clk, 
      muxsel   => clk,   
      ena      => vcc,   
      areset   => gnd(0),   
      sreset   => gnd(0),   
      dataout  => dqs_reg--,   
      --dfflo    => open,   
      --dffhi    => open,    
      --devclrn  => vcc,   
      --devpor   => vcc  
    );

  pseudo_diff0 : stratixiii_pseudo_diff_out
    port map(
      i     => dqs_reg,
      o     => dqs_buf,
      obar  => dqsn_buf
    );

-- Outout enable and oct for DQS, DQSN ----------------------------------------------

  dqs_oe_reg0 : stratixiii_ddio_oe
    generic map(
      power_up    => "low",    
      async_mode  => "none",    
      sync_mode   => "none",
      lpm_type    => "stratixiii_ddio_oe"
    )
    port map(
      oe        => dqs_oe,
      clk       => clk,
      ena       => vcc,
      areset    => gnd(0),
      sreset    => gnd(0),
      dataout   => dqs_oe_reg--,
      --dfflo   => open,
      --dffhi   => open,
      --devclrn => vcc,
      --devpor  => vcc
    );
  dqs_oe_reg_n <= not dqs_oe_reg;

  dqs_oct_reg0 : stratixiii_ddio_oe
    generic map(
      power_up    => "low",    
      async_mode  => "none",    
      sync_mode   => "none",
      lpm_type    => "stratixiii_ddio_oe"
    )
    port map(
      oe        => dqs_oct,
      clk       => clk,
      ena       => vcc,
      areset    => gnd(0),
      sreset    => gnd(0),
      dataout   => dqs_oct_reg--,
      --dfflo   => open,
      --dffhi   => open,
      --devclrn => vcc,
      --devpor  => vcc
    );
  
  dqsn_oe_reg0 : stratixiii_ddio_oe
    generic map(
      power_up    => "low",    
      async_mode  => "none",    
      sync_mode   => "none",
      lpm_type    => "stratixiii_ddio_oe"
    )
    port map(
      oe        => dqs_oe,
      clk       => clk,
      ena       => vcc,
      areset    => gnd(0),
      sreset    => gnd(0),
      dataout   => dqsn_oe_reg--,
      --dfflo   => open,
      --dffhi   => open,
      --devclrn => vcc,
      --devpor  => vcc
    );
  dqsn_oe_reg_n <= not dqsn_oe_reg;

  dqsn_oct_reg0 : stratixiii_ddio_oe
    generic map(
      power_up    => "low",    
      async_mode  => "none",    
      sync_mode   => "none",
      lpm_type    => "stratixiii_ddio_oe"
    )
    port map(
      oe        => dqs_oct,
      clk       => clk,
      ena       => vcc,
      areset    => gnd(0),
      sreset    => gnd(0),
      dataout   => dqsn_oct_reg--,
      --dfflo   => open,
      --dffhi   => open,
      --devclrn => vcc,
      --devpor  => vcc
    );

-- Out buffer (DQS, DQSN) -----------------------------------------------------------

  dqs_buf0 : stratixiii_io_obuf 
    generic map(
      open_drain_output                => "false",              
      shift_series_termination_control => "false",  
      bus_hold                         => "false",              
      lpm_type                         => "stratixiii_io_obuf"
    )               
    port map(
      i                          => dqs_buf,                                                 
      oe                         => dqs_oe_reg_n,                                                 
      dynamicterminationcontrol  => gnd(0),--dqs_oct_reg,                                 
      --seriesterminationcontrol   => gnd, 
      --parallelterminationcontrol => gnd, 
      o                          => dqs_pad,                                                       
      obar                       => open
    );                                                      

  dqsn_buf0 : stratixiii_io_obuf 
    generic map(
      open_drain_output                => "false",              
      shift_series_termination_control => "false",  
      bus_hold                         => "false",              
      lpm_type                         => "stratixiii_io_obuf"
    )               
    port map(
      i                          => dqsn_buf,                                                 
      oe                         => dqsn_oe_reg_n,                                                 
      dynamicterminationcontrol  => gnd(0),--dqsn_oct_reg,                                 
      --seriesterminationcontrol   => gnd, 
      --parallelterminationcontrol => gnd, 
      o                          => dqsn_pad,                                                       
      obar                       => open
    );                                                      
end;
