#!/usr/bin/python3
import re
# Constants
SVFile = "cv32e40p_aligner_ft.sv"
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

for i in sig_input_name:
    print("."+i+"('0),")

for i in sig_output_name:
    print("."+i+"('0),")
