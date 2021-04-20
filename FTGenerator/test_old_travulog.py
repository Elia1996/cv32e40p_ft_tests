#!/usr/bin/python

from travulog import *
import json

DIR="/media/tesla/Storage/Data/Scrivania/AllProject/Fare/Tesi/Esecuzione_tesi/"

infomod=GetModuleInfo(DIR+"cv32e40p/rtl/cv32e40p_if_stage_no_ft.sv")
formatted=json.dumps(infomod, indent=4)
print(formatted)
ElaborateHiddenTravulog(DIR+"/cv32e40p/rtl/cv32e40p_if_stage_no_ft.sv",infomod,DIR+"/cv32e40p_ft_tests/FTGenerator", {"ft_template":DIR+"cv32e40p_ft_tests/FTGenerator/ft_template.sv"})
