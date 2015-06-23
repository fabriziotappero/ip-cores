--************************************************************************************************
-- Internal I/O registers decoder/multiplexer for the AVR core
-- Version 1.11
-- Modified 05.06.2003
-- Designed by Ruslan Lepetenok
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

use WORK.AVRuCPackage.all;

entity io_adr_dec_cm2 is port (
		cp2_cml_1 : in std_logic;
		
          adr          : in std_logic_vector(5 downto 0);         
          iore         : in std_logic;         
          dbusin_ext   : in std_logic_vector(7 downto 0);
          dbusin_int   : out std_logic_vector(7 downto 0);
                    
          spl_out      : in std_logic_vector(7 downto 0); 
          sph_out      : in std_logic_vector(7 downto 0);           
          sreg_out     : in std_logic_vector(7 downto 0);           
          rampz_out    : in std_logic_vector(7 downto 0));
end io_adr_dec_cm2;

architecture RTL of io_adr_dec_cm2 is

signal dbusin_int_cml_out :  std_logic_vector ( 7 downto 0 );
signal adr_cml_1 :  std_logic_vector ( 5 downto 0 );
signal iore_cml_1 :  std_logic;
signal dbusin_ext_cml_1 :  std_logic_vector ( 7 downto 0 );
signal spl_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal sph_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal sreg_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal rampz_out_cml_1 :  std_logic_vector ( 7 downto 0 );

begin



process(cp2_cml_1) begin
if (cp2_cml_1 = '1' and cp2_cml_1'event) then
	adr_cml_1 <= adr;
	iore_cml_1 <= iore;
	dbusin_ext_cml_1 <= dbusin_ext;
	spl_out_cml_1 <= spl_out;
	sph_out_cml_1 <= sph_out;
	sreg_out_cml_1 <= sreg_out;
	rampz_out_cml_1 <= rampz_out;
end if;
end process;
dbusin_int <= dbusin_int_cml_out;


-- SynEDA CoreMultiplier
-- assignment(s): dbusin_int
-- replace(s): adr, iore, dbusin_ext, spl_out, sph_out, sreg_out, rampz_out

dbusin_int_cml_out <= spl_out_cml_1   when (adr_cml_1=SPL_Address  and iore_cml_1='1') else
              sph_out_cml_1  when  (adr_cml_1=SPH_Address  and iore_cml_1='1') else
              sreg_out_cml_1 when  (adr_cml_1=SREG_Address  and iore_cml_1='1') else
              rampz_out_cml_1 when (adr_cml_1=RAMPZ_Address and iore_cml_1='1') else
              dbusin_ext_cml_1;

end RTL;
