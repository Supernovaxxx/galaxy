# Development management facilities
#
# This file specifies useful routines to streamline development management.
# See https://www.gnu.org/software/make/.


# Consume environment variables
ifneq (,$(wildcard .env))
	include .env
endif

# Tool configuration
SHELL := /bin/bash
GNUMAKEFLAGS += --no-print-directory

# Path record
ROOT_DIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CONTENT_DIR ?= content
OUTPUT_DIR ?= public

# Target files
ENV_FILE ?= .env
EPHEMERAL_ARCHIVES ?= \
	$(OUTPUT_DIR)

# Behavior setup
PROJECT_NAME ?= $(shell basename $(ROOT_DIR) | tr a-z A-Z)

# Executables definition
GIT ?= git
SUBMODULES ?= $(GIT) submodule
NPM ?= npm
QUARTZ ?= npx quartz
REMOVE ?= rm -fr

# Execution configuration


%: # Treat unrecognized targets
	@ printf "\033[31;1mUnrecognized routine: '$(*)'\033[0m\n"
	$(MAKE) help

help:: ## Show this help
	@ printf "\033[33;1mGNU-Make available routines:\n"
	egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[37;1m%-20s\033[0m %s\n", $$1, $$2}'

prepare:: ## Inicialize virtual environment
	test -r $(ENV_FILE) -o ! -r $(ENV_FILE).example || cp $(ENV_FILE).example $(ENV_FILE)
	$(GIT) config --local include.path .gitconfig

init:: veryclean prepare $(REQUIREMENTS_TXT) ## Configure development environment
	$(SUBMODULES) update --init --recursive
	$(SUBMODULES) foreach --recursive $(MAKE) prepare
	$(NPM) install .

execute:: setup run ## Setup and run application

setup:: clean ## Process source code into an executable program

bundle:: ## Bundle source files
	$(NPM) run bundle

build:: setup ## Build application
	$(QUARTZ) build \
		--directory $(CONTENT_DIR) \
		--output $(OUTPUT_DIR)

run:: ## Launch application locally
	$(QUARTZ) build \
		--directory $(CONTENT_DIR) \
		--output $(OUTPUT_DIR) \
		--serve

finish:: ## Stop application execution

clean:: ## Delete project ephemeral archives
	-$(REMOVE) $(EPHEMERAL_ARCHIVES)

veryclean:: clean ## Delete all generated files
	-$(REMOVE) node_modules


.EXPORT_ALL_VARIABLES:
.ONESHELL:
.PHONY: help prepare init execute setup bundle build run finish clean veryclean