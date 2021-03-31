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


endpackage
