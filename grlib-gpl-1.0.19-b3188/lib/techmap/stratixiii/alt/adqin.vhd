library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library stratixiii;
use stratixiii.all;

entity adqin is
  port(
    clk           : in  std_logic;
    dq_pad        : in  std_logic; -- DQ pad
    dq_h          : out std_logic;
    dq_l          : out std_logic;
    config_clk    : in  std_logic;
    config_clken  : in  std_logic;
    config_datain : in  std_logic;
    config_update : in  std_logic
  );
end;
architecture rtl of adqin is
  component stratixiii_io_ibuf is
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

  component stratixiii_ddio_in is                                                                                       
    generic(                                                                                                  
      power_up                           :  string := "low";                                            
      async_mode                         :  string := "none";                                           
      sync_mode                          :  string := "none";                                           
      use_clkn                           :  string := "false";                                          
      lpm_type                           :  string := "stratixiii_ddio_in"                                   
    );                                                                                                 
    port (                                                                                                    
      datain                  : in std_logic := '0';                                                     
      clk                     : in std_logic := '0';                                                     
      clkn                    : in std_logic := '0';                                                     
      ena                     : in std_logic := '1';                                                     
      areset                  : in std_logic := '0';                                                     
      sreset                  : in std_logic := '0';                                                     
      regoutlo                : out std_logic;                                                           
      regouthi                : out std_logic--;                                                           
      --dfflo                   : out std_logic;                                                           
      --devclrn                 : in std_logic := '1';                                                     
      --devpor                  : in std_logic := '1'                                                      
    );                                                                                                    
  end component;                                                                                            

  component  stratixiii_delay_chain
  port ( 
    datain	    : in std_logic := '0';
    dataout	    : out std_logic;
    delayctrlin : in std_logic_vector(3 downto 0) := (others => '0')
  ); 
  end component;

  component  stratixiii_io_config
  port ( 
    clk	:	in std_logic := '0';
    datain	:	in std_logic := '0';
    dataout	:	out std_logic;
    ena	:	in std_logic := '0';
    outputdelaysetting1	:	out std_logic_vector(3 downto 0);
    outputdelaysetting2	:	out std_logic_vector(2 downto 0);
    padtoinputregisterdelaysetting	:	out std_logic_vector(3 downto 0);
    update	:	in std_logic := '0'
  ); 
  end component;

signal vcc      : std_logic;
signal gnd      : std_logic_vector(13 downto 0);
signal inputdelay : std_logic_vector(3 downto 0);
signal dq_buf, dq_dly  : std_logic;
begin
  vcc <= '1'; gnd <= (others => '0');

-- In buffer (DQS, DQSN) ------------------------------------------------------------

  dq_buf0 : stratixiii_io_ibuf 
    generic map(
      differential_mode => "false",
      bus_hold          => "false",
      simulate_z_as     => "z",
      lpm_type          => "stratixiii_io_ibuf"
    )               
    port map(
      i     => dq_pad,
      ibar  => open,
      o     => dq_buf
    );                                                      

-- Input delay chain (DQ) ------------------------------------------------------------
  
  dq_delay0 : stratixiii_delay_chain
    port map(
      datain      => dq_buf,
      dataout	    => dq_dly,
      delayctrlin => inputdelay
    );
  
  dq_delay_ctrl0 : stratixiii_io_config
    port map( 
      clk     => config_clk,
      datain  => config_datain,
      dataout => open,
      ena	    => config_clken,
      outputdelaysetting1 => open,
      outputdelaysetting2 => open,
      padtoinputregisterdelaysetting  => inputdelay,
      update  => config_update
    ); 

-- Input capture register (DQ) -------------------------------------------------------

  dq_reg0 : stratixiii_ddio_in                                                                                 
    generic map(                                                                                                  
      power_up   => "low",                                            
      async_mode => "clear",                                           
      sync_mode  => "none",                                           
      use_clkn   => "false",                                          
      lpm_type   => "stratixiii_ddio_in"                                   
    )                                                                                                 
    port map(                                                                                                    
      datain    => dq_dly,--dq_buf,
      clk       => clk,
      clkn      => open,
      ena       => vcc,
      areset    => gnd(0),
      sreset    => gnd(0),
      regoutlo  => dq_l,
      regouthi  => dq_h
      --dfflo                   : out std_logic;                                                           
      --devclrn                 : in std_logic := '1';                                                     
      --devpor                  : in std_logic := '1'                                                      
    );                                                                                                    
end;
