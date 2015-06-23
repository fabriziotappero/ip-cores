------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2004, Hangouet Samuel                                         --
--                  , Jan Sebastien                                               --
--                  , Mouton Louis-Marie                                          --
--                  , Schneider Olivier     all rights reserved                   --
--                                                                                --
--    This file is part of miniMIPS.                                              --
--                                                                                --
--    miniMIPS is free software; you can redistribute it and/or modify            --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    miniMIPS is distributed in the hope that it will be useful,                 --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with miniMIPS; if not, write to the Free Software                     --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------


-- If you encountered any problem, please contact :
--
--   lmouton@enserg.fr
--   oschneid@enserg.fr
--   shangoue@enserg.fr
--



--------------------------------------------------------------------------
--                                                                      --
--                                                                      --
--             miniMIPS Processor : bus controler                       --
--                                                                      --
--                                                                      --
--                                                                      --
-- Authors : Hangouet  Samuel                                           --
--           Jan       Sébastien                                        --
--           Mouton    Louis-Marie                                      --
--           Schneider Olivier                                          --
--                                                                      --
--                                                          june 2003   --
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pack_mips.all;

entity bus_ctrl is
port
(
    clock : std_logic;
    reset : std_logic;

    -- Interruption in the pipeline
    interrupt      : in std_logic;

    -- Interface for the Instruction Extraction Stage
    adr_from_ei    : in bus32;      -- The address of the data to read
    instr_to_ei    : out bus32;     -- Instruction from the memory

    -- Interface with the MEMory Stage
    req_from_mem   : in std_logic;  -- Request to access the ram
    r_w_from_mem   : in std_logic;  -- Read/Write request
    adr_from_mem   : in bus32;      -- Address in ram
    data_from_mem  : in bus32;      -- Data to write in ram
    data_to_mem    : out bus32;     -- Data from the ram to the MEMory stage

    -- RAM interface signals
    req_to_ram     : out std_logic;  -- Request to ram
    adr_to_ram     : out bus32;     -- Address of the data to read or write
    r_w_to_ram     : out std_logic; -- Read/Write request
    ack_from_ram   : in std_logic;  -- Acknowledge from the memory
    data_inout_ram : inout bus32;   -- Data from/to the memory

    -- Pipeline progress control signal
    stop_all       : out std_logic
);
end bus_ctrl;


architecture rtl of bus_ctrl is

    type ctrl_state is ( ST1, ST2 );
    signal cs, ns : ctrl_state;
    signal ei_buffer : bus32;       -- Buffer storing the data for EI

    signal r_w : std_logic;         -- Current utilisation of the tristate bus
    signal data_in : bus32;         -- Data read on the tristate bus
    signal req_allowed : std_logic;

begin

    -- Read/write on the tristate bus
    process (r_w, data_from_mem, data_inout_ram)
    begin
        r_w_to_ram <= r_w;
        if r_w='0' then -- Reads bus
            data_inout_ram <= (others => 'Z');
            data_in <= data_inout_ram;
        else            -- Writing of the data from the MEM stage
            data_inout_ram <= data_from_mem;
            data_in <= (others => '0');
        end if;
    end process;

    process (clock)
    begin
        if clock='1' and clock'event then
            if reset='1' then
                cs <= ST1;
                ei_buffer <= (others => '0');
            else
                if cs=ST1 then
                    -- Storing of the data to send to EI stage
                    ei_buffer <= data_in;
                end if;

                cs <= ns;
            end if;
        end if;
    end process;

    process (clock, ack_from_ram)
    begin
        if ack_from_ram = '0' then
            req_allowed <= '0';
        elsif clock='1' and clock'event then
            if ack_from_ram = '1' then
                req_allowed <= '1';
            end if;
        end if;
    end process;

    process (req_allowed, ack_from_ram)
    begin
        if req_allowed = '1' then
            req_to_ram <= '1';
        elsif ack_from_ram = '0' then
            req_to_ram <= '1';
        else
            req_to_ram <= '0';
        end if;
    end process;
    
    process (cs, interrupt, adr_from_ei, req_from_mem, r_w_from_mem, adr_from_mem, ack_from_ram)
    begin
        if interrupt = '1' then -- An interruption is detected
            ns <= ST1;       -- Get back to the reading request
            stop_all <= '0'; -- The pipeline is unlock for taking in account the interruption
            adr_to_ram <= adr_from_ei;
            r_w <= '0';
        else
            case cs is

                when ST1 => -- First step the reading for EI
                    adr_to_ram <= adr_from_ei;
                    r_w <= '0';

                    if ack_from_ram='1' then
                        
                        if req_from_mem='1' then
                            -- If request from MEM, then step 2
                            ns <= ST2;
                            stop_all <= '1';
                        else
                            -- else next reading for EI
                            ns <= ST1;
                            stop_all <= '0';
                        end if;
                    else
                        -- Wait the end of the reading
                        ns <= ST1;
                        stop_all <= '1';
                    end if;

                when ST2 => -- Treat the request from the MEM stage
                    adr_to_ram <= adr_from_mem;
                    r_w <= r_w_from_mem;

                    -- Wait the acknowledge from the RAM
                    if ack_from_ram='1' then
                        ns <= ST1;
                        stop_all <= '0';
                    else
                        ns <= ST2;
                        stop_all <= '1';
                    end if;

            end case;
        end if;
    end process;

    data_to_mem <= data_in;
    instr_to_ei <= ei_buffer when cs=ST2 else data_in;

end rtl;
