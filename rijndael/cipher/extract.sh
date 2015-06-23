if [ ! -z $1 ]; then
  awk -F? '{print $2}' $1 | sed -e 's/ //g' | uniq.exe | sed -e 's/^/0x/'
else
  echo "Usage $0: asimut-keyexpansion-output-file"
fi
