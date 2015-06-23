vlib work
vlog ../src/test_bch_encode.v
vlog ./tb_encode.v
vlog ./sim_top.v
vlog ../src/test_bch_syndrome.v
vlog ../src/test_bch_bm.v
vlog ../src/test_chian_search.v
vlog ../src/test_correct.v
vsim -novopt work.sim_top