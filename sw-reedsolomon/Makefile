default: rs_decode

chien_search: 
	g++ test_chien_search.cpp gf_arith.h gf_arith.cpp chien_search.cpp chien_search.h

error_mag: 
	g++ test_error_mag.cpp gf_arith.h gf_arith.cpp error_mag.cpp error_mag.h

error_correct: 
	g++ test_error_correct.cpp gf_arith.h gf_arith.cpp error_correct.cpp error_correct.h

syndrome: 
	g++ test_syndrome.cpp gf_arith.h gf_arith.cpp syndrome.cpp syndrome.h

berlekamp: 
	g++ test_berlkamp.cpp gf_arith.h gf_arith.cpp berlekamp.cpp berlekamp.h

rs_decode:
	g++ test_rs_decode.cpp gf_arith.h gf_arith.cpp rs_decode.h rs_decode.cpp syndrome.h syndrome.cpp \
	berlekamp.h berlekamp.cpp chien_search.h chien_search.cpp error_mag.h error_mag.cpp \
	error_correct.h error_correct.cpp rs_fifo.h rs_fifo.cpp

clean: 
	rm a.out *.gch