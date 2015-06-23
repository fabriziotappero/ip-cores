library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library stratixiii;
use stratixiii.all;

entity adqsin is
  port(
    dqs_pad   : in  std_logic; -- DQS pad
    dqsn_pad  : in  std_logic; -- DQSN pad
    dqs       : out std_logic
  );
end;
architecture rtl of adqsin is
  component stratixiii_io_ibuf IS
    generic (
      differential_mode       :  string := "false";
      bus_hold                :  string := "false";
      simulate_z_as           :  string    := "z";
      lpm_type                :  string := "stratixiii_io_ibuf"
    );    
    port (
      i                       : in std_logic := '0';   
      ibar                    : in std_logic := '0';   
      o                       : out std_logic
    );       
  end component;

signal vcc      : std_logic;
signal gnd      : std_logic_vector(13 downto 0);
signal dqs_buf  : std_logic;
begin
  vcc <= '1'; gnd <= (others => '0');

-- In buffer (DQS, DQSN) ------------------------------------------------------------

  dqs_buf0 : stratixiii_io_ibuf 
    generic map(
      differential_mode => "true",
      bus_hold          => "false",
      simulate_z_as     => "z",
      lpm_type          => "stratixiii_io_ibuf"
    )               
    port map(
      i     => dqs_pad,
      ibar  => dqsn_pad,
      o     => dqs_buf
    );                                                      

  dqs <= dqs_buf;

end;
