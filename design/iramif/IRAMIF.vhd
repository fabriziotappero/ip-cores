-------------------------------------------------------------------------------
-- File Name : IRamIF.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : IRamIF
--
-- Content   : IMAGE RAM Interface
--
-- Description : 
--
-- Spec.     : 
--
-- Author    : Michal Krepa
--
-------------------------------------------------------------------------------
-- History :
-- 20090301: (MK): Initial Creation.
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity IRamIF is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;

        -- IMAGE RAM
        iram_addr          : out std_logic_vector(19 downto 0);
        iram_rdata         : in  std_logic_vector(23 downto 0);
                           
        -- FDCT            
        jpg_iram_rden      : in  std_logic;
        jpg_iram_rdaddr    : in  std_logic_vector(31 downto 0);
        jpg_iram_data      : out std_logic_vector(23 downto 0)
    );
end entity IRamIF;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of IRamIF is

  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin
  
  jpg_iram_data  <= iram_rdata;
  
  -------------------------------------------------------------------
  -- 
  -------------------------------------------------------------------
  p_if : process(CLK, RST)
  begin
    if RST = '1' then
      iram_addr   <= (others => '0');
    elsif CLK'event and CLK = '1' then
      -- host has access
      iram_addr   <= jpg_iram_rdaddr(iram_addr'range);
    end if;
  end process;
  

end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------