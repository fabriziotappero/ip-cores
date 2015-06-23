config:
	make -C include/ config

ip:
	make -C uart16550/ ip
	vppreproc --noline --noblank -Iuart16550 top/ip.v | sed -r -e 's/\/\/E2_([a-z]+)/`\1/' | cat - top/versatile_io_top.v > versatile_io.v

clean:
	make -C uart16550/ clean
