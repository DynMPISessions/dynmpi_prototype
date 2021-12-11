include common.makefile

.PHONY: all
all: kmeans

kmeans: kmeans.upc
	upcc -tv $< -o $@

.PHONY: clean
clean:
	$(RM) kmeans
