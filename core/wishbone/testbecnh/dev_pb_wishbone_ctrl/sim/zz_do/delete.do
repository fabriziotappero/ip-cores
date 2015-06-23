#
# Define req:
#
quietly set LIBS [ list work ]

quietly set LOG_0_FILES [glob -nocomplain -type f trans_*]
quietly set LOG_1_FILES [glob -nocomplain -type f *.log]
quietly set DAT_FILES   [glob -nocomplain -type f *.dat]
quietly set LOG_VAWES   [glob -nocomplain -type f vsim_*]




#
# Define PROC:
#
proc delete {arg} {
	foreach item $arg {
		if {[file exists $item]} {
			file delete -force $item
		}
	}
}


#
# RUN:
#
delete $LIBS
delete $LOG_0_FILES
delete $LOG_1_FILES
delete $DAT_FILES
delete $LOG_VAWES

#
# MSG and EXIT:
#
echo Timestamp for DS_DMA Libs delete:
set val [clock format [clock seconds] -format "%A %B %d %H:%M:%S"]
exit 