include $(TIMER_DIR)/core.mk

#SUBMODULES
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
SUBMODULES+=INTERCON
INTERCON_DIR:=$(TIMER_DIR)/submodules/INTERCON
include $(INTERCON_DIR)/software/software.mk
endif

#INCLUDE
INCLUDE+=-I$(TIMER_DIR)/software

#HEADERS
HDR+=$(TIMER_SW_DIR)/iob-timer.h $(TIMER_SW_DIR)/TIMER_sw_reg.h

$(TIMER_SW_DIR)/TIMER_sw_reg.h: $(TIMER_HW_INC_DIR)/TIMER_sw_reg.v
	$(LIB_DIR)/software/mkregs.py $< SW
	mv TIMER_sw_reg.h $@

