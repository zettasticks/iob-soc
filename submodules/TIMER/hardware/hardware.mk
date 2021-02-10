include $(TIMER_DIR)/core.mk

#submodules
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
SUBMODULES+=INTERCON
INTERCON_DIR:=$(TIMER_DIR)/submodules/INTERCON
include $(INTERCON_DIR)/hardware/hardware.mk
endif

#include
INCLUDE+=$(incdir) $(TIMER_HW_INC_DIR)
INCLUDE+=$(incdir) $(LIB_DIR)/hardware/include
INCLUDE+=$(incdir) $(INTERCON_DIR)/hardware/include
TIMER_INC_DIR:=$(TIMER_HW_DIR)/include
INCLUDE+=$(incdir) $(TIMER_INC_DIR)


#headers
VHDR+=$(wildcard $(TIMER_HW_INC_DIR)/*.vh)
VHDR+=$(wildcard $(LIB_DIR)/hardware/include/*.vh)
VHDR+=$(wildcard $(INTERCON_DIR)/hardware/include/*.vh $(INTERCON_DIR)/hardware/include/*.v)
VHDR+=$(TIMER_HW_INC_DIR)/sw_reg_gen.v
VHDR+=$(wildcard $(TIMER_INC_DIR)/*.vh)

#sources
TIMER_SRC_DIR:=$(TIMER_DIR)/hardware/src
VSRC+=$(wildcard $(TIMER_HW_DIR)/src/*.v)

$(TIMER_HW_INC_DIR)/sw_reg_gen.v: $(TIMER_HW_INC_DIR)/sw_reg.v
	$(LIB_DIR)/software/mkregs.py $< HW
	mv sw_reg_gen.v $(TIMER_HW_INC_DIR)
	mv sw_reg_w.vh $(TIMER_HW_INC_DIR)

.PHONY: timer_clean_hw
