include common.makefile

.PHONY: all
all: prefix

prefix: prefix.cu
	nvcc -g -G -cudart=shared -o $@ $<

.PHONY: clean
clean:
	$(RM) prefix core
