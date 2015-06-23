-------------------------------------------------------------------------------
-- Title         : PCI interface for LEON processor
-- Project       : pci4leon
-------------------------------------------------------------------------------
-- File          : pci.vhd
-- Author        : Roland Weigand  <weigand@ws.estec.esa.nl>
-- Created       : 2000/02/29
-- Last modified : 2000/02/29
-------------------------------------------------------------------------------
-- Description :
-- This Unit is the top level of the PCI interface. It is connected
-- to the peripheral bus of LEON and the DMA port.
-- PCI ports must be connected to the top level pads.
-- It includes the Phoenix/In-Silicon PCI core
-------------------------------------------------------------------------------
-- THIS IS JUST A DUMMY VERSION TO TEST THE LEON/AHB INTERFACE
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

use work.amba.all;
use work.leon_iface.all;

entity pci_is is
   port (
      rst_n           : in  std_logic;
      pciresetn       : in  std_logic;
      app_clk         : in  clk_type;
      pci_clk         : in  clk_type;

      -- peripheral bus
      pbi             : in  APB_Slv_In_Type;   -- peripheral bus in
      pbo             : out APB_Slv_Out_Type;  -- peripheral bus out
      irq             : out std_logic;         -- interrupt request

      -- PCI-Target DMA-Port = AHB master
      TargetMasterOut : out ahb_mst_out_type;  -- dma port out
      TargetMasterIn  : in  ahb_mst_in_type;   -- dma port in
--    TargetAsi       : out std_logic_vector(3 downto 0);  -- sparc ASI

      -- PCI PORTS for top level
      pci_in          : in  pci_in_type;       -- PCI bus inputs
      pci_out         : out pci_out_type;      -- PCI bus outputs

      -- PCI-Initiator Word-Interface = AHB slave
      InitSlaveOut  : out ahb_slv_out_type;  -- Direct initiator I/F
      InitSlaveIn   : in  ahb_slv_in_type;   -- Direct initiator I/F

      -- PCI-Intitiator DMA-Port = AHB master
      InitMasterOut : out ahb_mst_out_type;  -- dma port out
      InitMasterIn  : in  ahb_mst_in_type    -- dma port in
--    InitAsi       : out std_logic_vector(3 downto 0);  -- sparc ASI
       
      );
end;      

architecture struct of pci_is is
begin

    InitMasterOut.haddr   <= (others => '0') ;
    InitMasterOut.htrans  <= HTRANS_IDLE;
    InitMasterOut.hbusreq <= '0';
    InitMasterOut.hwdata  <= (others => '0');
    InitMasterOut.hlock   <= '0';
    InitMasterOut.hwrite  <= '0';
    InitMasterOut.hsize   <= HSIZE_WORD;
    InitMasterOut.hburst  <= HBURST_SINGLE;
    InitMasterOut.hprot   <= (others => '0');      

    TargetMasterOut.haddr   <= (others => '0') ;
    TargetMasterOut.htrans  <= HTRANS_IDLE;
    TargetMasterOut.hbusreq <= '0';
    TargetMasterOut.hwdata  <= (others => '0');
    TargetMasterOut.hlock   <= '0';
    TargetMasterOut.hwrite  <= '0';
    TargetMasterOut.hsize   <= HSIZE_WORD;
    TargetMasterOut.hburst  <= HBURST_SINGLE;
    TargetMasterOut.hprot   <= (others => '0');      

    InitSlaveOut.hrdata <= (others => '0');
    InitSlaveOut.hready <= '1';
    InitSlaveOut.hresp  <= HRESP_OKAY;         

    irq <= '0';
end;
