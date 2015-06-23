--Configuration allows you to select
--the correct architecture to use.




configuration IntegerConfiguration of IQGainPhaseCorrection_entity is
	for IQGainPhaseCorrection_arch_integer --architecture name
		for DUT:IQGainPhaseCorrection	   --for instance_label:component_name
			--use entity library_name.entity_name(arch_name);
			use entity IQCorrection.IQGainPhaseCorrection_entity(IQGainPhaseCorrection_arch_integer); 
		end for;
	end for;
end configuration IntegerConfiguration;
