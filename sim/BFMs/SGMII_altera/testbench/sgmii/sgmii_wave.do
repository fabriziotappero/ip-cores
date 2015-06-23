# Copyright (C) 1991-2008 Altera Corporation
# Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
# support information,  device programming or simulation file,  and any other
# associated  documentation or information  provided by  Altera  or a partner
# under  Altera's   Megafunction   Partnership   Program  may  be  used  only
# to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
# other  use  of such  megafunction  design,  netlist,  support  information,
# device programming or simulation file,  or any other  related documentation
# or information  is prohibited  for  any  other purpose,  including, but not
# limited to  modification,  reverse engineering,  de-compiling, or use  with
# any other  silicon devices,  unless such use is  explicitly  licensed under
# a separate agreement with  Altera  or a megafunction partner.  Title to the
# intellectual property,  including patents,  copyrights,  trademarks,  trade
# secrets,  or maskworks,  embodied in any such megafunction design, netlist,
# support  information,  device programming or simulation file,  or any other
# related documentation or information provided by  Altera  or a megafunction
# partner, remains with Altera, the megafunction partner, or their respective
# licensors. No other licenses, including any licenses needed under any third
# party's intellectual property, are provided herein.


#####################################################################################
# Description : 
#
# ModelSIM HDL Simulator wave macro file
# 
#####################################################################################


onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider -height 40 {TESTBENCH INTERFACE}
if [regexp {/tb/reset} [find signals /tb/reset]]                            {add wave -noupdate -format Logic -radix hexadecimal /tb/reset}
if [regexp {/tb/reset_model} [find signals /tb/reset_model]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/reset_model}
if [regexp {/tb/reset_mdio} [find signals /tb/reset_mdio]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/reset_mdio}
if [regexp {/tb/state} [find signals /tb/state]]                            {add wave -noupdate -format Literal -radix unsigned /tb/state}
if [regexp {/tb/nextstate} [find signals /tb/nextstate]]                    {add wave -noupdate -format Literal -radix unsigned /tb/nextstate}
if [regexp {/tb/sim_start} [find signals /tb/sim_start]]                    {add wave -noupdate -format Logic -radix hexadecimal /tb/sim_start}
if [regexp {/tb/sim_stop} [find signals /tb/sim_stop]]                      {add wave -noupdate -format Logic -radix hexadecimal /tb/sim_stop}
if [regexp {/tb/frm_gen_ena_gmii} [find signals /tb/frm_gen_ena_gmii]]      {add wave -noupdate -format Logic /tb/frm_gen_ena_gmii}
if [regexp {/tb/frm_gen_ena_mii} [find signals /tb/frm_gen_ena_mii]]        {add wave -noupdate -format Logic /tb/frm_gen_ena_mii}
if [regexp {/tb/rxframe_cnt} [find signals /tb/rxframe_cnt]]                {add wave -noupdate -format Literal -radix unsigned /tb/rxframe_cnt}
if [regexp {/tb/rx_frm_cnt} [find signals /tb/rx_frm_cnt]]                  {add wave -noupdate -format Literal -radix unsigned /tb/rx_frm_cnt}
if [regexp {/tb/rxsim_done} [find signals /tb/rxsim_done]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/rxsim_done}
if [regexp {/tb/txframe_cnt} [find signals /tb/txframe_cnt]]                {add wave -noupdate -format Literal -radix unsigned /tb/txframe_cnt}
if [regexp {/tb/tx_frm_cnt} [find signals /tb/tx_frm_cnt]]                  {add wave -noupdate -format Literal -radix unsigned /tb/tx_frm_cnt}
if [regexp {/tb/txsim_done} [find signals /tb/txsim_done]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/txsim_done}


add wave -noupdate -divider -height 40 {CONTROL INTERFACE}  
if [regexp {/tb/dut/reset} [find signals /tb/dut/reset]]                    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/reset}
if [regexp {/tb/dut/reset_reg_clk} [find signals /tb/dut/reset_reg_clk]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/reset_reg_clk}
if [regexp {/tb/dut/reset_tx_clk} [find signals /tb/dut/reset_tx_clk]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/reset_tx_clk}
if [regexp {/tb/dut/reset_rx_clk} [find signals /tb/dut/reset_rx_clk]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/reset_rx_clk}
if [regexp {/tb/dut/clk} [find signals /tb/dut/clk]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/clk}
if [regexp {/tb/dut/address} [find signals /tb/dut/address]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/address}
if [regexp {/tb/dut/readdata} [find signals /tb/dut/readdata]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/readdata}
if [regexp {/tb/dut/read} [find signals /tb/dut/read]]                      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/read}
if [regexp {/tb/dut/writedata} [find signals /tb/dut/writedata]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/writedata}
if [regexp {/tb/dut/write} [find signals /tb/dut/write]]                    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/write}
if [regexp {/tb/dut/waitrequest} [find signals /tb/dut/waitrequest]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/waitrequest}
if [regexp {/tb/dut/reg_clk} [find signals /tb/dut/reg_clk]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/reg_clk}
if [regexp {/tb/dut/reg_addr} [find signals /tb/dut/reg_addr]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/reg_addr}
if [regexp {/tb/dut/reg_data_in} [find signals /tb/dut/reg_data_in]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/reg_data_in}
if [regexp {/tb/dut/reg_rd} [find signals /tb/dut/reg_rd]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/reg_rd}
if [regexp {/tb/dut/reg_data_out} [find signals /tb/dut/reg_data_out]]      {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/reg_data_out}
if [regexp {/tb/dut/reg_wr} [find signals /tb/dut/reg_wr]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/reg_wr}
if [regexp {/tb/dut/reg_busy} [find signals /tb/dut/reg_busy]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/reg_busy}

add wave -noupdate -divider -height 40 {RECEIVE INTERFACE}
if [regexp {/tb/dut/tbi_rx_d} [find signals /tb/dut/tbi_rx_d]]              {add wave -noupdate -divider {  PMA TBI RX}}
if [regexp {/tb/dut/tbi_rx_clk} [find signals /tb/dut/tbi_rx_clk]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk}
if [regexp {/tb/dut/tbi_rx_d} [find signals /tb/dut/tbi_rx_d]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d}

if [regexp {/tb/dut/tbi_rx_d_0} [find signals /tb/dut/tbi_rx_d_0]]              {add wave -noupdate -divider {  PMA TBI RX 0}}
if [regexp {/tb/dut/tbi_rx_clk_0} [find signals /tb/dut/tbi_rx_clk_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_0}
if [regexp {/tb/dut/tbi_rx_d_0} [find signals /tb/dut/tbi_rx_d_0]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_0}

if [regexp {/tb/dut/tbi_rx_d_1} [find signals /tb/dut/tbi_rx_d_1]]              {add wave -noupdate -divider {  PMA TBI RX 1}}
if [regexp {/tb/dut/tbi_rx_clk_1} [find signals /tb/dut/tbi_rx_clk_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_1}
if [regexp {/tb/dut/tbi_rx_d_1} [find signals /tb/dut/tbi_rx_d_1]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_1}

if [regexp {/tb/dut/tbi_rx_d_2} [find signals /tb/dut/tbi_rx_d_2]]              {add wave -noupdate -divider {  PMA TBI RX 2}}
if [regexp {/tb/dut/tbi_rx_clk_2} [find signals /tb/dut/tbi_rx_clk_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_2}
if [regexp {/tb/dut/tbi_rx_d_2} [find signals /tb/dut/tbi_rx_d_2]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_2}

if [regexp {/tb/dut/tbi_rx_d_3} [find signals /tb/dut/tbi_rx_d_3]]              {add wave -noupdate -divider {  PMA TBI RX 3}}
if [regexp {/tb/dut/tbi_rx_clk_3} [find signals /tb/dut/tbi_rx_clk_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_3}
if [regexp {/tb/dut/tbi_rx_d_3} [find signals /tb/dut/tbi_rx_d_3]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_3}

if [regexp {/tb/dut/tbi_rx_d_4} [find signals /tb/dut/tbi_rx_d_4]]              {add wave -noupdate -divider {  PMA TBI RX 4}}
if [regexp {/tb/dut/tbi_rx_clk_4} [find signals /tb/dut/tbi_rx_clk_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_4}
if [regexp {/tb/dut/tbi_rx_d_4} [find signals /tb/dut/tbi_rx_d_4]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_4}

if [regexp {/tb/dut/tbi_rx_d_5} [find signals /tb/dut/tbi_rx_d_5]]              {add wave -noupdate -divider {  PMA TBI RX 5}}
if [regexp {/tb/dut/tbi_rx_clk_5} [find signals /tb/dut/tbi_rx_clk_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_5}
if [regexp {/tb/dut/tbi_rx_d_5} [find signals /tb/dut/tbi_rx_d_5]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_5}

if [regexp {/tb/dut/tbi_rx_d_6} [find signals /tb/dut/tbi_rx_d_6]]              {add wave -noupdate -divider {  PMA TBI RX 6}}
if [regexp {/tb/dut/tbi_rx_clk_6} [find signals /tb/dut/tbi_rx_clk_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_6}
if [regexp {/tb/dut/tbi_rx_d_6} [find signals /tb/dut/tbi_rx_d_6]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_6}

if [regexp {/tb/dut/tbi_rx_d_7} [find signals /tb/dut/tbi_rx_d_7]]              {add wave -noupdate -divider {  PMA TBI RX 7}}
if [regexp {/tb/dut/tbi_rx_clk_7} [find signals /tb/dut/tbi_rx_clk_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_7}
if [regexp {/tb/dut/tbi_rx_d_7} [find signals /tb/dut/tbi_rx_d_7]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_7}

if [regexp {/tb/dut/tbi_rx_d_8} [find signals /tb/dut/tbi_rx_d_8]]              {add wave -noupdate -divider {  PMA TBI RX 8}}
if [regexp {/tb/dut/tbi_rx_clk_8} [find signals /tb/dut/tbi_rx_clk_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_8}
if [regexp {/tb/dut/tbi_rx_d_8} [find signals /tb/dut/tbi_rx_d_8]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_8}

if [regexp {/tb/dut/tbi_rx_d_9} [find signals /tb/dut/tbi_rx_d_9]]              {add wave -noupdate -divider {  PMA TBI RX 9}}
if [regexp {/tb/dut/tbi_rx_clk_9} [find signals /tb/dut/tbi_rx_clk_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_9}
if [regexp {/tb/dut/tbi_rx_d_9} [find signals /tb/dut/tbi_rx_d_9]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_9}

if [regexp {/tb/dut/tbi_rx_d_10} [find signals /tb/dut/tbi_rx_d_10]]              {add wave -noupdate -divider {  PMA TBI RX 10}}
if [regexp {/tb/dut/tbi_rx_clk_10} [find signals /tb/dut/tbi_rx_clk_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_10}
if [regexp {/tb/dut/tbi_rx_d_10} [find signals /tb/dut/tbi_rx_d_10]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_10}

if [regexp {/tb/dut/tbi_rx_d_11} [find signals /tb/dut/tbi_rx_d_11]]              {add wave -noupdate -divider {  PMA TBI RX 11}}
if [regexp {/tb/dut/tbi_rx_clk_11} [find signals /tb/dut/tbi_rx_clk_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_11}
if [regexp {/tb/dut/tbi_rx_d_11} [find signals /tb/dut/tbi_rx_d_11]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_11}

if [regexp {/tb/dut/tbi_rx_d_12} [find signals /tb/dut/tbi_rx_d_12]]              {add wave -noupdate -divider {  PMA TBI RX 12}}
if [regexp {/tb/dut/tbi_rx_clk_12} [find signals /tb/dut/tbi_rx_clk_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_12}
if [regexp {/tb/dut/tbi_rx_d_12} [find signals /tb/dut/tbi_rx_d_12]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_12}

if [regexp {/tb/dut/tbi_rx_d_13} [find signals /tb/dut/tbi_rx_d_13]]              {add wave -noupdate -divider {  PMA TBI RX 13}}
if [regexp {/tb/dut/tbi_rx_clk_13} [find signals /tb/dut/tbi_rx_clk_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_13}
if [regexp {/tb/dut/tbi_rx_d_13} [find signals /tb/dut/tbi_rx_d_13]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_13}

if [regexp {/tb/dut/tbi_rx_d_14} [find signals /tb/dut/tbi_rx_d_14]]              {add wave -noupdate -divider {  PMA TBI RX 14}}
if [regexp {/tb/dut/tbi_rx_clk_14} [find signals /tb/dut/tbi_rx_clk_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_14}
if [regexp {/tb/dut/tbi_rx_d_14} [find signals /tb/dut/tbi_rx_d_14]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_14}

if [regexp {/tb/dut/tbi_rx_d_15} [find signals /tb/dut/tbi_rx_d_15]]              {add wave -noupdate -divider {  PMA TBI RX 15}}
if [regexp {/tb/dut/tbi_rx_clk_15} [find signals /tb/dut/tbi_rx_clk_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_15}
if [regexp {/tb/dut/tbi_rx_d_15} [find signals /tb/dut/tbi_rx_d_15]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_15}

if [regexp {/tb/dut/tbi_rx_d_16} [find signals /tb/dut/tbi_rx_d_16]]              {add wave -noupdate -divider {  PMA TBI RX 16}}
if [regexp {/tb/dut/tbi_rx_clk_16} [find signals /tb/dut/tbi_rx_clk_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_16}
if [regexp {/tb/dut/tbi_rx_d_16} [find signals /tb/dut/tbi_rx_d_16]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_16}

if [regexp {/tb/dut/tbi_rx_d_17} [find signals /tb/dut/tbi_rx_d_17]]              {add wave -noupdate -divider {  PMA TBI RX 17}}
if [regexp {/tb/dut/tbi_rx_clk_17} [find signals /tb/dut/tbi_rx_clk_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_17}
if [regexp {/tb/dut/tbi_rx_d_17} [find signals /tb/dut/tbi_rx_d_17]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_17}

if [regexp {/tb/dut/tbi_rx_d_18} [find signals /tb/dut/tbi_rx_d_18]]              {add wave -noupdate -divider {  PMA TBI RX 18}}
if [regexp {/tb/dut/tbi_rx_clk_18} [find signals /tb/dut/tbi_rx_clk_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_18}
if [regexp {/tb/dut/tbi_rx_d_18} [find signals /tb/dut/tbi_rx_d_18]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_18}

if [regexp {/tb/dut/tbi_rx_d_19} [find signals /tb/dut/tbi_rx_d_19]]              {add wave -noupdate -divider {  PMA TBI RX 19}}
if [regexp {/tb/dut/tbi_rx_clk_19} [find signals /tb/dut/tbi_rx_clk_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_19}
if [regexp {/tb/dut/tbi_rx_d_19} [find signals /tb/dut/tbi_rx_d_19]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_19}

if [regexp {/tb/dut/tbi_rx_d_20} [find signals /tb/dut/tbi_rx_d_20]]              {add wave -noupdate -divider {  PMA TBI RX 20}}
if [regexp {/tb/dut/tbi_rx_clk_20} [find signals /tb/dut/tbi_rx_clk_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_20}
if [regexp {/tb/dut/tbi_rx_d_20} [find signals /tb/dut/tbi_rx_d_20]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_20}

if [regexp {/tb/dut/tbi_rx_d_21} [find signals /tb/dut/tbi_rx_d_21]]              {add wave -noupdate -divider {  PMA TBI RX 21}}
if [regexp {/tb/dut/tbi_rx_clk_21} [find signals /tb/dut/tbi_rx_clk_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_21}
if [regexp {/tb/dut/tbi_rx_d_21} [find signals /tb/dut/tbi_rx_d_21]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_21}

if [regexp {/tb/dut/tbi_rx_d_22} [find signals /tb/dut/tbi_rx_d_22]]              {add wave -noupdate -divider {  PMA TBI RX 22}}
if [regexp {/tb/dut/tbi_rx_clk_22} [find signals /tb/dut/tbi_rx_clk_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_22}
if [regexp {/tb/dut/tbi_rx_d_22} [find signals /tb/dut/tbi_rx_d_22]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_22}

if [regexp {/tb/dut/tbi_rx_d_23} [find signals /tb/dut/tbi_rx_d_23]]              {add wave -noupdate -divider {  PMA TBI RX 23}}
if [regexp {/tb/dut/tbi_rx_clk_23} [find signals /tb/dut/tbi_rx_clk_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_rx_clk_23}
if [regexp {/tb/dut/tbi_rx_d_23} [find signals /tb/dut/tbi_rx_d_23]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_rx_d_23}


if [regexp {/tb/dut/rxp} [find signals /tb/dut/rxp]]                        {add wave -noupdate -divider {  PMA SERIAL RX}}
if [regexp {/tb/dut/ref_clk} [find signals /tb/dut/ref_clk]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ref_clk}
if [regexp {/tb/dut/rxp} [find signals /tb/dut/rxp]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp}

if [regexp {/tb/dut/rxp_0} [find signals /tb/dut/rxp_0]]                        {add wave -noupdate -divider {  PMA SERIAL RX 0}}
if [regexp {/tb/dut/rxp_0} [find signals /tb/dut/rxp_0]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_0}

if [regexp {/tb/dut/rxp_1} [find signals /tb/dut/rxp_1]]                        {add wave -noupdate -divider {  PMA SERIAL RX 1}}
if [regexp {/tb/dut/rxp_1} [find signals /tb/dut/rxp_1]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_1}

if [regexp {/tb/dut/rxp_2} [find signals /tb/dut/rxp_2]]                        {add wave -noupdate -divider {  PMA SERIAL RX 2}}
if [regexp {/tb/dut/rxp_2} [find signals /tb/dut/rxp_2]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_2}

if [regexp {/tb/dut/rxp_3} [find signals /tb/dut/rxp_3]]                        {add wave -noupdate -divider {  PMA SERIAL RX 3}}
if [regexp {/tb/dut/rxp_3} [find signals /tb/dut/rxp_3]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_3}

if [regexp {/tb/dut/rxp_4} [find signals /tb/dut/rxp_4]]                        {add wave -noupdate -divider {  PMA SERIAL RX 4}}
if [regexp {/tb/dut/rxp_4} [find signals /tb/dut/rxp_4]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_4}

if [regexp {/tb/dut/rxp_5} [find signals /tb/dut/rxp_5]]                        {add wave -noupdate -divider {  PMA SERIAL RX 5}}
if [regexp {/tb/dut/rxp_5} [find signals /tb/dut/rxp_5]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_5}

if [regexp {/tb/dut/rxp_6} [find signals /tb/dut/rxp_6]]                        {add wave -noupdate -divider {  PMA SERIAL RX 6}}
if [regexp {/tb/dut/rxp_6} [find signals /tb/dut/rxp_6]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_6}

if [regexp {/tb/dut/rxp_7} [find signals /tb/dut/rxp_7]]                        {add wave -noupdate -divider {  PMA SERIAL RX 7}}
if [regexp {/tb/dut/rxp_7} [find signals /tb/dut/rxp_7]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_7}

if [regexp {/tb/dut/rxp_8} [find signals /tb/dut/rxp_8]]                        {add wave -noupdate -divider {  PMA SERIAL RX 8}}
if [regexp {/tb/dut/rxp_8} [find signals /tb/dut/rxp_8]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_8}

if [regexp {/tb/dut/rxp_9]} [find signals /tb/dut/rxp_9]]                        {add wave -noupdate -divider {  PMA SERIAL RX 9}}
if [regexp {/tb/dut/rxp_9]} [find signals /tb/dut/rxp_9]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_9}

if [regexp {/tb/dut/rxp_10} [find signals /tb/dut/rxp_10]]                        {add wave -noupdate -divider {  PMA SERIAL RX 10}}
if [regexp {/tb/dut/rxp_10} [find signals /tb/dut/rxp_10]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_10}

if [regexp {/tb/dut/rxp_11} [find signals /tb/dut/rxp_11]]                        {add wave -noupdate -divider {  PMA SERIAL RX 11}}
if [regexp {/tb/dut/rxp_11} [find signals /tb/dut/rxp_11]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_11}

if [regexp {/tb/dut/rxp_12} [find signals /tb/dut/rxp_12]]                        {add wave -noupdate -divider {  PMA SERIAL RX 12}}
if [regexp {/tb/dut/rxp_12} [find signals /tb/dut/rxp_12]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_12}

if [regexp {/tb/dut/rxp_13} [find signals /tb/dut/rxp_13]]                        {add wave -noupdate -divider {  PMA SERIAL RX 13}}
if [regexp {/tb/dut/rxp_13} [find signals /tb/dut/rxp_13]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_13}

if [regexp {/tb/dut/rxp_14} [find signals /tb/dut/rxp_14]]                        {add wave -noupdate -divider {  PMA SERIAL RX 14}}
if [regexp {/tb/dut/rxp_14} [find signals /tb/dut/rxp_14]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_14}

if [regexp {/tb/dut/rxp_15} [find signals /tb/dut/rxp_15]]                        {add wave -noupdate -divider {  PMA SERIAL RX 15}}
if [regexp {/tb/dut/rxp_15} [find signals /tb/dut/rxp_15]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_15}

if [regexp {/tb/dut/rxp_16} [find signals /tb/dut/rxp_16]]                        {add wave -noupdate -divider {  PMA SERIAL RX 16}}
if [regexp {/tb/dut/rxp_16} [find signals /tb/dut/rxp_16]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_16}

if [regexp {/tb/dut/rxp_17} [find signals /tb/dut/rxp_17]]                        {add wave -noupdate -divider {  PMA SERIAL RX 17}}
if [regexp {/tb/dut/rxp_17} [find signals /tb/dut/rxp_17]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_17}

if [regexp {/tb/dut/rxp_18} [find signals /tb/dut/rxp_18]]                        {add wave -noupdate -divider {  PMA SERIAL RX 18}}
if [regexp {/tb/dut/rxp_18} [find signals /tb/dut/rxp_18]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_18}

if [regexp {/tb/dut/rxp_19} [find signals /tb/dut/rxp_19]]                        {add wave -noupdate -divider {  PMA SERIAL RX 19}}
if [regexp {/tb/dut/rxp_19} [find signals /tb/dut/rxp_19]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_19}

if [regexp {/tb/dut/rxp_20} [find signals /tb/dut/rxp_20]]                        {add wave -noupdate -divider {  PMA SERIAL RX 20}}
if [regexp {/tb/dut/rxp_20} [find signals /tb/dut/rxp_20]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_20}

if [regexp {/tb/dut/rxp_21} [find signals /tb/dut/rxp_21]]                        {add wave -noupdate -divider {  PMA SERIAL RX 21}}
if [regexp {/tb/dut/rxp_21} [find signals /tb/dut/rxp_21]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_21}

if [regexp {/tb/dut/rxp_22} [find signals /tb/dut/rxp_22]]                        {add wave -noupdate -divider {  PMA SERIAL RX 22}}
if [regexp {/tb/dut/rxp_22} [find signals /tb/dut/rxp_22]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_22}

if [regexp {/tb/dut/rxp_22} [find signals /tb/dut/rxp_23]]                        {add wave -noupdate -divider {  PMA SERIAL RX 23}}
if [regexp {/tb/dut/rxp_22} [find signals /tb/dut/rxp_23]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rxp_23}


if [regexp {/tb/dut/gm_rx_err} [find signals /tb/dut/gm_rx_err]]            {add wave -noupdate -divider {  GMII RX}}
if [regexp {/tb/dut/gmii_rx_err} [find signals /tb/dut/gmii_rx_err]]        {add wave -noupdate -divider {  GMII RX}}
if [regexp {/tb/dut/rx_clk} [find signals /tb/dut/rx_clk]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk}
if [regexp {/tb/dut/rx_clkena} [find signals /tb/dut/rx_clkena]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clkena}
if [regexp {/tb/dut/gm_rx_err} [find signals /tb/dut/gm_rx_err]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err}
if [regexp {/tb/dut/gm_rx_dv} [find signals /tb/dut/gm_rx_dv]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv}
if [regexp {/tb/dut/gm_rx_d} [find signals /tb/dut/gm_rx_d]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d}
if [regexp {/tb/dut/gmii_rx_err} [find signals /tb/dut/gmii_rx_err]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err}
if [regexp {/tb/dut/gmii_rx_dv} [find signals /tb/dut/gmii_rx_dv]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv}
if [regexp {/tb/dut/gmii_rx_d} [find signals /tb/dut/gmii_rx_d]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d}

if [regexp {/tb/dut/gm_rx_err_0} [find signals /tb/dut/gm_rx_err_0]]            {add wave -noupdate -divider {  GMII RX 0}}
if [regexp {/tb/dut/gmii_rx_err_0} [find signals /tb/dut/gmii_rx_err_0]]        {add wave -noupdate -divider {  GMII RX 0}}
if [regexp {/tb/dut/rx_clk_0} [find signals /tb/dut/rx_clk_0]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_0}
if [regexp {/tb/dut/gm_rx_err_0} [find signals /tb/dut/gm_rx_err_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_0}
if [regexp {/tb/dut/gm_rx_dv_0} [find signals /tb/dut/gm_rx_dv_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_0}
if [regexp {/tb/dut/gm_rx_d_0} [find signals /tb/dut/gm_rx_d_0]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_0}
if [regexp {/tb/dut/gmii_rx_err_0} [find signals /tb/dut/gmii_rx_err_0]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_0}
if [regexp {/tb/dut/gmii_rx_dv_0} [find signals /tb/dut/gmii_rx_dv_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_0}
if [regexp {/tb/dut/gmii_rx_d_0} [find signals /tb/dut/gmii_rx_d_0]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_0}

if [regexp {/tb/dut/gm_rx_err_1} [find signals /tb/dut/gm_rx_err_1]]           {add wave -noupdate -divider {  GMII RX 1}}
if [regexp {/tb/dut/gmii_rx_err_1} [find signals /tb/dut/gmii_rx_err_1]]        {add wave -noupdate -divider {  GMII RX 1}}
if [regexp {/tb/dut/rx_clk_1} [find signals /tb/dut/rx_clk_1]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_1}
if [regexp {/tb/dut/gm_rx_err_1} [find signals /tb/dut/gm_rx_err_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_1}
if [regexp {/tb/dut/gm_rx_dv_1} [find signals /tb/dut/gm_rx_dv_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_1}
if [regexp {/tb/dut/gm_rx_d_1} [find signals /tb/dut/gm_rx_d_1]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_1}
if [regexp {/tb/dut/gmii_rx_err_1} [find signals /tb/dut/gmii_rx_err_1]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_1}
if [regexp {/tb/dut/gmii_rx_dv_1} [find signals /tb/dut/gmii_rx_dv_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_1}
if [regexp {/tb/dut/gmii_rx_d_1} [find signals /tb/dut/gmii_rx_d_1]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_1}

if [regexp {/tb/dut/gm_rx_err_2} [find signals /tb/dut/gm_rx_err_2]]            {add wave -noupdate -divider {  GMII RX 2}}
if [regexp {/tb/dut/gmii_rx_err_2} [find signals /tb/dut/gmii_rx_err_2]]        {add wave -noupdate -divider {  GMII RX 2}}
if [regexp {/tb/dut/rx_clk_2} [find signals /tb/dut/rx_clk_2]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_2}
if [regexp {/tb/dut/gm_rx_err_2} [find signals /tb/dut/gm_rx_err_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_2}
if [regexp {/tb/dut/gm_rx_dv_2} [find signals /tb/dut/gm_rx_dv_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_2}
if [regexp {/tb/dut/gm_rx_d_2} [find signals /tb/dut/gm_rx_d_2]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_2}
if [regexp {/tb/dut/gmii_rx_err_2} [find signals /tb/dut/gmii_rx_err_2]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_2}
if [regexp {/tb/dut/gmii_rx_dv_2} [find signals /tb/dut/gmii_rx_dv_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_2}
if [regexp {/tb/dut/gmii_rx_d_2} [find signals /tb/dut/gmii_rx_d_2]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_2}

if [regexp {/tb/dut/gm_rx_err_3} [find signals /tb/dut/gm_rx_err_3]]            {add wave -noupdate -divider {  GMII RX 3}}
if [regexp {/tb/dut/gmii_rx_err_3} [find signals /tb/dut/gmii_rx_err_3]]        {add wave -noupdate -divider {  GMII RX 3}}
if [regexp {/tb/dut/rx_clk_3} [find signals /tb/dut/rx_clk_3]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_3}
if [regexp {/tb/dut/gm_rx_err_3} [find signals /tb/dut/gm_rx_err_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_3}
if [regexp {/tb/dut/gm_rx_dv_3} [find signals /tb/dut/gm_rx_dv_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_3}
if [regexp {/tb/dut/gm_rx_d_3} [find signals /tb/dut/gm_rx_d_3]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_3}
if [regexp {/tb/dut/gmii_rx_err_3} [find signals /tb/dut/gmii_rx_err_3]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_3}
if [regexp {/tb/dut/gmii_rx_dv_3} [find signals /tb/dut/gmii_rx_dv_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_3}
if [regexp {/tb/dut/gmii_rx_d_3} [find signals /tb/dut/gmii_rx_d_3]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_3}

if [regexp {/tb/dut/gm_rx_err_4} [find signals /tb/dut/gm_rx_err_4]]            {add wave -noupdate -divider {  GMII RX 4}}
if [regexp {/tb/dut/gmii_rx_err_4} [find signals /tb/dut/gmii_rx_err_4]]        {add wave -noupdate -divider {  GMII RX 4}}
if [regexp {/tb/dut/rx_clk_4} [find signals /tb/dut/rx_clk_4]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_4}
if [regexp {/tb/dut/gm_rx_err_4} [find signals /tb/dut/gm_rx_err_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_4}
if [regexp {/tb/dut/gm_rx_dv_4} [find signals /tb/dut/gm_rx_dv_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_4}
if [regexp {/tb/dut/gm_rx_d_4} [find signals /tb/dut/gm_rx_d_4]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_4}
if [regexp {/tb/dut/gmii_rx_err_4} [find signals /tb/dut/gmii_rx_err_4]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_4}
if [regexp {/tb/dut/gmii_rx_dv_4} [find signals /tb/dut/gmii_rx_dv_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_4}
if [regexp {/tb/dut/gmii_rx_d_4} [find signals /tb/dut/gmii_rx_d_4]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_4}

if [regexp {/tb/dut/gm_rx_err_5} [find signals /tb/dut/gm_rx_err_5]]            {add wave -noupdate -divider {  GMII RX 5}}
if [regexp {/tb/dut/gmii_rx_err_5} [find signals /tb/dut/gmii_rx_err_5]]        {add wave -noupdate -divider {  GMII RX 5}}
if [regexp {/tb/dut/rx_clk_5} [find signals /tb/dut/rx_clk_5]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_5}
if [regexp {/tb/dut/gm_rx_err_5} [find signals /tb/dut/gm_rx_err_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_5}
if [regexp {/tb/dut/gm_rx_dv_5} [find signals /tb/dut/gm_rx_dv_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_5}
if [regexp {/tb/dut/gm_rx_d_5} [find signals /tb/dut/gm_rx_d_5]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_5}
if [regexp {/tb/dut/gmii_rx_err_5} [find signals /tb/dut/gmii_rx_err_5]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_5}
if [regexp {/tb/dut/gmii_rx_dv_5} [find signals /tb/dut/gmii_rx_dv_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_5}
if [regexp {/tb/dut/gmii_rx_d_5} [find signals /tb/dut/gmii_rx_d_5]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_5}

if [regexp {/tb/dut/gm_rx_err_6} [find signals /tb/dut/gm_rx_err_6]]            {add wave -noupdate -divider {  GMII RX 6}}
if [regexp {/tb/dut/gmii_rx_err_6} [find signals /tb/dut/gmii_rx_err_6]]        {add wave -noupdate -divider {  GMII RX 6}}
if [regexp {/tb/dut/rx_clk_6} [find signals /tb/dut/rx_clk_6]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_6}
if [regexp {/tb/dut/gm_rx_err_6} [find signals /tb/dut/gm_rx_err_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_6}
if [regexp {/tb/dut/gm_rx_dv_6} [find signals /tb/dut/gm_rx_dv_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_6}
if [regexp {/tb/dut/gm_rx_d_6} [find signals /tb/dut/gm_rx_d_6]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_6}
if [regexp {/tb/dut/gmii_rx_err_6} [find signals /tb/dut/gmii_rx_err_6]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_6}
if [regexp {/tb/dut/gmii_rx_dv_6} [find signals /tb/dut/gmii_rx_dv_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_6}
if [regexp {/tb/dut/gmii_rx_d_6} [find signals /tb/dut/gmii_rx_d_6]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_6}

if [regexp {/tb/dut/gm_rx_err_7} [find signals /tb/dut/gm_rx_err_7]]            {add wave -noupdate -divider {  GMII RX 7}}
if [regexp {/tb/dut/gmii_rx_err_7} [find signals /tb/dut/gmii_rx_err_7]]        {add wave -noupdate -divider {  GMII RX 7}}
if [regexp {/tb/dut/rx_clk_7} [find signals /tb/dut/rx_clk_7]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_7}
if [regexp {/tb/dut/gm_rx_err_7} [find signals /tb/dut/gm_rx_err_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_7}
if [regexp {/tb/dut/gm_rx_dv_7} [find signals /tb/dut/gm_rx_dv_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_7}
if [regexp {/tb/dut/gm_rx_d_7} [find signals /tb/dut/gm_rx_d_7]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_7}
if [regexp {/tb/dut/gmii_rx_err_7} [find signals /tb/dut/gmii_rx_err_7]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_7}
if [regexp {/tb/dut/gmii_rx_dv_7} [find signals /tb/dut/gmii_rx_dv_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_7}
if [regexp {/tb/dut/gmii_rx_d_7} [find signals /tb/dut/gmii_rx_d_7]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_7}

if [regexp {/tb/dut/gm_rx_err_8} [find signals /tb/dut/gm_rx_err_8]]            {add wave -noupdate -divider {  GMII RX 8}}
if [regexp {/tb/dut/gmii_rx_err_8} [find signals /tb/dut/gmii_rx_err_8]]        {add wave -noupdate -divider {  GMII RX 8}}
if [regexp {/tb/dut/rx_clk_8} [find signals /tb/dut/rx_clk_8]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_8}
if [regexp {/tb/dut/gm_rx_err_8} [find signals /tb/dut/gm_rx_err_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_8}
if [regexp {/tb/dut/gm_rx_dv_8} [find signals /tb/dut/gm_rx_dv_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_8}
if [regexp {/tb/dut/gm_rx_d_8} [find signals /tb/dut/gm_rx_d_8]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_8}
if [regexp {/tb/dut/gmii_rx_err_8} [find signals /tb/dut/gmii_rx_err_8]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_8}
if [regexp {/tb/dut/gmii_rx_dv_8} [find signals /tb/dut/gmii_rx_dv_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_8}
if [regexp {/tb/dut/gmii_rx_d_8} [find signals /tb/dut/gmii_rx_d_8]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_8}

if [regexp {/tb/dut/gm_rx_err_9} [find signals /tb/dut/gm_rx_err_9]]            {add wave -noupdate -divider {  GMII RX 9}}
if [regexp {/tb/dut/gmii_rx_err_9} [find signals /tb/dut/gmii_rx_err_9]]        {add wave -noupdate -divider {  GMII RX 9}}
if [regexp {/tb/dut/rx_clk_9} [find signals /tb/dut/rx_clk_9]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_9}
if [regexp {/tb/dut/gm_rx_err_9} [find signals /tb/dut/gm_rx_err_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_9}
if [regexp {/tb/dut/gm_rx_dv_9} [find signals /tb/dut/gm_rx_dv_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_9}
if [regexp {/tb/dut/gm_rx_d_9} [find signals /tb/dut/gm_rx_d_9]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_9}
if [regexp {/tb/dut/gmii_rx_err_9} [find signals /tb/dut/gmii_rx_err_9]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_9}
if [regexp {/tb/dut/gmii_rx_dv_9} [find signals /tb/dut/gmii_rx_dv_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_9}
if [regexp {/tb/dut/gmii_rx_d_9} [find signals /tb/dut/gmii_rx_d_9]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_9}

if [regexp {/tb/dut/gm_rx_err_10} [find signals /tb/dut/gm_rx_err_10]]            {add wave -noupdate -divider {  GMII RX 10}}
if [regexp {/tb/dut/gmii_rx_err_10} [find signals /tb/dut/gmii_rx_err_10]]        {add wave -noupdate -divider {  GMII RX 10}}
if [regexp {/tb/dut/rx_clk_10} [find signals /tb/dut/rx_clk_10]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_10}
if [regexp {/tb/dut/gm_rx_err_10} [find signals /tb/dut/gm_rx_err_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_10}
if [regexp {/tb/dut/gm_rx_dv_10} [find signals /tb/dut/gm_rx_dv_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_10}
if [regexp {/tb/dut/gm_rx_d_10} [find signals /tb/dut/gm_rx_d_10]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_10}
if [regexp {/tb/dut/gmii_rx_err_10} [find signals /tb/dut/gmii_rx_err_10]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_10}
if [regexp {/tb/dut/gmii_rx_dv_10} [find signals /tb/dut/gmii_rx_dv_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_10}
if [regexp {/tb/dut/gmii_rx_d_10} [find signals /tb/dut/gmii_rx_d_10]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_10}

if [regexp {/tb/dut/gm_rx_err_11} [find signals /tb/dut/gm_rx_err_11]]            {add wave -noupdate -divider {  GMII RX 11}}
if [regexp {/tb/dut/gmii_rx_err_11} [find signals /tb/dut/gmii_rx_err_11]]        {add wave -noupdate -divider {  GMII RX 11}}
if [regexp {/tb/dut/rx_clk_11} [find signals /tb/dut/rx_clk_11]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_11}
if [regexp {/tb/dut/gm_rx_err_11} [find signals /tb/dut/gm_rx_err_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_11}
if [regexp {/tb/dut/gm_rx_dv_11} [find signals /tb/dut/gm_rx_dv_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_11}
if [regexp {/tb/dut/gm_rx_d_11} [find signals /tb/dut/gm_rx_d_11]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_11}
if [regexp {/tb/dut/gmii_rx_err_11} [find signals /tb/dut/gmii_rx_err_11]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_11}
if [regexp {/tb/dut/gmii_rx_dv_11} [find signals /tb/dut/gmii_rx_dv_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_11}
if [regexp {/tb/dut/gmii_rx_d_11} [find signals /tb/dut/gmii_rx_d_11]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_11}


if [regexp {/tb/dut/gm_rx_err_12} [find signals /tb/dut/gm_rx_err_12]]            {add wave -noupdate -divider {  GMII RX 12}}
if [regexp {/tb/dut/gmii_rx_err_12} [find signals /tb/dut/gmii_rx_err_12]]        {add wave -noupdate -divider {  GMII RX 12}}
if [regexp {/tb/dut/rx_clk_12} [find signals /tb/dut/rx_clk_12]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_12}
if [regexp {/tb/dut/gm_rx_err_12} [find signals /tb/dut/gm_rx_err_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_12}
if [regexp {/tb/dut/gm_rx_dv_12} [find signals /tb/dut/gm_rx_dv_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_12}
if [regexp {/tb/dut/gm_rx_d_12} [find signals /tb/dut/gm_rx_d_12]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_12}
if [regexp {/tb/dut/gmii_rx_err_12} [find signals /tb/dut/gmii_rx_err_12]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_12}
if [regexp {/tb/dut/gmii_rx_dv_12} [find signals /tb/dut/gmii_rx_dv_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_12}
if [regexp {/tb/dut/gmii_rx_d_12} [find signals /tb/dut/gmii_rx_d_12]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_12}

if [regexp {/tb/dut/gm_rx_err_13} [find signals /tb/dut/gm_rx_err_13]]            {add wave -noupdate -divider {  GMII RX 13}}
if [regexp {/tb/dut/gmii_rx_err_13} [find signals /tb/dut/gmii_rx_err_13]]        {add wave -noupdate -divider {  GMII RX 13}}
if [regexp {/tb/dut/rx_clk_13} [find signals /tb/dut/rx_clk_13]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_13}
if [regexp {/tb/dut/gm_rx_err_13} [find signals /tb/dut/gm_rx_err_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_13}
if [regexp {/tb/dut/gm_rx_dv_13} [find signals /tb/dut/gm_rx_dv_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_13}
if [regexp {/tb/dut/gm_rx_d_13} [find signals /tb/dut/gm_rx_d_13]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_13}
if [regexp {/tb/dut/gmii_rx_err_13} [find signals /tb/dut/gmii_rx_err_13]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_13}
if [regexp {/tb/dut/gmii_rx_dv_13} [find signals /tb/dut/gmii_rx_dv_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_13}
if [regexp {/tb/dut/gmii_rx_d_13} [find signals /tb/dut/gmii_rx_d_13]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_13}


if [regexp {/tb/dut/gm_rx_err_14} [find signals /tb/dut/gm_rx_err_14]]            {add wave -noupdate -divider {  GMII RX 14}}
if [regexp {/tb/dut/gmii_rx_err_14} [find signals /tb/dut/gmii_rx_err_14]]        {add wave -noupdate -divider {  GMII RX 14}}
if [regexp {/tb/dut/rx_clk_14} [find signals /tb/dut/rx_clk_14]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_14}
if [regexp {/tb/dut/gm_rx_err_14} [find signals /tb/dut/gm_rx_err_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_14}
if [regexp {/tb/dut/gm_rx_dv_14} [find signals /tb/dut/gm_rx_dv_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_14}
if [regexp {/tb/dut/gm_rx_d_14} [find signals /tb/dut/gm_rx_d_14]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_14}
if [regexp {/tb/dut/gmii_rx_err_14} [find signals /tb/dut/gmii_rx_err_14]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_14}
if [regexp {/tb/dut/gmii_rx_dv_14} [find signals /tb/dut/gmii_rx_dv_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_14}
if [regexp {/tb/dut/gmii_rx_d_14} [find signals /tb/dut/gmii_rx_d_14]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_14}


if [regexp {/tb/dut/gm_rx_err_15} [find signals /tb/dut/gm_rx_err_15]]            {add wave -noupdate -divider {  GMII RX 15}}
if [regexp {/tb/dut/gmii_rx_err_15} [find signals /tb/dut/gmii_rx_err_15]]        {add wave -noupdate -divider {  GMII RX 15}}
if [regexp {/tb/dut/rx_clk_15} [find signals /tb/dut/rx_clk_15]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_15}
if [regexp {/tb/dut/gm_rx_err_15} [find signals /tb/dut/gm_rx_err_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_15}
if [regexp {/tb/dut/gm_rx_dv_15} [find signals /tb/dut/gm_rx_dv_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_15}
if [regexp {/tb/dut/gm_rx_d_15} [find signals /tb/dut/gm_rx_d_15]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_15}
if [regexp {/tb/dut/gmii_rx_err_15} [find signals /tb/dut/gmii_rx_err_15]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_15}
if [regexp {/tb/dut/gmii_rx_dv_15} [find signals /tb/dut/gmii_rx_dv_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_15}
if [regexp {/tb/dut/gmii_rx_d_15} [find signals /tb/dut/gmii_rx_d_15]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_15}


if [regexp {/tb/dut/gm_rx_err_16} [find signals /tb/dut/gm_rx_err_16]]            {add wave -noupdate -divider {  GMII RX 16}}
if [regexp {/tb/dut/gmii_rx_err_16} [find signals /tb/dut/gmii_rx_err_16]]        {add wave -noupdate -divider {  GMII RX 16}}
if [regexp {/tb/dut/rx_clk_16} [find signals /tb/dut/rx_clk_16]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_16}
if [regexp {/tb/dut/gm_rx_err_16} [find signals /tb/dut/gm_rx_err_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_16}
if [regexp {/tb/dut/gm_rx_dv_16} [find signals /tb/dut/gm_rx_dv_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_16}
if [regexp {/tb/dut/gm_rx_d_16} [find signals /tb/dut/gm_rx_d_16]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_16}
if [regexp {/tb/dut/gmii_rx_err_16} [find signals /tb/dut/gmii_rx_err_16]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_16}
if [regexp {/tb/dut/gmii_rx_dv_16} [find signals /tb/dut/gmii_rx_dv_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_16}
if [regexp {/tb/dut/gmii_rx_d_16} [find signals /tb/dut/gmii_rx_d_16]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_16}


if [regexp {/tb/dut/gm_rx_err_17} [find signals /tb/dut/gm_rx_err_17]]            {add wave -noupdate -divider {  GMII RX 17}}
if [regexp {/tb/dut/gmii_rx_err_17} [find signals /tb/dut/gmii_rx_err_17]]        {add wave -noupdate -divider {  GMII RX 17}}
if [regexp {/tb/dut/rx_clk_17} [find signals /tb/dut/rx_clk_17]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_17}
if [regexp {/tb/dut/gm_rx_err_17} [find signals /tb/dut/gm_rx_err_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_17}
if [regexp {/tb/dut/gm_rx_dv_17} [find signals /tb/dut/gm_rx_dv_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_17}
if [regexp {/tb/dut/gm_rx_d_17} [find signals /tb/dut/gm_rx_d_17]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_17}
if [regexp {/tb/dut/gmii_rx_err_17} [find signals /tb/dut/gmii_rx_err_17]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_17}
if [regexp {/tb/dut/gmii_rx_dv_17} [find signals /tb/dut/gmii_rx_dv_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_17}
if [regexp {/tb/dut/gmii_rx_d_17} [find signals /tb/dut/gmii_rx_d_17]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_17}


if [regexp {/tb/dut/gm_rx_err_18} [find signals /tb/dut/gm_rx_err_18]]            {add wave -noupdate -divider {  GMII RX 18}}
if [regexp {/tb/dut/gmii_rx_err_18} [find signals /tb/dut/gmii_rx_err_18]]        {add wave -noupdate -divider {  GMII RX 18}}
if [regexp {/tb/dut/rx_clk_18} [find signals /tb/dut/rx_clk_18]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_18}
if [regexp {/tb/dut/gm_rx_err_18} [find signals /tb/dut/gm_rx_err_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_18}
if [regexp {/tb/dut/gm_rx_dv_18} [find signals /tb/dut/gm_rx_dv_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_18}
if [regexp {/tb/dut/gm_rx_d_18} [find signals /tb/dut/gm_rx_d_18]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_18}
if [regexp {/tb/dut/gmii_rx_err_18} [find signals /tb/dut/gmii_rx_err_18]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_18}
if [regexp {/tb/dut/gmii_rx_dv_18} [find signals /tb/dut/gmii_rx_dv_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_18}
if [regexp {/tb/dut/gmii_rx_d_18} [find signals /tb/dut/gmii_rx_d_18]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_18}


if [regexp {/tb/dut/gm_rx_err_19} [find signals /tb/dut/gm_rx_err_19]]            {add wave -noupdate -divider {  GMII RX 19}}
if [regexp {/tb/dut/gmii_rx_err_19} [find signals /tb/dut/gmii_rx_err_19]]        {add wave -noupdate -divider {  GMII RX 19}}
if [regexp {/tb/dut/rx_clk_19} [find signals /tb/dut/rx_clk_19]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_19}
if [regexp {/tb/dut/gm_rx_err_19} [find signals /tb/dut/gm_rx_err_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_19}
if [regexp {/tb/dut/gm_rx_dv_19} [find signals /tb/dut/gm_rx_dv_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_19}
if [regexp {/tb/dut/gm_rx_d_19} [find signals /tb/dut/gm_rx_d_19]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_19}
if [regexp {/tb/dut/gmii_rx_err_19} [find signals /tb/dut/gmii_rx_err_19]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_19}
if [regexp {/tb/dut/gmii_rx_dv_19} [find signals /tb/dut/gmii_rx_dv_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_19}
if [regexp {/tb/dut/gmii_rx_d_19} [find signals /tb/dut/gmii_rx_d_19]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_19}


if [regexp {/tb/dut/gm_rx_err_20} [find signals /tb/dut/gm_rx_err_20]]            {add wave -noupdate -divider {  GMII RX 20}}
if [regexp {/tb/dut/gmii_rx_err_20} [find signals /tb/dut/gmii_rx_err_20]]        {add wave -noupdate -divider {  GMII RX 20}}
if [regexp {/tb/dut/rx_clk_20} [find signals /tb/dut/rx_clk_20]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_20}
if [regexp {/tb/dut/gm_rx_err_20} [find signals /tb/dut/gm_rx_err_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_20}
if [regexp {/tb/dut/gm_rx_dv_20} [find signals /tb/dut/gm_rx_dv_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_20}
if [regexp {/tb/dut/gm_rx_d_20} [find signals /tb/dut/gm_rx_d_20]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_20}
if [regexp {/tb/dut/gmii_rx_err_20} [find signals /tb/dut/gmii_rx_err_20]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_20}
if [regexp {/tb/dut/gmii_rx_dv_20} [find signals /tb/dut/gmii_rx_dv_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_20}
if [regexp {/tb/dut/gmii_rx_d_20} [find signals /tb/dut/gmii_rx_d_20]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_20}


if [regexp {/tb/dut/gm_rx_err_21} [find signals /tb/dut/gm_rx_err_21]]            {add wave -noupdate -divider {  GMII RX 21}}
if [regexp {/tb/dut/gmii_rx_err_21} [find signals /tb/dut/gmii_rx_err_21]]        {add wave -noupdate -divider {  GMII RX 21}}
if [regexp {/tb/dut/rx_clk_21} [find signals /tb/dut/rx_clk_21]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_21}
if [regexp {/tb/dut/gm_rx_err_21} [find signals /tb/dut/gm_rx_err_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_21}
if [regexp {/tb/dut/gm_rx_dv_21} [find signals /tb/dut/gm_rx_dv_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_21}
if [regexp {/tb/dut/gm_rx_d_21} [find signals /tb/dut/gm_rx_d_21]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_21}
if [regexp {/tb/dut/gmii_rx_err_21} [find signals /tb/dut/gmii_rx_err_21]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_21}
if [regexp {/tb/dut/gmii_rx_dv_21} [find signals /tb/dut/gmii_rx_dv_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_21}
if [regexp {/tb/dut/gmii_rx_d_21} [find signals /tb/dut/gmii_rx_d_21]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_21}


if [regexp {/tb/dut/gm_rx_err_22} [find signals /tb/dut/gm_rx_err_22]]            {add wave -noupdate -divider {  GMII RX 22}}
if [regexp {/tb/dut/gmii_rx_err_22} [find signals /tb/dut/gmii_rx_err_22]]        {add wave -noupdate -divider {  GMII RX 22}}
if [regexp {/tb/dut/rx_clk_22} [find signals /tb/dut/rx_clk_22]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_22}
if [regexp {/tb/dut/gm_rx_err_22} [find signals /tb/dut/gm_rx_err_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_22}
if [regexp {/tb/dut/gm_rx_dv_22} [find signals /tb/dut/gm_rx_dv_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_22}
if [regexp {/tb/dut/gm_rx_d_22} [find signals /tb/dut/gm_rx_d_22]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_22}
if [regexp {/tb/dut/gmii_rx_err_22} [find signals /tb/dut/gmii_rx_err_22]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_22}
if [regexp {/tb/dut/gmii_rx_dv_22} [find signals /tb/dut/gmii_rx_dv_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_22}
if [regexp {/tb/dut/gmii_rx_d_22} [find signals /tb/dut/gmii_rx_d_22]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_22}


if [regexp {/tb/dut/gm_rx_err_23} [find signals /tb/dut/gm_rx_err_23]]            {add wave -noupdate -divider {  GMII RX 23}}
if [regexp {/tb/dut/gmii_rx_err_23} [find signals /tb/dut/gmii_rx_err_23]]        {add wave -noupdate -divider {  GMII RX 23}}
if [regexp {/tb/dut/rx_clk_23} [find signals /tb/dut/rx_clk_23]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_23}
if [regexp {/tb/dut/gm_rx_err_23} [find signals /tb/dut/gm_rx_err_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_err_23}
if [regexp {/tb/dut/gm_rx_dv_23} [find signals /tb/dut/gm_rx_dv_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_rx_dv_23}
if [regexp {/tb/dut/gm_rx_d_23} [find signals /tb/dut/gm_rx_d_23]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_rx_d_23}
if [regexp {/tb/dut/gmii_rx_err_23} [find signals /tb/dut/gmii_rx_err_23]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_err_23}
if [regexp {/tb/dut/gmii_rx_dv_23} [find signals /tb/dut/gmii_rx_dv_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_rx_dv_23}
if [regexp {/tb/dut/gmii_rx_d_23} [find signals /tb/dut/gmii_rx_d_23]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_rx_d_23}




if [regexp {/tb/dut/rgmii_in} [find signals /tb/dut/rgmii_in]]              {add wave -noupdate -divider {  RGMII RX}}
if [regexp {/tb/dut/rx_control} [find signals /tb/dut/rx_control]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control}
if [regexp {/tb/dut/rgmii_in} [find signals /tb/dut/rgmii_in]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in}

if [regexp {/tb/dut/rgmii_in_0} [find signals /tb/dut/rgmii_in_0]]              {add wave -noupdate -divider {  RGMII RX 0}}
if [regexp {/tb/dut/rx_control_0} [find signals /tb/dut/rx_control_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_0}
if [regexp {/tb/dut/rgmii_in_0} [find signals /tb/dut/rgmii_in_0]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_0}

if [regexp {/tb/dut/rgmii_in_1} [find signals /tb/dut/rgmii_in_1]]              {add wave -noupdate -divider {  RGMII RX 1}}
if [regexp {/tb/dut/rx_control_1} [find signals /tb/dut/rx_control_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_1}
if [regexp {/tb/dut/rgmii_in_1} [find signals /tb/dut/rgmii_in_1]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_1}

if [regexp {/tb/dut/rgmii_in_2} [find signals /tb/dut/rgmii_in_2]]              {add wave -noupdate -divider {  RGMII RX 2}}
if [regexp {/tb/dut/rx_control_2} [find signals /tb/dut/rx_control_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_2}
if [regexp {/tb/dut/rgmii_in_2} [find signals /tb/dut/rgmii_in_2]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_2}

if [regexp {/tb/dut/rgmii_in_3} [find signals /tb/dut/rgmii_in_3]]              {add wave -noupdate -divider {  RGMII RX 3}}
if [regexp {/tb/dut/rx_control_3} [find signals /tb/dut/rx_control_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_3}
if [regexp {/tb/dut/rgmii_in_3} [find signals /tb/dut/rgmii_in_3]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_3}

if [regexp {/tb/dut/rgmii_in_4} [find signals /tb/dut/rgmii_in_4]]              {add wave -noupdate -divider {  RGMII RX 4}}
if [regexp {/tb/dut/rx_control_4} [find signals /tb/dut/rx_control_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_4}
if [regexp {/tb/dut/rgmii_in_4} [find signals /tb/dut/rgmii_in_4]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_4}

if [regexp {/tb/dut/rgmii_in_5} [find signals /tb/dut/rgmii_in_5]]              {add wave -noupdate -divider {  RGMII RX 5}}
if [regexp {/tb/dut/rx_control_5} [find signals /tb/dut/rx_control_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_5}
if [regexp {/tb/dut/rgmii_in_5} [find signals /tb/dut/rgmii_in_5]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_5}

if [regexp {/tb/dut/rgmii_in_6} [find signals /tb/dut/rgmii_in_6]]              {add wave -noupdate -divider {  RGMII RX 6}}
if [regexp {/tb/dut/rx_control_6} [find signals /tb/dut/rx_control_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_6}
if [regexp {/tb/dut/rgmii_in_6} [find signals /tb/dut/rgmii_in_6]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_6}

if [regexp {/tb/dut/rgmii_in_7} [find signals /tb/dut/rgmii_in_7]]              {add wave -noupdate -divider {  RGMII RX 7}}
if [regexp {/tb/dut/rx_control_7} [find signals /tb/dut/rx_control_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_7}
if [regexp {/tb/dut/rgmii_in_7} [find signals /tb/dut/rgmii_in_7]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_7}

if [regexp {/tb/dut/rgmii_in_8} [find signals /tb/dut/rgmii_in_8]]              {add wave -noupdate -divider {  RGMII RX 8}}
if [regexp {/tb/dut/rx_control_8} [find signals /tb/dut/rx_control_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_8}
if [regexp {/tb/dut/rgmii_in_8} [find signals /tb/dut/rgmii_in_8]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_8}

if [regexp {/tb/dut/rgmii_in_9} [find signals /tb/dut/rgmii_in_9]]              {add wave -noupdate -divider {  RGMII RX 9}}
if [regexp {/tb/dut/rx_control_9} [find signals /tb/dut/rx_control_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_9}
if [regexp {/tb/dut/rgmii_in_9} [find signals /tb/dut/rgmii_in_9]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_9}

if [regexp {/tb/dut/rgmii_in_10} [find signals /tb/dut/rgmii_in_10]]              {add wave -noupdate -divider {  RGMII RX 10}}
if [regexp {/tb/dut/rx_control_10} [find signals /tb/dut/rx_control_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_10}
if [regexp {/tb/dut/rgmii_in_10} [find signals /tb/dut/rgmii_in_10]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_10}

if [regexp {/tb/dut/rgmii_in_11} [find signals /tb/dut/rgmii_in_11]]              {add wave -noupdate -divider {  RGMII RX 11}}
if [regexp {/tb/dut/rx_control_11} [find signals /tb/dut/rx_control_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_11}
if [regexp {/tb/dut/rgmii_in_11} [find signals /tb/dut/rgmii_in_11]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_11}

if [regexp {/tb/dut/rgmii_in_12} [find signals /tb/dut/rgmii_in_12]]              {add wave -noupdate -divider {  RGMII RX 12}}
if [regexp {/tb/dut/rx_control_12} [find signals /tb/dut/rx_control_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_12}
if [regexp {/tb/dut/rgmii_in_12} [find signals /tb/dut/rgmii_in_12]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_12}

if [regexp {/tb/dut/rgmii_in_13} [find signals /tb/dut/rgmii_in_13]]              {add wave -noupdate -divider {  RGMII RX 13}}
if [regexp {/tb/dut/rx_control_13} [find signals /tb/dut/rx_control_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_13}
if [regexp {/tb/dut/rgmii_in_13} [find signals /tb/dut/rgmii_in_13]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_13}

if [regexp {/tb/dut/rgmii_in_14} [find signals /tb/dut/rgmii_in_14]]              {add wave -noupdate -divider {  RGMII RX 14}}
if [regexp {/tb/dut/rx_control_14} [find signals /tb/dut/rx_control_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_14}
if [regexp {/tb/dut/rgmii_in_14} [find signals /tb/dut/rgmii_in_14]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_14}

if [regexp {/tb/dut/rgmii_in_15} [find signals /tb/dut/rgmii_in_15]]              {add wave -noupdate -divider {  RGMII RX 15}}
if [regexp {/tb/dut/rx_control_15} [find signals /tb/dut/rx_control_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_15}
if [regexp {/tb/dut/rgmii_in_15} [find signals /tb/dut/rgmii_in_15]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_15}

if [regexp {/tb/dut/rgmii_in_16} [find signals /tb/dut/rgmii_in_16]]              {add wave -noupdate -divider {  RGMII RX 16}}
if [regexp {/tb/dut/rx_control_16} [find signals /tb/dut/rx_control_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_16}
if [regexp {/tb/dut/rgmii_in_16} [find signals /tb/dut/rgmii_in_16]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_16}

if [regexp {/tb/dut/rgmii_in_17} [find signals /tb/dut/rgmii_in_17]]              {add wave -noupdate -divider {  RGMII RX 17}}
if [regexp {/tb/dut/rx_control_17} [find signals /tb/dut/rx_control_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_17}
if [regexp {/tb/dut/rgmii_in_17} [find signals /tb/dut/rgmii_in_17]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_17}

if [regexp {/tb/dut/rgmii_in_18} [find signals /tb/dut/rgmii_in_18]]              {add wave -noupdate -divider {  RGMII RX 18}}
if [regexp {/tb/dut/rx_control_18} [find signals /tb/dut/rx_control_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_18}
if [regexp {/tb/dut/rgmii_in_18} [find signals /tb/dut/rgmii_in_18]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_18}

if [regexp {/tb/dut/rgmii_in_19} [find signals /tb/dut/rgmii_in_19]]              {add wave -noupdate -divider {  RGMII RX 19}}
if [regexp {/tb/dut/rx_control_19} [find signals /tb/dut/rx_control_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_19}
if [regexp {/tb/dut/rgmii_in_19} [find signals /tb/dut/rgmii_in_19]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_19}

if [regexp {/tb/dut/rgmii_in_20} [find signals /tb/dut/rgmii_in_20]]              {add wave -noupdate -divider {  RGMII RX 20}}
if [regexp {/tb/dut/rx_control_20} [find signals /tb/dut/rx_control_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_20}
if [regexp {/tb/dut/rgmii_in_20} [find signals /tb/dut/rgmii_in_20]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_20}

if [regexp {/tb/dut/rgmii_in_21} [find signals /tb/dut/rgmii_in_21]]              {add wave -noupdate -divider {  RGMII RX 21}}
if [regexp {/tb/dut/rx_control_21} [find signals /tb/dut/rx_control_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_21}
if [regexp {/tb/dut/rgmii_in_21} [find signals /tb/dut/rgmii_in_21]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_21}

if [regexp {/tb/dut/rgmii_in_22} [find signals /tb/dut/rgmii_in_22]]              {add wave -noupdate -divider {  RGMII RX 22}}
if [regexp {/tb/dut/rx_control_22} [find signals /tb/dut/rx_control_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_22}
if [regexp {/tb/dut/rgmii_in_22} [find signals /tb/dut/rgmii_in_22]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_22}

if [regexp {/tb/dut/rgmii_in_23} [find signals /tb/dut/rgmii_in_23]]              {add wave -noupdate -divider {  RGMII RX 23}}
if [regexp {/tb/dut/rx_control_23} [find signals /tb/dut/rx_control_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_control_23}
if [regexp {/tb/dut/rgmii_in_23} [find signals /tb/dut/rgmii_in_23]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_in_23}

if [regexp {/tb/dut/m_rx_d} [find signals /tb/dut/m_rx_d]]                  {add wave -noupdate -divider {  MII RX}}
if [regexp {/tb/dut/mii_rx_d} [find signals /tb/dut/mii_rx_d]]              {add wave -noupdate -divider {  MII RX}}
if [regexp {/tb/dut/rx_clk} [find signals /tb/dut/rx_clk]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk}
if [regexp {/tb/dut/rx_clkena} [find signals /tb/dut/rx_clkena]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clkena}
if [regexp {/tb/dut/m_rx_err} [find signals /tb/dut/m_rx_err]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err}
if [regexp {/tb/dut/m_rx_en} [find signals /tb/dut/m_rx_en]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en}
if [regexp {/tb/dut/m_rx_d} [find signals /tb/dut/m_rx_d]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d}
if [regexp {/tb/dut/m_rx_crs} [find signals /tb/dut/m_rx_crs]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs}
if [regexp {/tb/dut/m_rx_col} [find signals /tb/dut/m_rx_col]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col}
if [regexp {/tb/dut/mii_rx_err} [find signals /tb/dut/mii_rx_err]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err}
if [regexp {/tb/dut/mii_rx_dv} [find signals /tb/dut/mii_rx_dv]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv}
if [regexp {/tb/dut/mii_rx_d} [find signals /tb/dut/mii_rx_d]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d}
if [regexp {/tb/dut/mii_rx_crs} [find signals /tb/dut/mii_rx_crs]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs}
if [regexp {/tb/dut/mii_rx_col} [find signals /tb/dut/mii_rx_col]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col}

if [regexp {/tb/dut/m_rx_d_0} [find signals /tb/dut/m_rx_d_0]]                  {add wave -noupdate -divider {  MII RX 0}}
if [regexp {/tb/dut/mii_rx_d_0} [find signals /tb/dut/mii_rx_d_0]]              {add wave -noupdate -divider {  MII RX 0}}
if [regexp {/tb/dut/rx_clk_0} [find signals /tb/dut/rx_clk_0]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_0}
if [regexp {/tb/dut/m_rx_err_0} [find signals /tb/dut/m_rx_err_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_0}
if [regexp {/tb/dut/m_rx_en_0} [find signals /tb/dut/m_rx_en_0]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_0}
if [regexp {/tb/dut/m_rx_d_0} [find signals /tb/dut/m_rx_d_0]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_0}
if [regexp {/tb/dut/m_rx_crs_0} [find signals /tb/dut/m_rx_crs_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_0}
if [regexp {/tb/dut/m_rx_col_0} [find signals /tb/dut/m_rx_col_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_0}
if [regexp {/tb/dut/mii_rx_err_0} [find signals /tb/dut/mii_rx_err_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_0}
if [regexp {/tb/dut/mii_rx_dv_0} [find signals /tb/dut/mii_rx_dv_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_0}
if [regexp {/tb/dut/mii_rx_d_0} [find signals /tb/dut/mii_rx_d_0]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_0}
if [regexp {/tb/dut/mii_rx_crs_0} [find signals /tb/dut/mii_rx_crs_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_0}
if [regexp {/tb/dut/mii_rx_col_0} [find signals /tb/dut/mii_rx_col_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_0}

if [regexp {/tb/dut/m_rx_d_1} [find signals /tb/dut/m_rx_d_1]]                  {add wave -noupdate -divider {  MII RX 1}}
if [regexp {/tb/dut/mii_rx_d_1} [find signals /tb/dut/mii_rx_d_1]]              {add wave -noupdate -divider {  MII RX 1}}
if [regexp {/tb/dut/rx_clk_1} [find signals /tb/dut/rx_clk_1]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_1}
if [regexp {/tb/dut/m_rx_err_1} [find signals /tb/dut/m_rx_err_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_1}
if [regexp {/tb/dut/m_rx_en_1} [find signals /tb/dut/m_rx_en_1]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_1}
if [regexp {/tb/dut/m_rx_d_1} [find signals /tb/dut/m_rx_d_1]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_1}
if [regexp {/tb/dut/m_rx_crs_1} [find signals /tb/dut/m_rx_crs_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_1}
if [regexp {/tb/dut/m_rx_col_1} [find signals /tb/dut/m_rx_col_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_1}
if [regexp {/tb/dut/mii_rx_err_1} [find signals /tb/dut/mii_rx_err_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_1}
if [regexp {/tb/dut/mii_rx_dv_1} [find signals /tb/dut/mii_rx_dv_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_1}
if [regexp {/tb/dut/mii_rx_d_1} [find signals /tb/dut/mii_rx_d_1]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_1}
if [regexp {/tb/dut/mii_rx_crs_1} [find signals /tb/dut/mii_rx_crs_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_1}
if [regexp {/tb/dut/mii_rx_col_1} [find signals /tb/dut/mii_rx_col_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_1}

if [regexp {/tb/dut/m_rx_d_2} [find signals /tb/dut/m_rx_d_2]]                  {add wave -noupdate -divider {  MII RX 2}}
if [regexp {/tb/dut/mii_rx_d_2} [find signals /tb/dut/mii_rx_d_2]]              {add wave -noupdate -divider {  MII RX 2}}
if [regexp {/tb/dut/rx_clk_2} [find signals /tb/dut/rx_clk_2]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_2}
if [regexp {/tb/dut/m_rx_err_2} [find signals /tb/dut/m_rx_err_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_2}
if [regexp {/tb/dut/m_rx_en_2} [find signals /tb/dut/m_rx_en_2]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_2}
if [regexp {/tb/dut/m_rx_d_2} [find signals /tb/dut/m_rx_d_2]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_2}
if [regexp {/tb/dut/m_rx_crs_2} [find signals /tb/dut/m_rx_crs_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_2}
if [regexp {/tb/dut/m_rx_col_2} [find signals /tb/dut/m_rx_col_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_2}
if [regexp {/tb/dut/mii_rx_err_2} [find signals /tb/dut/mii_rx_err_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_2}
if [regexp {/tb/dut/mii_rx_dv_2} [find signals /tb/dut/mii_rx_dv_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_2}
if [regexp {/tb/dut/mii_rx_d_2} [find signals /tb/dut/mii_rx_d_2]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_2}
if [regexp {/tb/dut/mii_rx_crs_2} [find signals /tb/dut/mii_rx_crs_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_2}
if [regexp {/tb/dut/mii_rx_col_2} [find signals /tb/dut/mii_rx_col_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_2}

if [regexp {/tb/dut/m_rx_d_3} [find signals /tb/dut/m_rx_d_3]]                  {add wave -noupdate -divider {  MII RX 3}}
if [regexp {/tb/dut/mii_rx_d_3} [find signals /tb/dut/mii_rx_d_3]]              {add wave -noupdate -divider {  MII RX 3}}
if [regexp {/tb/dut/rx_clk_3} [find signals /tb/dut/rx_clk_3]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_3}
if [regexp {/tb/dut/m_rx_err_3} [find signals /tb/dut/m_rx_err_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_3}
if [regexp {/tb/dut/m_rx_en_3} [find signals /tb/dut/m_rx_en_3]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_3}
if [regexp {/tb/dut/m_rx_d_3} [find signals /tb/dut/m_rx_d_3]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_3}
if [regexp {/tb/dut/m_rx_crs_3} [find signals /tb/dut/m_rx_crs_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_3}
if [regexp {/tb/dut/m_rx_col_3} [find signals /tb/dut/m_rx_col_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_3}
if [regexp {/tb/dut/mii_rx_err_3} [find signals /tb/dut/mii_rx_err_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_3}
if [regexp {/tb/dut/mii_rx_dv_3} [find signals /tb/dut/mii_rx_dv_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_3}
if [regexp {/tb/dut/mii_rx_d_3} [find signals /tb/dut/mii_rx_d_3]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_3}
if [regexp {/tb/dut/mii_rx_crs_3} [find signals /tb/dut/mii_rx_crs_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_3}
if [regexp {/tb/dut/mii_rx_col_3} [find signals /tb/dut/mii_rx_col_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_3}

if [regexp {/tb/dut/m_rx_d_4} [find signals /tb/dut/m_rx_d_4]]                  {add wave -noupdate -divider {  MII RX 4}}
if [regexp {/tb/dut/mii_rx_d_4} [find signals /tb/dut/mii_rx_d_4]]              {add wave -noupdate -divider {  MII RX 4}}
if [regexp {/tb/dut/rx_clk_4} [find signals /tb/dut/rx_clk_4]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_4}
if [regexp {/tb/dut/m_rx_err_4} [find signals /tb/dut/m_rx_err_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_4}
if [regexp {/tb/dut/m_rx_en_4} [find signals /tb/dut/m_rx_en_4]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_4}
if [regexp {/tb/dut/m_rx_d_4} [find signals /tb/dut/m_rx_d_4]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_4}
if [regexp {/tb/dut/m_rx_crs_4} [find signals /tb/dut/m_rx_crs_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_4}
if [regexp {/tb/dut/m_rx_col_4} [find signals /tb/dut/m_rx_col_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_4}
if [regexp {/tb/dut/mii_rx_err_4} [find signals /tb/dut/mii_rx_err_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_4}
if [regexp {/tb/dut/mii_rx_dv_4} [find signals /tb/dut/mii_rx_dv_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_4}
if [regexp {/tb/dut/mii_rx_d_4} [find signals /tb/dut/mii_rx_d_4]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_4}
if [regexp {/tb/dut/mii_rx_crs_4} [find signals /tb/dut/mii_rx_crs_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_4}
if [regexp {/tb/dut/mii_rx_col_4} [find signals /tb/dut/mii_rx_col_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_4}

if [regexp {/tb/dut/m_rx_d_5} [find signals /tb/dut/m_rx_d_5]]                  {add wave -noupdate -divider {  MII RX 5}}
if [regexp {/tb/dut/mii_rx_d_5} [find signals /tb/dut/mii_rx_d_5]]              {add wave -noupdate -divider {  MII RX 5}}
if [regexp {/tb/dut/rx_clk_5} [find signals /tb/dut/rx_clk_5]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_5}
if [regexp {/tb/dut/m_rx_err_5} [find signals /tb/dut/m_rx_err_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_5}
if [regexp {/tb/dut/m_rx_en_5} [find signals /tb/dut/m_rx_en_5]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_5}
if [regexp {/tb/dut/m_rx_d_5} [find signals /tb/dut/m_rx_d_5]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_5}
if [regexp {/tb/dut/m_rx_crs_5} [find signals /tb/dut/m_rx_crs_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_5}
if [regexp {/tb/dut/m_rx_col_5} [find signals /tb/dut/m_rx_col_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_5}
if [regexp {/tb/dut/mii_rx_err_5} [find signals /tb/dut/mii_rx_err_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_5}
if [regexp {/tb/dut/mii_rx_dv_5} [find signals /tb/dut/mii_rx_dv_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_5}
if [regexp {/tb/dut/mii_rx_d_5} [find signals /tb/dut/mii_rx_d_5]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_5}
if [regexp {/tb/dut/mii_rx_crs_5} [find signals /tb/dut/mii_rx_crs_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_5}
if [regexp {/tb/dut/mii_rx_col_5} [find signals /tb/dut/mii_rx_col_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_5}

if [regexp {/tb/dut/m_rx_d_6} [find signals /tb/dut/m_rx_d_6]]                  {add wave -noupdate -divider {  MII RX 6}}
if [regexp {/tb/dut/mii_rx_d_6} [find signals /tb/dut/mii_rx_d_6]]              {add wave -noupdate -divider {  MII RX 6}}
if [regexp {/tb/dut/rx_clk_6} [find signals /tb/dut/rx_clk_6]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_6}
if [regexp {/tb/dut/m_rx_err_6} [find signals /tb/dut/m_rx_err_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_6}
if [regexp {/tb/dut/m_rx_en_6} [find signals /tb/dut/m_rx_en_6]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_6}
if [regexp {/tb/dut/m_rx_d_6} [find signals /tb/dut/m_rx_d_6]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_6}
if [regexp {/tb/dut/m_rx_crs_6} [find signals /tb/dut/m_rx_crs_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_6}
if [regexp {/tb/dut/m_rx_col_6} [find signals /tb/dut/m_rx_col_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_6}
if [regexp {/tb/dut/mii_rx_err_6} [find signals /tb/dut/mii_rx_err_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_6}
if [regexp {/tb/dut/mii_rx_dv_6} [find signals /tb/dut/mii_rx_dv_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_6}
if [regexp {/tb/dut/mii_rx_d_6} [find signals /tb/dut/mii_rx_d_6]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_6}
if [regexp {/tb/dut/mii_rx_crs_6} [find signals /tb/dut/mii_rx_crs_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_6}
if [regexp {/tb/dut/mii_rx_col_6} [find signals /tb/dut/mii_rx_col_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_6}

if [regexp {/tb/dut/m_rx_d_7} [find signals /tb/dut/m_rx_d_7]]                  {add wave -noupdate -divider {  MII RX 7}}
if [regexp {/tb/dut/mii_rx_d_7} [find signals /tb/dut/mii_rx_d_7]]              {add wave -noupdate -divider {  MII RX 7}}
if [regexp {/tb/dut/rx_clk_7} [find signals /tb/dut/rx_clk_7]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_7}
if [regexp {/tb/dut/m_rx_err_7} [find signals /tb/dut/m_rx_err_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_7}
if [regexp {/tb/dut/m_rx_en_7} [find signals /tb/dut/m_rx_en_7]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_7}
if [regexp {/tb/dut/m_rx_d_7} [find signals /tb/dut/m_rx_d_7]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_7}
if [regexp {/tb/dut/m_rx_crs_7} [find signals /tb/dut/m_rx_crs_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_7}
if [regexp {/tb/dut/m_rx_col_7} [find signals /tb/dut/m_rx_col_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_7}
if [regexp {/tb/dut/mii_rx_err_7} [find signals /tb/dut/mii_rx_err_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_7}
if [regexp {/tb/dut/mii_rx_dv_7} [find signals /tb/dut/mii_rx_dv_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_7}
if [regexp {/tb/dut/mii_rx_d_7} [find signals /tb/dut/mii_rx_d_7]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_7}
if [regexp {/tb/dut/mii_rx_crs_7} [find signals /tb/dut/mii_rx_crs_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_7}
if [regexp {/tb/dut/mii_rx_col_7} [find signals /tb/dut/mii_rx_col_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_7}

if [regexp {/tb/dut/m_rx_d_8} [find signals /tb/dut/m_rx_d_8]]                  {add wave -noupdate -divider {  MII RX 8}}
if [regexp {/tb/dut/mii_rx_d_8} [find signals /tb/dut/mii_rx_d_8]]              {add wave -noupdate -divider {  MII RX 8}}
if [regexp {/tb/dut/rx_clk_8} [find signals /tb/dut/rx_clk_8]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_8}
if [regexp {/tb/dut/m_rx_err_8} [find signals /tb/dut/m_rx_err_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_8}
if [regexp {/tb/dut/m_rx_en_8} [find signals /tb/dut/m_rx_en_8]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_8}
if [regexp {/tb/dut/m_rx_d_8} [find signals /tb/dut/m_rx_d_8]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_8}
if [regexp {/tb/dut/m_rx_crs_8} [find signals /tb/dut/m_rx_crs_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_8}
if [regexp {/tb/dut/m_rx_col_8} [find signals /tb/dut/m_rx_col_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_8}
if [regexp {/tb/dut/mii_rx_err_8} [find signals /tb/dut/mii_rx_err_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_8}
if [regexp {/tb/dut/mii_rx_dv_8} [find signals /tb/dut/mii_rx_dv_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_8}
if [regexp {/tb/dut/mii_rx_d_8} [find signals /tb/dut/mii_rx_d_8]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_8}
if [regexp {/tb/dut/mii_rx_crs_8} [find signals /tb/dut/mii_rx_crs_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_8}
if [regexp {/tb/dut/mii_rx_col_8} [find signals /tb/dut/mii_rx_col_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_8}

if [regexp {/tb/dut/m_rx_d_9} [find signals /tb/dut/m_rx_d_9]]                  {add wave -noupdate -divider {  MII RX 9}}
if [regexp {/tb/dut/mii_rx_d_9} [find signals /tb/dut/mii_rx_d_9]]              {add wave -noupdate -divider {  MII RX 9}}
if [regexp {/tb/dut/rx_clk_9} [find signals /tb/dut/rx_clk_9]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_9}
if [regexp {/tb/dut/m_rx_err_9} [find signals /tb/dut/m_rx_err_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_9}
if [regexp {/tb/dut/m_rx_en_9} [find signals /tb/dut/m_rx_en_9]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_9}
if [regexp {/tb/dut/m_rx_d_9} [find signals /tb/dut/m_rx_d_9]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_9}
if [regexp {/tb/dut/m_rx_crs_9} [find signals /tb/dut/m_rx_crs_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_9}
if [regexp {/tb/dut/m_rx_col_9} [find signals /tb/dut/m_rx_col_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_9}
if [regexp {/tb/dut/mii_rx_err_9} [find signals /tb/dut/mii_rx_err_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_9}
if [regexp {/tb/dut/mii_rx_dv_9} [find signals /tb/dut/mii_rx_dv_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_9}
if [regexp {/tb/dut/mii_rx_d_9} [find signals /tb/dut/mii_rx_d_9]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_9}
if [regexp {/tb/dut/mii_rx_crs_9} [find signals /tb/dut/mii_rx_crs_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_9}
if [regexp {/tb/dut/mii_rx_col_9} [find signals /tb/dut/mii_rx_col_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_9}

if [regexp {/tb/dut/m_rx_d_10} [find signals /tb/dut/m_rx_d_10]]                  {add wave -noupdate -divider {  MII RX 10}}
if [regexp {/tb/dut/mii_rx_d_10} [find signals /tb/dut/mii_rx_d_10]]              {add wave -noupdate -divider {  MII RX 10}}
if [regexp {/tb/dut/rx_clk_10} [find signals /tb/dut/rx_clk_10]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_10}
if [regexp {/tb/dut/m_rx_err_10} [find signals /tb/dut/m_rx_err_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_10}
if [regexp {/tb/dut/m_rx_en_10} [find signals /tb/dut/m_rx_en_10]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_10}
if [regexp {/tb/dut/m_rx_d_10} [find signals /tb/dut/m_rx_d_10]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_10}
if [regexp {/tb/dut/m_rx_crs_10} [find signals /tb/dut/m_rx_crs_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_10}
if [regexp {/tb/dut/m_rx_col_10} [find signals /tb/dut/m_rx_col_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_10}
if [regexp {/tb/dut/mii_rx_err_10} [find signals /tb/dut/mii_rx_err_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_10}
if [regexp {/tb/dut/mii_rx_dv_10} [find signals /tb/dut/mii_rx_dv_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_10}
if [regexp {/tb/dut/mii_rx_d_10} [find signals /tb/dut/mii_rx_d_10]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_10}
if [regexp {/tb/dut/mii_rx_crs_10} [find signals /tb/dut/mii_rx_crs_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_10}
if [regexp {/tb/dut/mii_rx_col_10} [find signals /tb/dut/mii_rx_col_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_10}

if [regexp {/tb/dut/m_rx_d_11} [find signals /tb/dut/m_rx_d_11]]                  {add wave -noupdate -divider {  MII RX 11}}
if [regexp {/tb/dut/mii_rx_d_11} [find signals /tb/dut/mii_rx_d_11]]              {add wave -noupdate -divider {  MII RX 11}}
if [regexp {/tb/dut/rx_clk_11} [find signals /tb/dut/rx_clk_11]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_11}
if [regexp {/tb/dut/m_rx_err_11} [find signals /tb/dut/m_rx_err_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_11}
if [regexp {/tb/dut/m_rx_en_11} [find signals /tb/dut/m_rx_en_11]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_11}
if [regexp {/tb/dut/m_rx_d_11} [find signals /tb/dut/m_rx_d_11]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_11}
if [regexp {/tb/dut/m_rx_crs_11} [find signals /tb/dut/m_rx_crs_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_11}
if [regexp {/tb/dut/m_rx_col_11} [find signals /tb/dut/m_rx_col_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_11}
if [regexp {/tb/dut/mii_rx_err_11} [find signals /tb/dut/mii_rx_err_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_11}
if [regexp {/tb/dut/mii_rx_dv_11} [find signals /tb/dut/mii_rx_dv_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_11}
if [regexp {/tb/dut/mii_rx_d_11} [find signals /tb/dut/mii_rx_d_11]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_11}
if [regexp {/tb/dut/mii_rx_crs_11} [find signals /tb/dut/mii_rx_crs_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_11}
if [regexp {/tb/dut/mii_rx_col_11} [find signals /tb/dut/mii_rx_col_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_11}

if [regexp {/tb/dut/m_rx_d_12} [find signals /tb/dut/m_rx_d_12]]                  {add wave -noupdate -divider {  MII RX 12}}
if [regexp {/tb/dut/mii_rx_d_12} [find signals /tb/dut/mii_rx_d_12]]              {add wave -noupdate -divider {  MII RX 12}}
if [regexp {/tb/dut/rx_clk_12} [find signals /tb/dut/rx_clk_12]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_12}
if [regexp {/tb/dut/m_rx_err_12} [find signals /tb/dut/m_rx_err_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_12}
if [regexp {/tb/dut/m_rx_en_12} [find signals /tb/dut/m_rx_en_12]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_12}
if [regexp {/tb/dut/m_rx_d_12} [find signals /tb/dut/m_rx_d_12]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_12}
if [regexp {/tb/dut/m_rx_crs_12} [find signals /tb/dut/m_rx_crs_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_12}
if [regexp {/tb/dut/m_rx_col_12} [find signals /tb/dut/m_rx_col_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_12}
if [regexp {/tb/dut/mii_rx_err_12} [find signals /tb/dut/mii_rx_err_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_12}
if [regexp {/tb/dut/mii_rx_dv_12} [find signals /tb/dut/mii_rx_dv_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_12}
if [regexp {/tb/dut/mii_rx_d_12} [find signals /tb/dut/mii_rx_d_12]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_12}
if [regexp {/tb/dut/mii_rx_crs_12} [find signals /tb/dut/mii_rx_crs_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_12}
if [regexp {/tb/dut/mii_rx_col_12} [find signals /tb/dut/mii_rx_col_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_12}

if [regexp {/tb/dut/m_rx_d_13} [find signals /tb/dut/m_rx_d_13]]                  {add wave -noupdate -divider {  MII RX 13}}
if [regexp {/tb/dut/mii_rx_d_13} [find signals /tb/dut/mii_rx_d_13]]              {add wave -noupdate -divider {  MII RX 13}}
if [regexp {/tb/dut/rx_clk_13} [find signals /tb/dut/rx_clk_13]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_13}
if [regexp {/tb/dut/m_rx_err_13} [find signals /tb/dut/m_rx_err_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_13}
if [regexp {/tb/dut/m_rx_en_13} [find signals /tb/dut/m_rx_en_13]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_13}
if [regexp {/tb/dut/m_rx_d_13} [find signals /tb/dut/m_rx_d_13]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_13}
if [regexp {/tb/dut/m_rx_crs_13} [find signals /tb/dut/m_rx_crs_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_13}
if [regexp {/tb/dut/m_rx_col_13} [find signals /tb/dut/m_rx_col_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_13}
if [regexp {/tb/dut/mii_rx_err_13} [find signals /tb/dut/mii_rx_err_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_13}
if [regexp {/tb/dut/mii_rx_dv_13} [find signals /tb/dut/mii_rx_dv_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_13}
if [regexp {/tb/dut/mii_rx_d_13} [find signals /tb/dut/mii_rx_d_13]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_13}
if [regexp {/tb/dut/mii_rx_crs_13} [find signals /tb/dut/mii_rx_crs_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_13}
if [regexp {/tb/dut/mii_rx_col_13} [find signals /tb/dut/mii_rx_col_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_13}

if [regexp {/tb/dut/m_rx_d_14} [find signals /tb/dut/m_rx_d_14]]                  {add wave -noupdate -divider {  MII RX 14}}
if [regexp {/tb/dut/mii_rx_d_14} [find signals /tb/dut/mii_rx_d_14]]              {add wave -noupdate -divider {  MII RX 14}}
if [regexp {/tb/dut/rx_clk_14} [find signals /tb/dut/rx_clk_14]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_14}
if [regexp {/tb/dut/m_rx_err_14} [find signals /tb/dut/m_rx_err_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_14}
if [regexp {/tb/dut/m_rx_en_14} [find signals /tb/dut/m_rx_en_14]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_14}
if [regexp {/tb/dut/m_rx_d_14} [find signals /tb/dut/m_rx_d_14]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_14}
if [regexp {/tb/dut/m_rx_crs_14} [find signals /tb/dut/m_rx_crs_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_14}
if [regexp {/tb/dut/m_rx_col_14} [find signals /tb/dut/m_rx_col_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_14}
if [regexp {/tb/dut/mii_rx_err_14} [find signals /tb/dut/mii_rx_err_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_14}
if [regexp {/tb/dut/mii_rx_dv_14} [find signals /tb/dut/mii_rx_dv_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_14}
if [regexp {/tb/dut/mii_rx_d_14} [find signals /tb/dut/mii_rx_d_14]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_14}
if [regexp {/tb/dut/mii_rx_crs_14} [find signals /tb/dut/mii_rx_crs_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_14}
if [regexp {/tb/dut/mii_rx_col_14} [find signals /tb/dut/mii_rx_col_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_14}

if [regexp {/tb/dut/m_rx_d_15} [find signals /tb/dut/m_rx_d_15]]                  {add wave -noupdate -divider {  MII RX 15}}
if [regexp {/tb/dut/mii_rx_d_15} [find signals /tb/dut/mii_rx_d_15]]              {add wave -noupdate -divider {  MII RX 15}}
if [regexp {/tb/dut/rx_clk_15} [find signals /tb/dut/rx_clk_15]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_15}
if [regexp {/tb/dut/m_rx_err_15} [find signals /tb/dut/m_rx_err_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_15}
if [regexp {/tb/dut/m_rx_en_15} [find signals /tb/dut/m_rx_en_15]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_15}
if [regexp {/tb/dut/m_rx_d_15} [find signals /tb/dut/m_rx_d_15]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_15}
if [regexp {/tb/dut/m_rx_crs_15} [find signals /tb/dut/m_rx_crs_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_15}
if [regexp {/tb/dut/m_rx_col_15} [find signals /tb/dut/m_rx_col_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_15}
if [regexp {/tb/dut/mii_rx_err_15} [find signals /tb/dut/mii_rx_err_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_15}
if [regexp {/tb/dut/mii_rx_dv_15} [find signals /tb/dut/mii_rx_dv_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_15}
if [regexp {/tb/dut/mii_rx_d_15} [find signals /tb/dut/mii_rx_d_15]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_15}
if [regexp {/tb/dut/mii_rx_crs_15} [find signals /tb/dut/mii_rx_crs_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_15}
if [regexp {/tb/dut/mii_rx_col_15} [find signals /tb/dut/mii_rx_col_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_15}

if [regexp {/tb/dut/m_rx_d_16} [find signals /tb/dut/m_rx_d_16]]                  {add wave -noupdate -divider {  MII RX 16}}
if [regexp {/tb/dut/mii_rx_d_16} [find signals /tb/dut/mii_rx_d_16]]              {add wave -noupdate -divider {  MII RX 16}}
if [regexp {/tb/dut/rx_clk_16} [find signals /tb/dut/rx_clk_16]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_16}
if [regexp {/tb/dut/m_rx_err_16} [find signals /tb/dut/m_rx_err_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_16}
if [regexp {/tb/dut/m_rx_en_16} [find signals /tb/dut/m_rx_en_16]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_16}
if [regexp {/tb/dut/m_rx_d_16} [find signals /tb/dut/m_rx_d_16]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_16}
if [regexp {/tb/dut/m_rx_crs_16} [find signals /tb/dut/m_rx_crs_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_16}
if [regexp {/tb/dut/m_rx_col_16} [find signals /tb/dut/m_rx_col_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_16}
if [regexp {/tb/dut/mii_rx_err_16} [find signals /tb/dut/mii_rx_err_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_16}
if [regexp {/tb/dut/mii_rx_dv_16} [find signals /tb/dut/mii_rx_dv_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_16}
if [regexp {/tb/dut/mii_rx_d_16} [find signals /tb/dut/mii_rx_d_16]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_16}
if [regexp {/tb/dut/mii_rx_crs_16} [find signals /tb/dut/mii_rx_crs_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_16}
if [regexp {/tb/dut/mii_rx_col_16} [find signals /tb/dut/mii_rx_col_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_16}

if [regexp {/tb/dut/m_rx_d_17} [find signals /tb/dut/m_rx_d_17]]                  {add wave -noupdate -divider {  MII RX 17}}
if [regexp {/tb/dut/mii_rx_d_17} [find signals /tb/dut/mii_rx_d_17]]              {add wave -noupdate -divider {  MII RX 17}}
if [regexp {/tb/dut/rx_clk_17} [find signals /tb/dut/rx_clk_17]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_17}
if [regexp {/tb/dut/m_rx_err_17} [find signals /tb/dut/m_rx_err_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_17}
if [regexp {/tb/dut/m_rx_en_17} [find signals /tb/dut/m_rx_en_17]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_17}
if [regexp {/tb/dut/m_rx_d_17} [find signals /tb/dut/m_rx_d_17]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_17}
if [regexp {/tb/dut/m_rx_crs_17} [find signals /tb/dut/m_rx_crs_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_17}
if [regexp {/tb/dut/m_rx_col_17} [find signals /tb/dut/m_rx_col_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_17}
if [regexp {/tb/dut/mii_rx_err_17} [find signals /tb/dut/mii_rx_err_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_17}
if [regexp {/tb/dut/mii_rx_dv_17} [find signals /tb/dut/mii_rx_dv_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_17}
if [regexp {/tb/dut/mii_rx_d_17} [find signals /tb/dut/mii_rx_d_17]]             {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_17}
if [regexp {/tb/dut/mii_rx_crs_17} [find signals /tb/dut/mii_rx_crs_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_17}
if [regexp {/tb/dut/mii_rx_col_17} [find signals /tb/dut/mii_rx_col_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_17}

if [regexp {/tb/dut/m_rx_d_18} [find signals /tb/dut/m_rx_d_18]]                  {add wave -noupdate -divider {  MII RX 18}}
if [regexp {/tb/dut/mii_rx_d_18} [find signals /tb/dut/mii_rx_d_18]]              {add wave -noupdate -divider {  MII RX 18}}
if [regexp {/tb/dut/rx_clk_18} [find signals /tb/dut/rx_clk_18]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_18}
if [regexp {/tb/dut/m_rx_err_18} [find signals /tb/dut/m_rx_err_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_18}
if [regexp {/tb/dut/m_rx_en_18} [find signals /tb/dut/m_rx_en_18]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_18}
if [regexp {/tb/dut/m_rx_d_18} [find signals /tb/dut/m_rx_d_18]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_18}
if [regexp {/tb/dut/m_rx_crs_18} [find signals /tb/dut/m_rx_crs_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_18}
if [regexp {/tb/dut/m_rx_col_18} [find signals /tb/dut/m_rx_col_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_18}
if [regexp {/tb/dut/mii_rx_err_18} [find signals /tb/dut/mii_rx_err_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_18}
if [regexp {/tb/dut/mii_rx_dv_18} [find signals /tb/dut/mii_rx_dv_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_18}
if [regexp {/tb/dut/mii_rx_d_18} [find signals /tb/dut/mii_rx_d_18]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_18}
if [regexp {/tb/dut/mii_rx_crs_18} [find signals /tb/dut/mii_rx_crs_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_18}
if [regexp {/tb/dut/mii_rx_col_18} [find signals /tb/dut/mii_rx_col_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_18}

if [regexp {/tb/dut/m_rx_d_19} [find signals /tb/dut/m_rx_d_19]]                  {add wave -noupdate -divider {  MII RX 19}}
if [regexp {/tb/dut/mii_rx_d_19} [find signals /tb/dut/mii_rx_d_19]]              {add wave -noupdate -divider {  MII RX 19}}
if [regexp {/tb/dut/rx_clk_19} [find signals /tb/dut/rx_clk_19]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_19}
if [regexp {/tb/dut/m_rx_err_19} [find signals /tb/dut/m_rx_err_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_19}
if [regexp {/tb/dut/m_rx_en_19} [find signals /tb/dut/m_rx_en_19]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_19}
if [regexp {/tb/dut/m_rx_d_19} [find signals /tb/dut/m_rx_d_19]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_19}
if [regexp {/tb/dut/m_rx_crs_19} [find signals /tb/dut/m_rx_crs_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_19}
if [regexp {/tb/dut/m_rx_col_19} [find signals /tb/dut/m_rx_col_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_19}
if [regexp {/tb/dut/mii_rx_err_19} [find signals /tb/dut/mii_rx_err_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_19}
if [regexp {/tb/dut/mii_rx_dv_19} [find signals /tb/dut/mii_rx_dv_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_19}
if [regexp {/tb/dut/mii_rx_d_19} [find signals /tb/dut/mii_rx_d_19]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_19}
if [regexp {/tb/dut/mii_rx_crs_19} [find signals /tb/dut/mii_rx_crs_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_19}
if [regexp {/tb/dut/mii_rx_col_19} [find signals /tb/dut/mii_rx_col_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_19}

if [regexp {/tb/dut/m_rx_d_20} [find signals /tb/dut/m_rx_d_20]]                  {add wave -noupdate -divider {  MII RX 20}}
if [regexp {/tb/dut/mii_rx_d_20} [find signals /tb/dut/mii_rx_d_20]]              {add wave -noupdate -divider {  MII RX 20}}
if [regexp {/tb/dut/rx_clk_20} [find signals /tb/dut/rx_clk_20]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_20}
if [regexp {/tb/dut/m_rx_err_20} [find signals /tb/dut/m_rx_err_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_20}
if [regexp {/tb/dut/m_rx_en_20} [find signals /tb/dut/m_rx_en_20]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_20}
if [regexp {/tb/dut/m_rx_d_20} [find signals /tb/dut/m_rx_d_20]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_20}
if [regexp {/tb/dut/m_rx_crs_20} [find signals /tb/dut/m_rx_crs_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_20}
if [regexp {/tb/dut/m_rx_col_20} [find signals /tb/dut/m_rx_col_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_20}
if [regexp {/tb/dut/mii_rx_err_20} [find signals /tb/dut/mii_rx_err_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_20}
if [regexp {/tb/dut/mii_rx_dv_20} [find signals /tb/dut/mii_rx_dv_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_20}
if [regexp {/tb/dut/mii_rx_d_20} [find signals /tb/dut/mii_rx_d_20]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_20}
if [regexp {/tb/dut/mii_rx_crs_20} [find signals /tb/dut/mii_rx_crs_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_20}
if [regexp {/tb/dut/mii_rx_col_20} [find signals /tb/dut/mii_rx_col_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_20}

if [regexp {/tb/dut/m_rx_d_21} [find signals /tb/dut/m_rx_d_21]]                  {add wave -noupdate -divider {  MII RX 21}}
if [regexp {/tb/dut/mii_rx_d_21} [find signals /tb/dut/mii_rx_d_21]]              {add wave -noupdate -divider {  MII RX 21}}
if [regexp {/tb/dut/rx_clk_21} [find signals /tb/dut/rx_clk_21]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_21}
if [regexp {/tb/dut/m_rx_err_21} [find signals /tb/dut/m_rx_err_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_21}
if [regexp {/tb/dut/m_rx_en_21} [find signals /tb/dut/m_rx_en_21]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_21}
if [regexp {/tb/dut/m_rx_d_21} [find signals /tb/dut/m_rx_d_21]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_21}
if [regexp {/tb/dut/m_rx_crs_21} [find signals /tb/dut/m_rx_crs_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_21}
if [regexp {/tb/dut/m_rx_col_21} [find signals /tb/dut/m_rx_col_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_21}
if [regexp {/tb/dut/mii_rx_err_21} [find signals /tb/dut/mii_rx_err_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_21}
if [regexp {/tb/dut/mii_rx_dv_21} [find signals /tb/dut/mii_rx_dv_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_21}
if [regexp {/tb/dut/mii_rx_d_21} [find signals /tb/dut/mii_rx_d_21]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_21}
if [regexp {/tb/dut/mii_rx_crs_21} [find signals /tb/dut/mii_rx_crs_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_21}
if [regexp {/tb/dut/mii_rx_col_21} [find signals /tb/dut/mii_rx_col_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_21}

if [regexp {/tb/dut/m_rx_d_22} [find signals /tb/dut/m_rx_d_22]]                  {add wave -noupdate -divider {  MII RX 22}}
if [regexp {/tb/dut/mii_rx_d_22} [find signals /tb/dut/mii_rx_d_22]]              {add wave -noupdate -divider {  MII RX 22}}
if [regexp {/tb/dut/rx_clk_22} [find signals /tb/dut/rx_clk_22]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_22}
if [regexp {/tb/dut/m_rx_err_22} [find signals /tb/dut/m_rx_err_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_22}
if [regexp {/tb/dut/m_rx_en_22} [find signals /tb/dut/m_rx_en_22]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_22}
if [regexp {/tb/dut/m_rx_d_22} [find signals /tb/dut/m_rx_d_22]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_22}
if [regexp {/tb/dut/m_rx_crs_22} [find signals /tb/dut/m_rx_crs_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_22}
if [regexp {/tb/dut/m_rx_col_22} [find signals /tb/dut/m_rx_col_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_22}
if [regexp {/tb/dut/mii_rx_err_22} [find signals /tb/dut/mii_rx_err_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_22}
if [regexp {/tb/dut/mii_rx_dv_22} [find signals /tb/dut/mii_rx_dv_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_22}
if [regexp {/tb/dut/mii_rx_d_22} [find signals /tb/dut/mii_rx_d_22]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_22}
if [regexp {/tb/dut/mii_rx_crs_22} [find signals /tb/dut/mii_rx_crs_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_22}
if [regexp {/tb/dut/mii_rx_col_22} [find signals /tb/dut/mii_rx_col_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_22}

if [regexp {/tb/dut/m_rx_d_23} [find signals /tb/dut/m_rx_d_23]]                  {add wave -noupdate -divider {  MII RX 23}}
if [regexp {/tb/dut/mii_rx_d_23} [find signals /tb/dut/mii_rx_d_23]]              {add wave -noupdate -divider {  MII RX 23}}
if [regexp {/tb/dut/rx_clk_23} [find signals /tb/dut/rx_clk_23]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_clk_23}
if [regexp {/tb/dut/m_rx_err_23} [find signals /tb/dut/m_rx_err_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_err_23}
if [regexp {/tb/dut/m_rx_en_23} [find signals /tb/dut/m_rx_en_23]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_en_23}
if [regexp {/tb/dut/m_rx_d_23} [find signals /tb/dut/m_rx_d_23]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_rx_d_23}
if [regexp {/tb/dut/m_rx_crs_23} [find signals /tb/dut/m_rx_crs_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_crs_23}
if [regexp {/tb/dut/m_rx_col_23} [find signals /tb/dut/m_rx_col_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_rx_col_23}
if [regexp {/tb/dut/mii_rx_err_23} [find signals /tb/dut/mii_rx_err_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_err_23}
if [regexp {/tb/dut/mii_rx_dv_23} [find signals /tb/dut/mii_rx_dv_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_dv_23}
if [regexp {/tb/dut/mii_rx_d_23} [find signals /tb/dut/mii_rx_d_23]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_rx_d_23}
if [regexp {/tb/dut/mii_rx_crs_23} [find signals /tb/dut/mii_rx_crs_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_crs_23}
if [regexp {/tb/dut/mii_rx_col_23} [find signals /tb/dut/mii_rx_col_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_rx_col_23}


if [regexp {/tb/dut/ff_rx_data} [find signals /tb/dut/ff_rx_data]]          {add wave -noupdate -divider {  FIFO RX}}
if [regexp {/tb/dut/ff_rx_clk} [find signals /tb/dut/ff_rx_clk]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_rx_clk}
if [regexp {/tb/dut/ff_rx_data} [find signals /tb/dut/ff_rx_data]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/ff_rx_data}
if [regexp {/tb/dut/ff_rx_sop} [find signals /tb/dut/ff_rx_sop]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_rx_sop}
if [regexp {/tb/dut/ff_rx_eop} [find signals /tb/dut/ff_rx_eop]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_rx_eop}
if [regexp {/tb/dut/ff_rx_rdy} [find signals /tb/dut/ff_rx_rdy]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_rx_rdy}
if [regexp {/tb/dut/ff_rx_dval} [find signals /tb/dut/ff_rx_dval]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_rx_dval}
if [regexp {/tb/dut/ff_rx_dsav} [find signals /tb/dut/ff_rx_dsav]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_rx_dsav}
if [regexp {/tb/dut/rx_frm_type} [find signals  /tb/dut/rx_frm_type]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rx_frm_type}
if [regexp {/tb/dut/rx_err_stat} [find signals /tb/dut/rx_err_stat]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rx_err_stat}
if [regexp {/tb/dut/rx_err} [find signals /tb/dut/rx_err]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rx_err}
if [regexp {/tb/dut/ff_rx_mod} [find signals /tb/dut/ff_rx_mod]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/ff_rx_mod}
if [regexp {/tb/dut/ff_rx_a_full} [find signals /tb/dut/ff_rx_a_full]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_rx_a_full}
if [regexp {/tb/dut/ff_rx_a_empty} [find signals /tb/dut/ff_rx_a_empty]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_rx_a_empty}

if [regexp {/tb/dut/rx_afull_clk} [find signals /tb/dut/rx_afull_clk]]                  {add wave -noupdate -divider {  EXTERNAL AVALON ST RX FIFO STATUS}}
if [regexp {/tb/dut/rx_afull_clk} [find signals /tb/dut/rx_afull_clk]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rx_afull_clk}
if [regexp {/tb/dut/rx_afull_channel} [find signals /tb/dut/rx_afull_channel]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rx_afull_channel}
if [regexp {/tb/dut/rx_afull_data} [find signals /tb/dut/rx_afull_data]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_afull_data}
if [regexp {/tb/dut/rx_afull_valid]} [find signals /tb/dut/rx_afull_valid]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/rx_afull_valid]}

if [regexp {/tb/dut/data_rx_data_0} [find signals /tb/dut/data_rx_data_0]]          {add wave -noupdate -divider {  AVALON ST RX 0}}
if [regexp {/tb/dut/mac_rx_clk_0} [find signals /tb/dut/mac_rx_clk_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_0}
if [regexp {/tb/dut/data_rx_data_0} [find signals /tb/dut/data_rx_data_0]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_0}
if [regexp {/tb/dut/data_rx_sop_0} [find signals /tb/dut/data_rx_sop_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_0}
if [regexp {/tb/dut/data_rx_eop_0} [find signals /tb/dut/data_rx_eop_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_0}
if [regexp {/tb/dut/data_rx_ready_0} [find signals /tb/dut/data_rx_ready_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_0}
if [regexp {/tb/dut/data_rx_error_0} [find signals /tb/dut/data_rx_error_0]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_0}
if [regexp {/tb/dut/data_rx_valid_0} [find signals /tb/dut/data_rx_valid_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_0}
if [regexp {/tb/dut/pkt_class_data_0} [find signals /tb/dut/pkt_class_data_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_0}
if [regexp {/tb/dut/pkt_class_valid_0} [find signals  /tb/dut/pkt_class_valid_0]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_0}

if [regexp {/tb/dut/data_rx_data_1} [find signals /tb/dut/data_rx_data_1]]          {add wave -noupdate -divider {  AVALON ST RX 1}}
if [regexp {/tb/dut/mac_rx_clk_1} [find signals /tb/dut/mac_rx_clk_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_1}
if [regexp {/tb/dut/data_rx_data_1} [find signals /tb/dut/data_rx_data_1]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_1}
if [regexp {/tb/dut/data_rx_sop_1} [find signals /tb/dut/data_rx_sop_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_1}
if [regexp {/tb/dut/data_rx_eop_1} [find signals /tb/dut/data_rx_eop_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_1}
if [regexp {/tb/dut/data_rx_ready_1} [find signals /tb/dut/data_rx_ready_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_1}
if [regexp {/tb/dut/data_rx_error_1} [find signals /tb/dut/data_rx_error_1]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_1}
if [regexp {/tb/dut/data_rx_valid_1} [find signals /tb/dut/data_rx_valid_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_1}
if [regexp {/tb/dut/pkt_class_data_1} [find signals /tb/dut/pkt_class_data_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_1}
if [regexp {/tb/dut/pkt_class_valid_1} [find signals  /tb/dut/pkt_class_valid_1]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_1}

if [regexp {/tb/dut/data_rx_data_2} [find signals /tb/dut/data_rx_data_2]]          {add wave -noupdate -divider {  AVALON ST RX 2}}
if [regexp {/tb/dut/mac_rx_clk_2} [find signals /tb/dut/mac_rx_clk_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_2}
if [regexp {/tb/dut/data_rx_data_2} [find signals /tb/dut/data_rx_data_2]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_2}
if [regexp {/tb/dut/data_rx_sop_2} [find signals /tb/dut/data_rx_sop_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_2}
if [regexp {/tb/dut/data_rx_eop_2} [find signals /tb/dut/data_rx_eop_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_2}
if [regexp {/tb/dut/data_rx_ready_2} [find signals /tb/dut/data_rx_ready_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_2}
if [regexp {/tb/dut/data_rx_error_2} [find signals /tb/dut/data_rx_error_2]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_2}
if [regexp {/tb/dut/data_rx_valid_2} [find signals /tb/dut/data_rx_valid_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_2}
if [regexp {/tb/dut/pkt_class_data_2} [find signals /tb/dut/pkt_class_data_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_2}
if [regexp {/tb/dut/pkt_class_valid_2} [find signals  /tb/dut/pkt_class_valid_2]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_2}

if [regexp {/tb/dut/data_rx_data_3} [find signals /tb/dut/data_rx_data_3]]          {add wave -noupdate -divider {  AVALON ST RX 3}}
if [regexp {/tb/dut/mac_rx_clk_3} [find signals /tb/dut/mac_rx_clk_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_3}
if [regexp {/tb/dut/data_rx_data_3} [find signals /tb/dut/data_rx_data_3]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_3}
if [regexp {/tb/dut/data_rx_sop_3} [find signals /tb/dut/data_rx_sop_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_3}
if [regexp {/tb/dut/data_rx_eop_3} [find signals /tb/dut/data_rx_eop_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_3}
if [regexp {/tb/dut/data_rx_ready_3} [find signals /tb/dut/data_rx_ready_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_3}
if [regexp {/tb/dut/data_rx_error_3} [find signals /tb/dut/data_rx_error_3]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_3}
if [regexp {/tb/dut/data_rx_valid_3} [find signals /tb/dut/data_rx_valid_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_3}
if [regexp {/tb/dut/pkt_class_data_3} [find signals /tb/dut/pkt_class_data_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_3}
if [regexp {/tb/dut/pkt_class_valid_3} [find signals  /tb/dut/pkt_class_valid_3]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_3}

if [regexp {/tb/dut/data_rx_data_4} [find signals /tb/dut/data_rx_data_4]]          {add wave -noupdate -divider {  AVALON ST RX 4}}
if [regexp {/tb/dut/mac_rx_clk_4} [find signals /tb/dut/mac_rx_clk_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_4}
if [regexp {/tb/dut/data_rx_data_4} [find signals /tb/dut/data_rx_data_4]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_4}
if [regexp {/tb/dut/data_rx_sop_4} [find signals /tb/dut/data_rx_sop_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_4}
if [regexp {/tb/dut/data_rx_eop_4} [find signals /tb/dut/data_rx_eop_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_4}
if [regexp {/tb/dut/data_rx_ready_4} [find signals /tb/dut/data_rx_ready_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_4}
if [regexp {/tb/dut/data_rx_error_4} [find signals /tb/dut/data_rx_error_4]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_4}
if [regexp {/tb/dut/data_rx_valid_4} [find signals /tb/dut/data_rx_valid_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_4}
if [regexp {/tb/dut/pkt_class_data_4} [find signals /tb/dut/pkt_class_data_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_4}
if [regexp {/tb/dut/pkt_class_valid_4} [find signals  /tb/dut/pkt_class_valid_4]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_4}

if [regexp {/tb/dut/data_rx_data_5} [find signals /tb/dut/data_rx_data_5]]          {add wave -noupdate -divider {  AVALON ST RX 5}}
if [regexp {/tb/dut/mac_rx_clk_5} [find signals /tb/dut/mac_rx_clk_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_5}
if [regexp {/tb/dut/data_rx_data_5} [find signals /tb/dut/data_rx_data_5]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_5}
if [regexp {/tb/dut/data_rx_sop_5} [find signals /tb/dut/data_rx_sop_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_5}
if [regexp {/tb/dut/data_rx_eop_5} [find signals /tb/dut/data_rx_eop_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_5}
if [regexp {/tb/dut/data_rx_ready_5} [find signals /tb/dut/data_rx_ready_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_5}
if [regexp {/tb/dut/data_rx_error_5} [find signals /tb/dut/data_rx_error_5]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_5}
if [regexp {/tb/dut/data_rx_valid_5} [find signals /tb/dut/data_rx_valid_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_5}
if [regexp {/tb/dut/pkt_class_data_5} [find signals /tb/dut/pkt_class_data_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_5}
if [regexp {/tb/dut/pkt_class_valid_5} [find signals  /tb/dut/pkt_class_valid_5]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_5}

if [regexp {/tb/dut/data_rx_data_6} [find signals /tb/dut/data_rx_data_6]]          {add wave -noupdate -divider {  AVALON ST RX 6}}
if [regexp {/tb/dut/mac_rx_clk_6} [find signals /tb/dut/mac_rx_clk_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_6}
if [regexp {/tb/dut/data_rx_data_6} [find signals /tb/dut/data_rx_data_6]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_6}
if [regexp {/tb/dut/data_rx_sop_6} [find signals /tb/dut/data_rx_sop_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_6}
if [regexp {/tb/dut/data_rx_eop_6} [find signals /tb/dut/data_rx_eop_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_6}
if [regexp {/tb/dut/data_rx_ready_6} [find signals /tb/dut/data_rx_ready_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_6}
if [regexp {/tb/dut/data_rx_error_6} [find signals /tb/dut/data_rx_error_6]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_6}
if [regexp {/tb/dut/data_rx_valid_6} [find signals /tb/dut/data_rx_valid_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_6}
if [regexp {/tb/dut/pkt_class_data_6} [find signals /tb/dut/pkt_class_data_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_6}
if [regexp {/tb/dut/pkt_class_valid_6} [find signals  /tb/dut/pkt_class_valid_6]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_6}

if [regexp {/tb/dut/data_rx_data_7} [find signals /tb/dut/data_rx_data_7]]          {add wave -noupdate -divider {  AVALON ST RX 7}}
if [regexp {/tb/dut/mac_rx_clk_7} [find signals /tb/dut/mac_rx_clk_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_7}
if [regexp {/tb/dut/data_rx_data_7} [find signals /tb/dut/data_rx_data_7]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_7}
if [regexp {/tb/dut/data_rx_sop_7} [find signals /tb/dut/data_rx_sop_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_7}
if [regexp {/tb/dut/data_rx_eop_7} [find signals /tb/dut/data_rx_eop_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_7}
if [regexp {/tb/dut/data_rx_ready_7} [find signals /tb/dut/data_rx_ready_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_7}
if [regexp {/tb/dut/data_rx_error_7} [find signals /tb/dut/data_rx_error_7]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_7}
if [regexp {/tb/dut/data_rx_valid_7} [find signals /tb/dut/data_rx_valid_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_7}
if [regexp {/tb/dut/pkt_class_data_7} [find signals /tb/dut/pkt_class_data_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_7}
if [regexp {/tb/dut/pkt_class_valid_7} [find signals  /tb/dut/pkt_class_valid_7]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_7}

if [regexp {/tb/dut/data_rx_data_8} [find signals /tb/dut/data_rx_data_8]]          {add wave -noupdate -divider {  AVALON ST RX 8}}
if [regexp {/tb/dut/mac_rx_clk_8} [find signals /tb/dut/mac_rx_clk_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_8}
if [regexp {/tb/dut/data_rx_data_8} [find signals /tb/dut/data_rx_data_8]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_8}
if [regexp {/tb/dut/data_rx_sop_8} [find signals /tb/dut/data_rx_sop_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_8}
if [regexp {/tb/dut/data_rx_eop_8} [find signals /tb/dut/data_rx_eop_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_8}
if [regexp {/tb/dut/data_rx_ready_8} [find signals /tb/dut/data_rx_ready_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_8}
if [regexp {/tb/dut/data_rx_error_8} [find signals /tb/dut/data_rx_error_8]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_8}
if [regexp {/tb/dut/data_rx_valid_8} [find signals /tb/dut/data_rx_valid_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_8}
if [regexp {/tb/dut/pkt_class_data_8} [find signals /tb/dut/pkt_class_data_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_8}
if [regexp {/tb/dut/pkt_class_valid_8} [find signals  /tb/dut/pkt_class_valid_8]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_8}

if [regexp {/tb/dut/data_rx_data_9} [find signals /tb/dut/data_rx_data_9]]          {add wave -noupdate -divider {  AVALON ST RX 9}}
if [regexp {/tb/dut/mac_rx_clk_9} [find signals /tb/dut/mac_rx_clk_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_9}
if [regexp {/tb/dut/data_rx_data_9} [find signals /tb/dut/data_rx_data_9]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_9}
if [regexp {/tb/dut/data_rx_sop_9} [find signals /tb/dut/data_rx_sop_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_9}
if [regexp {/tb/dut/data_rx_eop_9} [find signals /tb/dut/data_rx_eop_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_9}
if [regexp {/tb/dut/data_rx_ready_9} [find signals /tb/dut/data_rx_ready_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_9}
if [regexp {/tb/dut/data_rx_error_9} [find signals /tb/dut/data_rx_error_9]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_9}
if [regexp {/tb/dut/data_rx_valid_9} [find signals /tb/dut/data_rx_valid_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_9}
if [regexp {/tb/dut/pkt_class_data_9} [find signals /tb/dut/pkt_class_data_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_9}
if [regexp {/tb/dut/pkt_class_valid_9} [find signals  /tb/dut/pkt_class_valid_9]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_9}

if [regexp {/tb/dut/data_rx_data_10} [find signals /tb/dut/data_rx_data_10]]          {add wave -noupdate -divider {  AVALON ST RX 10}}
if [regexp {/tb/dut/mac_rx_clk_10} [find signals /tb/dut/mac_rx_clk_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_10}
if [regexp {/tb/dut/data_rx_data_10} [find signals /tb/dut/data_rx_data_10]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_10}
if [regexp {/tb/dut/data_rx_sop_10} [find signals /tb/dut/data_rx_sop_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_10}
if [regexp {/tb/dut/data_rx_eop_10} [find signals /tb/dut/data_rx_eop_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_10}
if [regexp {/tb/dut/data_rx_ready_10} [find signals /tb/dut/data_rx_ready_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_10}
if [regexp {/tb/dut/data_rx_error_10} [find signals /tb/dut/data_rx_error_10]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_10}
if [regexp {/tb/dut/data_rx_valid_10} [find signals /tb/dut/data_rx_valid_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_10}
if [regexp {/tb/dut/pkt_class_data_10} [find signals /tb/dut/pkt_class_data_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_10}
if [regexp {/tb/dut/pkt_class_valid_10} [find signals  /tb/dut/pkt_class_valid_10]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_10}

if [regexp {/tb/dut/data_rx_data_11} [find signals /tb/dut/data_rx_data_11]]          {add wave -noupdate -divider {  AVALON ST RX 11}}
if [regexp {/tb/dut/mac_rx_clk_11} [find signals /tb/dut/mac_rx_clk_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_11}
if [regexp {/tb/dut/data_rx_data_11} [find signals /tb/dut/data_rx_data_11]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_11}
if [regexp {/tb/dut/data_rx_sop_11} [find signals /tb/dut/data_rx_sop_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_11}
if [regexp {/tb/dut/data_rx_eop_11} [find signals /tb/dut/data_rx_eop_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_11}
if [regexp {/tb/dut/data_rx_ready_11} [find signals /tb/dut/data_rx_ready_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_11}
if [regexp {/tb/dut/data_rx_error_11} [find signals /tb/dut/data_rx_error_11]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_11}
if [regexp {/tb/dut/data_rx_valid_11} [find signals /tb/dut/data_rx_valid_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_11}
if [regexp {/tb/dut/pkt_class_data_11} [find signals /tb/dut/pkt_class_data_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_11}
if [regexp {/tb/dut/pkt_class_valid_11} [find signals  /tb/dut/pkt_class_valid_11]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_11}

if [regexp {/tb/dut/data_rx_data_12} [find signals /tb/dut/data_rx_data_12]]          {add wave -noupdate -divider {  AVALON ST RX 12}}
if [regexp {/tb/dut/mac_rx_clk_12} [find signals /tb/dut/mac_rx_clk_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_12}
if [regexp {/tb/dut/data_rx_data_12} [find signals /tb/dut/data_rx_data_12]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_12}
if [regexp {/tb/dut/data_rx_sop_12} [find signals /tb/dut/data_rx_sop_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_12}
if [regexp {/tb/dut/data_rx_eop_12} [find signals /tb/dut/data_rx_eop_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_12}
if [regexp {/tb/dut/data_rx_ready_12} [find signals /tb/dut/data_rx_ready_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_12}
if [regexp {/tb/dut/data_rx_error_12} [find signals /tb/dut/data_rx_error_12]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_12}
if [regexp {/tb/dut/data_rx_valid_12} [find signals /tb/dut/data_rx_valid_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_12}
if [regexp {/tb/dut/pkt_class_data_12} [find signals /tb/dut/pkt_class_data_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_12}
if [regexp {/tb/dut/pkt_class_valid_12} [find signals  /tb/dut/pkt_class_valid_12]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_12}

if [regexp {/tb/dut/data_rx_data_13} [find signals /tb/dut/data_rx_data_13]]          {add wave -noupdate -divider {  AVALON ST RX 13}}
if [regexp {/tb/dut/mac_rx_clk_13} [find signals /tb/dut/mac_rx_clk_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_13}
if [regexp {/tb/dut/data_rx_data_13} [find signals /tb/dut/data_rx_data_13]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_13}
if [regexp {/tb/dut/data_rx_sop_13} [find signals /tb/dut/data_rx_sop_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_13}
if [regexp {/tb/dut/data_rx_eop_13} [find signals /tb/dut/data_rx_eop_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_13}
if [regexp {/tb/dut/data_rx_ready_13} [find signals /tb/dut/data_rx_ready_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_13}
if [regexp {/tb/dut/data_rx_error_13} [find signals /tb/dut/data_rx_error_13]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_13}
if [regexp {/tb/dut/data_rx_valid_13} [find signals /tb/dut/data_rx_valid_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_13}
if [regexp {/tb/dut/pkt_class_data_13} [find signals /tb/dut/pkt_class_data_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_13}
if [regexp {/tb/dut/pkt_class_valid_13} [find signals  /tb/dut/pkt_class_valid_13]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_13}

if [regexp {/tb/dut/data_rx_data_14} [find signals /tb/dut/data_rx_data_14]]          {add wave -noupdate -divider {  AVALON ST RX 14}}
if [regexp {/tb/dut/mac_rx_clk_14} [find signals /tb/dut/mac_rx_clk_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_14}
if [regexp {/tb/dut/data_rx_data_14} [find signals /tb/dut/data_rx_data_14]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_14}
if [regexp {/tb/dut/data_rx_sop_14} [find signals /tb/dut/data_rx_sop_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_14}
if [regexp {/tb/dut/data_rx_eop_14} [find signals /tb/dut/data_rx_eop_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_14}
if [regexp {/tb/dut/data_rx_ready_14} [find signals /tb/dut/data_rx_ready_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_14}
if [regexp {/tb/dut/data_rx_error_14} [find signals /tb/dut/data_rx_error_14]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_14}
if [regexp {/tb/dut/data_rx_valid_14} [find signals /tb/dut/data_rx_valid_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_14}
if [regexp {/tb/dut/pkt_class_data_14} [find signals /tb/dut/pkt_class_data_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_14}
if [regexp {/tb/dut/pkt_class_valid_14} [find signals  /tb/dut/pkt_class_valid_14]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_14}

if [regexp {/tb/dut/data_rx_data_15} [find signals /tb/dut/data_rx_data_15]]          {add wave -noupdate -divider {  AVALON ST RX 15}}
if [regexp {/tb/dut/mac_rx_clk_15} [find signals /tb/dut/mac_rx_clk_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_15}
if [regexp {/tb/dut/data_rx_data_15} [find signals /tb/dut/data_rx_data_15]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_15}
if [regexp {/tb/dut/data_rx_sop_15} [find signals /tb/dut/data_rx_sop_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_15}
if [regexp {/tb/dut/data_rx_eop_15} [find signals /tb/dut/data_rx_eop_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_15}
if [regexp {/tb/dut/data_rx_ready_15} [find signals /tb/dut/data_rx_ready_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_15}
if [regexp {/tb/dut/data_rx_error_15} [find signals /tb/dut/data_rx_error_15]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_15}
if [regexp {/tb/dut/data_rx_valid_15} [find signals /tb/dut/data_rx_valid_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_15}
if [regexp {/tb/dut/pkt_class_data_15} [find signals /tb/dut/pkt_class_data_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_15}
if [regexp {/tb/dut/pkt_class_valid_15} [find signals  /tb/dut/pkt_class_valid_15]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_15}

if [regexp {/tb/dut/data_rx_data_16} [find signals /tb/dut/data_rx_data_16]]          {add wave -noupdate -divider {  AVALON ST RX 16}}
if [regexp {/tb/dut/mac_rx_clk_16} [find signals /tb/dut/mac_rx_clk_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_16}
if [regexp {/tb/dut/data_rx_data_16} [find signals /tb/dut/data_rx_data_16]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_16}
if [regexp {/tb/dut/data_rx_sop_16} [find signals /tb/dut/data_rx_sop_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_16}
if [regexp {/tb/dut/data_rx_eop_16} [find signals /tb/dut/data_rx_eop_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_16}
if [regexp {/tb/dut/data_rx_ready_16} [find signals /tb/dut/data_rx_ready_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_16}
if [regexp {/tb/dut/data_rx_error_16} [find signals /tb/dut/data_rx_error_16]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_16}
if [regexp {/tb/dut/data_rx_valid_16} [find signals /tb/dut/data_rx_valid_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_16}
if [regexp {/tb/dut/pkt_class_data_16} [find signals /tb/dut/pkt_class_data_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_16}
if [regexp {/tb/dut/pkt_class_valid_16} [find signals  /tb/dut/pkt_class_valid_16]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_16}

if [regexp {/tb/dut/data_rx_data_17} [find signals /tb/dut/data_rx_data_17]]          {add wave -noupdate -divider {  AVALON ST RX 17}}
if [regexp {/tb/dut/mac_rx_clk_17} [find signals /tb/dut/mac_rx_clk_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_17}
if [regexp {/tb/dut/data_rx_data_17} [find signals /tb/dut/data_rx_data_17]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_17}
if [regexp {/tb/dut/data_rx_sop_17} [find signals /tb/dut/data_rx_sop_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_17}
if [regexp {/tb/dut/data_rx_eop_17} [find signals /tb/dut/data_rx_eop_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_17}
if [regexp {/tb/dut/data_rx_ready_17} [find signals /tb/dut/data_rx_ready_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_17}
if [regexp {/tb/dut/data_rx_error_17} [find signals /tb/dut/data_rx_error_17]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_17}
if [regexp {/tb/dut/data_rx_valid_17} [find signals /tb/dut/data_rx_valid_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_17}
if [regexp {/tb/dut/pkt_class_data_17} [find signals /tb/dut/pkt_class_data_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_17}
if [regexp {/tb/dut/pkt_class_valid_17} [find signals  /tb/dut/pkt_class_valid_17]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_17}

if [regexp {/tb/dut/data_rx_data_18} [find signals /tb/dut/data_rx_data_18]]          {add wave -noupdate -divider {  AVALON ST RX 18}}
if [regexp {/tb/dut/mac_rx_clk_18} [find signals /tb/dut/mac_rx_clk_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_18}
if [regexp {/tb/dut/data_rx_data_18} [find signals /tb/dut/data_rx_data_18]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_18}
if [regexp {/tb/dut/data_rx_sop_18} [find signals /tb/dut/data_rx_sop_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_18}
if [regexp {/tb/dut/data_rx_eop_18} [find signals /tb/dut/data_rx_eop_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_18}
if [regexp {/tb/dut/data_rx_ready_18} [find signals /tb/dut/data_rx_ready_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_18}
if [regexp {/tb/dut/data_rx_error_18} [find signals /tb/dut/data_rx_error_18]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_18}
if [regexp {/tb/dut/data_rx_valid_18} [find signals /tb/dut/data_rx_valid_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_18}
if [regexp {/tb/dut/pkt_class_data_18} [find signals /tb/dut/pkt_class_data_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_18}
if [regexp {/tb/dut/pkt_class_valid_18} [find signals  /tb/dut/pkt_class_valid_18]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_18}

if [regexp {/tb/dut/data_rx_data_19} [find signals /tb/dut/data_rx_data_19]]          {add wave -noupdate -divider {  AVALON ST RX 19}}
if [regexp {/tb/dut/mac_rx_clk_19} [find signals /tb/dut/mac_rx_clk_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_19}
if [regexp {/tb/dut/data_rx_data_19} [find signals /tb/dut/data_rx_data_19]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_19}
if [regexp {/tb/dut/data_rx_sop_19} [find signals /tb/dut/data_rx_sop_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_19}
if [regexp {/tb/dut/data_rx_eop_19} [find signals /tb/dut/data_rx_eop_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_19}
if [regexp {/tb/dut/data_rx_ready_19} [find signals /tb/dut/data_rx_ready_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_19}
if [regexp {/tb/dut/data_rx_error_19} [find signals /tb/dut/data_rx_error_19]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_19}
if [regexp {/tb/dut/data_rx_valid_19} [find signals /tb/dut/data_rx_valid_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_19}
if [regexp {/tb/dut/pkt_class_data_19} [find signals /tb/dut/pkt_class_data_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_19}
if [regexp {/tb/dut/pkt_class_valid_19} [find signals  /tb/dut/pkt_class_valid_19]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_19}

if [regexp {/tb/dut/data_rx_data_20} [find signals /tb/dut/data_rx_data_20]]          {add wave -noupdate -divider {  AVALON ST RX 20}}
if [regexp {/tb/dut/mac_rx_clk_20} [find signals /tb/dut/mac_rx_clk_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_20}
if [regexp {/tb/dut/data_rx_data_20} [find signals /tb/dut/data_rx_data_20]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_20}
if [regexp {/tb/dut/data_rx_sop_20} [find signals /tb/dut/data_rx_sop_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_20}
if [regexp {/tb/dut/data_rx_eop_20} [find signals /tb/dut/data_rx_eop_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_20}
if [regexp {/tb/dut/data_rx_ready_20} [find signals /tb/dut/data_rx_ready_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_20}
if [regexp {/tb/dut/data_rx_error_20} [find signals /tb/dut/data_rx_error_20]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_20}
if [regexp {/tb/dut/data_rx_valid_20} [find signals /tb/dut/data_rx_valid_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_20}
if [regexp {/tb/dut/pkt_class_data_20} [find signals /tb/dut/pkt_class_data_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_20}
if [regexp {/tb/dut/pkt_class_valid_20} [find signals  /tb/dut/pkt_class_valid_20]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_20}

if [regexp {/tb/dut/data_rx_data_21} [find signals /tb/dut/data_rx_data_21]]          {add wave -noupdate -divider {  AVALON ST RX 21}}
if [regexp {/tb/dut/mac_rx_clk_21} [find signals /tb/dut/mac_rx_clk_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_21}
if [regexp {/tb/dut/data_rx_data_21} [find signals /tb/dut/data_rx_data_21]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_21}
if [regexp {/tb/dut/data_rx_sop_21} [find signals /tb/dut/data_rx_sop_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_21}
if [regexp {/tb/dut/data_rx_eop_21} [find signals /tb/dut/data_rx_eop_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_21}
if [regexp {/tb/dut/data_rx_ready_21} [find signals /tb/dut/data_rx_ready_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_21}
if [regexp {/tb/dut/data_rx_error_21} [find signals /tb/dut/data_rx_error_21]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_21}
if [regexp {/tb/dut/data_rx_valid_21} [find signals /tb/dut/data_rx_valid_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_21}
if [regexp {/tb/dut/pkt_class_data_21} [find signals /tb/dut/pkt_class_data_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_21}
if [regexp {/tb/dut/pkt_class_valid_21} [find signals  /tb/dut/pkt_class_valid_21]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_21}

if [regexp {/tb/dut/data_rx_data_22} [find signals /tb/dut/data_rx_data_22]]          {add wave -noupdate -divider {  AVALON ST RX 22}}
if [regexp {/tb/dut/mac_rx_clk_22} [find signals /tb/dut/mac_rx_clk_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_22}
if [regexp {/tb/dut/data_rx_data_22} [find signals /tb/dut/data_rx_data_22]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_22}
if [regexp {/tb/dut/data_rx_sop_22} [find signals /tb/dut/data_rx_sop_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_22}
if [regexp {/tb/dut/data_rx_eop_22} [find signals /tb/dut/data_rx_eop_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_22}
if [regexp {/tb/dut/data_rx_ready_22} [find signals /tb/dut/data_rx_ready_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_22}
if [regexp {/tb/dut/data_rx_error_22} [find signals /tb/dut/data_rx_error_22]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_22}
if [regexp {/tb/dut/data_rx_valid_22} [find signals /tb/dut/data_rx_valid_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_22}
if [regexp {/tb/dut/pkt_class_data_22} [find signals /tb/dut/pkt_class_data_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_22}
if [regexp {/tb/dut/pkt_class_valid_22} [find signals  /tb/dut/pkt_class_valid_22]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_22}

if [regexp {/tb/dut/data_rx_data_23} [find signals /tb/dut/data_rx_data_23]]          {add wave -noupdate -divider {  AVALON ST RX 23}}
if [regexp {/tb/dut/mac_rx_clk_23} [find signals /tb/dut/mac_rx_clk_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_rx_clk_23}
if [regexp {/tb/dut/data_rx_data_23} [find signals /tb/dut/data_rx_data_23]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_data_23}
if [regexp {/tb/dut/data_rx_sop_23} [find signals /tb/dut/data_rx_sop_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_sop_23}
if [regexp {/tb/dut/data_rx_eop_23} [find signals /tb/dut/data_rx_eop_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_eop_23}
if [regexp {/tb/dut/data_rx_ready_23} [find signals /tb/dut/data_rx_ready_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_ready_23}
if [regexp {/tb/dut/data_rx_error_23} [find signals /tb/dut/data_rx_error_23]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_rx_error_23}
if [regexp {/tb/dut/data_rx_valid_23} [find signals /tb/dut/data_rx_valid_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_rx_valid_23}
if [regexp {/tb/dut/pkt_class_data_23} [find signals /tb/dut/pkt_class_data_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pkt_class_data_23}
if [regexp {/tb/dut/pkt_class_valid_23} [find signals  /tb/dut/pkt_class_valid_23]]       {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/pkt_class_valid_23}


add wave -noupdate -divider -height 40 {TRANSMIT INTERFACE}
if [regexp {/tb/dut/ff_tx_data} [find signals /tb/dut/ff_tx_data]]          {add wave -noupdate -divider {  FIFO TX}}
if [regexp {/tb/dut/ff_tx_clk} [find signals /tb/dut/ff_tx_clk]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_clk}
if [regexp {/tb/dut/ff_tx_data} [find signals /tb/dut/ff_tx_data]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/ff_tx_data}
if [regexp {/tb/dut/ff_tx_sop} [find signals /tb/dut/ff_tx_sop]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_sop}
if [regexp {/tb/dut/ff_tx_eop} [find signals /tb/dut/ff_tx_eop]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_eop}
if [regexp {/tb/dut/ff_tx_rdy} [find signals /tb/dut/ff_tx_rdy]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_rdy}
if [regexp {/tb/dut/ff_tx_wren} [find signals /tb/dut/ff_tx_wren]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_wren}
if [regexp {/tb/dut/ff_tx_crc_fwd} [find signals /tb/dut/ff_tx_crc_fwd]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_crc_fwd}
if [regexp {/tb/dut/ff_tx_err} [find signals /tb/dut/ff_tx_err]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_err}
if [regexp {/tb/dut/ff_tx_mod} [find signals /tb/dut/ff_tx_mod]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/ff_tx_mod}
if [regexp {/tb/dut/ff_tx_septy} [find signals /tb/dut/ff_tx_septy]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_septy}
if [regexp {/tb/dut/tx_ff_uflow} [find signals /tb/dut/tx_ff_uflow]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_ff_uflow}
if [regexp {/tb/dut/ff_tx_a_full} [find signals /tb/dut/ff_tx_a_full]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_a_full}
if [regexp {/tb/dut/ff_tx_a_empty} [find signals /tb/dut/ff_tx_a_empty]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ff_tx_a_empty}

if [regexp {/tb/dut/data_tx_data_0} [find signals /tb/dut/data_tx_data_0]]          {add wave -noupdate -divider {  AVALON ST TX 0}}
if [regexp {/tb/dut/mac_tx_clk_0} [find signals /tb/dut/mac_tx_clk_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_0}
if [regexp {/tb/dut/data_tx_data_0} [find signals /tb/dut/data_tx_data_0]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_0}
if [regexp {/tb/dut/data_tx_sop_0} [find signals /tb/dut/data_tx_sop_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_0}
if [regexp {/tb/dut/data_tx_eop_0} [find signals /tb/dut/data_tx_eop_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_0}
if [regexp {/tb/dut/data_tx_ready_0} [find signals /tb/dut/data_tx_ready_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_0}
if [regexp {/tb/dut/data_tx_error_0} [find signals /tb/dut/data_tx_error_0]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_0}
if [regexp {/tb/dut/data_tx_valid_0} [find signals /tb/dut/data_tx_valid_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_0}

if [regexp {/tb/dut/data_tx_data_1} [find signals /tb/dut/data_tx_data_1]]          {add wave -noupdate -divider {  AVALON ST TX 1}}
if [regexp {/tb/dut/mac_tx_clk_1} [find signals /tb/dut/mac_tx_clk_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_1}
if [regexp {/tb/dut/data_tx_data_1} [find signals /tb/dut/data_tx_data_1]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_1}
if [regexp {/tb/dut/data_tx_sop_1} [find signals /tb/dut/data_tx_sop_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_1}
if [regexp {/tb/dut/data_tx_eop_1} [find signals /tb/dut/data_tx_eop_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_1}
if [regexp {/tb/dut/data_tx_ready_1} [find signals /tb/dut/data_tx_ready_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_1}
if [regexp {/tb/dut/data_tx_error_1} [find signals /tb/dut/data_tx_error_1]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_1}
if [regexp {/tb/dut/data_tx_valid_1} [find signals /tb/dut/data_tx_valid_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_1}

if [regexp {/tb/dut/data_tx_data_2} [find signals /tb/dut/data_tx_data_2]]          {add wave -noupdate -divider {  AVALON ST TX 2}}
if [regexp {/tb/dut/mac_tx_clk_2} [find signals /tb/dut/mac_tx_clk_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_2}
if [regexp {/tb/dut/data_tx_data_2} [find signals /tb/dut/data_tx_data_2]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_2}
if [regexp {/tb/dut/data_tx_sop_2} [find signals /tb/dut/data_tx_sop_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_2}
if [regexp {/tb/dut/data_tx_eop_2} [find signals /tb/dut/data_tx_eop_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_2}
if [regexp {/tb/dut/data_tx_ready_2} [find signals /tb/dut/data_tx_ready_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_2}
if [regexp {/tb/dut/data_tx_error_2} [find signals /tb/dut/data_tx_error_2]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_2}
if [regexp {/tb/dut/data_tx_valid_2} [find signals /tb/dut/data_tx_valid_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_2}

if [regexp {/tb/dut/data_tx_data_3} [find signals /tb/dut/data_tx_data_3]]          {add wave -noupdate -divider {  AVALON ST TX 3}}
if [regexp {/tb/dut/mac_tx_clk_3} [find signals /tb/dut/mac_tx_clk_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_3}
if [regexp {/tb/dut/data_tx_data_3} [find signals /tb/dut/data_tx_data_3]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_3}
if [regexp {/tb/dut/data_tx_sop_3} [find signals /tb/dut/data_tx_sop_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_3}
if [regexp {/tb/dut/data_tx_eop_3} [find signals /tb/dut/data_tx_eop_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_3}
if [regexp {/tb/dut/data_tx_ready_3} [find signals /tb/dut/data_tx_ready_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_3}
if [regexp {/tb/dut/data_tx_error_3} [find signals /tb/dut/data_tx_error_3]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_3}
if [regexp {/tb/dut/data_tx_valid_3} [find signals /tb/dut/data_tx_valid_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_3}

if [regexp {/tb/dut/data_tx_data_4} [find signals /tb/dut/data_tx_data_4]]          {add wave -noupdate -divider {  AVALON ST TX 4}}
if [regexp {/tb/dut/mac_tx_clk_4} [find signals /tb/dut/mac_tx_clk_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_4}
if [regexp {/tb/dut/data_tx_data_4} [find signals /tb/dut/data_tx_data_4]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_4}
if [regexp {/tb/dut/data_tx_sop_4} [find signals /tb/dut/data_tx_sop_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_4}
if [regexp {/tb/dut/data_tx_eop_4} [find signals /tb/dut/data_tx_eop_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_4}
if [regexp {/tb/dut/data_tx_ready_4} [find signals /tb/dut/data_tx_ready_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_4}
if [regexp {/tb/dut/data_tx_error_4} [find signals /tb/dut/data_tx_error_4]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_4}
if [regexp {/tb/dut/data_tx_valid_4} [find signals /tb/dut/data_tx_valid_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_4}

if [regexp {/tb/dut/data_tx_data_5} [find signals /tb/dut/data_tx_data_5]]          {add wave -noupdate -divider {  AVALON ST TX 5}}
if [regexp {/tb/dut/mac_tx_clk_5} [find signals /tb/dut/mac_tx_clk_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_5}
if [regexp {/tb/dut/data_tx_data_5} [find signals /tb/dut/data_tx_data_5]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_5}
if [regexp {/tb/dut/data_tx_sop_5} [find signals /tb/dut/data_tx_sop_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_5}
if [regexp {/tb/dut/data_tx_eop_5} [find signals /tb/dut/data_tx_eop_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_5}
if [regexp {/tb/dut/data_tx_ready_5} [find signals /tb/dut/data_tx_ready_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_5}
if [regexp {/tb/dut/data_tx_error_5} [find signals /tb/dut/data_tx_error_5]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_5}
if [regexp {/tb/dut/data_tx_valid_5} [find signals /tb/dut/data_tx_valid_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_5}

if [regexp {/tb/dut/data_tx_data_6} [find signals /tb/dut/data_tx_data_6]]          {add wave -noupdate -divider {  AVALON ST TX 6}}
if [regexp {/tb/dut/mac_tx_clk_6} [find signals /tb/dut/mac_tx_clk_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_6}
if [regexp {/tb/dut/data_tx_data_6} [find signals /tb/dut/data_tx_data_6]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_6}
if [regexp {/tb/dut/data_tx_sop_6} [find signals /tb/dut/data_tx_sop_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_6}
if [regexp {/tb/dut/data_tx_eop_6} [find signals /tb/dut/data_tx_eop_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_6}
if [regexp {/tb/dut/data_tx_ready_6} [find signals /tb/dut/data_tx_ready_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_6}
if [regexp {/tb/dut/data_tx_error_6} [find signals /tb/dut/data_tx_error_6]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_6}
if [regexp {/tb/dut/data_tx_valid_6} [find signals /tb/dut/data_tx_valid_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_6}

if [regexp {/tb/dut/data_tx_data_7} [find signals /tb/dut/data_tx_data_7]]          {add wave -noupdate -divider {  AVALON ST TX 7}}
if [regexp {/tb/dut/mac_tx_clk_7} [find signals /tb/dut/mac_tx_clk_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_7}
if [regexp {/tb/dut/data_tx_data_7} [find signals /tb/dut/data_tx_data_7]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_7}
if [regexp {/tb/dut/data_tx_sop_7} [find signals /tb/dut/data_tx_sop_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_7}
if [regexp {/tb/dut/data_tx_eop_7} [find signals /tb/dut/data_tx_eop_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_7}
if [regexp {/tb/dut/data_tx_ready_7} [find signals /tb/dut/data_tx_ready_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_7}
if [regexp {/tb/dut/data_tx_error_7} [find signals /tb/dut/data_tx_error_7]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_7}
if [regexp {/tb/dut/data_tx_valid_7} [find signals /tb/dut/data_tx_valid_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_7}

if [regexp {/tb/dut/data_tx_data_8} [find signals /tb/dut/data_tx_data_8]]          {add wave -noupdate -divider {  AVALON ST TX 8}}
if [regexp {/tb/dut/mac_tx_clk_8} [find signals /tb/dut/mac_tx_clk_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_8}
if [regexp {/tb/dut/data_tx_data_8} [find signals /tb/dut/data_tx_data_8]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_8}
if [regexp {/tb/dut/data_tx_sop_8} [find signals /tb/dut/data_tx_sop_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_8}
if [regexp {/tb/dut/data_tx_eop_8} [find signals /tb/dut/data_tx_eop_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_8}
if [regexp {/tb/dut/data_tx_ready_8} [find signals /tb/dut/data_tx_ready_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_8}
if [regexp {/tb/dut/data_tx_error_8} [find signals /tb/dut/data_tx_error_8]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_8}
if [regexp {/tb/dut/data_tx_valid_8} [find signals /tb/dut/data_tx_valid_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_8}

if [regexp {/tb/dut/data_tx_data_9} [find signals /tb/dut/data_tx_data_9]]          {add wave -noupdate -divider {  AVALON ST TX 9}}
if [regexp {/tb/dut/mac_tx_clk_9} [find signals /tb/dut/mac_tx_clk_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_9}
if [regexp {/tb/dut/data_tx_data_9} [find signals /tb/dut/data_tx_data_9]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_9}
if [regexp {/tb/dut/data_tx_sop_9} [find signals /tb/dut/data_tx_sop_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_9}
if [regexp {/tb/dut/data_tx_eop_9} [find signals /tb/dut/data_tx_eop_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_9}
if [regexp {/tb/dut/data_tx_ready_9} [find signals /tb/dut/data_tx_ready_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_9}
if [regexp {/tb/dut/data_tx_error_9} [find signals /tb/dut/data_tx_error_9]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_9}
if [regexp {/tb/dut/data_tx_valid_9} [find signals /tb/dut/data_tx_valid_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_9}

if [regexp {/tb/dut/data_tx_data_10} [find signals /tb/dut/data_tx_data_10]]          {add wave -noupdate -divider {  AVALON ST TX 10}}
if [regexp {/tb/dut/mac_tx_clk_10} [find signals /tb/dut/mac_tx_clk_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_10}
if [regexp {/tb/dut/data_tx_data_10} [find signals /tb/dut/data_tx_data_10]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_10}
if [regexp {/tb/dut/data_tx_sop_10} [find signals /tb/dut/data_tx_sop_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_10}
if [regexp {/tb/dut/data_tx_eop_10} [find signals /tb/dut/data_tx_eop_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_10}
if [regexp {/tb/dut/data_tx_ready_10} [find signals /tb/dut/data_tx_ready_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_10}
if [regexp {/tb/dut/data_tx_error_10} [find signals /tb/dut/data_tx_error_10]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_10}
if [regexp {/tb/dut/data_tx_valid_10} [find signals /tb/dut/data_tx_valid_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_10}

if [regexp {/tb/dut/data_tx_data_11} [find signals /tb/dut/data_tx_data_11]]          {add wave -noupdate -divider {  AVALON ST TX 11}}
if [regexp {/tb/dut/mac_tx_clk_11} [find signals /tb/dut/mac_tx_clk_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_11}
if [regexp {/tb/dut/data_tx_data_11} [find signals /tb/dut/data_tx_data_11]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_11}
if [regexp {/tb/dut/data_tx_sop_11} [find signals /tb/dut/data_tx_sop_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_11}
if [regexp {/tb/dut/data_tx_eop_11} [find signals /tb/dut/data_tx_eop_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_11}
if [regexp {/tb/dut/data_tx_ready_11} [find signals /tb/dut/data_tx_ready_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_11}
if [regexp {/tb/dut/data_tx_error_11} [find signals /tb/dut/data_tx_error_11]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_11}
if [regexp {/tb/dut/data_tx_valid_11} [find signals /tb/dut/data_tx_valid_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_11}

if [regexp {/tb/dut/data_tx_data_12} [find signals /tb/dut/data_tx_data_12]]          {add wave -noupdate -divider {  AVALON ST TX 12}}
if [regexp {/tb/dut/mac_tx_clk_12} [find signals /tb/dut/mac_tx_clk_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_12}
if [regexp {/tb/dut/data_tx_data_12} [find signals /tb/dut/data_tx_data_12]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_12}
if [regexp {/tb/dut/data_tx_sop_12} [find signals /tb/dut/data_tx_sop_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_12}
if [regexp {/tb/dut/data_tx_eop_12} [find signals /tb/dut/data_tx_eop_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_12}
if [regexp {/tb/dut/data_tx_ready_12} [find signals /tb/dut/data_tx_ready_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_12}
if [regexp {/tb/dut/data_tx_error_12} [find signals /tb/dut/data_tx_error_12]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_12}
if [regexp {/tb/dut/data_tx_valid_12} [find signals /tb/dut/data_tx_valid_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_12}

if [regexp {/tb/dut/data_tx_data_13} [find signals /tb/dut/data_tx_data_13]]          {add wave -noupdate -divider {  AVALON ST TX 13}}
if [regexp {/tb/dut/mac_tx_clk_13} [find signals /tb/dut/mac_tx_clk_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_13}
if [regexp {/tb/dut/data_tx_data_13} [find signals /tb/dut/data_tx_data_13]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_13}
if [regexp {/tb/dut/data_tx_sop_13} [find signals /tb/dut/data_tx_sop_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_13}
if [regexp {/tb/dut/data_tx_eop_13} [find signals /tb/dut/data_tx_eop_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_13}
if [regexp {/tb/dut/data_tx_ready_13} [find signals /tb/dut/data_tx_ready_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_13}
if [regexp {/tb/dut/data_tx_error_13} [find signals /tb/dut/data_tx_error_13]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_13}
if [regexp {/tb/dut/data_tx_valid_13} [find signals /tb/dut/data_tx_valid_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_13}

if [regexp {/tb/dut/data_tx_data_14} [find signals /tb/dut/data_tx_data_14]]          {add wave -noupdate -divider {  AVALON ST TX 14}}
if [regexp {/tb/dut/mac_tx_clk_14} [find signals /tb/dut/mac_tx_clk_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_14}
if [regexp {/tb/dut/data_tx_data_14} [find signals /tb/dut/data_tx_data_14]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_14}
if [regexp {/tb/dut/data_tx_sop_14} [find signals /tb/dut/data_tx_sop_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_14}
if [regexp {/tb/dut/data_tx_eop_14} [find signals /tb/dut/data_tx_eop_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_14}
if [regexp {/tb/dut/data_tx_ready_14} [find signals /tb/dut/data_tx_ready_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_14}
if [regexp {/tb/dut/data_tx_error_14} [find signals /tb/dut/data_tx_error_14]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_14}
if [regexp {/tb/dut/data_tx_valid_14} [find signals /tb/dut/data_tx_valid_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_14}

if [regexp {/tb/dut/data_tx_data_15} [find signals /tb/dut/data_tx_data_15]]          {add wave -noupdate -divider {  AVALON ST TX 15}}
if [regexp {/tb/dut/mac_tx_clk_15} [find signals /tb/dut/mac_tx_clk_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_15}
if [regexp {/tb/dut/data_tx_data_15} [find signals /tb/dut/data_tx_data_15]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_15}
if [regexp {/tb/dut/data_tx_sop_15} [find signals /tb/dut/data_tx_sop_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_15}
if [regexp {/tb/dut/data_tx_eop_15} [find signals /tb/dut/data_tx_eop_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_15}
if [regexp {/tb/dut/data_tx_ready_15} [find signals /tb/dut/data_tx_ready_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_15}
if [regexp {/tb/dut/data_tx_error_15} [find signals /tb/dut/data_tx_error_15]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_15}
if [regexp {/tb/dut/data_tx_valid_15} [find signals /tb/dut/data_tx_valid_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_15}

if [regexp {/tb/dut/data_tx_data_16} [find signals /tb/dut/data_tx_data_16]]          {add wave -noupdate -divider {  AVALON ST TX 16}}
if [regexp {/tb/dut/mac_tx_clk_16} [find signals /tb/dut/mac_tx_clk_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_16}
if [regexp {/tb/dut/data_tx_data_16} [find signals /tb/dut/data_tx_data_16]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_16}
if [regexp {/tb/dut/data_tx_sop_16} [find signals /tb/dut/data_tx_sop_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_16}
if [regexp {/tb/dut/data_tx_eop_16} [find signals /tb/dut/data_tx_eop_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_16}
if [regexp {/tb/dut/data_tx_ready_16} [find signals /tb/dut/data_tx_ready_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_16}
if [regexp {/tb/dut/data_tx_error_16} [find signals /tb/dut/data_tx_error_16]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_16}
if [regexp {/tb/dut/data_tx_valid_16} [find signals /tb/dut/data_tx_valid_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_16}

if [regexp {/tb/dut/data_tx_data_17} [find signals /tb/dut/data_tx_data_17]]          {add wave -noupdate -divider {  AVALON ST TX 17}}
if [regexp {/tb/dut/mac_tx_clk_17} [find signals /tb/dut/mac_tx_clk_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_17}
if [regexp {/tb/dut/data_tx_data_17} [find signals /tb/dut/data_tx_data_17]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_17}
if [regexp {/tb/dut/data_tx_sop_17} [find signals /tb/dut/data_tx_sop_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_17}
if [regexp {/tb/dut/data_tx_eop_17} [find signals /tb/dut/data_tx_eop_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_17}
if [regexp {/tb/dut/data_tx_ready_17} [find signals /tb/dut/data_tx_ready_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_17}
if [regexp {/tb/dut/data_tx_error_17} [find signals /tb/dut/data_tx_error_17]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_17}
if [regexp {/tb/dut/data_tx_valid_17} [find signals /tb/dut/data_tx_valid_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_17}

if [regexp {/tb/dut/data_tx_data_18} [find signals /tb/dut/data_tx_data_18]]          {add wave -noupdate -divider {  AVALON ST TX 18}}
if [regexp {/tb/dut/mac_tx_clk_18} [find signals /tb/dut/mac_tx_clk_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_18}
if [regexp {/tb/dut/data_tx_data_18} [find signals /tb/dut/data_tx_data_18]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_18}
if [regexp {/tb/dut/data_tx_sop_18} [find signals /tb/dut/data_tx_sop_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_18}
if [regexp {/tb/dut/data_tx_eop_18} [find signals /tb/dut/data_tx_eop_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_18}
if [regexp {/tb/dut/data_tx_ready_18} [find signals /tb/dut/data_tx_ready_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_18}
if [regexp {/tb/dut/data_tx_error_18} [find signals /tb/dut/data_tx_error_18]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_18}
if [regexp {/tb/dut/data_tx_valid_18} [find signals /tb/dut/data_tx_valid_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_18}

if [regexp {/tb/dut/data_tx_data_19} [find signals /tb/dut/data_tx_data_19]]          {add wave -noupdate -divider {  AVALON ST TX 19}}
if [regexp {/tb/dut/mac_tx_clk_19} [find signals /tb/dut/mac_tx_clk_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_19}
if [regexp {/tb/dut/data_tx_data_19} [find signals /tb/dut/data_tx_data_19]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_19}
if [regexp {/tb/dut/data_tx_sop_19} [find signals /tb/dut/data_tx_sop_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_19}
if [regexp {/tb/dut/data_tx_eop_19} [find signals /tb/dut/data_tx_eop_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_19}
if [regexp {/tb/dut/data_tx_ready_19} [find signals /tb/dut/data_tx_ready_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_19}
if [regexp {/tb/dut/data_tx_error_19} [find signals /tb/dut/data_tx_error_19]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_19}
if [regexp {/tb/dut/data_tx_valid_19} [find signals /tb/dut/data_tx_valid_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_19}

if [regexp {/tb/dut/data_tx_data_20} [find signals /tb/dut/data_tx_data_20]]          {add wave -noupdate -divider {  AVALON ST TX 20}}
if [regexp {/tb/dut/mac_tx_clk_20} [find signals /tb/dut/mac_tx_clk_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_20}
if [regexp {/tb/dut/data_tx_data_20} [find signals /tb/dut/data_tx_data_20]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_20}
if [regexp {/tb/dut/data_tx_sop_20} [find signals /tb/dut/data_tx_sop_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_20}
if [regexp {/tb/dut/data_tx_eop_20} [find signals /tb/dut/data_tx_eop_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_20}
if [regexp {/tb/dut/data_tx_ready_20} [find signals /tb/dut/data_tx_ready_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_20}
if [regexp {/tb/dut/data_tx_error_20} [find signals /tb/dut/data_tx_error_20]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_20}
if [regexp {/tb/dut/data_tx_valid_20} [find signals /tb/dut/data_tx_valid_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_20}

if [regexp {/tb/dut/data_tx_data_21} [find signals /tb/dut/data_tx_data_21]]          {add wave -noupdate -divider {  AVALON ST TX 21}}
if [regexp {/tb/dut/mac_tx_clk_21} [find signals /tb/dut/mac_tx_clk_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_21}
if [regexp {/tb/dut/data_tx_data_21} [find signals /tb/dut/data_tx_data_21]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_21}
if [regexp {/tb/dut/data_tx_sop_21} [find signals /tb/dut/data_tx_sop_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_21}
if [regexp {/tb/dut/data_tx_eop_21} [find signals /tb/dut/data_tx_eop_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_21}
if [regexp {/tb/dut/data_tx_ready_21} [find signals /tb/dut/data_tx_ready_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_21}
if [regexp {/tb/dut/data_tx_error_21} [find signals /tb/dut/data_tx_error_21]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_21}
if [regexp {/tb/dut/data_tx_valid_21} [find signals /tb/dut/data_tx_valid_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_21}

if [regexp {/tb/dut/data_tx_data_22} [find signals /tb/dut/data_tx_data_22]]          {add wave -noupdate -divider {  AVALON ST TX 22}}
if [regexp {/tb/dut/mac_tx_clk_22} [find signals /tb/dut/mac_tx_clk_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_22}
if [regexp {/tb/dut/data_tx_data_22} [find signals /tb/dut/data_tx_data_22]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_22}
if [regexp {/tb/dut/data_tx_sop_22} [find signals /tb/dut/data_tx_sop_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_22}
if [regexp {/tb/dut/data_tx_eop_22} [find signals /tb/dut/data_tx_eop_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_22}
if [regexp {/tb/dut/data_tx_ready_22} [find signals /tb/dut/data_tx_ready_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_22}
if [regexp {/tb/dut/data_tx_error_22} [find signals /tb/dut/data_tx_error_22]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_22}
if [regexp {/tb/dut/data_tx_valid_22} [find signals /tb/dut/data_tx_valid_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_22}

if [regexp {/tb/dut/data_tx_data_23} [find signals /tb/dut/data_tx_data_23]]          {add wave -noupdate -divider {  AVALON ST TX 23}}
if [regexp {/tb/dut/mac_tx_clk_23} [find signals /tb/dut/mac_tx_clk_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mac_tx_clk_23}
if [regexp {/tb/dut/data_tx_data_23} [find signals /tb/dut/data_tx_data_23]]          {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_data_23}
if [regexp {/tb/dut/data_tx_sop_23} [find signals /tb/dut/data_tx_sop_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_sop_23}
if [regexp {/tb/dut/data_tx_eop_23} [find signals /tb/dut/data_tx_eop_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_eop_23}
if [regexp {/tb/dut/data_tx_ready_23} [find signals /tb/dut/data_tx_ready_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_ready_23}
if [regexp {/tb/dut/data_tx_error_23} [find signals /tb/dut/data_tx_error_23]]        {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/data_tx_error_23}
if [regexp {/tb/dut/data_tx_valid_23} [find signals /tb/dut/data_tx_valid_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/data_tx_valid_23}


if [regexp {/tb/dut/gmii_tx_d} [find signals /tb/dut/gmii_tx_d]]            {add wave -noupdate -divider {  GMII TX}}
if [regexp {/tb/dut/gm_tx_d} [find signals /tb/dut/gm_tx_d]]                {add wave -noupdate -divider {  GMII TX}}
if [regexp {/tb/dut/tx_clk} [find signals /tb/dut/tx_clk]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk}
if [regexp {/tb/dut/tx_clkena} [find signals /tb/dut/tx_clkena]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clkena}
if [regexp {/tb/dut/gm_tx_err} [find signals /tb/dut/gm_tx_err]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err}
if [regexp {/tb/dut/gm_tx_en} [find signals /tb/dut/gm_tx_en]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en}
if [regexp {/tb/dut/gm_tx_d} [find signals /tb/dut/gm_tx_d]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d}
if [regexp {/tb/dut/gmii_tx_err} [find signals /tb/dut/gmii_tx_err]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err}
if [regexp {/tb/dut/gmii_tx_en} [find signals /tb/dut/gmii_tx_en]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en}
if [regexp {/tb/dut/gmii_tx_d} [find signals /tb/dut/gmii_tx_d]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d}


if [regexp {/tb/dut/gmii_tx_d_0} [find signals /tb/dut/gmii_tx_d_0]]            {add wave -noupdate -divider {  GMII TX 0}}
if [regexp {/tb/dut/gm_tx_d_0} [find signals /tb/dut/gm_tx_d_0]]                {add wave -noupdate -divider {  GMII TX 0}}
if [regexp {/tb/dut/tx_clk_0} [find signals /tb/dut/tx_clk_0]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_0}
if [regexp {/tb/dut/gm_tx_err_0} [find signals /tb/dut/gm_tx_err_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_0}
if [regexp {/tb/dut/gm_tx_en_0} [find signals /tb/dut/gm_tx_en_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_0}
if [regexp {/tb/dut/gm_tx_d_0} [find signals /tb/dut/gm_tx_d_0]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_0}
if [regexp {/tb/dut/gmii_tx_err_0} [find signals /tb/dut/gmii_tx_err_0]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_0}
if [regexp {/tb/dut/gmii_tx_en_0} [find signals /tb/dut/gmii_tx_en_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_0}
if [regexp {/tb/dut/gmii_tx_d_0} [find signals /tb/dut/gmii_tx_d_0]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_0}

if [regexp {/tb/dut/gmii_tx_d_1} [find signals /tb/dut/gmii_tx_d_1]]            {add wave -noupdate -divider {  GMII TX 1}}
if [regexp {/tb/dut/gm_tx_d_1} [find signals /tb/dut/gm_tx_d_1]]                {add wave -noupdate -divider {  GMII TX 1}}
if [regexp {/tb/dut/tx_clk_1} [find signals /tb/dut/tx_clk_1]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_1}
if [regexp {/tb/dut/gm_tx_err_1} [find signals /tb/dut/gm_tx_err_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_1}
if [regexp {/tb/dut/gm_tx_en_1} [find signals /tb/dut/gm_tx_en_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_1}
if [regexp {/tb/dut/gm_tx_d_1} [find signals /tb/dut/gm_tx_d_1]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_1}
if [regexp {/tb/dut/gmii_tx_err_1} [find signals /tb/dut/gmii_tx_err_1]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_1}
if [regexp {/tb/dut/gmii_tx_en_1} [find signals /tb/dut/gmii_tx_en_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_1}
if [regexp {/tb/dut/gmii_tx_d_1} [find signals /tb/dut/gmii_tx_d_1]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_1}

if [regexp {/tb/dut/gmii_tx_d_2} [find signals /tb/dut/gmii_tx_d_2]]            {add wave -noupdate -divider {  GMII TX 2}}
if [regexp {/tb/dut/gm_tx_d_2} [find signals /tb/dut/gm_tx_d_2]]                {add wave -noupdate -divider {  GMII TX 2}}
if [regexp {/tb/dut/tx_clk_2} [find signals /tb/dut/tx_clk_2]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_2}
if [regexp {/tb/dut/gm_tx_err_2} [find signals /tb/dut/gm_tx_err_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_2}
if [regexp {/tb/dut/gm_tx_en_2} [find signals /tb/dut/gm_tx_en_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_2}
if [regexp {/tb/dut/gm_tx_d_2} [find signals /tb/dut/gm_tx_d_2]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_2}
if [regexp {/tb/dut/gmii_tx_err_2} [find signals /tb/dut/gmii_tx_err_2]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_2}
if [regexp {/tb/dut/gmii_tx_en_2} [find signals /tb/dut/gmii_tx_en_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_2}
if [regexp {/tb/dut/gmii_tx_d_2} [find signals /tb/dut/gmii_tx_d_2]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_2}

if [regexp {/tb/dut/gmii_tx_d_3} [find signals /tb/dut/gmii_tx_d_3]]            {add wave -noupdate -divider {  GMII TX 3}}
if [regexp {/tb/dut/gm_tx_d_3} [find signals /tb/dut/gm_tx_d_3]]                {add wave -noupdate -divider {  GMII TX 3}}
if [regexp {/tb/dut/tx_clk_3} [find signals /tb/dut/tx_clk_3]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_3}
if [regexp {/tb/dut/gm_tx_err_3} [find signals /tb/dut/gm_tx_err_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_3}
if [regexp {/tb/dut/gm_tx_en_3} [find signals /tb/dut/gm_tx_en_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_3}
if [regexp {/tb/dut/gm_tx_d_3} [find signals /tb/dut/gm_tx_d_3]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_3}
if [regexp {/tb/dut/gmii_tx_err_3} [find signals /tb/dut/gmii_tx_err_3]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_3}
if [regexp {/tb/dut/gmii_tx_en_3} [find signals /tb/dut/gmii_tx_en_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_3}
if [regexp {/tb/dut/gmii_tx_d_3} [find signals /tb/dut/gmii_tx_d_3]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_3}

if [regexp {/tb/dut/gmii_tx_d_4} [find signals /tb/dut/gmii_tx_d_4]]            {add wave -noupdate -divider {  GMII TX 4}}
if [regexp {/tb/dut/gm_tx_d_4} [find signals /tb/dut/gm_tx_d_4]]                {add wave -noupdate -divider {  GMII TX 4}}
if [regexp {/tb/dut/tx_clk_4} [find signals /tb/dut/tx_clk_4]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_4}
if [regexp {/tb/dut/gm_tx_err_4} [find signals /tb/dut/gm_tx_err_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_4}
if [regexp {/tb/dut/gm_tx_en_4} [find signals /tb/dut/gm_tx_en_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_4}
if [regexp {/tb/dut/gm_tx_d_4} [find signals /tb/dut/gm_tx_d_4]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_4}
if [regexp {/tb/dut/gmii_tx_err_4} [find signals /tb/dut/gmii_tx_err_4]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_4}
if [regexp {/tb/dut/gmii_tx_en_4} [find signals /tb/dut/gmii_tx_en_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_4}
if [regexp {/tb/dut/gmii_tx_d_4} [find signals /tb/dut/gmii_tx_d_4]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_4}

if [regexp {/tb/dut/gmii_tx_d_5} [find signals /tb/dut/gmii_tx_d_5]]            {add wave -noupdate -divider {  GMII TX 5}}
if [regexp {/tb/dut/gm_tx_d_5} [find signals /tb/dut/gm_tx_d_5]]                {add wave -noupdate -divider {  GMII TX 5}}
if [regexp {/tb/dut/tx_clk_5} [find signals /tb/dut/tx_clk_5]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_5}
if [regexp {/tb/dut/gm_tx_err_5} [find signals /tb/dut/gm_tx_err_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_5}
if [regexp {/tb/dut/gm_tx_en_5} [find signals /tb/dut/gm_tx_en_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_5}
if [regexp {/tb/dut/gm_tx_d_5} [find signals /tb/dut/gm_tx_d_5]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_5}
if [regexp {/tb/dut/gmii_tx_err_5} [find signals /tb/dut/gmii_tx_err_5]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_5}
if [regexp {/tb/dut/gmii_tx_en_5} [find signals /tb/dut/gmii_tx_en_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_5}
if [regexp {/tb/dut/gmii_tx_d_5} [find signals /tb/dut/gmii_tx_d_5]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_5}

if [regexp {/tb/dut/gmii_tx_d_6} [find signals /tb/dut/gmii_tx_d_6]]            {add wave -noupdate -divider {  GMII TX 6}}
if [regexp {/tb/dut/gm_tx_d_6} [find signals /tb/dut/gm_tx_d_6]]                {add wave -noupdate -divider {  GMII TX 6}}
if [regexp {/tb/dut/tx_clk_6} [find signals /tb/dut/tx_clk_6]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_6}
if [regexp {/tb/dut/gm_tx_err_6} [find signals /tb/dut/gm_tx_err_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_6}
if [regexp {/tb/dut/gm_tx_en_6} [find signals /tb/dut/gm_tx_en_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_6}
if [regexp {/tb/dut/gm_tx_d_6} [find signals /tb/dut/gm_tx_d_6]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_6}
if [regexp {/tb/dut/gmii_tx_err_6} [find signals /tb/dut/gmii_tx_err_6]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_6}
if [regexp {/tb/dut/gmii_tx_en_6} [find signals /tb/dut/gmii_tx_en_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_6}
if [regexp {/tb/dut/gmii_tx_d_6} [find signals /tb/dut/gmii_tx_d_6]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_6}

if [regexp {/tb/dut/gmii_tx_d_7} [find signals /tb/dut/gmii_tx_d_7]]            {add wave -noupdate -divider {  GMII TX 7}}
if [regexp {/tb/dut/gm_tx_d_7} [find signals /tb/dut/gm_tx_d_7]]                {add wave -noupdate -divider {  GMII TX 7}}
if [regexp {/tb/dut/tx_clk_7} [find signals /tb/dut/tx_clk_7]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_7}
if [regexp {/tb/dut/gm_tx_err_7} [find signals /tb/dut/gm_tx_err_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_7}
if [regexp {/tb/dut/gm_tx_en_7} [find signals /tb/dut/gm_tx_en_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_7}
if [regexp {/tb/dut/gm_tx_d_7} [find signals /tb/dut/gm_tx_d_7]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_7}
if [regexp {/tb/dut/gmii_tx_err_7} [find signals /tb/dut/gmii_tx_err_7]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_7}
if [regexp {/tb/dut/gmii_tx_en_7} [find signals /tb/dut/gmii_tx_en_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_7}
if [regexp {/tb/dut/gmii_tx_d_7} [find signals /tb/dut/gmii_tx_d_7]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_7}

if [regexp {/tb/dut/gmii_tx_d_8} [find signals /tb/dut/gmii_tx_d_8]]            {add wave -noupdate -divider {  GMII TX 8}}
if [regexp {/tb/dut/gm_tx_d_8} [find signals /tb/dut/gm_tx_d_8]]                {add wave -noupdate -divider {  GMII TX 8}}
if [regexp {/tb/dut/tx_clk_8} [find signals /tb/dut/tx_clk_8]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_8}
if [regexp {/tb/dut/gm_tx_err_8} [find signals /tb/dut/gm_tx_err_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_8}
if [regexp {/tb/dut/gm_tx_en_8} [find signals /tb/dut/gm_tx_en_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_8}
if [regexp {/tb/dut/gm_tx_d_8} [find signals /tb/dut/gm_tx_d_8]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_8}
if [regexp {/tb/dut/gmii_tx_err_8} [find signals /tb/dut/gmii_tx_err_8]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_8}
if [regexp {/tb/dut/gmii_tx_en_8} [find signals /tb/dut/gmii_tx_en_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_8}
if [regexp {/tb/dut/gmii_tx_d_8} [find signals /tb/dut/gmii_tx_d_8]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_8}

if [regexp {/tb/dut/gmii_tx_d_9} [find signals /tb/dut/gmii_tx_d_9]]            {add wave -noupdate -divider {  GMII TX 9}}
if [regexp {/tb/dut/gm_tx_d_9} [find signals /tb/dut/gm_tx_d_9]]                {add wave -noupdate -divider {  GMII TX 9}}
if [regexp {/tb/dut/tx_clk_9} [find signals /tb/dut/tx_clk_9]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_9}
if [regexp {/tb/dut/gm_tx_err_9} [find signals /tb/dut/gm_tx_err_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_9}
if [regexp {/tb/dut/gm_tx_en_9} [find signals /tb/dut/gm_tx_en_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_9}
if [regexp {/tb/dut/gm_tx_d_9} [find signals /tb/dut/gm_tx_d_9]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_9}
if [regexp {/tb/dut/gmii_tx_err_9} [find signals /tb/dut/gmii_tx_err_9]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_9}
if [regexp {/tb/dut/gmii_tx_en_9} [find signals /tb/dut/gmii_tx_en_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_9}
if [regexp {/tb/dut/gmii_tx_d_9} [find signals /tb/dut/gmii_tx_d_9]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_9}

if [regexp {/tb/dut/gmii_tx_d_10} [find signals /tb/dut/gmii_tx_d_10]]            {add wave -noupdate -divider {  GMII TX 10}}
if [regexp {/tb/dut/gm_tx_d_10} [find signals /tb/dut/gm_tx_d_10]]                {add wave -noupdate -divider {  GMII TX 10}}
if [regexp {/tb/dut/tx_clk_10} [find signals /tb/dut/tx_clk_10]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_10}
if [regexp {/tb/dut/gm_tx_err_10} [find signals /tb/dut/gm_tx_err_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_10}
if [regexp {/tb/dut/gm_tx_en_10} [find signals /tb/dut/gm_tx_en_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_10}
if [regexp {/tb/dut/gm_tx_d_10} [find signals /tb/dut/gm_tx_d_10]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_10}
if [regexp {/tb/dut/gmii_tx_err_10} [find signals /tb/dut/gmii_tx_err_10]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_10}
if [regexp {/tb/dut/gmii_tx_en_10} [find signals /tb/dut/gmii_tx_en_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_10}
if [regexp {/tb/dut/gmii_tx_d_10} [find signals /tb/dut/gmii_tx_d_10]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_10}

if [regexp {/tb/dut/gmii_tx_d_11} [find signals /tb/dut/gmii_tx_d_11]]            {add wave -noupdate -divider {  GMII TX 11}}
if [regexp {/tb/dut/gm_tx_d_11} [find signals /tb/dut/gm_tx_d_11]]                {add wave -noupdate -divider {  GMII TX 11}}
if [regexp {/tb/dut/tx_clk_11} [find signals /tb/dut/tx_clk_11]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_11}
if [regexp {/tb/dut/gm_tx_err_11} [find signals /tb/dut/gm_tx_err_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_11}
if [regexp {/tb/dut/gm_tx_en_11} [find signals /tb/dut/gm_tx_en_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_11}
if [regexp {/tb/dut/gm_tx_d_11} [find signals /tb/dut/gm_tx_d_11]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_11}
if [regexp {/tb/dut/gmii_tx_err_11} [find signals /tb/dut/gmii_tx_err_11]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_11}
if [regexp {/tb/dut/gmii_tx_en_11} [find signals /tb/dut/gmii_tx_en_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_11}
if [regexp {/tb/dut/gmii_tx_d_11} [find signals /tb/dut/gmii_tx_d_11]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_11}

if [regexp {/tb/dut/gmii_tx_d_12} [find signals /tb/dut/gmii_tx_d_12]]            {add wave -noupdate -divider {  GMII TX 12}}
if [regexp {/tb/dut/gm_tx_d_12} [find signals /tb/dut/gm_tx_d_12]]                {add wave -noupdate -divider {  GMII TX 12}}
if [regexp {/tb/dut/tx_clk_12} [find signals /tb/dut/tx_clk_12]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_12}
if [regexp {/tb/dut/gm_tx_err_12} [find signals /tb/dut/gm_tx_err_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_12}
if [regexp {/tb/dut/gm_tx_en_12} [find signals /tb/dut/gm_tx_en_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_12}
if [regexp {/tb/dut/gm_tx_d_12} [find signals /tb/dut/gm_tx_d_12]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_12}
if [regexp {/tb/dut/gmii_tx_err_12} [find signals /tb/dut/gmii_tx_err_12]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_12}
if [regexp {/tb/dut/gmii_tx_en_12} [find signals /tb/dut/gmii_tx_en_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_12}
if [regexp {/tb/dut/gmii_tx_d_12} [find signals /tb/dut/gmii_tx_d_12]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_12}

if [regexp {/tb/dut/gmii_tx_d_13} [find signals /tb/dut/gmii_tx_d_13]]            {add wave -noupdate -divider {  GMII TX 13}}
if [regexp {/tb/dut/gm_tx_d_13} [find signals /tb/dut/gm_tx_d_13]]                {add wave -noupdate -divider {  GMII TX 13}}
if [regexp {/tb/dut/tx_clk_13} [find signals /tb/dut/tx_clk_13]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_13}
if [regexp {/tb/dut/gm_tx_err_13} [find signals /tb/dut/gm_tx_err_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_13}
if [regexp {/tb/dut/gm_tx_en_13} [find signals /tb/dut/gm_tx_en_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_13}
if [regexp {/tb/dut/gm_tx_d_13} [find signals /tb/dut/gm_tx_d_13]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_13}
if [regexp {/tb/dut/gmii_tx_err_13} [find signals /tb/dut/gmii_tx_err_13]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_13}
if [regexp {/tb/dut/gmii_tx_en_13} [find signals /tb/dut/gmii_tx_en_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_13}
if [regexp {/tb/dut/gmii_tx_d_13} [find signals /tb/dut/gmii_tx_d_13]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_13}

if [regexp {/tb/dut/gmii_tx_d_14} [find signals /tb/dut/gmii_tx_d_14]]            {add wave -noupdate -divider {  GMII TX 14}}
if [regexp {/tb/dut/gm_tx_d_14} [find signals /tb/dut/gm_tx_d_14]]                {add wave -noupdate -divider {  GMII TX 14}}
if [regexp {/tb/dut/tx_clk_14} [find signals /tb/dut/tx_clk_14]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_14}
if [regexp {/tb/dut/gm_tx_err_14} [find signals /tb/dut/gm_tx_err_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_14}
if [regexp {/tb/dut/gm_tx_en_14} [find signals /tb/dut/gm_tx_en_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_14}
if [regexp {/tb/dut/gm_tx_d_14} [find signals /tb/dut/gm_tx_d_14]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_14}
if [regexp {/tb/dut/gmii_tx_err_14} [find signals /tb/dut/gmii_tx_err_14]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_14}
if [regexp {/tb/dut/gmii_tx_en_14} [find signals /tb/dut/gmii_tx_en_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_14}
if [regexp {/tb/dut/gmii_tx_d_14} [find signals /tb/dut/gmii_tx_d_14]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_14}

if [regexp {/tb/dut/gmii_tx_d_15} [find signals /tb/dut/gmii_tx_d_15]]            {add wave -noupdate -divider {  GMII TX 15}}
if [regexp {/tb/dut/gm_tx_d_15} [find signals /tb/dut/gm_tx_d_15]]                {add wave -noupdate -divider {  GMII TX 15}}
if [regexp {/tb/dut/tx_clk_15} [find signals /tb/dut/tx_clk_15]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_15}
if [regexp {/tb/dut/gm_tx_err_15} [find signals /tb/dut/gm_tx_err_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_15}
if [regexp {/tb/dut/gm_tx_en_15} [find signals /tb/dut/gm_tx_en_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_15}
if [regexp {/tb/dut/gm_tx_d_15} [find signals /tb/dut/gm_tx_d_15]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_15}
if [regexp {/tb/dut/gmii_tx_err_15} [find signals /tb/dut/gmii_tx_err_15]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_15}
if [regexp {/tb/dut/gmii_tx_en_15} [find signals /tb/dut/gmii_tx_en_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_15}
if [regexp {/tb/dut/gmii_tx_d_15} [find signals /tb/dut/gmii_tx_d_15]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_15}

if [regexp {/tb/dut/gmii_tx_d_16} [find signals /tb/dut/gmii_tx_d_16]]            {add wave -noupdate -divider {  GMII TX 16}}
if [regexp {/tb/dut/gm_tx_d_16} [find signals /tb/dut/gm_tx_d_16]]                {add wave -noupdate -divider {  GMII TX 16}}
if [regexp {/tb/dut/tx_clk_16} [find signals /tb/dut/tx_clk_16]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_16}
if [regexp {/tb/dut/gm_tx_err_16} [find signals /tb/dut/gm_tx_err_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_16}
if [regexp {/tb/dut/gm_tx_en_16} [find signals /tb/dut/gm_tx_en_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_16}
if [regexp {/tb/dut/gm_tx_d_16} [find signals /tb/dut/gm_tx_d_16]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_16}
if [regexp {/tb/dut/gmii_tx_err_16} [find signals /tb/dut/gmii_tx_err_16]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_16}
if [regexp {/tb/dut/gmii_tx_en_16} [find signals /tb/dut/gmii_tx_en_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_16}
if [regexp {/tb/dut/gmii_tx_d_16} [find signals /tb/dut/gmii_tx_d_16]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_16}

if [regexp {/tb/dut/gmii_tx_d_17} [find signals /tb/dut/gmii_tx_d_17]]            {add wave -noupdate -divider {  GMII TX 17}}
if [regexp {/tb/dut/gm_tx_d_17} [find signals /tb/dut/gm_tx_d_17]]                {add wave -noupdate -divider {  GMII TX 17}}
if [regexp {/tb/dut/tx_clk_17} [find signals /tb/dut/tx_clk_17]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_17}
if [regexp {/tb/dut/gm_tx_err_17} [find signals /tb/dut/gm_tx_err_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_17}
if [regexp {/tb/dut/gm_tx_en_17} [find signals /tb/dut/gm_tx_en_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_17}
if [regexp {/tb/dut/gm_tx_d_17} [find signals /tb/dut/gm_tx_d_17]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_17}
if [regexp {/tb/dut/gmii_tx_err_17} [find signals /tb/dut/gmii_tx_err_17]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_17}
if [regexp {/tb/dut/gmii_tx_en_17} [find signals /tb/dut/gmii_tx_en_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_17}
if [regexp {/tb/dut/gmii_tx_d_17} [find signals /tb/dut/gmii_tx_d_17]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_17}

if [regexp {/tb/dut/gmii_tx_d_18} [find signals /tb/dut/gmii_tx_d_18]]            {add wave -noupdate -divider {  GMII TX 18}}
if [regexp {/tb/dut/gm_tx_d_18} [find signals /tb/dut/gm_tx_d_18]]                {add wave -noupdate -divider {  GMII TX 18}}
if [regexp {/tb/dut/tx_clk_18} [find signals /tb/dut/tx_clk_18]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_18}
if [regexp {/tb/dut/gm_tx_err_18} [find signals /tb/dut/gm_tx_err_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_18}
if [regexp {/tb/dut/gm_tx_en_18} [find signals /tb/dut/gm_tx_en_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_18}
if [regexp {/tb/dut/gm_tx_d_18} [find signals /tb/dut/gm_tx_d_18]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_18}
if [regexp {/tb/dut/gmii_tx_err_18} [find signals /tb/dut/gmii_tx_err_18]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_18}
if [regexp {/tb/dut/gmii_tx_en_18} [find signals /tb/dut/gmii_tx_en_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_18}
if [regexp {/tb/dut/gmii_tx_d_18} [find signals /tb/dut/gmii_tx_d_18]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_18}

if [regexp {/tb/dut/gmii_tx_d_19} [find signals /tb/dut/gmii_tx_d_19]]            {add wave -noupdate -divider {  GMII TX 19}}
if [regexp {/tb/dut/gm_tx_d_19} [find signals /tb/dut/gm_tx_d_19]]                {add wave -noupdate -divider {  GMII TX 19}}
if [regexp {/tb/dut/tx_clk_19} [find signals /tb/dut/tx_clk_19]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_19}
if [regexp {/tb/dut/gm_tx_err_19} [find signals /tb/dut/gm_tx_err_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_19}
if [regexp {/tb/dut/gm_tx_en_19} [find signals /tb/dut/gm_tx_en_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_19}
if [regexp {/tb/dut/gm_tx_d_19} [find signals /tb/dut/gm_tx_d_19]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_19}
if [regexp {/tb/dut/gmii_tx_err_19} [find signals /tb/dut/gmii_tx_err_19]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_19}
if [regexp {/tb/dut/gmii_tx_en_19} [find signals /tb/dut/gmii_tx_en_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_19}
if [regexp {/tb/dut/gmii_tx_d_19} [find signals /tb/dut/gmii_tx_d_19]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_19}

if [regexp {/tb/dut/gmii_tx_d_20} [find signals /tb/dut/gmii_tx_d_20]]            {add wave -noupdate -divider {  GMII TX 20}}
if [regexp {/tb/dut/gm_tx_d_20} [find signals /tb/dut/gm_tx_d_20]]                {add wave -noupdate -divider {  GMII TX 20}}
if [regexp {/tb/dut/tx_clk_20} [find signals /tb/dut/tx_clk_20]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_20}
if [regexp {/tb/dut/gm_tx_err_20} [find signals /tb/dut/gm_tx_err_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_20}
if [regexp {/tb/dut/gm_tx_en_20} [find signals /tb/dut/gm_tx_en_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_20}
if [regexp {/tb/dut/gm_tx_d_20} [find signals /tb/dut/gm_tx_d_20]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_20}
if [regexp {/tb/dut/gmii_tx_err_20} [find signals /tb/dut/gmii_tx_err_20]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_20}
if [regexp {/tb/dut/gmii_tx_en_20} [find signals /tb/dut/gmii_tx_en_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_20}
if [regexp {/tb/dut/gmii_tx_d_20} [find signals /tb/dut/gmii_tx_d_20]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_20}

if [regexp {/tb/dut/gmii_tx_d_21} [find signals /tb/dut/gmii_tx_d_21]]            {add wave -noupdate -divider {  GMII TX 21}}
if [regexp {/tb/dut/gm_tx_d_21} [find signals /tb/dut/gm_tx_d_21]]                {add wave -noupdate -divider {  GMII TX 21}}
if [regexp {/tb/dut/tx_clk_21} [find signals /tb/dut/tx_clk_21]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_21}
if [regexp {/tb/dut/gm_tx_err_21} [find signals /tb/dut/gm_tx_err_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_21}
if [regexp {/tb/dut/gm_tx_en_21} [find signals /tb/dut/gm_tx_en_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_21}
if [regexp {/tb/dut/gm_tx_d_21} [find signals /tb/dut/gm_tx_d_21]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_21}
if [regexp {/tb/dut/gmii_tx_err_21} [find signals /tb/dut/gmii_tx_err_21]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_21}
if [regexp {/tb/dut/gmii_tx_en_21} [find signals /tb/dut/gmii_tx_en_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_21}
if [regexp {/tb/dut/gmii_tx_d_21} [find signals /tb/dut/gmii_tx_d_21]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_21}

if [regexp {/tb/dut/gmii_tx_d_22} [find signals /tb/dut/gmii_tx_d_22]]            {add wave -noupdate -divider {  GMII TX 22}}
if [regexp {/tb/dut/gm_tx_d_22} [find signals /tb/dut/gm_tx_d_22]]                {add wave -noupdate -divider {  GMII TX 22}}
if [regexp {/tb/dut/tx_clk_22} [find signals /tb/dut/tx_clk_22]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_22}
if [regexp {/tb/dut/gm_tx_err_22} [find signals /tb/dut/gm_tx_err_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_22}
if [regexp {/tb/dut/gm_tx_en_22} [find signals /tb/dut/gm_tx_en_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_22}
if [regexp {/tb/dut/gm_tx_d_22} [find signals /tb/dut/gm_tx_d_22]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_22}
if [regexp {/tb/dut/gmii_tx_err_22} [find signals /tb/dut/gmii_tx_err_22]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_22}
if [regexp {/tb/dut/gmii_tx_en_22} [find signals /tb/dut/gmii_tx_en_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_22}
if [regexp {/tb/dut/gmii_tx_d_22} [find signals /tb/dut/gmii_tx_d_22]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_22}

if [regexp {/tb/dut/gmii_tx_d_23} [find signals /tb/dut/gmii_tx_d_23]]            {add wave -noupdate -divider {  GMII TX 23}}
if [regexp {/tb/dut/gm_tx_d_23} [find signals /tb/dut/gm_tx_d_23]]                {add wave -noupdate -divider {  GMII TX 23}}
if [regexp {/tb/dut/tx_clk_23} [find signals /tb/dut/tx_clk_23]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_23}
if [regexp {/tb/dut/gm_tx_err_23} [find signals /tb/dut/gm_tx_err_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_err_23}
if [regexp {/tb/dut/gm_tx_en_23} [find signals /tb/dut/gm_tx_en_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gm_tx_en_23}
if [regexp {/tb/dut/gm_tx_d_23} [find signals /tb/dut/gm_tx_d_23]]                {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gm_tx_d_23}
if [regexp {/tb/dut/gmii_tx_err_23} [find signals /tb/dut/gmii_tx_err_23]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_err_23}
if [regexp {/tb/dut/gmii_tx_en_23} [find signals /tb/dut/gmii_tx_en_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gmii_tx_en_23}
if [regexp {/tb/dut/gmii_tx_d_23} [find signals /tb/dut/gmii_tx_d_23]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/gmii_tx_d_23}


if [regexp {/tb/dut/rgmii_out} [find signals /tb/dut/rgmii_out]]            {add wave -noupdate -divider {  RGMII TX}}
if [regexp {/tb/dut/tx_control} [find signals /tb/dut/tx_control]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control}
if [regexp {/tb/dut/rgmii_out} [find signals /tb/dut/rgmii_out]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out}

if [regexp {/tb/dut/rgmii_out_0} [find signals /tb/dut/rgmii_out_0]]            {add wave -noupdate -divider {  RGMII TX 0}}
if [regexp {/tb/dut/tx_control_0} [find signals /tb/dut/tx_control_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_0}
if [regexp {/tb/dut/rgmii_out_0} [find signals /tb/dut/rgmii_out_0]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_0}

if [regexp {/tb/dut/rgmii_out_1} [find signals /tb/dut/rgmii_out_1]]            {add wave -noupdate -divider {  RGMII TX 1}}
if [regexp {/tb/dut/tx_control_1} [find signals /tb/dut/tx_control_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_1}
if [regexp {/tb/dut/rgmii_out_1} [find signals /tb/dut/rgmii_out_1]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_1}

if [regexp {/tb/dut/rgmii_out_2} [find signals /tb/dut/rgmii_out_2]]            {add wave -noupdate -divider {  RGMII TX 2}}
if [regexp {/tb/dut/tx_control_2} [find signals /tb/dut/tx_control_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_2}
if [regexp {/tb/dut/rgmii_out_2} [find signals /tb/dut/rgmii_out_2]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_2}

if [regexp {/tb/dut/rgmii_out_3} [find signals /tb/dut/rgmii_out_3]]            {add wave -noupdate -divider {  RGMII TX 3}}
if [regexp {/tb/dut/tx_control_3} [find signals /tb/dut/tx_control_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_3}
if [regexp {/tb/dut/rgmii_out_3} [find signals /tb/dut/rgmii_out_3]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_3}

if [regexp {/tb/dut/rgmii_out_4} [find signals /tb/dut/rgmii_out_4]]            {add wave -noupdate -divider {  RGMII TX 4}}
if [regexp {/tb/dut/tx_control_4} [find signals /tb/dut/tx_control_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_4}
if [regexp {/tb/dut/rgmii_out_4} [find signals /tb/dut/rgmii_out_4]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_4}

if [regexp {/tb/dut/rgmii_out_5} [find signals /tb/dut/rgmii_out_5]]            {add wave -noupdate -divider {  RGMII TX 5}}
if [regexp {/tb/dut/tx_control_5} [find signals /tb/dut/tx_control_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_5}
if [regexp {/tb/dut/rgmii_out_5} [find signals /tb/dut/rgmii_out_5]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_5}

if [regexp {/tb/dut/rgmii_out_6} [find signals /tb/dut/rgmii_out_6]]            {add wave -noupdate -divider {  RGMII TX 6}}
if [regexp {/tb/dut/tx_control_6} [find signals /tb/dut/tx_control_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_6}
if [regexp {/tb/dut/rgmii_out_6} [find signals /tb/dut/rgmii_out_6]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_6}

if [regexp {/tb/dut/rgmii_out_7} [find signals /tb/dut/rgmii_out_7]]            {add wave -noupdate -divider {  RGMII TX 7}}
if [regexp {/tb/dut/tx_control_7} [find signals /tb/dut/tx_control_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_7}
if [regexp {/tb/dut/rgmii_out_7} [find signals /tb/dut/rgmii_out_7]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_7}

if [regexp {/tb/dut/rgmii_out_8} [find signals /tb/dut/rgmii_out_8]]            {add wave -noupdate -divider {  RGMII TX 8}}
if [regexp {/tb/dut/tx_control_8} [find signals /tb/dut/tx_control_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_8}
if [regexp {/tb/dut/rgmii_out_8} [find signals /tb/dut/rgmii_out_8]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_8}

if [regexp {/tb/dut/rgmii_out_9} [find signals /tb/dut/rgmii_out_9]]            {add wave -noupdate -divider {  RGMII TX 9}}
if [regexp {/tb/dut/tx_control_9} [find signals /tb/dut/tx_control_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_9}
if [regexp {/tb/dut/rgmii_out_9} [find signals /tb/dut/rgmii_out_9]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_9}

if [regexp {/tb/dut/rgmii_out_10} [find signals /tb/dut/rgmii_out_10]]            {add wave -noupdate -divider {  RGMII TX 10}}
if [regexp {/tb/dut/tx_control_10} [find signals /tb/dut/tx_control_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_10}
if [regexp {/tb/dut/rgmii_out_10} [find signals /tb/dut/rgmii_out_10]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_10}

if [regexp {/tb/dut/rgmii_out_11} [find signals /tb/dut/rgmii_out_11]]            {add wave -noupdate -divider {  RGMII TX 11}}
if [regexp {/tb/dut/tx_control_11} [find signals /tb/dut/tx_control_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_11}
if [regexp {/tb/dut/rgmii_out_11} [find signals /tb/dut/rgmii_out_11]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_11}

if [regexp {/tb/dut/rgmii_out_12} [find signals /tb/dut/rgmii_out_12]]            {add wave -noupdate -divider {  RGMII TX 12}}
if [regexp {/tb/dut/tx_control_12} [find signals /tb/dut/tx_control_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_12}
if [regexp {/tb/dut/rgmii_out_12} [find signals /tb/dut/rgmii_out_12]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_12}

if [regexp {/tb/dut/rgmii_out_13} [find signals /tb/dut/rgmii_out_13]]            {add wave -noupdate -divider {  RGMII TX 13}}
if [regexp {/tb/dut/tx_control_13} [find signals /tb/dut/tx_control_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_13}
if [regexp {/tb/dut/rgmii_out_13} [find signals /tb/dut/rgmii_out_13]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_13}

if [regexp {/tb/dut/rgmii_out_14} [find signals /tb/dut/rgmii_out_14]]            {add wave -noupdate -divider {  RGMII TX 14}}
if [regexp {/tb/dut/tx_control_14} [find signals /tb/dut/tx_control_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_14}
if [regexp {/tb/dut/rgmii_out_14} [find signals /tb/dut/rgmii_out_14]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_14}

if [regexp {/tb/dut/rgmii_out_15} [find signals /tb/dut/rgmii_out_15]]            {add wave -noupdate -divider {  RGMII TX 15}}
if [regexp {/tb/dut/tx_control_15} [find signals /tb/dut/tx_control_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_15}
if [regexp {/tb/dut/rgmii_out_15} [find signals /tb/dut/rgmii_out_15]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_15}

if [regexp {/tb/dut/rgmii_out_16} [find signals /tb/dut/rgmii_out_16]]            {add wave -noupdate -divider {  RGMII TX 16}}
if [regexp {/tb/dut/tx_control_16} [find signals /tb/dut/tx_control_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_16}
if [regexp {/tb/dut/rgmii_out_16} [find signals /tb/dut/rgmii_out_16]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_16}

if [regexp {/tb/dut/rgmii_out_17} [find signals /tb/dut/rgmii_out_17]]            {add wave -noupdate -divider {  RGMII TX 17}}
if [regexp {/tb/dut/tx_control_17} [find signals /tb/dut/tx_control_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_17}
if [regexp {/tb/dut/rgmii_out_17} [find signals /tb/dut/rgmii_out_17]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_17}

if [regexp {/tb/dut/rgmii_out_18} [find signals /tb/dut/rgmii_out_18]]            {add wave -noupdate -divider {  RGMII TX 18}}
if [regexp {/tb/dut/tx_control_18} [find signals /tb/dut/tx_control_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_18}
if [regexp {/tb/dut/rgmii_out_18} [find signals /tb/dut/rgmii_out_18]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_18}

if [regexp {/tb/dut/rgmii_out_19} [find signals /tb/dut/rgmii_out_19]]            {add wave -noupdate -divider {  RGMII TX 19}}
if [regexp {/tb/dut/tx_control_19} [find signals /tb/dut/tx_control_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_19}
if [regexp {/tb/dut/rgmii_out_19} [find signals /tb/dut/rgmii_out_19]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_19}

if [regexp {/tb/dut/rgmii_out_20} [find signals /tb/dut/rgmii_out_20]]            {add wave -noupdate -divider {  RGMII TX 20}}
if [regexp {/tb/dut/tx_control_20} [find signals /tb/dut/tx_control_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_20}
if [regexp {/tb/dut/rgmii_out_20} [find signals /tb/dut/rgmii_out_20]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_20}

if [regexp {/tb/dut/rgmii_out_21} [find signals /tb/dut/rgmii_out_21]]            {add wave -noupdate -divider {  RGMII TX 21}}
if [regexp {/tb/dut/tx_control_21} [find signals /tb/dut/tx_control_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_21}
if [regexp {/tb/dut/rgmii_out_21} [find signals /tb/dut/rgmii_out_21]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_21}

if [regexp {/tb/dut/rgmii_out_22} [find signals /tb/dut/rgmii_out_22]]            {add wave -noupdate -divider {  RGMII TX 22}}
if [regexp {/tb/dut/tx_control_22} [find signals /tb/dut/tx_control_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_22}
if [regexp {/tb/dut/rgmii_out_22} [find signals /tb/dut/rgmii_out_22]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_22}

if [regexp {/tb/dut/rgmii_out_23} [find signals /tb/dut/rgmii_out_23]]            {add wave -noupdate -divider {  RGMII TX 23}}
if [regexp {/tb/dut/tx_control_23} [find signals /tb/dut/tx_control_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_control_23}
if [regexp {/tb/dut/rgmii_out_23} [find signals /tb/dut/rgmii_out_23]]            {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/rgmii_out_23}

if [regexp {/tb/dut/m_tx_d} [find signals /tb/dut/m_tx_d]]                  {add wave -noupdate -divider {  MII TX }}
if [regexp {/tb/dut/mii_tx_d} [find signals /tb/dut/mii_tx_d]]              {add wave -noupdate -divider {  MII TX }}
if [regexp {/tb/dut/tx_clk} [find signals /tb/dut/tx_clk]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk}
if [regexp {/tb/dut/tx_clkena} [find signals /tb/dut/tx_clkena]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clkena}
if [regexp {/tb/dut/m_tx_err} [find signals /tb/dut/m_tx_err]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err}
if [regexp {/tb/dut/m_tx_en} [find signals /tb/dut/m_tx_en]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en}
if [regexp {/tb/dut/m_tx_d} [find signals /tb/dut/m_tx_d]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d}
if [regexp {/tb/dut/mii_tx_err} [find signals /tb/dut/mii_tx_err]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err}
if [regexp {/tb/dut/mii_tx_en} [find signals /tb/dut/mii_tx_en]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en}
if [regexp {/tb/dut/mii_tx_d} [find signals /tb/dut/mii_tx_d]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d}

if [regexp {/tb/dut/m_tx_d_0} [find signals /tb/dut/m_tx_d_0]]                  {add wave -noupdate -divider {  MII TX 0}}
if [regexp {/tb/dut/mii_tx_d_0} [find signals /tb/dut/mii_tx_d_0]]              {add wave -noupdate -divider {  MII TX 0}}
if [regexp {/tb/dut/tx_clk_0} [find signals /tb/dut/tx_clk_0]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_0}
if [regexp {/tb/dut/m_tx_err_0} [find signals /tb/dut/m_tx_err_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_0}
if [regexp {/tb/dut/m_tx_en_0} [find signals /tb/dut/m_tx_en_0]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_0}
if [regexp {/tb/dut/m_tx_d_0} [find signals /tb/dut/m_tx_d_0]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_0}
if [regexp {/tb/dut/mii_tx_err_0} [find signals /tb/dut/mii_tx_err_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_0}
if [regexp {/tb/dut/mii_tx_en_0} [find signals /tb/dut/mii_tx_en_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_0}
if [regexp {/tb/dut/mii_tx_d_0} [find signals /tb/dut/mii_tx_d_0]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_0}

if [regexp {/tb/dut/m_tx_d_1} [find signals /tb/dut/m_tx_d_1]]                  {add wave -noupdate -divider {  MII TX 1}}
if [regexp {/tb/dut/mii_tx_d_1} [find signals /tb/dut/mii_tx_d_1]]              {add wave -noupdate -divider {  MII TX 1}}
if [regexp {/tb/dut/tx_clk_1} [find signals /tb/dut/tx_clk_1]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_1}
if [regexp {/tb/dut/m_tx_err_1} [find signals /tb/dut/m_tx_err_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_1}
if [regexp {/tb/dut/m_tx_en_1} [find signals /tb/dut/m_tx_en_1]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_1}
if [regexp {/tb/dut/m_tx_d_1} [find signals /tb/dut/m_tx_d_1]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_1}
if [regexp {/tb/dut/mii_tx_err_1} [find signals /tb/dut/mii_tx_err_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_1}
if [regexp {/tb/dut/mii_tx_en_1} [find signals /tb/dut/mii_tx_en_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_1}
if [regexp {/tb/dut/mii_tx_d_1} [find signals /tb/dut/mii_tx_d_1]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_1}

if [regexp {/tb/dut/m_tx_d_2} [find signals /tb/dut/m_tx_d_2]]                  {add wave -noupdate -divider {  MII TX 2}}
if [regexp {/tb/dut/mii_tx_d_2} [find signals /tb/dut/mii_tx_d_2]]              {add wave -noupdate -divider {  MII TX 2}}
if [regexp {/tb/dut/tx_clk_2} [find signals /tb/dut/tx_clk_2]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_2}
if [regexp {/tb/dut/m_tx_err_2} [find signals /tb/dut/m_tx_err_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_2}
if [regexp {/tb/dut/m_tx_en_2} [find signals /tb/dut/m_tx_en_2]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_2}
if [regexp {/tb/dut/m_tx_d_2} [find signals /tb/dut/m_tx_d_2]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_2}
if [regexp {/tb/dut/mii_tx_err_2} [find signals /tb/dut/mii_tx_err_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_2}
if [regexp {/tb/dut/mii_tx_en_2} [find signals /tb/dut/mii_tx_en_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_2}
if [regexp {/tb/dut/mii_tx_d_2} [find signals /tb/dut/mii_tx_d_2]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_2}

if [regexp {/tb/dut/m_tx_d_3} [find signals /tb/dut/m_tx_d_3]]                  {add wave -noupdate -divider {  MII TX 3}}
if [regexp {/tb/dut/mii_tx_d_3} [find signals /tb/dut/mii_tx_d_3]]              {add wave -noupdate -divider {  MII TX 3}}
if [regexp {/tb/dut/tx_clk_3} [find signals /tb/dut/tx_clk_3]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_3}
if [regexp {/tb/dut/m_tx_err_3} [find signals /tb/dut/m_tx_err_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_3}
if [regexp {/tb/dut/m_tx_en_3} [find signals /tb/dut/m_tx_en_3]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_3}
if [regexp {/tb/dut/m_tx_d_3} [find signals /tb/dut/m_tx_d_3]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_3}
if [regexp {/tb/dut/mii_tx_err_3} [find signals /tb/dut/mii_tx_err_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_3}
if [regexp {/tb/dut/mii_tx_en_3} [find signals /tb/dut/mii_tx_en_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_3}
if [regexp {/tb/dut/mii_tx_d_3} [find signals /tb/dut/mii_tx_d_3]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_3}

if [regexp {/tb/dut/m_tx_d_4} [find signals /tb/dut/m_tx_d_4]]                  {add wave -noupdate -divider {  MII TX 4}}
if [regexp {/tb/dut/mii_tx_d_4} [find signals /tb/dut/mii_tx_d_4]]              {add wave -noupdate -divider {  MII TX 4}}
if [regexp {/tb/dut/tx_clk_4} [find signals /tb/dut/tx_clk_4]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_4}
if [regexp {/tb/dut/m_tx_err_4} [find signals /tb/dut/m_tx_err_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_4}
if [regexp {/tb/dut/m_tx_en_4} [find signals /tb/dut/m_tx_en_4]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_4}
if [regexp {/tb/dut/m_tx_d_4} [find signals /tb/dut/m_tx_d_4]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_4}
if [regexp {/tb/dut/mii_tx_err_4} [find signals /tb/dut/mii_tx_err_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_4}
if [regexp {/tb/dut/mii_tx_en_4} [find signals /tb/dut/mii_tx_en_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_4}
if [regexp {/tb/dut/mii_tx_d_4} [find signals /tb/dut/mii_tx_d_4]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_4}

if [regexp {/tb/dut/m_tx_d_5} [find signals /tb/dut/m_tx_d_5]]                  {add wave -noupdate -divider {  MII TX 5}}
if [regexp {/tb/dut/mii_tx_d_5} [find signals /tb/dut/mii_tx_d_5]]              {add wave -noupdate -divider {  MII TX 5}}
if [regexp {/tb/dut/tx_clk_5} [find signals /tb/dut/tx_clk_5]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_5}
if [regexp {/tb/dut/m_tx_err_5} [find signals /tb/dut/m_tx_err_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_5}
if [regexp {/tb/dut/m_tx_en_5} [find signals /tb/dut/m_tx_en_5]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_5}
if [regexp {/tb/dut/m_tx_d_5} [find signals /tb/dut/m_tx_d_5]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_5}
if [regexp {/tb/dut/mii_tx_err_5} [find signals /tb/dut/mii_tx_err_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_5}
if [regexp {/tb/dut/mii_tx_en_5} [find signals /tb/dut/mii_tx_en_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_5}
if [regexp {/tb/dut/mii_tx_d_5} [find signals /tb/dut/mii_tx_d_5]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_5}

if [regexp {/tb/dut/m_tx_d_6} [find signals /tb/dut/m_tx_d_6]]                  {add wave -noupdate -divider {  MII TX 6}}
if [regexp {/tb/dut/mii_tx_d_6} [find signals /tb/dut/mii_tx_d_6]]              {add wave -noupdate -divider {  MII TX 6}}
if [regexp {/tb/dut/tx_clk_6} [find signals /tb/dut/tx_clk_6]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_6}
if [regexp {/tb/dut/m_tx_err_6} [find signals /tb/dut/m_tx_err_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_6}
if [regexp {/tb/dut/m_tx_en_6} [find signals /tb/dut/m_tx_en_6]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_6}
if [regexp {/tb/dut/m_tx_d_6} [find signals /tb/dut/m_tx_d_6]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_6}
if [regexp {/tb/dut/mii_tx_err_6} [find signals /tb/dut/mii_tx_err_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_6}
if [regexp {/tb/dut/mii_tx_en_6} [find signals /tb/dut/mii_tx_en_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_6}
if [regexp {/tb/dut/mii_tx_d_6} [find signals /tb/dut/mii_tx_d_6]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_6}

if [regexp {/tb/dut/m_tx_d_7} [find signals /tb/dut/m_tx_d_7]]                  {add wave -noupdate -divider {  MII TX 7}}
if [regexp {/tb/dut/mii_tx_d_7} [find signals /tb/dut/mii_tx_d_7]]              {add wave -noupdate -divider {  MII TX 7}}
if [regexp {/tb/dut/tx_clk_7} [find signals /tb/dut/tx_clk_7]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_7}
if [regexp {/tb/dut/m_tx_err_7} [find signals /tb/dut/m_tx_err_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_7}
if [regexp {/tb/dut/m_tx_en_7} [find signals /tb/dut/m_tx_en_7]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_7}
if [regexp {/tb/dut/m_tx_d_7} [find signals /tb/dut/m_tx_d_7]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_7}
if [regexp {/tb/dut/mii_tx_err_7} [find signals /tb/dut/mii_tx_err_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_7}
if [regexp {/tb/dut/mii_tx_en_7} [find signals /tb/dut/mii_tx_en_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_7}
if [regexp {/tb/dut/mii_tx_d_7} [find signals /tb/dut/mii_tx_d_7]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_7}

if [regexp {/tb/dut/m_tx_d_8} [find signals /tb/dut/m_tx_d_8]]                  {add wave -noupdate -divider {  MII TX 8}}
if [regexp {/tb/dut/mii_tx_d_8} [find signals /tb/dut/mii_tx_d_8]]              {add wave -noupdate -divider {  MII TX 8}}
if [regexp {/tb/dut/tx_clk_8} [find signals /tb/dut/tx_clk_8]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_8}
if [regexp {/tb/dut/m_tx_err_8} [find signals /tb/dut/m_tx_err_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_8}
if [regexp {/tb/dut/m_tx_en_8} [find signals /tb/dut/m_tx_en_8]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_8}
if [regexp {/tb/dut/m_tx_d_8} [find signals /tb/dut/m_tx_d_8]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_8}
if [regexp {/tb/dut/mii_tx_err_8} [find signals /tb/dut/mii_tx_err_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_8}
if [regexp {/tb/dut/mii_tx_en_8} [find signals /tb/dut/mii_tx_en_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_8}
if [regexp {/tb/dut/mii_tx_d_8} [find signals /tb/dut/mii_tx_d_8]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_8}

if [regexp {/tb/dut/m_tx_d_9} [find signals /tb/dut/m_tx_d_9]]                  {add wave -noupdate -divider {  MII TX 9}}
if [regexp {/tb/dut/mii_tx_d_9} [find signals /tb/dut/mii_tx_d_9]]              {add wave -noupdate -divider {  MII TX 9}}
if [regexp {/tb/dut/tx_clk_9} [find signals /tb/dut/tx_clk_9]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_9}
if [regexp {/tb/dut/m_tx_err_9} [find signals /tb/dut/m_tx_err_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_9}
if [regexp {/tb/dut/m_tx_en_9} [find signals /tb/dut/m_tx_en_9]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_9}
if [regexp {/tb/dut/m_tx_d_9} [find signals /tb/dut/m_tx_d_9]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_9}
if [regexp {/tb/dut/mii_tx_err_9} [find signals /tb/dut/mii_tx_err_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_9}
if [regexp {/tb/dut/mii_tx_en_9} [find signals /tb/dut/mii_tx_en_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_9}
if [regexp {/tb/dut/mii_tx_d_9} [find signals /tb/dut/mii_tx_d_9]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_9}

if [regexp {/tb/dut/m_tx_d_10} [find signals /tb/dut/m_tx_d_10]]                  {add wave -noupdate -divider {  MII TX 10}}
if [regexp {/tb/dut/mii_tx_d_10} [find signals /tb/dut/mii_tx_d_10]]              {add wave -noupdate -divider {  MII TX 10}}
if [regexp {/tb/dut/tx_clk_10} [find signals /tb/dut/tx_clk_10]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_10}
if [regexp {/tb/dut/m_tx_err_10} [find signals /tb/dut/m_tx_err_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_10}
if [regexp {/tb/dut/m_tx_en_10} [find signals /tb/dut/m_tx_en_10]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_10}
if [regexp {/tb/dut/m_tx_d_10} [find signals /tb/dut/m_tx_d_10]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_10}
if [regexp {/tb/dut/mii_tx_err_10} [find signals /tb/dut/mii_tx_err_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_10}
if [regexp {/tb/dut/mii_tx_en_10} [find signals /tb/dut/mii_tx_en_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_10}
if [regexp {/tb/dut/mii_tx_d_10} [find signals /tb/dut/mii_tx_d_10]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_10}

if [regexp {/tb/dut/m_tx_d_11} [find signals /tb/dut/m_tx_d_11]]                  {add wave -noupdate -divider {  MII TX 11}}
if [regexp {/tb/dut/mii_tx_d_11} [find signals /tb/dut/mii_tx_d_11]]              {add wave -noupdate -divider {  MII TX 11}}
if [regexp {/tb/dut/tx_clk_11} [find signals /tb/dut/tx_clk_11]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_11}
if [regexp {/tb/dut/m_tx_err_11} [find signals /tb/dut/m_tx_err_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_11}
if [regexp {/tb/dut/m_tx_en_11} [find signals /tb/dut/m_tx_en_11]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_11}
if [regexp {/tb/dut/m_tx_d_11} [find signals /tb/dut/m_tx_d_11]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_11}
if [regexp {/tb/dut/mii_tx_err_11} [find signals /tb/dut/mii_tx_err_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_11}
if [regexp {/tb/dut/mii_tx_en_11} [find signals /tb/dut/mii_tx_en_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_11}
if [regexp {/tb/dut/mii_tx_d_11} [find signals /tb/dut/mii_tx_d_11]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_11}

if [regexp {/tb/dut/m_tx_d_12} [find signals /tb/dut/m_tx_d_12]]                  {add wave -noupdate -divider {  MII TX 12}}
if [regexp {/tb/dut/mii_tx_d_12} [find signals /tb/dut/mii_tx_d_12]]              {add wave -noupdate -divider {  MII TX 12}}
if [regexp {/tb/dut/tx_clk_12} [find signals /tb/dut/tx_clk_12]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_12}
if [regexp {/tb/dut/m_tx_err_12} [find signals /tb/dut/m_tx_err_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_12}
if [regexp {/tb/dut/m_tx_en_12} [find signals /tb/dut/m_tx_en_12]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_12}
if [regexp {/tb/dut/m_tx_d_12} [find signals /tb/dut/m_tx_d_12]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_12}
if [regexp {/tb/dut/mii_tx_err_12} [find signals /tb/dut/mii_tx_err_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_12}
if [regexp {/tb/dut/mii_tx_en_12} [find signals /tb/dut/mii_tx_en_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_12}
if [regexp {/tb/dut/mii_tx_d_12} [find signals /tb/dut/mii_tx_d_12]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_12}

if [regexp {/tb/dut/m_tx_d_13} [find signals /tb/dut/m_tx_d_13]]                  {add wave -noupdate -divider {  MII TX 13}}
if [regexp {/tb/dut/mii_tx_d_13} [find signals /tb/dut/mii_tx_d_13]]              {add wave -noupdate -divider {  MII TX 13}}
if [regexp {/tb/dut/tx_clk_13} [find signals /tb/dut/tx_clk_13]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_13}
if [regexp {/tb/dut/m_tx_err_13} [find signals /tb/dut/m_tx_err_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_13}
if [regexp {/tb/dut/m_tx_en_13} [find signals /tb/dut/m_tx_en_13]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_13}
if [regexp {/tb/dut/m_tx_d_13} [find signals /tb/dut/m_tx_d_13]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_13}
if [regexp {/tb/dut/mii_tx_err_13} [find signals /tb/dut/mii_tx_err_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_13}
if [regexp {/tb/dut/mii_tx_en_13} [find signals /tb/dut/mii_tx_en_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_13}
if [regexp {/tb/dut/mii_tx_d_13} [find signals /tb/dut/mii_tx_d_13]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_13}

if [regexp {/tb/dut/m_tx_d_14} [find signals /tb/dut/m_tx_d_14]]                  {add wave -noupdate -divider {  MII TX 14}}
if [regexp {/tb/dut/mii_tx_d_14} [find signals /tb/dut/mii_tx_d_14]]              {add wave -noupdate -divider {  MII TX 14}}
if [regexp {/tb/dut/tx_clk_14} [find signals /tb/dut/tx_clk_14]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_14}
if [regexp {/tb/dut/m_tx_err_14} [find signals /tb/dut/m_tx_err_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_14}
if [regexp {/tb/dut/m_tx_en_14} [find signals /tb/dut/m_tx_en_14]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_14}
if [regexp {/tb/dut/m_tx_d_14} [find signals /tb/dut/m_tx_d_14]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_14}
if [regexp {/tb/dut/mii_tx_err_14} [find signals /tb/dut/mii_tx_err_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_14}
if [regexp {/tb/dut/mii_tx_en_14} [find signals /tb/dut/mii_tx_en_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_14}
if [regexp {/tb/dut/mii_tx_d_14} [find signals /tb/dut/mii_tx_d_14]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_14}

if [regexp {/tb/dut/m_tx_d_15} [find signals /tb/dut/m_tx_d_15]]                  {add wave -noupdate -divider {  MII TX 15}}
if [regexp {/tb/dut/mii_tx_d_15} [find signals /tb/dut/mii_tx_d_15]]              {add wave -noupdate -divider {  MII TX 15}}
if [regexp {/tb/dut/tx_clk_15} [find signals /tb/dut/tx_clk_15]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_15}
if [regexp {/tb/dut/m_tx_err_15} [find signals /tb/dut/m_tx_err_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_15}
if [regexp {/tb/dut/m_tx_en_15} [find signals /tb/dut/m_tx_en_15]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_15}
if [regexp {/tb/dut/m_tx_d_15} [find signals /tb/dut/m_tx_d_15]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_15}
if [regexp {/tb/dut/mii_tx_err_15} [find signals /tb/dut/mii_tx_err_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_15}
if [regexp {/tb/dut/mii_tx_en_15} [find signals /tb/dut/mii_tx_en_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_15}
if [regexp {/tb/dut/mii_tx_d_15} [find signals /tb/dut/mii_tx_d_15]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_15}

if [regexp {/tb/dut/m_tx_d_16} [find signals /tb/dut/m_tx_d_16]]                  {add wave -noupdate -divider {  MII TX 16}}
if [regexp {/tb/dut/mii_tx_d_16} [find signals /tb/dut/mii_tx_d_16]]              {add wave -noupdate -divider {  MII TX 16}}
if [regexp {/tb/dut/tx_clk_16} [find signals /tb/dut/tx_clk_16]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_16}
if [regexp {/tb/dut/m_tx_err_16} [find signals /tb/dut/m_tx_err_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_16}
if [regexp {/tb/dut/m_tx_en_16} [find signals /tb/dut/m_tx_en_16]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_16}
if [regexp {/tb/dut/m_tx_d_16} [find signals /tb/dut/m_tx_d_16]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_16}
if [regexp {/tb/dut/mii_tx_err_16} [find signals /tb/dut/mii_tx_err_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_16}
if [regexp {/tb/dut/mii_tx_en_16} [find signals /tb/dut/mii_tx_en_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_16}
if [regexp {/tb/dut/mii_tx_d_16} [find signals /tb/dut/mii_tx_d_16]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_16}

if [regexp {/tb/dut/m_tx_d_17} [find signals /tb/dut/m_tx_d_17]]                  {add wave -noupdate -divider {  MII TX 17}}
if [regexp {/tb/dut/mii_tx_d_17} [find signals /tb/dut/mii_tx_d_17]]              {add wave -noupdate -divider {  MII TX 17}}
if [regexp {/tb/dut/tx_clk_17} [find signals /tb/dut/tx_clk_17]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_17}
if [regexp {/tb/dut/m_tx_err_17} [find signals /tb/dut/m_tx_err_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_17}
if [regexp {/tb/dut/m_tx_en_17} [find signals /tb/dut/m_tx_en_17]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_17}
if [regexp {/tb/dut/m_tx_d_17} [find signals /tb/dut/m_tx_d_17]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_17}
if [regexp {/tb/dut/mii_tx_err_17} [find signals /tb/dut/mii_tx_err_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_17}
if [regexp {/tb/dut/mii_tx_en_17} [find signals /tb/dut/mii_tx_en_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_17}
if [regexp {/tb/dut/mii_tx_d_17} [find signals /tb/dut/mii_tx_d_17]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_17}

if [regexp {/tb/dut/m_tx_d_18} [find signals /tb/dut/m_tx_d_18]]                  {add wave -noupdate -divider {  MII TX 18}}
if [regexp {/tb/dut/mii_tx_d_18} [find signals /tb/dut/mii_tx_d_18]]              {add wave -noupdate -divider {  MII TX 18}}
if [regexp {/tb/dut/tx_clk_18} [find signals /tb/dut/tx_clk_18]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_18}
if [regexp {/tb/dut/m_tx_err_18} [find signals /tb/dut/m_tx_err_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_18}
if [regexp {/tb/dut/m_tx_en_18} [find signals /tb/dut/m_tx_en_18]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_18}
if [regexp {/tb/dut/m_tx_d_18} [find signals /tb/dut/m_tx_d_18]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_18}
if [regexp {/tb/dut/mii_tx_err_18} [find signals /tb/dut/mii_tx_err_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_18}
if [regexp {/tb/dut/mii_tx_en_18} [find signals /tb/dut/mii_tx_en_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_18}
if [regexp {/tb/dut/mii_tx_d_18} [find signals /tb/dut/mii_tx_d_18]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_18}

if [regexp {/tb/dut/m_tx_d_19} [find signals /tb/dut/m_tx_d_19]]                  {add wave -noupdate -divider {  MII TX 19}}
if [regexp {/tb/dut/mii_tx_d_19} [find signals /tb/dut/mii_tx_d_19]]              {add wave -noupdate -divider {  MII TX 19}}
if [regexp {/tb/dut/tx_clk_19} [find signals /tb/dut/tx_clk_19]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_19}
if [regexp {/tb/dut/m_tx_err_19} [find signals /tb/dut/m_tx_err_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_19}
if [regexp {/tb/dut/m_tx_en_19} [find signals /tb/dut/m_tx_en_19]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_19}
if [regexp {/tb/dut/m_tx_d_19} [find signals /tb/dut/m_tx_d_19]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_19}
if [regexp {/tb/dut/mii_tx_err_19} [find signals /tb/dut/mii_tx_err_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_19}
if [regexp {/tb/dut/mii_tx_en_19} [find signals /tb/dut/mii_tx_en_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_19}
if [regexp {/tb/dut/mii_tx_d_19} [find signals /tb/dut/mii_tx_d_19]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_19}

if [regexp {/tb/dut/m_tx_d_20} [find signals /tb/dut/m_tx_d_20]]                  {add wave -noupdate -divider {  MII TX 20}}
if [regexp {/tb/dut/mii_tx_d_20} [find signals /tb/dut/mii_tx_d_20]]              {add wave -noupdate -divider {  MII TX 20}}
if [regexp {/tb/dut/tx_clk_20} [find signals /tb/dut/tx_clk_20]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_20}
if [regexp {/tb/dut/m_tx_err_20} [find signals /tb/dut/m_tx_err_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_20}
if [regexp {/tb/dut/m_tx_en_20} [find signals /tb/dut/m_tx_en_20]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_20}
if [regexp {/tb/dut/m_tx_d_20} [find signals /tb/dut/m_tx_d_20]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_20}
if [regexp {/tb/dut/mii_tx_err_20} [find signals /tb/dut/mii_tx_err_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_20}
if [regexp {/tb/dut/mii_tx_en_20} [find signals /tb/dut/mii_tx_en_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_20}
if [regexp {/tb/dut/mii_tx_d_20} [find signals /tb/dut/mii_tx_d_20]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_20}

if [regexp {/tb/dut/m_tx_d_21} [find signals /tb/dut/m_tx_d_21]]                  {add wave -noupdate -divider {  MII TX 21}}
if [regexp {/tb/dut/mii_tx_d_21} [find signals /tb/dut/mii_tx_d_21]]              {add wave -noupdate -divider {  MII TX 21}}
if [regexp {/tb/dut/tx_clk_21} [find signals /tb/dut/tx_clk_21]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_21}
if [regexp {/tb/dut/m_tx_err_21} [find signals /tb/dut/m_tx_err_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_21}
if [regexp {/tb/dut/m_tx_en_21} [find signals /tb/dut/m_tx_en_21]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_21}
if [regexp {/tb/dut/m_tx_d_21} [find signals /tb/dut/m_tx_d_21]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_21}
if [regexp {/tb/dut/mii_tx_err_21} [find signals /tb/dut/mii_tx_err_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_21}
if [regexp {/tb/dut/mii_tx_en_21} [find signals /tb/dut/mii_tx_en_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_21}
if [regexp {/tb/dut/mii_tx_d_21} [find signals /tb/dut/mii_tx_d_21]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_21}

if [regexp {/tb/dut/m_tx_d_22} [find signals /tb/dut/m_tx_d_22]]                  {add wave -noupdate -divider {  MII TX 22}}
if [regexp {/tb/dut/mii_tx_d_22} [find signals /tb/dut/mii_tx_d_22]]              {add wave -noupdate -divider {  MII TX 22}}
if [regexp {/tb/dut/tx_clk_22} [find signals /tb/dut/tx_clk_22]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_22}
if [regexp {/tb/dut/m_tx_err_22} [find signals /tb/dut/m_tx_err_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_22}
if [regexp {/tb/dut/m_tx_en_22} [find signals /tb/dut/m_tx_en_22]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_22}
if [regexp {/tb/dut/m_tx_d_22} [find signals /tb/dut/m_tx_d_22]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_22}
if [regexp {/tb/dut/mii_tx_err_22} [find signals /tb/dut/mii_tx_err_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_22}
if [regexp {/tb/dut/mii_tx_en_22} [find signals /tb/dut/mii_tx_en_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_22}
if [regexp {/tb/dut/mii_tx_d_22} [find signals /tb/dut/mii_tx_d_22]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_22}

if [regexp {/tb/dut/m_tx_d_23} [find signals /tb/dut/m_tx_d_23]]                  {add wave -noupdate -divider {  MII TX 23}}
if [regexp {/tb/dut/mii_tx_d_23} [find signals /tb/dut/mii_tx_d_23]]              {add wave -noupdate -divider {  MII TX 23}}
if [regexp {/tb/dut/tx_clk_23} [find signals /tb/dut/tx_clk_23]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tx_clk_23}
if [regexp {/tb/dut/m_tx_err_23} [find signals /tb/dut/m_tx_err_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_err_23}
if [regexp {/tb/dut/m_tx_en_23} [find signals /tb/dut/m_tx_en_23]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/m_tx_en_23}
if [regexp {/tb/dut/m_tx_d_23} [find signals /tb/dut/m_tx_d_23]]                  {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/m_tx_d_23}
if [regexp {/tb/dut/mii_tx_err_23} [find signals /tb/dut/mii_tx_err_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_err_23}
if [regexp {/tb/dut/mii_tx_en_23} [find signals /tb/dut/mii_tx_en_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mii_tx_en_23}
if [regexp {/tb/dut/mii_tx_d_23} [find signals /tb/dut/mii_tx_d_23]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/mii_tx_d_23}


if [regexp {/tb/dut/tbi_tx_d} [find signals /tb/dut/tbi_tx_d]]              {add wave -noupdate -divider {  PMA TBI TX}}
if [regexp {/tb/dut/tbi_tx_clk} [find signals /tb/dut/tbi_tx_clk]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk}
if [regexp {/tb/dut/tbi_tx_d} [find signals /tb/dut/tbi_tx_d]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d}

if [regexp {/tb/dut/tbi_tx_d_0} [find signals /tb/dut/tbi_tx_d_0]]              {add wave -noupdate -divider {  PMA TBI TX 0}}
if [regexp {/tb/dut/tbi_tx_clk_0} [find signals /tb/dut/tbi_tx_clk_0]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_0}
if [regexp {/tb/dut/tbi_tx_d_0} [find signals /tb/dut/tbi_tx_d_0]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_0}

if [regexp {/tb/dut/tbi_tx_d_1} [find signals /tb/dut/tbi_tx_d_1]]              {add wave -noupdate -divider {  PMA TBI TX 1}}
if [regexp {/tb/dut/tbi_tx_clk_1} [find signals /tb/dut/tbi_tx_clk_1]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_1}
if [regexp {/tb/dut/tbi_tx_d_1} [find signals /tb/dut/tbi_tx_d_1]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_1}

if [regexp {/tb/dut/tbi_tx_d_2} [find signals /tb/dut/tbi_tx_d_2]]              {add wave -noupdate -divider {  PMA TBI TX 2}}
if [regexp {/tb/dut/tbi_tx_clk_2} [find signals /tb/dut/tbi_tx_clk_2]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_2}
if [regexp {/tb/dut/tbi_tx_d_2} [find signals /tb/dut/tbi_tx_d_2]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_2}

if [regexp {/tb/dut/tbi_tx_d_3} [find signals /tb/dut/tbi_tx_d_3]]              {add wave -noupdate -divider {  PMA TBI TX 3}}
if [regexp {/tb/dut/tbi_tx_clk_3} [find signals /tb/dut/tbi_tx_clk_3]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_3}
if [regexp {/tb/dut/tbi_tx_d_3} [find signals /tb/dut/tbi_tx_d_3]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_3}

if [regexp {/tb/dut/tbi_tx_d_4} [find signals /tb/dut/tbi_tx_d_4]]              {add wave -noupdate -divider {  PMA TBI TX 4}}
if [regexp {/tb/dut/tbi_tx_clk_4} [find signals /tb/dut/tbi_tx_clk_4]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_4}
if [regexp {/tb/dut/tbi_tx_d_4} [find signals /tb/dut/tbi_tx_d_4]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_4}

if [regexp {/tb/dut/tbi_tx_d_5} [find signals /tb/dut/tbi_tx_d_5]]              {add wave -noupdate -divider {  PMA TBI TX 5}}
if [regexp {/tb/dut/tbi_tx_clk_5} [find signals /tb/dut/tbi_tx_clk_5]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_5}
if [regexp {/tb/dut/tbi_tx_d_5} [find signals /tb/dut/tbi_tx_d_5]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_5}

if [regexp {/tb/dut/tbi_tx_d_6} [find signals /tb/dut/tbi_tx_d_6]]              {add wave -noupdate -divider {  PMA TBI TX 6}}
if [regexp {/tb/dut/tbi_tx_clk_6} [find signals /tb/dut/tbi_tx_clk_6]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_6}
if [regexp {/tb/dut/tbi_tx_d_6} [find signals /tb/dut/tbi_tx_d_6]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_6}

if [regexp {/tb/dut/tbi_tx_d_7} [find signals /tb/dut/tbi_tx_d_7]]              {add wave -noupdate -divider {  PMA TBI TX 7}}
if [regexp {/tb/dut/tbi_tx_clk_7} [find signals /tb/dut/tbi_tx_clk_7]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_7}
if [regexp {/tb/dut/tbi_tx_d_7} [find signals /tb/dut/tbi_tx_d_7]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_7}

if [regexp {/tb/dut/tbi_tx_d_8} [find signals /tb/dut/tbi_tx_d_8]]              {add wave -noupdate -divider {  PMA TBI TX 8}}
if [regexp {/tb/dut/tbi_tx_clk_8} [find signals /tb/dut/tbi_tx_clk_8]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_8}
if [regexp {/tb/dut/tbi_tx_d_8} [find signals /tb/dut/tbi_tx_d_8]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_8}

if [regexp {/tb/dut/tbi_tx_d_9} [find signals /tb/dut/tbi_tx_d_9]]              {add wave -noupdate -divider {  PMA TBI TX 9}}
if [regexp {/tb/dut/tbi_tx_clk_9} [find signals /tb/dut/tbi_tx_clk_9]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_9}
if [regexp {/tb/dut/tbi_tx_d_9} [find signals /tb/dut/tbi_tx_d_9]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_9}

if [regexp {/tb/dut/tbi_tx_d_10} [find signals /tb/dut/tbi_tx_d_10]]              {add wave -noupdate -divider {  PMA TBI TX 10}}
if [regexp {/tb/dut/tbi_tx_clk_10} [find signals /tb/dut/tbi_tx_clk_10]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_10}
if [regexp {/tb/dut/tbi_tx_d_10} [find signals /tb/dut/tbi_tx_d_10]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_10}

if [regexp {/tb/dut/tbi_tx_d_11} [find signals /tb/dut/tbi_tx_d_11]]              {add wave -noupdate -divider {  PMA TBI TX 11}}
if [regexp {/tb/dut/tbi_tx_clk_11} [find signals /tb/dut/tbi_tx_clk_11]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_11}
if [regexp {/tb/dut/tbi_tx_d_11} [find signals /tb/dut/tbi_tx_d_11]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_11}

if [regexp {/tb/dut/tbi_tx_d_12} [find signals /tb/dut/tbi_tx_d_12]]              {add wave -noupdate -divider {  PMA TBI TX 12}}
if [regexp {/tb/dut/tbi_tx_clk_12} [find signals /tb/dut/tbi_tx_clk_12]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_12}
if [regexp {/tb/dut/tbi_tx_d_12} [find signals /tb/dut/tbi_tx_d_12]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_12}

if [regexp {/tb/dut/tbi_tx_d_13} [find signals /tb/dut/tbi_tx_d_13]]              {add wave -noupdate -divider {  PMA TBI TX 13}}
if [regexp {/tb/dut/tbi_tx_clk_13} [find signals /tb/dut/tbi_tx_clk_13]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_13}
if [regexp {/tb/dut/tbi_tx_d_13} [find signals /tb/dut/tbi_tx_d_13]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_13}

if [regexp {/tb/dut/tbi_tx_d_14} [find signals /tb/dut/tbi_tx_d_14]]              {add wave -noupdate -divider {  PMA TBI TX 14}}
if [regexp {/tb/dut/tbi_tx_clk_14} [find signals /tb/dut/tbi_tx_clk_14]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_14}
if [regexp {/tb/dut/tbi_tx_d_14} [find signals /tb/dut/tbi_tx_d_14]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_14}

if [regexp {/tb/dut/tbi_tx_d_15} [find signals /tb/dut/tbi_tx_d_15]]              {add wave -noupdate -divider {  PMA TBI TX 15}}
if [regexp {/tb/dut/tbi_tx_clk_15} [find signals /tb/dut/tbi_tx_clk_15]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_15}
if [regexp {/tb/dut/tbi_tx_d_15} [find signals /tb/dut/tbi_tx_d_15]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_15}

if [regexp {/tb/dut/tbi_tx_d_16} [find signals /tb/dut/tbi_tx_d_16]]              {add wave -noupdate -divider {  PMA TBI TX 16}}
if [regexp {/tb/dut/tbi_tx_clk_16} [find signals /tb/dut/tbi_tx_clk_16]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_16}
if [regexp {/tb/dut/tbi_tx_d_16} [find signals /tb/dut/tbi_tx_d_16]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_16}

if [regexp {/tb/dut/tbi_tx_d_17} [find signals /tb/dut/tbi_tx_d_17]]              {add wave -noupdate -divider {  PMA TBI TX 17}}
if [regexp {/tb/dut/tbi_tx_clk_17} [find signals /tb/dut/tbi_tx_clk_17]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_17}
if [regexp {/tb/dut/tbi_tx_d_17} [find signals /tb/dut/tbi_tx_d_17]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_17}

if [regexp {/tb/dut/tbi_tx_d_18} [find signals /tb/dut/tbi_tx_d_18]]              {add wave -noupdate -divider {  PMA TBI TX 18}}
if [regexp {/tb/dut/tbi_tx_clk_18} [find signals /tb/dut/tbi_tx_clk_18]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_18}
if [regexp {/tb/dut/tbi_tx_d_18} [find signals /tb/dut/tbi_tx_d_18]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_18}

if [regexp {/tb/dut/tbi_tx_d_19} [find signals /tb/dut/tbi_tx_d_19]]              {add wave -noupdate -divider {  PMA TBI TX 19}}
if [regexp {/tb/dut/tbi_tx_clk_19} [find signals /tb/dut/tbi_tx_clk_19]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_19}
if [regexp {/tb/dut/tbi_tx_d_19} [find signals /tb/dut/tbi_tx_d_19]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_19}

if [regexp {/tb/dut/tbi_tx_d_20} [find signals /tb/dut/tbi_tx_d_20]]              {add wave -noupdate -divider {  PMA TBI TX 20}}
if [regexp {/tb/dut/tbi_tx_clk_20} [find signals /tb/dut/tbi_tx_clk_20]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_20}
if [regexp {/tb/dut/tbi_tx_d_20} [find signals /tb/dut/tbi_tx_d_20]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_20}

if [regexp {/tb/dut/tbi_tx_d_21} [find signals /tb/dut/tbi_tx_d_21]]              {add wave -noupdate -divider {  PMA TBI TX 21}}
if [regexp {/tb/dut/tbi_tx_clk_21} [find signals /tb/dut/tbi_tx_clk_21]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_21}
if [regexp {/tb/dut/tbi_tx_d_21} [find signals /tb/dut/tbi_tx_d_21]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_21}

if [regexp {/tb/dut/tbi_tx_d_22} [find signals /tb/dut/tbi_tx_d_22]]              {add wave -noupdate -divider {  PMA TBI TX 22}}
if [regexp {/tb/dut/tbi_tx_clk_22} [find signals /tb/dut/tbi_tx_clk_22]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_22}
if [regexp {/tb/dut/tbi_tx_d_22} [find signals /tb/dut/tbi_tx_d_22]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_22}

if [regexp {/tb/dut/tbi_tx_d_23} [find signals /tb/dut/tbi_tx_d_23]]              {add wave -noupdate -divider {  PMA TBI TX 23}}
if [regexp {/tb/dut/tbi_tx_clk_23} [find signals /tb/dut/tbi_tx_clk_23]]          {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/tbi_tx_clk_23}
if [regexp {/tb/dut/tbi_tx_d_23} [find signals /tb/dut/tbi_tx_d_23]]              {add wave -noupdate -format Literal -radix hexadecimal /tb/dut/tbi_tx_d_23}

if [regexp {/tb/dut/txp} [find signals /tb/dut/txp]]                        {add wave -noupdate -divider {  PMA SERIAL TX}}
if [regexp {/tb/dut/txp} [find signals /tb/dut/txp]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp}

if [regexp {/tb/dut/txp_0} [find signals /tb/dut/txp_0]]                        {add wave -noupdate -divider {  PMA SERIAL TX 0}}
if [regexp {/tb/dut/txp_0} [find signals /tb/dut/txp_0]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_0}

if [regexp {/tb/dut/txp_1} [find signals /tb/dut/txp_1]]                        {add wave -noupdate -divider {  PMA SERIAL TX 1}}
if [regexp {/tb/dut/txp_1} [find signals /tb/dut/txp_1]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_1}

if [regexp {/tb/dut/txp_2} [find signals /tb/dut/txp_2]]                        {add wave -noupdate -divider {  PMA SERIAL TX 2}}
if [regexp {/tb/dut/txp_2} [find signals /tb/dut/txp_2]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_2}

if [regexp {/tb/dut/txp_3} [find signals /tb/dut/txp_3]]                        {add wave -noupdate -divider {  PMA SERIAL TX 3}}
if [regexp {/tb/dut/txp_3} [find signals /tb/dut/txp_3]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_3}

if [regexp {/tb/dut/txp_4} [find signals /tb/dut/txp_4]]                        {add wave -noupdate -divider {  PMA SERIAL TX 4}}
if [regexp {/tb/dut/txp_4} [find signals /tb/dut/txp_4]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_4}

if [regexp {/tb/dut/txp_5} [find signals /tb/dut/txp_5]]                        {add wave -noupdate -divider {  PMA SERIAL TX 5}}
if [regexp {/tb/dut/txp_5} [find signals /tb/dut/txp_5]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_5}

if [regexp {/tb/dut/txp_6} [find signals /tb/dut/txp_6]]                        {add wave -noupdate -divider {  PMA SERIAL TX 6}}
if [regexp {/tb/dut/txp_6} [find signals /tb/dut/txp_6]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_6}

if [regexp {/tb/dut/txp_7} [find signals /tb/dut/txp_7]]                        {add wave -noupdate -divider {  PMA SERIAL TX 7}}
if [regexp {/tb/dut/txp_7} [find signals /tb/dut/txp_7]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_7}

if [regexp {/tb/dut/txp_8} [find signals /tb/dut/txp_8]]                        {add wave -noupdate -divider {  PMA SERIAL TX 8}}
if [regexp {/tb/dut/txp_8} [find signals /tb/dut/txp_8]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_8}

if [regexp {/tb/dut/txp_9} [find signals /tb/dut/txp_9]]                        {add wave -noupdate -divider {  PMA SERIAL TX 9}}
if [regexp {/tb/dut/txp_9} [find signals /tb/dut/txp_9]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_9}

if [regexp {/tb/dut/txp_10} [find signals /tb/dut/txp_10]]                        {add wave -noupdate -divider {  PMA SERIAL TX 10}}
if [regexp {/tb/dut/txp_10} [find signals /tb/dut/txp_10]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_10}

if [regexp {/tb/dut/txp_11} [find signals /tb/dut/txp_11]]                        {add wave -noupdate -divider {  PMA SERIAL TX 11}}
if [regexp {/tb/dut/txp_11} [find signals /tb/dut/txp_11]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_11}

if [regexp {/tb/dut/txp_12} [find signals /tb/dut/txp_12]]                        {add wave -noupdate -divider {  PMA SERIAL TX 12}}
if [regexp {/tb/dut/txp_12} [find signals /tb/dut/txp_12]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_12}

if [regexp {/tb/dut/txp_13} [find signals /tb/dut/txp_13]]                        {add wave -noupdate -divider {  PMA SERIAL TX 13}}
if [regexp {/tb/dut/txp_13} [find signals /tb/dut/txp_13]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_13}

if [regexp {/tb/dut/txp_14} [find signals /tb/dut/txp_14]]                        {add wave -noupdate -divider {  PMA SERIAL TX 14}}
if [regexp {/tb/dut/txp_14} [find signals /tb/dut/txp_14]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_14}

if [regexp {/tb/dut/txp_15} [find signals /tb/dut/txp_15]]                        {add wave -noupdate -divider {  PMA SERIAL TX 15}}
if [regexp {/tb/dut/txp_15} [find signals /tb/dut/txp_15]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_15}

if [regexp {/tb/dut/txp_16} [find signals /tb/dut/txp_16]]                        {add wave -noupdate -divider {  PMA SERIAL TX 16}}
if [regexp {/tb/dut/txp_16} [find signals /tb/dut/txp_16]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_16}

if [regexp {/tb/dut/txp_17} [find signals /tb/dut/txp_17]]                        {add wave -noupdate -divider {  PMA SERIAL TX 17}}
if [regexp {/tb/dut/txp_17} [find signals /tb/dut/txp_17]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_17}

if [regexp {/tb/dut/txp_18} [find signals /tb/dut/txp_18]]                        {add wave -noupdate -divider {  PMA SERIAL TX 18}}
if [regexp {/tb/dut/txp_18} [find signals /tb/dut/txp_18]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_18}

if [regexp {/tb/dut/txp_19} [find signals /tb/dut/txp_19]]                        {add wave -noupdate -divider {  PMA SERIAL TX 19}}
if [regexp {/tb/dut/txp_19} [find signals /tb/dut/txp_19]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_19}

if [regexp {/tb/dut/txp_20} [find signals /tb/dut/txp_20]]                        {add wave -noupdate -divider {  PMA SERIAL TX 20}}
if [regexp {/tb/dut/txp_20} [find signals /tb/dut/txp_20]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_20}

if [regexp {/tb/dut/txp_21} [find signals /tb/dut/txp_21]]                        {add wave -noupdate -divider {  PMA SERIAL TX 21}}
if [regexp {/tb/dut/txp_21} [find signals /tb/dut/txp_21]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_21}

if [regexp {/tb/dut/txp_22} [find signals /tb/dut/txp_22]]                        {add wave -noupdate -divider {  PMA SERIAL TX 22}}
if [regexp {/tb/dut/txp_22} [find signals /tb/dut/txp_22]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_22}

if [regexp {/tb/dut/txp_23} [find signals /tb/dut/txp_23]]                        {add wave -noupdate -divider {  PMA SERIAL TX 23}}
if [regexp {/tb/dut/txp_23} [find signals /tb/dut/txp_23]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/txp_23}

add wave -noupdate -divider -height 40 {STATUS n MISC CONTROL}
if [regexp {/tb/dut/led_an} [find signals /tb/dut/led_an]]                  {add wave -noupdate -divider {  PHY LINK STATUS}}
if [regexp {/tb/dut/led_an} [find signals /tb/dut/led_an]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an}
if [regexp {/tb/dut/led_crs} [find signals /tb/dut/led_crs]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs}
if [regexp {/tb/dut/led_char_err} [find signals /tb/dut/led_char_err]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err}
if [regexp {/tb/dut/led_link} [find signals /tb/dut/led_link]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link}
if [regexp {/tb/dut/led_col} [find signals /tb/dut/led_col]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col}
if [regexp {/tb/dut/led_disp_err} [find signals /tb/dut/led_disp_err]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err}

if [regexp {/tb/dut/led_an_0} [find signals /tb/dut/led_an_0]]                  {add wave -noupdate -divider {  PHY LINK STATUS 0}}
if [regexp {/tb/dut/led_an_0} [find signals /tb/dut/led_an_0]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_0}
if [regexp {/tb/dut/led_crs_0} [find signals /tb/dut/led_crs_0]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_0}
if [regexp {/tb/dut/led_char_err_0} [find signals /tb/dut/led_char_err_0]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_0}
if [regexp {/tb/dut/led_link_0} [find signals /tb/dut/led_link_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_0}
if [regexp {/tb/dut/led_col_0} [find signals /tb/dut/led_col_0]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_0}
if [regexp {/tb/dut/led_disp_err_0} [find signals /tb/dut/led_disp_err_0]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_0}

if [regexp {/tb/dut/led_an_1} [find signals /tb/dut/led_an_1]]                  {add wave -noupdate -divider {  PHY LINK STATUS 1}}
if [regexp {/tb/dut/led_an_1} [find signals /tb/dut/led_an_1]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_1}
if [regexp {/tb/dut/led_crs_1} [find signals /tb/dut/led_crs_1]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_1}
if [regexp {/tb/dut/led_char_err_1} [find signals /tb/dut/led_char_err_1]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_1}
if [regexp {/tb/dut/led_link_1} [find signals /tb/dut/led_link_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_1}
if [regexp {/tb/dut/led_col_1} [find signals /tb/dut/led_col_1]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_1}
if [regexp {/tb/dut/led_disp_err_1} [find signals /tb/dut/led_disp_err_1]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_1}

if [regexp {/tb/dut/led_an_2} [find signals /tb/dut/led_an_2]]                  {add wave -noupdate -divider {  PHY LINK STATUS 2}}
if [regexp {/tb/dut/led_an_2} [find signals /tb/dut/led_an_2]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_2}
if [regexp {/tb/dut/led_crs_2} [find signals /tb/dut/led_crs_2]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_2}
if [regexp {/tb/dut/led_char_err_2} [find signals /tb/dut/led_char_err_2]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_2}
if [regexp {/tb/dut/led_link_2} [find signals /tb/dut/led_link_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_2}
if [regexp {/tb/dut/led_col_2} [find signals /tb/dut/led_col_2]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_2}
if [regexp {/tb/dut/led_disp_err_2} [find signals /tb/dut/led_disp_err_2]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_2}

if [regexp {/tb/dut/led_an_3} [find signals /tb/dut/led_an_3]]                  {add wave -noupdate -divider {  PHY LINK STATUS 3}}
if [regexp {/tb/dut/led_an_3} [find signals /tb/dut/led_an_3]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_3}
if [regexp {/tb/dut/led_crs_3} [find signals /tb/dut/led_crs_3]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_3}
if [regexp {/tb/dut/led_char_err_3} [find signals /tb/dut/led_char_err_3]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_3}
if [regexp {/tb/dut/led_link_3} [find signals /tb/dut/led_link_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_3}
if [regexp {/tb/dut/led_col_3} [find signals /tb/dut/led_col_3]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_3}
if [regexp {/tb/dut/led_disp_err_3} [find signals /tb/dut/led_disp_err_3]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_3}

if [regexp {/tb/dut/led_an_4} [find signals /tb/dut/led_an_4]]                  {add wave -noupdate -divider {  PHY LINK STATUS 4}}
if [regexp {/tb/dut/led_an_4} [find signals /tb/dut/led_an_4]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_4}
if [regexp {/tb/dut/led_crs_4} [find signals /tb/dut/led_crs_4]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_4}
if [regexp {/tb/dut/led_char_err_4} [find signals /tb/dut/led_char_err_4]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_4}
if [regexp {/tb/dut/led_link_4} [find signals /tb/dut/led_link_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_4}
if [regexp {/tb/dut/led_col_4} [find signals /tb/dut/led_col_4]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_4}
if [regexp {/tb/dut/led_disp_err_4} [find signals /tb/dut/led_disp_err_4]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_4}

if [regexp {/tb/dut/led_an_5} [find signals /tb/dut/led_an_5]]                  {add wave -noupdate -divider {  PHY LINK STATUS 5}}
if [regexp {/tb/dut/led_an_5} [find signals /tb/dut/led_an_5]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_5}
if [regexp {/tb/dut/led_crs_5} [find signals /tb/dut/led_crs_5]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_5}
if [regexp {/tb/dut/led_char_err_5} [find signals /tb/dut/led_char_err_5]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_5}
if [regexp {/tb/dut/led_link_5} [find signals /tb/dut/led_link_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_5}
if [regexp {/tb/dut/led_col_5} [find signals /tb/dut/led_col_5]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_5}
if [regexp {/tb/dut/led_disp_err_5} [find signals /tb/dut/led_disp_err_5]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_5}

if [regexp {/tb/dut/led_an_6} [find signals /tb/dut/led_an_6]]                  {add wave -noupdate -divider {  PHY LINK STATUS 6}}
if [regexp {/tb/dut/led_an_6} [find signals /tb/dut/led_an_6]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_6}
if [regexp {/tb/dut/led_crs_6} [find signals /tb/dut/led_crs_6]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_6}
if [regexp {/tb/dut/led_char_err_6} [find signals /tb/dut/led_char_err_6]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_6}
if [regexp {/tb/dut/led_link_6} [find signals /tb/dut/led_link_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_6}
if [regexp {/tb/dut/led_col_6} [find signals /tb/dut/led_col_6]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_6}
if [regexp {/tb/dut/led_disp_err_6} [find signals /tb/dut/led_disp_err_6]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_6}

if [regexp {/tb/dut/led_an_7} [find signals /tb/dut/led_an_7]]                  {add wave -noupdate -divider {  PHY LINK STATUS 7}}
if [regexp {/tb/dut/led_an_7} [find signals /tb/dut/led_an_7]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_7}
if [regexp {/tb/dut/led_crs_7} [find signals /tb/dut/led_crs_7]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_7}
if [regexp {/tb/dut/led_char_err_7} [find signals /tb/dut/led_char_err_7]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_7}
if [regexp {/tb/dut/led_link_7} [find signals /tb/dut/led_link_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_7}
if [regexp {/tb/dut/led_col_7} [find signals /tb/dut/led_col_7]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_7}
if [regexp {/tb/dut/led_disp_err_7} [find signals /tb/dut/led_disp_err_7]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_7}

if [regexp {/tb/dut/led_an_8} [find signals /tb/dut/led_an_8]]                  {add wave -noupdate -divider {  PHY LINK STATUS 8}}
if [regexp {/tb/dut/led_an_8} [find signals /tb/dut/led_an_8]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_8}
if [regexp {/tb/dut/led_crs_8} [find signals /tb/dut/led_crs_8]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_8}
if [regexp {/tb/dut/led_char_err_8} [find signals /tb/dut/led_char_err_8]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_8}
if [regexp {/tb/dut/led_link_8} [find signals /tb/dut/led_link_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_8}
if [regexp {/tb/dut/led_col_8} [find signals /tb/dut/led_col_8]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_8}
if [regexp {/tb/dut/led_disp_err_8} [find signals /tb/dut/led_disp_err_8]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_8}

if [regexp {/tb/dut/led_an_9} [find signals /tb/dut/led_an_9]]                  {add wave -noupdate -divider {  PHY LINK STATUS 9}}
if [regexp {/tb/dut/led_an_9} [find signals /tb/dut/led_an_9]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_9}
if [regexp {/tb/dut/led_crs_9} [find signals /tb/dut/led_crs_9]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_9}
if [regexp {/tb/dut/led_char_err_9} [find signals /tb/dut/led_char_err_9]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_9}
if [regexp {/tb/dut/led_link_9} [find signals /tb/dut/led_link_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_9}
if [regexp {/tb/dut/led_col_9} [find signals /tb/dut/led_col_9]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_9}
if [regexp {/tb/dut/led_disp_err_9} [find signals /tb/dut/led_disp_err_9]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_9}

if [regexp {/tb/dut/led_an_10} [find signals /tb/dut/led_an_10]]                  {add wave -noupdate -divider {  PHY LINK STATUS 10}}
if [regexp {/tb/dut/led_an_10} [find signals /tb/dut/led_an_10]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_10}
if [regexp {/tb/dut/led_crs_10} [find signals /tb/dut/led_crs_10]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_10}
if [regexp {/tb/dut/led_char_err_10} [find signals /tb/dut/led_char_err_10]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_10}
if [regexp {/tb/dut/led_link_10} [find signals /tb/dut/led_link_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_10}
if [regexp {/tb/dut/led_col_10} [find signals /tb/dut/led_col_10]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_10}
if [regexp {/tb/dut/led_disp_err_10} [find signals /tb/dut/led_disp_err_10]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_10}

if [regexp {/tb/dut/led_an_11} [find signals /tb/dut/led_an_11]]                  {add wave -noupdate -divider {  PHY LINK STATUS 11}}
if [regexp {/tb/dut/led_an_11} [find signals /tb/dut/led_an_11]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_11}
if [regexp {/tb/dut/led_crs_11} [find signals /tb/dut/led_crs_11]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_11}
if [regexp {/tb/dut/led_char_err_11} [find signals /tb/dut/led_char_err_11]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_11}
if [regexp {/tb/dut/led_link_11} [find signals /tb/dut/led_link_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_11}
if [regexp {/tb/dut/led_col_11} [find signals /tb/dut/led_col_11]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_11}
if [regexp {/tb/dut/led_disp_err_11} [find signals /tb/dut/led_disp_err_11]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_11}

if [regexp {/tb/dut/led_an_12} [find signals /tb/dut/led_an_12]]                  {add wave -noupdate -divider {  PHY LINK STATUS 12}}
if [regexp {/tb/dut/led_an_12} [find signals /tb/dut/led_an_12]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_12}
if [regexp {/tb/dut/led_crs_12} [find signals /tb/dut/led_crs_12]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_12}
if [regexp {/tb/dut/led_char_err_12} [find signals /tb/dut/led_char_err_12]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_12}
if [regexp {/tb/dut/led_link_12} [find signals /tb/dut/led_link_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_12}
if [regexp {/tb/dut/led_col_12} [find signals /tb/dut/led_col_12]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_12}
if [regexp {/tb/dut/led_disp_err_12} [find signals /tb/dut/led_disp_err_12]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_12}

if [regexp {/tb/dut/led_an_13} [find signals /tb/dut/led_an_13]]                  {add wave -noupdate -divider {  PHY LINK STATUS 13}}
if [regexp {/tb/dut/led_an_13} [find signals /tb/dut/led_an_13]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_13}
if [regexp {/tb/dut/led_crs_13} [find signals /tb/dut/led_crs_13]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_13}
if [regexp {/tb/dut/led_char_err_13} [find signals /tb/dut/led_char_err_13]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_13}
if [regexp {/tb/dut/led_link_13} [find signals /tb/dut/led_link_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_13}
if [regexp {/tb/dut/led_col_13} [find signals /tb/dut/led_col_13]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_13}
if [regexp {/tb/dut/led_disp_err_13} [find signals /tb/dut/led_disp_err_13]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_13}

if [regexp {/tb/dut/led_an_14} [find signals /tb/dut/led_an_14]]                  {add wave -noupdate -divider {  PHY LINK STATUS 14}}
if [regexp {/tb/dut/led_an_14} [find signals /tb/dut/led_an_14]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_14}
if [regexp {/tb/dut/led_crs_14} [find signals /tb/dut/led_crs_14]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_14}
if [regexp {/tb/dut/led_char_err_14} [find signals /tb/dut/led_char_err_14]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_14}
if [regexp {/tb/dut/led_link_14} [find signals /tb/dut/led_link_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_14}
if [regexp {/tb/dut/led_col_14} [find signals /tb/dut/led_col_14]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_14}
if [regexp {/tb/dut/led_disp_err_14} [find signals /tb/dut/led_disp_err_14]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_14}

if [regexp {/tb/dut/led_an_15} [find signals /tb/dut/led_an_15]]                  {add wave -noupdate -divider {  PHY LINK STATUS 15}}
if [regexp {/tb/dut/led_an_15} [find signals /tb/dut/led_an_15]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_15}
if [regexp {/tb/dut/led_crs_15} [find signals /tb/dut/led_crs_15]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_15}
if [regexp {/tb/dut/led_char_err_15} [find signals /tb/dut/led_char_err_15]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_15}
if [regexp {/tb/dut/led_link_15} [find signals /tb/dut/led_link_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_15}
if [regexp {/tb/dut/led_col_15} [find signals /tb/dut/led_col_15]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_15}
if [regexp {/tb/dut/led_disp_err_15} [find signals /tb/dut/led_disp_err_15]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_15}

if [regexp {/tb/dut/led_an_16} [find signals /tb/dut/led_an_16]]                  {add wave -noupdate -divider {  PHY LINK STATUS 16}}
if [regexp {/tb/dut/led_an_16} [find signals /tb/dut/led_an_16]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_16}
if [regexp {/tb/dut/led_crs_16} [find signals /tb/dut/led_crs_16]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_16}
if [regexp {/tb/dut/led_char_err_16} [find signals /tb/dut/led_char_err_16]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_16}
if [regexp {/tb/dut/led_link_16} [find signals /tb/dut/led_link_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_16}
if [regexp {/tb/dut/led_col_16} [find signals /tb/dut/led_col_16]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_16}
if [regexp {/tb/dut/led_disp_err_16} [find signals /tb/dut/led_disp_err_16]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_16}

if [regexp {/tb/dut/led_an_17} [find signals /tb/dut/led_an_17]]                  {add wave -noupdate -divider {  PHY LINK STATUS 17}}
if [regexp {/tb/dut/led_an_17} [find signals /tb/dut/led_an_17]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_17}
if [regexp {/tb/dut/led_crs_17} [find signals /tb/dut/led_crs_17]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_17}
if [regexp {/tb/dut/led_char_err_17} [find signals /tb/dut/led_char_err_17]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_17}
if [regexp {/tb/dut/led_link_17} [find signals /tb/dut/led_link_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_17}
if [regexp {/tb/dut/led_col_17} [find signals /tb/dut/led_col_17]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_17}
if [regexp {/tb/dut/led_disp_err_17} [find signals /tb/dut/led_disp_err_17]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_17}

if [regexp {/tb/dut/led_an_18} [find signals /tb/dut/led_an_18]]                  {add wave -noupdate -divider {  PHY LINK STATUS 18}}
if [regexp {/tb/dut/led_an_18} [find signals /tb/dut/led_an_18]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_18}
if [regexp {/tb/dut/led_crs_18} [find signals /tb/dut/led_crs_18]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_18}
if [regexp {/tb/dut/led_char_err_18} [find signals /tb/dut/led_char_err_18]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_18}
if [regexp {/tb/dut/led_link_18} [find signals /tb/dut/led_link_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_18}
if [regexp {/tb/dut/led_col_18} [find signals /tb/dut/led_col_18]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_18}
if [regexp {/tb/dut/led_disp_err_18} [find signals /tb/dut/led_disp_err_18]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_18}

if [regexp {/tb/dut/led_an_19} [find signals /tb/dut/led_an_19]]                  {add wave -noupdate -divider {  PHY LINK STATUS 19}}
if [regexp {/tb/dut/led_an_19} [find signals /tb/dut/led_an_19]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_19}
if [regexp {/tb/dut/led_crs_19} [find signals /tb/dut/led_crs_19]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_19}
if [regexp {/tb/dut/led_char_err_19} [find signals /tb/dut/led_char_err_19]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_19}
if [regexp {/tb/dut/led_link_19} [find signals /tb/dut/led_link_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_19}
if [regexp {/tb/dut/led_col_19} [find signals /tb/dut/led_col_19]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_19}
if [regexp {/tb/dut/led_disp_err_19} [find signals /tb/dut/led_disp_err_19]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_19}

if [regexp {/tb/dut/led_an_20} [find signals /tb/dut/led_an_20]]                  {add wave -noupdate -divider {  PHY LINK STATUS 20}}
if [regexp {/tb/dut/led_an_20} [find signals /tb/dut/led_an_20]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_20}
if [regexp {/tb/dut/led_crs_20} [find signals /tb/dut/led_crs_20]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_20}
if [regexp {/tb/dut/led_char_err_20} [find signals /tb/dut/led_char_err_20]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_20}
if [regexp {/tb/dut/led_link_20} [find signals /tb/dut/led_link_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_20}
if [regexp {/tb/dut/led_col_20} [find signals /tb/dut/led_col_20]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_20}
if [regexp {/tb/dut/led_disp_err_20} [find signals /tb/dut/led_disp_err_20]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_20}

if [regexp {/tb/dut/led_an_21} [find signals /tb/dut/led_an_21]]                  {add wave -noupdate -divider {  PHY LINK STATUS 21}}
if [regexp {/tb/dut/led_an_21} [find signals /tb/dut/led_an_21]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_21}
if [regexp {/tb/dut/led_crs_21} [find signals /tb/dut/led_crs_21]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_21}
if [regexp {/tb/dut/led_char_err_21} [find signals /tb/dut/led_char_err_21]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_21}
if [regexp {/tb/dut/led_link_21} [find signals /tb/dut/led_link_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_21}
if [regexp {/tb/dut/led_col_21} [find signals /tb/dut/led_col_21]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_21}
if [regexp {/tb/dut/led_disp_err_21} [find signals /tb/dut/led_disp_err_21]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_21}

if [regexp {/tb/dut/led_an_22} [find signals /tb/dut/led_an_22]]                  {add wave -noupdate -divider {  PHY LINK STATUS 22}}
if [regexp {/tb/dut/led_an_22} [find signals /tb/dut/led_an_22]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_22}
if [regexp {/tb/dut/led_crs_22} [find signals /tb/dut/led_crs_22]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_22}
if [regexp {/tb/dut/led_char_err_22} [find signals /tb/dut/led_char_err_22]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_22}
if [regexp {/tb/dut/led_link_22} [find signals /tb/dut/led_link_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_22}
if [regexp {/tb/dut/led_col_22} [find signals /tb/dut/led_col_22]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_22}
if [regexp {/tb/dut/led_disp_err_22} [find signals /tb/dut/led_disp_err_22]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_22}

if [regexp {/tb/dut/led_an_23} [find signals /tb/dut/led_an_23]]                  {add wave -noupdate -divider {  PHY LINK STATUS 23}}
if [regexp {/tb/dut/led_an_23} [find signals /tb/dut/led_an_23]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_an_23}
if [regexp {/tb/dut/led_crs_23} [find signals /tb/dut/led_crs_23]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_crs_23}
if [regexp {/tb/dut/led_char_err_23} [find signals /tb/dut/led_char_err_23]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_char_err_23}
if [regexp {/tb/dut/led_link_23} [find signals /tb/dut/led_link_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_link_23}
if [regexp {/tb/dut/led_col_23} [find signals /tb/dut/led_col_23]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_col_23}
if [regexp {/tb/dut/led_disp_err_23} [find signals /tb/dut/led_disp_err_23]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/led_disp_err_23}


if [regexp {/tb/dut/powerdown} [find signals /tb/dut/powerdown] | \
regexp {/tb/dut/pcs_pwrdn_out} [find signals /tb/dut/pcs_pwrdn_out]]    {add wave -noupdate -divider {  PMA SERDES}}
if [regexp {/tb/dut/powerdown} [find signals /tb/dut/powerdown]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown}
if [regexp {/tb/dut/sd_loopback} [find signals /tb/dut/sd_loopback]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback}
if [regexp {/tb/dut/gxb_pwrdn_in} [find signals /tb/dut/gxb_pwrdn_in]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in}
if [regexp {/tb/dut/pcs_pwrdn_out} [find signals /tb/dut/pcs_pwrdn_out]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out}


if [regexp {/tb/dut/powerdown_0} [find signals /tb/dut/powerdown_0] | \
regexp {/tb/dut/pcs_pwrdn_out_0} [find signals /tb/dut/pcs_pwrdn_out_0]]    {add wave -noupdate -divider {  PMA SERDES 0}}
if [regexp {/tb/dut/powerdown_0} [find signals /tb/dut/powerdown_0]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_0}
if [regexp {/tb/dut/sd_loopback_0} [find signals /tb/dut/sd_loopback_0]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_0}
if [regexp {/tb/dut/gxb_pwrdn_in_0} [find signals /tb/dut/gxb_pwrdn_in_0]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_0}
if [regexp {/tb/dut/pcs_pwrdn_out_0} [find signals /tb/dut/pcs_pwrdn_out_0]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_0}

if [regexp {/tb/dut/powerdown_1} [find signals /tb/dut/powerdown_1] | \
regexp {/tb/dut/pcs_pwrdn_out_1} [find signals /tb/dut/pcs_pwrdn_out_1]]    {add wave -noupdate -divider {  PMA SERDES 1}}
if [regexp {/tb/dut/powerdown_1} [find signals /tb/dut/powerdown_1]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_1}
if [regexp {/tb/dut/sd_loopback_1} [find signals /tb/dut/sd_loopback_1]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_1}
if [regexp {/tb/dut/gxb_pwrdn_in_1} [find signals /tb/dut/gxb_pwrdn_in_1]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_1}
if [regexp {/tb/dut/pcs_pwrdn_out_1} [find signals /tb/dut/pcs_pwrdn_out_1]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_1}

if [regexp {/tb/dut/powerdown_2} [find signals /tb/dut/powerdown_2] | \
regexp {/tb/dut/pcs_pwrdn_out_2} [find signals /tb/dut/pcs_pwrdn_out_2]]    {add wave -noupdate -divider {  PMA SERDES 2}}
if [regexp {/tb/dut/powerdown_2} [find signals /tb/dut/powerdown_2]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_2}
if [regexp {/tb/dut/sd_loopback_2} [find signals /tb/dut/sd_loopback_2]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_2}
if [regexp {/tb/dut/gxb_pwrdn_in_2} [find signals /tb/dut/gxb_pwrdn_in_2]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_2}
if [regexp {/tb/dut/pcs_pwrdn_out_2} [find signals /tb/dut/pcs_pwrdn_out_2]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_2}

if [regexp {/tb/dut/powerdown_3} [find signals /tb/dut/powerdown_3] | \
regexp {/tb/dut/pcs_pwrdn_out_3} [find signals /tb/dut/pcs_pwrdn_out_3]]    {add wave -noupdate -divider {  PMA SERDES 3}}
if [regexp {/tb/dut/powerdown_3} [find signals /tb/dut/powerdown_3]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_3}
if [regexp {/tb/dut/sd_loopback_3} [find signals /tb/dut/sd_loopback_3]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_3}
if [regexp {/tb/dut/gxb_pwrdn_in_3} [find signals /tb/dut/gxb_pwrdn_in_3]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_3}
if [regexp {/tb/dut/pcs_pwrdn_out_3} [find signals /tb/dut/pcs_pwrdn_out_3]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_3}

if [regexp {/tb/dut/powerdown_4} [find signals /tb/dut/powerdown_4] | \
regexp {/tb/dut/pcs_pwrdn_out_4} [find signals /tb/dut/pcs_pwrdn_out_4]]    {add wave -noupdate -divider {  PMA SERDES 4}}
if [regexp {/tb/dut/powerdown_4} [find signals /tb/dut/powerdown_4]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_4}
if [regexp {/tb/dut/sd_loopback_4} [find signals /tb/dut/sd_loopback_4]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_4}
if [regexp {/tb/dut/gxb_pwrdn_in_4} [find signals /tb/dut/gxb_pwrdn_in_4]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_4}
if [regexp {/tb/dut/pcs_pwrdn_out_4} [find signals /tb/dut/pcs_pwrdn_out_4]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_4}

if [regexp {/tb/dut/powerdown_5} [find signals /tb/dut/powerdown_5] | \
regexp {/tb/dut/pcs_pwrdn_out_5} [find signals /tb/dut/pcs_pwrdn_out_5]]    {add wave -noupdate -divider {  PMA SERDES 5}}
if [regexp {/tb/dut/powerdown_5} [find signals /tb/dut/powerdown_5]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_5}
if [regexp {/tb/dut/sd_loopback_5} [find signals /tb/dut/sd_loopback_5]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_5}
if [regexp {/tb/dut/gxb_pwrdn_in_5} [find signals /tb/dut/gxb_pwrdn_in_5]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_5}
if [regexp {/tb/dut/pcs_pwrdn_out_5} [find signals /tb/dut/pcs_pwrdn_out_5]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_5}

if [regexp {/tb/dut/powerdown_6} [find signals /tb/dut/powerdown_6] | \
regexp {/tb/dut/pcs_pwrdn_out_6} [find signals /tb/dut/pcs_pwrdn_out_6]]    {add wave -noupdate -divider {  PMA SERDES 6}}
if [regexp {/tb/dut/powerdown_6} [find signals /tb/dut/powerdown_6]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_6}
if [regexp {/tb/dut/sd_loopback_6} [find signals /tb/dut/sd_loopback_6]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_6}
if [regexp {/tb/dut/gxb_pwrdn_in_6} [find signals /tb/dut/gxb_pwrdn_in_6]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_6}
if [regexp {/tb/dut/pcs_pwrdn_out_6} [find signals /tb/dut/pcs_pwrdn_out_6]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_6}

if [regexp {/tb/dut/powerdown_7} [find signals /tb/dut/powerdown_7] | \
regexp {/tb/dut/pcs_pwrdn_out_7} [find signals /tb/dut/pcs_pwrdn_out_7]]    {add wave -noupdate -divider {  PMA SERDES 7}}
if [regexp {/tb/dut/powerdown_7} [find signals /tb/dut/powerdown_7]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_7}
if [regexp {/tb/dut/sd_loopback_7} [find signals /tb/dut/sd_loopback_7]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_7}
if [regexp {/tb/dut/gxb_pwrdn_in_7} [find signals /tb/dut/gxb_pwrdn_in_7]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_7}
if [regexp {/tb/dut/pcs_pwrdn_out_7} [find signals /tb/dut/pcs_pwrdn_out_7]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_7}

if [regexp {/tb/dut/powerdown_8} [find signals /tb/dut/powerdown_8] | \
regexp {/tb/dut/pcs_pwrdn_out_8} [find signals /tb/dut/pcs_pwrdn_out_8]]    {add wave -noupdate -divider {  PMA SERDES 8}}
if [regexp {/tb/dut/powerdown_8} [find signals /tb/dut/powerdown_8]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_8}
if [regexp {/tb/dut/sd_loopback_8} [find signals /tb/dut/sd_loopback_8]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_8}
if [regexp {/tb/dut/gxb_pwrdn_in_8} [find signals /tb/dut/gxb_pwrdn_in_8]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_8}
if [regexp {/tb/dut/pcs_pwrdn_out_8} [find signals /tb/dut/pcs_pwrdn_out_8]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_8}

if [regexp {/tb/dut/powerdown_9} [find signals /tb/dut/powerdown_9] | \
regexp {/tb/dut/pcs_pwrdn_out_9} [find signals /tb/dut/pcs_pwrdn_out_9]]    {add wave -noupdate -divider {  PMA SERDES 9}}
if [regexp {/tb/dut/powerdown_9} [find signals /tb/dut/powerdown_9]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_9}
if [regexp {/tb/dut/sd_loopback_9} [find signals /tb/dut/sd_loopback_9]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_9}
if [regexp {/tb/dut/gxb_pwrdn_in_9} [find signals /tb/dut/gxb_pwrdn_in_9]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_9}
if [regexp {/tb/dut/pcs_pwrdn_out_9} [find signals /tb/dut/pcs_pwrdn_out_9]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_9}

if [regexp {/tb/dut/powerdown_10} [find signals /tb/dut/powerdown_10] | \
regexp {/tb/dut/pcs_pwrdn_out_10} [find signals /tb/dut/pcs_pwrdn_out_10]]    {add wave -noupdate -divider {  PMA SERDES 10}}
if [regexp {/tb/dut/powerdown_10} [find signals /tb/dut/powerdown_10]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_10}
if [regexp {/tb/dut/sd_loopback_10} [find signals /tb/dut/sd_loopback_10]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_10}
if [regexp {/tb/dut/gxb_pwrdn_in_10} [find signals /tb/dut/gxb_pwrdn_in_10]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_10}
if [regexp {/tb/dut/pcs_pwrdn_out_10} [find signals /tb/dut/pcs_pwrdn_out_10]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_10}

if [regexp {/tb/dut/powerdown_11} [find signals /tb/dut/powerdown_11] | \
regexp {/tb/dut/pcs_pwrdn_out_11} [find signals /tb/dut/pcs_pwrdn_out_11]]    {add wave -noupdate -divider {  PMA SERDES 11}}
if [regexp {/tb/dut/powerdown_11} [find signals /tb/dut/powerdown_11]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_11}
if [regexp {/tb/dut/sd_loopback_11} [find signals /tb/dut/sd_loopback_11]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_11}
if [regexp {/tb/dut/gxb_pwrdn_in_11} [find signals /tb/dut/gxb_pwrdn_in_11]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_11}
if [regexp {/tb/dut/pcs_pwrdn_out_11} [find signals /tb/dut/pcs_pwrdn_out_11]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_11}

if [regexp {/tb/dut/powerdown_12} [find signals /tb/dut/powerdown_12] | \
regexp {/tb/dut/pcs_pwrdn_out_12} [find signals /tb/dut/pcs_pwrdn_out_12]]    {add wave -noupdate -divider {  PMA SERDES 12}}
if [regexp {/tb/dut/powerdown_12} [find signals /tb/dut/powerdown_12]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_12}
if [regexp {/tb/dut/sd_loopback_12} [find signals /tb/dut/sd_loopback_12]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_12}
if [regexp {/tb/dut/gxb_pwrdn_in_12} [find signals /tb/dut/gxb_pwrdn_in_12]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_12}
if [regexp {/tb/dut/pcs_pwrdn_out_12} [find signals /tb/dut/pcs_pwrdn_out_12]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_12}

if [regexp {/tb/dut/powerdown_13} [find signals /tb/dut/powerdown_13] | \
regexp {/tb/dut/pcs_pwrdn_out_13} [find signals /tb/dut/pcs_pwrdn_out_13]]    {add wave -noupdate -divider {  PMA SERDES 13}}
if [regexp {/tb/dut/powerdown_13} [find signals /tb/dut/powerdown_13]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_13}
if [regexp {/tb/dut/sd_loopback_13} [find signals /tb/dut/sd_loopback_13]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_13}
if [regexp {/tb/dut/gxb_pwrdn_in_13} [find signals /tb/dut/gxb_pwrdn_in_13]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_13}
if [regexp {/tb/dut/pcs_pwrdn_out_13} [find signals /tb/dut/pcs_pwrdn_out_13]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_13}

if [regexp {/tb/dut/powerdown_14} [find signals /tb/dut/powerdown_14] | \
regexp {/tb/dut/pcs_pwrdn_out_14} [find signals /tb/dut/pcs_pwrdn_out_14]]    {add wave -noupdate -divider {  PMA SERDES 14}}
if [regexp {/tb/dut/powerdown_14} [find signals /tb/dut/powerdown_14]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_14}
if [regexp {/tb/dut/sd_loopback_14} [find signals /tb/dut/sd_loopback_14]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_14}
if [regexp {/tb/dut/gxb_pwrdn_in_14} [find signals /tb/dut/gxb_pwrdn_in_14]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_14}
if [regexp {/tb/dut/pcs_pwrdn_out_14} [find signals /tb/dut/pcs_pwrdn_out_14]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_14}

if [regexp {/tb/dut/powerdown_15} [find signals /tb/dut/powerdown_15] | \
regexp {/tb/dut/pcs_pwrdn_out_15} [find signals /tb/dut/pcs_pwrdn_out_15]]    {add wave -noupdate -divider {  PMA SERDES 15}}
if [regexp {/tb/dut/powerdown_15} [find signals /tb/dut/powerdown_15]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_15}
if [regexp {/tb/dut/sd_loopback_15} [find signals /tb/dut/sd_loopback_15]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_15}
if [regexp {/tb/dut/gxb_pwrdn_in_15} [find signals /tb/dut/gxb_pwrdn_in_15]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_15}
if [regexp {/tb/dut/pcs_pwrdn_out_15} [find signals /tb/dut/pcs_pwrdn_out_15]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_15}

if [regexp {/tb/dut/powerdown_16} [find signals /tb/dut/powerdown_16] | \
regexp {/tb/dut/pcs_pwrdn_out_16} [find signals /tb/dut/pcs_pwrdn_out_16]]    {add wave -noupdate -divider {  PMA SERDES 16}}
if [regexp {/tb/dut/powerdown_16} [find signals /tb/dut/powerdown_16]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_16}
if [regexp {/tb/dut/sd_loopback_16} [find signals /tb/dut/sd_loopback_16]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_16}
if [regexp {/tb/dut/gxb_pwrdn_in_16} [find signals /tb/dut/gxb_pwrdn_in_16]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_16}
if [regexp {/tb/dut/pcs_pwrdn_out_16} [find signals /tb/dut/pcs_pwrdn_out_16]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_16}

if [regexp {/tb/dut/powerdown_17} [find signals /tb/dut/powerdown_17] | \
regexp {/tb/dut/pcs_pwrdn_out_17} [find signals /tb/dut/pcs_pwrdn_out_17]]    {add wave -noupdate -divider {  PMA SERDES 17}}
if [regexp {/tb/dut/powerdown_17} [find signals /tb/dut/powerdown_17]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_17}
if [regexp {/tb/dut/sd_loopback_17} [find signals /tb/dut/sd_loopback_17]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_17}
if [regexp {/tb/dut/gxb_pwrdn_in_17} [find signals /tb/dut/gxb_pwrdn_in_17]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_17}
if [regexp {/tb/dut/pcs_pwrdn_out_17} [find signals /tb/dut/pcs_pwrdn_out_17]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_17}

if [regexp {/tb/dut/powerdown_18} [find signals /tb/dut/powerdown_18] | \
regexp {/tb/dut/pcs_pwrdn_out_18} [find signals /tb/dut/pcs_pwrdn_out_18]]    {add wave -noupdate -divider {  PMA SERDES 18}}
if [regexp {/tb/dut/powerdown_18} [find signals /tb/dut/powerdown_18]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_18}
if [regexp {/tb/dut/sd_loopback_18} [find signals /tb/dut/sd_loopback_18]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_18}
if [regexp {/tb/dut/gxb_pwrdn_in_18} [find signals /tb/dut/gxb_pwrdn_in_18]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_18}
if [regexp {/tb/dut/pcs_pwrdn_out_18} [find signals /tb/dut/pcs_pwrdn_out_18]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_18}


if [regexp {/tb/dut/powerdown_19} [find signals /tb/dut/powerdown_19] | \
regexp {/tb/dut/pcs_pwrdn_out_19} [find signals /tb/dut/pcs_pwrdn_out_19]]    {add wave -noupdate -divider {  PMA SERDES 19}}
if [regexp {/tb/dut/powerdown_19} [find signals /tb/dut/powerdown_19]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_19}
if [regexp {/tb/dut/sd_loopback_19} [find signals /tb/dut/sd_loopback_19]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_19}
if [regexp {/tb/dut/gxb_pwrdn_in_19} [find signals /tb/dut/gxb_pwrdn_in_19]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_19}
if [regexp {/tb/dut/pcs_pwrdn_out_19} [find signals /tb/dut/pcs_pwrdn_out_19]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_19}

if [regexp {/tb/dut/powerdown_20} [find signals /tb/dut/powerdown_20] | \
regexp {/tb/dut/pcs_pwrdn_out_20} [find signals /tb/dut/pcs_pwrdn_out_20]]    {add wave -noupdate -divider {  PMA SERDES 20}}
if [regexp {/tb/dut/powerdown_20} [find signals /tb/dut/powerdown_20]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_20}
if [regexp {/tb/dut/sd_loopback_20} [find signals /tb/dut/sd_loopback_20]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_20}
if [regexp {/tb/dut/gxb_pwrdn_in_20} [find signals /tb/dut/gxb_pwrdn_in_20]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_20}
if [regexp {/tb/dut/pcs_pwrdn_out_20} [find signals /tb/dut/pcs_pwrdn_out_20]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_20}

if [regexp {/tb/dut/powerdown_21} [find signals /tb/dut/powerdown_21] | \
regexp {/tb/dut/pcs_pwrdn_out_21} [find signals /tb/dut/pcs_pwrdn_out_21]]    {add wave -noupdate -divider {  PMA SERDES 21}}
if [regexp {/tb/dut/powerdown_21} [find signals /tb/dut/powerdown_21]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_21}
if [regexp {/tb/dut/sd_loopback_21} [find signals /tb/dut/sd_loopback_21]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_21}
if [regexp {/tb/dut/gxb_pwrdn_in_21} [find signals /tb/dut/gxb_pwrdn_in_21]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_21}
if [regexp {/tb/dut/pcs_pwrdn_out_21} [find signals /tb/dut/pcs_pwrdn_out_21]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_21}

if [regexp {/tb/dut/powerdown_22} [find signals /tb/dut/powerdown_22] | \
regexp {/tb/dut/pcs_pwrdn_out_22} [find signals /tb/dut/pcs_pwrdn_out_22]]    {add wave -noupdate -divider {  PMA SERDES 22}}
if [regexp {/tb/dut/powerdown_22} [find signals /tb/dut/powerdown_22]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_22}
if [regexp {/tb/dut/sd_loopback_22} [find signals /tb/dut/sd_loopback_22]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_22}
if [regexp {/tb/dut/gxb_pwrdn_in_22} [find signals /tb/dut/gxb_pwrdn_in_22]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_22}
if [regexp {/tb/dut/pcs_pwrdn_out_22} [find signals /tb/dut/pcs_pwrdn_out_22]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_22}

if [regexp {/tb/dut/powerdown_23} [find signals /tb/dut/powerdown_23] | \
regexp {/tb/dut/pcs_pwrdn_out_23} [find signals /tb/dut/pcs_pwrdn_out_23]]    {add wave -noupdate -divider {  PMA SERDES 23}}
if [regexp {/tb/dut/powerdown_23} [find signals /tb/dut/powerdown_23]]            {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/powerdown_23}
if [regexp {/tb/dut/sd_loopback_23} [find signals /tb/dut/sd_loopback_23]]        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/sd_loopback_23}
if [regexp {/tb/dut/gxb_pwrdn_in_23} [find signals /tb/dut/gxb_pwrdn_in_23]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/gxb_pwrdn_in_23}
if [regexp {/tb/dut/pcs_pwrdn_out_23} [find signals /tb/dut/pcs_pwrdn_out_23]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/pcs_pwrdn_out_23}



if [regexp {/tb/dut/mdc} [find signals /tb/dut/mdc]]                        {add wave -noupdate -divider {  MDIO}}
if [regexp {/tb/dut/mdio_out} [find signals /tb/dut/mdio_out]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mdio_out}
if [regexp {/tb/dut/mdio_oen} [find signals /tb/dut/mdio_oen]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mdio_oen}
if [regexp {/tb/dut/mdio_in} [find signals /tb/dut/mdio_in]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mdio_in}
if [regexp {/tb/dut/mdc} [find signals /tb/dut/mdc]]                        {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/mdc}


if {[regexp {/tb/dut/eth_mode} [find signals /tb/dut/eth_mode]]| \
[regexp {/tb/dut/magic_wakeup} [find signals /tb/dut/magic_wakeup]]}             {add wave -noupdate -divider {  MISC }}
if [regexp {/tb/dut/xon_gen} [find signals /tb/dut/xon_gen]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen}
if [regexp {/tb/dut/xoff_gen} [find signals /tb/dut/xoff_gen]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen}
if [regexp {/tb/dut/magic_wakeup} [find signals /tb/dut/magic_wakeup]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup}
if [regexp {/tb/dut/magic_sleep_n} [find signals /tb/dut/magic_sleep_n]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n}
if [regexp {/tb/dut/set_1000} [find signals /tb/dut/set_1000]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000}
if [regexp {/tb/dut/set_100} [find signals /tb/dut/set_100]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100}
if [regexp {/tb/dut/set_10} [find signals /tb/dut/set_10] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10}
if [regexp {/tb/dut/eth_mode} [find signals /tb/dut/eth_mode]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode}
if [regexp {/tb/dut/ena_10} [find signals /tb/dut/ena_10]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10}
if [regexp {/tb/dut/hd_ena} [find signals /tb/dut/hd_ena]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena}

if {[regexp {/tb/dut/eth_mode_0} [find signals /tb/dut/eth_mode_0]]| \
[regexp {/tb/dut/magic_wakeup_0} [find signals /tb/dut/magic_wakeup_0]]}             {add wave -noupdate -divider {  MISC 0}}
if [regexp {/tb/dut/xon_gen_0} [find signals /tb/dut/xon_gen_0]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_0}
if [regexp {/tb/dut/xoff_gen_0} [find signals /tb/dut/xoff_gen_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_0}
if [regexp {/tb/dut/magic_wakeup_0} [find signals /tb/dut/magic_wakeup_0]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_0}
if [regexp {/tb/dut/magic_sleep_n_0} [find signals /tb/dut/magic_sleep_n_0]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_0}
if [regexp {/tb/dut/set_1000_0} [find signals /tb/dut/set_1000_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_0}
if [regexp {/tb/dut/set_100_0} [find signals /tb/dut/set_100_0]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_0}
if [regexp {/tb/dut/set_10_0} [find signals /tb/dut/set_10_0] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_0}
if [regexp {/tb/dut/eth_mode_0} [find signals /tb/dut/eth_mode_0]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_0}
if [regexp {/tb/dut/ena_10_0} [find signals /tb/dut/ena_10_0]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_0}
if [regexp {/tb/dut/hd_ena_0} [find signals /tb/dut/hd_ena_0]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_0}

if {[regexp {/tb/dut/eth_mode_1} [find signals /tb/dut/eth_mode_1]]| \
[regexp {/tb/dut/magic_wakeup_1} [find signals /tb/dut/magic_wakeup_1]]}             {add wave -noupdate -divider {  MISC 1}}
if [regexp {/tb/dut/xon_gen_1} [find signals /tb/dut/xon_gen_1]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_1}
if [regexp {/tb/dut/xoff_gen_1} [find signals /tb/dut/xoff_gen_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_1}
if [regexp {/tb/dut/magic_wakeup_1} [find signals /tb/dut/magic_wakeup_1]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_1}
if [regexp {/tb/dut/magic_sleep_n_1} [find signals /tb/dut/magic_sleep_n_1]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_1}
if [regexp {/tb/dut/set_1000_1} [find signals /tb/dut/set_1000_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_1}
if [regexp {/tb/dut/set_100_1} [find signals /tb/dut/set_100_1]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_1}
if [regexp {/tb/dut/set_10_1} [find signals /tb/dut/set_10_1] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_1}
if [regexp {/tb/dut/eth_mode_1} [find signals /tb/dut/eth_mode_1]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_1}
if [regexp {/tb/dut/ena_10_1} [find signals /tb/dut/ena_10_1]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_1}
if [regexp {/tb/dut/hd_ena_1} [find signals /tb/dut/hd_ena_1]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_1}

if {[regexp {/tb/dut/eth_mode_2} [find signals /tb/dut/eth_mode_2]]| \
[regexp {/tb/dut/magic_wakeup_2} [find signals /tb/dut/magic_wakeup_2]]}             {add wave -noupdate -divider {  MISC 2}}
if [regexp {/tb/dut/xon_gen_2} [find signals /tb/dut/xon_gen_2]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_2}
if [regexp {/tb/dut/xoff_gen_2} [find signals /tb/dut/xoff_gen_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_2}
if [regexp {/tb/dut/magic_wakeup_2} [find signals /tb/dut/magic_wakeup_2]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_2}
if [regexp {/tb/dut/magic_sleep_n_2} [find signals /tb/dut/magic_sleep_n_2]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_2}
if [regexp {/tb/dut/set_1000_2} [find signals /tb/dut/set_1000_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_2}
if [regexp {/tb/dut/set_100_2} [find signals /tb/dut/set_100_2]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_2}
if [regexp {/tb/dut/set_10_2} [find signals /tb/dut/set_10_2] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_2}
if [regexp {/tb/dut/eth_mode_2} [find signals /tb/dut/eth_mode_2]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_2}
if [regexp {/tb/dut/ena_10_2} [find signals /tb/dut/ena_10_2]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_2}
if [regexp {/tb/dut/hd_ena_2} [find signals /tb/dut/hd_ena_2]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_2}

if {[regexp {/tb/dut/eth_mode_3} [find signals /tb/dut/eth_mode_3]]| \
[regexp {/tb/dut/magic_wakeup_3} [find signals /tb/dut/magic_wakeup_3]]}             {add wave -noupdate -divider {  MISC 3}}
if [regexp {/tb/dut/xon_gen_3} [find signals /tb/dut/xon_gen_3]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_3}
if [regexp {/tb/dut/xoff_gen_3} [find signals /tb/dut/xoff_gen_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_3}
if [regexp {/tb/dut/magic_wakeup_3} [find signals /tb/dut/magic_wakeup_3]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_3}
if [regexp {/tb/dut/magic_sleep_n_3} [find signals /tb/dut/magic_sleep_n_3]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_3}
if [regexp {/tb/dut/set_1000_3} [find signals /tb/dut/set_1000_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_3}
if [regexp {/tb/dut/set_100_3} [find signals /tb/dut/set_100_3]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_3}
if [regexp {/tb/dut/set_10_3} [find signals /tb/dut/set_10_3] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_3}
if [regexp {/tb/dut/eth_mode_3} [find signals /tb/dut/eth_mode_3]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_3}
if [regexp {/tb/dut/ena_10_3} [find signals /tb/dut/ena_10_3]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_3}
if [regexp {/tb/dut/hd_ena_3} [find signals /tb/dut/hd_ena_3]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_3}

if {[regexp {/tb/dut/eth_mode_4} [find signals /tb/dut/eth_mode_4]]| \
[regexp {/tb/dut/magic_wakeup_4} [find signals /tb/dut/magic_wakeup_4]]}             {add wave -noupdate -divider {  MISC 4}}
if [regexp {/tb/dut/xon_gen_4} [find signals /tb/dut/xon_gen_4]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_4}
if [regexp {/tb/dut/xoff_gen_4} [find signals /tb/dut/xoff_gen_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_4}
if [regexp {/tb/dut/magic_wakeup_4} [find signals /tb/dut/magic_wakeup_4]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_4}
if [regexp {/tb/dut/magic_sleep_n_4} [find signals /tb/dut/magic_sleep_n_4]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_4}
if [regexp {/tb/dut/set_1000_4} [find signals /tb/dut/set_1000_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_4}
if [regexp {/tb/dut/set_100_4} [find signals /tb/dut/set_100_4]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_4}
if [regexp {/tb/dut/set_10_4} [find signals /tb/dut/set_10_4] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_4}
if [regexp {/tb/dut/eth_mode_4} [find signals /tb/dut/eth_mode_4]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_4}
if [regexp {/tb/dut/ena_10_4} [find signals /tb/dut/ena_10_4]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_4}
if [regexp {/tb/dut/hd_ena_4} [find signals /tb/dut/hd_ena_4]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_4}

if {[regexp {/tb/dut/eth_mode_5} [find signals /tb/dut/eth_mode_5]]| \
[regexp {/tb/dut/magic_wakeup_5} [find signals /tb/dut/magic_wakeup_5]]}             {add wave -noupdate -divider {  MISC 5}}
if [regexp {/tb/dut/xon_gen_5} [find signals /tb/dut/xon_gen_5]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_5}
if [regexp {/tb/dut/xoff_gen_5} [find signals /tb/dut/xoff_gen_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_5}
if [regexp {/tb/dut/magic_wakeup_5} [find signals /tb/dut/magic_wakeup_5]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_5}
if [regexp {/tb/dut/magic_sleep_n_5} [find signals /tb/dut/magic_sleep_n_5]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_5}
if [regexp {/tb/dut/set_1000_5} [find signals /tb/dut/set_1000_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_5}
if [regexp {/tb/dut/set_100_5} [find signals /tb/dut/set_100_5]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_5}
if [regexp {/tb/dut/set_10_5} [find signals /tb/dut/set_10_5] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_5}
if [regexp {/tb/dut/eth_mode_5} [find signals /tb/dut/eth_mode_5]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_5}
if [regexp {/tb/dut/ena_10_5} [find signals /tb/dut/ena_10_5]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_5}
if [regexp {/tb/dut/hd_ena_5} [find signals /tb/dut/hd_ena_5]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_5}

if {[regexp {/tb/dut/eth_mode_6} [find signals /tb/dut/eth_mode_6]]| \
[regexp {/tb/dut/magic_wakeup_6} [find signals /tb/dut/magic_wakeup_6]]}             {add wave -noupdate -divider {  MISC 6}}
if [regexp {/tb/dut/xon_gen_6} [find signals /tb/dut/xon_gen_6]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_6}
if [regexp {/tb/dut/xoff_gen_6} [find signals /tb/dut/xoff_gen_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_6}
if [regexp {/tb/dut/magic_wakeup_6} [find signals /tb/dut/magic_wakeup_6]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_6}
if [regexp {/tb/dut/magic_sleep_n_6} [find signals /tb/dut/magic_sleep_n_6]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_6}
if [regexp {/tb/dut/set_1000_6} [find signals /tb/dut/set_1000_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_6}
if [regexp {/tb/dut/set_100_6} [find signals /tb/dut/set_100_6]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_6}
if [regexp {/tb/dut/set_10_6} [find signals /tb/dut/set_10_6] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_6}
if [regexp {/tb/dut/eth_mode_6} [find signals /tb/dut/eth_mode_6]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_6}
if [regexp {/tb/dut/ena_10_6} [find signals /tb/dut/ena_10_6]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_6}
if [regexp {/tb/dut/hd_ena_6} [find signals /tb/dut/hd_ena_6]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_6}

if {[regexp {/tb/dut/eth_mode_7} [find signals /tb/dut/eth_mode_7]]| \
[regexp {/tb/dut/magic_wakeup_7} [find signals /tb/dut/magic_wakeup_7]]}             {add wave -noupdate -divider {  MISC 7}}
if [regexp {/tb/dut/xon_gen_7} [find signals /tb/dut/xon_gen_7]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_7}
if [regexp {/tb/dut/xoff_gen_7} [find signals /tb/dut/xoff_gen_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_7}
if [regexp {/tb/dut/magic_wakeup_7} [find signals /tb/dut/magic_wakeup_7]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_7}
if [regexp {/tb/dut/magic_sleep_n_7} [find signals /tb/dut/magic_sleep_n_7]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_7}
if [regexp {/tb/dut/set_1000_7} [find signals /tb/dut/set_1000_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_7}
if [regexp {/tb/dut/set_100_7} [find signals /tb/dut/set_100_7]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_7}
if [regexp {/tb/dut/set_10_7} [find signals /tb/dut/set_10_7] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_7}
if [regexp {/tb/dut/eth_mode_7} [find signals /tb/dut/eth_mode_7]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_7}
if [regexp {/tb/dut/ena_10_7} [find signals /tb/dut/ena_10_7]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_7}
if [regexp {/tb/dut/hd_ena_7} [find signals /tb/dut/hd_ena_7]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_7}

if {[regexp {/tb/dut/eth_mode_8} [find signals /tb/dut/eth_mode_8]]| \
[regexp {/tb/dut/magic_wakeup_8} [find signals /tb/dut/magic_wakeup_8]]}             {add wave -noupdate -divider {  MISC 8}}
if [regexp {/tb/dut/xon_gen_8} [find signals /tb/dut/xon_gen_8]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_8}
if [regexp {/tb/dut/xoff_gen_8} [find signals /tb/dut/xoff_gen_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_8}
if [regexp {/tb/dut/magic_wakeup_8} [find signals /tb/dut/magic_wakeup_8]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_8}
if [regexp {/tb/dut/magic_sleep_n_8} [find signals /tb/dut/magic_sleep_n_8]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_8}
if [regexp {/tb/dut/set_1000_8} [find signals /tb/dut/set_1000_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_8}
if [regexp {/tb/dut/set_100_8} [find signals /tb/dut/set_100_8]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_8}
if [regexp {/tb/dut/set_10_8} [find signals /tb/dut/set_10_8] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_8}
if [regexp {/tb/dut/eth_mode_8} [find signals /tb/dut/eth_mode_8]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_8}
if [regexp {/tb/dut/ena_10_8} [find signals /tb/dut/ena_10_8]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_8}
if [regexp {/tb/dut/hd_ena_8} [find signals /tb/dut/hd_ena_8]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_8}

if {[regexp {/tb/dut/eth_mode_9} [find signals /tb/dut/eth_mode_9]]| \
[regexp {/tb/dut/magic_wakeup_9} [find signals /tb/dut/magic_wakeup_9]]}             {add wave -noupdate -divider {  MISC 9}}
if [regexp {/tb/dut/xon_gen_9} [find signals /tb/dut/xon_gen_9]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_9}
if [regexp {/tb/dut/xoff_gen_9} [find signals /tb/dut/xoff_gen_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_9}
if [regexp {/tb/dut/magic_wakeup_9} [find signals /tb/dut/magic_wakeup_9]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_9}
if [regexp {/tb/dut/magic_sleep_n_9} [find signals /tb/dut/magic_sleep_n_9]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_9}
if [regexp {/tb/dut/set_1000_9} [find signals /tb/dut/set_1000_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_9}
if [regexp {/tb/dut/set_100_9} [find signals /tb/dut/set_100_9]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_9}
if [regexp {/tb/dut/set_10_9} [find signals /tb/dut/set_10_9] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_9}
if [regexp {/tb/dut/eth_mode_9} [find signals /tb/dut/eth_mode_9]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_9}
if [regexp {/tb/dut/ena_10_9} [find signals /tb/dut/ena_10_9]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_9}
if [regexp {/tb/dut/hd_ena_9} [find signals /tb/dut/hd_ena_9]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_9}

if {[regexp {/tb/dut/eth_mode_10} [find signals /tb/dut/eth_mode_10]]| \
[regexp {/tb/dut/magic_wakeup_10} [find signals /tb/dut/magic_wakeup_10]]}             {add wave -noupdate -divider {  MISC 10}}
if [regexp {/tb/dut/xon_gen_10} [find signals /tb/dut/xon_gen_10]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_10}
if [regexp {/tb/dut/xoff_gen_10} [find signals /tb/dut/xoff_gen_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_10}
if [regexp {/tb/dut/magic_wakeup_10} [find signals /tb/dut/magic_wakeup_10]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_10}
if [regexp {/tb/dut/magic_sleep_n_10} [find signals /tb/dut/magic_sleep_n_10]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_10}
if [regexp {/tb/dut/set_1000_10} [find signals /tb/dut/set_1000_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_10}
if [regexp {/tb/dut/set_100_10} [find signals /tb/dut/set_100_10]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_10}
if [regexp {/tb/dut/set_10_10} [find signals /tb/dut/set_10_10] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_10}
if [regexp {/tb/dut/eth_mode_10} [find signals /tb/dut/eth_mode_10]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_10}
if [regexp {/tb/dut/ena_10_10} [find signals /tb/dut/ena_10_10]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_10}
if [regexp {/tb/dut/hd_ena_10} [find signals /tb/dut/hd_ena_10]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_10}

if {[regexp {/tb/dut/eth_mode_11} [find signals /tb/dut/eth_mode_11]]| \
[regexp {/tb/dut/magic_wakeup_11} [find signals /tb/dut/magic_wakeup_11]]}             {add wave -noupdate -divider {  MISC 11}}
if [regexp {/tb/dut/xon_gen_11} [find signals /tb/dut/xon_gen_11]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_11}
if [regexp {/tb/dut/xoff_gen_11} [find signals /tb/dut/xoff_gen_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_11}
if [regexp {/tb/dut/magic_wakeup_11} [find signals /tb/dut/magic_wakeup_11]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_11}
if [regexp {/tb/dut/magic_sleep_n_11} [find signals /tb/dut/magic_sleep_n_11]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_11}
if [regexp {/tb/dut/set_1000_11} [find signals /tb/dut/set_1000_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_11}
if [regexp {/tb/dut/set_100_11} [find signals /tb/dut/set_100_11]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_11}
if [regexp {/tb/dut/set_10_11} [find signals /tb/dut/set_10_11] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_11}
if [regexp {/tb/dut/eth_mode_11} [find signals /tb/dut/eth_mode_11]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_11}
if [regexp {/tb/dut/ena_10_11} [find signals /tb/dut/ena_10_11]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_11}
if [regexp {/tb/dut/hd_ena_11} [find signals /tb/dut/hd_ena_11]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_11}

if {[regexp {/tb/dut/eth_mode_12} [find signals /tb/dut/eth_mode_12]]| \
[regexp {/tb/dut/magic_wakeup_12} [find signals /tb/dut/magic_wakeup_12]]}             {add wave -noupdate -divider {  MISC 12}}
if [regexp {/tb/dut/xon_gen_12} [find signals /tb/dut/xon_gen_12]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_12}
if [regexp {/tb/dut/xoff_gen_12} [find signals /tb/dut/xoff_gen_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_12}
if [regexp {/tb/dut/magic_wakeup_12} [find signals /tb/dut/magic_wakeup_12]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_12}
if [regexp {/tb/dut/magic_sleep_n_12} [find signals /tb/dut/magic_sleep_n_12]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_12}
if [regexp {/tb/dut/set_1000_12} [find signals /tb/dut/set_1000_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_12}
if [regexp {/tb/dut/set_100_12} [find signals /tb/dut/set_100_12]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_12}
if [regexp {/tb/dut/set_10_12} [find signals /tb/dut/set_10_12] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_12}
if [regexp {/tb/dut/eth_mode_12} [find signals /tb/dut/eth_mode_12]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_12}
if [regexp {/tb/dut/ena_10_12} [find signals /tb/dut/ena_10_12]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_12}
if [regexp {/tb/dut/hd_ena_12} [find signals /tb/dut/hd_ena_12]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_12}

if {[regexp {/tb/dut/eth_mode_13} [find signals /tb/dut/eth_mode_13]]| \
[regexp {/tb/dut/magic_wakeup_13} [find signals /tb/dut/magic_wakeup_13]]}             {add wave -noupdate -divider {  MISC 13}}
if [regexp {/tb/dut/xon_gen_13} [find signals /tb/dut/xon_gen_13]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_13}
if [regexp {/tb/dut/xoff_gen_13} [find signals /tb/dut/xoff_gen_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_13}
if [regexp {/tb/dut/magic_wakeup_13} [find signals /tb/dut/magic_wakeup_13]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_13}
if [regexp {/tb/dut/magic_sleep_n_13} [find signals /tb/dut/magic_sleep_n_13]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_13}
if [regexp {/tb/dut/set_1000_13} [find signals /tb/dut/set_1000_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_13}
if [regexp {/tb/dut/set_100_13} [find signals /tb/dut/set_100_13]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_13}
if [regexp {/tb/dut/set_10_13} [find signals /tb/dut/set_10_13] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_13}
if [regexp {/tb/dut/eth_mode_13} [find signals /tb/dut/eth_mode_13]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_13}
if [regexp {/tb/dut/ena_10_13} [find signals /tb/dut/ena_10_13]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_13}
if [regexp {/tb/dut/hd_ena_13} [find signals /tb/dut/hd_ena_13]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_13}

if {[regexp {/tb/dut/eth_mode_14} [find signals /tb/dut/eth_mode_14]]| \
[regexp {/tb/dut/magic_wakeup_14} [find signals /tb/dut/magic_wakeup_14]]}             {add wave -noupdate -divider {  MISC 14}}
if [regexp {/tb/dut/xon_gen_14} [find signals /tb/dut/xon_gen_14]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_14}
if [regexp {/tb/dut/xoff_gen_14} [find signals /tb/dut/xoff_gen_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_14}
if [regexp {/tb/dut/magic_wakeup_14} [find signals /tb/dut/magic_wakeup_14]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_14}
if [regexp {/tb/dut/magic_sleep_n_14} [find signals /tb/dut/magic_sleep_n_14]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_14}
if [regexp {/tb/dut/set_1000_14} [find signals /tb/dut/set_1000_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_14}
if [regexp {/tb/dut/set_100_14} [find signals /tb/dut/set_100_14]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_14}
if [regexp {/tb/dut/set_10_14} [find signals /tb/dut/set_10_14] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_14}
if [regexp {/tb/dut/eth_mode_14} [find signals /tb/dut/eth_mode_14]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_14}
if [regexp {/tb/dut/ena_10_14} [find signals /tb/dut/ena_10_14]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_14}
if [regexp {/tb/dut/hd_ena_14} [find signals /tb/dut/hd_ena_14]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_14}

if {[regexp {/tb/dut/eth_mode_15} [find signals /tb/dut/eth_mode_15]]| \
[regexp {/tb/dut/magic_wakeup_15} [find signals /tb/dut/magic_wakeup_15]]}             {add wave -noupdate -divider {  MISC 15}}
if [regexp {/tb/dut/xon_gen_15} [find signals /tb/dut/xon_gen_15]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_15}
if [regexp {/tb/dut/xoff_gen_15} [find signals /tb/dut/xoff_gen_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_15}
if [regexp {/tb/dut/magic_wakeup_15} [find signals /tb/dut/magic_wakeup_15]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_15}
if [regexp {/tb/dut/magic_sleep_n_15} [find signals /tb/dut/magic_sleep_n_15]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_15}
if [regexp {/tb/dut/set_1000_15} [find signals /tb/dut/set_1000_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_15}
if [regexp {/tb/dut/set_100_15} [find signals /tb/dut/set_100_15]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_15}
if [regexp {/tb/dut/set_10_15} [find signals /tb/dut/set_10_15] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_15}
if [regexp {/tb/dut/eth_mode_15} [find signals /tb/dut/eth_mode_15]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_15}
if [regexp {/tb/dut/ena_10_15} [find signals /tb/dut/ena_10_15]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_15}
if [regexp {/tb/dut/hd_ena_15} [find signals /tb/dut/hd_ena_15]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_15}

if {[regexp {/tb/dut/eth_mode_16} [find signals /tb/dut/eth_mode_16]]| \
[regexp {/tb/dut/magic_wakeup_16} [find signals /tb/dut/magic_wakeup_16]]}             {add wave -noupdate -divider {  MISC 16}}
if [regexp {/tb/dut/xon_gen_16} [find signals /tb/dut/xon_gen_16]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_16}
if [regexp {/tb/dut/xoff_gen_16} [find signals /tb/dut/xoff_gen_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_16}
if [regexp {/tb/dut/magic_wakeup_16} [find signals /tb/dut/magic_wakeup_16]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_16}
if [regexp {/tb/dut/magic_sleep_n_16} [find signals /tb/dut/magic_sleep_n_16]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_16}
if [regexp {/tb/dut/set_1000_16} [find signals /tb/dut/set_1000_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_16}
if [regexp {/tb/dut/set_100_16} [find signals /tb/dut/set_100_16]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_16}
if [regexp {/tb/dut/set_10_16} [find signals /tb/dut/set_10_16] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_16}
if [regexp {/tb/dut/eth_mode_16} [find signals /tb/dut/eth_mode_16]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_16}
if [regexp {/tb/dut/ena_10_16} [find signals /tb/dut/ena_10_16]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_16}
if [regexp {/tb/dut/hd_ena_16} [find signals /tb/dut/hd_ena_16]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_16}

if {[regexp {/tb/dut/eth_mode_17} [find signals /tb/dut/eth_mode_17]]| \
[regexp {/tb/dut/magic_wakeup_17} [find signals /tb/dut/magic_wakeup_17]]}             {add wave -noupdate -divider {  MISC 17}}
if [regexp {/tb/dut/xon_gen_17} [find signals /tb/dut/xon_gen_17]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_17}
if [regexp {/tb/dut/xoff_gen_17} [find signals /tb/dut/xoff_gen_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_17}
if [regexp {/tb/dut/magic_wakeup_17} [find signals /tb/dut/magic_wakeup_17]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_17}
if [regexp {/tb/dut/magic_sleep_n_17} [find signals /tb/dut/magic_sleep_n_17]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_17}
if [regexp {/tb/dut/set_1000_17} [find signals /tb/dut/set_1000_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_17}
if [regexp {/tb/dut/set_100_17} [find signals /tb/dut/set_100_17]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_17}
if [regexp {/tb/dut/set_10_17} [find signals /tb/dut/set_10_17] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_17}
if [regexp {/tb/dut/eth_mode_17} [find signals /tb/dut/eth_mode_17]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_17}
if [regexp {/tb/dut/ena_10_17} [find signals /tb/dut/ena_10_17]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_17}
if [regexp {/tb/dut/hd_ena_17} [find signals /tb/dut/hd_ena_17]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_17}

if {[regexp {/tb/dut/eth_mode_18} [find signals /tb/dut/eth_mode_18]]| \
[regexp {/tb/dut/magic_wakeup_18} [find signals /tb/dut/magic_wakeup_18]]}             {add wave -noupdate -divider {  MISC 18}}
if [regexp {/tb/dut/xon_gen_18} [find signals /tb/dut/xon_gen_18]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_18}
if [regexp {/tb/dut/xoff_gen_18} [find signals /tb/dut/xoff_gen_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_18}
if [regexp {/tb/dut/magic_wakeup_18} [find signals /tb/dut/magic_wakeup_18]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_18}
if [regexp {/tb/dut/magic_sleep_n_18} [find signals /tb/dut/magic_sleep_n_18]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_18}
if [regexp {/tb/dut/set_1000_18} [find signals /tb/dut/set_1000_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_18}
if [regexp {/tb/dut/set_100_18} [find signals /tb/dut/set_100_18]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_18}
if [regexp {/tb/dut/set_10_18} [find signals /tb/dut/set_10_18] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_18}
if [regexp {/tb/dut/eth_mode_18} [find signals /tb/dut/eth_mode_18]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_18}
if [regexp {/tb/dut/ena_10_18} [find signals /tb/dut/ena_10_18]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_18}
if [regexp {/tb/dut/hd_ena_18} [find signals /tb/dut/hd_ena_18]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_18}

if {[regexp {/tb/dut/eth_mode_19} [find signals /tb/dut/eth_mode_19]]| \
[regexp {/tb/dut/magic_wakeup_19} [find signals /tb/dut/magic_wakeup_19]]}             {add wave -noupdate -divider {  MISC 19}}
if [regexp {/tb/dut/xon_gen_19} [find signals /tb/dut/xon_gen_19]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_19}
if [regexp {/tb/dut/xoff_gen_19} [find signals /tb/dut/xoff_gen_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_19}
if [regexp {/tb/dut/magic_wakeup_19} [find signals /tb/dut/magic_wakeup_19]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_19}
if [regexp {/tb/dut/magic_sleep_n_19} [find signals /tb/dut/magic_sleep_n_19]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_19}
if [regexp {/tb/dut/set_1000_19} [find signals /tb/dut/set_1000_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_19}
if [regexp {/tb/dut/set_100_19} [find signals /tb/dut/set_100_19]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_19}
if [regexp {/tb/dut/set_10_19} [find signals /tb/dut/set_10_19] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_19}
if [regexp {/tb/dut/eth_mode_19} [find signals /tb/dut/eth_mode_19]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_19}
if [regexp {/tb/dut/ena_10_19} [find signals /tb/dut/ena_10_19]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_19}
if [regexp {/tb/dut/hd_ena_19} [find signals /tb/dut/hd_ena_19]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_19}

if {[regexp {/tb/dut/eth_mode_20} [find signals /tb/dut/eth_mode_20]]| \
[regexp {/tb/dut/magic_wakeup_20} [find signals /tb/dut/magic_wakeup_20]]}             {add wave -noupdate -divider {  MISC 20}}
if [regexp {/tb/dut/xon_gen_20} [find signals /tb/dut/xon_gen_20]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_20}
if [regexp {/tb/dut/xoff_gen_20} [find signals /tb/dut/xoff_gen_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_20}
if [regexp {/tb/dut/magic_wakeup_20} [find signals /tb/dut/magic_wakeup_20]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_20}
if [regexp {/tb/dut/magic_sleep_n_20} [find signals /tb/dut/magic_sleep_n_20]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_20}
if [regexp {/tb/dut/set_1000_20} [find signals /tb/dut/set_1000_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_20}
if [regexp {/tb/dut/set_100_20} [find signals /tb/dut/set_100_20]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_20}
if [regexp {/tb/dut/set_10_20} [find signals /tb/dut/set_10_20] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_20}
if [regexp {/tb/dut/eth_mode_20} [find signals /tb/dut/eth_mode_20]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_20}
if [regexp {/tb/dut/ena_10_20} [find signals /tb/dut/ena_10_20]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_20}
if [regexp {/tb/dut/hd_ena_20} [find signals /tb/dut/hd_ena_20]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_20}

if {[regexp {/tb/dut/eth_mode_21} [find signals /tb/dut/eth_mode_21]]| \
[regexp {/tb/dut/magic_wakeup_21} [find signals /tb/dut/magic_wakeup_21]]}             {add wave -noupdate -divider {  MISC 21}}
if [regexp {/tb/dut/xon_gen_21} [find signals /tb/dut/xon_gen_21]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_21}
if [regexp {/tb/dut/xoff_gen_21} [find signals /tb/dut/xoff_gen_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_21}
if [regexp {/tb/dut/magic_wakeup_21} [find signals /tb/dut/magic_wakeup_21]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_21}
if [regexp {/tb/dut/magic_sleep_n_21} [find signals /tb/dut/magic_sleep_n_21]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_21}
if [regexp {/tb/dut/set_1000_21} [find signals /tb/dut/set_1000_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_21}
if [regexp {/tb/dut/set_100_21} [find signals /tb/dut/set_100_21]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_21}
if [regexp {/tb/dut/set_10_21} [find signals /tb/dut/set_10_21] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_21}
if [regexp {/tb/dut/eth_mode_21} [find signals /tb/dut/eth_mode_21]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_21}
if [regexp {/tb/dut/ena_10_21} [find signals /tb/dut/ena_10_21]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_21}
if [regexp {/tb/dut/hd_ena_21} [find signals /tb/dut/hd_ena_21]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_21}

if {[regexp {/tb/dut/eth_mode_22} [find signals /tb/dut/eth_mode_22]]| \
[regexp {/tb/dut/magic_wakeup_22} [find signals /tb/dut/magic_wakeup_22]]}             {add wave -noupdate -divider {  MISC 22}}
if [regexp {/tb/dut/xon_gen_22} [find signals /tb/dut/xon_gen_22]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_22}
if [regexp {/tb/dut/xoff_gen_22} [find signals /tb/dut/xoff_gen_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_22}
if [regexp {/tb/dut/magic_wakeup_22} [find signals /tb/dut/magic_wakeup_22]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_22}
if [regexp {/tb/dut/magic_sleep_n_22} [find signals /tb/dut/magic_sleep_n_22]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_22}
if [regexp {/tb/dut/set_1000_22} [find signals /tb/dut/set_1000_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_22}
if [regexp {/tb/dut/set_100_22} [find signals /tb/dut/set_100_22]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_22}
if [regexp {/tb/dut/set_10_22} [find signals /tb/dut/set_10_22] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_22}
if [regexp {/tb/dut/eth_mode_22} [find signals /tb/dut/eth_mode_22]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_22}
if [regexp {/tb/dut/ena_10_22} [find signals /tb/dut/ena_10_22]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_22}
if [regexp {/tb/dut/hd_ena_22} [find signals /tb/dut/hd_ena_22]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_22}

if {[regexp {/tb/dut/eth_mode_23} [find signals /tb/dut/eth_mode_23]]| \
[regexp {/tb/dut/magic_wakeup_23} [find signals /tb/dut/magic_wakeup_23]]}             {add wave -noupdate -divider {  MISC 23}}
if [regexp {/tb/dut/xon_gen_23} [find signals /tb/dut/xon_gen_23]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xon_gen_23}
if [regexp {/tb/dut/xoff_gen_23} [find signals /tb/dut/xoff_gen_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/xoff_gen_23}
if [regexp {/tb/dut/magic_wakeup_23} [find signals /tb/dut/magic_wakeup_23]]      {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_wakeup_23}
if [regexp {/tb/dut/magic_sleep_n_23} [find signals /tb/dut/magic_sleep_n_23]]    {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/magic_sleep_n_23}
if [regexp {/tb/dut/set_1000_23} [find signals /tb/dut/set_1000_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_1000_23}
if [regexp {/tb/dut/set_100_23} [find signals /tb/dut/set_100_23]]                {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_100_23}
if [regexp {/tb/dut/set_10_23} [find signals /tb/dut/set_10_23] ]                 {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/set_10_23}
if [regexp {/tb/dut/eth_mode_23} [find signals /tb/dut/eth_mode_23]]              {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/eth_mode_23}
if [regexp {/tb/dut/ena_10_23} [find signals /tb/dut/ena_10_23]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/ena_10_23}
if [regexp {/tb/dut/hd_ena_23} [find signals /tb/dut/hd_ena_23]]                  {add wave -noupdate -format Logic -radix hexadecimal /tb/dut/hd_ena_23}



TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 201
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {20 us}

