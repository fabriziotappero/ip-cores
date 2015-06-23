/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Single precision)                     ////
////                                                             ////
////  TEST BENCH                                                 ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          russelmann@hotmail.com                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000 Rudolf Usselmann                         ////
////                    russelmann@hotmail.com                   ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY        ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT           ////
//// LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND   ////
//// FITNESS FOR A PARTICULAR PURPOSE.                           ////
////                                                             ////
/////////////////////////////////////////////////////////////////////



	if(fp_combo)
	   begin
		$display("\n\nTesting FPU \n");

			$display("\nRunning Combo Test 1 ...\n");
			$readmemh ("test_vectors/combo/fpu_combo1.hex", tmem);
			run_test;

			$display("\nRunning Combo Test 2 ...\n");
			$readmemh ("test_vectors/combo/fpu_combo2.hex", tmem);
			run_test;

			$display("\nRunning Combo Test 3 ...\n");
			$readmemh ("test_vectors/combo/fpu_combo3.hex", tmem);
			run_test;

			$display("\nRunning Combo Test 4 ...\n");
			$readmemh ("test_vectors/combo/fpu_combo4.hex", tmem);
			run_test;

	   end

	if(fp_fasu)
	begin
	$display("\n\nTesting FP Add/Sub Unit\n");
	if(test_rmode[0])
	   begin
		$display("\n+++++ ROUNDING MODE: Nearest Even\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Add Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_pat0a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Sub Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_pat0b.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Add Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_pat1a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Sub Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_pat1b.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Add Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_pat2a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Sub Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_pat2b.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Add Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_lga.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Sub Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_lgb.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Add Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_sma.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Sub Test ...\n");
			$readmemh ("test_vectors/rtne/fasu_smb.hex", tmem);
			run_test;
		   end
	   end


	if(test_rmode[1])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards Zero\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Add Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_pat0a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Sub Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_pat0b.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Add Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_pat1a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Sub Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_pat1b.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Add Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_pat2a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Sub Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_pat2b.hex", tmem);
			run_test;
		   end

		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Add Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_lga.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Sub Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_lgb.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Add Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_sma.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Sub Test ...\n");
			$readmemh ("test_vectors/rtzero/fasu_smb.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[2])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF+ (UP)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Add Test ...\n");
			$readmemh ("test_vectors/rup/fasu_pat0a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Sub Test ...\n");
			$readmemh ("test_vectors/rup/fasu_pat0b.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Add Test ...\n");
			$readmemh ("test_vectors/rup/fasu_pat1a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Sub Test ...\n");
			$readmemh ("test_vectors/rup/fasu_pat1b.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Add Test ...\n");
			$readmemh ("test_vectors/rup/fasu_pat2a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Sub Test ...\n");
			$readmemh ("test_vectors/rup/fasu_pat2b.hex", tmem);
			run_test;
		   end

		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Add Test ...\n");
			$readmemh ("test_vectors/rup/fasu_lga.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Sub Test ...\n");
			$readmemh ("test_vectors/rup/fasu_lgb.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Add Test ...\n");
			$readmemh ("test_vectors/rup/fasu_sma.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Sub Test ...\n");
			$readmemh ("test_vectors/rup/fasu_smb.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[3])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF- (DOWN)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Add Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_pat0a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Sub Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_pat0b.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Add Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_pat1a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Sub Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_pat1b.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Add Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_pat2a.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Sub Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_pat2b.hex", tmem);
			run_test;
		   end

		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Add Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_lga.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Sub Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_lgb.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Add Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_sma.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Sub Test ...\n");
			$readmemh ("test_vectors/rdown/fasu_smb.hex", tmem);
			run_test;
		   end
	   end
	end

	if(fp_mul)
	begin

	$display("\n\nTesting FP MUL Unit\n");

	if(test_rmode[0])
	   begin
		$display("\n+++++ ROUNDING MODE: Nearest Even\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rtne/fmul_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rtne/fmul_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rtne/fmul_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rtne/fmul_lg.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rtne/fmul_sm.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[1])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards Zero\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rtzero/fmul_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rtzero/fmul_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rtzero/fmul_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rtzero/fmul_lg.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rtzero/fmul_sm.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[2])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF+ (UP)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rup/fmul_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rup/fmul_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rup/fmul_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rup/fmul_lg.hex", tmem);
			run_test;
		   end

		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rup/fmul_sm.hex", tmem);
			run_test;
		   end

	   end

	if(test_rmode[3])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF- (DOWN)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rdown/fmul_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rdown/fmul_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rdown/fmul_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rdown/fmul_lg.hex", tmem);
			run_test;
		   end

		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rdown/fmul_sm.hex", tmem);
			run_test;
		   end
	   end
	end

	if(fp_div)
	begin

	$display("\n\nTesting FP DIV Unit\n");

	if(test_rmode[0])
	   begin
		$display("\n+++++ ROUNDING MODE: Nearest Even\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rtne/fdiv_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rtne/fdiv_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rtne/fdiv_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rtne/fdiv_lg.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rtne/fdiv_sm.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[1])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards Zero\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rtzero/fdiv_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rtzero/fdiv_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rtzero/fdiv_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rtzero/fdiv_lg.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rtzero/fdiv_sm.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[2])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF+ (UP)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rup/fdiv_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rup/fdiv_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rup/fdiv_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rup/fdiv_lg.hex", tmem);
			run_test;
		   end

		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rup/fdiv_sm.hex", tmem);
			run_test;
		   end

	   end

	if(test_rmode[3])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF- (DOWN)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rdown/fdiv_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rdown/fdiv_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rdown/fdiv_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rdown/fdiv_lg.hex", tmem);
			run_test;
		   end

		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rdown/fdiv_sm.hex", tmem);
			run_test;
		   end
	   end
	end



	if(fp_i2f)
	begin

	$display("\n\nTesting FP I2F Unit\n");

	if(test_rmode[0])
	   begin
		$display("\n+++++ ROUNDING MODE: Nearest Even\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rtne/i2f_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rtne/i2f_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rtne/i2f_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rtne/i2f_lg.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rtne/i2f_sm.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[1])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards Zero\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rtzero/i2f_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rtzero/i2f_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rtzero/i2f_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rtzero/i2f_lg.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rtzero/i2f_sm.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[2])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF+ (UP)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rup/i2f_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rup/i2f_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rup/i2f_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rup/i2f_lg.hex", tmem);
			run_test;
		   end

		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rup/i2f_sm.hex", tmem);
			run_test;
		   end

	   end

	if(test_rmode[3])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF- (DOWN)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rdown/i2f_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rdown/i2f_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rdown/i2f_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rdown/i2f_lg.hex", tmem);
			run_test;
		   end

		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rdown/i2f_sm.hex", tmem);
			run_test;
		   end
	   end
	end


	if(fp_f2i)
	begin

	$display("\n\nTesting FP F2I Unit\n");

	if(test_rmode[0])
	   begin
		$display("\n+++++ ROUNDING MODE: Nearest Even\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rtne/f2i_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rtne/f2i_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rtne/f2i_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rtne/f2i_lg.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rtne/f2i_sm.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[1])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards Zero\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rtzero/f2i_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rtzero/f2i_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rtzero/f2i_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rtzero/f2i_lg.hex", tmem);
			run_test;
		   end
		
		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rtzero/f2i_sm.hex", tmem);
			run_test;
		   end
	   end

	if(test_rmode[2])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF+ (UP)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rup/f2i_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rup/f2i_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rup/f2i_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rup/f2i_lg.hex", tmem);
			run_test;
		   end

		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rup/f2i_sm.hex", tmem);
			run_test;
		   end

	   end

	if(test_rmode[3])
	   begin
		$display("\n\n+++++ ROUNDING MODE: Towards INF- (DOWN)\n\n");

		if(test_sel[0])
		   begin
			$display("\nRunning Pat 0 Test ...\n");
			$readmemh ("test_vectors/rdown/f2i_pat0.hex", tmem);
			run_test;
		   end
		
		if(test_sel[1])
		   begin
			$display("\nRunning Pat 1 Test ...\n");
			$readmemh ("test_vectors/rdown/f2i_pat1.hex", tmem);
			run_test;
		   end
		
		if(test_sel[2])
		   begin
			$display("\nRunning Pat 2 Test ...\n");
			$readmemh ("test_vectors/rdown/f2i_pat2.hex", tmem);
			run_test;
		   end
		
		if(test_sel[3])
		   begin
			$display("\nRunning Random Lg. Num Test ...\n");
			$readmemh ("test_vectors/rdown/f2i_lg.hex", tmem);
			run_test;
		   end

		if(test_sel[4])
		   begin
			$display("\nRunning Random Sm. Num Test ...\n");
			$readmemh ("test_vectors/rdown/f2i_sm.hex", tmem);
			run_test;
		   end
	   end
	end
