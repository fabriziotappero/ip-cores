-----------------------------------------------------------------------------
-- Entity:      pcitb_stimgen
-- File:        pcitb_stimgen.vhd
-- Author:      Alf Vaerneus, Gaisler Research
-- Description: PCI Stimuli generator. Contains the test sequence.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;

library grlib;
use grlib.stdlib.all;

library gaisler;
use gaisler.ambatest.all;
use gaisler.pcitb.all;
use gaisler.ahb_tb.all;
use gaisler.pci_tb.all;

--LIBRARY adpms_lib;
--USE adpms_lib.TEXTIO.ALL;

entity pcitb_stimgen is
  generic(
    slots : integer := 5;
    dbglevel : integer := 1);
  port(
    rsttrig   : out std_logic;
    tbi       : out tbi_array_type;
    tbo       : in  tbo_array_type
      );
end pcitb_stimgen;

architecture tb of pcitb_stimgen is

constant zero32 : std_logic_vector(31 downto 0) := (others => '0');
constant one32 : std_logic_vector(31 downto 0) := (others => '1');

type config_array_type is array(0 to slots-1) of config_header_type;

begin

  test_sequence : process
  variable ctrl : ctrl_type;
  variable i : integer;
  variable slotconf : config_array_type;
  begin

    ctrl := ctrl_init;

    -- Reset system
    rsttrig <= '0';
    wait for 30 ns;
    rsttrig <= '1';
    wait for 30 ns;
    rsttrig <= '0';

    wait for 2000 us;
    printf(" ");
    printf("-------------------------------");
    printf("PCI Test Start");
    printf(" ");

    ctrl.wfile := "pci_read.log      ";
    ctrl.usewfile := true;
    ctrl.userfile := false;

    -- Configure existing PCI units
    for i in 0 to slots-1 loop
      ctrl.address := (others => '0');
      ctrl.address((32-slots)+i) := '1';
      printf("Scanning slot %d",i);
      PCI_read_config(ctrl,tbi(0),tbo(0),dbglevel);
      if ctrl.status = OK then
        printf("Device found with ID %x",ctrl.data);
        slotconf(i).devid := ctrl.data(31 downto 16);
        slotconf(i).vendid := ctrl.data(15 downto 0);
        ctrl.address(7 downto 2) := conv_std_logic_vector(1,6);
        ctrl.data := (others => '1');
        PCI_write_config(ctrl,tbi(0),tbo(0),dbglevel);
        PCI_read_config(ctrl,tbi(0),tbo(0),dbglevel);
        slotconf(i).status  := ctrl.data(31 downto 16);
        slotconf(i).command := ctrl.data(15 downto 0);
        ctrl.address(7 downto 2) := conv_std_logic_vector(2,6);
        PCI_read_config(ctrl,tbi(0),tbo(0),dbglevel);
        slotconf(i).class_code := ctrl.data(31 downto 8);
        slotconf(i).revid := ctrl.data(7 downto 0);
        ctrl.address(7 downto 2) := conv_std_logic_vector(3,6);
        ctrl.data := (others => '1');
        PCI_write_config(ctrl,tbi(0),tbo(0),dbglevel);
        PCI_read_config(ctrl,tbi(0),tbo(0),dbglevel);
        slotconf(i).bist := ctrl.data(31 downto 24);
        slotconf(i).header_type := ctrl.data(23 downto 16);
        slotconf(i).lat_timer := ctrl.data(15 downto 8);
        slotconf(i).cache_lsize := ctrl.data(7 downto 0);
        for j in 0 to 5 loop
          ctrl.address(7 downto 2) := conv_std_logic_vector(j+4,6);
          ctrl.data := (others => '1');
          PCI_write_config(ctrl,tbi(0),tbo(0),dbglevel);
          PCI_read_config(ctrl,tbi(0),tbo(0),dbglevel);
          if ctrl.data > zero32 then
            ctrl.data := (others => '0');
            ctrl.data(31 downto 29) := conv_std_logic_vector(3,3);
            ctrl.data(28 downto 26) := conv_std_logic_vector(j,3);
            PCI_write_config(ctrl,tbi(0),tbo(0),dbglevel);
            PCI_read_config(ctrl,tbi(0),tbo(0),dbglevel);
            slotconf(i).bar(j) := ctrl.data;
            printf("BAR%d",j);
            printf("%x",ctrl.data);
          end if;
        end loop;
      else
        printf("No device found on slot %d",i);
        slotconf(i).vendid := (others => '1');
      end if;
    end loop;

    wait for 5 us;

    printf(" ");
    printf("-------------------------------");
    printf(" ");
    printf("Testcase 1: Read from target.");
    printf(" ");

    -- Set AHB register
    ctrl.address := conv_std_logic_vector_signed(16#60100000#,32); 
    ctrl.no_words := 1;
    ctrl.data := conv_std_logic_vector_signed(16#60000000#,32);
    PCI_write_single(ctrl,tbi(0),tbo(0),dbglevel);
    if ctrl.status = OK then
      printf("AHB register set!");
    end if;
    
    -- Try to read from every unit
    for i in 0 to slots-1 loop
      if slotconf(i).vendid /= one32(15 downto 0) then
        ctrl.address := slotconf(i).bar(0);
        ctrl.no_words := 1;
        printf("Try to read from slot%d",i);
        PCI_read_single(ctrl,tbi(0),tbo(0),dbglevel);
        if ctrl.status = OK then
          printf("Read data %x",ctrl.data);
        else
          printf("Read failed!");
        end if;
      end if;
    end loop;

    wait for 5 us;

    printf(" ");
    printf("-------------------------------");
    printf(" ");
    printf("Testcase 2: Write to target and verify.");
    printf(" ");


    -- Try to read from every unit
    for i in 0 to slots-1 loop
      if slotconf(i).vendid /= one32(15 downto 0) then
        ctrl.address := slotconf(i).bar(0);
        ctrl.data := conv_std_logic_vector_signed(16#12345678#,32);
        printf("Try to write to slot%d",i);
        printf("Write data: %x",ctrl.data);
        PCI_write_single(ctrl,tbi(0),tbo(0),dbglevel);
        printf("Read and verify");
        ctrl.usewfile := true;
        ctrl.no_words := 1;
        ctrl.wfile := "pci_read.log      ";
        PCI_read_single(ctrl,tbi(0),tbo(0),dbglevel);
        if ctrl.status = OK then
          printf("Read data %x",ctrl.data);
        else
          printf("Read failed!");
        end if;
      end if;
    end loop;

    wait for 5 us;

    printf(" ");
    printf("-------------------------------");
    printf(" ");
    printf("Testcase 3: Write from file to target and verify.");
    printf(" ");

    ctrl.userfile := true;

    -- Try to write from file
    printf("Write data: %x",ctrl.data);
    ctrl.rfile := "pcisequence.seq   ";
    PCI_write_single(ctrl,tbi(0),tbo(0),dbglevel);
    printf("Read and verify");
    ctrl.rfile := "pcisequence2.seq  ";
    PCI_read_single(ctrl,tbi(0),tbo(0),dbglevel);
    if ctrl.status = OK then
      printf("Read data %x",ctrl.data);
    else
      printf("Read failed!");
    end if;

    ctrl.userfile := false;

    wait for 10 us;

    printf(" ");
    printf("-------------------------------");
    printf("PCI Test Complete");
    printf(" ");
    --assert false
    --  report "Simulation Finished"
    --  severity failure;

    wait; 
  end process;

end;

