function check_executable {
	if [ ! -x $1 ]; then
		echo "$1 does not exist or is not executable."
		exit 0
	fi
}

function map {
	if [ ! -d ../out/$1 ] ; then
		vlib ../out/$1
		vmap $1 $2
	fi;
}
