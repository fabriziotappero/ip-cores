--************************************************************************************************
-- Internal I/O registers decoder/multiplexer for the AVR core
-- Version 1.11
-- Modified 05.06.2003
-- Designed by Ruslan Lepetenok
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

use WORK.AVRuCPackage.all;

entity io_adr_dec_cm4 is port (
		cp2_cml_1 : in std_logic;
		cp2_cml_2 : in std_logic;
		
          adr          : in std_logic_vector(5 downto 0);         
          iore         : in std_logic;         
          dbusin_ext   : in std_logic_vector(7 downto 0);
          dbusin_int   : out std_logic_vector(7 downto 0);
                    
          spl_out      : in std_logic_vector(7 downto 0); 
          sph_out      : in std_logic_vector(7 downto 0);           
          sreg_out     : in std_logic_vector(7 downto 0);           
          rampz_out    : in std_logic_vector(7 downto 0));
end io_adr_dec_cm4;

architecture RTL of io_adr_dec_cm4 is

signal dbusin_int_cml_out :  std_logic_vector ( 7 downto 0 );
signal dbusin_ext_cml_2 :  std_logic_vector ( 7 downto 0 );
signal dbusin_ext_cml_1 :  std_logic_vector ( 7 downto 0 );
signal spl_out_cml_2 :  std_logic_vector ( 7 downto 0 );
signal sph_out_cml_2 :  std_logic_vector ( 7 downto 0 );
signal sreg_out_cml_2 :  std_logic_vector ( 7 downto 0 );
signal sreg_out_cml_1 :  std_logic_vector ( 7 downto 0 );

begin



process(cp2_cml_1) begin
if (cp2_cml_1 = '1' and cp2_cml_1'event) then
	dbusin_ext_cml_1 <= dbusin_ext;
	sreg_out_cml_1 <= sreg_out;
end if;
end process;

process(cp2_cml_2) begin
if (cp2_cml_2 = '1' and cp2_cml_2'event) then
	dbusin_ext_cml_2 <= dbusin_ext_cml_1;
	spl_out_cml_2 <= spl_out;
	sph_out_cml_2 <= sph_out;
	sreg_out_cml_2 <= sreg_out_cml_1;
end if;
end process;
dbusin_int <= dbusin_int_cml_out;


-- SynEDA CoreMultiplier
-- assignment(s): dbusin_int
-- replace(s): dbusin_ext, spl_out, sph_out, sreg_out

dbusin_int_cml_out <= spl_out_cml_2   when (adr=SPL_Address  and iore='1') else
              sph_out_cml_2  when  (adr=SPH_Address  and iore='1') else
              sreg_out_cml_2 when  (adr=SREG_Address  and iore='1') else
              rampz_out when (adr=RAMPZ_Address and iore='1') else
              dbusin_ext_cml_2;

end RTL;
