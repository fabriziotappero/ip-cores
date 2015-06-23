EESchema Schematic File Version 2  date Sat 17 Dec 2011 02:52:46 PM CET
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:gpibComponents
LIBS:usbToGpib-cache
EELAYER 25  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 4 21
Title ""
Date "15 dec 2011"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 7100 4300 2    60   Input ~ 0
GND
Text HLabel 7100 3450 2    60   Input ~ 0
VCC
Wire Wire Line
	7100 4300 5700 4300
Wire Wire Line
	5050 6400 4000 6400
Wire Wire Line
	5050 5700 4000 5700
Wire Wire Line
	5050 5000 4000 5000
Wire Wire Line
	5050 4300 4000 4300
Wire Wire Line
	5050 3600 4000 3600
Wire Wire Line
	5050 3450 4000 3450
Wire Wire Line
	5050 2750 4000 2750
Wire Wire Line
	5050 2050 4000 2050
Wire Wire Line
	5050 1350 4000 1350
Connection ~ 6100 2900
Wire Wire Line
	6100 2200 5700 2200
Connection ~ 6100 4300
Wire Wire Line
	6100 3600 5700 3600
Connection ~ 6100 5700
Wire Wire Line
	6100 5000 5700 5000
Connection ~ 6000 5550
Wire Wire Line
	5700 6250 6000 6250
Wire Wire Line
	6000 6250 6000 1350
Connection ~ 6000 4150
Wire Wire Line
	6000 4850 5700 4850
Connection ~ 6000 2750
Wire Wire Line
	6000 1350 5700 1350
Wire Wire Line
	6000 2050 5700 2050
Wire Wire Line
	6000 2750 5700 2750
Connection ~ 6000 2050
Wire Wire Line
	6000 4150 5700 4150
Connection ~ 6000 3450
Wire Wire Line
	6000 5550 5700 5550
Connection ~ 6000 4850
Wire Wire Line
	5700 6400 6100 6400
Wire Wire Line
	6100 5700 5700 5700
Connection ~ 6100 5000
Wire Wire Line
	6100 2900 5700 2900
Connection ~ 6100 3600
Wire Wire Line
	6100 6400 6100 1500
Wire Wire Line
	6100 1500 5700 1500
Connection ~ 6100 2200
Wire Wire Line
	5050 1500 4000 1500
Wire Wire Line
	5050 2200 4000 2200
Wire Wire Line
	5050 2900 4000 2900
Wire Wire Line
	5050 4150 4000 4150
Wire Wire Line
	5050 4850 4000 4850
Wire Wire Line
	5050 5550 4000 5550
Wire Wire Line
	5050 6250 4000 6250
Wire Wire Line
	7100 3450 5700 3450
Text HLabel 4000 6400 0    60   Input ~ 0
D7_out
Text HLabel 4000 6250 0    60   Input ~ 0
D7_in
Text HLabel 4000 5700 0    60   Input ~ 0
D6_out
Text HLabel 4000 5550 0    60   Input ~ 0
D6_in
Text HLabel 4000 5000 0    60   Input ~ 0
D5_out
Text HLabel 4000 4850 0    60   Input ~ 0
D5_in
Text HLabel 4000 4300 0    60   Input ~ 0
D4_out
Text HLabel 4000 4150 0    60   Input ~ 0
D4_in
Text HLabel 4000 3600 0    60   Input ~ 0
D3_out
Text HLabel 4000 3450 0    60   Input ~ 0
D3_in
Text HLabel 4000 2900 0    60   Input ~ 0
D2_out
Text HLabel 4000 2750 0    60   Input ~ 0
D2_in
Text HLabel 4000 2200 0    60   Input ~ 0
D1_out
Text HLabel 4000 2050 0    60   Input ~ 0
D1_in
Text HLabel 4000 1500 0    60   Input ~ 0
D0_out
Text HLabel 4000 1350 0    60   Input ~ 0
D0_in
$Sheet
S 5050 6150 650  350 
U 4EE3C33E
F0 "D7" 60
F1 "ocIo.sch" 60
F2 "IN" I L 5050 6250 60 
F3 "GND" I R 5700 6400 60 
F4 "OUT" I L 5050 6400 60 
F5 "VCC" I R 5700 6250 60 
$EndSheet
$Sheet
S 5050 5450 650  350 
U 4EE3C320
F0 "D6" 60
F1 "ocIo.sch" 60
F2 "IN" I L 5050 5550 60 
F3 "GND" I R 5700 5700 60 
F4 "OUT" I L 5050 5700 60 
F5 "VCC" I R 5700 5550 60 
$EndSheet
$Sheet
S 5050 4750 650  350 
U 4EE3C2D8
F0 "D5" 60
F1 "ocIo.sch" 60
F2 "IN" I L 5050 4850 60 
F3 "GND" I R 5700 5000 60 
F4 "OUT" I L 5050 5000 60 
F5 "VCC" I R 5700 4850 60 
$EndSheet
$Sheet
S 5050 4050 650  350 
U 4EE3C2B3
F0 "D4" 60
F1 "ocIo.sch" 60
F2 "IN" I L 5050 4150 60 
F3 "GND" I R 5700 4300 60 
F4 "OUT" I L 5050 4300 60 
F5 "VCC" I R 5700 4150 60 
$EndSheet
$Sheet
S 5050 3350 650  350 
U 4EE3DF45
F0 "D3" 60
F1 "ocIo.sch" 60
F2 "IN" I L 5050 3450 60 
F3 "GND" I R 5700 3600 60 
F4 "OUT" I L 5050 3600 60 
F5 "VCC" I R 5700 3450 60 
$EndSheet
$Sheet
S 5050 2650 650  350 
U 4EE3C22A
F0 "D2" 60
F1 "ocIo.sch" 60
F2 "IN" I L 5050 2750 60 
F3 "GND" I R 5700 2900 60 
F4 "OUT" I L 5050 2900 60 
F5 "VCC" I R 5700 2750 60 
$EndSheet
$Sheet
S 5050 1950 650  350 
U 4EE3C0EB
F0 "D1" 60
F1 "ocIo.sch" 60
F2 "IN" I L 5050 2050 60 
F3 "GND" I R 5700 2200 60 
F4 "OUT" I L 5050 2200 60 
F5 "VCC" I R 5700 2050 60 
$EndSheet
$Sheet
S 5050 1250 650  350 
U 4EE3BBD0
F0 "D0" 60
F1 "ocIo.sch" 60
F2 "IN" I L 5050 1350 60 
F3 "GND" I R 5700 1500 60 
F4 "OUT" I L 5050 1500 60 
F5 "VCC" I R 5700 1350 60 
$EndSheet
$EndSCHEMATC
