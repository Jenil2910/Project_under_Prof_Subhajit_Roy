###  How to use this code??
To compile the sssp_to_be_given.cu use the following:-
`make all`
or `nvcc -lnvgraph -g sssp_to_be_given.cu`
### Input output format of sssp_to_be_given.cu.
time_finder()=> is the function that takes slowness value matrix, n(rows) and m(columns).
And output a 1D vector whose ith index is the time required to go from source node (0,0) to (0,i).
0<=i<=n   
