include $(KNN_DIR)/core.mk

#submodules
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
SUBMODULES+=INTERCON
INTERCON_DIR:=$(KNN_DIR)/submodules/INTERCON
include $(INTERCON_DIR)/hardware/hardware.mk
endif

#include
INCLUDE+=$(incdir) $(KNN_HW_INC_DIR)
INCLUDE+=$(incdir) $(LIB_DIR)/hardware/include
INCLUDE+=$(incdir) $(INTERCON_DIR)/hardware/include
KNN_INC_DIR:=$(KNN_HW_DIR)/include
INCLUDE+=$(incdir) $(KNN_INC_DIR)


#headers
VHDR+=$(wildcard $(KNN_HW_INC_DIR)/*.vh)
VHDR+=$(wildcard $(LIB_DIR)/hardware/include/*.vh)
VHDR+=$(wildcard $(INTERCON_DIR)/hardware/include/*.vh $(INTERCON_DIR)/hardware/include/*.v)
VHDR+=$(KNN_HW_INC_DIR)/KNN_sw_reg_gen.v
VHDR+=$(wildcard $(KNN_INC_DIR)/*.vh)

#sources
KNN_SRC_DIR:=$(KNN_DIR)/hardware/src
VSRC+=$(wildcard $(KNN_HW_DIR)/src/*.v)

$(KNN_HW_INC_DIR)/KNN_sw_reg_gen.v: $(KNN_HW_INC_DIR)/KNN_sw_reg.v
	$(LIB_DIR)/software/mkregs.py $< HW
	mv KNN_sw_reg_gen.v $(KNN_HW_INC_DIR)
	mv KNN_sw_reg_w.vh $(KNN_HW_INC_DIR)

.PHONY: knn_clean_hw
