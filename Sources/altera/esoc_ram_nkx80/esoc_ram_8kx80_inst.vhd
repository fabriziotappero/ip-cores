esoc_ram_8kx80_inst : esoc_ram_8kx80 PORT MAP (
		address_a	 => address_a_sig,
		address_b	 => address_b_sig,
		clock	 => clock_sig,
		data_a	 => data_a_sig,
		data_b	 => data_b_sig,
		rden_a	 => rden_a_sig,
		rden_b	 => rden_b_sig,
		wren_a	 => wren_a_sig,
		wren_b	 => wren_b_sig,
		q_a	 => q_a_sig,
		q_b	 => q_b_sig
	);
