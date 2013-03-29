FILES ?= $(wildcard *.sh)

all: lint

lint:
	@$(foreach file, $(FILES), $(shell bash -n $(file)))
