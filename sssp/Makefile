CC = nvcc
FLAG = -lnvgraph
OUT = sssp_to_be_given.out
ORIGIN = origin
BRANCH = master

all: ${OUT}

%.out: %.cu
	${CC} ${FLAG} $*.cu -o $*.out

pull:
	cd ..
	git pull ${ORIGIN} ${BRANCH}

push:
	cd  ..
	git push ${ORIGIN} ${BRANCH}
