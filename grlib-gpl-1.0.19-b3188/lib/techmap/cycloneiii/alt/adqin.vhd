library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library cycloneiii;
use cycloneiii.all;
library altera_mf;
use altera_mf.all;

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
  component cycloneiii_io_ibuf is
    generic (
      differential_mode       :  string := "false";
      bus_hold                :  string := "false";
      lpm_type                :  string := "cycloneiii_io_ibuf"
    );    
    port (
      i                       : in std_logic := '0';   
      ibar                    : in std_logic := '0';   
      o                       : out std_logic
    );       
  end component;

	component altddio_in
	generic (
		intended_device_family		: string;
		invert_input_clocks		: string;
		lpm_type		: string;
		power_up_high		: string;
		width		: natural
	);
	port (
			datain	: in std_logic_vector (0 downto 0);
			inclock	: in std_logic ;
			dataout_h	: out std_logic_vector (0 downto 0);
			dataout_l	: out std_logic_vector (0 downto 0)
	);
	end component;

signal vcc      : std_logic;
signal gnd      : std_logic_vector(13 downto 0);
signal inputdelay : std_logic_vector(3 downto 0);
signal dq_buf, dq_h_tmp, dq_l_tmp  : std_logic_vector(0 downto 0);
begin
  vcc <= '1'; gnd <= (others => '0');

-- In buffer (DQ) --------------------------------------------------------------------

  dq_buf0 : cycloneiii_io_ibuf 
    generic map(
      differential_mode => "false",
      bus_hold          => "false",
      lpm_type          => "cycloneiii_io_ibuf"
    )               
    port map(
      i     => dq_pad,
      ibar  => open,
      o     => dq_buf(0)
    );                                                      

-- Input capture register (DQ) -------------------------------------------------------

	altddio_in_component : altddio_in
	generic map (
		intended_device_family => "Cyclone III",
		invert_input_clocks => "off",
		lpm_type => "altddio_in",
		power_up_high => "off",
		width => 1
	)
	port map (
		datain => dq_buf,
		inclock => clk,
		dataout_h => dq_h_tmp,
		dataout_l => dq_l_tmp
	);
  
  dq_h <= dq_h_tmp(0); dq_l <= dq_l_tmp(0);

--  dq_reg0 : cycloneiii_ddio_in                                                                                 
--    generic map(                                                                                                  
--      power_up   => "low",                                            
--      async_mode => "clear",                                           
--      sync_mode  => "none",                                           
--      use_clkn   => "false",                                          
--      lpm_type   => "cycloneiii_ddio_in"                                   
--    )                                                                                                 
--    port map(                                                                                                    
--      datain    => dq_dq_buf,
--      clk       => clk,
--      clkn      => open,
--      ena       => vcc,
--      areset    => gnd(0),
--      sreset    => gnd(0),
--      regoutlo  => dq_l,
--      regouthi  => dq_h
--      --dfflo                   : out std_logic;                                                           
--      --devclrn                 : in std_logic := '1';                                                     
--      --devpor                  : in std_logic := '1'                                                      
--    );                                                                                                    
end;
