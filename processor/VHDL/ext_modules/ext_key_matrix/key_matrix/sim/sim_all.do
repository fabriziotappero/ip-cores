  project compileall
  vsim work.key_matrix_tb
  quietly WaveActivateNextPane {} 0
  add wave -noupdate -divider Testbench
  add wave -noupdate -format Logic -label sys_clk /key_matrix_tb/sys_clk
  add wave -noupdate -format Logic -label sys_res_n /key_matrix_tb/sys_res_n
  add wave -noupdate -format Literal -label columns /key_matrix_tb/columns
  add wave -noupdate -format Literal -label rows /key_matrix_tb/rows
  add wave -noupdate -format Literal -label key -radix hexadecimal /key_matrix_tb/key
  add wave -noupdate -format Logic -label stop /key_matrix_tb/stop
  add wave -noupdate -divider {Key Matrix}
  add wave -noupdate -format Literal -label key_matrix_state /key_matrix_tb/uut/key_matrix_state
  add wave -noupdate -format Literal -label key_matrix_state_next /key_matrix_tb/uut/key_matrix_state_next
  add wave -noupdate -format Literal -label rows_debounced /key_matrix_tb/uut/rows_debounced
  add wave -noupdate -format Literal -label rows_debounced_old /key_matrix_tb/uut/rows_debounced_old
  add wave -noupdate -format Literal -label rows_debounced_old_next /key_matrix_tb/uut/rows_debounced_old_next
  add wave -noupdate -format Logic -label debouncer_reinit /key_matrix_tb/uut/debouncer_reinit
  add wave -noupdate -format Literal -label debouncer_reinit_value /key_matrix_tb/uut/debouncer_reinit_value
  add wave -noupdate -format Literal -label interval /key_matrix_tb/uut/interval
  add wave -noupdate -format Literal -label interval_next /key_matrix_tb/uut/interval_next
  add wave -noupdate -format Literal -label current_column /key_matrix_tb/uut/current_column
  add wave -noupdate -format Literal -label current_column_next /key_matrix_tb/uut/current_column_next
  add wave -noupdate -format Literal -label key_next -radix hexadecimal /key_matrix_tb/uut/key_next
  TreeUpdate [SetDefaultTree]
  update
  run -all
