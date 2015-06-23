
onbreak {resume}

proc r {} {
    restart -force -all
}

transcript file ""

set debug 1 

if {$debug} {
    set seed [clock seconds]    
} else {
    set seed [clock seconds]
}

#transcript file transcript

if {$debug} {
vsim -novopt -sv_seed $seed -wlf hssdrc_work.wlf work.tb_top 

onerror {resume}
quietly WaveActivateNextPane {} 0

radix hexadecimal

add wave -noupdate -divider system
add wave -noupdate -format Logic /tb_top/clk
add wave -noupdate -format Logic /tb_top/reset
add wave -noupdate -format Logic /tb_top/sclr

add wave -noupdate -divider sys_if_req_resp
add wave -noupdate -format Logic /tb_top/sys_write
add wave -noupdate -format Logic /tb_top/sys_read
add wave -noupdate -format Logic /tb_top/sys_refr
add wave -noupdate -format Logic /tb_top/sys_ready

add wave -noupdate -divider sys_if_req_data
add wave -noupdate -format Literal /tb_top/sys_rowa
add wave -noupdate -format Literal /tb_top/sys_cola
add wave -noupdate -format Literal /tb_top/sys_ba
add wave -noupdate -format Literal /tb_top/sys_burst
add wave -noupdate -format Literal /tb_top/sys_chid_i

add wave -noupdate -divider sys_if_data
add wave -noupdate -format Literal /tb_top/sys_wdata
add wave -noupdate -format Literal /tb_top/sys_wdatam
add wave -noupdate -format Logic   /tb_top/sys_use_wdata

add wave -noupdate -format Logic   /tb_top/sys_chid_o
add wave -noupdate -format Literal /tb_top/sys_rdata
add wave -noupdate -format Logic   /tb_top/sys_vld_rdata

add wave -noupdate -divider sdram_if
add wave -noupdate -format Logic   /tb_top/nclk
add wave -noupdate -format Literal /tb_top/inter/cmd_e
add wave -noupdate -format Literal /tb_top/dq
add wave -noupdate -format Literal /tb_top/dqm
add wave -noupdate -format Literal /tb_top/addr
add wave -noupdate -format Literal /tb_top/ba
add wave -noupdate -format Logic   /tb_top/cs_n
add wave -noupdate -format Logic   /tb_top/ras_n
add wave -noupdate -format Logic   /tb_top/cas_n
add wave -noupdate -format Logic   /tb_top/we_n

add wave -noupdate -divider am
add wave -noupdate -format Logic   /tb_top/top/access_manager/am_pre_all_enable
add wave -noupdate -format Logic   /tb_top/top/access_manager/am_refr_enable
add wave -noupdate -format Literal /tb_top/top/access_manager/am_pre_enable
add wave -noupdate -format Literal /tb_top/top/access_manager/am_act_enable
add wave -noupdate -format Literal /tb_top/top/access_manager/am_read_enable
add wave -noupdate -format Literal /tb_top/top/access_manager/am_write_enable

add wave -noupdate -divider mux 
add wave -noupdate -format Logic   /tb_top/top/mux/mux_pre_all
add wave -noupdate -format Logic   /tb_top/top/mux/mux_refr 
add wave -noupdate -format Logic   /tb_top/top/mux/mux_pre  
add wave -noupdate -format Logic   /tb_top/top/mux/mux_act  
add wave -noupdate -format Logic   /tb_top/top/mux/mux_read 
add wave -noupdate -format Logic   /tb_top/top/mux/mux_write
add wave -noupdate -format Logic   /tb_top/top/mux/mux_lmr  
add wave -noupdate -format Literal /tb_top/top/mux/mux_burst  

add wave -noupdate -divider state
add wave -noupdate -format Literal /tb_top/top/decoder/state0/state
add wave -noupdate -format Literal /tb_top/top/decoder/state1/state
add wave -noupdate -format Literal /tb_top/top/decoder/state2/state

add wave -noupdate -divider ba_map
add wave -noupdate -format Logic   /tb_top/top/ba_map/update
add wave -noupdate -format Logic   /tb_top/top/ba_map/clear
add wave -noupdate -format Literal /tb_top/top/ba_map/ba
add wave -noupdate -format Literal /tb_top/top/ba_map/rowa
add wave -noupdate -format Logic   /tb_top/top/ba_map/pre_act_rw
add wave -noupdate -format Logic   /tb_top/top/ba_map/act_rw
add wave -noupdate -format Logic   /tb_top/top/ba_map/rw
add wave -noupdate -format Logic   /tb_top/top/ba_map/all_close

add wave -noupdate -divider init_state
add wave -noupdate -format Logic /tb_top/top/init_state/init_done

add wave -noupdate -divider refr_cnt
add wave -noupdate -format Logic /tb_top/top/refr_cnt/ack
add wave -noupdate -format Logic /tb_top/top/refr_cnt/hi_req
add wave -noupdate -format Logic /tb_top/top/refr_cnt/low_req



TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 203
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {1000 ps}

log -r /*

} else {
    vsim -sv_seed $seed work.tb_top 
    run -all
    quit 
}

