library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library cycloneiii;
use cycloneiii.all;

entity actrlout is
  generic(
    power_up  : string := "high"
  );
  port(
    clk     : in  std_logic;
    i       : in  std_logic;
    o       : out std_logic
  );
end;
architecture rtl of actrlout is

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

signal vcc      : std_logic;
signal gnd      : std_logic_vector(13 downto 0);
signal clk_reg  : std_logic;
signal clk_buf, clk_bufn  : std_logic;
begin
  vcc <= '1'; gnd <= (others => '0');

  out_reg0 : cycloneiii_ddio_out
    generic map(
      power_up               => power_up,--"high",          
      async_mode             => "none",       
      sync_mode              => "none",
      lpm_type               => "cycloneiii_ddio_out"
    )
    port map(
      datainlo => i,   
      datainhi => i,   
      clk      => clk, 
      ena      => vcc,   
      areset   => gnd(0),   
      sreset   => gnd(0),   
      dataout  => o,   
      dfflo    => open,   
      dffhi    => open--,    
      --devclrn  => vcc,   
      --devpor   => vcc  
    );


end;
