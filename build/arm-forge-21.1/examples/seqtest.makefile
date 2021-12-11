include common.makefile

####### Definitions

objects = seqtest.o
cflags = -g -O0
lflags = 
target = seqtest

####### Implicit rules

.SUFFIXES: .c
.c.o:
	$(CC) -c $(cflags) -o $@ $<

####### Target

.PHONY: all
all: $(target)

$(target): $(objects)
	$(CC) $(cflags) -o $@ $^ $(lflags) 

####### Objects

seqtest.o:

####### Clean

.PHONY: clean
clean:
	$(RM) $(target) core $(objects) *~
