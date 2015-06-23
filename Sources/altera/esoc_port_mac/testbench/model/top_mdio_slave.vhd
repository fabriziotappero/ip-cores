-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: top_mdio_slave.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/vhdl/mdio/top_mdio_slave.vhd,v $
--
-- $Revision: #1 $
-- $Date: 2008/08/09 $
-- Check in by : $Author: sc-build $
-- Author      : SKNg/TTChong
--
-- Project     : Triple Speed Ethernet - 10/100/1000 MAC
--
-- Description : (Simulation only)
--
-- MDIO Slave model
-- Instantiates mdio_slave (mdio_slave.vhd) and mdio_reg_sim (mdio_reg.vhd)
--
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------


library ieee ;
use     ieee.std_logic_1164.all ;

entity top_mdio_slave is port (

        reset           : in std_logic ;
        mdc             : in std_logic ;
        mdio            : inout std_logic ;
        dev_addr        : in std_logic_vector(4 downto 0) ;
        conf_done       : out std_logic) ;
        
end top_mdio_slave ;

architecture a of top_mdio_slave is

        component mdio_reg_sim port (

                reset           : in std_logic ;
                clk             : in std_logic ;                        -- MDIO 2.5MHz Clock
                reg_addr        : in std_logic_vector(4 downto 0);      -- Address Register
                reg_write       : in std_logic;                         -- Write Register       
                reg_read        : in std_logic;                         -- Read Register        
                reg_dout        : out std_logic_vector(15 downto 0);    -- Data Bus OUT
                reg_din         : in std_logic_vector(15 downto 0) ;    -- Data Bus IN
                conf_done       : out std_logic) ;                      -- PHY Config Done
                
        end component ;
        
        component mdio_slave port (
      
                reset           : in std_logic;                         -- asynch reset
                mdc             : in std_logic;                         -- system clock
                mdio            : inout std_logic;                      -- Data Bus
                dev_addr        : in  std_logic_vector(4 downto 0);     -- Device address
                reg_addr        : out std_logic_vector(4 downto 0);     -- Address register
                reg_read        : out std_logic;                        -- Read register         
                reg_write       : out std_logic;                        -- Write register         
                reg_dout        : out std_logic_vector(15 downto 0);    -- Data Bus OUT
                reg_din         : in  std_logic_vector(15 downto 0)) ;  -- Data Bus IN

        end component;  
        
        signal reg_addr         : std_logic_vector(4 downto 0);         -- Address register
        signal reg_read         : std_logic;                            -- Read register         
        signal reg_write        : std_logic;                            -- Write register         
        signal reg_dout         : std_logic_vector(15 downto 0);        -- Data Bus OUT
        signal reg_din          : std_logic_vector(15 downto 0);        -- Data Bus IN 
        
begin

        MDIO_C: mdio_slave port map (
      
                reset           => reset ,
                mdc             => mdc ,
                mdio            => mdio ,
                dev_addr        => dev_addr ,
                reg_addr        => reg_addr ,
                reg_read        => reg_read ,             
                reg_write       => reg_write ,             
                reg_dout        => reg_din ,        
                reg_din         => reg_dout) ;
                
        REG_C: mdio_reg_sim  port map (

                reset           => reset ,          
                clk             => mdc ,
                reg_addr        => reg_addr ,
                reg_write       => reg_write ,  
                reg_read        => reg_read ,   
                reg_dout        => reg_dout ,
                reg_din         => reg_din ,
                conf_done       => conf_done) ;
                
end a ;       
