--************************************************************************************************
--  Top entity for AVR core
--  Version 1.82? (Special version for the JTAG OCD)
--  Designed by Ruslan Lepetenok 
--  Modified 31.08.2006
--  SLEEP and CLRWDT instructions support was added
--  BREAK instructions support was added 
--  PM clock enable was added
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;


entity AVR_Core_cm3_top is port(
		
                        --Clock and reset
	                    cp2         : in  std_logic;
						cp2en       : in  std_logic;
                        ireset      : in  std_logic;
					    -- JTAG OCD support
					    valid_instr : out std_logic;
						insert_nop  : in  std_logic; 
						block_irq   : in  std_logic;
						change_flow : out std_logic;
                        -- Program Memory
                        pc          : out std_logic_vector(15 downto 0);   
                        inst        : in  std_logic_vector(15 downto 0);
                        -- I/O control
                        adr         : out std_logic_vector(5 downto 0); 	
                        iore        : out std_logic;                       
                        iowe        : out std_logic;						
                        -- Data memory control
                        ramadr      : out std_logic_vector(15 downto 0);
                        ramre       : out std_logic;
                        ramwe       : out std_logic;
						cpuwait     : in  std_logic;
						-- Data paths
                        dbusin      : in  std_logic_vector(7 downto 0);
                        dbusout     : out std_logic_vector(7 downto 0);
                        -- Interrupt
                        irqlines    : in  std_logic_vector(22 downto 0);
                        irqack      : out std_logic;
                        irqackad    : out std_logic_vector(4 downto 0);
                        --Sleep Control
                        sleepi	    : out std_logic;
                        irqok	    : out std_logic;
                        globint	    : out std_logic;
                        --Watchdog
                        wdri	    : out std_logic
						);
end AVR_Core_cm3_top;

architecture Struct of avr_core_cm3_top is

component AVR_Core_cm3 is port(
		cp2_cml_1 : in std_logic;
		cp2_cml_2 : in std_logic;

                        --Clock and reset
	                    cp2         : in  std_logic;
						cp2en       : in  std_logic;
                        ireset      : in  std_logic;
					    -- JTAG OCD support
					    valid_instr : out std_logic;
						insert_nop  : in  std_logic; 
						block_irq   : in  std_logic;
						change_flow : out std_logic;
                        -- Program Memory
                        pc          : out std_logic_vector(15 downto 0);   
                        inst        : in  std_logic_vector(15 downto 0);
                        -- I/O control
                        adr         : out std_logic_vector(5 downto 0); 	
                        iore        : out std_logic;                       
                        iowe        : out std_logic;						
                        -- Data memory control
                        ramadr      : out std_logic_vector(15 downto 0);
                        ramre       : out std_logic;
                        ramwe       : out std_logic;
						cpuwait     : in  std_logic;
						-- Data paths
                        dbusin      : in  std_logic_vector(7 downto 0);
                        dbusout     : out std_logic_vector(7 downto 0);
                        -- Interrupt
                        irqlines    : in  std_logic_vector(22 downto 0);
                        irqack      : out std_logic;
                        irqackad    : out std_logic_vector(4 downto 0);
                        --Sleep Control
                        sleepi	    : out std_logic;
                        irqok	    : out std_logic;
                        globint	    : out std_logic;
                        --Watchdog
                        wdri	    : out std_logic
						);
end component;


 
begin

AVR_Core_cm3_Inst:component AVR_Core_cm3 port map (
		cp2_cml_1 => cp2,
		cp2_cml_2 => cp2,
            -- Clock and reset
            cp2      => cp2,
		cp2en    => cp2en,
            ireset   => ireset,
		-- JTAG OCD support
		valid_instr => valid_instr,
		insert_nop  => insert_nop,
		block_irq   => block_irq,
		change_flow => change_flow,
                        -- Program Memory
                        pc  => pc, --        : out std_logic_vector(15 downto 0);   
                        inst  => inst  , --                : in  std_logic_vector(15 downto 0);
                        -- I/O control
                        adr  => adr  , --                 : out std_logic_vector(5 downto 0); 	
                        iore  => iore  , --                : out std_logic;                       
                        iowe  => iowe  , --                : out std_logic;						
                        -- Data memory control
                        ramadr  => ramadr  , --              : out std_logic_vector(15 downto 0);
                        ramre  => ramre  , --               : out std_logic;
                        ramwe  => ramwe  , --               : out std_logic;
				cpuwait  => cpuwait  , --             : in  std_logic;
				-- Data paths
                        dbusin  => dbusin  , --              : in  std_logic_vector(7 downto 0);
                        dbusout  => dbusout  , --             : out std_logic_vector(7 downto 0);
                        -- Interrupt
                        irqlines  => irqlines  , --            : in  std_logic_vector(22 downto 0);
                        irqack  => irqack  , --              : out std_logic;
                        irqackad  => irqackad  , --            : out std_logic_vector(4 downto 0);
                        --Sleep Control
                        sleepi  => sleepi  , --        	    : out std_logic;
                        irqok  => irqok  , --        	    : out std_logic;
                        globint  => globint  , --        	    : out std_logic;
                        --Watchdog
                        wdri  => wdri);

end Struct;
