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

package cv32e40p_pkg2_ft;
 
        //////////////////////////////////////////////////////////////////////
        // cv32e40p_program_counter_definition_ft        
        //////////////////////////////////////////////////////////////////////
        parameter int PRCODE_FT = 1;
        parameter int PRCODE_TIN = 1;
        // TOUT is referred to output signal in order of definition
        // TOUT[0] refers to instr_o -> Pipeline
        // TOUT[1] refers to is_compressed_o -> Pipeline
        // TOUT[2] refers to illegal_instr_o -> Pipeline
        //
        parameter int PRCODE_TOUT [2:0] = {0,0,0};

        // Parameter for breakage monitors
        parameter PRCODE_DECREMENT = 1; 
        parameter PRCODE_INCREMENT = 1; 
        parameter PRCODE_BREAKING_THRESHOLD = 3; 
        parameter PRCODE_COUNT_BIT = 8; 
        parameter PRCODE_INC_DEC_BIT = 2; 

        parameter int IFST_PRCODE_I = 0;


        //////////////////////////////////////////////////////////////////////
        // cv32e40p_prefetch_buffer_ft        
        //////////////////////////////////////////////////////////////////////
        parameter int PRBU_FT = 1;
        parameter int PRBU_TIN = 1;
        // TOUT is referred to output signal in order of definition
        // TOUT[0] refers to instr_o -> Pipeline
        // TOUT[1] refers to is_compressed_o -> Pipeline
        // TOUT[2] refers to illegal_instr_o -> Pipeline
        //
        parameter int PRBU_TOUT [2:0] = {0,0,0};

        // Parameter for breakage monitors
        parameter PRBU_DECREMENT = 1; 
        parameter PRBU_INCREMENT = 1; 
        parameter PRBU_BREAKING_THRESHOLD = 3; 
        parameter PRBU_COUNT_BIT = 8; 
        parameter PRBU_INC_DEC_BIT = 2; 

        parameter int IFST_PRBU_I = 1;


        //////////////////////////////////////////////////////////////////////
        // cv32e40p_if_stage_fsm_ft        
        //////////////////////////////////////////////////////////////////////
        parameter int IFSTFS_FT = 1;
        parameter int IFSTFS_TIN = 1;
        // TOUT is referred to output signal in order of definition
        // TOUT[0] refers to instr_o -> Pipeline
        // TOUT[1] refers to is_compressed_o -> Pipeline
        // TOUT[2] refers to illegal_instr_o -> Pipeline
        //
        parameter int IFSTFS_TOUT [2:0] = {0,0,0};

        // Parameter for breakage monitors
        parameter IFSTFS_DECREMENT = 1; 
        parameter IFSTFS_INCREMENT = 1; 
        parameter IFSTFS_BREAKING_THRESHOLD = 3; 
        parameter IFSTFS_COUNT_BIT = 8; 
        parameter IFSTFS_INC_DEC_BIT = 2; 

        parameter int IFST_IFSTFS_I = 2;


        //////////////////////////////////////////////////////////////////////
        // cv32e40p_if_pipeline_ft        
        //////////////////////////////////////////////////////////////////////
        parameter int IFPI_FT = 1;
        parameter int IFPI_TIN = 1;
        // TOUT is referred to output signal in order of definition
        // TOUT[0] refers to instr_o -> Pipeline
        // TOUT[1] refers to is_compressed_o -> Pipeline
        // TOUT[2] refers to illegal_instr_o -> Pipeline
        //
        parameter int IFPI_TOUT [2:0] = {0,0,0};

        // Parameter for breakage monitors
        parameter IFPI_DECREMENT = 1; 
        parameter IFPI_INCREMENT = 1; 
        parameter IFPI_BREAKING_THRESHOLD = 3; 
        parameter IFPI_COUNT_BIT = 8; 
        parameter IFPI_INC_DEC_BIT = 2; 

        parameter int IFST_IFPI_I = 3;


        //////////////////////////////////////////////////////////////////////
        // cv32e40p_aligner_ft        
        //////////////////////////////////////////////////////////////////////
        parameter int AL_FT = 1;
        parameter int AL_TIN = 1;
        // TOUT is referred to output signal in order of definition
        // TOUT[0] refers to instr_o -> Pipeline
        // TOUT[1] refers to is_compressed_o -> Pipeline
        // TOUT[2] refers to illegal_instr_o -> Pipeline
        //
        parameter int AL_TOUT [2:0] = {0,0,0};

        // Parameter for breakage monitors
        parameter AL_DECREMENT = 1; 
        parameter AL_INCREMENT = 1; 
        parameter AL_BREAKING_THRESHOLD = 3; 
        parameter AL_COUNT_BIT = 8; 
        parameter AL_INC_DEC_BIT = 2; 

        parameter int IFST_AL_I = 4;


        //////////////////////////////////////////////////////////////////////
        // cv32e40p_compressed_decoder_ft        
        //////////////////////////////////////////////////////////////////////
        parameter int CODE_FT = 1;
        parameter int CODE_TIN = 1;
        // TOUT is referred to output signal in order of definition
        // TOUT[0] refers to instr_o -> Pipeline
        // TOUT[1] refers to is_compressed_o -> Pipeline
        // TOUT[2] refers to illegal_instr_o -> Pipeline
        //
        parameter int CODE_TOUT [2:0] = {0,0,0};

        // Parameter for breakage monitors
        parameter CODE_DECREMENT = 1; 
        parameter CODE_INCREMENT = 1; 
        parameter CODE_BREAKING_THRESHOLD = 3; 
        parameter CODE_COUNT_BIT = 8; 
        parameter CODE_INC_DEC_BIT = 2; 

        parameter int IFST_CODE_I = 5;




endpackage
