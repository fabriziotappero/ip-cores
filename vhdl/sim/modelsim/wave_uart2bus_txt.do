onerror {resume}
virtual type { \
Idle\
HiNib\
{0x4 LoNib}\
{0x5 CharCR}\
{0x6 CharLF}\
{default undefined_state}\
} vt_tx
virtual type { \
Idle\
White1\
Data\
White2\
Addr\
Eol\
{0x8 BinCmd}\
{0x9 BinAdrh}\
{0xa BinAdrl}\
{0xb BinLen}\
{0xc BinData}\
{default undefined_state}\
} vt_main
quietly virtual signal -install /uart2bustop_txt_tb/uut/up {/uart2bustop_txt_tb/uut/up/mainsm  } vs_main
quietly virtual signal -install /uart2bustop_txt_tb/uut/up {/uart2bustop_txt_tb/uut/up/txsm  } vs_tx
quietly virtual function -install /uart2bustop_txt_tb/uut/up -env /uart2bustop_txt_tb { (vt_main) /uart2bustop_txt_tb/uut/up/vs_main} vf_main
quietly virtual function -install /uart2bustop_txt_tb/uut/up -env /uart2bustop_txt_tb { (vt_tx) /uart2bustop_txt_tb/uut/up/vs_tx} vf_tx
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {global signals}
add wave -noupdate -format Logic /uart2bustop_txt_tb/clr
add wave -noupdate -format Logic /uart2bustop_txt_tb/clk
add wave -noupdate -divider {UART serial signals}
add wave -noupdate -format Logic /uart2bustop_txt_tb/serin
add wave -noupdate -format Logic /uart2bustop_txt_tb/serout
add wave -noupdate -divider {Internal bus to register file}
add wave -noupdate -format Logic /uart2bustop_txt_tb/intaccessreq
add wave -noupdate -format Logic /uart2bustop_txt_tb/intaccessgnt
add wave -noupdate -format Literal -radix hexadecimal /uart2bustop_txt_tb/intrddata
add wave -noupdate -format Literal -radix hexadecimal /uart2bustop_txt_tb/intaddress
add wave -noupdate -format Literal -radix hexadecimal /uart2bustop_txt_tb/intwrdata
add wave -noupdate -format Logic /uart2bustop_txt_tb/intwrite
add wave -noupdate -format Logic /uart2bustop_txt_tb/intread
add wave -noupdate -divider Debug
add wave -noupdate -format Literal -radix hexadecimal /uart2bustop_txt_tb/recvdata
add wave -noupdate -format Logic /uart2bustop_txt_tb/newrxdata
add wave -noupdate -format Literal /uart2bustop_txt_tb/uut/up/vf_main
add wave -noupdate -format Literal /uart2bustop_txt_tb/uut/up/vf_tx
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 200
configure wave -valuecolwidth 40
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {52500 us}
