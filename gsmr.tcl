# Create a new project
create_project -force -part xc7a100tcsg324-1 gsmr gsmr
set_property board_part digilentinc.com:nexys-a7-100t:part0:1.3 [current_project]

# Create a new BD
create_bd_design microblaze_subsystem

# Create clock and reset interface ports
create_bd_port -dir I -type clk -freq_hz 100000000 sys_clock
create_bd_port -dir I -type rst reset

# Create clock wizard
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
set_property CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} [get_bd_cells /clk_wiz_0]
set_property CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} [get_bd_cells /clk_wiz_0]
set_property CONFIG.RESET_BOARD_INTERFACE {reset} [get_bd_cells /clk_wiz_0]
set_property CONFIG.USE_BOARD_FLOW {true} [get_bd_cells /clk_wiz_0]
set_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.0} [get_bd_cells /clk_wiz_0]

# Create reset wizard
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_wiz_0
set_property CONFIG.RESET_BOARD_INTERFACE {reset} [get_bd_cells /rst_wiz_0]

# Add extra NOT gate since the clock wizard requires active high reset,
# whereas reset is active low in the system
create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 reset_inv_0
set_property CONFIG.C_OPERATION {not} [get_bd_cells /reset_inv_0]
set_property CONFIG.C_SIZE {1} [get_bd_cells /reset_inv_0]

# Wire up clock and reset wizards
connect_bd_net [get_bd_ports /reset] [get_bd_pins /reset_inv_0/Op1]
connect_bd_net [get_bd_pins /reset_inv_0/Res] [get_bd_pins /clk_wiz_0/reset]
connect_bd_net [get_bd_ports /sys_clock] [get_bd_pins /clk_wiz_0/clk_in1]

connect_bd_net [get_bd_ports /reset] [get_bd_pin /rst_wiz_0/ext_reset_in]
connect_bd_net [get_bd_pins /clk_wiz_0/locked] [get_bd_pin /rst_wiz_0/dcm_locked]
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pin /rst_wiz_0/slowest_sync_clk]

# Create output ports

# Create basic Microblaze, set basic config and wire up clock and reset
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0
set_property CONFIG.C_D_AXI {1} [get_bd_cells /microblaze_0]
set_property CONFIG.C_USE_BARREL {true} [get_bd_cells /microblaze_0]
set_property CONFIG.C_USE_DIV {true} [get_bd_cells /microblaze_0]
set_property CONFIG.C_USE_FPU {true} [get_bd_cells /microblaze_0]
set_property CONFIG.C_USE_HW_MUL {true} [get_bd_cells /microblaze_0]
set_property CONFIG.C_USE_MMU {3} [get_bd_cells /microblaze_0]
set_property CONFIG.C_USE_REORDER_INSTR {true} [get_bd_cells /microblaze_0]
set_property CONFIG.C_USE_BRANCH_TARGET_CACHE {true} [get_bd_cells /microblaze_0]
set_property CONFIG.C_NUMBER_OF_PC_BRK {8} [get_bd_cells /microblaze_0]
set_property CONFIG.C_NUMBER_OF_RD_ADDR_BRK {4} [get_bd_cells /microblaze_0]
set_property CONFIG.C_NUMBER_OF_WR_ADDR_BRK {4} [get_bd_cells /microblaze_0]
set_property CONFIG.C_USE_INTERRUPT {true} [get_bd_cells /microblaze_0]
connect_bd_net [get_bd_pins /rst_wiz_0/mb_reset] [get_bd_pins /microblaze_0/Reset]
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /microblaze_0/Clk]

# Create debug core, wire up reset, and connect it to Microblaze
create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_0
connect_bd_net [get_bd_pins /mdm_0/Debug_SYS_Rst] [get_bd_pins /rst_wiz_0/mb_debug_sys_rst]
connect_bd_intf_net [get_bd_intf_pins /mdm_0/MBDEBUG_0] [get_bd_intf_pins /microblaze_0/DEBUG]

# LMB, which is a real chore

# Instantiate all IP cores needed
create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_0
create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_0
create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr_0
create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr_0
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram_0
# Configure BRAM
set_property CONFIG.Memory_Type {True_Dual_Port_RAM} [get_bd_cells /lmb_bram_0]
set_property CONFIG.use_bram_block {BRAM_Controller} [get_bd_cells /lmb_bram_0]
set_property CONFIG.EN_SAFETY_CKT {false} [get_bd_cells /lmb_bram_0]
# Wire up reset
connect_bd_net [get_bd_pins /rst_wiz_0/bus_struct_reset] [get_bd_pins /dlmb_0/SYS_Rst]
connect_bd_net [get_bd_pins /rst_wiz_0/bus_struct_reset] [get_bd_pins /ilmb_0/SYS_Rst]
connect_bd_net [get_bd_pins /rst_wiz_0/bus_struct_reset] [get_bd_pins /dlmb_bram_if_cntlr_0/LMB_Rst]
connect_bd_net [get_bd_pins /rst_wiz_0/bus_struct_reset] [get_bd_pins /ilmb_bram_if_cntlr_0/LMB_Rst]
# Wire up clock
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /dlmb_0/LMB_Clk]
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /ilmb_0/LMB_Clk]
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /dlmb_bram_if_cntlr_0/LMB_Clk]
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /ilmb_bram_if_cntlr_0/LMB_Clk]
# Wire up BRAM controller, actual BRAM and local memory cores
connect_bd_intf_net [get_bd_intf_pins /dlmb_bram_if_cntlr_0/BRAM_PORT] [get_bd_intf_pins /lmb_bram_0/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins /ilmb_bram_if_cntlr_0/BRAM_PORT] [get_bd_intf_pins /lmb_bram_0/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins /dlmb_0/LMB_Sl_0] [get_bd_intf_pins /dlmb_bram_if_cntlr_0/SLMB]
connect_bd_intf_net [get_bd_intf_pins /ilmb_0/LMB_Sl_0] [get_bd_intf_pins /ilmb_bram_if_cntlr_0/SLMB]
# Finally, connect local memory to Microblaze
connect_bd_intf_net [get_bd_intf_pins /microblaze_0/DLMB] [get_bd_intf_pins dlmb_0/LMB_M]
connect_bd_intf_net [get_bd_intf_pins /microblaze_0/ILMB] [get_bd_intf_pins ilmb_0/LMB_M]

# AXI
# First create output ports
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 led_16bits
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 usb_uart
# Create AXI smartconnect and configure it
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_0
set_property CONFIG.NUM_MI {4} [get_bd_cells /axi_smc_0]
set_property CONFIG.NUM_SI {1} [get_bd_cells /axi_smc_0]
# Create actual AXI peripherals and configure them
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property CONFIG.GPIO_BOARD_INTERFACE {led_16bits} [get_bd_cells /axi_gpio_0]
set_property CONFIG.USE_BOARD_FLOW {true} [get_bd_cells /axi_gpio_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
set_property CONFIG.UARTLITE_BOARD_INTERFACE {usb_uart} [get_bd_cells /axi_uartlite_0]
set_property CONFIG.USE_BOARD_FLOW {true} [get_bd_cells /axi_uartlite_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc_0
# Wire AXI connections
connect_bd_intf_net [get_bd_intf_ports /led_16bits] [get_bd_intf_pins /axi_gpio_0/GPIO]
connect_bd_intf_net [get_bd_intf_ports /usb_uart] [get_bd_intf_pins /axi_uartlite_0/UART]
connect_bd_intf_net [get_bd_intf_pins /axi_smc_0/M00_AXI] [get_bd_intf_pins /axi_gpio_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins /axi_smc_0/M01_AXI] [get_bd_intf_pins /axi_uartlite_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins /axi_smc_0/M02_AXI] [get_bd_intf_pins /axi_timer_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins /axi_smc_0/M03_AXI] [get_bd_intf_pins /axi_intc_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins /microblaze_0/M_AXI_DP] [get_bd_intf_pins /axi_smc_0/S00_AXI]
# Wire up AXI clock
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /axi_smc_0/aclk]
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /axi_gpio_0/s_axi_aclk]
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /axi_uartlite_0/s_axi_aclk]
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /axi_timer_0/s_axi_aclk]
connect_bd_net [get_bd_pins /clk_wiz_0/clk_out1] [get_bd_pins /axi_intc_0/s_axi_aclk]
# Wire up reset
connect_bd_net [get_bd_pins /rst_wiz_0/peripheral_aresetn] [get_bd_pins /axi_smc_0/aresetn]
connect_bd_net [get_bd_pins /rst_wiz_0/peripheral_aresetn] [get_bd_pins /axi_gpio_0/s_axi_aresetn]
connect_bd_net [get_bd_pins /rst_wiz_0/peripheral_aresetn] [get_bd_pins /axi_uartlite_0/s_axi_aresetn]
connect_bd_net [get_bd_pins /rst_wiz_0/peripheral_aresetn] [get_bd_pins /axi_timer_0/s_axi_aresetn]
connect_bd_net [get_bd_pins /rst_wiz_0/peripheral_aresetn] [get_bd_pins /axi_intc_0/s_axi_aresetn]

# Interrupts
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 int_concat_0
connect_bd_net [get_bd_pins /axi_uartlite_0/interrupt] [get_bd_pins /int_concat_0/In0]
connect_bd_net [get_bd_pins /axi_timer_0/interrupt] [get_bd_pins /int_concat_0/In1]
connect_bd_net [get_bd_pins /int_concat_0/dout] [get_bd_pins /axi_intc_0/intr]
connect_bd_intf_net [get_bd_intf_pins /microblaze_0/INTERRUPT] [get_bd_intf_pins /axi_intc_0/interrupt]

# Assign addresses, validate the design and save it
assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces /microblaze_0/Data] [get_bd_addr_segs /axi_gpio_0/S_AXI/Reg] -force
assign_bd_address -offset 0x41200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces /microblaze_0/Data] [get_bd_addr_segs /axi_intc_0/S_AXI/Reg] -force
assign_bd_address -offset 0x41C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces /microblaze_0/Data] [get_bd_addr_segs /axi_timer_0/S_AXI/Reg] -force
assign_bd_address -offset 0x40600000 -range 0x00010000 -target_address_space [get_bd_addr_spaces /microblaze_0/Data] [get_bd_addr_segs /axi_uartlite_0/S_AXI/Reg] -force
assign_bd_address -offset 0x00000000 -range 0x00008000 -target_address_space [get_bd_addr_spaces /microblaze_0/Data] [get_bd_addr_segs /dlmb_bram_if_cntlr_0/SLMB/Mem] -force
assign_bd_address -offset 0x00000000 -range 0x00008000 -target_address_space [get_bd_addr_spaces /microblaze_0/Instruction] [get_bd_addr_segs /ilmb_bram_if_cntlr_0/SLMB/Mem] -force
validate_bd_design
save_bd_design

# Generate wrapper
make_wrapper -force -top [get_files microblaze_subsystem.bd]
add_file ./gsmr/gsmr.gen/sources_1/bd/microblaze_subsystem/hdl/microblaze_subsystem_wrapper.v
