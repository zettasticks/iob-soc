CORE_NAME:=TIMER
IS_CORE:=1
USE_NETLIST ?=0

#RTL simulator
TIMER_SIMULATOR:=icarus

#paths
TIMER_SW_DIR:=$(TIMER_DIR)/software
TIMER_HW_DIR:=$(TIMER_DIR)/hardware
TIMER_HW_INC_DIR:=$(TIMER_HW_DIR)/include
