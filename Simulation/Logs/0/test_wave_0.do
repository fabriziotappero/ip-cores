onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {eSOC Control}
add wave -noupdate -group {eSoc System Clock Reset} /esoc_tb/esoc_tb/reset
add wave -noupdate -group {eSoc System Clock Reset} /esoc_tb/esoc_tb/esoc_areset
add wave -noupdate -group {eSoc System Clock Reset} /esoc_tb/esoc_tb/esoc_clk
add wave -noupdate -group {eSoc System Clock Reset} /esoc_tb/esoc_tb/clk_control
add wave -noupdate -group {eSoc System Clock Reset} /esoc_tb/esoc_tb/clk_search
add wave -noupdate -group {eSoc System Clock Reset} /esoc_tb/esoc_tb/clk_data
add wave -noupdate -expand -group {eSoc Boot Rom} /esoc_tb/esoc_tb/clk_control
add wave -noupdate -expand -group {eSoc Boot Rom} /esoc_tb/esoc_tb/u0/ctrl_bus_state
add wave -noupdate -expand -group {eSoc Boot Rom} /esoc_tb/esoc_tb/esoc_boot_complete
add wave -noupdate -expand -group {eSoc Boot Rom} /esoc_tb/esoc_tb/u0/brom_error
add wave -noupdate -expand -group {eSoc Boot Rom} /esoc_tb/esoc_tb/u0/brom_wait_count
add wave -noupdate -expand -group {eSoc Boot Rom} -radix hexadecimal /esoc_tb/esoc_tb/u0/brom_address_count
add wave -noupdate -expand -group {eSoc Boot Rom} -radix hexadecimal /esoc_tb/esoc_tb/u0/brom_rd
add wave -noupdate -expand -group {eSoc Boot Rom} -radix hexadecimal /esoc_tb/esoc_tb/u0/brom_address
add wave -noupdate -expand -group {eSoc Boot Rom} -radix hexadecimal /esoc_tb/esoc_tb/u0/brom_rddata
add wave -noupdate -group {eSoc Control interface} /esoc_tb/esoc_tb/esoc_boot_complete
add wave -noupdate -group {eSoc Control interface} -radix hexadecimal /esoc_tb/esoc_tb/u0/esoc_address
add wave -noupdate -group {eSoc Control interface} /esoc_tb/esoc_tb/u0/esoc_cs
add wave -noupdate -group {eSoc Control interface} -color red -radix hexadecimal /esoc_tb/esoc_tb/u0/esoc_wr
add wave -noupdate -group {eSoc Control interface} -color yellow -radix hexadecimal /esoc_tb/esoc_tb/u0/esoc_rd
add wave -noupdate -group {eSoc Control interface} /esoc_tb/esoc_tb/u0/esoc_wait
add wave -noupdate -group {eSoc Control interface} -radix hexadecimal /esoc_tb/esoc_tb/u0/esoc_data
add wave -noupdate -group {eSoc Control interface} -radix hexadecimal /esoc_tb/esoc_tb/u0/esoc_wr_sync
add wave -noupdate -group {eSoc Control interface} -radix hexadecimal /esoc_tb/esoc_tb/u0/esoc_rd_sync
add wave -noupdate -group {eSoc Control interface} /esoc_tb/esoc_wait_timer_start
add wave -noupdate -group {eSoc Control interface} /esoc_tb/esoc_wait_timer
add wave -noupdate -group {eSoc Control interface} /esoc_tb/esoc_wait_timeout
add wave -noupdate -group {eSoc Control interface} -radix hexadecimal /esoc_tb/esoc_tb/u0/ctrl_address
add wave -noupdate -group {eSoc Control interface} -radix hexadecimal /esoc_tb/esoc_tb/u0/ctrl_wr
add wave -noupdate -group {eSoc Control interface} -radix hexadecimal /esoc_tb/esoc_tb/u0/ctrl_rd
add wave -noupdate -group {eSoc Control interface} /esoc_tb/esoc_tb/u0/ctrl_wait
add wave -noupdate -group {eSoc Control interface} -radix hexadecimal /esoc_tb/esoc_tb/u0/ctrl_wrdata
add wave -noupdate -group {eSoc Control interface} -radix hexadecimal /esoc_tb/esoc_tb/u0/ctrl_rddata
add wave -noupdate -group {eSOC Configuration} -radix hexadecimal /esoc_tb/esoc_tb/u0/ctrl_address_i
add wave -noupdate -group {eSOC Configuration} /esoc_tb/esoc_tb/u0/ctrl_wr_i
add wave -noupdate -group {eSOC Configuration} /esoc_tb/esoc_tb/u0/ctrl_rd_i
add wave -noupdate -group {eSOC Configuration} /esoc_tb/esoc_tb/u0/ctrl_wait_i
add wave -noupdate -group {eSOC Configuration} -radix hexadecimal /esoc_tb/esoc_tb/u0/ctrl_wrdata_i
add wave -noupdate -group {eSOC Configuration} -radix hexadecimal /esoc_tb/esoc_tb/u0/ctrl_rddata_i
add wave -noupdate -divider {eSOC Bus Arbiters}
add wave -noupdate -group {eSOC Data Bus Arbiter Config} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_address
add wave -noupdate -group {eSOC Data Bus Arbiter Config} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_wr
add wave -noupdate -group {eSOC Data Bus Arbiter Config} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_rd
add wave -noupdate -group {eSOC Data Bus Arbiter Config} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_wait
add wave -noupdate -group {eSOC Data Bus Arbiter Config} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_wrdata
add wave -noupdate -group {eSOC Data Bus Arbiter Config} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_rddata
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/reset
add wave -noupdate -group {eSOC Data Bus Arbiter} /esoc_tb/esoc_tb/u4/id
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/clk_bus
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/clk_control
add wave -noupdate -group {eSOC Data Bus Arbiter} /esoc_tb/esoc_tb/u4/ctrl_bus_enable
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_address
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_rd
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_rddata
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_wait
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_wr
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/ctrl_wrdata
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/reg_arb_port_disable_dat
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/reg_arb_port_weight_dat
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/port_select
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/port_request
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix unsigned /esoc_tb/esoc_tb/u4/port_request_weight
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/state_data_bus
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/bus_req
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/bus_gnt_wr
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/bus_gnt_rd
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/bus_sof
add wave -noupdate -group {eSOC Data Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u4/bus_eof
add wave -noupdate -group {eSOCSearch Bus Arbiter Config} -radix hexadecimal /esoc_tb/esoc_tb/u5/ctrl_address
add wave -noupdate -group {eSOCSearch Bus Arbiter Config} /esoc_tb/esoc_tb/u5/ctrl_wr
add wave -noupdate -group {eSOCSearch Bus Arbiter Config} /esoc_tb/esoc_tb/u5/ctrl_rd
add wave -noupdate -group {eSOCSearch Bus Arbiter Config} /esoc_tb/esoc_tb/u5/ctrl_wait
add wave -noupdate -group {eSOCSearch Bus Arbiter Config} /esoc_tb/esoc_tb/u5/ctrl_wrdata
add wave -noupdate -group {eSOCSearch Bus Arbiter Config} /esoc_tb/esoc_tb/u5/ctrl_rddata
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/reset
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/id
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/clk_bus
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/clk_control
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/ctrl_address
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/ctrl_rd
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/ctrl_rddata
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/ctrl_wait
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/ctrl_wr
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/ctrl_wrdata
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/reg_arb_port_disable_dat
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/reg_arb_port_weight_dat
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix unsigned /esoc_tb/esoc_tb/u5/port_select
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/port_request
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/state_data_bus
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/bus_req
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/bus_gnt_wr
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/bus_gnt_rd
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/bus_sof
add wave -noupdate -group {eSOC Search Bus Arbiter} -radix hexadecimal /esoc_tb/esoc_tb/u5/bus_eof
add wave -noupdate -divider {eSOC Search Engine}
add wave -noupdate -group {eSOC Search Engine - Control} /esoc_tb/esoc_tb/u6/u3/reset
add wave -noupdate -group {eSOC Search Engine - Control} /esoc_tb/esoc_tb/u6/u3/clk_control
add wave -noupdate -group {eSOC Search Engine - Control} /esoc_tb/esoc_tb/u6/u3/clk_search
add wave -noupdate -group {eSOC Search Engine - Control} /esoc_tb/esoc_tb/u6/u3/ctrl_bus_enable
add wave -noupdate -group {eSOC Search Engine - Control} -radix hexadecimal /esoc_tb/esoc_tb/u6/u3/ctrl_address
add wave -noupdate -group {eSOC Search Engine - Control} /esoc_tb/esoc_tb/u6/u3/ctrl_rd
add wave -noupdate -group {eSOC Search Engine - Control} -radix hexadecimal /esoc_tb/esoc_tb/u6/u3/ctrl_rddata
add wave -noupdate -group {eSOC Search Engine - Control} /esoc_tb/esoc_tb/u6/u3/ctrl_wr
add wave -noupdate -group {eSOC Search Engine - Control} -radix hexadecimal /esoc_tb/esoc_tb/u6/u3/ctrl_wrdata
add wave -noupdate -group {eSOC Search Engine - Control} /esoc_tb/esoc_tb/u6/u3/ctrl_wait
add wave -noupdate -group {eSOC Search Engine - Control} -radix hexadecimal /esoc_tb/esoc_tb/u6/u3/reg_search_engine_sa_drop_count
add wave -noupdate -group {eSOC Search Engine - Control} -radix hexadecimal /esoc_tb/esoc_tb/u6/u3/reg_search_engine_stat_ctrl
add wave -noupdate -group {eSOC Search Engine - Control} /esoc_tb/esoc_tb/u6/u3/reg_search_engine_stat_ctrl_age_timer_ena
add wave -noupdate -group {eSOC Search Engine - Control} -radix hexadecimal /esoc_tb/esoc_tb/u6/u3/reg_search_engine_stat_ctrl_age_timer
add wave -noupdate -group {eSOC Search Engine - Control} /esoc_tb/esoc_tb/u6/u3/search_entry_age_time
add wave -noupdate -group {eSOC Search Engine - Control} -radix unsigned /esoc_tb/esoc_tb/u6/u3/search_sa_drop_cnt
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/reset
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/clk_search
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_sof
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_eof
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_state
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_key
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_key_i
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_hash_delay_cnt
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_table_coll_cnt
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_port_stalled
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_port_stalled_sync
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_result_i
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_result
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_result_av
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_table_address
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_table_address_i
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_table_wren
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_table_data
add wave -noupdate -group {eSOC Search Engine - DA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u0/search_table_q
add wave -noupdate -group {eSOC Search Engine - SA Store} -radix hexadecimal /esoc_tb/esoc_tb/u6/u5/reset
add wave -noupdate -group {eSOC Search Engine - SA Store} -radix hexadecimal /esoc_tb/esoc_tb/u6/u5/clk_search
add wave -noupdate -group {eSOC Search Engine - SA Store} -radix hexadecimal /esoc_tb/esoc_tb/u6/u5/store_sa_state
add wave -noupdate -group {eSOC Search Engine - SA Store} -radix hexadecimal /esoc_tb/esoc_tb/u6/u5/search_sof
add wave -noupdate -group {eSOC Search Engine - SA Store} -radix hexadecimal /esoc_tb/esoc_tb/u6/u5/search_eof
add wave -noupdate -group {eSOC Search Engine - SA Store} -radix hexadecimal /esoc_tb/esoc_tb/u6/u5/search_key
add wave -noupdate -group {eSOC Search Engine - SA Store} -radix hexadecimal /esoc_tb/esoc_tb/u6/u5/search_sa_store_wr
add wave -noupdate -group {eSOC Search Engine - SA Store} -radix hexadecimal /esoc_tb/esoc_tb/u6/u5/search_sa_store_d
add wave -noupdate -group {eSOC Search Engine - SA Store} -radix hexadecimal /esoc_tb/esoc_tb/u6/u5/search_sa_store_full
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/clk_search
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/reset
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_entry_age_time
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_state
add wave -noupdate -group {eSOC Search Engine - SA Processing} /esoc_tb/esoc_tb/u6/u1/search_sa_store_empty
add wave -noupdate -group {eSOC Search Engine - SA Processing} /esoc_tb/esoc_tb/u6/u1/search_sa_store_rd
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_sa_store_q
add wave -noupdate -group {eSOC Search Engine - SA Processing} /esoc_tb/esoc_tb/u6/u1/search_sa_drop_cnt
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_key_i
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix unsigned /esoc_tb/esoc_tb/u6/u1/search_table_coll_cnt
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix unsigned /esoc_tb/esoc_tb/u6/u1/search_hash_delay_cnt
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix unsigned /esoc_tb/esoc_tb/u6/u1/search_table_free_entry_os
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_free_entry
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_sa_drop_cnt
add wave -noupdate -group {eSOC Search Engine - SA Processing} -color {Orange Red} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_wren
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_address
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_address_i
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_data
add wave -noupdate -group {eSOC Search Engine - SA Processing} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_q
add wave -noupdate -group {eSOC Search Engine - SA Aging} /esoc_tb/esoc_tb/u6/u7/clk
add wave -noupdate -group {eSOC Search Engine - SA Aging} /esoc_tb/esoc_tb/u6/u7/clk_count
add wave -noupdate -group {eSOC Search Engine - SA Aging} /esoc_tb/esoc_tb/u6/u7/clk_div
add wave -noupdate -group {eSOC Search Engine - SA Aging} /esoc_tb/esoc_tb/u6/u7/clk_en
add wave -noupdate -group {eSOC Search Engine - SA Aging} /esoc_tb/esoc_tb/u6/u7/reset
add wave -noupdate -group {eSOC Search Engine - SA Aging} /esoc_tb/esoc_tb/u6/esoc_clk_en_gen_div
add wave -noupdate -group {eSOC Search Engine - SA Aging} /esoc_tb/esoc_tb/u6/u1/search_aging_tick
add wave -noupdate -group {eSOC Search Engine - SA Aging} /esoc_tb/esoc_tb/u6/u1/search_entry_age_time_ena
add wave -noupdate -group {eSOC Search Engine - SA Aging} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_entry_age_time
add wave -noupdate -group {eSOC Search Engine - SA Aging} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/aging_state
add wave -noupdate -group {eSOC Search Engine - SA Aging} -radix unsigned /esoc_tb/esoc_tb/u6/u1/aging_count_down
add wave -noupdate -group {eSOC Search Engine - SA Aging} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/aging_address
add wave -noupdate -group {eSOC Search Engine - SA Aging} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_key_i
add wave -noupdate -group {eSOC Search Engine - SA Aging} -color {Orange Red} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_wren
add wave -noupdate -group {eSOC Search Engine - SA Aging} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_address_i
add wave -noupdate -group {eSOC Search Engine - SA Aging} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_address
add wave -noupdate -group {eSOC Search Engine - SA Aging} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_q
add wave -noupdate -group {eSOC Search Engine - SA Aging} -radix hexadecimal /esoc_tb/esoc_tb/u6/u1/search_table_data
add wave -noupdate -divider {eSOC port 0}
add wave -noupdate -group {eSOC Port 0 - SMI} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/mac_mdc
add wave -noupdate -group {eSOC Port 0 - SMI} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/mac_mdio
add wave -noupdate -group {eSOC Port 0 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(0)/esoc_test_smi/smi_cmd
add wave -noupdate -group {eSOC Port 0 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(0)/esoc_test_smi/smi_dev_addr
add wave -noupdate -group {eSOC Port 0 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(0)/esoc_test_smi/smi_dev_reg
add wave -noupdate -group {eSOC Port 0 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(0)/esoc_test_smi/smi_data
add wave -noupdate -group {eSOC Port 0 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(0)/esoc_test_smi/smi_counter
add wave -noupdate -group {eSOC Port 0 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(0)/esoc_test_smi/smi_registers
add wave -noupdate -group {eSOC Port 0 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(0)/esoc_test_smi/smi_state
add wave -noupdate -group {eSOC Port 0 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/ctrl_bus_enable
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/ctrl_address
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/ctrl_wr
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/ctrl_wrdata
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/ctrl_rd
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/ctrl_wait
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/ctrl_rddata
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/mac_address
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/mac_wr
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/mac_rd
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/mac_wait
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/mac_wrdata
add wave -noupdate -group {eSOC Port 0 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/mac_rddata
add wave -noupdate -group {eSOC Port 0 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/esoc_port_nr
add wave -noupdate -group {eSOC Port 0 - MAL Config} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/ctrl_bus_enable
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_sleep
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_wakeup
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xoff_gen
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xon_gen
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/magic_sleep_n
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/magic_wakeup
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/xoff_gen
add wave -noupdate -group {eSOC Port 0 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u3/xon_gen
add wave -noupdate -group {eSOC Port 0 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/rgmii_rxc
add wave -noupdate -group {eSOC Port 0 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/rgmii_rxctl
add wave -noupdate -group {eSOC Port 0 - inbound MAC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/rgmii_rxd
add wave -noupdate -group {eSOC Port 0 - Processor Config} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_bus_enable
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/esoc_port_nr
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reset
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/clk_control
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/clk_data
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/clk_search
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC Port 0 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_vlan_id_wr
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_vlan_id
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_vlan_id_member_in
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/ctrl_vlan_id_member_out
add wave -noupdate -group {eSOC Port 0 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_stat_ctrl
add wave -noupdate -group {eSOC Port 0 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/inbound_done_cnt
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/inbound_drop_cnt
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/outbound_done_cnt
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/outbound_drop_cnt
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/search_done_cnt
add wave -noupdate -group {eSOC Port 0 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/search_drop_cnt
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_clk
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_dsav
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_a_empty
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_a_full
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_sop
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_eop
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} -color yellow /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_rdy
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} -color orange /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_dval
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/clk_control
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_data
add wave -noupdate -group {eSOC Port 0 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_rx_mod
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/reset
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/ff_rx_counter
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/u6/rdusedw
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/u6/wrusedw
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -color yellow -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/boundary64
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/boundary64_write
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/inbound_data
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/inbound_data_full
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/inbound_data_write
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/inbound_header
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/inbound_header_write
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/inbound_info
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/inbound_info_write
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/force_vlan_default_in
add wave -noupdate -group {eSOC Port 0 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u0/port_vlan_default
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/reset
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/clk_data
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/search_data
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/search_empty
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/search_read
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_info
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_info_empty
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_info_read
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_data_read_o
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_data_read
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_data
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_transfer_state
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_drop
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_info_length
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_req
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -color Orange -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_gnt_wr
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/clear_data_req
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_port_sel_o
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_sof_o
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_eof_o
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_o
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_port_sel
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_sof
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data_eof
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/data
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_done_cnt
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u1/inbound_drop_cnt
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_inbound_done_count_i
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC Port 0 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_inbound_drop_count_i
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/reset
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/clk_search
add wave -noupdate -group {eSOC Port 0 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_state
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/inbound_header
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/inbound_header_empty
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/inbound_header_read
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/inbound_vlan_member
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_req
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_gnt_wr
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_sof
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_eof
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_key
add wave -noupdate -group {eSOC Port 0 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_result_av
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_result
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_write
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_data
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_done_cnt
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u0/search_drop_cnt
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_search_done_count_i
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC Port 0 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_search_drop_count_i
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/reset
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/clk_data
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data_port_sel
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data_gnt_rd
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data_sof
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data_eof
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data_port_sel_i
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data_sof_i
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data_eof_i
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data_i
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/data_transfer_state
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_info_length
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_info_counter
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_data_full
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_data_write
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_data
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_info_write
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_info
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_vlan_id
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_vlan_member
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_vlan_member_check
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_done_cnt
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u2/outbound_drop_cnt
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_outbound_done_count_i
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC Port 0 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u1/u3/reg_port_proc_outbound_drop_count_i
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_proc_data_full
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_proc_data
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_proc_data_write
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_proc_info_write
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_proc_info
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -color orange -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_port_data_write
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_port_data
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_port_header_write
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_port_header
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_port_info_write
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_port_info
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/clk_data
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/clk_search
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_proc_data_read
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_proc_data
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_proc_header_empty
add wave -noupdate -group {eSOC Port 0 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_proc_header_read
add wave -noupdate -group {eSOC Port 0 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_proc_header
add wave -noupdate -group {eSOC Port 0 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_proc_info_empty
add wave -noupdate -group {eSOC Port 0 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_proc_info_read
add wave -noupdate -group {eSOC Port 0 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/inbound_proc_info
add wave -noupdate -group {eSOC Port 0 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u1/boundary64
add wave -noupdate -group {eSOC Port 0 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_port_data_read
add wave -noupdate -group {eSOC Port 0 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_port_data
add wave -noupdate -group {eSOC Port 0 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_port_info_empty
add wave -noupdate -group {eSOC Port 0 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_port_info_read
add wave -noupdate -group {eSOC Port 0 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u3/outbound_port_info
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u1/ff_tx_byte_counter
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u1/u1/ff_tx_state
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_clk
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_a_empty
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_a_full
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_septy
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_crc_fwd
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_sop
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_eop
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_rdy
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_wren
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_err
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_data
add wave -noupdate -group {eSOC Port 0 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/u0/ff_tx_mod
add wave -noupdate -group {eSOC Port 0 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/rgmii_txc
add wave -noupdate -group {eSOC Port 0 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/rgmii_txctl
add wave -noupdate -group {eSOC Port 0 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(0)/u0/u0/rgmii_txd
add wave -noupdate -divider {eSOC port 1}
add wave -noupdate -group {eSOC Port 1 - SMI} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/mac_mdc
add wave -noupdate -group {eSOC Port 1 - SMI} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/mac_mdio
add wave -noupdate -group {eSOC Port 1 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(1)/esoc_test_smi/smi_cmd
add wave -noupdate -group {eSOC Port 1 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(1)/esoc_test_smi/smi_dev_addr
add wave -noupdate -group {eSOC Port 1 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(1)/esoc_test_smi/smi_dev_reg
add wave -noupdate -group {eSOC Port 1 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(1)/esoc_test_smi/smi_data
add wave -noupdate -group {eSOC Port 1 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(1)/esoc_test_smi/smi_counter
add wave -noupdate -group {eSOC Port 1 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(1)/esoc_test_smi/smi_registers
add wave -noupdate -group {eSOC Port 1 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(1)/esoc_test_smi/smi_state
add wave -noupdate -group {eSOC port 1 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/ctrl_bus_enable
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/ctrl_address
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/ctrl_wr
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/ctrl_rd
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/ctrl_wait
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/ctrl_wrdata
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/ctrl_rddata
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/mac_address
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/mac_wr
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/mac_rd
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/mac_wait
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/mac_wrdata
add wave -noupdate -group {eSOC port 1 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/mac_rddata
add wave -noupdate -group {eSOC port 1 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/esoc_port_nr
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_sleep
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_wakeup
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xoff_gen
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xon_gen
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/magic_sleep_n
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/magic_wakeup
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/xoff_gen
add wave -noupdate -group {eSOC port 1 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u3/xon_gen
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/esoc_port_nr
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reset
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/clk_control
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/clk_data
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/clk_search
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 1 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_vlan_id_wr
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_vlan_id
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_vlan_id_member_in
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/ctrl_vlan_id_member_out
add wave -noupdate -group {eSOC port 1 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_stat_ctrl
add wave -noupdate -group {eSOC port 1 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/inbound_done_cnt
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/inbound_drop_cnt
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/outbound_done_cnt
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/outbound_drop_cnt
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/search_done_cnt
add wave -noupdate -group {eSOC port 1 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/search_drop_cnt
add wave -noupdate -group {eSOC port 1 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/rgmii_rxc
add wave -noupdate -group {eSOC port 1 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/rgmii_rxctl
add wave -noupdate -group {eSOC port 1 - inbound MAC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/rgmii_rxd
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_clk
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_a_empty
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_a_full
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_dsav
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_sop
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_eop
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} -color yellow /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_rdy
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/u0/wrfull
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/u0/wrusedw
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} -color orange /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_dval
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_data
add wave -noupdate -group {eSOC port 1 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_rx_mod
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/reset
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/clk_control
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u0/ff_rx_counter
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u0/boundary64
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u0/boundary64_write
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_port_data_write
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_port_data
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_port_header_write
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_port_header
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_port_info_write
add wave -noupdate -group {eSOC port 1 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_port_info
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/clk_data
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/clk_search
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_proc_data_read
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_proc_data
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_proc_header_empty
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_proc_header_read
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_proc_header
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_proc_info_empty
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_proc_info_read
add wave -noupdate -group {eSOC port 1 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/inbound_proc_info
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/reset
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/clk_data
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/search_data
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/search_empty
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/search_read
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_info
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_info_empty
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_info_read
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 1 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_data_read_o
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_data_read
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_data
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_transfer_state
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_drop
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_info_length
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_req
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -color Orange -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_gnt_wr
add wave -noupdate -group {eSOC port 1 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/clear_data_req
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_port_sel_o
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_sof_o
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_eof_o
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_o
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_port_sel
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_sof
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data_eof
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/data
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_done_cnt
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u1/inbound_drop_cnt
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_inbound_done_count_i
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 1 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_inbound_drop_count_i
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/reset
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/clk_search
add wave -noupdate -group {eSOC port 1 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_state
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/inbound_header
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/inbound_header_empty
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/inbound_header_read
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/inbound_vlan_member
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_req
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_gnt_wr
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_sof
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_eof
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_key
add wave -noupdate -group {eSOC port 1 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_result_av
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_result
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_write
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_data
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_done_cnt
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u0/search_drop_cnt
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_search_done_count_i
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 1 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_search_drop_count_i
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/reset
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/clk_data
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data_port_sel
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data_gnt_rd
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data_sof
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data_eof
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data_port_sel_i
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data_sof_i
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data_eof_i
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data_i
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/data_transfer_state
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_info_length
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_info_counter
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_data_full
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_data_write
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_data
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_info_write
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_info
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_vlan_id
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_vlan_member
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_vlan_member_check
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_done_cnt
add wave -noupdate -group {eSOC port 1 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u2/outbound_drop_cnt
add wave -noupdate -group {eSOC port 1 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 1 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_outbound_done_count_i
add wave -noupdate -group {eSOC port 1 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 1 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u1/u3/reg_port_proc_outbound_drop_count_i
add wave -noupdate -group {eSOC port 1 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_proc_data_full
add wave -noupdate -group {eSOC port 1 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_proc_data
add wave -noupdate -group {eSOC port 1 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_proc_data_write
add wave -noupdate -group {eSOC port 1 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_proc_info_write
add wave -noupdate -group {eSOC port 1 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_proc_info
add wave -noupdate -group {eSOC port 1 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u1/boundary64
add wave -noupdate -group {eSOC port 1 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_port_data_read
add wave -noupdate -group {eSOC port 1 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_port_data
add wave -noupdate -group {eSOC port 1 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_port_info_empty
add wave -noupdate -group {eSOC port 1 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_port_info_read
add wave -noupdate -group {eSOC port 1 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(1)/u0/u3/outbound_port_info
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u1/u1/ff_tx_state
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_clk
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_a_empty
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_a_full
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_septy
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_crc_fwd
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_sop
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_eop
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_rdy
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_wren
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_err
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_data
add wave -noupdate -group {eSOC port 1 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/u0/ff_tx_mod
add wave -noupdate -group {eSOC port 1 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/rgmii_txc
add wave -noupdate -group {eSOC port 1 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/rgmii_txctl
add wave -noupdate -group {eSOC port 1 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(1)/u0/u0/rgmii_txd
add wave -noupdate -divider {eSOC port 2}
add wave -noupdate -group {eSOC Port 2 - SMI} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/mac_mdc
add wave -noupdate -group {eSOC Port 2 - SMI} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/mac_mdio
add wave -noupdate -group {eSOC Port 2 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(2)/esoc_test_smi/smi_cmd
add wave -noupdate -group {eSOC Port 2 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(2)/esoc_test_smi/smi_dev_addr
add wave -noupdate -group {eSOC Port 2 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(2)/esoc_test_smi/smi_dev_reg
add wave -noupdate -group {eSOC Port 2 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(2)/esoc_test_smi/smi_data
add wave -noupdate -group {eSOC Port 2 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(2)/esoc_test_smi/smi_counter
add wave -noupdate -group {eSOC Port 2 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(2)/esoc_test_smi/smi_registers
add wave -noupdate -group {eSOC Port 2 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(2)/esoc_test_smi/smi_state
add wave -noupdate -group {eSOC port 2 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/ctrl_bus_enable
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/ctrl_address
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/ctrl_wr
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/ctrl_rd
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/ctrl_wait
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/ctrl_wrdata
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/ctrl_rddata
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/mac_address
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/mac_wr
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/mac_rd
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/mac_wait
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/mac_wrdata
add wave -noupdate -group {eSOC port 2 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/mac_rddata
add wave -noupdate -group {eSOC port 2 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/esoc_port_nr
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_sleep
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_wakeup
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xoff_gen
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xon_gen
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/magic_sleep_n
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/magic_wakeup
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/xoff_gen
add wave -noupdate -group {eSOC port 2 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u3/xon_gen
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/esoc_port_nr
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reset
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/clk_control
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/clk_data
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/clk_search
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 2 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_vlan_id_wr
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_vlan_id
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_vlan_id_member_in
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/ctrl_vlan_id_member_out
add wave -noupdate -group {eSOC port 2 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_stat_ctrl
add wave -noupdate -group {eSOC port 2 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/inbound_done_cnt
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/inbound_drop_cnt
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/outbound_done_cnt
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/outbound_drop_cnt
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/search_done_cnt
add wave -noupdate -group {eSOC port 2 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/search_drop_cnt
add wave -noupdate -group {eSOC port 2 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/rgmii_rxc
add wave -noupdate -group {eSOC port 2 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/rgmii_rxctl
add wave -noupdate -group {eSOC port 2 - inbound MAC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/rgmii_rxd
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_clk
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_a_empty
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_a_full
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_dsav
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_sop
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_eop
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} -color yellow /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_rdy
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/u0/wrfull
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/u0/wrusedw
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} -color orange /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_dval
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_data
add wave -noupdate -group {eSOC port 2 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_rx_mod
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/reset
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/clk_control
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u0/ff_rx_counter
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u0/boundary64
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u0/boundary64_write
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_port_data_write
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_port_data
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_port_header_write
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_port_header
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_port_info_write
add wave -noupdate -group {eSOC port 2 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_port_info
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/clk_data
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/clk_search
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_proc_data_read
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_proc_data
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_proc_header_empty
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_proc_header_read
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_proc_header
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_proc_info_empty
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_proc_info_read
add wave -noupdate -group {eSOC port 2 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/inbound_proc_info
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/reset
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/clk_data
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/search_data
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/search_empty
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/search_read
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_info
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_info_empty
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_info_read
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 2 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_data_read_o
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_data_read
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_data
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_transfer_state
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_drop
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_info_length
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_req
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -color Orange -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_gnt_wr
add wave -noupdate -group {eSOC port 2 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/clear_data_req
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_port_sel_o
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_sof_o
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_eof_o
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_o
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_port_sel
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_sof
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data_eof
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/data
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_done_cnt
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u1/inbound_drop_cnt
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_inbound_done_count_i
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 2 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_inbound_drop_count_i
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/reset
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/clk_search
add wave -noupdate -group {eSOC port 2 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_state
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/inbound_header
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/inbound_header_empty
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/inbound_header_read
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/inbound_vlan_member
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_req
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_gnt_wr
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_sof
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_eof
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_key
add wave -noupdate -group {eSOC port 2 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_result_av
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_result
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_write
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_data
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_done_cnt
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u0/search_drop_cnt
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_search_done_count_i
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 2 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_search_drop_count_i
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/reset
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/clk_data
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data_port_sel
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data_gnt_rd
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data_sof
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data_eof
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data_port_sel_i
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data_sof_i
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data_eof_i
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data_i
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/data_transfer_state
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_info_length
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_info_counter
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_data_full
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_data_write
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_data
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_info_write
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_info
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_vlan_id
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_vlan_member
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_vlan_member_check
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_done_cnt
add wave -noupdate -group {eSOC port 2 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u2/outbound_drop_cnt
add wave -noupdate -group {eSOC port 2 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 2 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_outbound_done_count_i
add wave -noupdate -group {eSOC port 2 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 2 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u1/u3/reg_port_proc_outbound_drop_count_i
add wave -noupdate -group {eSOC port 2 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_proc_data_full
add wave -noupdate -group {eSOC port 2 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_proc_data
add wave -noupdate -group {eSOC port 2 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_proc_data_write
add wave -noupdate -group {eSOC port 2 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_proc_info_write
add wave -noupdate -group {eSOC port 2 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_proc_info
add wave -noupdate -group {eSOC port 2 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u1/boundary64
add wave -noupdate -group {eSOC port 2 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_port_data_read
add wave -noupdate -group {eSOC port 2 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_port_data
add wave -noupdate -group {eSOC port 2 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_port_info_empty
add wave -noupdate -group {eSOC port 2 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_port_info_read
add wave -noupdate -group {eSOC port 2 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(2)/u0/u3/outbound_port_info
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u1/u1/ff_tx_state
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_clk
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_a_empty
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_a_full
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_septy
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_crc_fwd
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_sop
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_eop
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_rdy
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_wren
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_err
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_data
add wave -noupdate -group {eSOC port 2 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/u0/ff_tx_mod
add wave -noupdate -group {eSOC port 2 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/rgmii_txc
add wave -noupdate -group {eSOC port 2 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/rgmii_txctl
add wave -noupdate -group {eSOC port 2 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(2)/u0/u0/rgmii_txd
add wave -noupdate -divider {eSOC port 3}
add wave -noupdate -group {eSOC Port 3 - SMI} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/mac_mdc
add wave -noupdate -group {eSOC Port 3 - SMI} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/mac_mdio
add wave -noupdate -group {eSOC Port 3 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(3)/esoc_test_smi/smi_cmd
add wave -noupdate -group {eSOC Port 3 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(3)/esoc_test_smi/smi_dev_addr
add wave -noupdate -group {eSOC Port 3 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(3)/esoc_test_smi/smi_dev_reg
add wave -noupdate -group {eSOC Port 3 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(3)/esoc_test_smi/smi_data
add wave -noupdate -group {eSOC Port 3 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(3)/esoc_test_smi/smi_counter
add wave -noupdate -group {eSOC Port 3 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(3)/esoc_test_smi/smi_registers
add wave -noupdate -group {eSOC Port 3 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(3)/esoc_test_smi/smi_state
add wave -noupdate -group {eSOC port 3 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/ctrl_bus_enable
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/ctrl_address
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/ctrl_wr
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/ctrl_rd
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/ctrl_wait
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/ctrl_wrdata
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/ctrl_rddata
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/mac_address
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/mac_wr
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/mac_rd
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/mac_wait
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/mac_wrdata
add wave -noupdate -group {eSOC port 3 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/mac_rddata
add wave -noupdate -group {eSOC port 3 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/esoc_port_nr
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_sleep
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_wakeup
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xoff_gen
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xon_gen
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/magic_sleep_n
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/magic_wakeup
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/xoff_gen
add wave -noupdate -group {eSOC port 3 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u3/xon_gen
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/esoc_port_nr
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reset
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/clk_control
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/clk_data
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/clk_search
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 3 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_vlan_id_wr
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_vlan_id
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_vlan_id_member_in
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/ctrl_vlan_id_member_out
add wave -noupdate -group {eSOC port 3 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_stat_ctrl
add wave -noupdate -group {eSOC port 3 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/inbound_done_cnt
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/inbound_drop_cnt
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/outbound_done_cnt
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/outbound_drop_cnt
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/search_done_cnt
add wave -noupdate -group {eSOC port 3 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/search_drop_cnt
add wave -noupdate -group {eSOC port 3 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/rgmii_rxc
add wave -noupdate -group {eSOC port 3 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/rgmii_rxctl
add wave -noupdate -group {eSOC port 3 - inbound MAC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/rgmii_rxd
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_clk
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_a_empty
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_a_full
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_dsav
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_sop
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_eop
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} -color yellow /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_rdy
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/u0/wrfull
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/u0/wrusedw
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} -color orange /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_dval
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_data
add wave -noupdate -group {eSOC port 3 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_rx_mod
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/reset
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/clk_control
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u0/ff_rx_counter
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u0/boundary64
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u0/boundary64_write
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_port_data_write
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_port_data
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_port_header_write
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_port_header
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_port_info_write
add wave -noupdate -group {eSOC port 3 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_port_info
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/clk_data
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/clk_search
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_proc_data_read
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_proc_data
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_proc_header_empty
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_proc_header_read
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_proc_header
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_proc_info_empty
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_proc_info_read
add wave -noupdate -group {eSOC port 3 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/inbound_proc_info
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/reset
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/clk_data
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/search_data
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/search_empty
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/search_read
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_info
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_info_empty
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_info_read
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 3 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_data_read_o
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_data_read
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_data
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_transfer_state
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_drop
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_info_length
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_req
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -color Orange -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_gnt_wr
add wave -noupdate -group {eSOC port 3 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/clear_data_req
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_port_sel_o
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_sof_o
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_eof_o
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_o
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_port_sel
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_sof
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data_eof
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/data
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_done_cnt
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u1/inbound_drop_cnt
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_inbound_done_count_i
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 3 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_inbound_drop_count_i
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/reset
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/clk_search
add wave -noupdate -group {eSOC port 3 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_state
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/inbound_header
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/inbound_header_empty
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/inbound_header_read
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/inbound_vlan_member
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_req
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_gnt_wr
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_sof
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_eof
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_key
add wave -noupdate -group {eSOC port 3 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_result_av
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_result
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_write
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_data
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_done_cnt
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u0/search_drop_cnt
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_search_done_count_i
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 3 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_search_drop_count_i
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/reset
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/clk_data
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data_port_sel
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data_gnt_rd
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data_sof
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data_eof
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data_port_sel_i
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data_sof_i
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data_eof_i
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data_i
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/data_transfer_state
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_info_length
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_info_counter
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_data_full
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_data_write
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_data
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_info_write
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_info
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_vlan_id
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_vlan_member
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_vlan_member_check
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_done_cnt
add wave -noupdate -group {eSOC port 3 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u2/outbound_drop_cnt
add wave -noupdate -group {eSOC port 3 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 3 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_outbound_done_count_i
add wave -noupdate -group {eSOC port 3 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 3 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u1/u3/reg_port_proc_outbound_drop_count_i
add wave -noupdate -group {eSOC port 3 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_proc_data_full
add wave -noupdate -group {eSOC port 3 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_proc_data
add wave -noupdate -group {eSOC port 3 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_proc_data_write
add wave -noupdate -group {eSOC port 3 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_proc_info_write
add wave -noupdate -group {eSOC port 3 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_proc_info
add wave -noupdate -group {eSOC port 3 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u1/boundary64
add wave -noupdate -group {eSOC port 3 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_port_data_read
add wave -noupdate -group {eSOC port 3 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_port_data
add wave -noupdate -group {eSOC port 3 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_port_info_empty
add wave -noupdate -group {eSOC port 3 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_port_info_read
add wave -noupdate -group {eSOC port 3 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(3)/u0/u3/outbound_port_info
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u1/u1/ff_tx_state
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_clk
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_a_empty
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_a_full
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_septy
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_crc_fwd
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_sop
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_eop
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_rdy
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_wren
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_err
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_data
add wave -noupdate -group {eSOC port 3 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/u0/ff_tx_mod
add wave -noupdate -group {eSOC port 3 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/rgmii_txc
add wave -noupdate -group {eSOC port 3 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/rgmii_txctl
add wave -noupdate -group {eSOC port 3 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(3)/u0/u0/rgmii_txd
add wave -noupdate -divider {eSOC port 4}
add wave -noupdate -group {eSOC Port 4 - SMI} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/mac_mdc
add wave -noupdate -group {eSOC Port 4 - SMI} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/mac_mdio
add wave -noupdate -group {eSOC Port 4 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(4)/esoc_test_smi/smi_cmd
add wave -noupdate -group {eSOC Port 4 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(4)/esoc_test_smi/smi_dev_addr
add wave -noupdate -group {eSOC Port 4 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(4)/esoc_test_smi/smi_dev_reg
add wave -noupdate -group {eSOC Port 4 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(4)/esoc_test_smi/smi_data
add wave -noupdate -group {eSOC Port 4 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(4)/esoc_test_smi/smi_counter
add wave -noupdate -group {eSOC Port 4 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(4)/esoc_test_smi/smi_registers
add wave -noupdate -group {eSOC Port 4 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(4)/esoc_test_smi/smi_state
add wave -noupdate -group {eSOC port 4 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/ctrl_bus_enable
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/ctrl_address
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/ctrl_wr
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/ctrl_rd
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/ctrl_wait
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/ctrl_wrdata
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/ctrl_rddata
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/mac_address
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/mac_wr
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/mac_rd
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/mac_wait
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/mac_wrdata
add wave -noupdate -group {eSOC port 4 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/mac_rddata
add wave -noupdate -group {eSOC port 4 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/esoc_port_nr
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_sleep
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_wakeup
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xoff_gen
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xon_gen
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/magic_sleep_n
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/magic_wakeup
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/xoff_gen
add wave -noupdate -group {eSOC port 4 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u3/xon_gen
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/esoc_port_nr
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reset
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/clk_control
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/clk_data
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/clk_search
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 4 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_vlan_id_wr
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_vlan_id
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_vlan_id_member_in
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/ctrl_vlan_id_member_out
add wave -noupdate -group {eSOC port 4 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_stat_ctrl
add wave -noupdate -group {eSOC port 4 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/inbound_done_cnt
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/inbound_drop_cnt
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/outbound_done_cnt
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/outbound_drop_cnt
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/search_done_cnt
add wave -noupdate -group {eSOC port 4 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/search_drop_cnt
add wave -noupdate -group {eSOC port 4 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/rgmii_rxc
add wave -noupdate -group {eSOC port 4 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/rgmii_rxctl
add wave -noupdate -group {eSOC port 4 - inbound MAC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/rgmii_rxd
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_clk
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_a_empty
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_a_full
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_dsav
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_sop
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_eop
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} -color yellow /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_rdy
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/u0/wrfull
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/u0/wrusedw
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} -color orange /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_dval
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_data
add wave -noupdate -group {eSOC port 4 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_rx_mod
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/reset
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/clk_control
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u0/ff_rx_counter
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u0/boundary64
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u0/boundary64_write
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_port_data_write
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_port_data
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_port_header_write
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_port_header
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_port_info_write
add wave -noupdate -group {eSOC port 4 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_port_info
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/clk_data
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/clk_search
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_proc_data_read
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_proc_data
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_proc_header_empty
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_proc_header_read
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_proc_header
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_proc_info_empty
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_proc_info_read
add wave -noupdate -group {eSOC port 4 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/inbound_proc_info
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/reset
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/clk_data
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/search_data
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/search_empty
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/search_read
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_info
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_info_empty
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_info_read
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 4 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_data_read_o
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_data_read
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_data
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_transfer_state
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_drop
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_info_length
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_req
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -color Orange -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_gnt_wr
add wave -noupdate -group {eSOC port 4 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/clear_data_req
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_port_sel_o
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_sof_o
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_eof_o
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_o
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_port_sel
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_sof
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data_eof
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/data
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_done_cnt
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u1/inbound_drop_cnt
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_inbound_done_count_i
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 4 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_inbound_drop_count_i
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/reset
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/clk_search
add wave -noupdate -group {eSOC port 4 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_state
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/inbound_header
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/inbound_header_empty
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/inbound_header_read
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/inbound_vlan_member
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_req
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_gnt_wr
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_sof
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_eof
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_key
add wave -noupdate -group {eSOC port 4 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_result_av
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_result
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_write
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_data
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_done_cnt
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u0/search_drop_cnt
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_search_done_count_i
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 4 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_search_drop_count_i
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/reset
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/clk_data
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data_port_sel
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data_gnt_rd
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data_sof
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data_eof
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data_port_sel_i
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data_sof_i
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data_eof_i
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data_i
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/data_transfer_state
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_info_length
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_info_counter
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_data_full
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_data_write
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_data
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_info_write
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_info
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_vlan_id
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_vlan_member
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_vlan_member_check
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_done_cnt
add wave -noupdate -group {eSOC port 4 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u2/outbound_drop_cnt
add wave -noupdate -group {eSOC port 4 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 4 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_outbound_done_count_i
add wave -noupdate -group {eSOC port 4 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 4 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u1/u3/reg_port_proc_outbound_drop_count_i
add wave -noupdate -group {eSOC port 4 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_proc_data_full
add wave -noupdate -group {eSOC port 4 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_proc_data
add wave -noupdate -group {eSOC port 4 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_proc_data_write
add wave -noupdate -group {eSOC port 4 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_proc_info_write
add wave -noupdate -group {eSOC port 4 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_proc_info
add wave -noupdate -group {eSOC port 4 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u1/boundary64
add wave -noupdate -group {eSOC port 4 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_port_data_read
add wave -noupdate -group {eSOC port 4 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_port_data
add wave -noupdate -group {eSOC port 4 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_port_info_empty
add wave -noupdate -group {eSOC port 4 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_port_info_read
add wave -noupdate -group {eSOC port 4 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(4)/u0/u3/outbound_port_info
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u1/u1/ff_tx_state
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_clk
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_a_empty
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_a_full
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_septy
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_crc_fwd
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_sop
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_eop
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_rdy
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_wren
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_err
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_data
add wave -noupdate -group {eSOC port 4 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/u0/ff_tx_mod
add wave -noupdate -group {eSOC port 4 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/rgmii_txc
add wave -noupdate -group {eSOC port 4 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/rgmii_txctl
add wave -noupdate -group {eSOC port 4 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(4)/u0/u0/rgmii_txd
add wave -noupdate -divider {eSOC port 5}
add wave -noupdate -group {eSOC Port 5 - SMI} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/mac_mdc
add wave -noupdate -group {eSOC Port 5 - SMI} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/mac_mdio
add wave -noupdate -group {eSOC Port 5 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(5)/esoc_test_smi/smi_cmd
add wave -noupdate -group {eSOC Port 5 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(5)/esoc_test_smi/smi_dev_addr
add wave -noupdate -group {eSOC Port 5 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(5)/esoc_test_smi/smi_dev_reg
add wave -noupdate -group {eSOC Port 5 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(5)/esoc_test_smi/smi_data
add wave -noupdate -group {eSOC Port 5 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(5)/esoc_test_smi/smi_counter
add wave -noupdate -group {eSOC Port 5 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(5)/esoc_test_smi/smi_registers
add wave -noupdate -group {eSOC Port 5 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(5)/esoc_test_smi/smi_state
add wave -noupdate -group {eSOC port 5 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/ctrl_bus_enable
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/ctrl_address
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/ctrl_wr
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/ctrl_rd
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/ctrl_wait
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/ctrl_wrdata
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/ctrl_rddata
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/mac_address
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/mac_wr
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/mac_rd
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/mac_wait
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/mac_wrdata
add wave -noupdate -group {eSOC port 5 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/mac_rddata
add wave -noupdate -group {eSOC port 5 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/esoc_port_nr
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_sleep
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_wakeup
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xoff_gen
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xon_gen
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/magic_sleep_n
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/magic_wakeup
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/xoff_gen
add wave -noupdate -group {eSOC port 5 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u3/xon_gen
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/esoc_port_nr
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reset
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/clk_control
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/clk_data
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/clk_search
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 5 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_vlan_id_wr
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_vlan_id
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_vlan_id_member_in
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/ctrl_vlan_id_member_out
add wave -noupdate -group {eSOC port 5 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_stat_ctrl
add wave -noupdate -group {eSOC port 5 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/inbound_done_cnt
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/inbound_drop_cnt
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/outbound_done_cnt
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/outbound_drop_cnt
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/search_done_cnt
add wave -noupdate -group {eSOC port 5 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/search_drop_cnt
add wave -noupdate -group {eSOC port 5 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/rgmii_rxc
add wave -noupdate -group {eSOC port 5 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/rgmii_rxctl
add wave -noupdate -group {eSOC port 5 - inbound MAC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/rgmii_rxd
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_clk
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_a_empty
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_a_full
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_dsav
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_sop
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_eop
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} -color yellow /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_rdy
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/u0/wrfull
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/u0/wrusedw
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} -color orange /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_dval
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_data
add wave -noupdate -group {eSOC port 5 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_rx_mod
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/reset
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/clk_control
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u0/ff_rx_counter
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u0/boundary64
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u0/boundary64_write
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_port_data_write
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_port_data
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_port_header_write
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_port_header
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_port_info_write
add wave -noupdate -group {eSOC port 5 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_port_info
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/clk_data
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/clk_search
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_proc_data_read
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_proc_data
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_proc_header_empty
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_proc_header_read
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_proc_header
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_proc_info_empty
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_proc_info_read
add wave -noupdate -group {eSOC port 5 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/inbound_proc_info
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/reset
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/clk_data
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/search_data
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/search_empty
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/search_read
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_info
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_info_empty
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_info_read
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 5 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_data_read_o
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_data_read
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_data
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_transfer_state
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_drop
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_info_length
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_req
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -color Orange -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_gnt_wr
add wave -noupdate -group {eSOC port 5 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/clear_data_req
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_port_sel_o
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_sof_o
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_eof_o
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_o
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_port_sel
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_sof
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data_eof
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/data
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_done_cnt
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u1/inbound_drop_cnt
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_inbound_done_count_i
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 5 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_inbound_drop_count_i
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/reset
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/clk_search
add wave -noupdate -group {eSOC port 5 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_state
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/inbound_header
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/inbound_header_empty
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/inbound_header_read
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/inbound_vlan_member
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_req
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_gnt_wr
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_sof
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_eof
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_key
add wave -noupdate -group {eSOC port 5 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_result_av
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_result
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_write
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_data
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_done_cnt
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u0/search_drop_cnt
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_search_done_count_i
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 5 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_search_drop_count_i
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/reset
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/clk_data
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data_port_sel
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data_gnt_rd
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data_sof
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data_eof
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data_port_sel_i
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data_sof_i
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data_eof_i
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data_i
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/data_transfer_state
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_info_length
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_info_counter
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_data_full
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_data_write
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_data
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_info_write
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_info
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_vlan_id
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_vlan_member
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_vlan_member_check
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_done_cnt
add wave -noupdate -group {eSOC port 5 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u2/outbound_drop_cnt
add wave -noupdate -group {eSOC port 5 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 5 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_outbound_done_count_i
add wave -noupdate -group {eSOC port 5 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 5 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u1/u3/reg_port_proc_outbound_drop_count_i
add wave -noupdate -group {eSOC port 5 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_proc_data_full
add wave -noupdate -group {eSOC port 5 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_proc_data
add wave -noupdate -group {eSOC port 5 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_proc_data_write
add wave -noupdate -group {eSOC port 5 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_proc_info_write
add wave -noupdate -group {eSOC port 5 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_proc_info
add wave -noupdate -group {eSOC port 5 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u1/boundary64
add wave -noupdate -group {eSOC port 5 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_port_data_read
add wave -noupdate -group {eSOC port 5 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_port_data
add wave -noupdate -group {eSOC port 5 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_port_info_empty
add wave -noupdate -group {eSOC port 5 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_port_info_read
add wave -noupdate -group {eSOC port 5 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(5)/u0/u3/outbound_port_info
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u1/u1/ff_tx_state
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_clk
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_a_empty
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_a_full
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_septy
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_crc_fwd
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_sop
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_eop
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_rdy
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_wren
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_err
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_data
add wave -noupdate -group {eSOC port 5 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/u0/ff_tx_mod
add wave -noupdate -group {eSOC port 5 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/rgmii_txc
add wave -noupdate -group {eSOC port 5 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/rgmii_txctl
add wave -noupdate -group {eSOC port 5 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(5)/u0/u0/rgmii_txd
add wave -noupdate -divider {eSOC port 6}
add wave -noupdate -group {eSOC Port 6 - SMI} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/mac_mdc
add wave -noupdate -group {eSOC Port 6 - SMI} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/mac_mdio
add wave -noupdate -group {eSOC Port 6 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(6)/esoc_test_smi/smi_cmd
add wave -noupdate -group {eSOC Port 6 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(6)/esoc_test_smi/smi_dev_addr
add wave -noupdate -group {eSOC Port 6 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(6)/esoc_test_smi/smi_dev_reg
add wave -noupdate -group {eSOC Port 6 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(6)/esoc_test_smi/smi_data
add wave -noupdate -group {eSOC Port 6 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(6)/esoc_test_smi/smi_counter
add wave -noupdate -group {eSOC Port 6 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(6)/esoc_test_smi/smi_registers
add wave -noupdate -group {eSOC Port 6 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(6)/esoc_test_smi/smi_state
add wave -noupdate -group {eSOC port 6 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/ctrl_bus_enable
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/ctrl_address
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/ctrl_wr
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/ctrl_rd
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/ctrl_wait
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/ctrl_wrdata
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/ctrl_rddata
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/mac_address
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/mac_wr
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/mac_rd
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/mac_wait
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/mac_wrdata
add wave -noupdate -group {eSOC port 6 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/mac_rddata
add wave -noupdate -group {eSOC port 6 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/esoc_port_nr
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_sleep
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_wakeup
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xoff_gen
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xon_gen
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/magic_sleep_n
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/magic_wakeup
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/xoff_gen
add wave -noupdate -group {eSOC port 6 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u3/xon_gen
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/esoc_port_nr
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reset
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/clk_control
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/clk_data
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/clk_search
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 6 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_vlan_id_wr
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_vlan_id
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_vlan_id_member_in
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/ctrl_vlan_id_member_out
add wave -noupdate -group {eSOC port 6 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_stat_ctrl
add wave -noupdate -group {eSOC port 6 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/inbound_done_cnt
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/inbound_drop_cnt
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/outbound_done_cnt
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/outbound_drop_cnt
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/search_done_cnt
add wave -noupdate -group {eSOC port 6 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/search_drop_cnt
add wave -noupdate -group {eSOC port 6 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/rgmii_rxc
add wave -noupdate -group {eSOC port 6 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/rgmii_rxctl
add wave -noupdate -group {eSOC port 6 - inbound MAC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/rgmii_rxd
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_clk
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_a_empty
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_a_full
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_dsav
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_sop
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_eop
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} -color yellow /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_rdy
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/u0/wrfull
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/u0/wrusedw
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} -color orange /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_dval
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_data
add wave -noupdate -group {eSOC port 6 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_rx_mod
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/reset
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/clk_control
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u0/ff_rx_counter
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u0/boundary64
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u0/boundary64_write
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_port_data_write
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_port_data
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_port_header_write
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_port_header
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_port_info_write
add wave -noupdate -group {eSOC port 6 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_port_info
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/clk_data
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/clk_search
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_proc_data_read
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_proc_data
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_proc_header_empty
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_proc_header_read
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_proc_header
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_proc_info_empty
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_proc_info_read
add wave -noupdate -group {eSOC port 6 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/inbound_proc_info
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/reset
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/clk_data
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/search_data
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/search_empty
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/search_read
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_info
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_info_empty
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_info_read
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 6 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_data_read_o
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_data_read
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_data
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_transfer_state
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_drop
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_info_length
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_req
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -color Orange -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_gnt_wr
add wave -noupdate -group {eSOC port 6 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/clear_data_req
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_port_sel_o
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_sof_o
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_eof_o
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_o
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_port_sel
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_sof
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data_eof
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/data
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_done_cnt
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u1/inbound_drop_cnt
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_inbound_done_count_i
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 6 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_inbound_drop_count_i
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/reset
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/clk_search
add wave -noupdate -group {eSOC port 6 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_state
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/inbound_header
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/inbound_header_empty
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/inbound_header_read
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/inbound_vlan_member
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_req
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_gnt_wr
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_sof
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_eof
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_key
add wave -noupdate -group {eSOC port 6 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_result_av
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_result
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_write
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_data
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_done_cnt
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u0/search_drop_cnt
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_search_done_count_i
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 6 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_search_drop_count_i
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/reset
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/clk_data
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data_port_sel
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data_gnt_rd
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data_sof
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data_eof
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data_port_sel_i
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data_sof_i
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data_eof_i
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data_i
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/data_transfer_state
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_info_length
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_info_counter
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_data_full
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_data_write
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_data
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_info_write
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_info
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_vlan_id
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_vlan_member
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_vlan_member_check
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_done_cnt
add wave -noupdate -group {eSOC port 6 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u2/outbound_drop_cnt
add wave -noupdate -group {eSOC port 6 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 6 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_outbound_done_count_i
add wave -noupdate -group {eSOC port 6 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 6 - Outbound PROC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u1/u3/reg_port_proc_outbound_drop_count_i
add wave -noupdate -group {eSOC port 6 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_proc_data_full
add wave -noupdate -group {eSOC port 6 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_proc_data
add wave -noupdate -group {eSOC port 6 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_proc_data_write
add wave -noupdate -group {eSOC port 6 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_proc_info_write
add wave -noupdate -group {eSOC port 6 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_proc_info
add wave -noupdate -group {eSOC port 6 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u1/boundary64
add wave -noupdate -group {eSOC port 6 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_port_data_read
add wave -noupdate -group {eSOC port 6 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_port_data
add wave -noupdate -group {eSOC port 6 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_port_info_empty
add wave -noupdate -group {eSOC port 6 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_port_info_read
add wave -noupdate -group {eSOC port 6 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(6)/u0/u3/outbound_port_info
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u1/u1/ff_tx_state
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_clk
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_a_empty
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_a_full
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_septy
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_crc_fwd
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_sop
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_eop
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_rdy
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_wren
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_err
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_data
add wave -noupdate -group {eSOC port 6 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/u0/ff_tx_mod
add wave -noupdate -group {eSOC port 6 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/rgmii_txc
add wave -noupdate -group {eSOC port 6 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/rgmii_txctl
add wave -noupdate -group {eSOC port 6 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(6)/u0/u0/rgmii_txd
add wave -noupdate -divider {eSOC port 7}
add wave -noupdate -group {eSOC Port 7 - SMI} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/mac_mdc
add wave -noupdate -group {eSOC Port 7 - SMI} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/mac_mdio
add wave -noupdate -group {eSOC Port 7 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(7)/esoc_test_smi/smi_cmd
add wave -noupdate -group {eSOC Port 7 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(7)/esoc_test_smi/smi_dev_addr
add wave -noupdate -group {eSOC Port 7 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(7)/esoc_test_smi/smi_dev_reg
add wave -noupdate -group {eSOC Port 7 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(7)/esoc_test_smi/smi_data
add wave -noupdate -group {eSOC Port 7 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(7)/esoc_test_smi/smi_counter
add wave -noupdate -group {eSOC Port 7 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(7)/esoc_test_smi/smi_registers
add wave -noupdate -group {eSOC Port 7 - SMI} -radix hexadecimal /esoc_tb/esoc_test_smi(7)/esoc_test_smi/smi_state
add wave -noupdate -group {eSOC port 7 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/ctrl_bus_enable
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/ctrl_address
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/ctrl_wr
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/ctrl_rd
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/ctrl_wait
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/ctrl_wrdata
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/ctrl_rddata
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/mac_address
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/mac_wr
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/mac_rd
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/mac_wait
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/mac_wrdata
add wave -noupdate -group {eSOC port 7 - MAC Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/mac_rddata
add wave -noupdate -group {eSOC port 7 - MAC Config} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/esoc_port_nr
add wave -noupdate -group {eSOC port 7 - MAL Config} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/ctrl_bus_enable
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_sleep
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_magic_wakeup
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xoff_gen
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/reg_port_mal_stat_ctrl_xon_gen
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/magic_sleep_n
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/magic_wakeup
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/xoff_gen
add wave -noupdate -group {eSOC port 7 - MAL Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u3/xon_gen
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/esoc_port_nr
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reset
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/clk_control
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/clk_data
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/clk_search
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_address
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_wait
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_rd
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_rddata
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_wr
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_wrdata
add wave -noupdate -group {eSOC port 7 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_vlan_id_wr
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_vlan_id
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_vlan_id_member_in
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/ctrl_vlan_id_member_out
add wave -noupdate -group {eSOC port 7 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_stat_ctrl
add wave -noupdate -group {eSOC port 7 - Processor Config} -divider <NULL>
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/inbound_done_cnt
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/inbound_drop_cnt
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/outbound_done_cnt
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/outbound_drop_cnt
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/search_done_cnt
add wave -noupdate -group {eSOC port 7 - Processor Config} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/search_drop_cnt
add wave -noupdate -group {eSOC port 7 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/rgmii_rxc
add wave -noupdate -group {eSOC port 7 - inbound MAC} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/rgmii_rxctl
add wave -noupdate -group {eSOC port 7 - inbound MAC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/rgmii_rxd
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_clk
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_a_empty
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_a_full
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_dsav
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_sop
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_eop
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} -color yellow /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_rdy
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/u0/wrfull
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/u0/wrusedw
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} -color orange /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_dval
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_data
add wave -noupdate -group {eSOC port 7 - inbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_rx_mod
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/reset
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/clk_control
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u0/ff_rx_counter
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u0/boundary64
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u0/boundary64_write
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_port_data_full
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_port_data_write
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_port_data
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_port_header_write
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_port_header
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_port_info_write
add wave -noupdate -group {eSOC port 7 - Inbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_port_info
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/clk_data
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/clk_search
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_proc_data_read
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_proc_data
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_proc_header_empty
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_proc_header_read
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_proc_header
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_proc_info_empty
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_proc_info_read
add wave -noupdate -group {eSOC port 7 - Inbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/inbound_proc_info
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/reset
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/clk_data
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/search_data
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/search_empty
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/search_read
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_info
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_info_empty
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_info_read
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 7 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_data_read_o
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_data_read
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_data
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_transfer_state
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_drop
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_info_length
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_req
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -color Orange -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_gnt_wr
add wave -noupdate -group {eSOC port 7 - Inbound PROC} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/clear_data_req
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_port_sel_o
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_sof_o
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_eof_o
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_o
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_port_sel
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_sof
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data_eof
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/data
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -divider <NULL>
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_done_cnt
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u1/inbound_drop_cnt
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_inbound_done_count
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_inbound_done_count_i
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_inbound_drop_count
add wave -noupdate -group {eSOC port 7 - Inbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_inbound_drop_count_i
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/reset
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/clk_search
add wave -noupdate -group {eSOC port 7 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_state
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/inbound_header
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/inbound_header_empty
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/inbound_header_read
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/inbound_vlan_member
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_req
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_gnt_wr
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_sof
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_eof
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_key
add wave -noupdate -group {eSOC port 7 - Search PROC} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_result_av
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_result
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_write
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_data
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_done_cnt
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u0/search_drop_cnt
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_search_done_count
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_search_done_count_i
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_search_drop_count
add wave -noupdate -group {eSOC port 7 - Search PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_search_drop_count_i
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/reset
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/clk_data
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data_port_sel
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data_gnt_rd
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data_sof
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data_eof
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data_port_sel_i
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data_sof_i
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data_eof_i
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data_i
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/data_transfer_state
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_info_length
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_info_counter
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_data_full
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_data_write
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_data
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_info_write
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_info
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_vlan_id
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_vlan_member
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_vlan_member_check
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_done_cnt
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u2/outbound_drop_cnt
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_outbound_done_count
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_outbound_done_count_i
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_outbound_drop_count
add wave -noupdate -group {eSOC port 7 - Outbound PROC} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u1/u3/reg_port_proc_outbound_drop_count_i
add wave -noupdate -group {eSOC port 7 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_proc_data_full
add wave -noupdate -group {eSOC port 7 - Outbound PROC FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/u0/wrfull
add wave -noupdate -group {eSOC port 7 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_proc_data
add wave -noupdate -group {eSOC port 7 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_proc_data_write
add wave -noupdate -group {eSOC port 7 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_proc_info_write
add wave -noupdate -group {eSOC port 7 - Outbound PROC FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_proc_info
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/clk_control
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/ff_tx_state
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/port_vlan_default
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/force_vlan_default_out
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/u0/rdempty
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/boundary64
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_port_data_read
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/outbound_data_read_enable
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/outbound_data_read_dummy
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/outbound_data_modify_enable
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/outbound_data_modify
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_port_data
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_port_info_empty
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_port_info_read
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u3/outbound_port_info
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/outbound_info_vlan_flag
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/ff_tx_byte_counter
add wave -noupdate -group {eSOC port 7 - Outbound PORT FIFO} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/ff_tx_word_counter
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/ff_tx_state
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_clk
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_a_empty
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_a_full
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_septy
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_crc_fwd
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_sop
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_eop
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_rdy
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_wren
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_err
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u1/u1/ff_tx_word_counter
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} -radix hexadecimal /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_data
add wave -noupdate -group {eSOC port 7 - outbound Avalon ST} -radix unsigned /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/u0/ff_tx_mod
add wave -noupdate -group {eSOC port 7 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/rgmii_txc
add wave -noupdate -group {eSOC port 7 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/rgmii_txctl
add wave -noupdate -group {eSOC port 7 - outbound MAC} /esoc_tb/esoc_tb/esoc_ports(7)/u0/u0/rgmii_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {33286630 ps} 0} {{Cursor 4} {109807794 ps} 0}
configure wave -namecolwidth 226
configure wave -valuecolwidth 127
configure wave -justifyvalue right
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {124540500 ps}
