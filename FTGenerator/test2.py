#!/usr/bin/python3

from travulog import *
import json

stringa = [ " cv32e40p_prefetch_buffer",
"        #(",
"                .PULP_OBI          ( PULP_OBI                    ),",
"                .PULP_XPULP        ( PULP_XPULP                  )",
"        ) ",
"        prefetch_buffer_i",
"        (",
"                .clk               ( clk                         ),",
"                .rst_n             ( rst_n                       ),",
"                .req_i             ( req_i                       ),",
"                .branch_i          ( branch_req                  ),",
"                .branch_addr_i     ( {branch_addr_n[31:1], 1'b0} ),",
"                .hwlp_jump_i       ( hwlp_jump_i                 ),",
"                .hwlp_target_i     ( hwlp_target_i               ),",
"                .fetch_ready_i     ( fetch_ready                 ),",
"                .fetch_valid_o     ( fetch_valid                 ),",
"               .fetch_rdata_o     ( fetch_rdata                 ),",
"               // goes to instruction memory / instruction cache",
"               .instr_req_o       ( instr_req_o                 ),",
"               .instr_addr_o      ( instr_addr_o                ),",
"               .instr_gnt_i       ( instr_gnt_i                 ),",
"               .instr_rvalid_i    ( instr_rvalid_i              ),",
"               .instr_err_i       ( instr_err_i                 ),     // Not supported (yet)",
"               .instr_err_pmp_i   ( instr_err_pmp_i             ),    // Not supported (yet)",
"               .instr_rdata_i     ( instr_rdata_i               ),",
"                // Prefetch Buffer Status",
"                .busy_o            ( prefetch_busy               )",
"        );" ]
stringa = "\n".join(stringa)
print(stringa)
print(json.dumps(GetInstanceInfo(stringa, 0), indent=4))
