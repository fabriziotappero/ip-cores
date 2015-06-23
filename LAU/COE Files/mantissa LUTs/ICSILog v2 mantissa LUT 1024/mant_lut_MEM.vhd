--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: mant_lut_MEM.vhd
-- /___/   /\     Timestamp: Fri Jul 24 14:28:04 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\mant_lut_MEM.ngc" "C:\Documents and Settings\Administrator\Desktop\Felsenstein Coprocessor\Logarithm LUT based\HW Implementation\Coregen\tmp\_cg\mant_lut_MEM.vhd" 
-- Device	: 5vsx95tff1136-1
-- Input file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/mant_lut_MEM.ngc
-- Output file	: C:/Documents and Settings/Administrator/Desktop/Felsenstein Coprocessor/Logarithm LUT based/HW Implementation/Coregen/tmp/_cg/mant_lut_MEM.vhd
-- # of Entities	: 1
-- Design Name	: mant_lut_MEM
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

entity mant_lut_MEM is
  port (
    clka : in STD_LOGIC := 'X'; 
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 ); 
    douta : out STD_LOGIC_VECTOR ( 26 downto 0 ) 
  );
end mant_lut_MEM;

architecture STRUCTURE of mant_lut_MEM is
  signal BU2_N1 : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGA_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGB_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal addra_2 : STD_LOGIC_VECTOR ( 9 downto 0 ); 
  signal douta_3 : STD_LOGIC_VECTOR ( 26 downto 0 ); 
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
  douta(26) <= douta_3(26);
  douta(25) <= douta_3(25);
  douta(24) <= douta_3(24);
  douta(23) <= douta_3(23);
  douta(22) <= douta_3(22);
  douta(21) <= douta_3(21);
  douta(20) <= douta_3(20);
  douta(19) <= douta_3(19);
  douta(18) <= douta_3(18);
  douta(17) <= douta_3(17);
  douta(16) <= douta_3(16);
  douta(15) <= douta_3(15);
  douta(14) <= douta_3(14);
  douta(13) <= douta_3(13);
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
  BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP : RAMB36_EXP
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_7E => X"39414307394102633940423B3940020E393F415E393F012A393E4071393E0035",
      INIT_7F => X"39454417394504133944440B3944037F3943436F3943035B3942434339420327",
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      SRVAL_A => X"000000000",
      SRVAL_B => X"000000000",
      INIT_00 => X"1F3C40181E3D2F361D3E0E6E1C3E5E3D1A7E3C39187F1C15157F38090F7F6001",
      INIT_01 => X"2358484B23193E6E225A2D2C221B1405215B7277211C497F205D191C201D604B",
      INIT_02 => X"2567400E25481A0C2528701F25094247246A1102244A5B51242B2232240B6524",
      INIT_03 => X"2760672427415F522722541C270345032664320626451B232626005926066228",
      INIT_04 => X"286C0E60285C5971284D2315283D6A4B282E3012281E736A280F3552277F6B15",
      INIT_05 => X"2966731729574D072948250D29387B2829294F58291A221C290A7275287B4161",
      INIT_06 => X"2A60625B2A514B0D2A4231592A33163D2A23793A2A145A4E2A05397A2976173E",
      INIT_07 => X"2B595F082B4A55612B3B4A572B2C3D692B1D2F172B0E1E602A7F0C442A6F7842",
      INIT_08 => X"2C28747B2C21372D2C1978702C1239432C0A79252C0338162B776C2D2B68664C",
      INIT_09 => X"2C64423C2C5D0B682C5554252C4E1B742C4662542C3F28442C376D462C303158",
      INIT_0A => X"2D1F586F2D1829072D1078322D0946702D0214412C7A61242C732D1A2C6B7822",
      INIT_0B => X"2D5A38782D530F702D4B657C2D443B1D2D3D0F522D35631C2D2E35792D27076A",
      INIT_0C => X"2E14633C2E0D41072E061D682D7E79602D77546D2D702F102D6908482D616116",
      INIT_0D => X"2E4E591A2E473D2D2E4020572E3903192E3164722E2A45622E2325692E1C0507",
      INIT_0E => X"2F081A722F0105402E796F282E7258282E6B40412E6427732E5D0E3D2E557420",
      INIT_0F => X"2F4129212F3A1A1F2F330A382F2B796B2F2468392F1D56202F1643222F0F2F3D",
      INIT_10 => X"2F7A05012F727C242F6B72632F64683E2F5D5D352F5651472F4F44742F48373D",
      INIT_11 => X"301917363015561430121441300E523D300B100830074D2030040A073000463D",
      INIT_12 => X"3035135C30315542302E1677302A577C302718503023587330201865301C5826",
      INIT_13 => X"3050775E304D3C46304A007E304645073043085F303F4C07303C0E7E30385145",
      INIT_14 => X"306C436530690B4B3065530130621A07305E605E305B270630576C7E30543246",
      INIT_15 => X"3107781C3104427931010D27307D5727307A207830766A1A3073330D306F7B51",
      INIT_16 => X"31231528311F6279311C301B31187D0F311549553112156C310E6155310B2D10",
      INIT_17 => X"313E1B34313A6B7231373C0331340B6631305B1C312D2A243129787E3126472A",
      INIT_18 => X"31590A6431555E0C31523106314F0354314B5575314827683144792F31414A48",
      INIT_19 => X"3173635F3170396B316D0F4B3169647E31663A0631630E60315F630E315C370F",
      INIT_1A => X"320E264A320A7F36320757763204300B32010774317D5F31317A364231770D26",
      INIT_1B => X"3228534932252F1132220A2D321E651E321B3F643218197F3214736E32114D32",
      INIT_1C => X"32426B00323F491F323C27133239045D3235617B32323E6F322F1B38322B7756",
      INIT_1D => X"325C6D1332594E0432562E4C32530E69324F6E5C324C4E2532492D4332460C37",
      INIT_1E => X"32765A2332733D633270207A326D0366326966293266484232632A3232600B78",
      INIT_1F => X"33103253330D185D33097E3E330663763303490533002D6A327D12273279763A",
      INIT_20 => X"3329764333265F133323473B33202F3A331D171133197E3E3316654333134C20",
      INIT_21 => X"3343261433401126333C7C11333966533336506D33333A5F33302429332D0D4A",
      INIT_22 => X"335C416633592F3633561C5F33530961334F763B334C626D33494E7733463A59",
      INIT_23 => X"3375495833723962336F2946336C190333690818336577073362654E335F536E",
      INIT_24 => X"34071F04340558253404113234024A2C34010313337E774D337B684D33785926",
      INIT_25 => X"34134F4B34120A053410442C340E7E40340D3841340B722F340A2C0934086550",
      INIT_26 => X"341F7650341E3221341C6D60341B290C3419642534181F2B34165A1E3415147E",
      INIT_27 => X"342C1420342A510734290D5C34274A1E3426064D3424426A34227E7434213A6B",
      INIT_28 => X"3438284B343666463435242F3433620534321F4934305C7B342F1A1A342D5726",
      INIT_29 => X"3444335D3442726B34413166343F704F343E2F26343C6D6B343B2C1D34396A3D",
      INIT_2A => X"34503566344E7604344D3610344B760A344A3572344875483447350C3445743E",
      INIT_2B => X"345C2E73345A70203459313B345772443456333B345474213453347534517536",
      INIT_2C => X"34681F103466614A346523733463660A3462280F34606A02345F2B64345D6D34",
      INIT_2D => X"3474064C34724A1134710D46346F5068346E137A346C5679346B196834695C45",
      INIT_2E => X"347F6532347E2A02347C6E40347B326D3479770934783B1434767F0D34754275",
      INIT_2F => X"350B3B50350A01283508466F35070C253505514A3504165E35025B6035012052",
      INIT_30 => X"35170932351550113514165F35125D1C35112348350F6963350E2F6E350C7568",
      INIT_31 => X"35224E6435211648351F5E1C351E255E351C6D11351B343235197B4335184243",
      INIT_32 => X"352E0B73352C545A352B1D323529657935282E2F3526765535253E6B35240670",
      INIT_33 => X"3539406935380A533536542D35351D77353367303532305935307972352F427A",
      INIT_34 => X"35446D533543383E3542031935404D64353F181F353D624A353C2C64353A766F",
      INIT_35 => X"3550123C354E5E27354D2A01354B754C354A410735490C323547574D35462258",
      INIT_36 => X"355B2F3035597C18355848713557153A3555617435542E1E35527A3835514642",
      INIT_37 => X"356644383565121D35635F7335622D3A35607A70355F4818355E152F355C6237",
      INIT_38 => X"3571516135702042356E6F13356D3D55356C0C08356A5A2B3569283F35677643",
      INIT_39 => X"357C5735357B27103579765B3578461835771545357564633574337235730271",
      INIT_3A => X"3607553E36062612360476563603470C360217323600674A357F3752357E074B",
      INIT_3B => X"36124C0736111D52360F6F0E360E403C360D115A360B626A360A336A3609045C",
      INIT_3C => X"361D3B1A361C0D5C361A600E36193232361804473616564D3615284536137A2D",
      INIT_3D => X"36282301362676373625495F36241C78362270033621427E3620156C361E684A",
      INIT_3E => X"363303463631577036302C0C362F0019362D5418362C2808362A7B6936294F3D",
      INIT_3F => X"363D5C73363C320F363B071E36395C1D3638310F3637057236355A4736342F0E",
      INIT_40 => X"36482F113647051E36455B1E364431103643067336415C483640320F363F0748",
      INIT_41 => X"36527A293651512736502817364E7E79364D554D364C2C13364B024B36495875",
      INIT_42 => X"365D3E45365C1632365A6E113659456236581D263656745C36554C033654231D",
      INIT_43 => X"36677B6E3666544936652D163664055636625E083661362C36600E42365E664A",
      INIT_44 => X"3672322E36710B75366F652F366E3E5C366D177B366B710C366A4A1036692306",
      INIT_45 => X"367C620C367B3C3F367A16653678707D36774B083676250636747E7636735858",
      INIT_46 => X"37070B113705662F3704414037031C433701773937005222367F2C7D367E074B",
      INIT_47 => X"37112D473710094E370E6548370D4136370C1D16370A78683709542E37082F66",
      INIT_48 => X"371B4935371A26253719030837175F5E37163C26371518623713751137125132",
      INIT_49 => X"37255E6437243C3C37231A063721774437205474371F3218371E0F2E371C6C38",
      INIT_4A => X"372F6D5D372E4C1A372D2A4C372C0870372A6707372945123728231037270100",
      INIT_4B => X"373976263738554A373734603736136A37347267373351583732303C37310F12",
      INIT_4C => X"3743784A374258513741384C3740183A373E781C373D5772373C373A373B1677",
      INIT_4D => X"374D744D374C5538374B3616374A16693748772E374757683746381537451836",
      INIT_4E => X"37576A3A37564C0737552D4837540E7E375270263751514237503252374F1356",
      INIT_4F => X"37615A1737603C46375F1E69375E0100375C630A375B4508375A267A37590860",
      INIT_50 => X"376B436C376A267C3769097F37676C7637664F6237653242376415153762775C",
      INIT_51 => X"3775274037740B3037726F133771526A37703636376F1976376D7D29376C6050",
      INIT_52 => X"377F051C377D696A377C4E2C377B3262377A170D37787B2C37775F3E37764346",
      INIT_53 => X"38042E423803611838031368380246323801787738012B3638005D6E38001021",
      INIT_54 => X"3809174138084A4638077D443807303D380663303806161E3805490538047B66",
      INIT_55 => X"380D7D4E380D3101380C642E380C1754380B4A76380A7E12380A312738096437",
      INIT_56 => X"3812606D3812144D3811482738107B7C38102F4B380F6314380F1658380E4A16",
      INIT_57 => X"381741203816752D3816293538155D37381511343814452A3813791C38132D07",
      INIT_58 => X"381C1E6B381B5326381B075A381A3C0938197032381924563818587438180D0D",
      INIT_59 => X"3820795238202E39381F631A381F1775381E4C4B381E011C381D3566381C6A2C",
      INIT_5A => X"382551583825066A38243B783823707F3823260138225A7E38220F7538214466",
      INIT_5B => X"382A270038295C3E382911763828472A38277C58382732003826672238261C40",
      INIT_5C => X"382E794C382E2F36382D651A382D1A78382C5051382C0625382B3B73382A713C",
      INIT_5D => X"3833494238327F563832356438316B6E383121723830577038300D6A382F435E",
      INIT_5E => X"3838166238374D203837035A38363A0E3835703C3835266638345D0A38341328",
      INIT_5F => X"383C6131383C181A383B4E7D383B055B383A3C3438397307383929563838601E",
      INIT_60 => X"384129323840604438401751383F4E58383F055B383E3C58383D7350383D2A44",
      INIT_61 => X"38456E663845262238445D583844150938434C353843035C38423A7E3841721A",
      INIT_62 => X"384A3152384969373849211638485870384810453847481538467F6038463726",
      INIT_63 => X"384E7179384E2A06384D620E384D1A10384C520E384C0A07384B417B384A7969",
      INIT_64 => X"38532F5C38526812385220423851586D385111133850493438500150384F3967",
      INIT_65 => X"38576B003857235D38565C353856150838554D563855061F38543E6338537722",
      INIT_66 => X"385C2366385B5C6A385B156A385A4E64385A075A3859404B385879373858321E",
      INIT_67 => X"38605A113860133D385F4C64385F0606385E3F23385D783B385D314E385C6A5C",
      INIT_68 => X"38650E05386447573864012538633A6E3862743238622D713861672B38612061",
      INIT_69 => X"38693F433868793C3868333038676D203867270A3866607038661A513865542E",
      INIT_6A => X"386D6E4F386D286E386C6309386C1D1E386B572F386B113C386A4B43386A0545",
      INIT_6B => X"38721B2B387155703871103038704A6C38700523386F3F55386E7A02386E342B",
      INIT_6C => X"387645593876004438753B2A3874760B3874306838736B403873261338726061",
      INIT_6D => X"387A6D5D387A286D3879637838791E7E38785A003878147E38774F7638770A6A",
      INIT_6E => X"387F1338387E4E6D387E0A1D387D4549387D0070387C3C12387B7730387B3248",
      INIT_6F => X"3903366E3902724739022E1C3901696C390125383900607E39001C41387F577F",
      INIT_70 => X"390758003907137D39064F7639060B6B3905475B3905034639043F2D39037B10",
      INIT_71 => X"390B7671390B3312390A6F2F390A2B483909675C3909236C39085F7739081B7D",
      INIT_72 => X"39101343390F5008390F0C49390E4905390E053D390D4171390C7E20390C3A4A",
      INIT_73 => X"39142D7939136A6239132746391264263912210139115D5839111A2B39105679",
      INIT_74 => X"39184615391803213917402839167D2B39163A2A391577243915341A3914710C",
      INIT_75 => X"391C5C1A391C1948391B5672391B1418391A513A391A0E5739194B7039190905",
      INIT_76 => X"3920700939202D5A391F6B27391F286F391E6634391E2374391D612F391D1E66",
      INIT_77 => X"3925016539243F5839237D4739233B32392279193922367B3921745939213233",
      INIT_78 => X"3929113039284F4539280D5639274B633927096C39264771392605713925436D",
      INIT_79 => X"392D1E6C392C5D23392C1B56392B5A05392B182F392A5656392A147839295316",
      INIT_7A => X"39312A1C3930687439302749392F6619392F2465392E632D392E2171392D6030",
      INIT_7B => X"393533413934723B393431303933702239332F0F39326D7939322C5E39316B3F",
      INIT_7C => X"39393A5E393879793938390F39377822393737303936763B3936354139357443",
      INIT_7D => X"393D3F75393C7F30393C3E67393B7E1B393B3D4A393A7C75393A3C1C39397B3F",
      INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_FILE => "NONE",
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 36,
      READ_WIDTH_B => 36,
      SIM_COLLISION_CHECK => "ALL",
      SIM_MODE => "SAFE",
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 36,
      WRITE_WIDTH_B => 36,
      INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000"
    )
    port map (
      ENAU => BU2_N1,
      ENAL => BU2_N1,
      ENBU => BU2_doutb(0),
      ENBL => BU2_doutb(0),
      SSRAU => BU2_doutb(0),
      SSRAL => BU2_doutb(0),
      SSRBU => BU2_doutb(0),
      SSRBL => BU2_doutb(0),
      CLKAU => clka,
      CLKAL => clka,
      CLKBU => BU2_doutb(0),
      CLKBL => BU2_doutb(0),
      REGCLKAU => clka,
      REGCLKAL => clka,
      REGCLKBU => BU2_doutb(0),
      REGCLKBL => BU2_doutb(0),
      REGCEAU => BU2_doutb(0),
      REGCEAL => BU2_doutb(0),
      REGCEBU => BU2_doutb(0),
      REGCEBL => BU2_doutb(0),
      CASCADEINLATA => BU2_doutb(0),
      CASCADEINLATB => BU2_doutb(0),
      CASCADEINREGA => BU2_doutb(0),
      CASCADEINREGB => BU2_doutb(0),
      CASCADEOUTLATA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATA_UNCONNECTED,
      CASCADEOUTLATB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTLATB_UNCONNECTED,
      CASCADEOUTREGA => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGA_UNCONNECTED,
      CASCADEOUTREGB => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_CASCADEOUTREGB_UNCONNECTED,
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
      DIPA(3) => BU2_doutb(0),
      DIPA(2) => BU2_doutb(0),
      DIPA(1) => BU2_doutb(0),
      DIPA(0) => BU2_doutb(0),
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
      DIPB(3) => BU2_doutb(0),
      DIPB(2) => BU2_doutb(0),
      DIPB(1) => BU2_doutb(0),
      DIPB(0) => BU2_doutb(0),
      ADDRAL(15) => BU2_doutb(0),
      ADDRAL(14) => addra_2(9),
      ADDRAL(13) => addra_2(8),
      ADDRAL(12) => addra_2(7),
      ADDRAL(11) => addra_2(6),
      ADDRAL(10) => addra_2(5),
      ADDRAL(9) => addra_2(4),
      ADDRAL(8) => addra_2(3),
      ADDRAL(7) => addra_2(2),
      ADDRAL(6) => addra_2(1),
      ADDRAL(5) => addra_2(0),
      ADDRAL(4) => BU2_doutb(0),
      ADDRAL(3) => BU2_doutb(0),
      ADDRAL(2) => BU2_doutb(0),
      ADDRAL(1) => BU2_doutb(0),
      ADDRAL(0) => BU2_doutb(0),
      ADDRAU(14) => addra_2(9),
      ADDRAU(13) => addra_2(8),
      ADDRAU(12) => addra_2(7),
      ADDRAU(11) => addra_2(6),
      ADDRAU(10) => addra_2(5),
      ADDRAU(9) => addra_2(4),
      ADDRAU(8) => addra_2(3),
      ADDRAU(7) => addra_2(2),
      ADDRAU(6) => addra_2(1),
      ADDRAU(5) => addra_2(0),
      ADDRAU(4) => BU2_doutb(0),
      ADDRAU(3) => BU2_doutb(0),
      ADDRAU(2) => BU2_doutb(0),
      ADDRAU(1) => BU2_doutb(0),
      ADDRAU(0) => BU2_doutb(0),
      ADDRBL(15) => BU2_doutb(0),
      ADDRBL(14) => BU2_doutb(0),
      ADDRBL(13) => BU2_doutb(0),
      ADDRBL(12) => BU2_doutb(0),
      ADDRBL(11) => BU2_doutb(0),
      ADDRBL(10) => BU2_doutb(0),
      ADDRBL(9) => BU2_doutb(0),
      ADDRBL(8) => BU2_doutb(0),
      ADDRBL(7) => BU2_doutb(0),
      ADDRBL(6) => BU2_doutb(0),
      ADDRBL(5) => BU2_doutb(0),
      ADDRBL(4) => BU2_doutb(0),
      ADDRBL(3) => BU2_doutb(0),
      ADDRBL(2) => BU2_doutb(0),
      ADDRBL(1) => BU2_doutb(0),
      ADDRBL(0) => BU2_doutb(0),
      ADDRBU(14) => BU2_doutb(0),
      ADDRBU(13) => BU2_doutb(0),
      ADDRBU(12) => BU2_doutb(0),
      ADDRBU(11) => BU2_doutb(0),
      ADDRBU(10) => BU2_doutb(0),
      ADDRBU(9) => BU2_doutb(0),
      ADDRBU(8) => BU2_doutb(0),
      ADDRBU(7) => BU2_doutb(0),
      ADDRBU(6) => BU2_doutb(0),
      ADDRBU(5) => BU2_doutb(0),
      ADDRBU(4) => BU2_doutb(0),
      ADDRBU(3) => BU2_doutb(0),
      ADDRBU(2) => BU2_doutb(0),
      ADDRBU(1) => BU2_doutb(0),
      ADDRBU(0) => BU2_doutb(0),
      WEAU(3) => BU2_doutb(0),
      WEAU(2) => BU2_doutb(0),
      WEAU(1) => BU2_doutb(0),
      WEAU(0) => BU2_doutb(0),
      WEAL(3) => BU2_doutb(0),
      WEAL(2) => BU2_doutb(0),
      WEAL(1) => BU2_doutb(0),
      WEAL(0) => BU2_doutb(0),
      WEBU(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_7_UNCONNECTED,
      WEBU(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_6_UNCONNECTED,
      WEBU(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_5_UNCONNECTED,
      WEBU(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBU_4_UNCONNECTED,
      WEBU(3) => BU2_doutb(0),
      WEBU(2) => BU2_doutb(0),
      WEBU(1) => BU2_doutb(0),
      WEBU(0) => BU2_doutb(0),
      WEBL(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_7_UNCONNECTED,
      WEBL(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_6_UNCONNECTED,
      WEBL(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_5_UNCONNECTED,
      WEBL(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_WEBL_4_UNCONNECTED,
      WEBL(3) => BU2_doutb(0),
      WEBL(2) => BU2_doutb(0),
      WEBL(1) => BU2_doutb(0),
      WEBL(0) => BU2_doutb(0),
      DOA(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_31_UNCONNECTED,
      DOA(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_30_UNCONNECTED,
      DOA(29) => douta_3(26),
      DOA(28) => douta_3(25),
      DOA(27) => douta_3(24),
      DOA(26) => douta_3(23),
      DOA(25) => douta_3(22),
      DOA(24) => douta_3(21),
      DOA(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_23_UNCONNECTED,
      DOA(22) => douta_3(20),
      DOA(21) => douta_3(19),
      DOA(20) => douta_3(18),
      DOA(19) => douta_3(17),
      DOA(18) => douta_3(16),
      DOA(17) => douta_3(15),
      DOA(16) => douta_3(14),
      DOA(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_15_UNCONNECTED,
      DOA(14) => douta_3(13),
      DOA(13) => douta_3(12),
      DOA(12) => douta_3(11),
      DOA(11) => douta_3(10),
      DOA(10) => douta_3(9),
      DOA(9) => douta_3(8),
      DOA(8) => douta_3(7),
      DOA(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOA_7_UNCONNECTED,
      DOA(6) => douta_3(6),
      DOA(5) => douta_3(5),
      DOA(4) => douta_3(4),
      DOA(3) => douta_3(3),
      DOA(2) => douta_3(2),
      DOA(1) => douta_3(1),
      DOA(0) => douta_3(0),
      DOPA(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_3_UNCONNECTED,
      DOPA(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_2_UNCONNECTED,
      DOPA(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_1_UNCONNECTED,
      DOPA(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPA_0_UNCONNECTED,
      DOB(31) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_31_UNCONNECTED,
      DOB(30) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_30_UNCONNECTED,
      DOB(29) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_29_UNCONNECTED,
      DOB(28) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_28_UNCONNECTED,
      DOB(27) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_27_UNCONNECTED,
      DOB(26) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_26_UNCONNECTED,
      DOB(25) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_25_UNCONNECTED,
      DOB(24) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_24_UNCONNECTED,
      DOB(23) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_23_UNCONNECTED,
      DOB(22) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_22_UNCONNECTED,
      DOB(21) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_21_UNCONNECTED,
      DOB(20) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_20_UNCONNECTED,
      DOB(19) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_19_UNCONNECTED,
      DOB(18) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_18_UNCONNECTED,
      DOB(17) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_17_UNCONNECTED,
      DOB(16) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_16_UNCONNECTED,
      DOB(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_15_UNCONNECTED,
      DOB(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_14_UNCONNECTED,
      DOB(13) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_13_UNCONNECTED,
      DOB(12) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_12_UNCONNECTED,
      DOB(11) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_11_UNCONNECTED,
      DOB(10) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_10_UNCONNECTED,
      DOB(9) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_9_UNCONNECTED,
      DOB(8) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_8_UNCONNECTED,
      DOB(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_7_UNCONNECTED,
      DOB(6) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_6_UNCONNECTED,
      DOB(5) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_5_UNCONNECTED,
      DOB(4) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_4_UNCONNECTED,
      DOB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_3_UNCONNECTED,
      DOB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_2_UNCONNECTED,
      DOB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_1_UNCONNECTED,
      DOB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOB_0_UNCONNECTED,
      DOPB(3) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_3_UNCONNECTED,
      DOPB(2) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_2_UNCONNECTED,
      DOPB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_SINGLE_PRIM36_SP_DOPB_0_UNCONNECTED
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
