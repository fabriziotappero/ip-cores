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

entity admout is
  port(
    clk       : in  std_logic; -- clk0
    dm_h      : in  std_logic;
    dm_l      : in  std_logic;
    dm_pad    : out std_logic  -- DQ pad
  );
end;
architecture rtl of admout is

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
signal dm_reg   : std_logic;
begin
  vcc <= '1'; gnd <= (others => '0');

-- DM output register --------------------------------------------------------------

  dm_reg0 : stratixiii_ddio_out
    generic map(
      power_up               => "high",          
      async_mode             => "none",       
      sync_mode              => "none",
      half_rate_mode         => "false",      
      use_new_clocking_model => "true",
      lpm_type               => "stratixiii_ddio_out"
    )
    port map(
      datainlo => dm_l,   
      datainhi => dm_h,   
      clk      => clk, 
      clkhi    => clk, 
      clklo    => clk, 
      muxsel   => clk,   
      ena      => vcc,   
      areset   => gnd(0),   
      sreset   => gnd(0),   
      dataout  => dm_reg--,   
      --dfflo    => open,   
      --dffhi    => open,    
      --devclrn  => vcc,   
      --devpor   => vcc  
    );

-- Out buffer (DM) ------------------------------------------------------------------

  dm_buf0 : stratixiii_io_obuf 
    generic map(
      open_drain_output                => "false",              
      shift_series_termination_control => "false",  
      bus_hold                         => "false",              
      lpm_type                         => "stratixiii_io_obuf"
    )               
    port map(
      i                          => dm_reg,                                                 
      oe                         => vcc,                                                 
      dynamicterminationcontrol  => gnd(0),                                 
      --seriesterminationcontrol   => gnd, 
      --parallelterminationcontrol => gnd, 
      o                          => dm_pad,                                                       
      obar                       => open
    );                                                      
end;
