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

entity io_reg_file is port (
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
end io_reg_file;

architecture rtl of io_reg_file is
signal sreg    : std_logic_vector(7 downto 0);
signal sph     : std_logic_vector(7 downto 0);
signal spl     : std_logic_vector(7 downto 0);
signal rampz   : std_logic_vector(7 downto 0);

signal sp_int  : std_logic_vector(15 downto 0);
signal sp_intp : std_logic_vector(15 downto 0);
signal sp_intm : std_logic_vector(15 downto 0);
signal sp_res : std_logic_vector(15 downto 0);


begin

sreg_write:process(cp2,ireset)
begin
if ireset='0' then 
sreg <= (others => '0');
elsif (cp2='1' and cp2'event) then
 if (cp2en='1') then 							  -- Clock enable	
  for i in sreg'range loop  
   if (sreg_fl_wr_en(i)='1' or (adr=SREG_Address and iowe='1')) then    -- CLOCK ENABLE
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


sp_intp<=(sph&spl)+1;
sp_intm<=(sph&spl)-1;
sp_res<= sp_intm when sp_ndown_up='0' else sp_intp;

spl_write:process(cp2,ireset)
begin
if ireset='0' then 
spl <= (others => '0');
elsif (cp2='1' and cp2'event) then
if (sp_en='1' or (adr=SPL_Address and iowe='1')) then    -- CLOCK ENABLE
 if iowe='1' then 
  spl <= dbusout;                                        -- FROM THE INTERNAL DATA BUS
   else
    spl <= sp_res(7 downto 0);                          -- FROM SPL BUS
     end if;
 end if;

end if;
end process;

spl_out <= spl;

sph_write:process(cp2,ireset)
begin
if ireset='0' then 
sph <= (others => '0');
elsif (cp2='1' and cp2'event) then
if (sp_en='1' or (adr=SPH_Address and iowe='1')) then    -- CLOCK ENABLE
 if iowe='1' then 
  sph <= dbusout;                        -- FROM THE INTERNAL DATA BUS
   else
    sph <= sp_res(15 downto 8);                          -- FROM SPH BUS
     end if;
 end if;

end if;
end process;

sph_out <= sph;


rampz_write:process(cp2,ireset)
begin
if ireset='0' then 
rampz <= (others => '0');
elsif (cp2='1' and cp2'event) then
if (adr=RAMPZ_Address and iowe='1') then    -- CLOCK ENABLE
  rampz <= dbusout;                      -- FROM THE INTERNAL DATA BUS
 end if;
end if;
end process;

rampz_out <= rampz;

end rtl;
