include common.makefile

####### Definitions

objects = stl_example3.o
cflags = -g -O0
lflags = 
target = stl_example3

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

stl_example3.o:

####### Clean

.PHONY: clean
clean:
	$(RM) $(target) core $(objects) *~
