--************************************************************************************************
-- Internal I/O registers (implemented inside the core) decoder/multiplexer 
-- for AVR core
-- Version 1.3 (Special version for the JTAG OCD)
-- Designed by Ruslan Lepetenok
-- Modified 22.04.2004
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use WORK.AVRuCPackage.all;

entity io_reg_file_cm3 is port (
		cp2_cml_1 : in std_logic;
		cp2_cml_2 : in std_logic;
		
		                    --Clock and reset
	                        cp2           : in std_logic;
							cp2en         : in std_logic;
                            ireset        : in std_logic;

                            adr           : in std_logic_vector(5 downto 0);         
                            iowe          : in std_logic;         
                            dbusout       : in std_logic_vector(7 downto 0);         

                            sreg_fl_in    : in std_logic_vector(7 downto 0);         
                            sreg_out      : out std_logic_vector(7 downto 0);         

                            sreg_fl_wr_en : in  std_logic_vector (7 downto 0);   --FLAGS WRITE ENABLE SIGNALS       

                            spl_out       : out std_logic_vector(7 downto 0);         
                            sph_out       : out std_logic_vector(7 downto 0);         
                            sp_ndown_up   : in std_logic; -- DIRECTION OF CHANGING OF STACK POINTER SPH:SPL 0->UP(+) 1->DOWN(-)
                            sp_en         : in std_logic; -- WRITE ENABLE(COUNT ENABLE) FOR SPH AND SPL REGISTERS
  
                            rampz_out    : out std_logic_vector(7 downto 0));
end io_reg_file_cm3;

architecture rtl of io_reg_file_cm3 is
signal sreg    : std_logic_vector(7 downto 0);
signal sph     : std_logic_vector(7 downto 0);
signal spl     : std_logic_vector(7 downto 0);
signal rampz   : std_logic_vector(7 downto 0);

signal sp_int  : std_logic_vector(15 downto 0);
signal sp_intp : std_logic_vector(15 downto 0);
signal sp_intm : std_logic_vector(15 downto 0);
signal sp_res : std_logic_vector(15 downto 0);


signal adr_cml_2 :  std_logic_vector ( 5 downto 0 );
signal sreg_cml_2 :  std_logic_vector ( 7 downto 0 );
signal sreg_cml_1 :  std_logic_vector ( 7 downto 0 );
signal sph_out_cml_out :  std_logic_vector ( 7 downto 0 );
signal sph_cml_2 :  std_logic_vector ( 7 downto 0 );
signal sph_cml_1 :  std_logic_vector ( 7 downto 0 );
signal spl_out_cml_out :  std_logic_vector ( 7 downto 0 );
signal spl_cml_2 :  std_logic_vector ( 7 downto 0 );
signal spl_cml_1 :  std_logic_vector ( 7 downto 0 );
signal rampz_out_cml_out :  std_logic_vector ( 7 downto 0 );
signal rampz_cml_2 :  std_logic_vector ( 7 downto 0 );
signal rampz_cml_1 :  std_logic_vector ( 7 downto 0 );

begin



process(cp2_cml_1) begin
if (cp2_cml_1 = '1' and cp2_cml_1'event) then
	sreg_cml_1 <= sreg;
	sph_cml_1 <= sph;
	spl_cml_1 <= spl;
	rampz_cml_1 <= rampz;
end if;
end process;

process(cp2_cml_2) begin
if (cp2_cml_2 = '1' and cp2_cml_2'event) then
	adr_cml_2 <= adr;
	sreg_cml_2 <= sreg_cml_1;
	sph_cml_2 <= sph_cml_1;
	spl_cml_2 <= spl_cml_1;
	rampz_cml_2 <= rampz_cml_1;
end if;
end process;
sph_out <= sph_out_cml_out;
spl_out <= spl_out_cml_out;
rampz_out <= rampz_out_cml_out;


-- SynEDA CoreMultiplier
-- assignment(s): sreg
-- replace(s): adr, sreg

sreg_write:process(cp2,ireset)
begin
if ireset='0' then 
sreg <= (others => '0');
elsif (cp2='1' and cp2'event) then sreg <= sreg_cml_2;
 if (cp2en='1') then 							  -- Clock enable	
  for i in sreg'range loop  
   if (sreg_fl_wr_en(i)='1' or (adr_cml_2=SREG_Address and iowe='1')) then    -- CLOCK ENABLE
    if iowe='1' then 
     sreg(i) <= dbusout(i);                        -- FROM THE INTERNAL DATA BUS
    else
     sreg(i) <= sreg_fl_in(i);                  -- FROM ALU FLAGS
    end if;
   end if;
  end loop;
 end if; 
end if;
end process;

sreg_out <= sreg;


-- SynEDA CoreMultiplier
-- assignment(s): sp_intp
-- replace(s): sph, spl

sp_intp<=(sph_cml_2&spl_cml_2)+1;
-- SynEDA CoreMultiplier
-- assignment(s): sp_intm
-- replace(s): sph, spl

sp_intm<=(sph_cml_2&spl_cml_2)-1;
sp_res<= sp_intm when sp_ndown_up='0' else sp_intp;

-- SynEDA CoreMultiplier
-- assignment(s): spl
-- replace(s): adr, spl

spl_write:process(cp2,ireset)
begin
if ireset='0' then 
spl <= (others => '0');
elsif (cp2='1' and cp2'event) then spl <= spl_cml_2;
if (sp_en='1' or (adr_cml_2=SPL_Address and iowe='1')) then    -- CLOCK ENABLE
 if iowe='1' then 
  spl <= dbusout;                                        -- FROM THE INTERNAL DATA BUS
   else
    spl <= sp_res(7 downto 0);                          -- FROM SPL BUS
     end if;
 end if;

end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): spl_out
-- replace(s): spl

spl_out_cml_out <= spl_cml_1;

-- SynEDA CoreMultiplier
-- assignment(s): sph
-- replace(s): adr, sph

sph_write:process(cp2,ireset)
begin
if ireset='0' then 
sph <= (others => '0');
elsif (cp2='1' and cp2'event) then sph <= sph_cml_2;
if (sp_en='1' or (adr_cml_2=SPH_Address and iowe='1')) then    -- CLOCK ENABLE
 if iowe='1' then 
  sph <= dbusout;                        -- FROM THE INTERNAL DATA BUS
   else
    sph <= sp_res(15 downto 8);                          -- FROM SPH BUS
     end if;
 end if;

end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): sph_out
-- replace(s): sph

sph_out_cml_out <= sph_cml_1;


-- SynEDA CoreMultiplier
-- assignment(s): rampz
-- replace(s): adr, rampz

rampz_write:process(cp2,ireset)
begin
if ireset='0' then 
rampz <= (others => '0');
elsif (cp2='1' and cp2'event) then rampz <= rampz_cml_2;
if (adr_cml_2=RAMPZ_Address and iowe='1') then    -- CLOCK ENABLE
  rampz <= dbusout;                      -- FROM THE INTERNAL DATA BUS
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): rampz_out
-- replace(s): rampz

rampz_out_cml_out <= rampz_cml_1;

end rtl;
