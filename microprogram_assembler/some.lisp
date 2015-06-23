(%LAMBDA (ARGS)
	 (%IF ARGS
	      (%IF (%EQ? (%QUOTE %.) (%CAR ARGS))
		   (%CAR (%CDR ARGS))
		   (%CONS (%CAR ARGS)
			  (REC (%CDR ARGS))))
	      nil))
