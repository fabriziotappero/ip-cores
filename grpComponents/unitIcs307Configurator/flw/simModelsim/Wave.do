onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tbics307configurator/clk
add wave -noupdate -format Logic /tbics307configurator/nresetasync
add wave -noupdate -format Logic /tbics307configurator/strobe
add wave -noupdate -format Logic /tbics307configurator/sclk
add wave -noupdate -format Logic /tbics307configurator/data
add wave -noupdate -format Logic /tbics307configurator/ics307configurator_1/iclk
add wave -noupdate -format Logic /tbics307configurator/ics307configurator_1/inresetasync
add wave -noupdate -format Logic /tbics307configurator/ics307configurator_1/osclk
add wave -noupdate -format Logic /tbics307configurator/ics307configurator_1/odata
add wave -noupdate -format Logic /tbics307configurator/ics307configurator_1/ostrobe
add wave -noupdate -format Literal /tbics307configurator/ics307configurator_1/r
add wave -noupdate -format Literal /tbics307configurator/ics307configurator_1/nxr
add wave -noupdate -format Logic /tbics307configurator/pwronresetsource/onresetasync
add wave -noupdate -format Logic /tbics307configurator/ics307_1/isclk
add wave -noupdate -format Logic /tbics307configurator/ics307_1/idata
add wave -noupdate -format Logic /tbics307configurator/ics307_1/istrobe
add wave -noupdate -format Logic /tbics307configurator/ics307_1/oclk1
add wave -noupdate -format Literal /tbics307configurator/ics307_1/shiftin
add wave -noupdate -format Logic /tbics307configurator/ics307_1/genclock
add wave -noupdate -format Literal /tbics307configurator/ics307_1/clk1currentperiod
add wave -noupdate -format Literal /tbics307configurator/ics307_1/deltaperiod
add wave -noupdate -format Literal /tbics307configurator/ics307_1/clk1targetperiod
add wave -noupdate -format Literal /tbics307configurator/ics307_1/targettime
add wave -noupdate -format Analog-Step -height 200 -offset -8000000.0 -radix decimal -scale 5.0000000000000004e-006 /tbics307configurator/ics307_1/genclkcycle/vclk1currentperiod
add wave -noupdate -format Literal /tbics307configurator/ics307_1/genclkcycle/vtimetospendintransition
add wave -noupdate -format Literal /tbics307configurator/ics307_1/newtargetperiod/vdatareceived
add wave -noupdate -format Literal /tbics307configurator/ics307_1/newtargetperiod/voutdiv
add wave -noupdate -format Literal /tbics307configurator/ics307_1/newtargetperiod/vvdw
add wave -noupdate -format Literal /tbics307configurator/ics307_1/newtargetperiod/vrdw
add wave -noupdate -format Literal /tbics307configurator/ics307_1/newtargetperiod/vcyclestospendintransition
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1325026712388 fs} 0}
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 fs} {6300042 ns}
