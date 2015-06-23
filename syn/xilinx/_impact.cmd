setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:TRUE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:TRUE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setMode -bs
setPreference -pref UserLevel:Novice
setMode -pff
setMode -mpm
setMode -cf
setMode -dtconfig
setMode -bsfile
setMode -sm
setMode -ss
setMode -bs
addDevice -position 1 -part "xc3s200"
addDevice -position 2 -part "xcf02s"
setAttribute -position 2 -attr configFileName -value "F:\yacc\syn\xilinx\Untitled.mcs"

setCable -port lpt1
setMode -bs
setMode -bs
setMode -ss
setMode -sm
setMode -bsfile
setMode -dtconfig
setMode -cf
setMode -mpm
setMode -pff
setMode -bs
Program -p 2 -e -v 
 -pff
setMode -pff
setSubmode -pffserial
setAttribute -configdevice -attr name -value "PFFConfigDevice"
setAttribute -configdevice -attr size -value "0"
addCollection -name "Untitled"
setAttribute -collection -attr dir -value "UP"
addDesign -version 0 -name "0000"
addDeviceChain -index 0
addDevice -position 1 -file "F:\yacc\syn\xilinx\s3_vsmpl.bit"
setMode -pff
setAttribute -configdevice -attr fillValue -value "FF"
setAttribute -configdevice -attr fileFormat -value "mcs"
setAttribute -collection -attr dir -value "UP"
setAttribute -configdevice -attr path -value "f:\yacc\syn\xilinx/"
setAttribute -collection -attr name -value "Untitled"
generate -generic
setCurrentDesign -version 0
