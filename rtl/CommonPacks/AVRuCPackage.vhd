-- *****************************************************************************************
-- AVR constants and type declarations
-- Version 1.0A(Special version for the JTAG OCD)
-- Modified 05.05.2004
-- Designed by Ruslan Lepetenok
-- *****************************************************************************************

library	IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

use WORK.SynthCtrlPack.all;

package AVRuCPackage is
-- Old package
type ext_mux_din_type is array(0 to CExtMuxInSize-1) of std_logic_vector(7 downto 0);
subtype ext_mux_en_type  is std_logic_vector(0 to CExtMuxInSize-1);
-- End of old package

constant IOAdrWidth    : positive := 6;
	
type AVRIOAdr_Type is array(0 to 63) of std_logic_vector(IOAdrWidth-1 downto 0); 	
constant CAVRIOAdr : AVRIOAdr_Type :=("000000","000001","000010","000011",
                                      "000100","000101","000110","000111",
                                      "001000","001001","001010","001011",
						  "001100","001101","001110","001111",
                                      "010000","010001","010010","010011",
                                      "010100","010101","010110","010111",
                                      "011000","011001","011010","011011",
                                      "011100","011101","011110","011111",
                                      "100000","100001","100010","100011",
                                      "100100","100101","100110","100111",
                                      "101000","101001","101010","101011",
                                      "101100","101101","101110","101111",
                                      "110000","110001","110010","110011",
                                      "110100","110101","110110","110111",
                                      "111000","111001","111010","111011",
                                      "111100","111101","111110","111111");	
	
-- I/O port addresses

-- I/O register file
constant RAMPZ_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#3B#);
constant SPL_Address   : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#3D#);
constant SPH_Address   : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#3E#);
constant SREG_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(63); --16#3F#);
-- End of I/O register file

-- UART
constant UDR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#0C#);
constant UBRR_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#09#);
constant USR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#0B#);
constant UCR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#0A#);
-- End of UART	

-- Timer/Counter
constant TCCR0_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#33#);
constant TCCR1A_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#2F#);
constant TCCR1B_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#2E#);
constant TCCR2_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#25#);
constant ASSR_Address   : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#30#);
constant TIMSK_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#37#);
constant TIFR_Address   : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#36#);
constant TCNT0_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#32#);
constant TCNT2_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#24#);
constant OCR0_Address   : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#31#);
constant OCR2_Address   : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#23#);
constant TCNT1H_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#2D#);
constant TCNT1L_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#2C#);
constant OCR1AH_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#2B#);
constant OCR1AL_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#2A#);
constant OCR1BH_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#29#);
constant OCR1BL_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#28#);
constant ICR1AH_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#27#);
constant ICR1AL_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#26#);
-- End of Timer/Counter	

-- Service module
constant MCUCR_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#35#);
constant EIMSK_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#39#);
constant EIFR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#38#);
constant EICR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#3A#);
constant MCUSR_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#34#);
constant XDIV_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#3C#);
-- End of service module

-- EEPROM 
constant EEARH_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#1F#);
constant EEARL_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#1E#);
constant EEDR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#1D#);
constant EECR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#1C#);
-- End of EEPROM 

-- SPI
constant SPDR_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#0F#);
constant SPSR_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#0E#);
constant SPCR_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#0D#);
-- End of SPI

-- PORTA addresses 
constant PORTA_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#1B#);
constant DDRA_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#1A#);
constant PINA_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#19#);

-- PORTB addresses 
constant PORTB_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#18#);
constant DDRB_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#17#);
constant PINB_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#16#);

-- PORTC addresses 
constant PORTC_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#15#);

-- PORTD addresses 
constant PORTD_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#12#);
constant DDRD_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#11#);
constant PIND_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#10#);

-- PORTE addresses 
constant PORTE_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#03#);
constant DDRE_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#02#);
constant PINE_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#01#);

-- PORTF addresses
constant PINF_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#00#);

-- ******************** Parallel port address table **************************************
constant CMaxNumOfPPort : positive := 2;

type PPortAdrTbl_Type is record Port_Adr : std_logic_vector(IOAdrWidth-1 downto 0);
	                            DDR_Adr  : std_logic_vector(IOAdrWidth-1 downto 0);
	                            Pin_Adr  : std_logic_vector(IOAdrWidth-1 downto 0);
end record;

type PPortAdrTblArray_Type is array (0 to CMaxNumOfPPort-1) of PPortAdrTbl_Type;

--constant PPortAdrArray : PPortAdrTblArray_Type := ((PORTA_Address,DDRA_Address,PINA_Address),  -- PORTA
--                                                   (PORTB_Address,DDRB_Address,PINB_Address)); -- PORTB

-- ***************************************************************************************
											   
-- Analog to digital converter
constant ADCL_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#04#);
constant ADCH_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#05#);
constant ADCSR_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#06#);
constant ADMUX_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#07#);

-- Analog comparator
constant ACSR_Address  : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#08#);

-- Watchdog
constant WDTCR_Address : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#21#);

-- JTAG OCDR (ATmega128)
constant OCDR_Address   : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#22#);

-- JTAG OCDR (ATmega16)
--constant OCDR_Address   : std_logic_vector(IOAdrWidth-1 downto 0) := CAVRIOAdr(16#31#);

-- ***************************************************************************************

-- Function declaration
function LOG2(Number : positive) return natural;

end AVRuCPackage;

package	body AVRuCPackage is

-- Functions	
function LOG2(Number : positive) return natural is
variable Temp : positive;
begin
Temp := 1;
if Number=1 then 
 return 0;
  else 
   for i in 1 to integer'high loop
    Temp := 2*Temp; 
     if Temp>=Number then 
      return i;
     end if;
end loop;
end if;	
end LOG2;	
-- End of functions	

end AVRuCPackage;	
