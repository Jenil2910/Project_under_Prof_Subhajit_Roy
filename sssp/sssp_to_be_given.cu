#include<iostream>
#include<nvgraph.h>
#include<bits/stdc++.h>
#include<stdio.h>

#define ROOT_TWO sqrt(2)
using namespace std;
///////////////////////////////////////////////////
void check(nvgraphStatus_t status) {
  if (status != NVGRAPH_STATUS_SUCCESS) {
    printf("ERROR : %d\n", status);
    exit(0);
  }
}

float* time_finder(float **slow,int _N,int _M) {
    int edges=_N *( _M +1)+(_N+1)*_M+ _M * _N*2;
    int nodes=(_N+1)*(_M+1);
    float* weights=new float[edges*2];
    int* destination_offset=new int[nodes+1];
    int* source=new int[edges*2];
    int count=0;
    for(int i=0;i<= _N;i++){
        for(int j=0;j<= _M;j++){
            int index=i*(_M+1)+j;
            destination_offset[index]=count;
            //case 1
            if(i>0){
                //case 1.1
                if(j>0){
                    weights[count]= ROOT_TWO * slow[i-1][j-1];
                    source[count]=(i-1)*(_M+1)+j-1;
                    count++;
                }
                //case 1.2
                if(j>0&&j<_M){
                    weights[count]=(slow[i-1][j-1]+slow[i-1][j])/2.0;
                    source[count]=(i-1)*(_M+1)+j;
                    count++;
                }else if(j==_M){
                    weights[count]=slow[i-1][j-1];
                    source[count]=(i-1)*(_M+1)+j;
                    count++;
                }else{//j==0
                    weights[count]=slow[i-1][j];
                    source[count]=(i-1)*(_M+1)+j;
                    count++;
                }
                //case 1.3
                if(j<_M){
                    weights[count]= ROOT_TWO * slow[i-1][j];
                    source[count]=(i-1)*(_M+1)+j+1;
                    count++;
                }
            }
            //case 2
            //case 2.1
            if(i>0&&j>0&&i<_N){
                weights[count]=(slow[i-1][j-1]+slow[i][j-1])/2.0;
                source[count]=(i)*(_M+1)+j-1;
                count++;
            }else if(i==0&&j>0){
                weights[count]=slow[i][j-1];
                source[count]=(i)*(_M+1)+j-1;
                count++;
            }else if(i==_N&&j>0){
                weights[count]=slow[i-1][j-1];
                source[count]=(i)*(_M+1)+j-1;
                count++;
            }
            //case 2.2
            if(i>0&&j<_M&&i<_N){
                weights[count]=(slow[i-1][j]+slow[i][j])/2.0;
                source[count]=(i)*(_M+1)+j+1;
                count++;
            }else if(i==0&&j<_M){
                weights[count]=slow[i][j];
                source[count]=(i)*(_M+1)+j+1;
                count++;
            }else if(i==_N&&j<_M){
                weights[count]=slow[i-1][j];
                source[count]=(i)*(_M+1)+j+1;
                count++;
            }
            //case 3
            if(i<_N){
                //case 3.1
                if(j>0){
                    weights[count]= ROOT_TWO * slow[i][j-1];
                    source[count]=(i+1)*(_M+1)+j-1;
                    count++;
                }
                //case 3.2
                if(j>0&&j<_M){
                    weights[count]=(slow[i][j-1]+slow[i][j])/2.0;
                    source[count]=(i+1)*(_M+1)+j;
                    count++;
                }else if(j==_M){
                    weights[count]=slow[i][j-1];
                    source[count]=(i+1)*(_M+1)+j;
                    count++;
                }else{//j==0
                    weights[count]=slow[i][j];
                    source[count]=(i+1)*(_M+1)+j;
                    count++;
                }
                //case 3.3
                if(j<_M){
                    weights[count]= ROOT_TWO * slow[i][j];
                    source[count]=(i+1)*(_M+1)+j+1;
                    count++;
                }
            }
        }
    }
    destination_offset[nodes]=count;
	//Converting Adjacency Matrix in input to required input for nvgraph


    const size_t n = nodes, nnz = edges*2,    vertex_numsets = 1,    edge_numsets = 1;
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


    float* Actual_seed = new float[(_N+1)*(_M+1)];
    double error=0;
    free(vertex_dim);
    free(vertex_dimT);
    free(CSC_input);
    check(nvgraphDestroyGraphDescr(handle, graph));
    check(nvgraphDestroy(handle));
    return sssp_1_h;
}
int main(){
  float ** inp;
  inp=(float**)malloc(sizeof(float*)*10);
  for(int i=0;i<10;i++){
    inp[i]=(float*)malloc(sizeof(float)*20);
    for(int j=0;j<20;j++){
      inp[i][j]=1;
    }
  }
  float* out=time_finder(inp,10,20);
  for (int i = 0; i < 21; i++) {
    cout<<out[i]<<' ';
  }
  return 0;
}
