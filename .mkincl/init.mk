MKINCL_DIR ?= .mkincl
INITS = $(wildcard $(MKINCL_DIR)/inits/*)

.PHONY: init-mkincl $(INITS)
init-mkincl: clean-mkincl $(INITS)
$(INITS):
	@echo -- Initializing provider $@
	. $(realpath $@) \
	&& mkdir -p $(MKINCL_DIR)/providers \
	&& git clone --quiet $$URL $(MKINCL_DIR)/providers/$$NAME \
	&& git -C $(MKINCL_DIR)/providers/$$NAME reset --quiet --hard $$VERSION

.PHONY: clean-mkincl
clean-mkincl:
	rm -rf $(MKINCL_DIR)/providers

-include $(MKINCL_DIR)/providers/*/include.mk
