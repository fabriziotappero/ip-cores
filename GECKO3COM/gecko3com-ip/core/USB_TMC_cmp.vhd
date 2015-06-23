----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:49:14 04/15/2009 
-- Design Name: 
-- Module Name:    com_cmp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
--------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library XilinxCoreLib;

library work;
use work.GECKO3COM_defines.all;


package USB_TMC_cmp is

  
  attribute box_type      : string;
  
  
 --------------------------------------------------------------------------------- 
 --     COMPONENTS  
 ---------------------------------------------------------------------------------




--<!-->

-- FSM Loopback
component USB_TMC_IP_loopback 
  port (
    i_nReset,
	 i_SYSCLK,									 -- FPGA System CLK
	 i_U2X_AM_EMPTY,
	 i_U2X_EMPTY,
	 i_X2U_AM_FULL,
	 i_X2U_FULL	    : in  std_logic;
	 i_U2X_DATA     : in  std_logic_vector(SIZE_DBUS_FPGA-1 downto 0);
	 o_U2X_RD_EN,
	 o_X2U_WR_EN    : out std_logic;
	 o_X2U_DATA     : out std_logic_vector(SIZE_DBUS_FPGA-1 downto 0)
	);
end component;
--<!-->


end USB_TMC_cmp;

