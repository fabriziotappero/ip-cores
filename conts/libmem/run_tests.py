#!/usr/bin/python
import os
import shutil
from os.path import join
import sys

project_root = join(os.getcwd(), "../..")
source_root = os.path.join(project_root, 'src')
headers_root = os.path.join(project_root, 'include')
tests_run_root = os.path.join(os.getcwd(), 'tmp')
tools_root = os.getcwd()

init_state = "page_init.out"
exit_state = "page_exit.out"
SZ_10MB = 1024 * 1024 * 10

def power(x, y):
	res = 1
	for i in range(y):
		res = res * x;
	return res

def test_mm():
	'''
	Tries to set up meaningful input parameters for page_size, maximum allocation
	size, total number of allocations, and total pages, and tests the memory allocator
	in every one of these combinations. The parameter guessing is not great, but at least
	some test cases are reasonable.
	'''
	page_sizes = [128, 256, 512, 1024, 2048, 4096, 8192]
	max_alloc_sizes = [1, 10, 40, 50, 100, 200]

	for page_size in page_sizes:
		numpages = SZ_10MB / page_size
		for i in range(1, 3):
			res = numpages / power(10, i)	# Divide numpages to 10, 100, 1000
			if res > 0:
				max_alloc_sizes.append(numpages/10)
				max_alloc_sizes.append(numpages/100)
				max_alloc_sizes.append(numpages/1000)
		for max_alloc_size in max_alloc_sizes:
			if max_alloc_size >= numpages:	# If a single allocation exceeds total, adjust.
				max_alloc_size = numpages / 2
			num_allocs = numpages / (max_alloc_size) * 2 * 2 / 3
			cmd = "./test -a=p -n=%d -s=%d -fi=%s -fx=%s -ps=%d -pn=%d" % \
			       (num_allocs, max_alloc_size, join(tests_run_root, init_state),\
				join(tests_run_root, exit_state), page_size, numpages)
			print "num_allocs = %d, max_alloc_size = %d, page_size = %d, numpages = %d" % \
				(num_allocs, max_alloc_size, page_size, numpages)
			os.system(cmd)
			#os.system("cat %s" % join(tests_run_root, init_state))
			diffcmd = "diff " + join(tests_run_root, init_state) + " " + join(tests_run_root, exit_state)
			if os.system(diffcmd) != 0:
				print "Error: %s has failed.\n" % cmd
				sys.exit(1)

def test_km():
	'''
	Tries to set up meaningful input parameters for payload size, maximum allocation
	size, total number of allocations, and total pages, and tests kmalloc
	in every one of these combinations. The parameter guessing is not great, but at least
	some test cases are reasonable.
	'''
	page_sizes = [4096, 8192]
	max_alloc_sizes = [1, 10, 40, 50, 100, 200, 1024, 2048, 4096, 10000, 50000, 100000]
	numpages = 1024
	for page_size in page_sizes:
		for max_alloc_size in max_alloc_sizes:
			num_allocs = (numpages * page_size * 3) / (max_alloc_size * 2)
			cmd = "./test -a=k -n=%d -s=%d -fi=%s -fx=%s -ps=%d -pn=%d" % \
			       (num_allocs, max_alloc_size, join(tests_run_root, init_state),\
				join(tests_run_root, exit_state), page_size, numpages)
			print "num_allocs = %d, max_alloc_size = %d, page_size = %d, numpages = %d" %\
				(num_allocs, max_alloc_size, page_size, numpages)
			diffcmd = "diff " + join(tests_run_root, init_state) + " " +\
				   join(tests_run_root, exit_state)
			if os.system(diffcmd) != 0:
				print "Error: %s has failed.\n" % cmd
				sys.exit(1)


def test_mm_params(num_allocs, max_alloc_size, page_size, numpages, iterations):
	for i in range(iterations):
		cmd = "./test -a=p -n=%d -s=%d -fi=%s -fx=%s -ps=%d -pn=%d" % \
		      (num_allocs, max_alloc_size, join(tests_run_root, init_state),\
		      join(tests_run_root, exit_state), page_size, numpages)
		print "num_allocs = %d, max_alloc_size = %d, page_size = %d, numpages = %d" % \
		      (num_allocs, max_alloc_size, page_size, numpages)
		os.system(cmd)
		#os.system("cat %s" % join(tests_run_root, init_state))
		diffcmd = "diff " + join(tests_run_root, init_state) + " " + join(tests_run_root, exit_state)
		if os.system(diffcmd) != 0:
			print "Error: %s has failed.\n" % cmd
			sys.exit(1)

def run_tests():
	if os.path.exists(tests_run_root):
		shutil.rmtree(tests_run_root)
	os.mkdir(tests_run_root)

	#	for i in range (100):
#test_km()
	test_mm()
	#test_mm_params(10922, 10, 128, 81920, 50)
	#test_km()
	#test_mc()

if __name__ == '__main__':
	run_tests()

