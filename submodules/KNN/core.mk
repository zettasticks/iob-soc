CORE_NAME:=KNN
IS_CORE:=1
USE_NETLIST ?=0

#RTL simulator
KNN_SIMULATOR:=icarus

#paths
KNN_SW_DIR:=$(KNN_DIR)/software
KNN_HW_DIR:=$(KNN_DIR)/hardware
KNN_HW_INC_DIR:=$(KNN_HW_DIR)/include
