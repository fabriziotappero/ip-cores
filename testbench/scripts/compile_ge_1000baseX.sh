
#!/bin/bash

LIBRARY_NAME=ge_1000baseX_lib
LIBRARY_DIRECTORY=./$LIBRARY_NAME

MODULES="rtl/verilog"

INCLUDES=""

for m in $MODULES; do
  INCLUDES="$INCLUDES +incdir+../$m"
done


if [[ $# != 0 ]]; then
  echo "Only building modules:" $*
  MODULES=$*
else
  if [ -x $LIBRARY_DIRECTORY ]; then 
    echo "Removing libraries..."
    mv -f $LIBRARY_DIRECTORY ${LIBRARY_DIRECTORY}_tmp
    rm -r -f ${LIBRARY_DIRECTORY}_tmp &
  fi
  vlib $LIBRARY_DIRECTORY
  vmap $LIBRARY_NAME $LIBRARY_DIRECTORY
fi

OPTS="-quiet -sv"

for m in $MODULES; do
  files=`find ../$m -name "*.v" | egrep -v "unused|ASIC|Alternate"`

  for f in $files; do
    echo "Compiling $f"
    if ! vlog -work $LIBRARY_NAME $OPTS $INCLUDES $f; then
      echo "COMPILE FAILED!"
      exit
    fi
  done
done

date

