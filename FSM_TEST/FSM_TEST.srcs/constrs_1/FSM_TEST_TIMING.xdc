create_clock -period 10.000 -name CLK -waveform {0.000 5.000} [get_ports -filter { NAME =~  "*CLK*" && DIRECTION == "IN" }]
create_clock -period 10.000 -name VCLK100 -waveform {0.000 5.000}
set_clock_groups -name group0 -asynchronous -group [get_clocks -of_objects [get_pins clk_wiz_11/inst/mmcm_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins clk_wiz_100/inst/mmcm_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins clk_wiz_153/inst/mmcm_adv_inst/CLKOUT0]] -group [list [get_clocks [list clk_wiz_11/inst/clk_100m_in clk_wiz_100/inst/clk_100m_in clk_wiz_153/inst/clk_100m_in [get_clocks -of_objects [get_pins clk_wiz_11/inst/mmcm_adv_inst/CLKFBOUT]] [get_clocks -of_objects [get_pins clk_wiz_100/inst/mmcm_adv_inst/CLKFBOUT]] [get_clocks -of_objects [get_pins clk_wiz_153/inst/mmcm_adv_inst/CLKFBOUT]]]] [get_clocks CLK]] -group [get_clocks VCLK100]
set_input_delay -clock [get_clocks VCLK100] 0.000 [get_ports {RST RST_BTN {RXD[0]} {RXD[1]} {RXD[2]} {RXD[3]} {RXD[4]} {RXD[5]} {RXD[6]} {RXD[7]} {RXD[8]} {RXD[9]} {RXD[10]} {RXD[11]} {RXD[12]} {RXD[13]} {RXD[14]} {RXD[15]} {RXD[16]} {RXD[17]} {RXD[18]} TRG}]
set_output_delay -clock [get_clocks VCLK100] 0.000 [get_ports -filter { NAME =~  "*" && DIRECTION == "OUT" }]


