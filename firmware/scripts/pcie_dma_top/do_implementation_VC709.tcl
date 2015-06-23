set IMPL_RUN [get_runs impl*]
set SYNTH_RUN [get_runs synth*]
set PROJECT_NAME "pcie_dma_top_VC709"
set scriptdir [pwd]
set HDLDIR $scriptdir/../../

foreach design [get_designs] {
   puts "Closing design: $design"
   current_design $design
   close_design
}

reset_run $SYNTH_RUN

set svn_hash [exec svn info]
set svn_hash_lines [split $svn_hash "\n"]
set svn_version "0"
cd $HDLDIR
foreach line $svn_hash_lines {
   if [regexp {Last Changed Rev: } $line ] {
      set svn_version [ lindex [split $line] 3 ]
   }
}
cd $scriptdir

puts "SVN_VERSION = $svn_version"


set systemTime [clock seconds]
set build_date "40'h[clock format $systemTime -format %y%m%d%H%M]"
puts "BUILD_DATE = $build_date"


set_property is_enabled false [get_files  $HDLDIR/constraints/pcie_dma_top_HTG710.xdc]
set_property is_enabled true [get_files  $HDLDIR/constraints/pcie_dma_top_VC709.xdc]

#set to true in order to generate the GBT links
set NUMBER_OF_INTERRUPTS 8
set NUMBER_OF_DESCRIPTORS 8

set_property generic "BUILD_DATETIME=$build_date SVN_VERSION=$svn_version NUMBER_OF_INTERRUPTS=$NUMBER_OF_INTERRUPTS NUMBER_OF_DESCRIPTORS=$NUMBER_OF_DESCRIPTORS" [current_fileset]

launch_runs $SYNTH_RUN
launch_runs $IMPL_RUN 
#launch_runs $IMPL_RUN  -to_step write_bitstream
#cd $HDLDIR/Synt/
wait_on_run $IMPL_RUN
set TIMESTAMP [clock format $systemTime -format {%y%m%d_%H_%M}]



open_run $IMPL_RUN
current_run $IMPL_RUN

write_bitstream $HDLDIR/output/${PROJECT_NAME}_${TIMESTAMP}.bit

cd $HDLDIR/output/


set BitFile ${PROJECT_NAME}_$TIMESTAMP.bit
set IMPL_DIR [get_property DIRECTORY [current_run]]

write_cfgmem -force -format MCS -size 128 -interface BPIx16 -loadbit "up 0x00000000 $BitFile" ${PROJECT_NAME}_$TIMESTAMP.mcs
if {[file exists $IMPL_DIR/debug_nets.ltx] == 1} {
   file copy $IMPL_DIR/debug_nets.ltx ${PROJECT_NAME}_debug_nets_$TIMESTAMP.ltx
}


cd $scriptdir
