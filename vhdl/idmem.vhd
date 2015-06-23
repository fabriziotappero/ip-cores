--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2005 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file idmem.vhd when simulating
-- the core, idmem. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synopsys directives "translate_off/translate_on" specified
-- below are supported by XST, FPGA Compiler II, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

library ieee;
use ieee.std_logic_1164.all;
-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on
entity idmem is
  port (
    addr  : in  std_logic_vector(11 downto 0);
    clk   : in  std_logic;
    din   : in  std_logic_vector(15 downto 0);
    dout  : out std_logic_vector(15 downto 0);
    sinit : in  std_logic;
    we    : in  std_logic);
end idmem;

architecture idmem_a of idmem is
-- synopsys translate_off
  component wrapped_idmem
    port (
      addr  : in  std_logic_vector(11 downto 0);
      clk   : in  std_logic;
      din   : in  std_logic_vector(15 downto 0);
      dout  : out std_logic_vector(15 downto 0);
      sinit : in  std_logic;
      we    : in  std_logic);
  end component;

-- Configuration specification 
  for all : wrapped_idmem use entity XilinxCoreLib.blkmemsp_v6_2(behavioral)
    generic map(
      c_sinit_value           => "0",
      c_has_en                => 0,
      c_reg_inputs            => 0,
      c_yclk_is_rising        => 1,
      c_ysinit_is_high        => 0,
      c_ywe_is_high           => 1,
      c_yprimitive_type       => "8kx2",
      c_ytop_addr             => "1024",
      c_yhierarchy            => "hierarchy1",
      c_has_limit_data_pitch  => 0,
      c_has_rdy               => 0,
      c_write_mode            => 0,
      c_width                 => 16,
      c_yuse_single_primitive => 0,
      c_has_nd                => 0,
      c_has_we                => 1,
      c_enable_rlocs          => 0,
      c_has_rfd               => 0,
      c_has_din               => 1,
      c_ybottom_addr          => "0",
      c_pipe_stages           => 0,
      c_yen_is_high           => 1,
      c_depth                 => 4096,
      c_has_default_data      => 0,
      c_limit_data_pitch      => 18,
      c_has_sinit             => 1,
      c_mem_init_file         => "idmem.mif",
      c_yydisable_warnings    => 1,
      c_default_data          => "0",
      c_ymake_bmm             => 0,
      c_addr_width            => 12);
-- synopsys translate_on
begin
-- synopsys translate_off
  U0 : wrapped_idmem
    port map (
      addr  => addr,
      clk   => clk,
      din   => din,
      dout  => dout,
      sinit => sinit,
      we    => we);
-- synopsys translate_on

end idmem_a;

