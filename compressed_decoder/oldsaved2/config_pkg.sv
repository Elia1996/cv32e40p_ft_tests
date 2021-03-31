// Copyright 2020 Politecnico di Torino.


////////////////////////////////////////////////////////////////////////////////
// Engineer:       Elia Ribaldone - s265613@studenti.polito.it                //
//                                                                            //
// Design Name:    config_pkg                                                 //
// Project Name:   cv32e40p Fault tolernat                                    //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:   Majority voter of 3                                         //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_PKG
    `define CONFIG_PKG
    package config_pkg;
	// Definition of structure used for
	typedef struct {
		// Input signal of block
		int N_I;
		// Output signals of block
		int N_O;
		/* Total Number of Bit of VOter Input , e.g the sum of dimension of all input signal */
		int TNBVI; // SUM(i=0;i=3){BIT_O[i]}
		/* Total Number of Bit of Voted Output , e.g. depends on S_VOT_SET */
		int TNBVO; // SUM(i=0;i=3){BIT_O[i]+BIT_O[i]*(2*(VOTE_SET[i]/2))}
		 /* Total Number of Bit of Error Output , e.g. depends on S_VOT_SET  */
		int TNBEO; // SUM(i=0;i=3){1 + 2*(VOTE_SET[i]/2)}
		// Bits of each input signal
		int BIT_I [];
		// Bits of each output signal
		int BIT_O [];
		// Settings for voter block replication if:
		// 0 -> no replication, the block isn't FT
		// 1 -> TMR
		// 2 -> TMR plus voter triplication
		int VOTE_SET [];
	} conf_block;

	// Parameter used as mnemonic for each block settings
	parameter int ADDER_FT_CONF = 0;
	

	

	// matrix of configuration
	parameter conf_block CONFIG_MAT [1:0]= '{
		'{	3,
			2,
			17,
			9,
			2,
			'{8,8,1},
			'{8,1},
			'{1,1}
		}, 
		'{	3,
			2,
			17,
			9,
			2,
			'{8,8,1},
			'{8,1},
			'{1,1}
		}
	};
	//CONFIG_MAT[0].N_I = 3;
		
endpackage
`endif
