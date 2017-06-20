In general, obsolete files have tilde at end of filename, before extension.


LOG:
----
20161012: gliderCTD_Generate_L1_Data:

		-Tested new version of correctThermalLag, including support for pumped CTDs
		 Decommissioned old correctThermalLag i.e. the one in this folder by adding tilde, 
		 so we can be sure to use new one, which is under glider_toolbox-master.
		-Restructured code, so most of glider- and deployment-specific stuff is in the caller.
		 (Still need to move some stuff out...)


20161017: gliderOptode_Generate_L1_Data

		-Restructured code, so most of glider- and deployment-specific stuff is in the caller.
		 (Still need to move some stuff out...)

20161020: Added support for SECOORA, using separate driver scripts (for CTD...still need to do same for DO).


