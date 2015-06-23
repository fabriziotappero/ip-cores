if [ "$1" = "" ]; then
    echo "Usage: $0 <bitstream>"
    exit 1
fi    
../../../java/FWLoader -c -uu standalone.ihx -ue standalone.ihx -um $1

