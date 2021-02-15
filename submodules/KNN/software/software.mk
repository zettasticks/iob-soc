include $(KNN_DIR)/core.mk

#SUBMODULES
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
SUBMODULES+=INTERCON
INTERCON_DIR:=$(KNN_DIR)/submodules/INTERCON
include $(INTERCON_DIR)/software/software.mk
endif

#INCLUDE
INCLUDE+=-I$(KNN_DIR)/software

#HEADERS
HDR+=$(KNN_SW_DIR)/iob-knn.h $(KNN_SW_DIR)/KNN_sw_reg.h

$(KNN_SW_DIR)/KNN_sw_reg.h: $(KNN_HW_INC_DIR)/KNN_sw_reg.v
	$(LIB_DIR)/software/mkregs.py $< SW
	mv KNN_sw_reg.h $@

