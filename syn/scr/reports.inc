/* Basic reports */
report_area			 > LOG_PATH + STAGE + _ + TOPLEVEL + _area.log
report_timing -nworst 1000 	 > LOG_PATH + STAGE + _ + TOPLEVEL + _timing.log
report_hierarchy        	 > LOG_PATH + STAGE + _ + TOPLEVEL + _hierarchy.log
report_resources        	 > LOG_PATH + STAGE + _ + TOPLEVEL + _resources.log
report_constraint -all_violators > LOG_PATH + STAGE + _ + TOPLEVEL + _constraint.log
/*
report_power        		> LOG_PATH + STAGE + _ + TOPLEVEL + _power.log
*/

