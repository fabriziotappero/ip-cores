--------------------------------------------------------------------------------
-- Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: K.39
--  \   \         Application: netgen
--  /   /         Filename: mant_lut_MEM.vhd
-- /___/   /\     Timestamp: Fri Jul 24 13:57:08 2009
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
    addra : in STD_LOGIC_VECTOR ( 8 downto 0 ); 
    douta : out STD_LOGIC_VECTOR ( 26 downto 0 ) 
  );
end mant_lut_MEM;

architecture STRUCTURE of mant_lut_MEM is
  signal BU2_N1 : STD_LOGIC; 
  signal NLW_VCC_P_UNCONNECTED : STD_LOGIC; 
  signal NLW_GND_G_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOA_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOB_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOB_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOB_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOPA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOPA_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOPB_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOPB_0_UNCONNECTED : STD_LOGIC; 
  signal addra_2 : STD_LOGIC_VECTOR ( 8 downto 0 ); 
  signal douta_3 : STD_LOGIC_VECTOR ( 26 downto 0 ); 
  signal BU2_doutb : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
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
  BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP : RAMB18
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      INIT_A => X"00000",
      INIT_B => X"00000",
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      SRVAL_A => X"00000",
      INIT_00 => X"23390459223A6155213C1F38203D3D711E7C79641C7E3853197E7024137F4005",
      INIT_01 => X"2751237727130D0C265467112616317D25576D4A25191970245A3667241B4429",
      INIT_02 => X"295F202D294050382921791829031A48286434462845470E2826521C2807556C",
      INIT_03 => X"2B521A512B34043C2B1567182A7742602A5917112A3A64282A1C2A21297D6879",
      INIT_04 => X"2C6067202C51781A2C43055A2C340F5D2C2516222C1619272C07186B2B702958",
      INIT_05 => X"2D5664422D48105A2D3939452D2A5E7F2D1C01082D0D1F5E2C7E3B002C6F526C",
      INIT_06 => X"2E4B0B302E3C52052E2E15372E1F55452E11122F2E024B712D74020B2D65347C",
      INIT_07 => X"2F3D616C2F2F421E2F211F392F12793C2F0450262E7623752E6774272E59413B",
      INIT_08 => X"3017366B3010334630092E5A300228282F76405F2F682D5D2F5A174A2F4B7E25",
      INIT_09 => X"304F1A183048230930412A39303A302830333455302C374030253868301E384C",
      INIT_0A => X"31061D50307F322D3078454F30715735306A675E3063764A305D037830560F68",
      INIT_0B => X"313C43593135637A312F02663128201A31213C16311A565B31136F66310D0738",
      INIT_0C => X"31720E6A316B3A2A31646438315E0D143157343D31505A3331497E7431432201",
      INIT_0D => X"322701323220376B32196C7732132055320C530532060406317F335831786179",
      INIT_0E => X"325B1D5132545E60324E1E4632475D0232411A15323A557E3234103B322D494C",
      INIT_0F => X"330E655D3308311F33017B3D327B443532750C08326E52353268173B32615B1A",
      INIT_10 => X"33415B62333B31373335056B332E587E33282A7033217B40331B4A6D33151877",
      INIT_11 => X"33740162336D612A33673F5433611C62335A785333545325334E2C583348046D",
      INIT_12 => X"34126C6B340F6139340C553A3409486F34063B5734032D7234001F3F337A207E",
      INIT_13 => X"342B325634282B7F3425245E34221C72341F143B341C0B383419016A34157750",
      INIT_14 => X"344353263440511D343D4E4B343A4B2F3437474A3434431C34313E24342E3862",
      INIT_15 => X"345B4F4B345852023455537034525518344F5578344C56103449556034465467",
      INIT_16 => X"3473283134702F19346D353C346A3B1934674030346445003461490B345E4C4E",
      INIT_17 => X"350A5E3E3507694C3504741635017E1B347F075C347C10593479191034762103",
      INIT_18 => X"35217258351F017F351C106335191F0535162C643513397F35104658350D526D",
      INIT_19 => X"353865603535791435330C0735301E38352D3029352A41573527524435246270",
      INIT_1A => X"354F3833354C4F693549665E35467D143544130B35412840353E3D36353B516C",
      INIT_1B => X"35656B2D3563065835602146355D3B75355A556635576F183555080B3552203F",
      INIT_1C => X"357B7F2435791E3C35763D1635735B3335707914356E1636356B331B35684F43",
      INIT_1D => X"3611746E360F1767360C3A2436095C2536067D6A36041E7336013F40357E5F50",
      INIT_1E => X"36274C5E3624732E36221942361F3F1D361C643D361A092236172D4C3614513B",
      INIT_1F => X"363D0743363A315F36375B423635046D36322D5D362F5614362C7E11362A2555",
      INIT_20 => X"3652256A364F534A364D0072364A2D6236475A19364506193642315F363F5C6E",
      INIT_21 => X"3667281D3664593836620A1B365F3A48365C6A3D365A197C3657490336547752",
      INIT_22 => X"367C0F27367943733676780936742B6936715F13366F1207366C44453669764C",
      INIT_23 => X"37105B4C370E1340370B4B003709020C3706386237036F033701246F367E5A26",
      INIT_24 => X"37250D523722486637200348371D3D75371A776E3718313437156A4637132323",
      INIT_25 => X"3739257A373664263734222137315F68372F1C7D372C595F372A160E3727520A",
      INIT_26 => X"374D2504374A66413748274D374568263743284E37406844373E2808373B671A",
      INIT_27 => X"37610B30375E4F76375C140A3759576F37571B2237545E2437522076374F6316",
      INIT_28 => X"3774593A37722100376F6817376D2E7E376A753637683B3C376601143763463A",
      INIT_29 => X"3804076E38026D0E3801521738003708377E3744377C00483779491E37771144",
      INIT_2A => X"380D5728380C3E02380B2444380A0A70380871043807570238063C6838052236",
      INIT_2B => X"38171B273816033738146B303813531238123A5E3811221238100930380E7038",
      INIT_2C => X"38205406381F3D48381E2674381D100A381B7909381A617238194A4538183301",
      INIT_2D => X"382A016038286C513827572C3826417238252C223824163C3823004038216A2E",
      INIT_2E => X"3833244C3832106A38307C72382F6864382E5442382D400A382C2B3C382B1658",
      INIT_2F => X"383C3C66383B2A2C383A175E3839047A3837720238365E7438354B523834381A",
      INIT_30 => X"38454A4538443931384328093842164C3841047B383F7315383E611A383D4F0A",
      INIT_31 => X"384E4E00384D3E10384C2E0B384B1D72384A0D4538487D0438476C2E38465B44",
      INIT_32 => X"3857472F3856385F3855297B38541B0338530B7838517C5838506D24384F5D5C",
      INIT_33 => X"38603668385F2935385E1B6F385D0E16385C0029385A7228385964133858556B",
      INIT_34 => X"38691C40386810293867037E3865774038646A6F38635E0A3862511238614407",
      INIT_35 => X"3871784E38706D4F386F623C386E5717386D4B5F386C4014386B3436386A2845",
      INIT_36 => X"387A4B263879413C3878374038772D313876230F3875185B38740E143873033A",
      INIT_37 => X"3903145B39020C043901031C387F7A20387E7113387D6773387C5E41387B547D",
      INIT_38 => X"390B5502390A4D3C3909456439083D7B3907357F39062D713905255139041D1F",
      INIT_39 => X"39140C2E3913057639117F2D39107853390F7166390E6A68390D6358390C5C36",
      INIT_3A => X"391C3A71391B3546391A300939192A3B3918245C39171E6A3916186839151254",
      INIT_3B => X"3924605F39235C3D3922580B3921534739204E72391F4A0C391E4514391D400B",
      INIT_3C => X"392C7E08392B7A6E392A7743392974073928703B39276C5D3926686F3925646F",
      INIT_3D => X"3935127E3934106A39330E4539320C0F3931094839300671392F040A392E0111",
      INIT_3E => X"393D1F53393C1E41393B1D20393A1B6E39391A2C393818593937167639361502",
      INIT_3F => X"394524163944240639432366394223363941227539402225393F2145393E2054",
      INIT_FILE => "NONE",
      READ_WIDTH_A => 18,
      READ_WIDTH_B => 18,
      SIM_COLLISION_CHECK => "ALL",
      SIM_MODE => "SAFE",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 18,
      WRITE_WIDTH_B => 18,
      SRVAL_B => X"00000"
    )
    port map (
      CLKA => clka,
      CLKB => clka,
      ENA => BU2_N1,
      ENB => BU2_N1,
      REGCEA => BU2_doutb(0),
      REGCEB => BU2_doutb(0),
      SSRA => BU2_doutb(0),
      SSRB => BU2_doutb(0),
      ADDRA(13) => addra_2(8),
      ADDRA(12) => addra_2(7),
      ADDRA(11) => addra_2(6),
      ADDRA(10) => addra_2(5),
      ADDRA(9) => addra_2(4),
      ADDRA(8) => addra_2(3),
      ADDRA(7) => addra_2(2),
      ADDRA(6) => addra_2(1),
      ADDRA(5) => addra_2(0),
      ADDRA(4) => BU2_doutb(0),
      ADDRA(3) => BU2_doutb(0),
      ADDRA(2) => BU2_doutb(0),
      ADDRA(1) => BU2_doutb(0),
      ADDRA(0) => BU2_doutb(0),
      ADDRB(13) => addra_2(8),
      ADDRB(12) => addra_2(7),
      ADDRB(11) => addra_2(6),
      ADDRB(10) => addra_2(5),
      ADDRB(9) => addra_2(4),
      ADDRB(8) => addra_2(3),
      ADDRB(7) => addra_2(2),
      ADDRB(6) => addra_2(1),
      ADDRB(5) => addra_2(0),
      ADDRB(4) => BU2_N1,
      ADDRB(3) => BU2_doutb(0),
      ADDRB(2) => BU2_doutb(0),
      ADDRB(1) => BU2_doutb(0),
      ADDRB(0) => BU2_doutb(0),
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
      DIPA(1) => BU2_doutb(0),
      DIPA(0) => BU2_doutb(0),
      DIPB(1) => BU2_doutb(0),
      DIPB(0) => BU2_doutb(0),
      DOA(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOA_15_UNCONNECTED,
      DOA(14) => douta_3(13),
      DOA(13) => douta_3(12),
      DOA(12) => douta_3(11),
      DOA(11) => douta_3(10),
      DOA(10) => douta_3(9),
      DOA(9) => douta_3(8),
      DOA(8) => douta_3(7),
      DOA(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOA_7_UNCONNECTED,
      DOA(6) => douta_3(6),
      DOA(5) => douta_3(5),
      DOA(4) => douta_3(4),
      DOA(3) => douta_3(3),
      DOA(2) => douta_3(2),
      DOA(1) => douta_3(1),
      DOA(0) => douta_3(0),
      DOB(15) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOB_15_UNCONNECTED,
      DOB(14) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOB_14_UNCONNECTED,
      DOB(13) => douta_3(26),
      DOB(12) => douta_3(25),
      DOB(11) => douta_3(24),
      DOB(10) => douta_3(23),
      DOB(9) => douta_3(22),
      DOB(8) => douta_3(21),
      DOB(7) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOB_7_UNCONNECTED,
      DOB(6) => douta_3(20),
      DOB(5) => douta_3(19),
      DOB(4) => douta_3(18),
      DOB(3) => douta_3(17),
      DOB(2) => douta_3(16),
      DOB(1) => douta_3(15),
      DOB(0) => douta_3(14),
      DOPA(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOPA_1_UNCONNECTED,
      DOPA(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOPA_0_UNCONNECTED,
      DOPB(1) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOPB_1_UNCONNECTED,
      DOPB(0) => NLW_BU2_U0_blk_mem_generator_valid_cstr_ramloop_0_ram_r_v5_init_ram_SP_WIDE_PRIM18_SP_DOPB_0_UNCONNECTED,
      WEA(1) => BU2_doutb(0),
      WEA(0) => BU2_doutb(0),
      WEB(1) => BU2_doutb(0),
      WEB(0) => BU2_doutb(0)
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
