--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: exp_lut_MEM.vhd
-- /___/   /\     Timestamp: Tue Sep 22 14:13:07 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\exp_lut_MEM.ngc" "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\exp_lut_MEM.vhd" 
-- Device	: 4vsx55ff1148-12
-- Input file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/exp_lut_MEM.ngc
-- Output file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/exp_lut_MEM.vhd
-- # of Entities	: 1
-- Design Name	: exp_lut_MEM
-- Xilinx	: C:\Xilinx\10.1\ISE
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Development System Reference Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity exp_lut_MEM is
  port (
    clka : in STD_LOGIC := 'X'; 
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 ); 
    douta : out STD_LOGIC_VECTOR ( 12 downto 0 ) 
  );
end exp_lut_MEM;

architecture STRUCTURE of exp_lut_MEM is
  signal BU2_N1 : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_CASCADEOUTA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_CASCADEOUTB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPA_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal addra_2 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal douta_3 : STD_LOGIC_VECTOR ( 12 downto 0 ); 
  signal BU2_doutb : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  addra_2(9) <= addra(9);
  addra_2(8) <= addra(8);
  addra_2(7) <= addra(7);
  addra_2(6) <= addra(6);
  addra_2(5) <= addra(5);
  addra_2(4) <= addra(4);
  addra_2(3) <= addra(3);
  addra_2(2) <= addra(2);
  addra_2(1) <= addra(1);
  addra_2(0) <= addra(0);
  douta(12) <= douta_3(12);
  douta(11) <= douta_3(11);
  douta(10) <= douta_3(10);
  douta(9) <= douta_3(9);
  douta(8) <= douta_3(8);
  douta(7) <= douta_3(7);
  douta(6) <= douta_3(6);
  douta(5) <= douta_3(5);
  douta(4) <= douta_3(4);
  douta(3) <= douta_3(3);
  douta(2) <= douta_3(2);
  douta(1) <= douta_3(1);
  douta(0) <= douta_3(0);
  VCC_0 : VCC
    port map (
      P => NLW_VCC_P_UNCONNECTED
    );
  GND_1 : GND
    port map (
      G => NLW_GND_G_UNCONNECTED
    );
  BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP : RAMB16
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      SRVAL_A => X"000000000",
      INIT_00 => X"2370237123722373237423752376237723782379237A237B237C237D237E237F",
      INIT_01 => X"2360236123622363236423652366236723682369236A236B236C236D236E236F",
      INIT_02 => X"2350235123522353235423552356235723582359235A235B235C235D235E235F",
      INIT_03 => X"2340234123422343234423452346234723482349234A234B234C234D234E234F",
      INIT_04 => X"2330233123322333233423352336233723382339233A233B233C233D233E233F",
      INIT_05 => X"2320232123222323232423252326232723282329232A232B232C232D232E232F",
      INIT_06 => X"2310231123122313231423152316231723182319231A231B231C231D231E231F",
      INIT_07 => X"2300230123022303230423052306230723082309230A230B230C230D230E230F",
      INIT_08 => X"2270227122722273227422752276227722782279227A227B227C227D227E227F",
      INIT_09 => X"2260226122622263226422652266226722682269226A226B226C226D226E226F",
      INIT_0A => X"2250225122522253225422552256225722582259225A225B225C225D225E225F",
      INIT_0B => X"2240224122422243224422452246224722482249224A224B224C224D224E224F",
      INIT_0C => X"2230223122322233223422352236223722382239223A223B223C223D223E223F",
      INIT_0D => X"2220222122222223222422252226222722282229222A222B222C222D222E222F",
      INIT_0E => X"2210221122122213221422152216221722182219221A221B221C221D221E221F",
      INIT_0F => X"2200220122022203220422052206220722082209220A220B220C220D220E220F",
      INIT_10 => X"2170217121722173217421752176217721782179217A217B217C217D217E217F",
      INIT_11 => X"2160216121622163216421652166216721682169216A216B216C216D216E216F",
      INIT_12 => X"2150215121522153215421552156215721582159215A215B215C215D215E215F",
      INIT_13 => X"2140214121422143214421452146214721482149214A214B214C214D214E214F",
      INIT_14 => X"2130213121322133213421352136213721382139213A213B213C213D213E213F",
      INIT_15 => X"2120212121222123212421252126212721282129212A212B212C212D212E212F",
      INIT_16 => X"2110211121122113211421152116211721182119211A211B211C211D211E211F",
      INIT_17 => X"2100210121022103210421052106210721082109210A210B210C210D210E210F",
      INIT_18 => X"2070207120722073207420752076207720782079207A207B207C207D207E207F",
      INIT_19 => X"2060206120622063206420652066206720682069206A206B206C206D206E206F",
      INIT_1A => X"2050205120522053205420552056205720582059205A205B205C205D205E205F",
      INIT_1B => X"2040204120422043204420452046204720482049204A204B204C204D204E204F",
      INIT_1C => X"2030203120322033203420352036203720382039203A203B203C203D203E203F",
      INIT_1D => X"2020202120222023202420252026202720282029202A202B202C202D202E202F",
      INIT_1E => X"2010201120122013201420152016201720182019201A201B201C201D201E201F",
      INIT_1F => X"2000200120022003200420052006200720082009200A200B200C200D200E200F",
      INIT_20 => X"1F601F621F641F661F681F6A1F6C1F6E1F701F721F741F761F781F7A1F7C1F7E",
      INIT_21 => X"1F401F421F441F461F481F4A1F4C1F4E1F501F521F541F561F581F5A1F5C1F5E",
      INIT_22 => X"1F201F221F241F261F281F2A1F2C1F2E1F301F321F341F361F381F3A1F3C1F3E",
      INIT_23 => X"1F001F021F041F061F081F0A1F0C1F0E1F101F121F141F161F181F1A1F1C1F1E",
      INIT_24 => X"1E601E621E641E661E681E6A1E6C1E6E1E701E721E741E761E781E7A1E7C1E7E",
      INIT_25 => X"1E401E421E441E461E481E4A1E4C1E4E1E501E521E541E561E581E5A1E5C1E5E",
      INIT_26 => X"1E201E221E241E261E281E2A1E2C1E2E1E301E321E341E361E381E3A1E3C1E3E",
      INIT_27 => X"1E001E021E041E061E081E0A1E0C1E0E1E101E121E141E161E181E1A1E1C1E1E",
      INIT_28 => X"1D601D621D641D661D681D6A1D6C1D6E1D701D721D741D761D781D7A1D7C1D7E",
      INIT_29 => X"1D401D421D441D461D481D4A1D4C1D4E1D501D521D541D561D581D5A1D5C1D5E",
      INIT_2A => X"1D201D221D241D261D281D2A1D2C1D2E1D301D321D341D361D381D3A1D3C1D3E",
      INIT_2B => X"1D001D021D041D061D081D0A1D0C1D0E1D101D121D141D161D181D1A1D1C1D1E",
      INIT_2C => X"1C601C621C641C661C681C6A1C6C1C6E1C701C721C741C761C781C7A1C7C1C7E",
      INIT_2D => X"1C401C421C441C461C481C4A1C4C1C4E1C501C521C541C561C581C5A1C5C1C5E",
      INIT_2E => X"1C201C221C241C261C281C2A1C2C1C2E1C301C321C341C361C381C3A1C3C1C3E",
      INIT_2F => X"1C001C021C041C061C081C0A1C0C1C0E1C101C121C141C161C181C1A1C1C1C1E",
      INIT_30 => X"1B401B441B481B4C1B501B541B581B5C1B601B641B681B6C1B701B741B781B7C",
      INIT_31 => X"1B001B041B081B0C1B101B141B181B1C1B201B241B281B2C1B301B341B381B3C",
      INIT_32 => X"1A401A441A481A4C1A501A541A581A5C1A601A641A681A6C1A701A741A781A7C",
      INIT_33 => X"1A001A041A081A0C1A101A141A181A1C1A201A241A281A2C1A301A341A381A3C",
      INIT_34 => X"194019441948194C195019541958195C196019641968196C197019741978197C",
      INIT_35 => X"190019041908190C191019141918191C192019241928192C193019341938193C",
      INIT_36 => X"184018441848184C185018541858185C186018641868186C187018741878187C",
      INIT_37 => X"180018041808180C181018141818181C182018241828182C183018341838183C",
      INIT_38 => X"1700170817101718172017281730173817401748175017581760176817701778",
      INIT_39 => X"1600160816101618162016281630163816401648165016581660166816701678",
      INIT_3A => X"1500150815101518152015281530153815401548155015581560156815701578",
      INIT_3B => X"1400140814101418142014281430143814401448145014581460146814701478",
      INIT_3C => X"1200121012201230124012501260127013001310132013301340135013601370",
      INIT_3D => X"1000101010201030104010501060107011001110112011301140115011601170",
      INIT_3E => X"0C000C200C400C600D000D200D400D600E000E200E400E600F000F200F400F60",
      INIT_3F => X"00003C0000000200040005000600070008000840090009400A000A400B000B40",
      INIT_FILE => "NONE",
      INVERT_CLK_DOA_REG => FALSE,
      INVERT_CLK_DOB_REG => FALSE,
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 18,
      READ_WIDTH_B => 18,
      SIM_COLLISION_CHECK => "ALL",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 18,
      WRITE_WIDTH_B => 18,
      SRVAL_B => X"000000000"
    )
    port map (
      CASCADEINA => BU2_doutb(0),
      CASCADEINB => BU2_doutb(0),
      CLKA => clka,
      CLKB => BU2_doutb(0),
      ENA => BU2_N1,
      REGCEA => BU2_doutb(0),
      REGCEB => BU2_doutb(0),
      ENB => BU2_doutb(0),
      SSRA => BU2_doutb(0),
      SSRB => BU2_doutb(0),
      CASCADEOUTA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_CASCADEOUTA_UNCONNECTED,
      CASCADEOUTB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_CASCADEOUTB_UNCONNECTED,
      ADDRA(14) => BU2_doutb(0),
      ADDRA(13) => addra_2(9),
      ADDRA(12) => addra_2(8),
      ADDRA(11) => addra_2(7),
      ADDRA(10) => addra_2(6),
      ADDRA(9) => addra_2(5),
      ADDRA(8) => addra_2(4),
      ADDRA(7) => addra_2(3),
      ADDRA(6) => addra_2(2),
      ADDRA(5) => addra_2(1),
      ADDRA(4) => addra_2(0),
      ADDRA(3) => BU2_doutb(0),
      ADDRA(2) => BU2_doutb(0),
      ADDRA(1) => BU2_doutb(0),
      ADDRA(0) => BU2_doutb(0),
      ADDRB(14) => BU2_doutb(0),
      ADDRB(13) => BU2_doutb(0),
      ADDRB(12) => BU2_doutb(0),
      ADDRB(11) => BU2_doutb(0),
      ADDRB(10) => BU2_doutb(0),
      ADDRB(9) => BU2_doutb(0),
      ADDRB(8) => BU2_doutb(0),
      ADDRB(7) => BU2_doutb(0),
      ADDRB(6) => BU2_doutb(0),
      ADDRB(5) => BU2_doutb(0),
      ADDRB(4) => BU2_doutb(0),
      ADDRB(3) => BU2_doutb(0),
      ADDRB(2) => BU2_doutb(0),
      ADDRB(1) => BU2_doutb(0),
      ADDRB(0) => BU2_doutb(0),
      DIA(31) => BU2_doutb(0),
      DIA(30) => BU2_doutb(0),
      DIA(29) => BU2_doutb(0),
      DIA(28) => BU2_doutb(0),
      DIA(27) => BU2_doutb(0),
      DIA(26) => BU2_doutb(0),
      DIA(25) => BU2_doutb(0),
      DIA(24) => BU2_doutb(0),
      DIA(23) => BU2_doutb(0),
      DIA(22) => BU2_doutb(0),
      DIA(21) => BU2_doutb(0),
      DIA(20) => BU2_doutb(0),
      DIA(19) => BU2_doutb(0),
      DIA(18) => BU2_doutb(0),
      DIA(17) => BU2_doutb(0),
      DIA(16) => BU2_doutb(0),
      DIA(15) => BU2_doutb(0),
      DIA(14) => BU2_doutb(0),
      DIA(13) => BU2_doutb(0),
      DIA(12) => BU2_doutb(0),
      DIA(11) => BU2_doutb(0),
      DIA(10) => BU2_doutb(0),
      DIA(9) => BU2_doutb(0),
      DIA(8) => BU2_doutb(0),
      DIA(7) => BU2_doutb(0),
      DIA(6) => BU2_doutb(0),
      DIA(5) => BU2_doutb(0),
      DIA(4) => BU2_doutb(0),
      DIA(3) => BU2_doutb(0),
      DIA(2) => BU2_doutb(0),
      DIA(1) => BU2_doutb(0),
      DIA(0) => BU2_doutb(0),
      DIB(31) => BU2_doutb(0),
      DIB(30) => BU2_doutb(0),
      DIB(29) => BU2_doutb(0),
      DIB(28) => BU2_doutb(0),
      DIB(27) => BU2_doutb(0),
      DIB(26) => BU2_doutb(0),
      DIB(25) => BU2_doutb(0),
      DIB(24) => BU2_doutb(0),
      DIB(23) => BU2_doutb(0),
      DIB(22) => BU2_doutb(0),
      DIB(21) => BU2_doutb(0),
      DIB(20) => BU2_doutb(0),
      DIB(19) => BU2_doutb(0),
      DIB(18) => BU2_doutb(0),
      DIB(17) => BU2_doutb(0),
      DIB(16) => BU2_doutb(0),
      DIB(15) => BU2_doutb(0),
      DIB(14) => BU2_doutb(0),
      DIB(13) => BU2_doutb(0),
      DIB(12) => BU2_doutb(0),
      DIB(11) => BU2_doutb(0),
      DIB(10) => BU2_doutb(0),
      DIB(9) => BU2_doutb(0),
      DIB(8) => BU2_doutb(0),
      DIB(7) => BU2_doutb(0),
      DIB(6) => BU2_doutb(0),
      DIB(5) => BU2_doutb(0),
      DIB(4) => BU2_doutb(0),
      DIB(3) => BU2_doutb(0),
      DIB(2) => BU2_doutb(0),
      DIB(1) => BU2_doutb(0),
      DIB(0) => BU2_doutb(0),
      DIPA(3) => BU2_doutb(0),
      DIPA(2) => BU2_doutb(0),
      DIPA(1) => BU2_doutb(0),
      DIPA(0) => BU2_doutb(0),
      DIPB(3) => BU2_doutb(0),
      DIPB(2) => BU2_doutb(0),
      DIPB(1) => BU2_doutb(0),
      DIPB(0) => BU2_doutb(0),
      WEA(3) => BU2_doutb(0),
      WEA(2) => BU2_doutb(0),
      WEA(1) => BU2_doutb(0),
      WEA(0) => BU2_doutb(0),
      WEB(3) => BU2_doutb(0),
      WEB(2) => BU2_doutb(0),
      WEB(1) => BU2_doutb(0),
      WEB(0) => BU2_doutb(0),
      DOA(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_31_UNCONNECTED,
      DOA(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_30_UNCONNECTED,
      DOA(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_29_UNCONNECTED,
      DOA(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_28_UNCONNECTED,
      DOA(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_27_UNCONNECTED,
      DOA(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_26_UNCONNECTED,
      DOA(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_25_UNCONNECTED,
      DOA(24) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_24_UNCONNECTED,
      DOA(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_23_UNCONNECTED,
      DOA(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_22_UNCONNECTED,
      DOA(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_21_UNCONNECTED,
      DOA(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_20_UNCONNECTED,
      DOA(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_19_UNCONNECTED,
      DOA(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_18_UNCONNECTED,
      DOA(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_17_UNCONNECTED,
      DOA(16) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_16_UNCONNECTED,
      DOA(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_15_UNCONNECTED,
      DOA(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_14_UNCONNECTED,
      DOA(13) => douta_3(12),
      DOA(12) => douta_3(11),
      DOA(11) => douta_3(10),
      DOA(10) => douta_3(9),
      DOA(9) => douta_3(8),
      DOA(8) => douta_3(7),
      DOA(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOA_7_UNCONNECTED,
      DOA(6) => douta_3(6),
      DOA(5) => douta_3(5),
      DOA(4) => douta_3(4),
      DOA(3) => douta_3(3),
      DOA(2) => douta_3(2),
      DOA(1) => douta_3(1),
      DOA(0) => douta_3(0),
      DOB(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_31_UNCONNECTED,
      DOB(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_30_UNCONNECTED,
      DOB(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_29_UNCONNECTED,
      DOB(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_28_UNCONNECTED,
      DOB(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_27_UNCONNECTED,
      DOB(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_26_UNCONNECTED,
      DOB(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_25_UNCONNECTED,
      DOB(24) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_24_UNCONNECTED,
      DOB(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_23_UNCONNECTED,
      DOB(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_22_UNCONNECTED,
      DOB(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_21_UNCONNECTED,
      DOB(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_20_UNCONNECTED,
      DOB(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_19_UNCONNECTED,
      DOB(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_18_UNCONNECTED,
      DOB(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_17_UNCONNECTED,
      DOB(16) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_16_UNCONNECTED,
      DOB(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_15_UNCONNECTED,
      DOB(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_14_UNCONNECTED,
      DOB(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_13_UNCONNECTED,
      DOB(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_12_UNCONNECTED,
      DOB(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_11_UNCONNECTED,
      DOB(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_10_UNCONNECTED,
      DOB(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_9_UNCONNECTED,
      DOB(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_8_UNCONNECTED,
      DOB(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_7_UNCONNECTED,
      DOB(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_6_UNCONNECTED,
      DOB(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_5_UNCONNECTED,
      DOB(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_4_UNCONNECTED,
      DOB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_3_UNCONNECTED,
      DOB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_2_UNCONNECTED,
      DOB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_1_UNCONNECTED,
      DOB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOB_0_UNCONNECTED,
      DOPA(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPA_3_UNCONNECTED,
      DOPA(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPA_2_UNCONNECTED,
      DOPA(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPA_1_UNCONNECTED,
      DOPA(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPA_0_UNCONNECTED,
      DOPB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPB_3_UNCONNECTED,
      DOPB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPB_2_UNCONNECTED,
      DOPB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v4_init_ram_SP_SINGLE_PRIM_SP_DOPB_0_UNCONNECTED
    );
  BU2_XST_VCC : VCC
    port map (
      P => BU2_N1
    );
  BU2_XST_GND : GND
    port map (
      G => BU2_doutb(0)
    );

end STRUCTURE;

-- synthesis translate_on
