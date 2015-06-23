#! /bin/sh
# The tests pass if three things happen:
# 1) runs to completion
# 2) does not print any lines with "FAIL"
# 3) a wrapper program successfully verifies MATCH/EXPECTED output

# The names of tests to run, or ""/"all".
test_list="$@"
[ "$test_list" == "" ] && test_list=all

test="driver"
source ./test-utils.sh

fail_count=0
pass_count=0

for test in `cd ${srcdir} && ls -1 *.test`
do
    if [ "${test_list}" != "all" ]
    then
	cases="`echo ${test_list} | sed -e 's/ /,/g' | sed -e 's/,/|/g'`"
	# Use an eval here so that $cases gets evaluated first.
	eval "case $test in \
	$cases) ;; \
	*) continue ;; \
	esac"
    fi

    if ${SHELL} ${srcdir}/$test
    then
	pass_count=$(( ${pass_count} + 1 ))
    else
	fail_count=$(( ${fail_count} + 1 ))
    fi
done

echo ""
echo "Test summary:"
echo "# failures: ${fail_count}"
echo "# passes:   ${pass_count}"

if [ ${fail_count} == 0 ]
then
    exit 0
else
    exit 1
fi
