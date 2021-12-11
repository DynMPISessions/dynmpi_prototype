include common.makefile

####### Definitions

objects = matrix_mult.o
cflags = -g -O0
lflags = 
target = matrix_mult

####### Implicit rules

.SUFFIXES: .cpp
.cpp.o:
	$(MPICXX) -c $(cflags) -o $@ $<

####### Target

.PHONY: all
all: $(target)

$(target): $(objects)
	$(MPICXX) $(cflags) -o $@ $^ $(lflags)

####### Objects

matrix_mult.o:

####### Clean

.PHONY: clean
clean:
	$(RM) $(target) core $(objects) *~
