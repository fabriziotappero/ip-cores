if test -d work
then
echo work is ready
else
vlib work
echo work is created
fi

vlog -f vlog-$1.list 

if test $? -ne 0
then
echo compiling err occured...
exit 1
fi

