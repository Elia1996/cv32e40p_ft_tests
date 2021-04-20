	//////////////////////////////////////////////////////////////////////
	// MODULE_NAME_ft	
	//////////////////////////////////////////////////////////////////////
	parameter int PARAM_NAME_FT = 1;
	parameter int PARAM_NAME_TIN = 1;
        // TOUT is referred to output signal in order of definition
        // TOUT[0] refers to instr_o -> Pipeline
        // TOUT[1] refers to is_compressed_o -> Pipeline
        // TOUT[2] refers to illegal_instr_o -> Pipeline
        //
	parameter int PARAM_NAME_TOUT [2:0] = {0,0,0};

	// Parameter for breakage monitors
	parameter PARAM_NAME_DECREMENT = 1; 
	parameter PARAM_NAME_INCREMENT = 1; 
	parameter PARAM_NAME_BREAKING_THRESHOLD = 3; 
	parameter PARAM_NAME_COUNT_BIT = 8; 
	parameter PARAM_NAME_INC_DEC_BIT = 2; 
