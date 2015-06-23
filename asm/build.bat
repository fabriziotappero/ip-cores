@echo off
set ASM_OPTS=-80 -h -x7 -o20 -p70 -Ddb=.db -Dorg=.org -Dsll=sli -Ddw=.dw -Daseg=.cseg -Dend=.end

set FILES=180_ops 180_opsd alu_ops alu_opsd dat_mov dat_movd int_ops int_opsd int_opss ez8_ops ez8_opsd

for %%f in (%FILES%) do (
	tasm %ASM_OPTS% %%f.s %%f.hex %%f.lst && ihex2vm %%f.hex %%f.vm
	if errorlevel 1 (
		pause
		goto :eof
	)
)
