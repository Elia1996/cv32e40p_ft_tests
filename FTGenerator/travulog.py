#!/usr/bin/python3
import sys
import os
import re
import json

def RemoveComments(string):
    # remove all occurrences streamed comments (/*COMMENT */) from string
    string = re.sub(re.compile("/\*.*?\*/",re.DOTALL ) ,"" ,string)
    # remove all occurrence single-line comments (//COMMENT\n ) from string
    string = re.sub(re.compile("//.*?\n" ) ,"" ,string)
    return string

def GetBits(string):
    ####################################################################################
    # Find bits from a sv init string
    ####################################################################################
    if "[" in string:
        lista = string.split(":")
        if len(lista) == 2:
            return [int(lista[0].split("[")[-1])+1]
        elif len(lista) == 3:
            return [int(lista[0].split("[")[-1])+1, int(lista[1].split("[")[-1])+1]
        else:
            exit(-1)
    else:
        return [1]

def GetModuleInfo(filename):
    ####################################################################################
    # Find info about a sv file
    ####################################################################################
    fp = open(filename, "r")

    sig_input_name = []
    sig_input_bits = []
    sig_output_name = []
    sig_output_bits = []
    mod_patt="^module "
    parameter_name = []
    parameter_bits = []
    parameter_value = []
    sig_intern_name = []
    sig_intern_bits = []

    cnt=0
    save_intern_signals=0
    for line in fp.readlines():
        line = RemoveComments(line)
        if not save_intern_signals:
            if (" input " in line) or (" output " in line):
                real_line = " ".join(line.split()).replace(',','')

            if " input " in line:
                sig_input_name.append(real_line.split()[-1])
                sig_input_bits.append(GetBits(line))
           
            if " output " in line:
                sig_output_name.append(real_line.split()[-1])
                sig_output_bits.append(GetBits(line))
            if re.match(mod_patt,line):
                module = line.split(" ")[1].strip()

            if re.match("^.*parameter.*[,)\n]", line):
                real_line=" ".join(line.split()).strip()
                real_line=real_line.replace(",","").strip()
                l1=real_line.split("=")
                l=l1[0].strip().split(" ")
                parameter_name.append(l[-1])
                if "[" in l[-1] :
                    print("not implemented!!")
                    exit(-1)
                else:
                    parameter_bits.append(1)
                parameter_value.append(l1[1].strip())
        else:
            line_split = " ".join(line.strip().replace(";","").replace("\t","").replace(","," ").split())
            line_split = line_split.split(" ")
            if len(line_split)!=0 and line_split[0] == "logic":
                for word in line_split[1:]:
                    if not "[" in word:
                        sig_intern_name.append(word)
                        sig_intern_bits.append(GetBits(line))

        if cnt==0 and "#(" in line:
            cnt+=1
        elif cnt==1 and ")" in line:
            cnt+=1
        elif cnt==2 and "(" in line:
            cnt+=1
        elif cnt==3 and ");" in line:
            save_intern_signals=1
            cnt+=1



    return {"module":module,"parameter_value":parameter_value, "parameter_name":parameter_name, "parameter_bits":parameter_bits, "sig_input_name" : sig_input_name , "sig_input_bits":sig_input_bits, "sig_output_name":sig_output_name, "sig_output_bits":sig_output_bits , "sig_intern_name": sig_intern_name, "sig_intern_bits":sig_intern_bits}


def GetVoterInstance(model_data, sig_name, voter_name, param_name, index, data_bit_number, indent):    
    ####################################################################################
    # Starting from a verilog code with some variable this function return
    # a new code with variable substituted.
    # SIGNAME -> name of the signal to vote
    # PARAM_NAME -> there are some parameters used in verilog to change FT behaviour
    #               this parameter is the base name of these parameters
    # INDEX -> error correction and detection are saved as vectors, for these
    #           reason each voter will have a number used to address these vectors
    # BITNUMBER -> number of bits of signal to vote
    # VOTER_NAME -> name of the instance of the voter
    ####################################################################################
    data=model_data
    # Substitute signal name
    data = data.replace("SIGNAME",sig_name)
    # Substitute the base name of the FT parameter in the FT package
    data = data.replace("PARAM_NAME",param_name)
    # Substitute the index of output for error detection and correction signals
    data = data.replace("INDEX", str(index))
    # The bits of the signal should be incremented by one if it is greater then one
    if int(index) == 1:
        data = data.replace("BITNUMBER","1")
    else:
        data = data.replace("BITNUMBER",str(data_bit_number[0]))

    # Change voter name
    data = data.replace("VOTER_NAME",voter_name+"_"+str(index)+"_"+sig_name)
    ndata=""
    for line in data.split("\n"):
        ndata = ndata + indent + line + "\n"

    return ndata

def GetVotersInstances(model_file_name, module_info,param_name, align):
    ####################################################################################
    # This function give all voter instance starting from a model file with some
    # parameter:
    # model_file_name -> is the name of the model file, see GetVoterInstance to 
    #                   understand parameters
    # module_info -> the ouput of GetModuleInfo, are used only the output name and
    #               bit number
    # param_name -> when the voter is compiled need some parameter that have this common
    #              radix,e.g. compressed decoder have CDEC as param_name and e.g if
    #               CDEC_FT is setted triplication is implemented.
    # align -> indentation string
    #
    ####################################################################################
    fp=open(model_file_name,"r")
    read = fp.read()
    i=0
    voter_instance = ""
    for sig_name, sig_bits in zip(module_info["sig_output_name"], module_info["sig_output_bits"]):
        voter_instance = voter_instance + GetVoterInstance(read, sig_name,"voter", param_name,i,sig_bits, align)
        i=i+1

    return voter_instance

def getTripleIoPort(start,sig_name,sig_bits,append):
    ####################################################################################
    # Return a string starting with "start" and ending with "append". According
    # to number of bits a vector of 3 element is created
    ####################################################################################
    if str(sig_bits) == "1":
        return start + " logic [2:0] " + sig_name + append
    else:
        if type(sig_bits) == list:
            return start + " logic [2:0][" + str(int(sig_bits[0])-1) + ":0] " + sig_name + append
        else: 
            return start + " logic [2:0][" + str(int(sig_bits)-1) + ":0] " + sig_name + append

def getIoPort(start,sig_name,sig_bits,append):
    ####################################################################################
    # Return a string starting with "start" and ending with "append".
    ####################################################################################
    if str(sig_bits) == "1":
        return start + " logic " + sig_name + append
    else:
        if type(sig_bits) == list:
            return start + " logic [" + str(int(sig_bits[0])-1) + ":0] " + sig_name + append
        else:
            return start + " logic [" + str(int(sig_bits)-1) + ":0] " + sig_name + append

def GetParameterDef(module_info, indent):
    # Write parameter
    i=1
    declaration=""
    if module_info["parameter_name"] != []:
        declaration= declaration + "#(\n"
        parnum=len(module_info["parameter_name"])
        for par_name,par_value in zip(module_info["parameter_name"],module_info["parameter_value"]):
            if i == parnum:
                declaration = declaration + indent + "parameter "+par_name+" = "+par_value+"\n" 
            else:
                declaration = declaration + indent + "parameter "+par_name+" = "+par_value+",\n" 
        declaration = declaration + ")\n"
    return declaration

def GetFTModuleIoDeclaration( module_info, ft_sig_info, indent, ft=1):
    ####################################################################################
    # This function create the declaration of ft module using info from module_info
    # and adding new signal from ft_sig_info
    ####################################################################################

    declaration="module "+module_info["module"]+"_ft\n"

    # Write parameter
    declaration+= GetParameterDef(module_info, indent)
    declaration += "( "
    if module_info["module"] == "cv32e40p_if_pipeline":
        print(module_info)
    
    isclock=0
    isrst_n=0
    # Write input ports
    declaration = declaration +"\n"+ indent + "// Input signal of "+module_info["module"]+" block\n" 
    for sig_in,sig_bits in zip(module_info["sig_input_name"], module_info["sig_input_bits"]):
        if ft == 1:
            declaration = declaration + getTripleIoPort(indent+"input",sig_in,sig_bits[0],",\n")
        else:
            declaration = declaration + getIoPort(indent+"input",sig_in,sig_bits[0],",\n")
        if sig_in == "clk":
            isclock=1
        if sig_in == "rst_n":
            isrst_n=1
    


    # Write output ports
    declaration = declaration +"\n"+ indent + "// Output signal of "+module_info["module"]+" block\n" 
    for sig_out,sig_bits in zip(module_info["sig_output_name"], module_info["sig_output_bits"]):
        if ft == 1:
            declaration = declaration + getTripleIoPort(indent+"output",sig_out,sig_bits[0],",\n")
        else:
            declaration = declaration + getIoPort(indent+"output",sig_out,sig_bits[0],",\n")
    
    if ft == 1:
        if not isclock or not isrst_n:
            declaration = declaration +"\n"+ indent + "// Input clock and reset added for conf_voter\n" 
        if not isclock:
            declaration = declaration + indent + "input logic clk,\n"
        if not isrst_n:
            declaration = declaration + indent + "input logic rst_n,\n"

        # Write new signals
        declaration = declaration +"\n"+ indent + "// Fault tolerant state signals\n"    
        endstr=",\n"
        if len(ft_sig_info) > 0 :
            i=1
            ftsign = len(ft_sig_info["sig_name"])
            for name,bits,io in zip(ft_sig_info["sig_name"], ft_sig_info["sig_bits"], ft_sig_info["io"]):
                if i == ftsign:
                    endstr="\n"
                if str(bits) == "1":
                    declaration = declaration + indent + io + " logic " +name+endstr 
                else:
                    declaration = declaration + indent + io + " logic ["+str(int(bits)-1)+":0] "+name+endstr 
                i=i+1

    declaration =   declaration + ");\n"

    # Write internal signals if they exist
    if "sig_intern_name" in module_info.keys():
        for sig,bit in zip(module_info["sig_intern_name"], module_info["sig_intern_bits"]):
            declaration += getTripleIoPort(indent, sig,bit, ";\n")

    return declaration

def GetInstance(module_name, instance_name, parameter, vect1, vect2, indent):
    #######################################################################################
    # This function create a verilog instance 
    #######################################################################################
    instance=""
    indent2= indent + "        "
    instance += indent + module_name 
    if len(parameter) >= 1:
        instance +="\n"+ indent + "#( "
    for par in parameter :
        if par==parameter[-1]:
            instance += par +" ) \n"
        else:
            instance += par +" ,"
    if len(parameter) >= 1:
        instance += indent
    instance += " " +instance_name + "\n"
    instance += indent + "(\n"
    for sig,sigin in zip(vect1, vect2):
        if sig == vect1[-1]:
            instance += indent2 + "." + sig + "( " + sigin + " )\n"
        else:
            instance += indent2 + "." + sig + "( " + sigin + " ),\n"
    instance += indent + ");\n"
    return instance


def GetOrigInstance(module_info, instance_name, param_pre_suf, in_pre_suf, out_pre_suf, indent):
    ########################################################################################
    # This function return the instance of a module saved in module_info variable
    # param/in/out_pre_suf are all two elements list, the first element is the 
    # prefix and the second is the suffix of parameter, input and output
    ########################################################################################
    # parameter suf and pref are not implemented yet
    module_name = module_info["module"]
    parameter = module_info["parameter_name"]
    vect1 = module_info["sig_input_name"] + module_info["sig_output_name"]
    vect2 = []
    for sig in module_info["sig_input_name"]:
        if in_pre_suf[0] == "UNIQUE":
            vect2.append(in_pre_suf[1])
        else:
            vect2.append(in_pre_suf[0]+sig+in_pre_suf[1])
    
    for sig in module_info["sig_output_name"]:
        if out_pre_suf[0] == "UNIQUE":
            vect2.append(out_pre_suf[1])
        else:
            vect2.append(out_pre_suf[0]+sig+out_pre_suf[1])

    instance = GetInstance(module_name, instance_name, parameter, vect1, vect2, indent)
    return instance

        
def GetIndent(stringa):
    #######################################################################
    # Find the current indentation of "stringa", this
    # function return the number of space before the first letter
    #######################################################################
    endindent=0
    indent_cnt=0
    for letter in stringa:
        if not endindent:
            if letter==" ":
               indent_cnt+=1
            else:
                return indent_cnt

def GetInnerCommand(data_lines, lineno, key):
    ########################################################################
    # This function return all text between lineno and the first occurrence
    # of key, data_lines is a list of lines
    ########################################################################
    i=lineno+1
    command=""
    while not key in data_lines[i]:
        command+=data_lines[i].strip() + "\n"
        i+=1
        if i > len(data_lines):
            print("ERROR at line %d end keyword %s not found" % lineno, key)
            exit(-1)
    return [command,i+1]

def GetDeclarationForeach(block, inout, command, cmd2, lineno, indent):
    ###########################################################################################
    # This function create a declaration foreach IN, OUT or both of a block.
    # Cycling along input or/and output SIGNAME and BITINIT are substituted in "command" string
    ###########################################################################################
    data=""
    if inout == "IN" or inout == "IN_OUT":
        for sig,bit in zip(block["sig_input_name"], block["sig_input_bits"]):
            ok=1
            if "NOT" in cmd2.keys():
                if sig in cmd2["NOT"]:
                    ok=0
            if ok==1:
                data += indent
                if int(bit[0]) == 1:
                    data+= command.replace("INOUT","input").replace("SIGNAME",sig).replace("BITINIT","") 
                else:
                    data+= command.replace("INOUT","input").replace("SIGNAME",sig).replace("BITINIT","["+str(int(bit[0])-1)+":0]") 

    if inout == "OUT" or inout == "IN_OUT":
        for sig,bit in zip(block["sig_output_name"], block["sig_output_bits"]):
            ok=1
            if "NOT" in cmd2.keys():
                if sig in cmd2["NOT"]:
                    ok=0
            if ok==1:
                data += indent
                if int(bit[0]) == 1:
                    data+= command.replace("INOUT","output").replace("SIGNAME",sig).replace("BITINIT","") 
                else:
                    data+= command.replace("INOUT","output").replace("SIGNAME",sig).replace("BITINIT","["+str(int(bit[0])-1)+":0]")
    if inout != "OUT" and inout != "IN" and inout != "IN_OUT":
        print("ERROR line %d, INOUT variable can be only IN,OUT or IN_OUT" % lineno)

    data += "\n"
    return data

def GetDeclarationIfNotPort(block, sig_to_verify, command, lineno, indent):
    ####################################################################################
    # This function check if "sig_to_verify" exist in block signals, and if this signals
    # don't exist the "command" string is returned
    ####################################################################################
    lista = block["sig_input_name"] + block["sig_output_name"]
    
    for sig in lista:
        for sig2 in sig_to_verify: 
            if sig2 == sig:
                return ""
    data = ""
    for line in command.split("\n"):
        data += indent + line + "\n"

    return data

def GetPrefixSuffix(what, sequence, key, lineno):
    #############################################################################
    # This function analyze sequence list and it find prefix and suffix of key
    # the general format is "prefix key suffix", key can also don't exist, but
    # should be at least a word. We could have the following case:
    #   prefix key
    #   key suffix
    #   suffix
    #   prefix key suffix
    #############################################################################
    prefix=""
    suffix=""
    if what == key:
        if len(sequence) == 3: # we have prefix and suffix
            if sequence[1] == key:
                prefix = sequence[0]    
                suffix = sequence[2]
            else:
                print("ERROR : line %d second argument of \"%s =\" should be %s " % lineno,key,key)
                exit(-1)
        elif len(sequence) == 2:
            if sequence[0] == key:
                suffix = sequence[1]
            elif sequence[1] == key:
                prefix = sequence[0]
            else:
                print("ERROR : line %d, when you give two argument first or second should be %s" % lineno,key)
                exit(-1)
        elif len(sequence) == 1 and sequence[0] != "IN" and sequence[0] != "OUT" and sequence[0] != "PARAM":
            prefix="UNIQUE"
            suffix = sequence[0]
        elif len(sequence) == 1:
            prefix=""
            suffix=""
        else:
            print("ERROR : line %d, you should said how to connect signals" % lineno)
            exit(-1)
    return [prefix, suffix]


def  SetSignalElaborationInstance(block, siglist, inoutpar, after_equal, signal_elab, lineno):
    if inoutpar != "IN" and inoutpar != "OUT" and inoutpar != "PARAM":
        print("ERROR line %d, only IN, OUT and PARAM is possible"%lineno)
        exit(-1)
    sigdict = {"IN":block["sig_input_name"],  "OUT":block["sig_output_name"], "PARAM":block["parameter_name"]}
    pre_suf = GetPrefixSuffix(inoutpar, after_equal, inoutpar,lineno)
    append_list = []
    flag=0
    for sig in siglist:
        if not sig in sigdict[inoutpar]:
            print("ERROR line %d, signal %s isn't an %s signal of set block" % lineno, sig,inoutpar)
            exit(-1)
        if len(signal_elab[inoutpar])==0:
            append_list.append(sig)
            flag=1
        else:
            thereis=0
            for data in signal_elab[inoutpar]:
                for sig1 in data[0]:
                    if sig == sig1:
                        thereis =1

            if not thereis:
                append_list.append(sig)
                flag=1

    if flag==1:
        signal_elab[inoutpar].append([append_list,pre_suf])
    
    return signal_elab
            

def GetCmdInstance(block,  command, instance_name, lineno, indent):
    #########################################################################################
    # This function return an instance of a block, using "command" to correctly connect
    # instance, instance_name is the name of the instance while block is a 
    # dictionary with info about the module
    #########################################################################################
    cmd_line=command.strip().split("\n")
    data=""
    signal_elab  = {"OUT":[],"IN":[],"PARAM":[]} 
    sigdict = {"IN":block["sig_input_name"],  "OUT":block["sig_output_name"], "PARAM":block["parameter_name"]}
    for cmd in cmd_line:
        cmd_list=cmd.strip().split(" ")
        if cmd_list[0] == "IF":
            if not "IN" in cmd and not "OUT" in cmd and not "PARAM" in cmd and not "=" in cmd:
                print("ERROR line %d, IF without IN,OUT or PARAM keyword"%lineno)
                exit(-1)
            else:
                before_equal=cmd.split("=")[0].strip()
                what = before_equal.strip().split(" ")[-1]
                apply_to_list = before_equal.strip().split(" ")[1:-1] 
                equal_to=cmd.split("=")[1].strip() 
                sequence = equal_to.split(" ")
                if what == "IN" or what == "OUT" or what == "PARAM":
                    signal_elab = SetSignalElaborationInstance(block, apply_to_list,what, sequence, signal_elab, lineno)
                else:
                    print("ERROR, line "+str(lineno)+", use IN, OUT and PARAM command only, not -"+what+"-")
                    exit(-1) 
        elif "=" in cmd:
                what=cmd.split("=")[0].strip() 
                equal_to=cmd.split("=")[1].strip() 
                sequence = equal_to.split(" ")
                if what == "IN" or what == "OUT" or what == "PARAM":
                    signal_elab = SetSignalElaborationInstance(block, sigdict[what],what, sequence, signal_elab, lineno)
                else:
                    print("ERROR, line "+str(lineno)+", use IN, OUT and PARAM command only, not -"+what+"-")
                    exit(-1)
                    
    module_name = block["module"]
    parameter = block["parameter_name"]
    vect1 = block["sig_input_name"] + block["sig_output_name"]
    vect2 = []

    for sig in block["sig_input_name"]:
        for sig_tc_list in signal_elab["IN"]:
            for sig_tc in sig_tc_list[0]:
                if sig == sig_tc:
                    if sig_tc_list[1][0] == "UNIQUE":
                        vect2.append(sig_tc_list[1][1])
                    else:
                        vect2.append(sig_tc_list[1][0]+sig+sig_tc_list[1][1])
    
    for sig in block["sig_output_name"]:
        for sig_tc_list in signal_elab["OUT"]:
            for sig_tc in sig_tc_list[0]:
                if sig == sig_tc:
                    if sig_tc_list[1][0] == "UNIQUE":
                        vect2.append(sig_tc_list[1][1])
                    else:
                        vect2.append(sig_tc_list[1][0]+sig+sig_tc_list[1][1])
    
    data += GetInstance(module_name, instance_name, parameter, vect1, vect2, indent)                

    return data

def GetInstanceForeach(block_info, model_data, inout, lineno,indent):
    ####################################################################################
    # Starting from a verilog code with some variable this function return
    # a new code with variable substituted.
    # SIGNAME -> name of the signal to vote
    # INDEX -> error correction and detection are saved as vectors, for these
    #           reason each voter will have a number used to address these vectors
    # BITNUMBER -> number of bits of signal to vote
    # VOTER_NAME -> name of the instance of the voter
    ####################################################################################
    names=[]
    bits=[]
    if inout == "IN" or inout == "IN_OUT":
        names = block_info["sig_input_name"]
        bits = block_info["sig_input_bits"]
    if inout == "OUT" or inout == "IN_OUT":
        names += block_info["sig_output_name"]
        bits += block_info["sig_output_bits"]
    if inout!="IN" and inout != "OUT" and inout !="IN_OUT":
        print("ERROR at line %d, %s is wrong, only IN, OUT or IN_OUT can be used "%lineno, inout)
        exit(-1)
    
    index=0
    instance = ""
    for sig,bit in zip(names, bits):
        data=model_data
        # Substitute signal name
        data = data.replace("SIGNAME",sig)
        # Substitute the index of output for error detection and correction signals
        data = data.replace("INDEX", str(index))
        # The bits of the signal should be incremented by one if it is greater then one
        if int(bit[0]) == 1:
            data = data.replace("BITNUMBER","1")
        else:
            data = data.replace("BITNUMBER",str(bit[0]))

        ndata=""
        for line in data.split("\n"):
            if "." in line:
                ndata = ndata + indent + "         "+ line + "\n"
            else:
                ndata = ndata + indent + line + "\n"
        instance += ndata
        index += 1

    return instance

def GetOpUnroll(line_strip, start, end, op, sig, lineno, indent):
    ######################################################################################
    # 
    #####################################################################################
    if start > end or start==end:
        print("Error line %d, start (%d) should be less then end (%d)"%lineno,start,end)
        exit(-1)
    unroll=indent
    words=line_strip.split(" ")
    indent_word = ""
    i=0
    while i < len(words):
        if words[i] == "OP_UNROLL":
            i+=5
            cnt=int(start)
            indent_word = len(unroll.strip())*" "
            operation= " " +sig + "["+str(cnt)+"]\n"
            cnt+=1
            while cnt < int(end)-1: 
                operation += indent + indent_word+ op + " " + sig + "["+str(cnt)+"]\n"
                cnt+=1
            operation += indent + indent_word+ op + " " + sig + "["+str(cnt)+"];\n"
            unroll += operation 

        else:
            unroll += words[i] + " "
        i+=1

    return unroll

def GetOpForeach(line_strip, block_info, inout, op, sig, lineno, indent):
    unroll=indent
    words=line_strip.split(" ")
    indent_word = ""
    i=0
    while i < len(words):
        if words[i] == "OP_FOREACH":
            i+=5
            names=[]
            bits=[]
            if inout == "IN" or inout == "IN_OUT":
                names = block_info["sig_input_name"]
                bits = block_info["sig_input_bits"]
            if inout == "OUT" or inout == "IN_OUT":
                names += block_info["sig_output_name"]
                bits += block_info["sig_output_bits"]
            if inout!="IN" and inout != "OUT" and inout !="IN_OUT":
                print("ERROR at line %d, %s is wrong, only IN, OUT or IN_OUT can be used "%lineno, inout)
                exit(-1)
            indent_word = len(unroll.strip())*" "
            operation= " " + sig.replace("SIGNAME",names[0]) + "\n"
            cnt=1
            while cnt < len(names)-1: 
                operation += indent + indent_word+ op + " " + sig.replace("SIGNAME",names[cnt]) + "\n"
                cnt+=1
            operation += indent + indent_word+ op + " " + sig.replace("SIGNAME",names[cnt]) + ";\n"
            unroll += operation 

        else:
            unroll += words[i] + " "
        i+=1

    return unroll

def FindIfSigInModule(module_info, sig):
    if sig in module_info["sig_input_name"]:
        # We save the number of bits of the input signal 
        cmd_in_bits = module_info["sig_input_bits"][module_info["sig_input_name"].index(sig)]
    elif sig in module_info["sig_output_name"]:
        # Save bits
        cmd_in_bits = module_info["sig_output_bits"][module_info["sig_output_name"].index(sig)]
    elif sig in module_info["sig_intern_name"]:
        # Save bits
        cmd_in_bits = module_info["sig_intern_bits"][module_info["sig_intern_name"].index(sig)]
    else:
        # The signal should be at least in the input/output/intern signal
        return 0
    return cmd_in_bits
    


def CreateNewBlockInfo(cmd_dict, module_info):
    cmd_in_sig = cmd_dict["IN"]
    cmd_out_sig = cmd_dict["OUT"]
    cmd_io = cmd_in_sig + cmd_out_sig
    cmd_verilog_block = cmd_dict["verilog_block"]
    orig_all_sig = module_info["sig_input_name"] + module_info["sig_output_name"] +  module_info["sig_intern_name"]

    new_block = {}
    new_block["sig_input_bits"] = []
    new_block["sig_input_name"] = cmd_in_sig
    new_block["sig_output_bits"] = []
    new_block["sig_output_name"] = cmd_out_sig
    # These are the signals to init in the new block
    new_block["sig_intern_name"] =[]
    new_block["sig_intern_bits"] =[]
    new_block["parameter_name"] = []
    new_block["parameter_bits"] = []
    new_block["verilog_block"] = cmd_dict["verilog_block"]


    # We cycle on all signals of input and output of new block
    # and check that their exist in main module, input, output or internal signals

    # INPUT SIGNALS
    # Verify input of new block and save their bits
    for sig in cmd_in_sig:  
        bits = FindIfSigInModule(module_info,sig)
        if bits != 0:
            # Save bits
            new_block["sig_input_bits"].append( bits )
        else:
            # The signal should be at least in the input/output/intern signal
            print("ERROR, signal %s there isn't in the main module IO and intern signals." % sig)
            exit(-1)

    # OUTPUT SIGNALS
    # Verify outputs of new block and save their bits
    for sig in cmd_out_sig:  
        bits = FindIfSigInModule(module_info,sig)
        if bits != 0:
            # Save bits
            new_block["sig_output_bits"].append( bits )
        else:
            # The signal should be at least in the input/output/intern signal
            print("ERROR, signal %s there isn't in the main module IO and intern signals." % sig)
            exit(-1)

    # INTERNAL SIGNALS
    # Find signal to init in the new block, to do this
    # we cycle on all in/out and find signals that are in the verilog block
    # and don't are input or output 
    for sig, bit in zip(module_info["sig_input_name"]+module_info["sig_output_name"]+module_info["sig_intern_name"],module_info["sig_input_bits"]+module_info["sig_output_bits"]+module_info["sig_intern_bits"]):
        # If the input signal is not a io of the new block
        if not sig in cmd_io:
            # If the input signal is in the verilog block save it as 
            # internal signal
            if sig in cmd_verilog_block:
                new_block["sig_intern_name"].append(sig)
                new_block["sig_intern_bits"].append(bit)

    # PARAMETER
    for par,bit,value in  zip(module_info["parameter_name"],module_info["parameter_bits"],module_info["parameter_value"]):
        # If the parameter is used in the verilog block we save this parameter
        # in order to pass it in the new block
        if par in cmd_verilog_block:
            new_block["parameter_name"] = par
            new_block["parameter_bits"] = bit
            new_block["parameter_value"] = value


    return new_block

def CreateFtBlock(cmd_dict, block_name, module_info, out_dir, indent):
    ############################################################################################
    # This function return the new block verilog and the instance of the new block
    # to place in the original block.
    # cmd_dict -> dictionary of the hidden travulog command
    # block_name -> name of the new block to create
    # module_info -> info about the main module in wich will be instanced the new block
    # indent -> indentation of the new instance 

    # In newmod_info will be saved the module info dict 
    newmod_info = CreateNewBlockInfo(cmd_dict, module_info)
    newmod_info["module"] = block_name

    ##### DATAFILE CREATION
    datafile = GetFTModuleIoDeclaration(newmod_info, newmod_info, indent, 0)
    for sig,bit in zip(newmod_info["sig_intern_name"],newmod_info["sig_intern_bits"]):
        datafile +=  getIoPort(indent+"logic ",sig,bit,";\n")
    datafile += newmod_info["verilog_block"]
    datafile += "endmodule\n"
    
    # We print datafile on file (not already ft)
    fp = open(out_dir+"/"+block_name+".sv","w")
    fp.write(create_ft_block_dict[block_name]["datafile"])
    fp.close()

    ##### FT block creation
    # We use the template to transform the new block in a ft block
    short_name = block_name.replace("cv32e40p_","")
    param_name=short_name[:2].upper()
    i=2
    while i < len(short_name):
        if short_name[i] == "_":
            i+=1
            param_name += short_name[i:i+2].upper()
            i+=2
        else:
            i+=1

    ft_datafile = GetElaboratedTravulog(cmd_dict["template_filename"], newmod_info, block_name, short_name, param_name)
    # Print ft_datafile
    fp = open(out_dir+"/"+block_name+"_ft.sv","w")
    fp.write(ft_datafile)
    fp.close()
    
    ##### INSTANCE creation
    # Get module info in order to create new instance of the ft block
    ft_module_info = GetModuleInfo(out_dir+"/"+block_name+"_ft.sv")
    instance = GetOrigInstance(ft_module_info, block_name+"_ft", ["",""], ["",""], ["",""], indent)
    
    return instance
            


    
def ElaborateHiddenTravulog(sv_filename, orig_module_info, ft_dir, template_dict):
    #############################################################################################
    # This function elaborate travulog code hidden in a verilog or sistemverilog file
    # hidden travulog for command CREATE_FT_BLOCK appears like:
    # //// CREATE_FT_BLOCK template_name block_name
    # //// IN all input
    # //// OUT all output
    # //// END_CREATE_FT_BLOCK
    # 
    # This type of code is useful when designer have a verilog hardware description that
    # should became fault tolerant. In this case Hidden Travulog don't modify verilog
    # code but can be analyzed by this function to create a new FT block for example. 
    # In this way any time that you apply a change in the original verilog, you could
    # simulate you verilog and verify the behavior whitout delete Travulog code, then 
    # running this function your FT structure is created.
    fp = open(sv_filename,"r")
    data_orig=fp.read()
    tab="        "
    data_orig=data_orig.replace("\t",tab)
    
    data_line = data_orig.split("\n")

    data_elab=""
    lineno=0
    linemax=len(data_line)
    HTKEY="////"
    create_ft_block_dict={}
    create_ft_block_instance={}
    create_ft_block_datafile={}
    declaration_begin_line=0
    declaration_end_line=0
    # This list contain begin line, end line and name of a new block
    lines=[]


    # Elaboration cycle
    while lineno < linemax:
        line= " ".join(data_line[lineno].strip().split()).strip()
        if line.split(" ")[0] == "module":
            declaration_begin_line = lineno
        if line.split(" ")[0] == "logic":
            declaration_end_line = lineno
        
        # La stringa ////  l'indice di una riga di Travulog
        if line.split(" ")[0] == HTKEY:
            
            cmd=line.replace(HTKEY,"").strip()
            
            if "CREATE_FT_BLOCK" in cmd:
                cmd_list = cmd.split(" ")
                ###########################
                # Controls
                ###########################
                # The first line should contain three word
                if len(cmd_list)!= 3 :  # CREATE_FT_BLOCK template_name block_name
                    print("ERROR line %d, CREATE_FT_BLOCK template_name block_name" % lineno)
                    exit(-1)
                if not cmd_list[1] in template_dict.keys():  # Errore se il template non e presente
                    print("ERROR line %d template %s not found"%lineno,cmd_list[1])
                    exit(-1)
                ##########################
                # Parsing
                ##########################
                block_name = cmd_list[2]
                create_ft_block_dict[block_name]={}
                create_ft_block_dict[block_name]["template_filename"] = template_dict[cmd_list[1]]
                create_ft_block_dict[block_name]["start_line"]=lineno
                # le linee di hidden travulog devono essere attaccate percui cerco 
                # HTKEY nelle linee successive, devono infatti esserci gli ingressi e le uscite
                lineno += 1
                line= " ".join(data_line[lineno].strip().split()).strip()
                # If this two variable are already false after cycle means that
                # in out or both are not found in hidden travulog, this create an error
                find_in=False  
                find_out=False
                current_saving=""
                # Save travulog hidden command
                while line.split(" ")[0] == HTKEY:
                    if " IN " in line:
                        current_saving="IN"
                        find_in=True
                        create_ft_block_dict[block_name]["IN"]=[]
                    elif " OUT " in line:
                        current_saving="OUT"
                        find_out=True
                        create_ft_block_dict[block_name]["OUT"]=[]
                    else:
                        if current_saving=="":
                            break
                    cmd_split = line.replace(HTKEY, "").strip().split(" ")
                    if len(cmd_split) < 1:
                        break
                    if current_saving == "IN":
                        for ingressi in cmd_split:
                            if ingressi != "IN":
                               create_ft_block_dict[block_name]["IN"].append(ingressi)
                    if current_saving == "OUT":
                        for ingressi in cmd_split:
                            if ingressi != "OUT":
                                create_ft_block_dict[block_name]["OUT"].append(ingressi)

                    lineno +=1
                    line= " ".join(data_line[lineno].strip().split()).strip()

                # Verify that both input and output are given
                if not find_in or not find_out or len(create_ft_block_dict[block_name]["IN"])<1 or len(create_ft_block_dict[block_name]["OUT"])<1:
                    print("ERROR, line %d, hiddent travulog needs continuos statments"
                            ", CREATE_FT_BLOCK needs input and output signal, "
                            "you remember that IN and OUT need a space before and after"
                            " to be recognized" % lineno)
                    exit(-1)

                # Save verilog block to use in new block 
                create_ft_block_dict[block_name]["verilog_block"] = data_line[lineno]
                lineno +=1
                line= " ".join(data_line[lineno].strip().split()).strip()
                while line.split(" ")[0] != HTKEY:
                    create_ft_block_dict[block_name]["verilog_block"] += data_line[lineno] + "\n"
                    lineno +=1
                    line= " ".join(data_line[lineno].strip().split()).strip()

                # Verify end key
                if line.split(" ")[1] != "END_CREATE_FT_BLOCK":
                    print("ERROR, line %d, at the end of the verilog block"
                            " you should place END_CREATE_FT_BLOCK command" % lineno)
                    exit(-1)
            
                # Create datafile and instance
                create_ft_block_dict[block_name]["end_line"]=lineno
                lines.append([create_ft_block_dict[block_name]["start_line"], lineno, block_name])
                ft_instance = CreateFtBlock(create_ft_block_dict[block_name], block_name, orig_module_info, ft_dir,tab)
                create_ft_block_dict[block_name]["instance"] = ft_instance


                # Now we use template to create the ft block to instantiate


        lineno+=1
    
    ########################################################################
    # Create the new file of original block module_info
    ########################################################################
    # print(json.dumps(create_ft_block_dict,indent=4))
    
    lineno = 0
    datafile = ""

    # Copy the beginning of the file before IO declaration
    while lineno < declaration_begin_line:
        datafile += data_line[lineno] + "\n"
        lineno +=1 
    
    # Add declaration and internal signals
    datafile += GetFTModuleIoDeclaration(orig_module_info, [], tab, 1)

    lineno = declaration_end_line + 1 
    # Add all internal verilog and the instance of the new block if they exist
    i=0
    while lineno < len(data_line): 
        if len(lines) > 0:
            if i < len(lines) and lineno == lines[i][0]:
                datafile += create_ft_block_dict[lines[i][2]]["instance"]
                # Jump to the end of the new block declaration
                lineno = lines[i][1]+1
                i+=1
        
        datafile += data_line[lineno] + "\n"
        lineno+=1
    
    print datafile
    return datafile

    
def NextHTLine(lines, lineno, key):
    # Next Hidden Travulog Line
    n=lineno
    HTKEY=key
    while n< len(lines):
        line= " ".join(lines[lineno].strip().split()).strip()
        if line.split(" ")[0] == HTKEY:
            return [line,n] 
        n+=1    
    return [0,0]






def GetElaboratedTravulog(template_filename, block_info, module_name, short_module_name, param_name):
    #############################################################################################
    # This function start from a template file that create a FT structure of a non 
    # FT block, in this file will be many uppercase variable that should be substitute by 
    # block of autogenerated code. This autogenerated code depends by arguments of this function
    # These are parameter that wil be substitute:
    # Global variable , this variable are substitute before elaboration in all file
    #-- MODULE_NAME -> Name of the module
    #-- PARAM_NAME -> there are some parameters used in verilog to change FT behaviour
    #                   this parameter is the base name of these parameters
    #-- block_name_MODNAME -> name of the block
    #
    # Elaboration blocks, elements in this block will be cloned for all in or out signal
    #-- PARAMETER_DECLARATION block_name -> declare the same parameter of block_name module
    #-- DECLARATION_FOREACH block_name inout    
    #       declaration_command
    #   END_DECLARATION -> cycle on block_name input (if inout=IN) or output 
    #                   (if inout=OUT) or both (if inout=IN_OUT) and substitute follow variable:
    #                   INOUT -> if the signal is an input INOUT="input", if it is an output INOUT="output"
    #                   BITINIT -> if the signal has only a bit BITINIT="" otherwhise BITINIT="[BITNUMBER-1:0]"
    #                   SIGNAME -> It is substituted with signal name
    #-- INSTANCE block_name
    #       PARAM = 
    #       IN = IN_string   
    #       OUT= OUT_string
    #   END_INSTANCE -> create an instance of block_name connecting input/output signals adding string, 
    #       for example:
    #           INSTANCE BLOCK
    #               PARAM=PARAM
    #               IN=IN[0]
    #               OUT = OUT_to_vote[i]
    #           END_INSTANCE
    #       Generate:
    #           cv32e40p_compressed_decoder #(FPU) compressed_decoder
    #           (
    #               .instr_i(instr_i[0]),
    #               .instr_o(instr_o_to_vote[i]),
    #               .is_compressed_o(is_compressed_o_to_vote[i]),
    #               .illegal_instr_o(illegal_instr_o_to_vote[i])
    #           );
    #
    #-- INSTANCE_FOREACH block_name inout
    #       instance_template
    #   END_INSTANCE  -> This command cycle on input or output of block and substitute
    #               variable in instance_template string in order to create instance of some
    #               block connected to input, output or both of block_name block.
    #               Variable can be:
    #                   BITNUMBER -> number of bit of the signal to connect
    #                   INDEX -> index of cycle
    #                   SIGNAME -> name of the signal
    #   
    #-- OR_UNROLL start end operation signame -> this command unroll a reduction operation in order
    #                   to have better representation in schematic during complation.
    #                   For example:
    #                       assign err_detected_o = OP_UNROLL 0 3 | err_detected ;
    #                   Generate:
    #                       assign err_detected_o =   err_detected[0] 
    #                                               | err_detected[1] 
    #                                               | err_detected[2];
    #-- OP_FOREACH block_name inout operation expression -> apply an operation between each input
    #               or output of block_name block. For example:
    #                   assign block_err_detected[m] = OP_FOREACH BLOCK OUT | SIGNAME_block_err[m] ;
    #               Generate:
    #                   assign block_err_detected[m] =   instr_o_block_err[m]
    #                                                  | illegal_instr_o_block_err[m]
    #                                                  | is_compressed_o_block_err[m];
    #   
    #############################################################################################

    fp = open(template_filename,"r") 
    data_orig=fp.read()
    tab="        "
    data_orig=data_orig.replace("\t",tab)
    
    # Substitution of constant
    data = data_orig.replace("MODULE_NAME",module_name)
    data = data.replace("PARAM_NAME", param_name)
    for key,value in zip(block_info.keys(), block_info.values()):
        data = data.replace(key+"_MODNAME", short_module_name)

    data_line = data.split("\n")

    data_elab=""
    lineno=0
    linemax=len(data_line)

    # Elaboration cycle
    while lineno < linemax:
        line=data_line[lineno]
        line_indent=GetIndent(line)
        line_strip = line.strip()
        line_strip_split = line_strip.split(" ")

        # Parameter declaration
        if "PARAMETER_DECLARATION" in line_strip:
            if len(line_strip_split) == 2:
                # get the dictionary of info of corresponding block
                block=block_info[line_strip_split[1]]
                data_elab += GetParameterDef(block, line_indent*" ")
            else:
                print("ERROR! PARAMETER_DECLARATION at line %d need the name of block to copy parameter" % lineno)
                exit(-1)
        elif "DECLARATION_FOREACH" in line_strip:
            # DEyCLARATION_FOREACH BLOCK IN_OUT
            #    INOUT logic [2:0]BITINIT SIGNAME,
            # END_DECLARATION_FOREACH

            if len(line_strip_split) >= 3:
                block=block_info[line_strip_split[1]]
                inout=line_strip_split[2]
                if len(line_strip_split) > 4:
                    cmd2 = {line_strip_split[3]: line_strip_split[4:]}
                [command, lineno]= GetInnerCommand(data_line, lineno, "END_DECLARATION_FOREACH")
                data_elab += GetDeclarationForeach(block, inout, command, cmd2, lineno, line_indent*" ")    
            else:
                print("ERROR! DECLARATION_FOREACH at line %d needs block name and IN/OUT/IN_OUT option" % lineno)
                print("LINE: %s" % line_strip_split)
                exit(-1) 
        elif "DECLARATION_IF_NOT_PORT" in line_strip:
            # DECLARATION_IF_NOT_PORT BLOCK clk rst_n
            #   input logic clk,
            #   input logic rst_n,
            # END_DECLARATION_IF_NOT_PORT

            if len(line_strip_split) >= 3:
                signals = line_strip_split[2:-1]
                block = block_info[line_strip_split[1]]
                [command, lineno]= GetInnerCommand(data_line, lineno, "END_DECLARATION_IF_NOT_PORT")
                data_elab += GetDeclarationIfNotPort(block, signals,  command, lineno, line_indent*" ")
            else:
                print("ERROR! DECLARATION_IF_NOT_PORT at line %d needs block name and at least a name of signal" % lineno)
                exit(-1)
        elif "INSTANCE " in line_strip:
            # INSTANCE BLOCK BLOCK_MODNAME_triplicated
            #         PARAM=PARAM
            #         IN = IN [i]
            #         OUT = OUT _to_vote[i]
            # END_INSTANCE
            if len(line_strip_split) == 3:
                block = block_info[line_strip_split[1]]
                instance_name = line_strip_split[2]
                [command, lineno]= GetInnerCommand(data_line, lineno, "END_INSTANCE")
                data_elab += GetCmdInstance(block,  command, instance_name ,lineno, line_indent*" ")
            else:
                print("ERROR! INSTANCE at line %d needs block name and instance name" % lineno)
                exit(-1)
        elif "INSTANCE_FOREACH" in line_strip:
            # INSTANCE_FOREACH BLOCK OUT
            #         // Voter for TOVOTE signal, triple voter if
            #         // CDEC_TOUT[INDEX] == 1
            #         cv32e40p_conf_voter
            #         #(
            #                 .L1(BITNUMBER),
            #                 .TOUT(CDEC_TOUT[INDEX])
            #         ) voter_SIGNAME_INDEX
            #         (
            #                 .to_vote_i( SIGNAME_to_vote ),
            #                 .voted_o( SIGNAME),
            #                 .block_err_o( SIGNAME_block_err),
            #                 .broken_block_i(is_broken_o),
            #                 .err_detected_o(err_detected[INDEX]),
            #                 .err_corrected_o(err_corrected[INDEX])
            #         );
            # END_INSTANCE_FOREACH
            if len(line_strip_split) == 3:
                block = block_info[line_strip_split[1]]
                inout = line_strip_split[2]
                [command, lineno]= GetInnerCommand(data_line, lineno, "END_INSTANCE_FOREACH")
                data_elab += GetInstanceForeach(block,  command, inout, lineno, line_indent*" ")
            else:
                print("ERROR! INSTANCE_FOREACH at line %d needs block name and inout parameter" % lineno)
                exit(-1)
        elif "OP_UNROLL" in line_strip:
            # assign err_detected_o = OP_UNROLL 3 | err_detected ;
            cmd = line_strip.split("=")[1].strip()
            cmd_split = cmd.split(" ")
            if len(cmd_split) > 5:
                start=cmd_split[1]
                end=cmd_split[2]
                op=cmd_split[3]
                sig=cmd_split[4]
                data_elab += GetOpUnroll(line_strip, start, end, op, sig, lineno, line_indent*" ")
            else:
                print("ERROR! OP_UNROLL at line %d needs block name and instance name" % lineno)
                exit(-1)

        elif "OP_FOREACH" in line_strip:
            # assign err_detected_o = OP_UNROLL 3 | err_detected ;
            i=0
            while i< len(line_strip_split):
                if line_strip_split[i] == "OP_FOREACH":
                    if i+4 < len(line_strip_split):
                        cmd = line_strip_split[i:i+5]
                        i+=4
                    else:
                        print("ERROR! OP_FOREACH at line %d, some arguments are missing '%s'" % lineno,line_strip)
                        exit(-1)
                i+=1
            
            block = block_info[cmd[1]]
            inout=cmd[2]
            op=cmd[3]
            sig=cmd[4]
            data_elab += GetOpForeach(line_strip, block, inout, op, sig, lineno, line_indent*" ")
        else:
            data_elab+=line + "\n"

        lineno+=1
    return data_elab
