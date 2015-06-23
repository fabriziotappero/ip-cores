--------------------------------------------------------------------
--       Actel Axcelerator VITAL Library
--       NAME: axcelerator.vhd
--       DATE: Friday, February 11, 2005 
---------------------------------------------------------------------/

library IEEE;
use IEEE.std_logic_1164.all;
--pragma translate_off
use IEEE.VITAL_Timing.all;
--pragma translate_on

package COMPONENTS is

--pragma translate_off
constant DefaultTimingChecksOn : Boolean := True;
constant DefaultXGenerationOn : Boolean := False;
constant DefaultXon : Boolean := False;
constant DefaultMsgOn : Boolean := True;
--pragma translate_on



------ Component ADD1 ------
 component ADD1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		FCI		: in    STD_ULOGIC;
		S		: out    STD_ULOGIC;
		FCO		: out    STD_ULOGIC);
 end component;


------ Component AND2 ------
 component AND2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND2A ------
 component AND2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND2B ------
 component AND2B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND3 ------
 component AND3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND3A ------
 component AND3A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND3B ------
 component AND3B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND3C ------
 component AND3C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND4 ------
 component AND4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND4A ------
 component AND4A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND4B ------
 component AND4B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND4C ------
 component AND4C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND4D ------
 component AND4D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND5A ------
 component AND5A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND5B ------
 component AND5B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AND5C ------
 component AND5C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO1 ------
 component AO1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO10 ------
 component AO10
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO11 ------
 component AO11
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO12 ------
 component AO12
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO13 ------
 component AO13
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO14 ------
 component AO14
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO15 ------
 component AO15
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO16 ------
 component AO16
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO17 ------
 component AO17
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO18 ------
 component AO18
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO1A ------
 component AO1A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO1B ------
 component AO1B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO1C ------
 component AO1C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO1D ------
 component AO1D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO1E ------
 component AO1E
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO2 ------
 component AO2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO2A ------
 component AO2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO2B ------
 component AO2B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO2C ------
 component AO2C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO2D ------
 component AO2D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO2E ------
 component AO2E
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO3 ------
 component AO3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO3A ------
 component AO3A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO3B ------
 component AO3B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO3C ------
 component AO3C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO4A ------
 component AO4A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO5A ------
 component AO5A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO6 ------
 component AO6
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO6A ------
 component AO6A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO7 ------
 component AO7
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO8 ------
 component AO8
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AO9 ------
 component AO9
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI1 ------
 component AOI1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI1A ------
 component AOI1A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI1B ------
 component AOI1B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI1C ------
 component AOI1C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI1D ------
 component AOI1D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI2A ------
 component AOI2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI2B ------
 component AOI2B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI3A ------
 component AOI3A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI4 ------
 component AOI4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI4A ------
 component AOI4A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AOI5 ------
 component AOI5
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AFCNTECP1 ------
 component AFCNTECP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_UD_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_Q_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_UD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		Q		:  out STD_ULOGIC;
		UD		:  in    STD_ULOGIC;
		FCI		:  in    STD_ULOGIC;
		FCO		:  out    STD_ULOGIC);

 end component;


------ Component ARCNTECP1 ------
 component ARCNTECP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_UD_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_Q_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_UD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		Q		:  out STD_ULOGIC;
		UD		:  in    STD_ULOGIC;
		FCI		:  in    STD_ULOGIC;
		FCO		:  out    STD_ULOGIC);

 end component;


------ Component AFCNTELDCP1 ------
 component AFCNTELDCP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_UD_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_LD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_LD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_LD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_LD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_LD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_UD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		LD		:  in    STD_ULOGIC;
		Q		:  out STD_ULOGIC;
		UD		:  in    STD_ULOGIC;
		FCI		:  in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		FCO		:  out    STD_ULOGIC);

 end component;


------ Component ARCNTELDCP1 ------
 component ARCNTELDCP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_UD_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_LD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_LD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_LD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_LD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_LD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_UD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		LD		:  in    STD_ULOGIC;
		Q		:  out STD_ULOGIC;
		UD		:  in    STD_ULOGIC;
		FCI		:  in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		FCO		:  out    STD_ULOGIC);

 end component;


------ Component AX1 ------
 component AX1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AX1A ------
 component AX1A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AX1B ------
 component AX1B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AX1C ------
 component AX1C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AX1D ------
 component AX1D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AX1E ------
 component AX1E
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXO1 ------
 component AXO1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXO2 ------
 component AXO2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXO3 ------
 component AXO3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXO5 ------
 component AXO5
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXO6 ------
 component AXO6
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXO7 ------
 component AXO7
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXOI1 ------
 component AXOI1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXOI2 ------
 component AXOI2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXOI3 ------
 component AXOI3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXOI4 ------
 component AXOI4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXOI5 ------
 component AXOI5
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component AXOI7 ------
 component AXOI7
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF ------
 component BIBUF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_8 ------
 component BIBUF_S_8
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_8D ------
 component BIBUF_S_8D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_8U ------
 component BIBUF_S_8U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_12 ------
 component BIBUF_S_12
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_12D ------
 component BIBUF_S_12D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_12U ------
 component BIBUF_S_12U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_16 ------
 component BIBUF_S_16
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_16D ------
 component BIBUF_S_16D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_16U ------
 component BIBUF_S_16U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_24 ------
 component BIBUF_S_24
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_24D ------
 component BIBUF_S_24D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_S_24U ------
 component BIBUF_S_24U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_8 ------
 component BIBUF_F_8
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_8D ------
 component BIBUF_F_8D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_8U ------
 component BIBUF_F_8U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_12 ------
 component BIBUF_F_12
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_12D ------
 component BIBUF_F_12D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_12U ------
 component BIBUF_F_12U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_16 ------
 component BIBUF_F_16
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_16D ------
 component BIBUF_F_16D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_16U ------
 component BIBUF_F_16U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_24 ------
 component BIBUF_F_24
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_24D ------
 component BIBUF_F_24D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_F_24U ------
 component BIBUF_F_24U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_LVCMOS25 ------
 component BIBUF_LVCMOS25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_LVCMOS25D ------
 component BIBUF_LVCMOS25D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_LVCMOS25U ------
 component BIBUF_LVCMOS25U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_LVCMOS18 ------
 component BIBUF_LVCMOS18
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_LVCMOS18D ------
 component BIBUF_LVCMOS18D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_LVCMOS18U ------
 component BIBUF_LVCMOS18U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_LVCMOS15 ------
 component BIBUF_LVCMOS15
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_LVCMOS15D ------
 component BIBUF_LVCMOS15D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_LVCMOS15U ------
 component BIBUF_LVCMOS15U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_PCI ------
 component BIBUF_PCI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_PCIX ------
 component BIBUF_PCIX
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_GTLP33 ------
 component BIBUF_GTLP33
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_GTLP25 ------
 component BIBUF_GTLP25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BUFA ------
 component BUFA
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BUFD ------
 component BUFD
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBIBUF ------
 component CLKBIBUF
--pragma translate_off
    generic(
                TimingChecksOn:Boolean := True;
                Xon: Boolean := False;
                InstancePath: STRING :="*";
                MsgOn: Boolean := True;
                tpd_D_PAD               : VitalDelayType01 := (0.100 ns, 0.100 ns);
               tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
                tpd_PAD_Y               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_D_Y                 : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_E_Y                 : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tipd_D                  : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_E                  : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_PAD                : VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
                PAD             : inout  STD_ULOGIC;
                D               : in     STD_ULOGIC;
                E               : in     STD_ULOGIC;
                Y               : out    STD_ULOGIC);
 end component;


------ Component CLKBUF ------
 component CLKBUF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_LVCMOS25 ------
 component CLKBUF_LVCMOS25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_LVCMOS18 ------
 component CLKBUF_LVCMOS18
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_LVCMOS15 ------
 component CLKBUF_LVCMOS15
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_PCI ------
 component CLKBUF_PCI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_PCIX ------
 component CLKBUF_PCIX
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_GTLP33 ------
 component CLKBUF_GTLP33
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_GTLP25 ------
 component CLKBUF_GTLP25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_HSTL_I ------
 component CLKBUF_HSTL_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_SSTL3_I ------
 component CLKBUF_SSTL3_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_SSTL3_II ------
 component CLKBUF_SSTL3_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_SSTL2_I ------
 component CLKBUF_SSTL2_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKBUF_SSTL2_II ------
 component CLKBUF_SSTL2_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CM7 ------
 component CM7
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S0		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CM8 ------
 component CM8
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CM8BUFF ------
 component CM8BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
                tpw_A_posedge   : VitalDelayType := 0.000 ns;
                tpw_A_negedge   : VitalDelayType := 0.000 ns;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CM8INV ------
 component CM8INV
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMA9 ------
 component CMA9
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMAF ------
 component CMAF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMB3 ------
 component CMB3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMB7 ------
 component CMB7
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMBB ------
 component CMBB
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMBF ------
 component CMBF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMEA ------
 component CMEA
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		DB		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMEB ------
 component CMEB
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMEE ------
 component CMEE
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		DB		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMEF ------
 component CMEF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMF1 ------
 component CMF1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMF2 ------
 component CMF2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		DB		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMF3 ------
 component CMF3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMF4 ------
 component CMF4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		DB		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMF5 ------
 component CMF5
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMF6 ------
 component CMF6
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		DB		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMF7 ------
 component CMF7
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMF8 ------
 component CMF8
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		DB		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMF9 ------
 component CMF9
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMFA ------
 component CMFA
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		DB		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMFB ------
 component CMFB
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMFC ------
 component CMFC
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		DB		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMFD ------
 component CMFD
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		DB		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CMFE ------
 component CMFE
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_DB_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S00_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S01_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_DB		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S00		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S01		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		DB		: in    STD_ULOGIC;
		S00		: in    STD_ULOGIC;
		S01		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S10		: in    STD_ULOGIC;
		S11		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CS1 ------
 component CS1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		S		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CS2 ------
 component CS2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		S		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CY2A ------
 component CY2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B0		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A1		: in    STD_ULOGIC;
		B1		: in    STD_ULOGIC;
		A0		: in    STD_ULOGIC;
		B0		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CY2B ------
 component CY2B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B0		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A1		: in    STD_ULOGIC;
		B1		: in    STD_ULOGIC;
		A0		: in    STD_ULOGIC;
		B0		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component DF1 ------
 component DF1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DF1_CC ------
 component DF1_CC
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DF1B ------
 component DF1B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFC1B ------
 component DFC1B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFC1B_CC ------
 component DFC1B_CC
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFC1D ------
 component DFC1D
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFE1C ------
 component DFE1C
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFE1B ------
 component DFE1B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFE3C ------
 component DFE3C
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFE3D ------
 component DFE3D
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFE4F ------
 component DFE4F
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFE4G ------
 component DFE4G
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFEG ------
 component DFEG
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFEH ------
 component DFEH
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFP1 ------
 component DFP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_posedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFP1A ------
 component DFP1A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_posedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFP1B ------
 component DFP1B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFP1B_CC ------
 component DFP1B_CC
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFP1D ------
 component DFP1D
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFPC ------
 component DFPC
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFPCB ------
 component DFPCB
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFPCC ------
 component DFPCC
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DL1 ------
 component DL1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DL1A ------
 component DL1A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		QN		:  out    STD_ULOGIC);

 end component;


------ Component DL1B ------
 component DL1B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DL1C ------
 component DL1C
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		QN		:  out    STD_ULOGIC);

 end component;


------ Component DL2A ------
 component DL2A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_PRE_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DL2C ------
 component DL2C
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_PRE_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLC ------
 component DLC
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLC1 ------
 component DLC1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_CLR_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLC1A ------
 component DLC1A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLC1F ------
 component DLC1F
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_CLR_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		QN		:  out    STD_ULOGIC);

 end component;


------ Component DLC1G ------
 component DLC1G
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		QN		:  out    STD_ULOGIC);

 end component;


------ Component DLCA ------
 component DLCA
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLE ------
 component DLE
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLE1D ------
 component DLE1D
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		QN		:  out    STD_ULOGIC);

 end component;


------ Component DLE2B ------
 component DLE2B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLE2C ------
 component DLE2C
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLE3B ------
 component DLE3B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_PRE_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLE3C ------
 component DLE3C
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLEA ------
 component DLEA
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLEB ------
 component DLEB
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLEC ------
 component DLEC
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLM ------
 component DLM
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_A_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		A		:  in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLM2 ------
 component DLM2
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_A_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		A		:  in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLM2B ------
 component DLM2B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_A_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		A		:  in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		CLR		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLM3 ------
 component DLM3
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D0_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S0_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S1_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D0_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D0_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D0_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D0_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S0_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S0_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S0_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S0_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D1_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D1_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D1_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D1_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S1_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S1_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S1_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S1_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D2_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D2_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D2_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D2_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D3_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D3_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D3_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D3_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D0		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S0		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S1		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D0		:  in    STD_ULOGIC;
		S0		:  in    STD_ULOGIC;
		D1		:  in    STD_ULOGIC;
		S1		:  in    STD_ULOGIC;
		D2		:  in    STD_ULOGIC;
		D3		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLM3A ------
 component DLM3A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D0_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S0_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S1_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D0_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D0_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D0_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D0_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S0_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S0_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S0_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S0_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D1_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D1_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D1_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D1_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S1_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S1_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S1_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S1_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D2_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D2_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D2_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D2_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D3_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D3_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D3_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D3_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D0		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S0		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S1		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D0		:  in    STD_ULOGIC;
		S0		:  in    STD_ULOGIC;
		D1		:  in    STD_ULOGIC;
		S1		:  in    STD_ULOGIC;
		D2		:  in    STD_ULOGIC;
		D3		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLM4 ------
 component DLM4
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S0_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D0_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S10_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S10_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S10_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S10_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S11_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S11_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S11_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S11_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S0_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S0_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S0_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S0_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D0_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D0_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D0_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D0_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D1_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D1_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D1_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D1_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D2_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D2_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D2_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D2_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D3_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D3_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D3_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D3_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S0		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D0		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		S10		:  in    STD_ULOGIC;
		S11		:  in    STD_ULOGIC;
		S0		:  in    STD_ULOGIC;
		D0		:  in    STD_ULOGIC;
		D1		:  in    STD_ULOGIC;
		D2		:  in    STD_ULOGIC;
		D3		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLM4A ------
 component DLM4A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S10_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S11_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S0_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D0_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S10_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S10_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S10_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S10_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S11_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S11_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S11_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S11_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S0_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S0_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S0_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S0_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D0_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D0_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D0_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D0_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D1_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D1_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D1_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D1_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D2_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D2_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D2_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D2_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D3_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D3_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D3_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D3_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S10		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S11		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S0		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D0		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		S10		:  in    STD_ULOGIC;
		S11		:  in    STD_ULOGIC;
		S0		:  in    STD_ULOGIC;
		D0		:  in    STD_ULOGIC;
		D1		:  in    STD_ULOGIC;
		D2		:  in    STD_ULOGIC;
		D3		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLMA ------
 component DLMA
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_A_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		A		:  in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLME1A ------
 component DLME1A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_A_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_E_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_E_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_E_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		A		:  in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		E		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLP1 ------
 component DLP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_PRE_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLP1A ------
 component DLP1A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_PRE_posedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLP1B ------
 component DLP1B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLP1C ------
 component DLP1C
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DLP1D ------
 component DLP1D
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_negedge		:VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_posedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		QN		:  out    STD_ULOGIC);

 end component;


------ Component DLP1E ------
 component DLP1E
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_QN		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_G_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_G_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tperiod_G_posedge		:  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_G_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		D		:  in    STD_ULOGIC;
		PRE		:  in    STD_ULOGIC;
		G		:  in    STD_ULOGIC;
		QN		:  out    STD_ULOGIC);

 end component;


------ Component FA1 ------
 component FA1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CI_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CI_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CI		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		CI		: in    STD_ULOGIC;
		S		: out    STD_ULOGIC;
		CO		: out    STD_ULOGIC);
 end component;


------ Component FCEND_BUFF ------
 component FCEND_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_FCI_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_FCI		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		FCI		: in    STD_ULOGIC;
		CO		: out    STD_ULOGIC);
 end component;


------ Component FCEND_INV ------
 component FCEND_INV
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_FCI_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_FCI		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		FCI		: in    STD_ULOGIC;
		CO		: out    STD_ULOGIC);
 end component;


------ Component FCINIT_BUFF ------
 component FCINIT_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		FCO		: out    STD_ULOGIC);
 end component;


------ Component FCINIT_GND ------
 component FCINIT_GND
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True		);
--pragma translate_on
    port(
		FCO		: out    STD_ULOGIC);
 end component;


------ Component FCINIT_INV ------
 component FCINIT_INV
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		FCO		: out    STD_ULOGIC);
 end component;


------ Component FCINIT_VCC ------
 component FCINIT_VCC
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True		);
--pragma translate_on
    port(
		FCO		: out    STD_ULOGIC);
 end component;


------ Component GAND2 ------
 component GAND2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		G		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component GMX4 ------
 component GMX4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S0		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		G		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component GNAND2 ------
 component GNAND2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		G		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component GND ------
 component GND
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True		);
--pragma translate_on
    port(
		Y		: out    STD_ULOGIC);
 end component;


------ Component GNOR2 ------
 component GNOR2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		G		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component GOR2 ------
 component GOR2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		G		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component GXOR2 ------
 component GXOR2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_G_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_G		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		G		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HA1 ------
 component HA1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		S		: out    STD_ULOGIC;
		CO		: out    STD_ULOGIC);
 end component;


------ Component HA1A ------
 component HA1A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		S		: out    STD_ULOGIC;
		CO		: out    STD_ULOGIC);
 end component;


------ Component HA1B ------
 component HA1B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		S		: out    STD_ULOGIC;
		CO		: out    STD_ULOGIC);
 end component;


------ Component HA1C ------
 component HA1C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_CO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		S		: out    STD_ULOGIC;
		CO		: out    STD_ULOGIC);
 end component;


------ Component HCLKBIBUF ------
 component HCLKBIBUF
--pragma translate_off
    generic(
                TimingChecksOn:Boolean := True;
                Xon: Boolean := False;
                InstancePath: STRING :="*";
                MsgOn: Boolean := True;
                tpd_D_PAD               : VitalDelayType01 := (0.100 ns, 0.100 ns);
               tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
                tpd_PAD_Y               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_D_Y                 : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_E_Y                 : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tipd_D                  : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_E                  : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_PAD                : VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
                PAD             : inout  STD_ULOGIC;
                D               : in     STD_ULOGIC;
                E               : in     STD_ULOGIC;
                Y               : out    STD_ULOGIC);
 end component;


------ Component HCLKBUF ------
 component HCLKBUF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_LVCMOS25 ------
 component HCLKBUF_LVCMOS25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_LVCMOS18 ------
 component HCLKBUF_LVCMOS18
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_LVCMOS15 ------
 component HCLKBUF_LVCMOS15
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_PCI ------
 component HCLKBUF_PCI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_PCIX ------
 component HCLKBUF_PCIX
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_GTLP33 ------
 component HCLKBUF_GTLP33
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_GTLP25 ------
 component HCLKBUF_GTLP25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_HSTL_I ------
 component HCLKBUF_HSTL_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_SSTL3_I ------
 component HCLKBUF_SSTL3_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_SSTL3_II ------
 component HCLKBUF_SSTL3_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_SSTL2_I ------
 component HCLKBUF_SSTL2_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKBUF_SSTL2_II ------
 component HCLKBUF_SSTL2_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component HCLKINT ------
 component HCLKINT
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF ------
 component INBUF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_LVCMOS25 ------
 component INBUF_LVCMOS25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_LVCMOS25D ------
 component INBUF_LVCMOS25D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_LVCMOS25U ------
 component INBUF_LVCMOS25U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_LVCMOS18 ------
 component INBUF_LVCMOS18
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_LVCMOS18D ------
 component INBUF_LVCMOS18D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_LVCMOS18U ------
 component INBUF_LVCMOS18U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_LVCMOS15 ------
 component INBUF_LVCMOS15
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_LVCMOS15D ------
 component INBUF_LVCMOS15D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_LVCMOS15U ------
 component INBUF_LVCMOS15U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_PCI ------
 component INBUF_PCI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_PCIX ------
 component INBUF_PCIX
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_GTLP33 ------
 component INBUF_GTLP33
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_GTLP25 ------
 component INBUF_GTLP25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_HSTL_I ------
 component INBUF_HSTL_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_SSTL3_I ------
 component INBUF_SSTL3_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_SSTL3_II ------
 component INBUF_SSTL3_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_SSTL2_I ------
 component INBUF_SSTL2_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INBUF_SSTL2_II ------
 component INBUF_SSTL2_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INV ------
 component INV
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INVA ------
 component INVA
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component INVD ------
 component INVD
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOI_DFEG ------
 component IOI_DFEG
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component IOI_DFEH ------
 component IOI_DFEH
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component IOI_BUFF ------
 component IOI_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOOE_BUFF ------
 component IOOE_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOOE_DFEG ------
 component IOOE_DFEG
	generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_PRE_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_YOUT	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_PRE_YOUT	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_YOUT	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_posedge   :   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge   :   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge	:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge       :   VitalDelayType := 0.000 ns;
		tperiod_CLK_negedge        :  VitalDelayType := 0.000 ns;
		tpw_CLK_posedge        :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge        :  VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge	:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge	:   VitalDelayType := 0.000 ns;
		tpw_CLR_negedge	:  VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge   :   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge   :   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge	:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge       :   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge	:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge	:   VitalDelayType := 0.000 ns;
		tpw_PRE_negedge	:  VitalDelayType := 0.000 ns;
		tipd_D :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PRE :   VitalDelayType01 := (0.000 ns, 0.000 ns));
--pragma translate_on
    port(
                D         : in    STD_ULOGIC;
                CLK         : in    STD_ULOGIC;
                CLR         : in    STD_ULOGIC;
                E         : in    STD_ULOGIC;
                PRE         : in    STD_ULOGIC;
                Q                : out    STD_ULOGIC;
                YOUT                : out    STD_ULOGIC);
 end component;


------ Component IOOE_DFEH ------
 component IOOE_DFEH
	generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_PRE_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_YOUT	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_PRE_YOUT	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_YOUT	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_D_CLK_posedge_negedge   :   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge   :   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge	:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge       :   VitalDelayType := 0.000 ns;
		tperiod_CLK_negedge        :  VitalDelayType := 0.000 ns;
		tpw_CLK_posedge        :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge        :  VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge	:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge	:   VitalDelayType := 0.000 ns;
		tpw_CLR_negedge	:  VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge   :   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge   :   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge	:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge       :   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge	:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge	:   VitalDelayType := 0.000 ns;
		tpw_PRE_negedge	:  VitalDelayType := 0.000 ns;
		tipd_D :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PRE :   VitalDelayType01 := (0.000 ns, 0.000 ns));
--pragma translate_on
    port(
                D         : in    STD_ULOGIC;
                CLK         : in    STD_ULOGIC;
                CLR         : in    STD_ULOGIC;
                E         : in    STD_ULOGIC;
                PRE         : in    STD_ULOGIC;
                Q                : out    STD_ULOGIC;
                YOUT                : out    STD_ULOGIC);
 end component;


------ Component IOPAD_IN ------
 component IOPAD_IN
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
-- DNW: Add the following 2 lines
		tpw_PAD_posedge		: VitalDelayType := 0.000 ns;
		tpw_PAD_negedge		: VitalDelayType := 0.000 ns;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOPAD_TRI ------
 component IOPAD_TRI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpw_D_posedge	: VitalDelayType := 0.000 ns;
		tpw_D_negedge	: VitalDelayType := 0.000 ns;
		tpw_E_posedge   : VitalDelayType := 0.000 ns;
		tpw_E_negedge	: VitalDelayType := 0.000 ns;

		tpd_D_PAD       : VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD	: VitalDelayType01Z := (0.100 ns, 0.100 ns, 0.100 ns, 0.100 ns, 0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component IOPAD_BI ------
 component IOPAD_BI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		
                tpw_D_posedge           : VitalDelayType := 0.000 ns;
                tpw_D_negedge           : VitalDelayType := 0.000 ns;
                tpw_E_posedge           : VitalDelayType := 0.000 ns;
                tpw_E_negedge           : VitalDelayType := 0.000 ns;
                tpw_PAD_negedge         : VitalDelayType := 0.000 ns;
                tpw_PAD_posedge         : VitalDelayType := 0.000 ns;
  
                tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component JKF ------
 component JKF
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_J_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_J_CLK_posedge_posedge   :   VitalDelayType := 0.000 ns;
		tsetup_J_CLK_negedge_posedge           :   VitalDelayType := 0.000 ns;
		thold_J_CLK_negedge_posedge   :   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_K_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_negedge_posedge           :   VitalDelayType := 0.000 ns;
		thold_K_CLK_negedge_posedge           :   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge		:  VitalDelayType := 0.000 ns;
		tipd_J      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_K      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK	:   VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		J	:  in    STD_ULOGIC;
		K	:  in    STD_ULOGIC;
	        CLK	:  in    STD_ULOGIC;
		Q	:  out    STD_ULOGIC);

 end component;


------ Component JKF1B ------
 component JKF1B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_J_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_J_CLK_posedge_negedge   :   VitalDelayType := 0.000 ns;
		tsetup_J_CLK_negedge_negedge           :   VitalDelayType := 0.000 ns;
		thold_J_CLK_negedge_negedge   :   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_K_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_negedge_negedge           :   VitalDelayType := 0.000 ns;
		thold_K_CLK_negedge_negedge           :   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge		:  VitalDelayType := 0.000 ns;
		tipd_J      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_K      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK	:   VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		J	:  in    STD_ULOGIC;
		K	:  in    STD_ULOGIC;
	        CLK	:  in    STD_ULOGIC;
		Q	:  out    STD_ULOGIC);

 end component;


------ Component JKF2A ------
 component JKF2A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_J_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_J_CLK_posedge_posedge   :   VitalDelayType := 0.000 ns;
		tsetup_J_CLK_negedge_posedge           :   VitalDelayType := 0.000 ns;
		thold_J_CLK_negedge_posedge   :   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_K_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_negedge_posedge           :   VitalDelayType := 0.000 ns;
		thold_K_CLK_negedge_posedge           :   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge	:  VitalDelayType := 0.000 ns;
		tipd_CLR	:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_J      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_K      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK	:   VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		J	:  in    STD_ULOGIC;
		K	:  in    STD_ULOGIC;
	        CLR	:  in    STD_ULOGIC;
	        CLK	:  in    STD_ULOGIC;
		Q	:  out    STD_ULOGIC);

 end component;


------ Component JKF2B ------
 component JKF2B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_J_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_J_CLK_posedge_negedge   :   VitalDelayType := 0.000 ns;
		tsetup_J_CLK_negedge_negedge           :   VitalDelayType := 0.000 ns;
		thold_J_CLK_negedge_negedge   :   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_K_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_negedge_negedge           :   VitalDelayType := 0.000 ns;
		thold_K_CLK_negedge_negedge           :   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge           :   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge	:  VitalDelayType := 0.000 ns;
		tipd_CLR	:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_J      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_K      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK	:   VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		J	:  in    STD_ULOGIC;
		K	:  in    STD_ULOGIC;
	        CLR	:  in    STD_ULOGIC;
	        CLK	:  in    STD_ULOGIC;
		Q	:  out    STD_ULOGIC);

 end component;


------ Component JKF3A ------
 component JKF3A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_J_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_J_CLK_posedge_posedge   :   VitalDelayType := 0.000 ns;
		tsetup_J_CLK_negedge_posedge           :   VitalDelayType := 0.000 ns;
		thold_J_CLK_negedge_posedge   :   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_K_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_negedge_posedge           :   VitalDelayType := 0.000 ns;
		thold_K_CLK_negedge_posedge           :   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge   	:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge		:  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE	:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_J      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_K      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK	:   VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		J	:  in    STD_ULOGIC;
		K	:  in    STD_ULOGIC;
	        PRE	:  in    STD_ULOGIC;
	        CLK	:  in    STD_ULOGIC;
		Q	:  out    STD_ULOGIC);

 end component;


------ Component JKF3B ------
 component JKF3B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_J_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_J_CLK_posedge_negedge   :   VitalDelayType := 0.000 ns;
		tsetup_J_CLK_negedge_negedge           :   VitalDelayType := 0.000 ns;
		thold_J_CLK_negedge_negedge   :   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_K_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_K_CLK_negedge_negedge           :   VitalDelayType := 0.000 ns;
		thold_K_CLK_negedge_negedge           :   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge   	:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge		:  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge		:  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE	:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_J      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_K      :   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK	:   VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		J	:  in    STD_ULOGIC;
		K	:  in    STD_ULOGIC;
	        PRE	:  in    STD_ULOGIC;
	        CLK	:  in    STD_ULOGIC;
		Q	:  out    STD_ULOGIC);

 end component;


------ Component MAJ3 ------
 component MAJ3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MAJ3X ------
 component MAJ3X
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MAJ3XI ------
 component MAJ3XI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MIN3 ------
 component MIN3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MIN3X ------
 component MIN3X
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MIN3XI ------
 component MIN3XI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MULT1 ------
 component MULT1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_PO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_PO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_PI_PO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_PO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_PI_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PI		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		PI		: in    STD_ULOGIC;
		FCI		: in    STD_ULOGIC;
		PO		: out    STD_ULOGIC;
		FCO		: out    STD_ULOGIC);
 end component;


------ Component MX2 ------
 component MX2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		S		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MX2A ------
 component MX2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		S		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MX2B ------
 component MX2B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		S		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MX2C ------
 component MX2C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		S		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component MX4 ------
 component MX4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S0_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_S1_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D2_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D3_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S0		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S1		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D2		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D3		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D0		: in    STD_ULOGIC;
		S0		: in    STD_ULOGIC;
		D1		: in    STD_ULOGIC;
		S1		: in    STD_ULOGIC;
		D2		: in    STD_ULOGIC;
		D3		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND2 ------
 component NAND2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND2A ------
 component NAND2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND2B ------
 component NAND2B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND3 ------
 component NAND3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND3A ------
 component NAND3A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND3B ------
 component NAND3B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND3C ------
 component NAND3C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND4 ------
 component NAND4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND4A ------
 component NAND4A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND4B ------
 component NAND4B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND4C ------
 component NAND4C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND4D ------
 component NAND4D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND5B ------
 component NAND5B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NAND5C ------
 component NAND5C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR2 ------
 component NOR2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR2A ------
 component NOR2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR2B ------
 component NOR2B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR3 ------
 component NOR3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR3A ------
 component NOR3A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR3B ------
 component NOR3B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR3C ------
 component NOR3C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR4 ------
 component NOR4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR4A ------
 component NOR4A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR4B ------
 component NOR4B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR4C ------
 component NOR4C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR4D ------
 component NOR4D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR5B ------
 component NOR5B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component NOR5C ------
 component NOR5C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA1 ------
 component OA1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA1A ------
 component OA1A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA1B ------
 component OA1B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		C		: in    STD_ULOGIC;
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA1C ------
 component OA1C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		C		: in    STD_ULOGIC;
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA2 ------
 component OA2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA2A ------
 component OA2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA3 ------
 component OA3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA3A ------
 component OA3A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA3B ------
 component OA3B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA4 ------
 component OA4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA4A ------
 component OA4A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OA5 ------
 component OA5
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OAI1 ------
 component OAI1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OAI2A ------
 component OAI2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OAI3 ------
 component OAI3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OAI3A ------
 component OAI3A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR2 ------
 component OR2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR2A ------
 component OR2A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR2B ------
 component OR2B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR3 ------
 component OR3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR3A ------
 component OR3A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR3B ------
 component OR3B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR3C ------
 component OR3C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR4 ------
 component OR4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR4A ------
 component OR4A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR4B ------
 component OR4B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR4C ------
 component OR4C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR4D ------
 component OR4D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR5A ------
 component OR5A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR5B ------
 component OR5B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OR5C ------
 component OR5C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF ------
 component OUTBUF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_S_8 ------
 component OUTBUF_S_8
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_S_12 ------
 component OUTBUF_S_12
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_S_16 ------
 component OUTBUF_S_16
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_S_24 ------
 component OUTBUF_S_24
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_F_8 ------
 component OUTBUF_F_8
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_F_12 ------
 component OUTBUF_F_12
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_F_16 ------
 component OUTBUF_F_16
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_F_24 ------
 component OUTBUF_F_24
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_LVCMOS25 ------
 component OUTBUF_LVCMOS25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_LVCMOS18 ------
 component OUTBUF_LVCMOS18
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_LVCMOS15 ------
 component OUTBUF_LVCMOS15
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_PCI ------
 component OUTBUF_PCI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_PCIX ------
 component OUTBUF_PCIX
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_GTLP33 ------
 component OUTBUF_GTLP33
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_GTLP25 ------
 component OUTBUF_GTLP25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_HSTL_I ------
 component OUTBUF_HSTL_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_SSTL3_I ------
 component OUTBUF_SSTL3_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_SSTL3_II ------
 component OUTBUF_SSTL3_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_SSTL2_I ------
 component OUTBUF_SSTL2_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component OUTBUF_SSTL2_II ------
 component OUTBUF_SSTL2_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component PLLHCLK ------
 component PLLHCLK
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component PLLRCLK ------
 component PLLRCLK
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component SFCNTECP1 ------
 component SFCNTECP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_UD_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_Q_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_UD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		Q		:  out STD_ULOGIC;
		UD		:  in    STD_ULOGIC;
		FCI		:  in    STD_ULOGIC;
		FCO		:  out    STD_ULOGIC);

 end component;


------ Component SRCNTECP1 ------
 component SRCNTECP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_UD_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_Q_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_UD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		Q		:  out STD_ULOGIC;
		UD		:  in    STD_ULOGIC;
		FCI		:  in    STD_ULOGIC;
		FCO		:  out    STD_ULOGIC);

 end component;


------ Component SFCNTELDCP1 ------
 component SFCNTELDCP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_UD_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_Q_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_LD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_LD_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_LD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_LD_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_UD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_LD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		Q		:  out STD_ULOGIC;
		UD		:  in    STD_ULOGIC;
		FCI		:  in    STD_ULOGIC;
		LD		:  in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		FCO		:  out    STD_ULOGIC);

 end component;


------ Component SRCNTELDCP1 ------
 component SRCNTELDCP1
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_UD_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		:   VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_Q_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_LD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_LD_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_Q_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_Q_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_UD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_UD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_FCI_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_FCI_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_LD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_LD_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_D_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_UD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_LD		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		Q		:  out STD_ULOGIC;
		UD		:  in    STD_ULOGIC;
		FCI		:  in    STD_ULOGIC;
		LD		:  in    STD_ULOGIC;
		D		:  in    STD_ULOGIC;
		FCO		:  out    STD_ULOGIC);

 end component;


------ Component SUB1 ------
 component SUB1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_S		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_A_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_FCO		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		FCI		: in    STD_ULOGIC;
		S		: out    STD_ULOGIC;
		FCO		: out    STD_ULOGIC);
 end component;


------ Component TF1A ------
 component TF1A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_T_CLK_negedge_posedge	:   VitalDelayType := 0.000 ns;
		thold_T_CLK_negedge_posedge	:   VitalDelayType := 0.000 ns;
		tsetup_T_CLK_posedge_posedge   :   VitalDelayType := 0.000 ns;
		thold_T_CLK_posedge_posedge   :   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge	:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge	:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge	:  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge	:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge	:  VitalDelayType := 0.000 ns;
		tipd_CLK	:  VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR	:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_T	:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		T	:  in    STD_ULOGIC;
		CLR	:  in    STD_ULOGIC;
	        CLK	:  in    STD_ULOGIC;
		Q	:  out    STD_ULOGIC);

 end component;


------ Component TF1B ------
 component TF1B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q	:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_T_CLK_negedge_negedge	:   VitalDelayType := 0.000 ns;
		thold_T_CLK_negedge_negedge	:   VitalDelayType := 0.000 ns;
		tsetup_T_CLK_posedge_negedge   :   VitalDelayType := 0.000 ns;
		thold_T_CLK_posedge_negedge   :   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge	:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge	:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge	:  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge	:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge	:  VitalDelayType := 0.000 ns;
		tipd_CLK	:  VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR	:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_T	:   VitalDelayType01 := (0.000 ns, 0.000 ns));


 --pragma translate_on
    port(
		T	:  in    STD_ULOGIC;
		CLR	:  in    STD_ULOGIC;
	        CLK	:  in    STD_ULOGIC;
		Q	:  out    STD_ULOGIC);

 end component;


------ Component TRIBUFF ------
 component TRIBUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_8 ------
 component TRIBUFF_S_8
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_8D ------
 component TRIBUFF_S_8D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_8U ------
 component TRIBUFF_S_8U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_12 ------
 component TRIBUFF_S_12
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_12D ------
 component TRIBUFF_S_12D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_12U ------
 component TRIBUFF_S_12U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_16 ------
 component TRIBUFF_S_16
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_16D ------
 component TRIBUFF_S_16D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_16U ------
 component TRIBUFF_S_16U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_24 ------
 component TRIBUFF_S_24
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_24D ------
 component TRIBUFF_S_24D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_S_24U ------
 component TRIBUFF_S_24U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_8 ------
 component TRIBUFF_F_8
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_8D ------
 component TRIBUFF_F_8D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_8U ------
 component TRIBUFF_F_8U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_12 ------
 component TRIBUFF_F_12
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_12D ------
 component TRIBUFF_F_12D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_12U ------
 component TRIBUFF_F_12U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_16 ------
 component TRIBUFF_F_16
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_16D ------
 component TRIBUFF_F_16D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_16U ------
 component TRIBUFF_F_16U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_24 ------
 component TRIBUFF_F_24
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_24D ------
 component TRIBUFF_F_24D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_F_24U ------
 component TRIBUFF_F_24U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_LVCMOS25 ------
 component TRIBUFF_LVCMOS25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_LVCMOS25D ------
 component TRIBUFF_LVCMOS25D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_LVCMOS25U ------
 component TRIBUFF_LVCMOS25U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_LVCMOS18 ------
 component TRIBUFF_LVCMOS18
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_LVCMOS18D ------
 component TRIBUFF_LVCMOS18D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_LVCMOS18U ------
 component TRIBUFF_LVCMOS18U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_LVCMOS15 ------
 component TRIBUFF_LVCMOS15
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_LVCMOS15D ------
 component TRIBUFF_LVCMOS15D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_LVCMOS15U ------
 component TRIBUFF_LVCMOS15U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_PCI ------
 component TRIBUFF_PCI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_PCIX ------
 component TRIBUFF_PCIX
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_GTLP33 ------
 component TRIBUFF_GTLP33
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_GTLP25 ------
 component TRIBUFF_GTLP25
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component VCC ------
 component VCC
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True		);
--pragma translate_on
    port(
		Y		: out    STD_ULOGIC);
 end component;


------ Component XA1 ------
 component XA1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XA1A ------
 component XA1A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XA1B ------
 component XA1B
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XA1C ------
 component XA1C
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XAI1 ------
 component XAI1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XAI1A ------
 component XAI1A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XNOR2 ------
 component XNOR2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XNOR3 ------
 component XNOR3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XNOR4 ------
 component XNOR4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XO1 ------
 component XO1
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XO1A ------
 component XO1A
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XOR2 ------
 component XOR2
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XOR3 ------
 component XOR3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XOR4 ------
 component XOR4
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		D		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component XOR4_FCI ------
 component XOR4_FCI
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_FCI_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_FCI		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		FCI		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component ZOR3 ------
 component ZOR3
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component ZOR3I ------
 component ZOR3I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_B_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_C_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_C		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		B		: in    STD_ULOGIC;
		C		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOFIFO_BIBUF ------
 component IOFIFO_BIBUF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_AIN_YIN		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_AOUT_YOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_AIN		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_AOUT		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		AIN		: in    STD_ULOGIC;
		AOUT		: in    STD_ULOGIC;
		YIN		: out    STD_ULOGIC;
		YOUT		: out    STD_ULOGIC);
 end component;


------ Component IOI_FCLK_EN_BUFF ------
 component IOI_FCLK_EN_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_EN_ENOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_EN		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		EN		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC;
		ENOUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOI_FCLK_BUFF ------
 component IOI_FCLK_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOI_RCLK_EN_BUFF ------
 component IOI_RCLK_EN_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_EN_ENOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_EN		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		EN		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC;
		ENOUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOI_RCLK_BUFF ------
 component IOI_RCLK_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_FCLK_EN_BUFF ------
 component IOOE_FCLK_EN_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_YOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_EN_ENOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_EN		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		EN		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		YOUT		: out    STD_ULOGIC;
		ENOUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_FCLK ------
 component IOOE_FCLK
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLK		: in    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_RCLK_EN_BUFF ------
 component IOOE_RCLK_EN_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_YOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_EN_ENOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_EN		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		EN		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		YOUT		: out    STD_ULOGIC;
		ENOUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_RCLK_CLR_EN ------
 component IOOE_RCLK_CLR_EN
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_CLR_CLROUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_EN_ENOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_CLR		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_EN		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		: in    STD_ULOGIC;
		EN		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		CLROUT		: out    STD_ULOGIC;
		ENOUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_RCLK_BUFF ------
 component IOOE_RCLK_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_YOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		YOUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_RCLK ------
 component IOOE_RCLK
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLK		: in    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component PLLINT ------
 component PLLINT
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component PLLOUT ------
 component PLLOUT
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_HSTL_I ------
 component BIBUF_HSTL_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_SSTL3_I ------
 component BIBUF_SSTL3_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_SSTL3_II ------
 component BIBUF_SSTL3_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_SSTL2_I ------
 component BIBUF_SSTL2_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BIBUF_SSTL2_II ------
 component BIBUF_SSTL2_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
			tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component BUFF ------
 component BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKINT ------
 component CLKINT
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKINT_W ------
 component CLKINT_W
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKOUT_E ------
 component CLKOUT_E
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component CLKOUT_W ------
 component CLKOUT_W
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component DFM ------
 component DFM
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFM3B ------
 component DFM3B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFM4A ------
 component DFM4A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFM4B ------
 component DFM4B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFMA ------
 component DFMA
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFMB ------
 component DFMB
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFME1A ------
 component DFME1A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFME1B ------
 component DFME1B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFME2A ------
 component DFME2A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFME2B ------
 component DFME2B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFME3A ------
 component DFME3A
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFME3B ------
 component DFME3B
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFMEG ------
 component DFMEG
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFMEH ------
 component DFMEH
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_E_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		E		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFMPCA ------
 component DFMPCA
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_posedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component DFMPCB ------
 component DFMPCB
--pragma translate_off
    generic(
		TimingChecksOn: Boolean := True;
		InstancePath: STRING := "*";
		Xon: Boolean := False;
		MsgOn: Boolean := True;
		tpd_PRE_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_Q		:  VitalDelayType01 := (0.100 ns, 0.100 ns);
		tsetup_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_S_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_A_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		tsetup_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_B_CLK_negedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_PRE_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		thold_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		trecovery_CLR_CLK_posedge_negedge		:   VitalDelayType := 0.000 ns;
		tpw_CLK_posedge :  VitalDelayType := 0.000 ns;
		tpw_CLK_negedge  :  VitalDelayType := 0.000 ns;
		tpw_PRE_negedge		:  VitalDelayType := 0.000 ns;
		tpw_CLR_negedge		:  VitalDelayType := 0.000 ns;
		tipd_PRE		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_S		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_A		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_B		:   VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		:    VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		CLR		:   in    STD_ULOGIC;
		PRE		:   in    STD_ULOGIC;
		CLK		:   in    STD_ULOGIC;
		S		:  in    STD_ULOGIC;
		A		:  in    STD_ULOGIC;
		B		:  in    STD_ULOGIC;
		Q		:  out    STD_ULOGIC);

 end component;


------ Component HCLKMUX ------
 component HCLKMUX
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		
                tpw_A_posedge   : VitalDelayType := 0.000 ns;
                tpw_A_negedge   : VitalDelayType := 0.000 ns;    
                tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOFIFO_INBUF ------
 component IOFIFO_INBUF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOFIFO_OUTBUF ------
 component IOFIFO_OUTBUF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOOE_FCLK_BUFF ------
 component IOOE_FCLK_BUFF
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_YOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		YOUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_OUT_FCLK ------
 component IOOE_OUT_FCLK
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_YOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		YOUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_OUT_FCLK_CLR_EN ------
 component IOOE_OUT_FCLK_CLR_EN
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_YOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_EN_ENOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_CLROUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_EN		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		EN		: in    STD_ULOGIC;
		CLR		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		YOUT		: out    STD_ULOGIC;
		ENOUT		: out    STD_ULOGIC;
		CLROUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_OUT_RCLK ------
 component IOOE_OUT_RCLK
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_YOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		YOUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_OUT_RCLK_CLR_EN ------
 component IOOE_OUT_RCLK_CLR_EN
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_A_YOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_EN_ENOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_CLROUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_EN		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		EN		: in    STD_ULOGIC;
		CLR		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		YOUT		: out    STD_ULOGIC;
		ENOUT		: out    STD_ULOGIC;
		CLROUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOOE_FCLK_CLR_EN ------
 component IOOE_FCLK_CLR_EN
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_EN_ENOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLR_CLROUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_CLK_CLKOUT		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_EN		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLR		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_CLK		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		EN		: in    STD_ULOGIC;
		CLR		: in    STD_ULOGIC;
		CLK		: in    STD_ULOGIC;
		ENOUT		: out    STD_ULOGIC;
		CLROUT		: out    STD_ULOGIC;
		CLKOUT		: out    STD_ULOGIC);
 end component;


------ Component IOPAD_IN_U ------
 component IOPAD_IN_U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpw_PAD_posedge		: VitalDelayType := 0.000 ns;
		tpw_PAD_negedge		: VitalDelayType := 0.000 ns;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOPAD_IN_D ------
 component IOPAD_IN_D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpw_PAD_posedge		: VitalDelayType := 0.000 ns;
		tpw_PAD_negedge         : VitalDelayType := 0.000 ns;
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		PAD		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOPAD_TRI_U ------
 component IOPAD_TRI_U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpw_D_posedge	: VitalDelayType := 0.000 ns;
		tpw_D_negedge	: VitalDelayType := 0.000 ns;
		tpw_E_posedge	: VitalDelayType := 0.000 ns;
		tpw_E_negedge       : VitalDelayType := 0.000 ns;
		
                tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component IOPAD_TRI_D ------
 component IOPAD_TRI_D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpw_D_posedge	: VitalDelayType := 0.000 ns;
	        tpw_D_negedge   : VitalDelayType := 0.000 ns;
		tpw_E_posedge   : VitalDelayType := 0.000 ns;
                tpw_E_negedge 	: VitalDelayType := 0.000 ns;

                tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component IOPAD_BI_U ------
 component IOPAD_BI_U
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;

		tpw_D_posedge	    : VitalDelayType := 0.000 ns;
	        tpw_D_negedge       : VitalDelayType := 0.000 ns;
		tpw_E_posedge       : VitalDelayType := 0.000 ns;
                tpw_E_negedge 	    : VitalDelayType := 0.000 ns;
		tpw_PAD_posedge     : VitalDelayType := 0.000 ns;
                tpw_PAD_negedge     : VitalDelayType := 0.000 ns;

                tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);

		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD	: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component IOPAD_BI_D ------
 component IOPAD_BI_D
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
	
		tpw_E_posedge       : VitalDelayType := 0.000 ns;
                tpw_E_negedge 	    : VitalDelayType := 0.000 ns;
		tpw_D_posedge       : VitalDelayType := 0.000 ns;
                tpw_D_negedge 	    : VitalDelayType := 0.000 ns;
		tpw_PAD_posedge     : VitalDelayType := 0.000 ns;
                tpw_PAD_negedge     : VitalDelayType := 0.000 ns;

        	tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tpd_PAD_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_D_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_Y			: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_PAD		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: inout STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component RCLKMUX ------
 component RCLKMUX
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
	   
                tpw_A_posedge   : VitalDelayType := 0.000 ns;
                tpw_A_negedge   : VitalDelayType := 0.000 ns;
         	tpd_A_Y		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tipd_A		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		A		: in    STD_ULOGIC;
		Y		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_HSTL_I ------
 component TRIBUFF_HSTL_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		
                tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_SSTL3_I ------
 component TRIBUFF_SSTL3_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_SSTL3_II ------
 component TRIBUFF_SSTL3_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_SSTL2_I ------
 component TRIBUFF_SSTL2_I
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;


------ Component TRIBUFF_SSTL2_II ------
 component TRIBUFF_SSTL2_II
--pragma translate_off
    generic(
		TimingChecksOn:Boolean := True;
		Xon: Boolean := False;
		InstancePath: STRING :="*";
		MsgOn: Boolean := True;
		tpd_D_PAD		: VitalDelayType01 := (0.100 ns, 0.100 ns);
		tpd_E_PAD               : VitalDelayType01Z := (0.100 ns, 0.100 ns,0.100 ns, 0.100 ns,0.100 ns, 0.100 ns);
		tipd_D		: VitalDelayType01 := (0.000 ns, 0.000 ns);
		tipd_E		: VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
		D		: in    STD_ULOGIC;
		E		: in    STD_ULOGIC;
		PAD		: out    STD_ULOGIC);
 end component;

component BIOFIFO_BIDIRINFIFO 
--pragma translate_off
  GENERIC (
        tipd_A       : VitalDelayType01 := (0.00 ns, 0.00 ns);
        tipd_D       : VitalDelayType01 := (0.00 ns, 0.00 ns);
        tipd_WENB       : VitalDelayType01 := (0.00 ns, 0.00 ns);
        tipd_WCLK     : VitalDelayType01 := (0.00 ns, 0.00 ns);
        tipd_RENB       : VitalDelayType01 := (0.00 ns, 0.00 ns);
        tipd_RCLK     : VitalDelayType01 := (0.00 ns, 0.00 ns);
        tipd_CLRB      : VitalDelayType01 := (0.00 ns, 0.00 ns);
        tpd_A_Y   : VitalDelayType01 := (0.1000 ns, 0.1000 ns);
        tpd_RCLK_Q   : VitalDelayType01 := (0.1000 ns, 0.1000 ns);
        tpd_CLRB_Q    : VitalDelayType01 := (0.1000 ns, 0.1000 ns);
        tsetup_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_D_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_negedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_RCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLRB_WCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_WCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_CLRB_negedge     : VitalDelayType := 0.000 ns;
        TimingCheckOn : BOOLEAN := TRUE;
        InstancePath  : STRING := "*";
        Xon: Boolean := False;
        MsgOn: Boolean := True
        );
--pragma translate_on
  PORT (
        A     : IN STD_ULOGIC ;
        D     : IN STD_ULOGIC ;
        WENB     : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RENB     : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        CLRB    : IN STD_ULOGIC ;
        Q     : OUT STD_ULOGIC ;
        Y     : OUT STD_ULOGIC
        );

  
end component;


component BIOFIFO_BIDIROUTFIFO 
--pragma translate_off
  GENERIC (
        tipd_A       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_D       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_CLRB      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tpd_A_Y   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_Q   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLRB_Q    : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tsetup_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_D_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_negedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_RCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLRB_WCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_WCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_CLRB_negedge     : VitalDelayType := 0.000 ns;
        TimingCheckOn : BOOLEAN := TRUE;
        InstancePath  : STRING := "*";
        Xon: Boolean := False;
        MsgOn: Boolean := True
        );
--pragma translate_on
  PORT (
        A     : IN STD_ULOGIC ;
        D     : IN STD_ULOGIC ;
        WENB     : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RENB     : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        CLRB    : IN STD_ULOGIC ;
        Q     : OUT STD_ULOGIC ;
        Y     : OUT STD_ULOGIC
        );

  
end component;


component BIOFIFO_INFIFO 
--pragma translate_off
  GENERIC (
        tipd_D       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_CLRB      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tpd_RCLK_Q   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLRB_Q    : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tsetup_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_negedge_posedge     :   VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_RCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLRB_WCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_WCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_CLRB_negedge     : VitalDelayType := 0.000 ns;
        TimingCheckOn : BOOLEAN := TRUE;
        InstancePath  : STRING := "*";
        Xon: Boolean := False;
        MsgOn: Boolean := True
        );
--pragma translate_on
  PORT (
        D     : IN STD_ULOGIC ;
        WENB     : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RENB     : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        CLRB    : IN STD_ULOGIC ;
        Q     : OUT STD_ULOGIC
        );

  
end component;

component BIOFIFO_OUTFIFO 
--pragma translate_off
  GENERIC (
        tipd_D       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_CLRB      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tpd_RCLK_Q   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLRB_Q    : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tsetup_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_negedge_posedge     :   VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_RCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLRB_WCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_WCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_CLRB_negedge     : VitalDelayType := 0.000 ns;
        TimingCheckOn : BOOLEAN := TRUE;
        InstancePath  : STRING := "*";
        Xon: Boolean := False;
        MsgOn: Boolean := True
        );
--pragma translate_on
  PORT (
        D     : IN STD_ULOGIC ;
        WENB     : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RENB     : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        CLRB    : IN STD_ULOGIC ;
        Q     : OUT STD_ULOGIC
        );


end component;


component IOFIFO_BIDIRINFIFO 
--pragma translate_off
  GENERIC (
        tipd_A       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_D       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_CLRB      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tpd_A_Y   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_Q   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLRB_Q    : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tsetup_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_D_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_negedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_RCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLRB_WCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_WCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_CLRB_negedge     : VitalDelayType := 0.000 ns;
        TimingCheckOn : BOOLEAN := TRUE;
        InstancePath  : STRING := "*";
        Xon: Boolean := False;
        MsgOn: Boolean := True
        );
--pragma translate_on
  PORT (
        A     : IN STD_ULOGIC ;
        D     : IN STD_ULOGIC ;
        WENB     : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RENB     : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        CLRB    : IN STD_ULOGIC ;
        Q     : OUT STD_ULOGIC ;
        Y     : OUT STD_ULOGIC
        );


  
end component;


component IOFIFO_BIDIROUTFIFO 
--pragma translate_off
  GENERIC (
        tipd_A       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_D       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_CLRB      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tpd_A_Y   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_Q   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLRB_Q    : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tsetup_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_D_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_negedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_RCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLRB_WCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_WCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_CLRB_negedge     : VitalDelayType := 0.000 ns;
        TimingCheckOn : BOOLEAN := TRUE;
        InstancePath  : STRING := "*";
        Xon: Boolean := False;
        MsgOn: Boolean := True
        );
--pragma translate_on
  PORT (
        A     : IN STD_ULOGIC ;
        D     : IN STD_ULOGIC ;
        WENB     : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RENB     : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        CLRB    : IN STD_ULOGIC ;
        Q     : OUT STD_ULOGIC ;
        Y     : OUT STD_ULOGIC
        );

  
end component;


component IOFIFO_INFIFO 
--pragma translate_off
  GENERIC (
        tipd_D       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_CLRB      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tpd_RCLK_Q   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLRB_Q    : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tsetup_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_negedge_posedge     :   VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_RCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLRB_WCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_WCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_CLRB_negedge     : VitalDelayType := 0.000 ns;
        TimingCheckOn : BOOLEAN := TRUE;
        InstancePath  : STRING := "*";
        Xon: Boolean := False;
        MsgOn: Boolean := True
        );
--pragma translate_on
  PORT (
        D     : IN STD_ULOGIC ;
        WENB     : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RENB     : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        CLRB    : IN STD_ULOGIC ;
        Q     : OUT STD_ULOGIC
        );

  
end component;

component IOFIFO_OUTFIFO 
--pragma translate_off
  GENERIC (
        tipd_D       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RENB       : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_CLRB      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tpd_RCLK_Q   : VitalDelayType01 := (0.1000 ns, 0.100 ns);
        tpd_CLRB_Q    : VitalDelayType01 := (0.1000 ns, 0.1000 ns);
        tsetup_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_D_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RENB_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WENB_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RENB_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WENB_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_negedge_posedge     :   VitalDelayType := 0.000 ns;
        thold_CLRB_RCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_RCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLRB_WCLK_posedge_posedge     :   VitalDelayType := 0.000 ns;
        trecovery_CLRB_WCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_CLRB_negedge     : VitalDelayType := 0.000 ns;
        TimingCheckOn : BOOLEAN := TRUE;
        InstancePath  : STRING := "*";
        Xon: Boolean := False;
        MsgOn: Boolean := True
        );
--pragma translate_on
  PORT (
        D     : IN STD_ULOGIC ;
        WENB     : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RENB     : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        CLRB    : IN STD_ULOGIC ;
        Q     : OUT STD_ULOGIC
        );

  
end component;

component IOPADP_IN
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      
      tpw_PAD_posedge 		: VitalDelayType := 0.000 ns;
      tpw_PAD_negedge           : VitalDelayType := 0.000 ns;
      tpw_N2PIN_posedge 	: VitalDelayType := 0.000 ns;
      tpw_N2PIN_negedge         : VitalDelayType := 0.000 ns;   

      tpd_PAD_Y                 :        VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_N2PIN_Y               :        VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_PAD         	     :        VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_N2PIN       	     :        VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      PAD                            :        in    STD_ULOGIC;
      N2PIN                          :        in    STD_ULOGIC;
      Y                              :        out   STD_ULOGIC);

end component;


component IOPADN_IN 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      
      tpw_PAD_posedge 		: VitalDelayType := 0.000 ns;
      tpw_PAD_negedge           : VitalDelayType := 0.000 ns;
 
      tpd_PAD_N2POUT                 :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_PAD                       	     :	VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      PAD                            :	in    STD_ULOGIC;
      N2POUT                         :	out   STD_ULOGIC);

end component;

component IOPADP_TRI 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpw_E_posedge           : VitalDelayType := 0.000 ns;
      tpw_E_negedge           : VitalDelayType := 0.000 ns;
      tpw_D_posedge           : VitalDelayType := 0.000 ns;
      tpw_D_negedge           : VitalDelayType := 0.000 ns;
      
      tpd_E_PAD                      :	VitalDelayType01Z := 
               (0.100 ns, 0.100 ns, 0.100 ns, 0.000 ns, 0.100 ns, 0.100 ns);
      tpd_D_PAD                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_D                         :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_E                         :	VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      D                              :	in    STD_ULOGIC;
      E                              :	in    STD_ULOGIC;
      PAD                            :	out   STD_ULOGIC);

end component;

component IOPADN_TRI 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      
      tpw_DB_posedge 	    :   VitalDelayType := 0.000 ns;
      tpw_DB_negedge            :   VitalDelayType := 0.000 ns;
      tpw_E_posedge 		: VitalDelayType := 0.000 ns;
      tpw_E_negedge           : VitalDelayType := 0.000 ns;

      tpd_E_PAD                     :	VitalDelayType01Z := 
               (0.100 ns, 0.100 ns, 0.100 ns, 0.100 ns, 0.100 ns, 0.100 ns);
      tpd_DB_PAD                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_DB                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_E                         :	VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      DB                             :	in    STD_ULOGIC;
      E                              :	in    STD_ULOGIC;
      PAD                            :	out   STD_ULOGIC);

end component;


component CLKBUF_LVDS 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpd_PADP_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_PADN_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_PADP                             :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_PADN                             :  VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      PADP                           :  in    STD_ULOGIC;
      PADN                           :  in    STD_ULOGIC;
      Y                              :  out   STD_ULOGIC);

end component;

component CLKBUF_LVPECL 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpd_PADP_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_PADN_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_PADP                             :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_PADN                             :  VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      PADP                           :  in    STD_ULOGIC;
      PADN                           :  in    STD_ULOGIC;
      Y                              :  out   STD_ULOGIC);

end component;

component HCLKBUF_LVDS 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpd_PADP_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_PADN_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_PADP                             :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_PADN                             :  VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      PADP                           :  in    STD_ULOGIC;
      PADN                           :  in    STD_ULOGIC;
      Y                              :  out   STD_ULOGIC);

end component;

component HCLKBUF_LVPECL 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpd_PADP_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_PADN_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_PADP                             :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_PADN                             :  VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      PADP                           :  in    STD_ULOGIC;
      PADN                           :  in    STD_ULOGIC;
      Y                              :  out   STD_ULOGIC);

end component;

component INBUF_LVDS 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpd_PADP_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_PADN_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_PADP                             :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_PADN                             :  VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      PADP                           :  in    STD_ULOGIC;
      PADN                           :  in    STD_ULOGIC;
      Y                              :  out   STD_ULOGIC);

end component;

component INBUF_LVPECL 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpd_PADP_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_PADN_Y                    :  VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_PADP                             :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_PADN                             :  VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      PADP                           :  in    STD_ULOGIC;
      PADN                           :  in    STD_ULOGIC;
      Y                              :  out   STD_ULOGIC);

end component;

component OUTBUF_LVDS 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpd_D_PADP                     :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D_PADN                     :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_D                                 :	VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      D                              :	in    STD_ULOGIC;
      PADP                           :	out   STD_ULOGIC;
      PADN                           :	out   STD_ULOGIC);

end component;

component OUTBUF_LVPECL 
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpd_D_PADP                     :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D_PADN                     :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_D                         :	VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      D                              :	in    STD_ULOGIC;
      PADP                           :	out   STD_ULOGIC;
      PADN                           :	out   STD_ULOGIC);

end component;


component CM8F
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;
      tpd_S11_Y                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_S10_Y                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_S01_Y                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_S00_Y                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D3_Y                       :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D2_Y                       :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D1_Y                       :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D0_Y                       :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_S11_FY                     :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_S10_FY                     :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_S01_FY                     :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_S00_FY                     :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D3_FY                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D2_FY                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D1_FY                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_D0_FY                      :	VitalDelayType01 := (0.100 ns, 0.100 ns);
      tipd_D0                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_D1                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_D2                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_D3                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_S00                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_S01                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_S10                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_S11                       :	VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      D0                             :	in    STD_ULOGIC;
      D1                             :	in    STD_ULOGIC;
      D2                             :	in    STD_ULOGIC;
      D3                             :	in    STD_ULOGIC;
      S00                            :	in    STD_ULOGIC;
      S01                            :	in    STD_ULOGIC;
      S10                            :	in    STD_ULOGIC;
      S11                            :	in    STD_ULOGIC;
      FY                             :	out   STD_ULOGIC;
      Y                              :	out   STD_ULOGIC);
end component; 

component FIFO64K36 
--pragma translate_off
  GENERIC (
        tipd_DEPTH3   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_DEPTH2   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_DEPTH1   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_DEPTH0   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WIDTH2   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WIDTH1   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WIDTH0   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AEVAL7   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AEVAL6   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AEVAL5   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AEVAL4   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AEVAL3   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AEVAL2   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AEVAL1   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AEVAL0   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AFVAL7   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AFVAL6   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AFVAL5   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AFVAL4   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AFVAL3   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AFVAL2   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AFVAL1   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_AFVAL0   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_REN      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD35     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD34     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD33     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD32     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD31     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD30     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD29     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD28     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD27     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD26     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD25     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD24     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD23     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD22     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD21     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD20     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD19     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD18     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD17     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD16     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD15     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD14     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD13     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD12     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD11     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD10     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD9      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD8      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD7      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD6      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD5      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD4      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD3      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD2      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD1      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD0      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WEN      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_CLR      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tpd_RCLK_RD0  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD1  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD2  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD3  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD4  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD5  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD6  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD7  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD8  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD9  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD10 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD11 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD12 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD13 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD14 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD15 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD16 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD17 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD18 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD19 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD20 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD21 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD22 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD23 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD24 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD25 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD26 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD27 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD28 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD29 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD30 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD31 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD32 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD33 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD34 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD35 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_FULL   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_AFULL  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_EMPTY  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_AEMPTY : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD0  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD1  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD2  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD3  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD4  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD5  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD6  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD7  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD8  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD9  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD10 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD11 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD12 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD13 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD14 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD15 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD16 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD17 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD18 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD19 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD20 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD21 : VitalDelayType01 := (0.100 ns, 0.10 ns);
        tpd_CLR_RD22 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD23 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD24 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD25 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD26 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD27 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD28 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD29 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD30 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD31 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD32 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD33 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_RD34 : VitalDelayType01 := (0.1000 ns, 0.100 ns);
        tpd_CLR_RD35 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_FULL   : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_AFULL  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_EMPTY  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_CLR_AEMPTY : VitalDelayType01 := (0.100 ns, 0.100 ns);


        tsetup_WD35_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD34_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD33_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD32_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD31_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD30_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD29_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD28_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD27_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD26_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD25_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD24_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD23_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD22_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD21_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD20_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD19_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD18_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD17_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD16_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD15_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD14_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD13_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD12_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD11_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD10_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD9_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD8_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD7_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD6_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD5_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD4_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD3_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD2_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD1_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD0_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD35_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD34_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD33_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD32_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD31_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD30_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD29_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD28_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD27_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD26_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD25_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD24_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD23_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD22_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD21_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD20_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD19_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD18_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD17_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD16_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD15_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD14_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD13_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD12_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD11_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD10_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD9_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD8_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD7_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD6_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD5_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD4_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD3_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD2_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD1_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD0_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;

        tsetup_WEN_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        tsetup_WEN_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;

        tsetup_DEPTH3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        tsetup_WIDTH2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_AEVAL7_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL6_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL5_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL4_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL7_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL6_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL5_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL4_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_AFVAL7_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL6_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL5_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL4_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL7_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL6_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL5_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL4_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_DEPTH3_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH3_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_DEPTH0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        tsetup_WIDTH2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WIDTH0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        tsetup_AEVAL7_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL6_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL5_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL4_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL3_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL7_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL6_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL5_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL4_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL3_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AEVAL0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_AFVAL7_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL6_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL5_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL4_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL3_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL7_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL6_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL5_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL4_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL3_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_AFVAL0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_REN_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        tsetup_REN_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;

        thold_WD35_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD34_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD33_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD32_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD31_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD30_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD29_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD28_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD27_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD26_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD25_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD24_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD23_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD22_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD21_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD20_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD19_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD18_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD17_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD16_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD15_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD14_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD13_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD12_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD11_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD10_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD9_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD8_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD7_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD6_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD5_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD4_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD3_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD2_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD1_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD0_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD35_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD34_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD33_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD32_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD31_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD30_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD29_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD28_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD27_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD26_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD25_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD24_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD23_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD22_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD21_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD20_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD19_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD18_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD17_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD16_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD15_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD14_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD13_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD12_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD11_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD10_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD9_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD8_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD7_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD6_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD5_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD4_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD3_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD2_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD1_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD0_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;


        thold_WEN_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WEN_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;

        thold_DEPTH3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        thold_WIDTH2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        thold_AEVAL7_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL6_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL5_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL4_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL7_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL6_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL5_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL4_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        thold_AFVAL7_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL6_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL5_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL4_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL7_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL6_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL5_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL4_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;



        thold_DEPTH3_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH3_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        thold_WIDTH2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WIDTH0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        thold_AEVAL7_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL6_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL5_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL4_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL3_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL7_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL6_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL5_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL4_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL3_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AEVAL0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        thold_AFVAL7_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL6_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL5_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL4_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL3_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL7_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL6_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL5_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL4_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL3_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_AFVAL0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        thold_REN_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_REN_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;

        trecovery_CLR_RCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLR_RCLK_posedge_posedge      :  VitalDelayType := 0.000 ns;

        trecovery_CLR_WCLK_posedge_posedge :  VitalDelayType := 0.000 ns;
        thold_CLR_WCLK_posedge_posedge      :  VitalDelayType := 0.000 ns;
        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_CLR_negedge     : VitalDelayType := 0.000 ns;
        TimingCheckOn : BOOLEAN := TRUE;
        InstancePath  : STRING := "*";
        Xon: Boolean := False;
        MsgOn: Boolean := True
        );
--pragma translate_on
  PORT (
        DEPTH3 : IN STD_ULOGIC ;
        DEPTH2 : IN STD_ULOGIC ;
        DEPTH1 : IN STD_ULOGIC ;
        DEPTH0 : IN STD_ULOGIC ;
        WIDTH2 : IN STD_ULOGIC ;
        WIDTH1 : IN STD_ULOGIC ;
        WIDTH0 : IN STD_ULOGIC ;
        AEVAL7 : IN STD_ULOGIC ;
        AEVAL6 : IN STD_ULOGIC ;
        AEVAL5 : IN STD_ULOGIC ;
        AEVAL4 : IN STD_ULOGIC ;
        AEVAL3 : IN STD_ULOGIC ;
        AEVAL2 : IN STD_ULOGIC ;
        AEVAL1 : IN STD_ULOGIC ;
        AEVAL0 : IN STD_ULOGIC ;
        AFVAL7 : IN STD_ULOGIC ;
        AFVAL6 : IN STD_ULOGIC ;
        AFVAL5 : IN STD_ULOGIC ;
        AFVAL4 : IN STD_ULOGIC ;
        AFVAL3 : IN STD_ULOGIC ;
        AFVAL2 : IN STD_ULOGIC ;
        AFVAL1 : IN STD_ULOGIC ;
        AFVAL0 : IN STD_ULOGIC ;
        REN    : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        WD35   : IN STD_ULOGIC ;
        WD34   : IN STD_ULOGIC ;
        WD33   : IN STD_ULOGIC ;
        WD32   : IN STD_ULOGIC ;
        WD31   : IN STD_ULOGIC ;
        WD30   : IN STD_ULOGIC ;
        WD29   : IN STD_ULOGIC ;
        WD28   : IN STD_ULOGIC ;
        WD27   : IN STD_ULOGIC ;
        WD26   : IN STD_ULOGIC ;
        WD25   : IN STD_ULOGIC ;
        WD24   : IN STD_ULOGIC ;
        WD23   : IN STD_ULOGIC ;
        WD22   : IN STD_ULOGIC ;
        WD21   : IN STD_ULOGIC ;
        WD20   : IN STD_ULOGIC ;
        WD19   : IN STD_ULOGIC ;
        WD18   : IN STD_ULOGIC ;
        WD17   : IN STD_ULOGIC ;
        WD16   : IN STD_ULOGIC ;
        WD15   : IN STD_ULOGIC ;
        WD14   : IN STD_ULOGIC ;
        WD13   : IN STD_ULOGIC ;
        WD12   : IN STD_ULOGIC ;
        WD11   : IN STD_ULOGIC ;
        WD10   : IN STD_ULOGIC ;
        WD9    : IN STD_ULOGIC ;
        WD8    : IN STD_ULOGIC ;
        WD7    : IN STD_ULOGIC ;
        WD6    : IN STD_ULOGIC ;
        WD5    : IN STD_ULOGIC ;
        WD4    : IN STD_ULOGIC ;
        WD3    : IN STD_ULOGIC ;
        WD2    : IN STD_ULOGIC ;
        WD1    : IN STD_ULOGIC ;
        WD0    : IN STD_ULOGIC ;
        WEN    : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        CLR    : IN STD_ULOGIC ;
        RD35   : OUT STD_ULOGIC ;
        RD34   : OUT STD_ULOGIC ;
        RD33   : OUT STD_ULOGIC ;
        RD32   : OUT STD_ULOGIC ;
        RD31   : OUT STD_ULOGIC ;
        RD30   : OUT STD_ULOGIC ;
        RD29   : OUT STD_ULOGIC ;
        RD28   : OUT STD_ULOGIC ;
        RD27   : OUT STD_ULOGIC ;
        RD26   : OUT STD_ULOGIC ;
        RD25   : OUT STD_ULOGIC ;
        RD24   : OUT STD_ULOGIC ;
        RD23   : OUT STD_ULOGIC ;
        RD22   : OUT STD_ULOGIC ;
        RD21   : OUT STD_ULOGIC ;
        RD20   : OUT STD_ULOGIC ;
        RD19   : OUT STD_ULOGIC ;
        RD18   : OUT STD_ULOGIC ;
        RD17   : OUT STD_ULOGIC ;
        RD16   : OUT STD_ULOGIC ;
        RD15   : OUT STD_ULOGIC ;
        RD14   : OUT STD_ULOGIC ;
        RD13   : OUT STD_ULOGIC ;
        RD12   : OUT STD_ULOGIC ;
        RD11   : OUT STD_ULOGIC ;
        RD10   : OUT STD_ULOGIC ;
        RD9    : OUT STD_ULOGIC ;
        RD8    : OUT STD_ULOGIC ;
        RD7    : OUT STD_ULOGIC ;
        RD6    : OUT STD_ULOGIC ;
        RD5    : OUT STD_ULOGIC ;
        RD4    : OUT STD_ULOGIC ;
        RD3    : OUT STD_ULOGIC ;
        RD2    : OUT STD_ULOGIC ;
        RD1    : OUT STD_ULOGIC ;
        RD0    : OUT STD_ULOGIC ;
        FULL   : OUT STD_ULOGIC ;
        AFULL  : OUT STD_ULOGIC ;
        EMPTY  : OUT STD_ULOGIC ;
        AEMPTY : OUT STD_ULOGIC
        );


  
end component;


component RAM64K36 
--pragma translate_off
  GENERIC (

        TimingChecksOn  : Boolean := True;
        InstancePath    : String  := "*";
        Xon             : Boolean := False;
        MsgOn           : Boolean := True;
        MEMORYFILE      : String  := "";

        tipd_DEPTH3   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_DEPTH2   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_DEPTH1   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_DEPTH0   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD15   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD14   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD13   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD12   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD11   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD10   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD9    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD8    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD7    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD6    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD5    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD4    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD3    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD2    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD1    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD0    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD35     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD34     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD33     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD32     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD31     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD30     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD29     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD28     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD27     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD26     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD25     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD24     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD23     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD22     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD21     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD20     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD19     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD18     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD17     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD16     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD15     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD14     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD13     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD12     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD11     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD10     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD9      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD8      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD7      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD6      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD5      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD4      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD3      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD2      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD1      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD0      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WW2      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WW1      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WW0      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WEN      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD15   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD14   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD13   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD12   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD11   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD10   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD9    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD8    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD7    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD6    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD5    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD4    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD3    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD2    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD1    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD0    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RW2      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RW1      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RW0      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_REN      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);


        tpd_RCLK_RD0  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD1  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD2  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD3  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD4  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD5  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD6  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD7  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD8  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD9  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD10 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD11 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD12 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD13 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD14 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD15 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD16 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD17 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD18 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD19 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD20 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD21 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD22 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD23 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD24 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD25 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD26 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD27 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD28 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD29 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD30 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD31 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD32 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD33 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD34 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD35 : VitalDelayType01 := (0.100 ns, 0.100 ns);


        tsetup_RDAD15_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD14_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD13_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD12_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD11_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD10_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD9_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD8_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD7_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD6_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD5_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD4_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD3_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_RDAD15_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD14_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD13_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD12_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD11_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD10_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD9_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD8_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD7_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD6_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD5_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD4_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD3_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        tsetup_RW2_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW1_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW0_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW2_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW1_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW0_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;


        tsetup_DEPTH3_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH2_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH1_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH0_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH3_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH2_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH1_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH0_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;



        tsetup_WRAD15_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD14_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD13_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD12_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD11_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD10_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD9_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD8_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD7_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD6_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD5_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD4_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_WRAD15_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD14_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD13_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD12_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD11_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD10_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD9_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD8_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD7_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD6_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD5_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD4_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_WD35_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD34_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD33_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD32_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD31_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD30_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD29_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD28_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD27_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD26_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD25_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD24_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD23_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD22_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD21_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD20_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD19_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD18_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD17_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD16_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD15_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD14_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD13_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD12_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD11_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD10_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD9_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD8_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD7_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD6_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD5_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD4_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD3_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD2_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD1_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD0_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD35_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD34_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD33_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD32_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD31_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD30_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD29_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD28_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD27_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD26_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD25_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD24_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD23_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD22_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD21_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD20_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD19_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD18_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD17_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD16_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD15_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD14_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD13_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD12_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD11_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD10_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD9_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD8_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD7_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD6_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD5_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD4_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD3_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD2_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD1_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD0_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;


        tsetup_WW2_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW1_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW0_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW2_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW1_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW0_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;


        thold_RDAD15_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD14_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD13_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD12_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD11_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD10_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD9_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD8_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD7_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD6_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD5_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD4_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD3_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD2_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD1_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD0_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;

        thold_RDAD15_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD14_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD13_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD12_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD11_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD10_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD9_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD8_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD7_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD6_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD5_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD4_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD3_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD2_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD1_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD0_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;



        thold_RW2_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW1_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW0_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW2_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW1_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW0_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;

        thold_DEPTH3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;

        thold_WRAD15_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD14_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD13_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD12_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD11_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD10_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD9_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD8_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD7_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD6_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD5_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD4_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;

        thold_WRAD15_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD14_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD13_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD12_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD11_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD10_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD9_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD8_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD7_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD6_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD5_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD4_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        thold_WD35_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD34_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD33_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD32_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD31_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD30_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD29_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD28_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD27_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD26_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD25_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD24_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD23_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD22_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD21_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD20_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD19_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD18_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD17_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD16_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD15_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD14_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD13_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD12_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD11_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD10_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD9_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD8_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD7_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD6_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD5_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD4_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD3_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD2_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD1_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD0_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD35_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD34_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD33_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD32_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD31_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD30_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD29_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD28_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD27_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD26_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD25_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD24_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD23_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD22_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD21_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD20_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD19_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD18_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD17_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD16_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD15_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD14_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD13_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD12_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD11_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD10_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD9_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD8_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD7_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD6_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD5_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD4_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD3_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD2_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD1_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD0_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;


        thold_WW2_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW1_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW0_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW2_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW1_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW0_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;

        tsetup_REN_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WEN_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_REN_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WEN_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        tsetup_REN_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WEN_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_REN_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WEN_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;

        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns

        );
--pragma translate_on
  PORT (
        DEPTH3 : IN STD_ULOGIC ;
        DEPTH2 : IN STD_ULOGIC ;
        DEPTH1 : IN STD_ULOGIC ;
        DEPTH0 : IN STD_ULOGIC ;
        WRAD15 : IN STD_ULOGIC ;
        WRAD14 : IN STD_ULOGIC ;
        WRAD13 : IN STD_ULOGIC ;
        WRAD12 : IN STD_ULOGIC ;
        WRAD11 : IN STD_ULOGIC ;
        WRAD10 : IN STD_ULOGIC ;
        WRAD9  : IN STD_ULOGIC ;
        WRAD8  : IN STD_ULOGIC ;
        WRAD7  : IN STD_ULOGIC ;
        WRAD6  : IN STD_ULOGIC ;
        WRAD5  : IN STD_ULOGIC ;
        WRAD4  : IN STD_ULOGIC ;
        WRAD3  : IN STD_ULOGIC ;
        WRAD2  : IN STD_ULOGIC ;
        WRAD1  : IN STD_ULOGIC ;
        WRAD0  : IN STD_ULOGIC ;
        WD35   : IN STD_ULOGIC ;
        WD34   : IN STD_ULOGIC ;
        WD33   : IN STD_ULOGIC ;
        WD32   : IN STD_ULOGIC ;
        WD31   : IN STD_ULOGIC ;
        WD30   : IN STD_ULOGIC ;
        WD29   : IN STD_ULOGIC ;
        WD28   : IN STD_ULOGIC ;
        WD27   : IN STD_ULOGIC ;
        WD26   : IN STD_ULOGIC ;
        WD25   : IN STD_ULOGIC ;
        WD24   : IN STD_ULOGIC ;
        WD23   : IN STD_ULOGIC ;
        WD22   : IN STD_ULOGIC ;
        WD21   : IN STD_ULOGIC ;
        WD20   : IN STD_ULOGIC ;
        WD19   : IN STD_ULOGIC ;
        WD18   : IN STD_ULOGIC ;
        WD17   : IN STD_ULOGIC ;
        WD16   : IN STD_ULOGIC ;
        WD15   : IN STD_ULOGIC ;
        WD14   : IN STD_ULOGIC ;
        WD13   : IN STD_ULOGIC ;
        WD12   : IN STD_ULOGIC ;
        WD11   : IN STD_ULOGIC ;
        WD10   : IN STD_ULOGIC ;
        WD9    : IN STD_ULOGIC ;
        WD8    : IN STD_ULOGIC ;
        WD7    : IN STD_ULOGIC ;
        WD6    : IN STD_ULOGIC ;
        WD5    : IN STD_ULOGIC ;
        WD4    : IN STD_ULOGIC ;
        WD3    : IN STD_ULOGIC ;
        WD2    : IN STD_ULOGIC ;
        WD1    : IN STD_ULOGIC ;
        WD0    : IN STD_ULOGIC ;
        WW2    : IN STD_ULOGIC ;
        WW1    : IN STD_ULOGIC ;
        WW0    : IN STD_ULOGIC ;
        WEN    : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RDAD15 : IN STD_ULOGIC ;
        RDAD14 : IN STD_ULOGIC ;
        RDAD13 : IN STD_ULOGIC ;
        RDAD12 : IN STD_ULOGIC ;
        RDAD11 : IN STD_ULOGIC ;
        RDAD10 : IN STD_ULOGIC ;
        RDAD9  : IN STD_ULOGIC ;
        RDAD8  : IN STD_ULOGIC ;
        RDAD7  : IN STD_ULOGIC ;
        RDAD6  : IN STD_ULOGIC ;
        RDAD5  : IN STD_ULOGIC ;
        RDAD4  : IN STD_ULOGIC ;
        RDAD3  : IN STD_ULOGIC ;
        RDAD2  : IN STD_ULOGIC ;
        RDAD1  : IN STD_ULOGIC ;
        RDAD0  : IN STD_ULOGIC ;
        RW2    : IN STD_ULOGIC ;
        RW1    : IN STD_ULOGIC ;
        RW0    : IN STD_ULOGIC ;
        REN    : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        RD35   : OUT STD_ULOGIC ;
        RD34   : OUT STD_ULOGIC ;
        RD33   : OUT STD_ULOGIC ;
        RD32   : OUT STD_ULOGIC ;
        RD31   : OUT STD_ULOGIC ;
        RD30   : OUT STD_ULOGIC ;
        RD29   : OUT STD_ULOGIC ;
        RD28   : OUT STD_ULOGIC ;
        RD27   : OUT STD_ULOGIC ;
        RD26   : OUT STD_ULOGIC ;
        RD25   : OUT STD_ULOGIC ;
        RD24   : OUT STD_ULOGIC ;
        RD23   : OUT STD_ULOGIC ;
        RD22   : OUT STD_ULOGIC ;
        RD21   : OUT STD_ULOGIC ;
        RD20   : OUT STD_ULOGIC ;
        RD19   : OUT STD_ULOGIC ;
        RD18   : OUT STD_ULOGIC ;
        RD17   : OUT STD_ULOGIC ;
        RD16   : OUT STD_ULOGIC ;
        RD15   : OUT STD_ULOGIC ;
        RD14   : OUT STD_ULOGIC ;
        RD13   : OUT STD_ULOGIC ;
        RD12   : OUT STD_ULOGIC ;
        RD11   : OUT STD_ULOGIC ;
        RD10   : OUT STD_ULOGIC ;
        RD9    : OUT STD_ULOGIC ;
        RD8    : OUT STD_ULOGIC ;
        RD7    : OUT STD_ULOGIC ;
        RD6    : OUT STD_ULOGIC ;
        RD5    : OUT STD_ULOGIC ;
        RD4    : OUT STD_ULOGIC ;
        RD3    : OUT STD_ULOGIC ;
        RD2    : OUT STD_ULOGIC ;
        RD1    : OUT STD_ULOGIC ;
        RD0    : OUT STD_ULOGIC
        );


end component;


component RAM64K36P 
--pragma translate_off
  GENERIC (

        TimingChecksOn  : Boolean := True;
        InstancePath    : String  := "*";
        Xon             : Boolean := False;
        MsgOn           : Boolean := True;
        MEMORYFILE      : String  := "";

        tipd_DEPTH3   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_DEPTH2   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_DEPTH1   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_DEPTH0   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD15   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD14   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD13   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD12   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD11   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD10   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD9    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD8    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD7    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD6    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD5    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD4    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD3    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD2    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD1    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WRAD0    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD35     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD34     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD33     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD32     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD31     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD30     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD29     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD28     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD27     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD26     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD25     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD24     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD23     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD22     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD21     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD20     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD19     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD18     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD17     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD16     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD15     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD14     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD13     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD12     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD11     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD10     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD9      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD8      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD7      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD6      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD5      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD4      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD3      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD2      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD1      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WD0      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WW2      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WW1      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WW0      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WEN      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_WCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD15   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD14   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD13   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD12   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD11   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD10   : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD9    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD8    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD7    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD6    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD5    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD4    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD3    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD2    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD1    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RDAD0    : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RW2      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RW1      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RW0      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_REN      : VitalDelayType01 := (0.000 ns, 0.000 ns);
        tipd_RCLK     : VitalDelayType01 := (0.000 ns, 0.000 ns);


        tpd_RCLK_RD0  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD1  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD2  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD3  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD4  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD5  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD6  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD7  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD8  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD9  : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD10 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD11 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD12 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD13 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD14 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD15 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD16 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD17 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD18 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD19 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD20 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD21 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD22 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD23 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD24 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD25 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD26 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD27 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD28 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD29 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD30 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD31 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD32 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD33 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD34 : VitalDelayType01 := (0.100 ns, 0.100 ns);
        tpd_RCLK_RD35 : VitalDelayType01 := (0.100 ns, 0.100 ns);


        tsetup_RDAD15_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD14_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD13_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD12_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD11_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD10_RCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD9_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD8_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD7_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD6_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD5_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD4_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD3_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD2_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD1_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD0_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_RDAD15_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD14_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD13_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD12_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD11_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD10_RCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_RDAD9_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD8_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD7_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD6_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD5_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD4_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD3_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD2_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD1_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_RDAD0_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;



        tsetup_RW2_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW1_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW0_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW2_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW1_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_RW0_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;


        tsetup_DEPTH3_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH2_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH1_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH0_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH3_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH2_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH1_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_DEPTH0_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;



        tsetup_WRAD15_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD14_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD13_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD12_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD11_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD10_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD9_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD8_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD7_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD6_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD5_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD4_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;

        tsetup_WRAD15_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD14_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD13_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD12_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD11_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD10_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        tsetup_WRAD9_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD8_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD7_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD6_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD5_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD4_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        tsetup_WRAD0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        tsetup_WD35_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD34_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD33_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD32_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD31_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD30_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD29_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD28_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD27_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD26_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD25_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD24_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD23_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD22_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD21_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD20_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD19_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD18_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD17_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD16_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD15_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD14_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD13_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD12_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD11_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD10_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD9_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD8_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD7_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD6_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD5_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD4_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD3_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD2_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD1_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD0_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD35_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD34_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD33_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD32_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD31_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD30_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD29_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD28_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD27_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD26_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD25_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD24_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD23_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD22_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD21_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD20_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD19_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD18_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD17_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD16_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD15_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD14_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD13_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD12_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD11_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD10_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        tsetup_WD9_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD8_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD7_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD6_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD5_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD4_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD3_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD2_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD1_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WD0_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;



        tsetup_WW2_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW1_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW0_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW2_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW1_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WW0_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;


        thold_RDAD15_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD14_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD13_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD12_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD11_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD10_RCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD9_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD8_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD7_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD6_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD5_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD4_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD3_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD2_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD1_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD0_RCLK_posedge_posedge    : VitalDelayType := 0.000 ns;

        thold_RDAD15_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD14_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD13_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD12_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD11_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD10_RCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_RDAD9_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD8_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD7_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD6_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD5_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD4_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD3_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD2_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD1_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_RDAD0_RCLK_negedge_posedge    : VitalDelayType := 0.000 ns;

        thold_RW2_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW1_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW0_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW2_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW1_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_RW0_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;

        thold_DEPTH3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_DEPTH0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        thold_WRAD15_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD14_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD13_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD12_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD11_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD10_WCLK_posedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD9_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD8_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD7_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD6_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD5_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD4_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD3_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD2_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD1_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD0_WCLK_posedge_posedge   : VitalDelayType := 0.000 ns;

        thold_WRAD15_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD14_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD13_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD12_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD11_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD10_WCLK_negedge_posedge  : VitalDelayType := 0.000 ns;
        thold_WRAD9_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD8_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD7_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD6_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD5_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD4_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD3_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD2_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD1_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;
        thold_WRAD0_WCLK_negedge_posedge   : VitalDelayType := 0.000 ns;


        thold_WD35_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD34_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD33_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD32_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD31_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD30_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD29_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD28_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD27_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD26_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD25_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD24_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD23_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD22_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD21_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD20_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD19_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD18_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD17_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD16_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD15_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD14_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD13_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD12_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD11_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD10_WCLK_posedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD9_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD8_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD7_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD6_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD5_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD4_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD3_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD2_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD1_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD0_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD35_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD34_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD33_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD32_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD31_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD30_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD29_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD28_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD27_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD26_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD25_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD24_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD23_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD22_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD21_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD20_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD19_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD18_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD17_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD16_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD15_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD14_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD13_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD12_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD11_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD10_WCLK_negedge_posedge    : VitalDelayType := 0.000 ns;
        thold_WD9_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD8_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD7_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD6_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD5_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD4_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD3_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD2_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD1_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_WD0_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;


        thold_WW2_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW1_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW0_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW2_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW1_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WW0_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;

        tsetup_REN_RCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WEN_WCLK_posedge_posedge     : VitalDelayType := 0.000 ns;
        thold_REN_RCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WEN_WCLK_posedge_posedge      : VitalDelayType := 0.000 ns;
        tsetup_REN_RCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        tsetup_WEN_WCLK_negedge_posedge     : VitalDelayType := 0.000 ns;
        thold_REN_RCLK_negedge_posedge      : VitalDelayType := 0.000 ns;
        thold_WEN_WCLK_negedge_posedge      : VitalDelayType := 0.000 ns;



        tpw_RCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_RCLK_negedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_posedge    : VitalDelayType := 0.000 ns;
        tpw_WCLK_negedge    : VitalDelayType := 0.000 ns

        );
--pragma translate_on
  PORT (
        DEPTH3 : IN STD_ULOGIC ;
        DEPTH2 : IN STD_ULOGIC ;
        DEPTH1 : IN STD_ULOGIC ;
        DEPTH0 : IN STD_ULOGIC ;
        WRAD15 : IN STD_ULOGIC ;
        WRAD14 : IN STD_ULOGIC ;
        WRAD13 : IN STD_ULOGIC ;
        WRAD12 : IN STD_ULOGIC ;
        WRAD11 : IN STD_ULOGIC ;
        WRAD10 : IN STD_ULOGIC ;
        WRAD9  : IN STD_ULOGIC ;
        WRAD8  : IN STD_ULOGIC ;
        WRAD7  : IN STD_ULOGIC ;
        WRAD6  : IN STD_ULOGIC ;
        WRAD5  : IN STD_ULOGIC ;
        WRAD4  : IN STD_ULOGIC ;
        WRAD3  : IN STD_ULOGIC ;
        WRAD2  : IN STD_ULOGIC ;
        WRAD1  : IN STD_ULOGIC ;
        WRAD0  : IN STD_ULOGIC ;
        WD35   : IN STD_ULOGIC ;
        WD34   : IN STD_ULOGIC ;
        WD33   : IN STD_ULOGIC ;
        WD32   : IN STD_ULOGIC ;
        WD31   : IN STD_ULOGIC ;
        WD30   : IN STD_ULOGIC ;
        WD29   : IN STD_ULOGIC ;
        WD28   : IN STD_ULOGIC ;
        WD27   : IN STD_ULOGIC ;
        WD26   : IN STD_ULOGIC ;
        WD25   : IN STD_ULOGIC ;
        WD24   : IN STD_ULOGIC ;
        WD23   : IN STD_ULOGIC ;
        WD22   : IN STD_ULOGIC ;
        WD21   : IN STD_ULOGIC ;
        WD20   : IN STD_ULOGIC ;
        WD19   : IN STD_ULOGIC ;
        WD18   : IN STD_ULOGIC ;
        WD17   : IN STD_ULOGIC ;
        WD16   : IN STD_ULOGIC ;
        WD15   : IN STD_ULOGIC ;
        WD14   : IN STD_ULOGIC ;
        WD13   : IN STD_ULOGIC ;
        WD12   : IN STD_ULOGIC ;
        WD11   : IN STD_ULOGIC ;
        WD10   : IN STD_ULOGIC ;
        WD9    : IN STD_ULOGIC ;
        WD8    : IN STD_ULOGIC ;
        WD7    : IN STD_ULOGIC ;
        WD6    : IN STD_ULOGIC ;
        WD5    : IN STD_ULOGIC ;
        WD4    : IN STD_ULOGIC ;
        WD3    : IN STD_ULOGIC ;
        WD2    : IN STD_ULOGIC ;
        WD1    : IN STD_ULOGIC ;
        WD0    : IN STD_ULOGIC ;
        WW2    : IN STD_ULOGIC ;
        WW1    : IN STD_ULOGIC ;
        WW0    : IN STD_ULOGIC ;
        WEN    : IN STD_ULOGIC ;
        WCLK   : IN STD_ULOGIC ;
        RDAD15 : IN STD_ULOGIC ;
        RDAD14 : IN STD_ULOGIC ;
        RDAD13 : IN STD_ULOGIC ;
        RDAD12 : IN STD_ULOGIC ;
        RDAD11 : IN STD_ULOGIC ;
        RDAD10 : IN STD_ULOGIC ;
        RDAD9  : IN STD_ULOGIC ;
        RDAD8  : IN STD_ULOGIC ;
        RDAD7  : IN STD_ULOGIC ;
        RDAD6  : IN STD_ULOGIC ;
        RDAD5  : IN STD_ULOGIC ;
        RDAD4  : IN STD_ULOGIC ;
        RDAD3  : IN STD_ULOGIC ;
        RDAD2  : IN STD_ULOGIC ;
        RDAD1  : IN STD_ULOGIC ;
        RDAD0  : IN STD_ULOGIC ;
        RW2    : IN STD_ULOGIC ;
        RW1    : IN STD_ULOGIC ;
        RW0    : IN STD_ULOGIC ;
        REN    : IN STD_ULOGIC ;
        RCLK   : IN STD_ULOGIC ;
        RD35   : OUT STD_ULOGIC ;
        RD34   : OUT STD_ULOGIC ;
        RD33   : OUT STD_ULOGIC ;
        RD32   : OUT STD_ULOGIC ;
        RD31   : OUT STD_ULOGIC ;
        RD30   : OUT STD_ULOGIC ;
        RD29   : OUT STD_ULOGIC ;
        RD28   : OUT STD_ULOGIC ;
        RD27   : OUT STD_ULOGIC ;
        RD26   : OUT STD_ULOGIC ;
        RD25   : OUT STD_ULOGIC ;
        RD24   : OUT STD_ULOGIC ;
        RD23   : OUT STD_ULOGIC ;
        RD22   : OUT STD_ULOGIC ;
        RD21   : OUT STD_ULOGIC ;
        RD20   : OUT STD_ULOGIC ;
        RD19   : OUT STD_ULOGIC ;
        RD18   : OUT STD_ULOGIC ;
        RD17   : OUT STD_ULOGIC ;
        RD16   : OUT STD_ULOGIC ;
        RD15   : OUT STD_ULOGIC ;
        RD14   : OUT STD_ULOGIC ;
        RD13   : OUT STD_ULOGIC ;
        RD12   : OUT STD_ULOGIC ;
        RD11   : OUT STD_ULOGIC ;
        RD10   : OUT STD_ULOGIC ;
        RD9    : OUT STD_ULOGIC ;
        RD8    : OUT STD_ULOGIC ;
        RD7    : OUT STD_ULOGIC ;
        RD6    : OUT STD_ULOGIC ;
        RD5    : OUT STD_ULOGIC ;
        RD4    : OUT STD_ULOGIC ;
        RD3    : OUT STD_ULOGIC ;
        RD2    : OUT STD_ULOGIC ;
        RD1    : OUT STD_ULOGIC ;
        RD0    : OUT STD_ULOGIC
        );

 
  
end component;

component DDR_OUT
    port(DR, DF, E, CLK, PRE, CLR : in std_logic;  Q : out std_logic) ;
end component; 

component DDR_REG
    port(D, E, CLK, CLR, PRE : in std_logic;  QR, QF : out std_logic) ;
end component; 

component PLL
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;

      f_REFCLK_LOCK          :	Integer := 3; -- Number of REFCLK pulses after which LOCK is raised

      tipd_PWRDWN            :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_REFCLK            :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_LOWFREQ           :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OSC2              :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OSC1              :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OSC0              :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI5             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI4             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI3             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI2             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI1             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI0             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ5             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ4             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ3             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ2             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ1             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ0             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE4        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE3        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE2        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE1        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE0        :	VitalDelayType01 := (0.000 ns, 0.000 ns);

      tpd_REFCLK_CLK1        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_REFCLK_CLK2        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_REFCLK_LOCK        :  VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on
   port(
      PWRDWN                  :	in    STD_ULOGIC; -- Active high
      REFCLK                  :	in    STD_ULOGIC;
      LOWFREQ                 : in    STD_ULOGIC; 
      OSC2                    : in    STD_ULOGIC; 
      OSC1                    : in    STD_ULOGIC; 
      OSC0                    : in    STD_ULOGIC; 
      DIVI5                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI4                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI3                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI2                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI1                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI0                   : in    STD_ULOGIC; -- Clock multiplier
      DIVJ5                   : in    STD_ULOGIC; -- Clock divider
      DIVJ4                   : in    STD_ULOGIC; -- Clock divider
      DIVJ3                   : in    STD_ULOGIC; -- Clock divider
      DIVJ2                   : in    STD_ULOGIC; -- Clock divider
      DIVJ1                   : in    STD_ULOGIC; -- Clock divider
      DIVJ0                   : in    STD_ULOGIC; -- Clock divider
      DELAYLINE4              : in    STD_ULOGIC; -- Delay Value
      DELAYLINE3              : in    STD_ULOGIC; -- Delay Value
      DELAYLINE2              : in    STD_ULOGIC; -- Delay Value
      DELAYLINE1              : in    STD_ULOGIC; -- Delay Value
      DELAYLINE0              : in    STD_ULOGIC; -- Delay Value
      LOCK                    :	out   STD_ULOGIC;
      CLK1                    :	out   STD_ULOGIC;
      CLK2                    :	out   STD_ULOGIC);

end component; 

component PLLFB
--pragma translate_off
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := True;

      f_REFCLK_LOCK          :	Integer := 3; -- Number of REFCLK pulses after which LOCK is raised

      tipd_PWRDWN            :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_REFCLK            :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_FB                :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_LOWFREQ           :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OSC2              :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OSC1              :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OSC0              :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI5             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI4             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI3             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI2             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI1             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVI0             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ5             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ4             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ3             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ2             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ1             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIVJ0             :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE4        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE3        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE2        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE1        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DELAYLINE0        :	VitalDelayType01 := (0.000 ns, 0.000 ns);

      tpd_REFCLK_CLK1        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_REFCLK_CLK2        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_REFCLK_LOCK        :  VitalDelayType01 := (0.000 ns, 0.000 ns));

--pragma translate_on

   port(
      PWRDWN                  :	in    STD_ULOGIC; -- Active high
      REFCLK                  :	in    STD_ULOGIC;
      FB                      :	in    STD_ULOGIC;
      LOWFREQ                 : in    STD_ULOGIC; 
      OSC2                    : in    STD_ULOGIC; 
      OSC1                    : in    STD_ULOGIC; 
      OSC0                    : in    STD_ULOGIC; 
      DIVI5                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI4                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI3                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI2                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI1                   : in    STD_ULOGIC; -- Clock multiplier
      DIVI0                   : in    STD_ULOGIC; -- Clock multiplier
      DIVJ5                   : in    STD_ULOGIC; -- Clock divider
      DIVJ4                   : in    STD_ULOGIC; -- Clock divider
      DIVJ3                   : in    STD_ULOGIC; -- Clock divider
      DIVJ2                   : in    STD_ULOGIC; -- Clock divider
      DIVJ1                   : in    STD_ULOGIC; -- Clock divider
      DIVJ0                   : in    STD_ULOGIC; -- Clock divider
      DELAYLINE4              : in    STD_ULOGIC; -- Delay Value
      DELAYLINE3              : in    STD_ULOGIC; -- Delay Value
      DELAYLINE2              : in    STD_ULOGIC; -- Delay Value
      DELAYLINE1              : in    STD_ULOGIC; -- Delay Value
      DELAYLINE0              : in    STD_ULOGIC; -- Delay Value
      LOCK                    :	out   STD_ULOGIC;
      CLK1                    :	out   STD_ULOGIC;
      CLK2                    :	out   STD_ULOGIC);

end component; 


---------------- CELL:NOR5D ---------------

COMPONENT NOR5D
   port(
          A     : in std_logic;
          B     : in std_logic;
          C     : in std_logic;
          D     : in std_logic;
          E     : in std_logic;
          Y             : out std_logic);
END COMPONENT;




------ Component ADDSUB1 ------
 component ADDSUB1
--pragma translate_off
    generic(
                TimingChecksOn:Boolean :=True;
                Xon: Boolean :=False;
                InstancePath: STRING :="*";
                MsgOn: Boolean :=True;
                tpd_A_S         : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_FCI_S               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_B_S         : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_A_FCO               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_B_FCO               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_AS_FCO              : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_FCI_FCO             : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tipd_A          : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_FCI                : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_B          : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_AS         : VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
                A               : in    STD_ULOGIC;
                FCI             : in    STD_ULOGIC;
                B               : in    STD_ULOGIC;
                AS              : in    STD_ULOGIC;
                S               : out    STD_ULOGIC;
                FCO             : out    STD_ULOGIC);
 end component;



---------------- CELL:NAND5D ---------------

COMPONENT NAND5D
   port(
          A     : in std_logic;
          B     : in std_logic;
          C     : in std_logic;
          D     : in std_logic;
          E     : in std_logic;
          Y             : out std_logic);
END COMPONENT;



------ Component FA1A ------
 component FA1A
--pragma translate_off
    generic(
                TimingChecksOn:Boolean :=True;
                Xon: Boolean :=False;
                InstancePath: STRING :="*";
                MsgOn: Boolean :=True;
                tpd_CI_CO               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_B_CO                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_A_CO                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_CI_S                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_A_S         : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_B_S         : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tipd_CI         : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_B          : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_A          : VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
                CI              : in    STD_ULOGIC;
                B               : in    STD_ULOGIC;
                A               : in    STD_ULOGIC;
                CO              : out    STD_ULOGIC;
                S               : out    STD_ULOGIC);
 end component;



------ Component FA1B ------
 component FA1B
--pragma translate_off
    generic(
                TimingChecksOn:Boolean :=True;
                Xon: Boolean :=False;
                InstancePath: STRING :="*";
                MsgOn: Boolean :=True;
                tpd_A_CO                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_B_CO                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_CI_CO               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_CI_S                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_A_S         : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_B_S         : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tipd_A          : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_B          : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_CI         : VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
                A               : in    STD_ULOGIC;
                B               : in    STD_ULOGIC;
                CI              : in    STD_ULOGIC;
                CO              : out    STD_ULOGIC;
                S               : out    STD_ULOGIC);
 end component;



------ Component FA2A ------
 component FA2A
--pragma translate_off
    generic(
                TimingChecksOn:Boolean :=True;
                Xon: Boolean :=False;
                InstancePath: STRING :="*";
                MsgOn: Boolean :=True;
                tpd_CI_CO               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_B_CO                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_A0_CO               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_A1_CO               : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_A0_S                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_A1_S                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_B_S         : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tpd_CI_S                : VitalDelayType01 := (0.100 ns, 0.100 ns);
                tipd_CI         : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_B          : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_A0         : VitalDelayType01 := (0.000 ns, 0.000 ns);
                tipd_A1         : VitalDelayType01 := (0.000 ns, 0.000 ns));


--pragma translate_on
    port(
                CI              : in    STD_ULOGIC;
                B               : in    STD_ULOGIC;
                A0              : in    STD_ULOGIC;
                A1              : in    STD_ULOGIC;
                CO              : out    STD_ULOGIC;
                S               : out    STD_ULOGIC);
 end component;

  attribute syn_tpd11 : string; 
  attribute syn_tpd11 of inbuf_pci : component is "pad -> y = 2.0";
  attribute syn_tpd12 : string; 
  attribute syn_tpd12 of bibuf_pci : component is "pad -> y = 2.0";
  attribute syn_tpd13 : string; 
  attribute syn_tpd13 of outbuf_pci : component is "d -> pad = 2.0";
  attribute syn_tpd14 : string; 
  attribute syn_tpd14 of tribuff_pci : component is "d,e -> pad = 2.0";

  attribute syn_black_box : boolean;
  attribute syn_black_box of RAM64K36 : component is true;
  attribute syn_tco1 : string;
  attribute syn_tco2 : string;
  attribute syn_tco1 of RAM64K36 : component is
  "RCLK->RD0,RD1,RD2,RD3,RD4,RD5,RD6,RD7,RD8,RD9,RD10,RD11,RD12,RD13,RD14,RD15,RD16,RD17,RD18,RD19,RD20,RD21,RD22,RD23,RD24,RD25,RD26,RD27,RD28,RD29,RD30,RD31,RD32,RD33,RD34,RD35 = 4.0";

 END COMPONENTS;
