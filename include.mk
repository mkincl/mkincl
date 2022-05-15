# An example mkincl include Makefile.
MYDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
NAME := $(shell basename $(MYDIR))
VERSION := $(shell git branch --show-current)

# Make provider specific targets dependencies to generic targets.
.PHONY: lint lint-$(NAME)
lint: lint-$(NAME)

.PHONY: fix fix-$(NAME)
fix: fix-$(NAME)

# Define the provider's actual targets.
.PHONY: lint-$(NAME)-linter1 lint-$(NAME)-linter2
lint-$(NAME): lint-$(NAME)-linter1 lint-$(NAME)-linter2

lint-$(NAME)-linter1:
	echo "Running linter1"

lint-$(NAME)-linter2:
	echo "Running linter2"

.PHONY: fix-$(NAME)-fixer1 fix-$(NAME)-fixer2
fix-$(NAME): fix-$(NAME)-fixer1 fix-$(NAME)-fixer2

fix-$(NAME)-fixer1:
	echo "Running fixer1"

fix-$(NAME)-fixer2:
	echo "Running fixer2"
