MKINCL_DIR ?= .mkincl
INITS = $(wildcard $(MKINCL_DIR)/inits/*)

.PHONY: init $(INITS)
init: clean $(INITS)
$(INITS):
	. $(realpath $@) \
	&& mkdir -p $(MKINCL_DIR)/providers \
	&& git clone --quiet $$URL $(MKINCL_DIR)/providers/$$NAME \
	&& git -C $(MKINCL_DIR)/providers/$$NAME reset --quiet --hard $$VERSION

.PHONY: clean
clean:
	rm -rf $(MKINCL_DIR)/providers

-include $(MKINCL_DIR)/providers/*/include.mk
