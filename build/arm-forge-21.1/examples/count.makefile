include common.makefile

####### Definitions

objects = count.o
cflags = -g -O0
lflags = 
target = count

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

count.o:

####### Clean

.PHONY: clean
clean:
	$(RM) $(target) core $(objects) *~
