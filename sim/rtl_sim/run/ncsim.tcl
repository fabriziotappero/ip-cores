database -open waves -shm -into ../out/waves.shm
probe -create -database waves gpio_testbench -shm -all -depth all
run
quit
