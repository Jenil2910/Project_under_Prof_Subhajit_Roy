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
#define ROW 500
#define COL 4000
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
            int i_m,i_p,j_m,j_p;
            i_m=(i-1>0?i-1:0);
            i_p=(i>_N-1?_N-1:i);
            j_m=(j-1>0?j-1:0);
            j_p=(j>_M-1?_M-1:j);
            //case 1
            if(i>0){
                //case 1.1
                if(j>0){
                    weights[count]= ROOT_TWO * slow[i_m][j_m];
                    source[count]=(i-1)*(_M+1)+j_m;
                    count++;
                }
                //case 1.2
                    weights[count]=(slow[i_m][j_m]+slow[i_m][j_p])/2.0;
                    source[count]=(i-1)*(_M+1)+j;
                    count++;
                //case 1.3
                if(j<_M){
                    weights[count]= ROOT_TWO * slow[i-1][j];
                    source[count]=(i-1)*(_M+1)+j+1;
                    count++;
                }
            }
            //case 2
            //case 2.1
            if(j>0){
                weights[count]=(slow[i_m][j_m]+slow[i_p][j_m])/2.0;
                source[count]=(i)*(_M+1)+j-1;
                count++;
              }
            //case 2.2
            if(j<_M){
                weights[count]=(slow[i_m][j_p]+slow[i_p][j_p])/2.0;
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
                    weights[count]=(slow[i_p][j_m]+slow[i_p][j_p])/2.0;
                    source[count]=(i+1)*(_M+1)+j;
                    count++;
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


    int n = nodes, nnz = edges*2,    vertex_numsets = 1,    edge_numsets = 1;
    float *weights_h=new float[nnz];
    int *destination_offsets_h=new int[n+1];
    int *source_indices_h=new int[nnz];

    for(int i=0;i<nnz;i++){
    	weights_h[i]=weights[i];
    	source_indices_h[i]=source[i];
    }
    for(int i=0;i<nodes+1;i++){
    destination_offsets_h[i]=destination_offset[i];
    }
    delete weights;
    delete destination_offset;
    delete source;
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
    sssp_1_h = new float[n];
    vertex_dim = new void*[vertex_numsets];
    vertex_dimT=new cudaDataType_t[vertex_numsets];
    CSC_input= (nvgraphCSCTopology32I_t)new nvgraphCSCTopology32I_t;
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
    delete weights_h;
    delete destination_offsets_h;
    delete source_indices_h;
    free(vertex_dim);
    delete vertex_dimT;
    delete CSC_input;
    check(nvgraphDestroyGraphDescr(handle, graph));
    check(nvgraphDestroy(handle));
    return sssp_1_h;
}
int main(){
  float ** inp;
  int n=ROW,m=COL;
  inp=new float*[n];
  for(int i=0;i<n;i++){
    inp[i]=new float[m];
    for(int j=0;j<m;j++){
      inp[i][j]=1;
    }
  }
  float tpck[m+1];
  float* out=time_finder(inp,n,m);
  for(int i=0;i<m+1;i++){
    tpck[i]=2;

  }
  double sum=0;
  for(int i=0;i<m+1;i++){
    cout<<out[i]<<" ";
    sum=sum+(tpck[i]-out[i])*(tpck[i]-out[i]);
  }
  cout<<endl<<sum<<endl;
  return 0;
}
