--------------------------------------------------------------------------------
--    This file is owned and controlled by Xilinx and must be used solely     --
--    for design, simulation, implementation and creation of design files     --
--    limited to Xilinx devices or technologies. Use with non-Xilinx          --
--    devices or technologies is expressly prohibited and immediately         --
--    terminates your license.                                                --
--                                                                            --
--    XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY    --
--    FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY    --
--    PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE             --
--    IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS      --
--    MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY      --
--    CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY       --
--    RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY       --
--    DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE   --
--    IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR          --
--    REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF         --
--    INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A   --
--    PARTICULAR PURPOSE.                                                     --
--                                                                            --
--    Xilinx products are not intended for use in life support appliances,    --
--    devices, or systems.  Use in such applications are expressly            --
--    prohibited.                                                             --
--                                                                            --
--    (c) Copyright 1995-2015 Xilinx, Inc.                                    --
--    All rights reserved.                                                    --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--    Generated from core with identifier: xilinx.com:ip:blk_mem_gen:7.1      --
--                                                                            --
--    The Xilinx LogiCORE IP Block Memory Generator replaces the Dual Port    --
--    Block Memory and Single Port Block Memory LogiCOREs, but is not a       --
--    direct drop-in replacement.  It should be used in all new Xilinx        --
--    designs. The core supports RAM and ROM functions over a wide range of   --
--    widths and depths. Use this core to generate block memories with        --
--    symmetric or asymmetric read and write port widths, as well as cores    --
--    which can perform simultaneous write operations to separate             --
--    locations, and simultaneous read operations from the same location.     --
--    For more information on differences in interface and feature support    --
--    between this core and the Dual Port Block Memory and Single Port        --
--    Block Memory LogiCOREs, please consult the data sheet.                  --
--------------------------------------------------------------------------------

-- Interfaces:
--    AXI_SLAVE_S_AXI
--        AXI_SLAVE
--    AXILite_SLAVE_S_AXI
--        AXILite_SLAVE
--    BRAM_PORTA
--        BRAM_PORTA
--    BRAM_PORTB
--        BRAM_PORTB

-- The following code must appear in the VHDL architecture header:

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT blockMemory
  PORT (
    clka : IN STD_LOGIC;
    rsta : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(511 DOWNTO 0)
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : blockMemory
  PORT MAP (
    clka => clka,
    rsta => rsta,
    wea => wea,
    addra => addra,
    dina => dina,
    douta => douta
  );
-- INST_TAG_END ------ End INSTANTIATION Template ------------

-- You must compile the wrapper file blockMemory.vhd when simulating
-- the core, blockMemory. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

