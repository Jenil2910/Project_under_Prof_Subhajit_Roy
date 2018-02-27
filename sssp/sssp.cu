#include<iostream>
#include<nvgraph.h>
#include<bits/stdc++.h>
#include<stdio.h>

void check(nvgraphStatus_t status) {
  if (status != NVGRAPH_STATUS_SUCCESS) {
    printf("ERROR : %d\n", status);
    exit(0);
  }
}

/*
This code takes Adjacency Matrix as input and finds the exact shortest path from source to every vertex.
Sample input is provided alongside the code.
Sample output obtained is:

Path to vertex 1
1 <- 0
Path to vertex 2
2 <- 1 <- 0
Path to vertex 3
3 <- 1 <- 0
Path to vertex 4
4 <- 3 <- 1 <- 0

*/




int main(int argc, char * * argv) {

  int edges, nodes;
	scanf("%d %d",&nodes,&edges);
	float Matrix[nodes][nodes];
	for(int i=0;i<nodes;i++){
	    for(int j=0;j<nodes;j++){
	        scanf("%f",&Matrix[i][j]);
	    }
	}
	int d_off=0;
	int edge_itr=0;
	float weights[edges];
	int destination_offset[nodes+1];
	int source[edges];
	for(int j=0;j<nodes;j++){
	    destination_offset[j]=d_off;
	    for(int i=0;i<nodes;i++){
	        if(Matrix[i][j]!=-1){
	            source[edge_itr]=i;
	            weights[edge_itr]=Matrix[i][j];
	            edge_itr++;
	            d_off++;
	        }
	    }
	}
	destination_offset[nodes]=edges;
	//Converting Adjacency Matrix in input to required input for nvgraph
  
  
  const size_t n = nodes, nnz = edges,    vertex_numsets = 1,    edge_numsets = 1;
  float weights_h[nnz];
  int destination_offsets_h[nodes+1];
  int source_indices_h[nnz];
  
  for(int i=0;i<nnz;i++){
		weights_h[i]=weights[i];
		source_indices_h[i]=source[i];
  }
  for(int i=0;i<nodes+1;i++){
	destination_offsets_h[i]=destination_offset[i];
  }
  
  //Converting our variables to variables for nvgraph
  
  float * sssp_1_h;
  void * * vertex_dim; // nvgraph variables _h for host data.
  nvgraphStatus_t status;
  nvgraphHandle_t handle;
  nvgraphGraphDescr_t graph;
  nvgraphCSCTopology32I_t CSC_input;
  cudaDataType_t edge_dimT = CUDA_R_32F;
  cudaDataType_t * vertex_dimT;
  
  
  // Init host data 
  sssp_1_h = (float * ) malloc(n * sizeof(float));
  vertex_dim = (void * * ) malloc(vertex_numsets * sizeof(void * ));
  vertex_dimT = (cudaDataType_t * ) malloc(vertex_numsets * sizeof(cudaDataType_t));
  CSC_input = (nvgraphCSCTopology32I_t) malloc(sizeof(struct nvgraphCSCTopology32I_st));
  vertex_dim[0] = (void * ) sssp_1_h;
  vertex_dimT[0] = CUDA_R_32F;
  
  /*float weights_h[],  destination_offsets_h[],   source_indices_h[]  are defined earlier...*/
  
  
  check(nvgraphCreate( & handle));
  check(nvgraphCreateGraphDescr(handle, & graph));
  CSC_input -> nvertices = n;
  CSC_input -> nedges = nnz;
  CSC_input -> destination_offsets = destination_offsets_h;
  CSC_input -> source_indices = source_indices_h;
  check(nvgraphSetGraphStructure(handle, graph, (void * ) CSC_input, NVGRAPH_CSC_32));
  check(nvgraphAllocateVertexData(handle, graph, vertex_numsets, vertex_dimT));
  check(nvgraphAllocateEdgeData(handle, graph, edge_numsets, & edge_dimT));
  check(nvgraphSetEdgeData(handle, graph, (void * ) weights_h, 0));
  int source_vert = 0;
  check(nvgraphSssp(handle, graph, 0, & source_vert, 0));
  check(nvgraphGetVertexData(handle, graph, (void * ) sssp_1_h, 0));
  
  
  //sssp_1_h is the array that contains the shortest distance of every vertex from the source.
  
  
  ///////////////////////////////////////////////
  int parent[n];
  parent[0]=0;
  for(int i=1;i<n;i++){
	int j=i;
	int d_start=destination_offsets_h[j];
	int d_end=destination_offsets_h[j+1];
	int min=d_start;
	for(int y=d_start;y<d_end;y++){
		if(sssp_1_h[source_indices_h[min]]+weights_h[min]>sssp_1_h[source_indices_h[y]]+weights_h[y]){
			min=y;
		}
	}
	j=source_indices_h[min];
	parent[i]=j;
  }
  
  for(int i=1;i<n;i++){
	int node=i;
	printf("Path to vertex %d\n",i);
	while((node!=0)&&(node!=parent[node])){
		printf("%d <- ",node);
		node=parent[node];
	}
	printf("0\n");
  }
  
  //Use DP for finding the exact path.
  //////////////////////////////////////////////
  
  free(sssp_1_h);
  free(vertex_dim);
  free(vertex_dimT);
  free(CSC_input);
  check(nvgraphDestroyGraphDescr(handle, graph));
  check(nvgraphDestroy(handle));
  return 0;
}
