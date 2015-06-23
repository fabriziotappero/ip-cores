setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:FALSE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:FALSE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setMode -bs
setCable -port usb21
Identify
setAttribute -position 1 -attr devicePartName -value "xc18v04"
setAttribute -position 1 -attr configFileName -value "gr-cpci-xc2v_0.mcs"
setAttribute -position 2 -attr devicePartName -value "xc18v04"
setAttribute -position 2 -attr configFileName -value "gr-cpci-xc2v_1.mcs"
setAttribute -position 3 -attr devicePartName -value "xc18v04"
setAttribute -position 3 -attr configFileName -value "gr-cpci-xc2v_2.mcs"
setAttribute -position 4 -attr devicePartName -value "xc18v04"
setAttribute -position 4 -attr configFileName -value "gr-cpci-xc2v_3.mcs"
setAttribute -position 5 -attr devicePartName -value "xc18v04"
setAttribute -position 5 -attr configFileName -value "gr-cpci-xc2v_4.mcs"
setAttribute -position 6 -attr devicePartName -value "xc18v04"
setAttribute -position 6 -attr configFileName -value "gr-cpci-xc2v_5.mcs"

Program -p 1 2 3 4 5 6 -e -v 
quit
