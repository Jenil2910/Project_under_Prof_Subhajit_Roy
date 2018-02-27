This code uses nvgraph library from nvidia and finds the shortest possible path distance from source vertex to every node, and then it uses Dynamic Programming to get the actual path.



sssp.out is the executable file.

if we want to provide different input, put it into a .txt file and then run:
cat <input>.txt|./sssp.out

I have not taken the input according to the matrix you provided, but instead used an Adjacency Matrix.
Sample_output is present in the code.