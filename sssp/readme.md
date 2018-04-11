###  How to use this code??
To compile the sssp_to_be_given.cu use the following:-
`make all`
or `nvcc -lnvgraph -g sssp_to_be_given.cu`
### Input output format of sssp_to_be_given.cu.
time_finder()=> is the function that takes slowness value matrix, n(rows), m(columns) , `out`(pointer to 1D array) and `A`(pointer to 2D array). `out` array will be output for predicted time. In, `A` matrix i<sup>th</sup> row will have the distance for i<sup>th</sup> ray.
