include common.makefile

####### Definitions

objects = simple.o
cflags = -g -O0
lflags = 
target = simple

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

simple.o:

####### Clean

.PHONY: clean
clean:
	$(RM) $(target) core $(objects) *~
