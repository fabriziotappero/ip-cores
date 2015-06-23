// File Name    : controlmode.c
// Version      : v1.2
// Description  : control block for operation mode
// Purpose      : to generate structural description of control mode
// Author       : Sigit Dewantoro
// Address      : IS Laboratory, Labtek VIII, ITB, Jl. Ganesha 10, Bandung, Indonesia
// Email        : sigit@students.ee.itb.ac.id, sigit@ic.vlsi.itb.ac.id
// Date         : August 24th, 2001

#include <genlib.h>

main()
{
 int i;

 DEF_LOFIG ("controlmode");

 LOCON ("clk", IN, "clk");
 LOCON ("start", IN, "start");
 LOCON ("mode[0:1]", IN, "mode[0:1]");

 LOCON ("cke", IN, "cke");
 LOCON ("ikey_ready", IN, "ikey_ready");
 LOCON ("key_ready", IN, "key_ready");
 LOCON ("dt_ready", IN, "dt_ready");
 LOCON ("finish", IN, "finish");
 LOCON ("req_cp", IN, "req_cp");
 LOCON ("E", IN, "E");

 LOCON ("first_dt", OUT, "first_dt");
 LOCON ("E_mesin", OUT, "E_mesin");
 LOCON ("s_mesin", OUT, "s_mesin");
 LOCON ("s_gen_key", OUT, "s_gen_key");
 LOCON ("emp_buf", OUT, "emp_buf");
 LOCON ("cp_ready", OUT, "cp_ready");
 LOCON ("cke_b_mode", OUT, "cke_b_mode");
 LOCON ("en_in", OUT, "en_in");
 LOCON ("en_iv", OUT, "en_iv");
 LOCON ("en_rcbc", OUT, "en_rcbc");
 LOCON ("en_out", OUT, "en_out");
 LOCON ("sel1[0:1]", OUT, "sel1[0:1]");
 LOCON ("sel2[0:1]", OUT, "sel2[0:1]");
 LOCON ("sel3[0:1]", OUT, "sel3[0:1]");

 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");

 LOINS ("dec_mode", "decmode", "start", "mode[1:0]", "modeecb", "modecbc", "modecfb",
        "modeofb", "vdd", "vss", 0);

 LOINS ("ecb", "ecb", "modeecb", "clk", "cke", "key_ready", "finish", "req_cp",
        "E", "E_mesin_ecb", "s_mesin_ecb", "s_gen_key_ecb", "emp_buf_ecb", "cp_ready_ecb",
        "cke_b_mode_ecb", "en_in_ecb", "en_iv_ecb", "en_rcbc_ecb", "en_out_ecb", "sel1_ecb[1:0]",
        "sel2_ecb[1:0]", "sel3_ecb[1:0]", "vdd", "vss", 0);

 LOINS ("cbc", "cbc", "modecbc", "clk", "cke", "ikey_ready", "key_ready", "dt_ready",
        "finish", "E", "first_dt_cbc", "E_mesin_cbc", "s_mesin_cbc", "s_gen_key_cbc", "emp_buf_cbc",
        "cp_ready_cbc", "cke_b_mode_cbc", "en_in_cbc", "en_iv_cbc", "en_rcbc_cbc", "en_out_cbc",
        "sel1_cbc[1:0]", "sel2_cbc[1:0]", "sel3_cbc[1:0]", "vdd", "vss", 0);

 LOINS ("cfb", "cfb", "modecfb", "clk", "key_ready", "dt_ready", "finish",
        "E", "first_dt_cfb", "E_mesin_cfb", "s_mesin_cfb", "s_gen_key_cfb", "emp_buf_cfb",
        "cp_ready_cfb", "cke_b_mode_cfb", "en_in_cfb", "en_iv_cfb", "en_rcbc_cfb", "en_out_cfb",
        "sel1_cfb[1:0]", "sel2_cfb[1:0]", "sel3_cfb[1:0]", "vdd", "vss", 0);

 LOINS ("ofb", "ofb", "modeofb", "clk", "key_ready", "dt_ready", "finish","first_dt_ofb",
        "E_mesin_ofb", "s_mesin_ofb", "emp_buf_ofb", "cp_ready_ofb",
        "cke_b_mode_ofb", "en_in_ofb", "en_iv_ofb", "en_rcbc_ofb", "en_out_ofb",
        "sel1_ofb[1:0]", "sel2_ofb[1:0]", "sel3_ofb[1:0]", "vdd", "vss", 0);

 LOINS ("zero_x0", "zero", "nol", "vdd", "vss", 0);

 LOINS ("mux01", "mux_first_dt", "nol", "first_dt_cbc", "first_dt_cfb", "first_dt_ofb",
        "mode[1:0]", "first_dt", "vdd", "vss", 0);
 LOINS ("mux01", "mux_E_mesin", "E_mesin_ecb", "E_mesin_cbc", "E_mesin_cfb", "E_mesin_ofb",
        "mode[1:0]", "E_mesin", "vdd", "vss", 0);
 LOINS ("mux01", "mux_s_mesin", "s_mesin_ecb", "s_mesin_cbc", "s_mesin_cfb", "s_mesin_ofb",
        "mode[1:0]", "s_mesin", "vdd", "vss", 0);
 LOINS ("mux01", "mux_s_gen_key", "s_gen_key_ecb", "s_gen_key_cbc", "s_gen_key_cfb", "cke_b_mode_ofb",
        "mode[1:0]", "s_gen_key", "vdd", "vss", 0);
 LOINS ("mux01", "mux_emp_buf", "emp_buf_ecb", "emp_buf_cbc", "emp_buf_cfb", "emp_buf_ofb",
        "mode[1:0]", "emp_buf", "vdd", "vss", 0);
 LOINS ("mux01", "mux_cp_ready", "cp_ready_ecb", "cp_ready_cbc", "cp_ready_cfb", "cp_ready_ofb",
        "mode[1:0]", "cp_ready", "vdd", "vss", 0);
 LOINS ("mux01", "mux_cke_b_mode", "cke_b_mode_ecb", "cke_b_mode_cbc", "cke_b_mode_cfb", "cke_b_mode_ofb",
        "mode[1:0]", "cke_b_mode", "vdd", "vss", 0);
 LOINS ("mux01", "mux_en_in", "en_in_ecb", "en_in_cbc", "en_in_cfb", "en_in_ofb",
        "mode[1:0]", "en_in", "vdd", "vss", 0);
 LOINS ("mux01", "mux_en_iv", "en_iv_ecb", "en_iv_cbc", "en_iv_cfb", "en_iv_ofb",
        "mode[1:0]", "en_iv", "vdd", "vss", 0);
 LOINS ("mux01", "mux_en_rcbc", "en_rcbc_ecb", "en_rcbc_cbc", "en_rcbc_cfb", "en_rcbc_ofb",
        "mode[1:0]", "en_rcbc", "vdd", "vss", 0);
 LOINS ("mux01", "mux_en_out", "en_out_ecb", "en_out_cbc", "en_out_cfb", "en_out_ofb",
        "mode[1:0]", "en_out", "vdd", "vss", 0);

 LOINS ("mux02", "mux_sel1", "sel1_ecb[1:0]", "sel1_cbc[1:0]", "sel1_cfb[1:0]", "sel1_ofb[1:0]",
        "mode[1:0]", "sel1[1:0]", "vdd", "vss", 0);
 LOINS ("mux02", "mux_sel2", "sel2_ecb[1:0]", "sel2_cbc[1:0]", "sel2_cfb[1:0]", "sel2_ofb[1:0]",
        "mode[1:0]", "sel2[1:0]", "vdd", "vss", 0);
 LOINS ("mux02", "mux_sel3", "sel3_ecb[1:0]", "sel3_cbc[1:0]", "sel3_cfb[1:0]", "sel3_ofb[1:0]",
        "mode[1:0]", "sel3[1:0]", "vdd", "vss", 0);

 SAVE_LOFIG();
 exit(0);
}
