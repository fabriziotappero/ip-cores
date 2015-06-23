library ieee;
use ieee.std_logic_1164.all;
use work.fp_generic.all;
use work.fpmult_comp.all;

entity test_fpmult is
end;

architecture testbench of test_fpmult is
  type test_condition_type is record
    a:fp_type;
    b:fp_type;
    p:fp_type;
    msg:string(1 to 43);
  end record;

  type test_condition_array_type is array(positive range <>) of test_condition_type;

	signal clk:std_logic:='0';
	signal d:fpmult_in_type;
	signal q:fpmult_out_type;

  constant number_of_stages:integer:=25;
  constant clock_period:time:=20 ns;
  constant pipeline_delay:time:=number_of_stages*clock_period;

  constant plus_zero:fp_type:=x"00000000";
  constant minus_zero:fp_type:=x"80000000";

  constant plus_normal:fp_type:=x"3FB76CE1";
  constant minus_normal:fp_type:=x"BFB76CE1";

  constant plus_normal_squared:fp_type:=x"40036CD8";
  constant minus_normal_squared:fp_type:=x"C0036CD8";

  constant plus_subnormal:fp_type:=x"00051D75";
  constant minus_subnormal:fp_type:=x"80051D75";

  constant plus_infinite:fp_type:=x"7F800000";
  constant minus_infinite:fp_type:=x"FF800000";

  constant plus_qnan:fp_type:=x"7FC00000";
  constant minus_qnan:fp_type:=x"FFC00000";

  constant plus_snan:fp_type:=x"7FBFFFFF";
  constant minus_snan:fp_type:=x"FFBFFFFF";

  constant multiplier_testset:test_condition_array_type:=
  (
    ----------------------------------------------------------------------------
    -- zero * zero
    ----------------------------------------------------------------------------
    (       plus_zero,       plus_zero,            plus_zero, "+0 * +0 != +0                              " ),
    (       plus_zero,      minus_zero,           minus_zero, "+0 * -0 != -0                              " ),
    (      minus_zero,       plus_zero,           minus_zero, "-0 * +0 != -0                              " ),
    (      minus_zero,      minus_zero,            plus_zero, "-0 * -0 != +0                              " ),

    ----------------------------------------------------------------------------
    -- zero * normal
    ----------------------------------------------------------------------------
    (       plus_zero,     plus_normal,            plus_zero, "+0 * +normal != +0                         " ),
    (       plus_zero,    minus_normal,           minus_zero, "+0 * -normal != -0                         " ),
    (      minus_zero,     plus_normal,           minus_zero, "-0 * +normal != -0                         " ),
    (      minus_zero,    minus_normal,            plus_zero, "-0 * -normal != +0                         " ),

    ----------------------------------------------------------------------------
    -- normal * zero
    ----------------------------------------------------------------------------
    (     plus_normal,       plus_zero,            plus_zero, "+normal * +0 != +0                         " ),
    (     plus_normal,      minus_zero,           minus_zero, "+normal * -0 != -0                         " ),
    (    minus_normal,       plus_zero,           minus_zero, "-normal * +0 != -0                         " ),
    (    minus_normal,      minus_zero,            plus_zero, "-normal * -0 != +0                         " ),

    ----------------------------------------------------------------------------
    -- zero * subnormal
    ----------------------------------------------------------------------------
    (       plus_zero,  plus_subnormal,            plus_zero, "+0 * +subnormal != +0                      " ),
    (       plus_zero, minus_subnormal,           minus_zero, "+0 * -subnormal != -0                      " ),
    (      minus_zero,  plus_subnormal,           minus_zero, "-0 * +subnormal != -0                      " ),
    (      minus_zero, minus_subnormal,            plus_zero, "-0 * -subnormal != +0                      " ),

    ----------------------------------------------------------------------------
    -- subnormal * zero
    ----------------------------------------------------------------------------
    (  plus_subnormal,       plus_zero,            plus_zero, "+subnormal * +0 != +0                      " ),
    (  plus_subnormal,      minus_zero,           minus_zero, "+subnormal * -0 != -0                      " ),
    ( minus_subnormal,       plus_zero,           minus_zero, "-subnormal * +0 != -0                      " ),
    ( minus_subnormal,      minus_zero,            plus_zero, "-subnormal * -0 != +0                      " ),

    ----------------------------------------------------------------------------
    -- zero * infinite
    ----------------------------------------------------------------------------
    (       plus_zero,   plus_infinite,            plus_qnan, "+0 * +infinite != +qnan                    " ),
    (       plus_zero,  minus_infinite,           minus_qnan, "+0 * -infinite != -qnan                    " ),
    (      minus_zero,   plus_infinite,           minus_qnan, "-0 * +infinite != -qnan                    " ),
    (      minus_zero,  minus_infinite,            plus_qnan, "-0 * -infinite != +qnan                    " ),

    ----------------------------------------------------------------------------
    -- infinite * zero
    ----------------------------------------------------------------------------
    (   plus_infinite,       plus_zero,            plus_qnan, "+infinite * +0 != +qnan                    " ),
    (   plus_infinite,      minus_zero,           minus_qnan, "+infinite * -0 != -qnan                    " ),
    (  minus_infinite,       plus_zero,           minus_qnan, "-infinite * +0 != -qnan                    " ),
    (  minus_infinite,      minus_zero,            plus_qnan, "-infinite * -0 != +qnan                    " ),

    ----------------------------------------------------------------------------
    -- zero * qnan
    ----------------------------------------------------------------------------
    (       plus_zero,       plus_qnan,            plus_qnan, "+0 * +qnan != +qnan                        " ),
    (       plus_zero,      minus_qnan,           minus_qnan, "+0 * -qnan != -qnan                        " ),
    (      minus_zero,       plus_qnan,           minus_qnan, "-0 * +qnan != -qnan                        " ),
    (      minus_zero,      minus_qnan,            plus_qnan, "-0 * -qnan != +qnan                        " ),

    ----------------------------------------------------------------------------
    -- qnan * zero
    ----------------------------------------------------------------------------
    (       plus_qnan,       plus_zero,            plus_qnan, "+qnan * +0 != +qnan                        " ),
    (       plus_qnan,      minus_zero,           minus_qnan, "+qnan * -0 != -qnan                        " ),
    (      minus_qnan,       plus_zero,           minus_qnan, "-qnan * +0 != -qnan                        " ),
    (      minus_qnan,      minus_zero,            plus_qnan, "-qnan * -0 != +qnan                        " ),

    ----------------------------------------------------------------------------
    -- zero * snan
    ----------------------------------------------------------------------------
    (       plus_zero,       plus_snan,            plus_qnan, "+0 * +snan != +qnan                        " ),
    (       plus_zero,      minus_snan,           minus_qnan, "+0 * -snan != -qnan                        " ),
    (      minus_zero,       plus_snan,           minus_qnan, "-0 * +snan != -qnan                        " ),
    (      minus_zero,      minus_snan,            plus_qnan, "-0 * -snan != +qnan                        " ),

    ----------------------------------------------------------------------------
    -- snan * zero
    ----------------------------------------------------------------------------
    (       plus_snan,       plus_zero,            plus_qnan, "+snan * +0 != +qnan                        " ),
    (       plus_snan,      minus_zero,           minus_qnan, "+snan * -0 != -qnan                        " ),
    (      minus_snan,       plus_zero,           minus_qnan, "-snan * +0 != -qnan                        " ),
    (      minus_snan,      minus_zero,            plus_qnan, "-snan * -0 != +qnan                        " ),

    ----------------------------------------------------------------------------
    -- normal * normal
    ----------------------------------------------------------------------------
    (     plus_normal,     plus_normal,  plus_normal_squared, "+normal * +normal != +normal               " ),
    (     plus_normal,    minus_normal, minus_normal_squared, "+normal * -normal != -normal               " ),
    (    minus_normal,     plus_normal, minus_normal_squared, "-normal * +normal != -normal               " ),
    (    minus_normal,    minus_normal,  plus_normal_squared, "-normal * -normal != +normal               " ),

    ----------------------------------------------------------------------------
    -- normal * subnormal
    ----------------------------------------------------------------------------
    (     plus_normal,  plus_subnormal,            plus_zero, "+normal * +subnormal != +0                 " ),
    (     plus_normal, minus_subnormal,           minus_zero, "+normal * -subnormal != -0                 " ),
    (    minus_normal,  plus_subnormal,           minus_zero, "-normal * +subnormal != -0                 " ),
    (    minus_normal, minus_subnormal,            plus_zero, "-normal * -subnormal != +0                 " ),

    ----------------------------------------------------------------------------
    -- subnormal * normal
    ----------------------------------------------------------------------------
    (  plus_subnormal,     plus_normal,            plus_zero, "+subnormal * +normal != +0                 " ),
    (  plus_subnormal,    minus_normal,           minus_zero, "+subnormal * -normal != -0                 " ),
    ( minus_subnormal,     plus_normal,           minus_zero, "-subnormal * +normal != -0                 " ),
    ( minus_subnormal,    minus_normal,            plus_zero, "-subnormal * -normal != +0                 " ),

    ----------------------------------------------------------------------------
    -- normal * infinite
    ----------------------------------------------------------------------------
    (     plus_normal,   plus_infinite,        plus_infinite, "+normal * +infinite != +infinite           " ),
    (     plus_normal,  minus_infinite,       minus_infinite, "+normal * -infinite != -infinite           " ),
    (    minus_normal,   plus_infinite,       minus_infinite, "-normal * +infinite != -infinite           " ),
    (    minus_normal,  minus_infinite,        plus_infinite, "-normal * -infinite != +infinite           " ),

    ----------------------------------------------------------------------------
    -- infinite * normal
    ----------------------------------------------------------------------------
    (   plus_infinite,     plus_normal,        plus_infinite, "+infinite * +normal != +infinite           " ),
    (   plus_infinite,    minus_normal,       minus_infinite, "+infinite * -normal != -infinite           " ),
    (  minus_infinite,     plus_normal,       minus_infinite, "-infinite * +normal != -infinite           " ),
    (  minus_infinite,    minus_normal,        plus_infinite, "-infinite * -normal != +infinite           " ),

    ----------------------------------------------------------------------------
    -- normal * qnan
    ----------------------------------------------------------------------------
    (     plus_normal,       plus_qnan,            plus_qnan, "+normal * +qnan != +qnan                   " ),
    (     plus_normal,      minus_qnan,           minus_qnan, "+normal * -qnan != -qnan                   " ),
    (    minus_normal,       plus_qnan,           minus_qnan, "-normal * +qnan != -qnan                   " ),
    (    minus_normal,      minus_qnan,            plus_qnan, "-normal * -qnan != +qnan                   " ),

    ----------------------------------------------------------------------------
    -- qnan * normal
    ----------------------------------------------------------------------------
    (       plus_qnan,     plus_normal,            plus_qnan, "+qnan * +normal != +qnan                   " ),
    (       plus_qnan,    minus_normal,           minus_qnan, "+qnan * -normal != -qnan                   " ),
    (      minus_qnan,     plus_normal,           minus_qnan, "-qnan * +normal != -qnan                   " ),
    (      minus_qnan,    minus_normal,            plus_qnan, "-qnan * -normal != +qnan                   " ),

    ----------------------------------------------------------------------------
    -- normal * snan
    ----------------------------------------------------------------------------
    (     plus_normal,       plus_snan,            plus_qnan, "+normal * +snan != +qnan                   " ),
    (     plus_normal,      minus_snan,           minus_qnan, "+normal * -snan != -qnan                   " ),
    (    minus_normal,       plus_snan,           minus_qnan, "-normal * +snan != -qnan                   " ),
    (    minus_normal,      minus_snan,            plus_qnan, "-normal * -snan != +qnan                   " ),

    ----------------------------------------------------------------------------
    -- snan * normal
    ----------------------------------------------------------------------------
    (       plus_snan,     plus_normal,            plus_qnan, "+snan * +normal != +qnan                   " ),
    (       plus_snan,    minus_normal,           minus_qnan, "+snan * -normal != -qnan                   " ),
    (      minus_snan,     plus_normal,           minus_qnan, "-snan * +normal != -qnan                   " ),
    (      minus_snan,    minus_normal,            plus_qnan, "-snan * -normal != +qnan                   " ),

    ----------------------------------------------------------------------------
    -- subnormal * subnormal
    ----------------------------------------------------------------------------
    (  plus_subnormal,  plus_subnormal,            plus_zero, "+subnormal * +subnormal != +0              " ),
    (  plus_subnormal, minus_subnormal,           minus_zero, "+subnormal * -subnormal != -0              " ),
    ( minus_subnormal,  plus_subnormal,           minus_zero, "-subnormal * +subnormal != -0              " ),
    ( minus_subnormal, minus_subnormal,            plus_zero, "-subnormal * -subnormal != +0              " ),

    ----------------------------------------------------------------------------
    -- subnormal * infinite
    ----------------------------------------------------------------------------
    (  plus_subnormal,   plus_infinite,            plus_qnan, "+subnormal * +infinite != +qnan            " ),
    (  plus_subnormal,  minus_infinite,           minus_qnan, "+subnormal * -infinite != -qnan            " ),
    ( minus_subnormal,   plus_infinite,           minus_qnan, "-subnormal * +infinite != -qnan            " ),
    ( minus_subnormal,  minus_infinite,            plus_qnan, "-subnormal * -infinite != +qnan            " ),

    ----------------------------------------------------------------------------
    -- infinite * subnormal
    ----------------------------------------------------------------------------
    (   plus_infinite,  plus_subnormal,            plus_qnan, "+infinite * +subnormal != +qnan            " ),
    (   plus_infinite, minus_subnormal,           minus_qnan, "+infinite * -subnormal != -qnan            " ),
    (  minus_infinite,  plus_subnormal,           minus_qnan, "-infinite * +subnormal != -qnan            " ),
    (  minus_infinite, minus_subnormal,            plus_qnan, "-infinite * -subnormal != +qnan            " ),

    ----------------------------------------------------------------------------
    -- subnormal * qnan
    ----------------------------------------------------------------------------
    (  plus_subnormal,       plus_qnan,            plus_qnan, "+subnormal * +qnan != +qnan                " ),
    (  plus_subnormal,      minus_qnan,           minus_qnan, "+subnormal * -qnan != -qnan                " ),
    ( minus_subnormal,       plus_qnan,           minus_qnan, "-subnormal * +qnan != -qnan                " ),
    ( minus_subnormal,      minus_qnan,            plus_qnan, "-subnormal * -qnan != +qnan                " ),

    ----------------------------------------------------------------------------
    -- qnan * subnormal
    ----------------------------------------------------------------------------
    (       plus_qnan,  plus_subnormal,            plus_qnan, "+qnan * +subnormal != +qnan                " ),
    (       plus_qnan, minus_subnormal,           minus_qnan, "+qnan * -subnormal != -qnan                " ),
    (      minus_qnan,  plus_subnormal,           minus_qnan, "-qnan * +subnormal != -qnan                " ),
    (      minus_qnan, minus_subnormal,            plus_qnan, "-qnan * -subnormal != +qnan                " ),

    ----------------------------------------------------------------------------
    -- subnormal * snan
    ----------------------------------------------------------------------------
    (  plus_subnormal,       plus_snan,            plus_qnan, "+subnormal * +snan != +qnan                " ),
    (  plus_subnormal,      minus_snan,           minus_qnan, "+subnormal * -snan != -qnan                " ),
    ( minus_subnormal,       plus_snan,           minus_qnan, "-subnormal * +snan != -qnan                " ),
    ( minus_subnormal,      minus_snan,            plus_qnan, "-subnormal * -snan != +qnan                " ),

    ----------------------------------------------------------------------------
    -- snan * subnormal
    ----------------------------------------------------------------------------
    (       plus_snan,  plus_subnormal,            plus_qnan, "+snan * +subnormal != +qnan                " ),
    (       plus_snan, minus_subnormal,           minus_qnan, "+snan * -subnormal != -qnan                " ),
    (      minus_snan,  plus_subnormal,           minus_qnan, "-snan * +subnormal != -qnan                " ),
    (      minus_snan, minus_subnormal,            plus_qnan, "-snan * -subnormal != +qnan                " ),

    ----------------------------------------------------------------------------
    -- infinite * infinite
    ----------------------------------------------------------------------------
    (   plus_infinite,   plus_infinite,        plus_infinite, "+infinite * +infinite != +infinite         " ),
    (   plus_infinite,  minus_infinite,       minus_infinite, "+infinite * -infinite != -infinite         " ),
    (  minus_infinite,   plus_infinite,       minus_infinite, "-infinite * +infinite != -infinite         " ),
    (  minus_infinite,  minus_infinite,        plus_infinite, "-infinite * -infinite != +infinite         " ),

    ----------------------------------------------------------------------------
    -- infinite * qnan
    ----------------------------------------------------------------------------
    (   plus_infinite,       plus_qnan,            plus_qnan, "+infinite * +qnan != +qnan                 " ),
    (   plus_infinite,      minus_qnan,           minus_qnan, "+infinite * -qnan != -qnan                 " ),
    (  minus_infinite,       plus_qnan,           minus_qnan, "-infinite * +qnan != -qnan                 " ),
    (  minus_infinite,      minus_qnan,            plus_qnan, "-infinite * -qnan != +qnan                 " ),

    ----------------------------------------------------------------------------
    -- qnan * infinite
    ----------------------------------------------------------------------------
    (       plus_qnan,   plus_infinite,            plus_qnan, "+qnan * +infinite != +qnan                 " ),
    (       plus_qnan,  minus_infinite,           minus_qnan, "+qnan * -infinite != -qnan                 " ),
    (      minus_qnan,   plus_infinite,           minus_qnan, "-qnan * +infinite != -qnan                 " ),
    (      minus_qnan,  minus_infinite,            plus_qnan, "-qnan * -infinite != +qnan                 " ),

    ----------------------------------------------------------------------------
    -- infinite * snan
    ----------------------------------------------------------------------------
    (   plus_infinite,       plus_snan,            plus_qnan, "+infinite * +snan != +qnan                 " ),
    (   plus_infinite,      minus_snan,           minus_qnan, "+infinite * -snan != -qnan                 " ),
    (  minus_infinite,       plus_snan,           minus_qnan, "-infinite * +snan != -qnan                 " ),
    (  minus_infinite,      minus_snan,            plus_qnan, "-infinite * -snan != +qnan                 " ),

    ----------------------------------------------------------------------------
    -- snan * infinite
    ----------------------------------------------------------------------------
    (       plus_snan,   plus_infinite,            plus_qnan, "+snan * +infinite != +qnan                 " ),
    (       plus_snan,  minus_infinite,           minus_qnan, "+snan * -infinite != -qnan                 " ),
    (      minus_snan,   plus_infinite,           minus_qnan, "-snan * +infinite != -qnan                 " ),
    (      minus_snan,  minus_infinite,            plus_qnan, "-snan * -infinite != +qnan                 " ),

    ----------------------------------------------------------------------------
    -- qnan * qnan
    ----------------------------------------------------------------------------
    (       plus_qnan,       plus_qnan,            plus_qnan, "+qnan * +qnan != +qnan                     " ),
    (       plus_qnan,      minus_qnan,           minus_qnan, "+qnan * -qnan != -qnan                     " ),
    (      minus_qnan,       plus_qnan,           minus_qnan, "-qnan * +qnan != -qnan                     " ),
    (      minus_qnan,      minus_qnan,            plus_qnan, "-qnan * -qnan != +qnan                     " ),

    ----------------------------------------------------------------------------
    -- qnan * snan
    ----------------------------------------------------------------------------
    (       plus_qnan,       plus_snan,            plus_qnan, "+qnan * +snan != +qnan                     " ),
    (       plus_qnan,      minus_snan,           minus_qnan, "+qnan * -snan != -qnan                     " ),
    (      minus_qnan,       plus_snan,           minus_qnan, "-qnan * +snan != -qnan                     " ),
    (      minus_qnan,      minus_snan,            plus_qnan, "-qnan * -snan != +qnan                     " ),

    ----------------------------------------------------------------------------
    -- snan * qnan
    ----------------------------------------------------------------------------
    (       plus_snan,       plus_qnan,            plus_qnan, "+snan * +qnan != +qnan                     " ),
    (       plus_snan,      minus_qnan,           minus_qnan, "+snan * -qnan != -qnan                     " ),
    (      minus_snan,       plus_qnan,           minus_qnan, "-snan * +qnan != -qnan                     " ),
    (      minus_snan,      minus_qnan,            plus_qnan, "-snan * -qnan != +qnan                     " ),

    ----------------------------------------------------------------------------
    -- snan * snan
    ----------------------------------------------------------------------------
    (       plus_snan,       plus_snan,            plus_qnan, "+snan * +snan != +qnan                     " ),
    (       plus_snan,      minus_snan,           minus_qnan, "+snan * -snan != -qnan                     " ),
    (      minus_snan,       plus_snan,           minus_qnan, "-snan * +snan != -qnan                     " ),
    (      minus_snan,      minus_snan,            plus_qnan, "-snan * -snan != +qnan                     " )
  );

  constant pipeline_testset:test_condition_array_type:=
  (
    (     x"2923be84",     x"e16cd6ae",          x"cb177cf2", " 3.63585e-14 * -2.73056e+20 != -9.92792e+06" ),
    (     x"529049f1",     x"f1bbe9eb",          x"ff800000", " 3.09858e+11 * -1.86101e+30 !=    -infinite" ),
    (     x"b3a6db3c",     x"870c3e99",          x"000016da", "-7.76986e-08 * -1.05508e-34 !=   +subnormal" ),
    (     x"245e0d1c",     x"06b747de",          x"00000000", " 4.81497e-17 *  6.89425e-35 !=        +zero" ),
    (     x"b3124dc8",     x"43bb8ba6",          x"b7565d40", "-3.40640e-08 *  3.75091e+02 != -1.27771e-05" ),
    (     x"1f035a7d",     x"0938251f",          x"00000000", " 2.78152e-20 *  2.21656e-33 !=        +zero" ),
    (     x"5dd4cbfc",     x"96f5453b",          x"b54be0c4", " 1.91670e+18 * -3.96256e-25 != -7.59505e-07" ),
    (     x"130d890a",     x"1cdbae32",          x"00000000", " 1.78643e-27 *  1.45372e-21 !=        +zero" ),
    (     x"209a50ee",     x"407836fd",          x"21959f8c", " 2.61422e-19 *  3.87836e+00 !=  1.01389e-18" ),
    (     x"124932f6",     x"9e7d49dc",          x"80000000", " 6.34872e-28 * -1.34090e-20 !=        -zero" ),
    (     x"ad4f14f2",     x"444066d0",          x"b21ba2e0", "-1.17712e-11 *  7.69606e+02 != -9.05922e-09" ),
    (     x"6bc430b7",     x"323ba122",          x"5e8fcb12", " 4.74359e+26 *  1.09215e-08 !=  5.18070e+18" ),
    (     x"f622919d",     x"e18b1fda",          x"7f800000", "-8.24322e+32 * -3.20799e+20 !=    +infinite" ),
    (     x"b0ca9902",     x"b9729d49",          x"2ac0011d", "-1.47409e-09 * -2.31375e-04 !=  3.41068e-13" ),
    (     x"2c807ec5",     x"99d5e980",          x"86d6bd5b", " 3.65205e-12 * -2.21180e-23 != -8.07761e-35" ),
    (     x"b2eac9cc",     x"53bf67d6",          x"c72f8bcb", "-2.73330e-08 *  1.64416e+12 != -4.49398e+04" ),
    (     x"bf14d67e",     x"2ddc8e66",          x"ad803b1f", "-5.81398e-01 *  2.50743e-11 != -1.45782e-11" ),
    (     x"83ef5749",     x"61ff698f",          x"a66ecaa2", "-1.40672e-36 *  5.88941e+20 != -8.28475e-16" ),
    (     x"61cdd11e",     x"9d9c1672",          x"bffafaf4", " 4.74581e+20 * -4.13161e-21 != -1.96078e+00" ),
    (     x"72e61df0",     x"844f4a77",          x"b7ba5525", " 9.11587e+30 * -2.43669e-36 != -2.22126e-05" ),
    (     x"02d7e839",     x"2c53cbc9",          x"00000000", " 3.17247e-37 *  3.00980e-12 !=        +zero" ),
    (     x"121e3374",     x"9e0cf4d5",          x"80000000", " 4.99194e-28 * -7.46217e-21 !=        -zero" ),
    (     x"d49fd4a4",     x"597e35cf",          x"ee9eb693", "-5.49174e+12 *  4.47211e+15 != -2.45597e+28" ),
    (     x"3222f4cc",     x"cfd3902d",          x"c286ab8a", " 9.48530e-09 * -7.09888e+09 != -6.73350e+01" ),
    (     x"48d38f75",     x"e6d91d2a",          x"f0336cb4", " 4.33276e+05 * -5.12646e+23 != -2.22117e+29" ),
    (     x"e5c0f72b",     x"78818744",          x"ff800000", "-1.13907e+23 *  2.10172e+34 !=    -infinite" ),
    (     x"0e5f5000",     x"d4618dbe",          x"a344c0f5", " 2.75254e-30 * -3.87498e+12 != -1.06660e-17" ),
    (     x"7b051507",     x"3b33821f",          x"76baa2b1", " 6.91002e+35 *  2.73908e-03 !=  1.89271e+33" ),
    (     x"187092da",     x"6454ceb1",          x"3d47fbd9", " 3.10934e-24 *  1.57024e+22 !=  4.88242e-02" ),
    (     x"853e6915",     x"f8466a04",          x"3e139421", "-8.95306e-36 * -1.60973e+34 !=  1.44120e-01" ),
    (     x"96730ed9",     x"162f6768",          x"80000000", "-1.96341e-25 *  1.41690e-25 !=        -zero" ),
    (     x"d4f74a4a",     x"d0576876",          x"65d0144c", "-8.49683e+12 * -1.44558e+10 !=  1.22828e+23" ),
    (     x"fa16bb11",     x"adae2488",          x"684d1150", "-1.95660e+35 * -1.97977e-11 !=  3.87362e+24" ),
    (     x"79fe52db",     x"2543e53c",          x"5fc29cd9", " 1.65065e+35 *  1.69912e-16 !=  2.80466e+19" ),
    (     x"f445d3d8",     x"28ce0bf5",          x"dd9f39b5", "-6.26940e+31 *  2.28758e-14 != -1.43418e+18" ),
    (     x"c560593d",     x"97278a59",          x"1d12d375", "-3.58958e+03 * -5.41352e-25 !=  1.94323e-21" ),
    (     x"762dd0c2",     x"c9cd68d4",          x"ff800000", " 8.81349e+32 * -1.68271e+06 !=    -infinite" ),
    (     x"496a7925",     x"08614014",          x"124e4f2a", " 9.60402e+05 *  6.77838e-34 !=  6.50997e-28" ),
    (     x"b13b6aa5",     x"1128c18c",          x"82f7175c", "-2.72727e-09 *  1.33125e-28 != -3.63068e-37" ),
    (     x"d6a90b87",     x"978c2ff1",          x"2eb923ec", "-9.29335e+13 * -9.05939e-25 !=  8.41921e-11" ),
    (     x"151d9a95",     x"c19be1c0",          x"973fef27", " 3.18278e-26 * -1.94852e+01 != -6.20173e-25" ),
    (     x"7ee9a89a",     x"a786c2b5",          x"e6f5ffef", " 1.55293e+38 * -3.74036e-15 != -5.80850e+23" ),
    (     x"54bf9ae7",     x"d923d155",          x"ee75389c", " 6.58350e+12 * -2.88191e+15 != -1.89731e+28" ),
    (     x"903828d1",     x"d96ca166",          x"2a2a39bc", "-3.63190e-29 * -4.16285e+15 !=  1.51191e-13" ),
    (     x"5e4ee130",     x"9cfed971",          x"bbcdf326", " 3.72681e+18 * -1.68645e-21 != -6.28509e-03" ),
    (     x"9fe2a5e2",     x"0c9bb447",          x"80000000", "-9.59892e-20 *  2.39900e-31 !=        -zero" ),
    (     x"65382a46",     x"89a98279",          x"af73e389", " 5.43560e+22 * -4.08080e-33 != -2.21816e-10" ),
    (     x"7a7678c2",     x"63b126df",          x"7f800000", " 3.19939e+35 *  6.53575e+21 !=    +infinite" ),
    (     x"da296d3e",     x"62e09612",          x"fd94a2e8", "-1.19223e+16 *  2.07144e+21 != -2.46965e+37" ),
    (     x"34bf39a6",     x"3f895ef1",          x"34cd398a", " 3.56185e-07 *  1.07321e+00 !=  3.82261e-07" ),
    (     x"6d0ee36c",     x"28a11e20",          x"5633dbaf", " 2.76386e+27 *  1.78877e-14 !=  4.94390e+13" ),
    (     x"1dcbc203",     x"3f410784",          x"1d99a340", " 5.39343e-21 *  7.54021e-01 !=  4.06676e-21" ),
    (     x"0f140565",     x"1b2861c9",          x"00000000", " 7.29800e-30 *  1.39282e-22 !=        +zero" ),
    (     x"c5e72c8e",     x"463608dc",          x"cca461ad", "-7.39757e+03 *  1.16502e+04 != -8.61833e+07" ),
    (     x"f3a88dfe",     x"bef2eb71",          x"731ff13f", "-2.67086e+31 * -4.74453e-01 !=  1.26719e+31" ),
    (     x"ffa0d03b",     x"75068c7e",          x"ffe0d03b", "       -qnan *  1.70561e+32 !=        -snan" ),
    (     x"8778734d",     x"d0be82be",          x"18b8e476", "-1.86913e-34 * -2.55699e+10 !=  4.77936e-24" ),
    (     x"dbc24641",     x"2b8cfa30",          x"c7d5f891", "-1.09367e+17 *  1.00170e-12 != -1.09553e+05" ),
    (     x"7f70f0a7",     x"54863295",          x"7f800000", " 3.20264e+38 *  4.61099e+12 !=    +infinite" ),
    (     x"aa5b6813",     x"0be6fcf5",          x"8000000c", "-1.94872e-13 *  8.89734e-32 !=   -subnormal" ),
    (     x"cabe7d9f",     x"898a411b",          x"14cdc053", "-6.24200e+06 * -3.32835e-33 !=  2.07756e-26" ),
    (     x"fdb84f68",     x"f6727b14",          x"7f800000", "-3.06238e+37 * -1.22952e+33 !=    +infinite" ),
    (     x"99cdd30d",     x"f0443ab4",          x"4a9dc4c8", "-2.12817e-23 * -2.42920e+29 !=  5.16976e+06" ),
    (     x"a6665333",     x"0bcba110",          x"80000000", "-7.99100e-16 *  7.84351e-32 !=        -zero" )
  );
begin

	dut:fpmult port map(clk,d,q);

	clock:process
	begin
	   wait for (clock_period/2);
	   clk<=not clk;
	end process clock;

	stimulus:process
	 variable test_condition:test_condition_type;
	begin
	  -----------------------------------------------------------------------------
	  -- Check qualifying functions and constants
	  -----------------------------------------------------------------------------
    assert not fp_is_normal(plus_zero)                report "Bad +0" severity error;
    assert     fp_is_zero(plus_zero)                  report "Bad +0" severity error;
    assert not fp_is_subnormal(plus_zero)             report "Bad +0" severity error;
    assert not fp_is_infinite(plus_zero)              report "Bad +0" severity error;
    assert not fp_is_nan(plus_zero)                   report "Bad +0" severity error;
    assert not fp_is_signalling(plus_zero)            report "Bad +0" severity error;
    assert not fp_is_quiet(plus_zero)                 report "Bad +0" severity error;
    assert     fp_is_positive(plus_zero)              report "Bad +0" severity error;
    assert not fp_is_negative(plus_zero)              report "Bad +0" severity error;

    assert not fp_is_normal(minus_zero)               report "Bad -0" severity error;
    assert     fp_is_zero(minus_zero)                 report "Bad -0" severity error;
    assert not fp_is_subnormal(minus_zero)            report "Bad -0" severity error;
    assert not fp_is_infinite(minus_zero)             report "Bad -0" severity error;
    assert not fp_is_nan(minus_zero)                  report "Bad -0" severity error;
    assert not fp_is_signalling(minus_zero)           report "Bad -0" severity error;
    assert not fp_is_quiet(minus_zero)                report "Bad -0" severity error;
    assert not fp_is_positive(minus_zero)             report "Bad -0" severity error;
    assert     fp_is_negative(minus_zero)             report "Bad -0" severity error;

    assert     fp_is_normal(plus_normal)              report "Bad +normal" severity error;
    assert not fp_is_zero(plus_normal)                report "Bad +normal" severity error;
    assert not fp_is_subnormal(plus_normal)           report "Bad +normal" severity error;
    assert not fp_is_infinite(plus_normal)            report "Bad +normal" severity error;
    assert not fp_is_nan(plus_normal)                 report "Bad +normal" severity error;
    assert not fp_is_signalling(plus_normal)          report "Bad +normal" severity error;
    assert not fp_is_quiet(plus_normal)               report "Bad +normal" severity error;
    assert     fp_is_positive(plus_normal)            report "Bad +normal" severity error;
    assert not fp_is_negative(plus_normal)            report "Bad +normal" severity error;

    assert     fp_is_normal(minus_normal)             report "Bad -normal" severity error;
    assert not fp_is_zero(minus_normal)               report "Bad -normal" severity error;
    assert not fp_is_subnormal(minus_normal)          report "Bad -normal" severity error;
    assert not fp_is_infinite(minus_normal)           report "Bad -normal" severity error;
    assert not fp_is_nan(minus_normal)                report "Bad -normal" severity error;
    assert not fp_is_signalling(minus_normal)         report "Bad -normal" severity error;
    assert not fp_is_quiet(minus_normal)              report "Bad -normal" severity error;
    assert not fp_is_positive(minus_normal)           report "Bad -normal" severity error;
    assert     fp_is_negative(minus_normal)           report "Bad -normal" severity error;

    assert     fp_is_normal(plus_normal_squared)      report "Bad +normal^2" severity error;
    assert not fp_is_zero(plus_normal_squared)        report "Bad +normal^2" severity error;
    assert not fp_is_subnormal(plus_normal_squared)   report "Bad +normal^2" severity error;
    assert not fp_is_infinite(plus_normal_squared)    report "Bad +normal^2" severity error;
    assert not fp_is_nan(plus_normal_squared)         report "Bad +normal^2" severity error;
    assert not fp_is_signalling(plus_normal_squared)  report "Bad +normal^2" severity error;
    assert not fp_is_quiet(plus_normal_squared)       report "Bad +normal^2" severity error;
    assert     fp_is_positive(plus_normal_squared)    report "Bad +normal^2" severity error;
    assert not fp_is_negative(plus_normal_squared)    report "Bad +normal^2" severity error;

    assert     fp_is_normal(minus_normal_squared)     report "Bad -normal^2" severity error;
    assert not fp_is_zero(minus_normal_squared)       report "Bad -normal^2" severity error;
    assert not fp_is_subnormal(minus_normal_squared)  report "Bad -normal^2" severity error;
    assert not fp_is_infinite(minus_normal_squared)   report "Bad -normal^2" severity error;
    assert not fp_is_nan(minus_normal_squared)        report "Bad -normal^2" severity error;
    assert not fp_is_signalling(minus_normal_squared) report "Bad -normal^2" severity error;
    assert not fp_is_quiet(minus_normal_squared)      report "Bad -normal^2" severity error;
    assert not fp_is_positive(minus_normal_squared)   report "Bad -normal^2" severity error;
    assert     fp_is_negative(minus_normal_squared)   report "Bad -normal^2" severity error;

    assert not fp_is_normal(plus_subnormal)           report "Bad +subnormal" severity error;
    assert not fp_is_zero(plus_subnormal)             report "Bad +subnormal" severity error;
    assert     fp_is_subnormal(plus_subnormal)        report "Bad +subnormal" severity error;
    assert not fp_is_infinite(plus_subnormal)         report "Bad +subnormal" severity error;
    assert not fp_is_nan(plus_subnormal)              report "Bad +subnormal" severity error;
    assert not fp_is_signalling(plus_subnormal)       report "Bad +subnormal" severity error;
    assert not fp_is_quiet(plus_subnormal)            report "Bad +subnormal" severity error;
    assert     fp_is_positive(plus_subnormal)         report "Bad +subnormal" severity error;
    assert not fp_is_negative(plus_subnormal)         report "Bad +subnormal" severity error;

    assert not fp_is_normal(minus_subnormal)          report "Bad -subnormal" severity error;
    assert not fp_is_zero(minus_subnormal)            report "Bad -subnormal" severity error;
    assert     fp_is_subnormal(minus_subnormal)       report "Bad -subnormal" severity error;
    assert not fp_is_infinite(minus_subnormal)        report "Bad -subnormal" severity error;
    assert not fp_is_nan(minus_subnormal)             report "Bad -subnormal" severity error;
    assert not fp_is_signalling(minus_subnormal)      report "Bad -subnormal" severity error;
    assert not fp_is_quiet(minus_subnormal)           report "Bad -subnormal" severity error;
    assert not fp_is_positive(minus_subnormal)        report "Bad -subnormal" severity error;
    assert     fp_is_negative(minus_subnormal)        report "Bad -subnormal" severity error;

    assert not fp_is_normal(plus_infinite)            report "Bad +infinite" severity error;
    assert not fp_is_zero(plus_infinite)              report "Bad +infinite" severity error;
    assert not fp_is_subnormal(plus_infinite)         report "Bad +infinite" severity error;
    assert     fp_is_infinite(plus_infinite)          report "Bad +infinite" severity error;
    assert not fp_is_nan(plus_infinite)               report "Bad +infinite" severity error;
    assert not fp_is_signalling(plus_infinite)        report "Bad +infinite" severity error;
    assert not fp_is_quiet(plus_infinite)             report "Bad +infinite" severity error;
    assert     fp_is_positive(plus_infinite)          report "Bad +infinite" severity error;
    assert not fp_is_negative(plus_infinite)          report "Bad +infinite" severity error;

    assert not fp_is_normal(minus_infinite)           report "Bad -infinite" severity error;
    assert not fp_is_zero(minus_infinite)             report "Bad -infinite" severity error;
    assert not fp_is_subnormal(minus_infinite)        report "Bad -infinite" severity error;
    assert     fp_is_infinite(minus_infinite)         report "Bad -infinite" severity error;
    assert not fp_is_nan(minus_infinite)              report "Bad -infinite" severity error;
    assert not fp_is_signalling(minus_infinite)       report "Bad -infinite" severity error;
    assert not fp_is_quiet(minus_infinite)            report "Bad -infinite" severity error;
    assert not fp_is_positive(minus_infinite)         report "Bad -infinite" severity error;
    assert     fp_is_negative(minus_infinite)         report "Bad -infinite" severity error;

    assert not fp_is_normal(plus_qnan)                report "Bad +qnan" severity error;
    assert not fp_is_zero(plus_qnan)                  report "Bad +qnan" severity error;
    assert not fp_is_subnormal(plus_qnan)             report "Bad +qnan" severity error;
    assert not fp_is_infinite(plus_qnan)              report "Bad +qnan" severity error;
    assert     fp_is_nan(plus_qnan)                   report "Bad +qnan" severity error;
    assert not fp_is_signalling(plus_qnan)            report "Bad +qnan" severity error;
    assert     fp_is_quiet(plus_qnan)                 report "Bad +qnan" severity error;
    assert     fp_is_positive(plus_qnan)              report "Bad +qnan" severity error;
    assert not fp_is_negative(plus_qnan)              report "Bad +qnan" severity error;

    assert not fp_is_normal(minus_qnan)               report "Bad -qnan" severity error;
    assert not fp_is_zero(minus_qnan)                 report "Bad -qnan" severity error;
    assert not fp_is_subnormal(minus_qnan)            report "Bad -qnan" severity error;
    assert not fp_is_infinite(minus_qnan)             report "Bad -qnan" severity error;
    assert     fp_is_nan(minus_qnan)                  report "Bad -qnan" severity error;
    assert not fp_is_signalling(minus_qnan)           report "Bad -qnan" severity error;
    assert     fp_is_quiet(minus_qnan)                report "Bad -qnan" severity error;
    assert not fp_is_positive(minus_qnan)             report "Bad -qnan" severity error;
    assert     fp_is_negative(minus_qnan)             report "Bad -qnan" severity error;

    assert not fp_is_normal(plus_snan)                report "Bad +snan" severity error;
    assert not fp_is_zero(plus_snan)                  report "Bad +snan" severity error;
    assert not fp_is_subnormal(plus_snan)             report "Bad +snan" severity error;
    assert not fp_is_infinite(plus_snan)              report "Bad +snan" severity error;
    assert     fp_is_nan(plus_snan)                   report "Bad +snan" severity error;
    assert     fp_is_signalling(plus_snan)            report "Bad +snan" severity error;
    assert not fp_is_quiet(plus_snan)                 report "Bad +snan" severity error;
    assert     fp_is_positive(plus_snan)              report "Bad +snan" severity error;
    assert not fp_is_negative(plus_snan)              report "Bad +snan" severity error;

    assert not fp_is_normal(minus_snan)               report "Bad -snan" severity error;
    assert not fp_is_zero(minus_snan)                 report "Bad -snan" severity error;
    assert not fp_is_subnormal(minus_snan)            report "Bad -snan" severity error;
    assert not fp_is_infinite(minus_snan)             report "Bad -snan" severity error;
    assert     fp_is_nan(minus_snan)                  report "Bad -snan" severity error;
    assert     fp_is_signalling(minus_snan)           report "Bad -snan" severity error;
    assert not fp_is_quiet(minus_snan)                report "Bad -snan" severity error;
    assert not fp_is_positive(minus_snan)             report "Bad -snan" severity error;
    assert     fp_is_negative(minus_snan)             report "Bad -snan" severity error;

	  -----------------------------------------------------------------------------
	  -- Check multiplier
	  -----------------------------------------------------------------------------
    for i in multiplier_testset'range loop
      test_condition:=multiplier_testset(i);
      d.a<=test_condition.a;
      d.b<=test_condition.b;
      wait for pipeline_delay;
	    assert q.p = test_condition.p report test_condition.msg severity error;
	  end loop;

	  -----------------------------------------------------------------------------
	  -- Check pipeline
	  -----------------------------------------------------------------------------
    for i in pipeline_testset'range loop
      test_condition:=pipeline_testset(i);
      d.a<=test_condition.a;
      d.b<=test_condition.b;
      wait for clock_period;
      if i>=number_of_stages then
        assert q.p = pipeline_testset(i-number_of_stages+1).p report pipeline_testset(i-number_of_stages+1).msg severity error;
      end if;
	  end loop;

	  d.a<="0"&"01111111"&"10110010100011101010101";  -- 0x3FD94755 -> +1.69748938083648681640625E0
	  d.b<="0"&"01111111"&"01101110110110011100001";  -- 0x3FB76CE1 -> +1.43301022052764892578125E0
	  --    0   01111111 100110111010111001100110110100101000110110110101
	  --    0   10000000  100110111010111001100110110100101000110110110101
	  --    0   10000000   00110111010111001100111       0x401bae67 -> +2.4325196743011474609375E0
	  --    |-----||--||-----||--||--||--||--||--|
    wait for 20 ns;

	  d.a<="1"&"10000000"&"10010010000111111011011";  -- 0xC0490FDB -> -3.1415927410125732421875E0
	  d.b<="0"&"10000010"&"00001011110001011101010";  -- 0x4105E2EA -> +8.3678989410400390625E0
	  --    1   10000011 011010010010011101110100100011101101010000101110
	  --    1   10000011  11010010010011101110100100011101101010000101110
	  --    1   10000011   10100100100111011101001       0xC1D24EE9 -> -2.62885303497314453125E1 
	  --    |-----||--||-----||--||--||--||--||--|
    wait for 20 ns;

	  d.a<="1"&"10000101"&"01110011100001000111010";  -- 0xC2B9C23A -> -9.28793487548828125E1
	  d.b<="1"&"10000111"&"11010001001111000001110";  -- 0xC3E89E0E -> -4.6523480224609375E2
	  --    0   10001101 101010001100101010110100100110000110101100101100
	  --    0   10001110  101010001100101010110100100110000110101100101100
	  --    0   10001110   01010001100101010110101       0x4728CAB5 -> +4.321070703125E4  
	  --    |-----||--||-----||--||--||--||--||--|
    wait for 20 ns;

    wait for 1 us;
	end process stimulus;

end testbench;

