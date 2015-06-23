library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library cycloneiii;
use cycloneiii.all;

entity aclkout is
  port(
    clk     : in  std_logic;
    ddr_clk : out std_logic;
    ddr_clkn: out std_logic
  );
end;
architecture rtl of aclkout is

component cycloneiii_ddio_out 
  generic(
    power_up                           :  string := "low";          
    async_mode                         :  string := "none";       
    sync_mode                          :  string := "none";
    lpm_type                           :  string := "cycloneiii_ddio_out"
  );
  port (
    datainlo                : in std_logic := '0';   
    datainhi                : in std_logic := '0';   
    clk                     : in std_logic := '0'; 
    ena                     : in std_logic := '1';   
    areset                  : in std_logic := '0';   
    sreset                  : in std_logic := '0';   
    dataout                 : out std_logic;         
    dfflo                   : out std_logic;         
    dffhi                   : out std_logic-- ;         
    --devclrn                 : in std_logic := '1';   
    --devpor                  : in std_logic := '1'   
  );   
end component;

component  cycloneiii_io_obuf
  generic(
    bus_hold	:	string := "false";
    open_drain_output	:	string := "false";
    lpm_type	:	string := "cycloneiii_io_obuf"
  );
  port( 
    i	:	in std_logic := '0';
    oe	:	in std_logic := '1';
    --devoe : in std_logic := '1';
    o	:	out std_logic;
    obar	:	out std_logic--;
    --seriesterminationcontrol	:	in std_logic_vector(15 downto 0) := (others => '0')
  ); 
end component;

signal vcc      : std_logic;
signal gnd      : std_logic_vector(13 downto 0);
signal clk_reg, clkn_reg  : std_logic;
begin
  vcc <= '1'; gnd <= (others => '0');

  out_reg0 : cycloneiii_ddio_out
    generic map(
      power_up               => "low",          
      async_mode             => "none",       
      sync_mode              => "none",
      lpm_type               => "cycloneiii_ddio_out"
    )
    port map(
      datainlo => gnd(0),   
      datainhi => vcc,   
      clk      => clk, 
      ena      => vcc,   
      areset   => gnd(0),   
      sreset   => gnd(0),   
      dataout  => clk_reg,   
      dfflo    => open,   
      dffhi    => open--,    
      --devclrn  => vcc,   
      --devpor   => vcc  
    );
  
  outn_reg0 : cycloneiii_ddio_out
    generic map(
      power_up               => "low",          
      async_mode             => "none",       
      sync_mode              => "none",
      lpm_type               => "cycloneiii_ddio_out"
    )
    port map(
      datainlo => vcc,   
      datainhi => gnd(0),   
      clk      => clk, 
      ena      => vcc,   
      areset   => gnd(0),   
      sreset   => gnd(0),   
      dataout  => clkn_reg,   
      dfflo    => open,   
      dffhi    => open--,    
      --devclrn  => vcc,   
      --devpor   => vcc  
    );

  out_buf0 : cycloneiii_io_obuf 
    generic map(
      open_drain_output                => "false",              
      bus_hold                         => "false",              
      lpm_type                         => "cycloneiii_io_obuf"
    )               
    port map(
      i                          => clk_reg,                                                 
      oe                         => vcc,                                                 
      --devoe                      => vcc,
      o                          => ddr_clk,                                                       
      obar                       => open
      --seriesterminationcontrol   => gnd, 
    );                                                      
  
  outn_buf0 : cycloneiii_io_obuf 
    generic map(
      open_drain_output                => "false",              
      bus_hold                         => "false",              
      lpm_type                         => "cycloneiii_io_obuf"
    )               
    port map(
      i                          => clkn_reg,                                                 
      oe                         => vcc,                                                 
      --devoe                      => vcc,
      o                          => ddr_clkn,                                                       
      obar                       => open
      --seriesterminationcontrol   => gnd, 
    );                                                      

end;
