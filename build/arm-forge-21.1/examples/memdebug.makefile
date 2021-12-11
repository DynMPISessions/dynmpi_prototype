include common.makefile

####### Definitions

objects = memdebug.o
cflags = -g -O0
lflags = 
target = memdebug

####### Implicit rules

.SUFFIXES: .cpp
.cpp.o:
	$(CXX) -c $(cflags) -o $@ $<

####### Target

.PHONY: all
all: $(target)

$(target): $(objects)
	$(CXX) $(cflags) -o $@ $^ $(lflags)

####### Objects

memdebug.o:

####### Clean

.PHONY: clean
clean:
	$(RM) $(target) core $(objects) *~
