library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity intraffic is
    port(
        RESET         : in std_logic;
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

begin
    
    SLOE <= '1';
    SLRD <= '1';
    FIFOADR0 <= '0';
    FIFOADR1 <= '0';
    PKTEND <= '1';		-- no data alignment

    dpIFCLK: process (IFCLK, RESET)
    begin
-- reset
        if RESET = '1' 
	then
	    GEN_CNT <= ( others => '0' );
	    INT_CNT <= ( others => '0' );
	    FIFO_WORD <= '0';
	    SLWR <= '1';
-- IFCLK
        elsif IFCLK'event and IFCLK = '1' 
	then

	    if CONT = '1' or FLAGB = '1'
	    then
		if FIFO_WORD = '0'
		then
		    FD(14 downto 0) <= GEN_CNT(14 downto 0);
		else
		    FD(14 downto 0) <= GEN_CNT(29 downto 15);
		end if;
		FD(15) <= FIFO_WORD;

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
	        SLWR <= '1';
	    else
	        SLWR <= '0';
	    end if;
	    
	end if;
    end process dpIFCLK;

end RTL;
