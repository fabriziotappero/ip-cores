library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity intraffic is
    port(
        RESET         : in std_logic;
        CS            : in std_logic;
        CONT          : in std_logic;
        IFCLK         : in std_logic;

        FD            : out std_logic_vector(15 downto 0); 

        SLOE          : out std_logic;
        SLRD          : out std_logic;
        SLWR          : out std_logic;
        FIFOADR0      : out std_logic;
        FIFOADR1      : out std_logic;
        PKTEND        : out std_logic;

        FLAGB         : in std_logic
        
--        SCL	      : in std_logic;
--        SDA	      : in std_logic
    );
end intraffic;

architecture RTL of intraffic is

----------------------------
-- test pattern generator --
----------------------------
-- 30 bit counter
signal GEN_CNT : std_logic_vector(29 downto 0);
signal INT_CNT : std_logic_vector(6 downto 0);

signal FIFO_WORD : std_logic;
signal SLWR_R : std_logic;
signal FD_R : std_logic_vector(15 downto 0); 

begin
    
    SLOE <= '1' when CS = '1' else 'Z';
    SLRD <= '1' when CS = '1' else 'Z';
    SLWR <= SLWR_R when CS = '1' else 'Z';
    FIFOADR0 <= '0' when CS = '1' else 'Z';
    FIFOADR1 <= '0' when CS = '1' else 'Z';
    PKTEND <= '1' when CS = '1' else 'Z';		-- no data alignment
    FD <= FD_R when CS = '1' else (others => 'Z');
    
    dpIFCLK: process (IFCLK, RESET)
    begin
-- reset
        if RESET = '1' 
	then
	    GEN_CNT <= ( others => '0' );
	    INT_CNT <= ( others => '0' );
	    FIFO_WORD <= '0';
	    SLWR_R <= '1';
-- IFCLK
        elsif IFCLK'event and IFCLK = '1' 
	then

	    if CONT = '1' or FLAGB = '1'
	    then
		if FIFO_WORD = '0'
		then
		    FD_R(14 downto 0) <= GEN_CNT(14 downto 0);
		else
		    FD_R(14 downto 0) <= GEN_CNT(29 downto 15);
		end if;
		FD_R(15) <= FIFO_WORD;

		if FIFO_WORD = '1'
		then
		    GEN_CNT <= GEN_CNT + '1';
		    if INT_CNT = conv_std_logic_vector(99,7)
		    then 
			INT_CNT <= ( others => '0' );
		    else		    
			INT_CNT <= INT_CNT + '1';
		    end if;
		end if;
		FIFO_WORD <= not FIFO_WORD;
	    end if;
	    
    	    if ( INT_CNT >= conv_std_logic_vector(90,7) ) and ( CONT = '0' )
	    then
	        SLWR_R <= '1';
	    else
	        SLWR_R <= '0';
	    end if;
	    
	end if;
    end process dpIFCLK;

end RTL;
