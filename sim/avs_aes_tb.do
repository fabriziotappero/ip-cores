onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Avalon Interface}
add wave -noupdate -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/clk
add wave -noupdate -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/reset
add wave -noupdate -format Literal -radix hexadecimal -expand /avs_aes_tb/testresult
add wave -noupdate -format Literal -radix hexadecimal -expand /avs_aes_tb/expected
add wave -noupdate -expand -group {Avalon signals}
add wave -noupdate -group {Avalon signals} -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/avs_s1_address
add wave -noupdate -group {Avalon signals} -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/avs_s1_chipselect
add wave -noupdate -group {Avalon signals} -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/avs_s1_irq
add wave -noupdate -group {Avalon signals} -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/avs_s1_read
add wave -noupdate -group {Avalon signals} -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/avs_s1_readdata
add wave -noupdate -group {Avalon signals} -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/avs_s1_write
add wave -noupdate -group {Avalon signals} -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/avs_s1_writedata
add wave -noupdate -group {Avalon signals} -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/avs_s1_waitrequest
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/ctrl_reg
add wave -noupdate -divider Core
add wave -noupdate -expand -group Common
add wave -noupdate -group Common -format Logic /avs_aes_tb/avs_aes_1/keyexp_done
add wave -noupdate -group Common -format Logic /avs_aes_tb/avs_aes_1/decrypt_mode
add wave -noupdate -group Common -format Logic /avs_aes_tb/avs_aes_1/data_stable
add wave -noupdate -group Common -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/data_in
add wave -noupdate -group Common -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_idx
add wave -noupdate -group Common -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey
add wave -noupdate -group Common -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/finished
add wave -noupdate -group Common -color Gold -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/result
add wave -noupdate -expand -group Encrypt
add wave -noupdate -group Encrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/fsm_enc/fsm
add wave -noupdate -group Encrypt -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/finished_enc
add wave -noupdate -group Encrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_idx_enc
add wave -noupdate -group Encrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/addkey_in_enc
add wave -noupdate -group Encrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/addkey_out_enc
add wave -noupdate -group Encrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/sbox_out_enc
add wave -noupdate -group Encrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/addkey_out_enc
add wave -noupdate -group Encrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/addkey_in_enc
add wave -noupdate -group Encrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/mixcol_out_enc
add wave -noupdate -expand -group Decrypt
add wave -noupdate -group Decrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/decrypt_datapath/fsm_dec/fsm
add wave -noupdate -group Decrypt -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/finished_dec
add wave -noupdate -group Decrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_idx_dec
add wave -noupdate -group Decrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/addkey_in_dec
add wave -noupdate -group Decrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/addkey_out_dec
add wave -noupdate -group Decrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/shiftrow_in_dec
add wave -noupdate -group Decrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/shiftrow_out_dec
add wave -noupdate -group Decrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/sbox_out_dec
add wave -noupdate -group Decrypt -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/mixcol_out_dec
add wave -noupdate -divider keyexpansion
add wave -noupdate -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/key_stable
add wave -noupdate -group userkey
add wave -noupdate -group userkey -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/keyword
add wave -noupdate -group userkey -format Logic -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/w_ena_keyword
add wave -noupdate -group userkey -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/keyshiftreg_in
add wave -noupdate -group userkey -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/keywordaddr
add wave -noupdate -group Keymemory
add wave -noupdate -group Keymemory -format Logic /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/w_ena_keymem
add wave -noupdate -group Keymemory -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/keymem
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/keyshiftreg_in
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/keyshiftreg_out
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/to_sbox
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/from_sbox
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/roundconstant
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/xorrcon_out
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/last_word
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/xor_lastblock_in
add wave -noupdate -format Literal -radix hexadecimal /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/expstate
add wave -noupdate -format Literal -radix unsigned /avs_aes_tb/avs_aes_1/aes_core_1/roundkey_generator/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2670 ns} 0} {{Cursor 2} {11620 ns} 0}
configure wave -namecolwidth 173
configure wave -valuecolwidth 115
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 40
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {2624 ns} {2748 ns}
