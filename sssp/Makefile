CC = nvcc
FLAG = -lnvgraph -g
OUT = sssp_to_be_given.out
CU = sssp_to_be_given.cu
ORIGIN = origin
BRANCH = master
INPUT_FILE = Input.txt

all: ${OUT}

%.out: %.cu
	${CC} ${FLAG} $*.cu -o $*.out

run:
	cat ${INPUT_FILE}|./${OUT}

rerun:
	${CC} ${FLAG} ${CU} -o ${OUT}
	cat ${INPUT_FILE}|./${OUT}

pull:
	cd .. && \
	git pull ${ORIGIN} ${BRANCH}

push:
	cd  .. && \
	git add . && \
	git commit -a && \
	git push ${ORIGIN} ${BRANCH}

clean:
	rm -rf *.out
