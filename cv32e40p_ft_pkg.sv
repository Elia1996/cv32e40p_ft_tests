////////////////////////////////////////////////////////////////////////////////
// Engineer:            Elia Ribaldone - ribaldoneelia@gmail.com              //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
// Design Name:    RISC-V processor core                                      //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Defines for various constants used by the processor core.  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

package ft_pkg;
 
	//////////////////////////////////////////////////////////////////////
	//      						      _	
	//	  ___ ___  _ __ ___  _ __  _ __ ___  ___ ___  ___  __| |
	//	 / __/ _ \| '_ ` _ \| '_ \| '__/ _ \/ __/ __|/ _ \/ _` |
	//	| (_| (_) | | | | | | |_) | | |  __/\__ \__ \  __/ (_| |
	//	 \___\___/|_| |_| |_| .__/|_|  \___||___/___/\___|\__,_|
	//			    |_|
	//	     _                    _
	//	  __| | ___  ___ ___   __| | ___ _ __
	//	 / _` |/ _ \/ __/ _ \ / _` |/ _ \ '__|
	//	| (_| |  __/ (_| (_) | (_| |  __/ |
	//	 \__,_|\___|\___\___/ \__,_|\___|_|          parameters
	//	
	//////////////////////////////////////////////////////////////////////
	parameter int CDEC_FT = 1;
	parameter int CDEC_TIN = 1;
        // TOUT is referred to output signal in order of definition
        // TOUT[0] refers to instr_o
        // TOUT[1] refers to is_compressed_o
        // TOUT[2] refers to illegal_instr_o
        //
	parameter int CDEC_TOUT [2:0] = {1,0,0};

	// Parameter for breakage monitors
	parameter CDEC_DECREMENT = 1; 
	parameter CDEC_INCREMENT = 1; 
	parameter CDEC_BREAKING_THRESHOLD = 3; 
	parameter CDEC_COUNT_BIT = 8; 
	parameter CDEC_INC_DEC_BIT = 2; 

	//////////////////////////////////////////////////////////////////////
        //	       _ _
	//	  __ _| (_) __ _ _ __   ___ _ __
	//	 / _` | | |/ _` | '_ \ / _ \ '__|
	//	| (_| | | | (_| | | | |  __/ |
	//	 \__,_|_|_|\__, |_| |_|\___|_|
	//		   |___/                             parameters
	//////////////////////////////////////////////////////////////////////

	parameter int ALIG_FT = 1; // Used fault tolerance if it is one
	parameter int ALIG_TIN = 1; // triplicated input if one
        // TOUT is referred to output signal in order of definition
        // TOUT[0] refers to instr_o
        // TOUT[1] refers to is_compressed_o
        // TOUT[2] refers to illegal_instr_o
        //
	// Output:      ALIG_TOUT[0]  aligner_ready_o  -> if_stage FSM
	// 		ALIG_TOUT[1]  instr_aligned_o  -> Compressed_decoder
	// 		ALIG_TOUT[2]  instr_valid_o    -> Pipeline
	// 		ALIG_TOUT[3]  pc_o             -> Pipeline & Output
	//
	//                               3 2 1 0
	parameter int ALIG_TOUT [3:0] = {0,0,1,0};

	// Parameter for breakage monitors
	parameter ALIG_DECREMENT = 1; 
	parameter ALIG_INCREMENT = 1; 
	parameter ALIG_BREAKING_THRESHOLD = 3; 
	parameter ALIG_COUNT_BIT = 8; 
	parameter ALIG_INC_DEC_BIT = 2; 

endpackage
