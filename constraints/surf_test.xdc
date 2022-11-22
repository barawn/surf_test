set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]

#set_false_path -through [get_nets -hier *coeff_data*]

set axiclk [get_clocks clk_pl_0]
set axiclk_net [get_nets -of_objects $axiclk]
set aclk [get_clocks clk_out1_ps_base_adc0_clk_wiz_0]
set aclk_net [get_nets -of_objects $aclk]
set memclk [get_clocks clk_out2_ps_base_adc0_clk_wiz_0]
set memclk_net [get_nets -of_objects $aclk]
set syncclk [get_clocks clk_out3_ps_base_adc0_clk_wiz_0]
set syncclk_net [get_nets -of_objects $syncclk]

create_clock -period 8.00 -name rx_clk [get_ports -filter { NAME =~ "RXCLK_P" && DIRECTION == "IN" }]
set rxclk [get_clocks -of_objects [get_pins u_rxclk/rxclk]]
set rxclk_net [get_nets -of_objects $rxclk]
set parclk [get_clocks -of_objects [get_pins u_rxclk/parclk]]
set parclk_net [get_nets -of_objects $parclk]
set rxsyncclk [get_clocks -of_objects [get_pins u_rxclk/syncclk]]
set rxsyncclk_net [get_nets -of_objects $rxsyncclk]

set_property CLOCK_DELAY_GROUP ADC_CLKS $aclk_net
set_property CLOCK_DELAY_GROUP ADC_CLKS $memclk_net
set_property CLOCK_DELAY_GROUP ADC_CLKS $syncclk_net

set_property CLOCK_DELAY_GROUP RACK_CLKS $rxclk_net
set_property CLOCK_DELAY_GROUP RACK_CLKS $parclk_net
set_property CLOCK_DELAY_GROUP RACK_CLKS $rxsyncclk_net

set rxclk_period [get_property PERIOD $rxclk]
set parclk_period [get_property PERIOD $parclk]

##########################
#### GEARBOX CONSTRAINTS
# The 4-to-3 gearbox in the rackbus path is a synchronous gearbox, but the constraints
# are adjusted for max delay. Implement that here.
# 
set gearbox_read_data [get_cells -hier -filter { NAME=~ *u_rackbus/u_gearbox/*slowclk_data* && PRIMITIVE_TYPE =~ REGISTER*}]
set gearbox_write_data [get_cells -hier -filter { NAME=~ *u_rackbus/u_gearbox/*fastclk_data* && PRIMITIVE_TYPE =~ REGISTER*}]

## The *minimum* setup time is 6 ticks (2x memclk period)
set_max_delay -from $gearbox_read_data -to $gearbox_write_data [expr 2*$rxclk_period]
## The *maximum* hold time is 1 ticks (1/3x memclk period)
set_min_delay -from $gearbox_read_data -to $gearbox_write_data [expr -1*$rxclk_period/3.]

##########################

set aclk_period [get_property PERIOD $aclk]
set memclk_period [get_property PERIOD $memclk]

set_max_delay -datapath_only -from $axiclk -to $aclk 10.00
set_max_delay -datapath_only -from $aclk -to $axiclk 10.00

#set uram_areset [get_cells -hier -filter { NAME=~ *u_uram/aclk_reset* && PRIMITIVE_TYPE =~ REGISTER*}]
#set uram_reset [get_cells -hier -filter { NAME=~ *u_uram/write_reset* && PRIMITIVE_TYPE =~ REGISTER*}]
#set uram_run [get_cells -hier -filter { NAME=~ *u_uram/write_run* && PRIMITIVE_TYPE =~ REGISTER*}]
#set uram_addr [get_cells -hier -filter { NAME=~ *u_uram/write_addr* && PRIMITIVE_TYPE =~ REGISTER*}]

## This just groups the whole things at first. Later we'll repartition buffer_data
## into 6 different groups so we can specifically call out all of the delays properly.
## Doing that with regexps isn't easy.
#set uram_buffer_data [get_cells -hier -filter { NAME=~ *u_uram/buffer_data* && PRIMITIVE_TYPE =~ REGISTER*}]
#set uram_write_data [get_cells -hier -filter { NAME=~ *u_uram/write_data* && PRIMITIVE_TYPE =~ REGISTER*}]

### These are the multicycle paths in memclk domain
##set_multicycle_path 2 -setup -from $uram_reset -to $uram_run
##set_multicycle_path 2 -setup -from $uram_reset -to $uram_addr
### if you set this to 4, Vivado goes apeshit
##set_multicycle_path 2 -setup -from $uram_addr -to $uram_addr

## These are the cross-clock paths from aclk->memclk
## Let's *first* try just using the tightest constraint, at clk1. Which is 6 ticks, or 2x memclk periods
## Note "datapath" is not here, we *have* to handle the clock skew.
## Also I need to figure out WTF I do with "min_delay" here. Technically for a normal
## clock the max delay is 1 clock, the min delay is 0 (full setup/hold).
## But I don't know if that's actually true here, I think the "min_delay" is actually *negative*
## if I properly do it. By a *lot*. Because none of this data changes except once every 4 clock periods.

## The *minimum* setup time is 6 ticks (2x memclk period)
#set_max_delay -from $uram_buffer_data -to $uram_write_data [expr 2*$memclk_period]
## The *maximum* hold time is 1 ticks (1/3x memclk period)
#set_min_delay -from $uram_buffer_data -to $uram_write_data [expr -1*$memclk_period/3.]

## this *works* but is stupid
##set_multicycle_path -setup 2 -end -from $uram_buffer_data -to $uram_write_data
##set_multicycle_path -hold 1 -end -from $uram_buffer_data -to $uram_write_data

## reset cross-path
#set_max_delay -from $uram_areset -to $uram_reset [expr 2*$memclk_period]
#set_min_delay -from $uram_areset -to $uram_reset [expr -2*$memclk_period]

## NOTE NOTE NOTE: CIN/RXCLK are INVERTED but we handle that at TURFIO
# CIN_P/N are B65 L4_N/P
# RXCLK_P/N are B65 L12_N/P
# so we LIE HERE about which one is connected to P/N
set_property -dict { IOSTANDARD LVDS PACKAGE_PIN AJ17 DIFF_TERM TRUE } [get_ports {RXCLK_P }]
set_property -dict { IOSTANDARD LVDS PACKAGE_PIN AK16 DIFF_TERM TRUE } [get_ports {RXCLK_N }]

set_property -dict { IOSTANDARD LVDS PACKAGE_PIN AL17 DIFF_TERM TRUE } [get_ports {CIN_P }]
set_property -dict { IOSTANDARD LVDS PACKAGE_PIN AM16 DIFF_TERM TRUE } [get_ports {CIN_N }]

# NO diff terms available here
#set_property -dict { IOSTANDARD LVDS PACKAGE_PIN F14 } [get_ports {PLCLK_P}]
#set_property -dict { IOSTANDARD LVDS PACKAGE_PIN F13 } [get_ports {PLCLK_N}]

set_property -dict { IOSTANDARD LVDS PACKAGE_PIN AG17 DIFF_TERM TRUE } [get_ports {PL_SYSREF_P}]
set_property -dict { IOSTANDARD LVDS PACKAGE_PIN AH17 DIFF_TERM TRUE } [get_ports {PL_SYSREF_N}]
create_clock -period 128.00 -name sysref_clk [get_ports -filter { NAME =~ "PL_SYSREF_P" && DIRECTION == "IN" }]

set sysrefclk [get_clocks sysref_clk]

set_max_delay -datapath_only -from $sysrefclk -to $axiclk 10.00
set_max_delay -datapath_only -from $axiclk -to $sysrefclk 10.00

set_max_delay -datapath_only -from $axiclk -to $rxclk 8.00
set_max_delay -datapath_only -from $rxclk -to $axiclk 8.00

connect_debug_port dbg_hub/clk [get_nets -of_objects $axiclk]

