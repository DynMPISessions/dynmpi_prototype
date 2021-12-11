include common.makefile

####### Definitions

objects = heightmap.o
cflags = -g -O0
lflags = -lm
target = heightmap

####### Implicit rules

.SUFFIXES: .c
.c.o:
	$(MPICC) -c $(cflags) -o $@ $<

####### Target

.PHONY: all
all: $(target)

$(target): $(objects)
	$(MPICC) -o $@ $^ $(lflags)

####### Objects

hello.o:

####### Clean

.PHONY: clean
clean:
	$(RM) $(target) core $(objects) *~
