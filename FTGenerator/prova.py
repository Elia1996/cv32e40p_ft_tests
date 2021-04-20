#!/usr/bin/python3
import re

ss="        // \n\
        //// INSTANCE_AND_BLOCK_TO_FT cv32e40p_prefetch_buffer.sv\n\
        cv32e40p_prefetch_buffer\n\
        #(\n\
                .PULP_OBI          ( PULP_OBI                    ),\n\
                .PULP_XPULP        ( PULP_XPULP                  )\n\
        )\n\
        prefetch_buffer_i\n\
        (\n\
                .clk               ( clk                         ),\n\
                .rst_n             ( rst_n                       ),\n\
\n\
                .req_i             ( req_i                       ),\n\
\n\
                .branch_i          ( branch_req                  ),\n\
                .branch_addr_i     ( {branch_addr_n[31:1], 1'b0} ),\n\
\n\
                .hwlp_jump_i       ( hwlp_jump_i                 ),\n\
                .hwlp_target_i     ( hwlp_target_i               ),\n\
\n\
                .fetch_ready_i     ( fetch_ready                 ),\n\
                .fetch_valid_o     ( fetch_valid                 ),\n\
                .fetch_rdata_o     ( fetch_rdata                 ),\n\
\n\
                // goes to instruction memory / instruction cache\n\
                .instr_req_o       ( instr_req_o                 ),\n\
                .instr_addr_o      ( instr_addr_o                ),\n\
                .instr_gnt_i       ( instr_gnt_i                 ),\n\
                .instr_rvalid_i    ( instr_rvalid_i              ),\n\
                .instr_err_i       ( instr_err_i                 ),     // Not supported (yet)\n\
                .instr_err_pmp_i   ( instr_err_pmp_i             ),     // Not supported (yet)\n\
                .instr_rdata_i     ( instr_rdata_i               ),\n\
\n\
                // Prefetch Buffer Status\n\
                .busy_o            ( prefetch_busy               )\n\
        );\n\
        //// END_INSTANCE_AND_BLOCK_TO_FT\n\
\n\
"

print(ss)
print(re.match(r"i", ss))
