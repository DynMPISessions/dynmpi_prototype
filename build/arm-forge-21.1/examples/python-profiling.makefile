include common.makefile
CFLAGS = $(MAP_CFLAGS) -fPIC
LDFLAGS = -shared

targets = libfibonacci.so

.PHONY: all
all: $(targets)

lib%.so : %.c
	$(LINK.c) $^ -o $@

.PHONY: clean
clean:
	$(RM) $(targets)
