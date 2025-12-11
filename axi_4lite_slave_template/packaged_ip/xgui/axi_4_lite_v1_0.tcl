# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXI_Addrwidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_Dwidth" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXI_Addrwidth { PARAM_VALUE.AXI_Addrwidth } {
	# Procedure called to update AXI_Addrwidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_Addrwidth { PARAM_VALUE.AXI_Addrwidth } {
	# Procedure called to validate AXI_Addrwidth
	return true
}

proc update_PARAM_VALUE.AXI_Dwidth { PARAM_VALUE.AXI_Dwidth } {
	# Procedure called to update AXI_Dwidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_Dwidth { PARAM_VALUE.AXI_Dwidth } {
	# Procedure called to validate AXI_Dwidth
	return true
}


proc update_MODELPARAM_VALUE.AXI_Dwidth { MODELPARAM_VALUE.AXI_Dwidth PARAM_VALUE.AXI_Dwidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_Dwidth}] ${MODELPARAM_VALUE.AXI_Dwidth}
}

proc update_MODELPARAM_VALUE.AXI_Addrwidth { MODELPARAM_VALUE.AXI_Addrwidth PARAM_VALUE.AXI_Addrwidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_Addrwidth}] ${MODELPARAM_VALUE.AXI_Addrwidth}
}

