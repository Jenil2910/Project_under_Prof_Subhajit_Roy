This code uses nvgraph library from nvidia and finds the shortest possible path distance from source vertex to every node, and then it uses Dynamic Programming to get the actual path.



sssp.out is the executable file.

if we want to provide different input, put it into a .txt file and then run:
cat <input>.txt|./sssp.out

### input in slowness matrix is taken in input.cpp and get converted in required input format for sssp.cu
In the input file _N, _M are number of rows and columns 

