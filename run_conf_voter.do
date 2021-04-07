vlib  work
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/tb_conf_voter.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_ft_pkg.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_3voter.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_pkg.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_sim_clock_gate.sv
vlog -sv -reportprogress 300 -work work /home/elia.ribaldone/Desktop/prova/cv32e40p_conf_voter.sv

vsim -debugDB work.tb
add schematic -full sim:/tb/conf_voter
add wave *
add wave -position insertpoint {sim:/tb/compressed_decoder_ft/genblk1/genblk2[2]/breakage_monitor/*}
