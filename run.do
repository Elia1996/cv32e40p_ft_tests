vlib  work
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/tb.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_ft_pkg.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_3voter.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_pkg.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_sim_clock_gate.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_conf_voter.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_breakage_monitor.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_compressed_decoder_ft.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_compressed_decoder.sv

vsim -debugDB work.tb
add schematic -full sim:/tb/compressed_decoder_ft
add wave *
add wave -position insertpoint sim:/tb/compressed_decoder_ft/*
add wave -position insertpoint {sim:/tb/compressed_decoder_ft/genblk2/genblk1[0]/breakage_monitor/*}
add wave -position insertpoint {sim:/tb/compressed_decoder_ft/genblk2/genblk1[1]/breakage_monitor/*}
add wave -position insertpoint {sim:/tb/compressed_decoder_ft/genblk2/genblk1[2]/breakage_monitor/*}
add wave -position insertpoint {/tb/compressed_decoder_ft/genblk1/genblk2[2]/breakage_monitor/clk_gated}
add schematic -full sim:/tb/compressed_decoder_ft
add wave -position insertpoint {sim:/tb/compressed_decoder_ft/genblk1/genblk2[2]/breakage_monitor/*}
