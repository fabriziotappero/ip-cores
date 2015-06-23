------------------------------------------------------------------- 
--                                                               --
--  Copyright (C) 2013 Author and VariStream Studio              --
--  Author : Yu Peng                                             --
--                                                               -- 
--  This source file may be used and distributed without         -- 
--  restriction provided that this copyright statement is not    -- 
--  removed from the file and that any derivative work contains  -- 
--  the original copyright notice and the associated disclaimer. -- 
--                                                               -- 
--  This source file is free software; you can redistribute it   -- 
--  and/or modify it under the terms of the GNU Lesser General   -- 
--  Public License as published by the Free Software Foundation; -- 
--  either version 2.1 of the License, or (at your option) any   -- 
--  later version.                                               -- 
--                                                               -- 
--  This source is distributed in the hope that it will be       -- 
--  useful, but WITHOUT ANY WARRANTY; without even the implied   -- 
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      -- 
--  PURPOSE.  See the GNU Lesser General Public License for more -- 
--  details.                                                     -- 
--                                                               -- 
--  You should have received a copy of the GNU Lesser General    -- 
--  Public License along with this source; if not, download it   -- 
--  from http://www.opencores.org/lgpl.shtml                     -- 
--                                                               -- 
------------------------------------------------------------------- 
--  Description:
--      Simple dual-port RAM in read-first mode with output 
--      register.
--      This block infers block RAM or distribute RAM according 
--      to value of gADDRESS_WIDTH and gDATA_WIDTH.
--  NOTE: 
--      Reset is on data output ONLY.
--      This requirement follows the XST User Guide to synthesize
--      into BRAM.
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sdpram_infer_read_first_outreg is
    generic (
        gADDRESS_WIDTH : integer := 5;
        gDATA_WIDTH : integer := 24
        );
    port (
        iClk : in std_logic;
        iReset_sync : in std_logic;
        iWe : in std_logic;
        ivWrAddr : in std_logic_vector(gADDRESS_WIDTH-1 downto 0);
		ivRdAddr : in std_logic_vector(gADDRESS_WIDTH-1 downto 0);
        ivDataIn : in std_logic_vector(gDATA_WIDTH-1 downto 0);
        ovDataOut : out std_logic_vector(gDATA_WIDTH-1 downto 0)
        );
end sdpram_infer_read_first_outreg;

architecture behavioral of sdpram_infer_read_first_outreg is
    -- Output register
    signal svDataOut : std_logic_vector (gDATA_WIDTH-1 downto 0) := (others => '0');

    -- RAM addressable data array
    type   tRAM is array (2**gADDRESS_WIDTH-1 downto 0) of std_logic_vector (gDATA_WIDTH-1 downto 0);
    signal svRAM : tRAM := (others => (others => '0'));

begin
    ovDataOut <= svDataOut;
    process (iClk)
    begin
        if iClk'event and iClk = '1' then
            if iWE = '1' then
                svRAM(conv_integer(ivWrAddr)) <= ivDataIn;
            end if;
			
			svDataOut <= svRAM(conv_integer(ivRdAddr));
        end if;
    end process;
end behavioral;
