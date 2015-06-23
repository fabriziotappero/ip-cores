#!/bin/bash

for txt in *.txt; do
    ucf=${txt%*.txt}.ucf
    xdc=${txt%*.txt}.xdc
    tf=${txt%*.txt}.tmp
    
    rm -f $tf
    [ -f "${txt%*.txt}.repl" ] && cp ${txt%*.txt}.repl $tf
    cat convert.repl >> $tf
    
    echo "# !!! Constraint files are application specific !!!" > $ucf
    echo "# !!!          This is a template only          !!!" >> $ucf
    echo -e "\n# on-board signals\n" >> $ucf

    echo "# !!! Constraint files are application specific !!!" > $xdc
    echo "# !!!          This is a template only          !!!" >> $xdc
    echo -e "\n# on-board signals\n" >> $xdc

    
    pa=""
    while read a b c; do
	if [ "$pa" != "" -a "$a" = "" ]; then
	    echo >> $ucf
	    echo >> $xdc
	fi
	if [ "$a" = "-" ]; then
	    if [ "$c" != "" ]; then
		case "$b" in
		    "CLKOUT/FXCLK")
			echo "# CLKOUT/FXCLK " >> $ucf
			echo "NET \"fxclk_in\" TNM_NET = \"fxclk_in\";" >> $ucf
			echo "TIMESPEC \"ts_fxclk_in\" = PERIOD \"fxclk_in\" 48 MHz HIGH 50 %;" >> $ucf
			echo "NET \"fxclk_in\"  LOC = \"$c\" | IOSTANDARD = LVCMOS33 ;" >> $ucf

			echo "# CLKOUT/FXCLK " >> $xdc
			echo "create_clock -name fxclk_in -period 20.833 [get_ports fxclk_in]" >> $xdc
			echo "set_property PACKAGE_PIN $c [get_ports fxclk_in]" >> $xdc
			echo "set_property IOSTANDARD LVCMOS33 [get_ports fxclk_in]" >> $xdc
			;;
		    "IFCLK")
			echo "# IFCLK " >> $ucf
			echo "NET \"ifclk_in\" TNM_NET = \"ifclk_in\";" >> $ucf
			echo "TIMESPEC \"ts_ifclk_in\" = PERIOD \"ifclk_in\" 48 MHz HIGH 50 %;" >> $ucf
			echo "NET \"ifclk_in\"  LOC = \"$c\" | IOSTANDARD = LVCMOS33 ;" >> $ucf

			echo "# IFCLK " >> $xdc
			echo "create_clock -name ifclk_in -period 20.833 [get_ports ifclk_in]" >> $xdc
			echo "set_property PACKAGE_PIN $c [get_ports ifclk_in]" >> $xdc
			echo "set_property IOSTANDARD LVCMOS33 [get_ports ifclk_in]" >> $xdc
			;;
		    *)
			b2=`echo "$b" | tr -d "*" `
			c2=`grep -i -m 1 -x "$b2.*" $tf | ( read a b c; echo $b )`
			if [ "$c2" != "" ]; then
			    echo "NET \"$c2\"	LOC = \"$c\" | IOSTANDARD = LVCMOS33 ;		# $b2"  | tr "[]" "<>" >> $ucf

#			echo -e "\n# $b2" >> $xdc
#			echo "set_property PACKAGE_PIN $c [get_ports {$c2}]" >> $xdc
			echo -e "\nset_property PACKAGE_PIN $c [get_ports {$c2}]  		;# $b2" >> $xdc
			echo "set_property IOSTANDARD LVCMOS33 [get_ports {$c2}]" >> $xdc
			else 
			    echo "Unknown signal: $b" >&2
			    echo "$b" >> convert.unknown
			fi
			;;
		esac
	    fi
	    pa=$a
	else 
	    pa=""
	fi
    done < $txt

    echo -e "\n# external I/O\n" >> $ucf
    echo -e "\n\n# external I/O" >> $xdc

    rm -f $tf
    pa=""
    while read a b c; do
	if [ "$a" != "-" -a "$c" != "" ]; then
	    echo "$a	$c	$a / $b" >> $tf
	fi	    
    done < $txt
    
    pa="A"
    cnt=0
    sort -V $tf | while read a b c; do
	a0=${a:0:1} 
	if [ "$a0" != "$pa" ]; then
	    cnt=0
	    echo >> $ucf
	    echo >> $xdc
	fi
	echo "NET \"IO_$a0<$cnt>\"	LOC = \"$b\" | IOSTANDARD = LVCMOS33 ;		# $c"  >> $ucf

#	echo -e "\n# $c" >> $xdc
#	echo "set_property PACKAGE_PIN $b [get_ports {IO_$a0[$cnt]}]" >> $xdc
	echo -e "\nset_property PACKAGE_PIN $b [get_ports {IO_$a0[$cnt]}]		;# $c" >> $xdc
	echo "set_property IOSTANDARD LVCMOS33 [get_ports {IO_$a0[$cnt]}]" >> $xdc
	
	let "cnt+=1"
	pa=$a0
    done

    rm -f $tf
done