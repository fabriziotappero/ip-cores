library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
--#use IEEE.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity ucecho is
   port(
      fxclk_in  : in std_logic;
      MM_A      : in std_logic_vector(15 downto 0);
      MM_D      : inout std_logic_vector(7 downto 0);
      MM_WRN    : in std_logic;
      MM_RDN    : in std_logic;
      MM_PSENN  : in std_logic
   );
end ucecho;

architecture RTL of ucecho is

--signal declaration
signal rd : std_logic := '1';
signal rd0,rd1 : std_logic := '1';
signal wr : std_logic := '1';
signal wr0,wr1 : std_logic := '1';

signal datain : std_logic_vector(7 downto 0);
signal dataout : std_logic_vector(7 downto 0);

signal fxclk : std_logic;  -- 96 MHz
signal fxclk_fb : std_logic;

begin
    -- PLL is used as clock filter
    fxclk_pll : PLLE2_BASE
    generic map (
       BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
       CLKFBOUT_MULT => 20,       -- Multiply value for all CLKOUT, (2-64)
       CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
       CLKIN1_PERIOD => 0.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
       CLKOUT0_DIVIDE => 10,
       CLKOUT1_DIVIDE => 1,
       CLKOUT2_DIVIDE => 1,
       CLKOUT3_DIVIDE => 1,
       CLKOUT4_DIVIDE => 1,
       CLKOUT5_DIVIDE => 1,
       -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
       CLKOUT0_DUTY_CYCLE => 0.5,
       CLKOUT1_DUTY_CYCLE => 0.5,
       CLKOUT2_DUTY_CYCLE => 0.5,
       CLKOUT3_DUTY_CYCLE => 0.5,
       CLKOUT4_DUTY_CYCLE => 0.5,
       CLKOUT5_DUTY_CYCLE => 0.5,
       -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
       CLKOUT0_PHASE => 0.0,
       CLKOUT1_PHASE => 0.0,
       CLKOUT2_PHASE => 0.0,
       CLKOUT3_PHASE => 0.0,
       CLKOUT4_PHASE => 0.0,
       CLKOUT5_PHASE => 0.0,
       DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
       REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
       STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
    )
    port map (
       CLKOUT0 => fxclk,
       CLKFBOUT => fxclk_fb,   -- 1-bit output: Feedback clock
       CLKIN1 => fxclk_in,     -- 1-bit input: Input clock
       PWRDWN => '0',          -- 1-bit input: Power-down
       RST => '0',             -- 1-bit input: Reset
       CLKFBIN => fxclk_fb     -- 1-bit input: Feedback clock
    );

    rd <= MM_RDN and MM_PSENN;
    wr <= MM_WRN;

    MM_D <= dataout when ((rd1 or rd0 or rd) = '0') else ( others => 'Z' );	-- enable output
    
    dpUCECHO: process(fxclk)
    begin
         if fxclk' event and fxclk = '1' then
            if (wr1 = '1') and (wr0 = '0')			-- EZ-USB write strobe
            then
        	if MM_A = conv_std_logic_vector(16#5001#,16)  	-- read data from EZ-USB if addr=0x5001
        	then
        	    datain <= MM_D;
        	end if;
    	    elsif (rd1 = '1') and (rd0 = '0')			-- EZ-USB read strobe
    	    then
        	if MM_A = conv_std_logic_vector(16#5002#,16)	-- write data to EZ-USB if addr=0x5002
        	then
		    if ( datain >= conv_std_logic_vector(97,8) ) and ( datain <= conv_std_logic_vector(122,8) )	-- do the upercase conversion
		    then
			dataout <= datain - conv_std_logic_vector(32,8);
		    else
			dataout <= datain ;
		    end if;
        	end if;
    	    end if;
    	    
    	    rd0 <= rd;
    	    rd1 <= rd0;
    	    wr0 <= wr;
    	    wr1 <= wr0;
	end if;
    end process dpUCECHO;
    
end RTL;
