#!/usr/bin/python3
import re
# Constants
SVFile = "cv32e40p_aligner.sv" 
TXTConfVoterFile = "cv32e40p_conf_voter_instance.txt"
PARAM_NAME="ALIG"
VOTER_NAME="voter"
level_of_indent = 8
indent="    "


def removeComments(string):
    # remove all occurrences streamed comments (/*COMMENT */) from string
    string = re.sub(re.compile("/\*.*?\*/",re.DOTALL ) ,"" ,string) 
    # remove all occurrence single-line comments (//COMMENT\n ) from string
    string = re.sub(re.compile("//.*?\n" ) ,"" ,string) 
    return string

# Conf_voter is used only for the ouput of the block, for this reason
# here we find all output of block

# Open file
fp = open(SVFile, "r")

sig_input_name = []
sig_input_bits = []
sig_output_name = []
sig_output_bits = []


for line in fp.readlines():
    if ("input" in line) or ("output" in line):
        line = removeComments(line)
        real_line = " ".join(line.split()).replace(',','') 

    if "input" in line: 
        print(real_line.split()[-1])
        sig_input_name.append(real_line.split()[-1])
        if "[" in real_line:
              sig_input_bits.append(real_line.split(":")[0].split("[")[1])
        else:
              sig_input_bits.append(1)
    
    if "output" in line: 
        print(real_line.split()[-1])
        sig_output_name.append(real_line.split()[-1])
        if "[" in real_line:
              sig_output_bits.append(real_line.split(":")[0].split("[")[1])
        else:
              sig_output_bits.append("1")
            


fp_conf_voter=open(TXTConfVoterFile,"r")
data = fp_conf_voter.read()

i=0
print(indent*2+"// Signals out to each compressed decoder block to be voted")
for sig_out in sig_output_name:
    if sig_output_bits[i] == "1":
        print(indent*2+"logic [2:0] "+sig_out+"_to_vote ;")
    else:
        print(indent*2+"logic [2:0]["+sig_output_bits[i]+":0] "+sig_out+"_to_vote ;")
    i=i+1

print(indent*2+"// Error signals")
for sig_out in sig_output_name:
    print(indent*2+"logic [2:0] "+sig_out+"_block_err ;")

print("        // Signals that use error signal to find if there is one error on\n\
        // each block, it is the or of previous signals\n\
        logic [2:0] block_err_detected;\n\
        logic [%d:0] err_detected;\n\
        logic [%d:0] err_corrected;\n\
" % sig_out.size(),sig_out.size())


i=0
block_err0=[]
block_err1=[]
block_err2=[]

for sig_out in sig_output_name:
    conf_instance = data.replace("SIGNAME",sig_out)
    conf_instance = conf_instance.replace("PARAM_NAME",PARAM_NAME)
    conf_instance = conf_instance.replace("INDEX",str(i))
    if sig_output_bits[i] == "1":
        conf_instance = conf_instance.replace("BITNUMBER","1")
    else:
        conf_instance = conf_instance.replace("BITNUMBER",str(int(sig_output_bits[i])+1))
    conf_instance = conf_instance.replace("VOTER_NAME",VOTER_NAME+"_"+str(i)+"_"+sig_out)
    for line in conf_instance.split("\n"):
        print(indent*level_of_indent+line)
    i=i+1
    block_err0.append(sig_out+"_block_err[0]")
    block_err1.append(sig_out+"_block_err[1]")
    block_err2.append(sig_out+"_block_err[2]")


print(indent*level_of_indent+"assign block_err_detected[0] =    ", end="")
al="                                "
print(block_err0[0])
for var in block_err0[1:-1]:
    print(indent*level_of_indent+al+"| "+var)
print(indent*level_of_indent+al+"| "+block_err0[-1]+";")

print(indent*level_of_indent+"assign block_err_detected[1] =    ", end="")
al="                                "
print(block_err1[0])
for var in block_err1[1:-1]:
    print(indent*level_of_indent+al+"| "+var)
print(indent*level_of_indent+al+"| "+block_err1[-1]+";")

print(indent*level_of_indent+"assign block_err_detected[2] =    ", end="")
al="                                "
print(block_err2[0])
for var in block_err2[1:-1]:
    print(indent*level_of_indent+al+"| "+var)
print(indent*level_of_indent+al+"| "+block_err2[-1]+";")


print("\n\n\n")


