#!/usr/bin/python3

################################################################
# Coding Style
# Variable -> word divided by _   variable_dd
# Function -> Word divided by uppercase letter  FunctionVeryGood
# constant -> uppercase  CONSTANT_VAR
################################################################

from block_info import *

######################################################
# Parameter   ########################################
######################################################
# Fault tolerant module name
FT_DIR_OUT=""
FT_MODULE_BASE_NAME = "cv32e40p_"
FT_MODULE_NAME = "compressed_decoder_ft"
# Module to use for fault tolerance
ORIG_DIR="../"
ORIG_MODULE_BASE_NAME = "cv32e40p_"
ORIG_MODULE_NAME = "compressed_decoder"
PARAM_BASE="CDEC"
# Indentation constant
TAB="       "
DECLARATION_ALIGN=2
# /

FT_FILENAME = FT_DIR_OUT+FT_MODULE_BASE_NAME+FT_MODULE_NAME+".sv"
ORIG_FILENAME = ORIG_DIR+ORIG_MODULE_BASE_NAME+ORIG_MODULE_NAME+".sv"

orig_module_info = GetModuleInfo(ORIG_FILENAME)

blocks= {"BLOCK":orig_module_info}

data=ElaborateFTTemplate("ft_template.sv", blocks,  ORIG_MODULE_BASE_NAME+ORIG_MODULE_NAME, PARAM_BASE)

fp = open(FT_FILENAME,"w")
fp.write(data)
fp.close()


