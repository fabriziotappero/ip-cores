library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
--#use IEEE.numeric_std.all;


entity ucecho is
   port(
      FXCLK     : in std_logic;
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
signal rd_prev : std_logic := '1';
signal wr : std_logic := '1';
signal wr_prev : std_logic := '1';

signal datain : std_logic_vector(7 downto 0);
signal dataout : std_logic_vector(7 downto 0);

begin
    rd <= MM_RDN and MM_PSENN;
    wr <= MM_WRN;

    MM_D <= dataout when ((rd_prev or rd) = '0') else ( others => 'Z' );	-- enable output
    
    dpUCECHO: process(FXCLK)
    begin
         if FXCLK' event and FXCLK = '1' then
            if (wr_prev = '1') and (wr = '0')			-- EZ-USB write strobe
            then
        	if MM_A = conv_std_logic_vector(16#5001#,16)  	-- read data from EZ-USB if addr=0x5001
        	then
        	    datain <= MM_D;
        	end if;
    	    elsif (rd_prev = '1') and (rd = '0')		-- EZ-USB read strobe
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
    	    
    	    rd_prev <= rd;
    	    wr_prev <= wr;
	end if;
    end process dpUCECHO;
    
end RTL;
