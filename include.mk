# An example mkincl include Makefile.
NAME := mkincl
VERSION := $(shell git branch --show-current)

# Make provider specific targets dependencies to generic targets.
.PHONY: lint lint-$(NAME)
lint: lint-$(NAME)

.PHONY: fix fix-$(NAME)
fix: fix-$(NAME)

# Container target
IMAGE_REGISTRY := ghcr.io/carlsmedstad
IMAGE_MKINCL := $(IMAGE_REGISTRY)/$(NAME):$(VERSION)

.PHONY: enter-$(NAME)-container
enter-$(NAME)-container:
	docker run --rm --interactive --tty --pull always --volume "$$(pwd)":/pwd --workdir /pwd $(IMAGE_MKINCL)

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
