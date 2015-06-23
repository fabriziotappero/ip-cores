library IEEE;
use ieee.std_logic_1164.all;
use work.whisk_constants.all;

-- THANKS TO SINTEF / DAG ROGNLIEN!
-- --------------------------------
-- This code is based on work by Sintef / Dag Rognlien,
-- and shall not be reused under any circumstances without
-- their permission.

entity synchronizer is
	port (
		clk : in std_logic;
		ws : in std_logic;
		wso : out std_logic
	);

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of synchronizer: entity is "yes";
    -- Do not create SRL16 for synchrnoization (not real FLIP-FLOPS)
    attribute shreg_extract : string; 
    attribute shreg_extract of synchronizer: entity is "no";
    -- Do not move logic in between the FLIP-FLOPS
    attribute register_balancing : string;
    attribute register_balancing of synchronizer: entity is "no";
    -- Do not duplicate O register 
    attribute register_duplication : string;
    attribute register_duplication of synchronizer : entity is "no";

end entity;

architecture behav of synchronizer is
begin
	clock1 : process(clk)
		variable wsflop : std_logic;
		variable syncflop : std_logic;
	begin
		if rising_edge(clk) then
			wso <= wsflop;
			wsflop := ws;
		end if;
	end process;
end architecture;
