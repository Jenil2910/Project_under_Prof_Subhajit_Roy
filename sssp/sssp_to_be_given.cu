
#include <nvgraph.h>
#include <bits/stdc++.h>
#include<cuda.h>
#define ROOT_TWO sqrt(2)
using namespace std;
///////////////////////////////////////////////////
void check(nvgraphStatus_t status) {
        if (status != NVGRAPH_STATUS_SUCCESS) {
                printf("ERROR : %d\n", status);
                exit(0);
        }
}
#define ROW 3
#define COL 3
void time_finder(float* sssp_1_h,float *slow,int _N,int _M,float** actualSeed) {
        int n=(_N+1)*(_M+1), vertex_numsets = 1, edge_numsets = 1, nnz=(_N *( _M +1)+(_N+1)*_M+ _M*_N*2)*2; //nnz=edges*2;
        float *weights_h=new float[nnz];
        int *destination_offsets_h=new int[n+1];
        int *source_indices_h=new int[nnz];
        int count=0;
        for(int i=0; i<= _N; i++) {
                for(int j=0; j<= _M; j++) {
                        int index=i*(_M+1)+j;
                        destination_offsets_h[index]=count;
                        int i_m,i_p,j_m,j_p;
                        i_m=(i-1>0 ? i-1 : 0);
                        i_p=(i>_N-1 ? _N-1 : i);
                        j_m=(j-1>0 ? j-1 : 0);
                        j_p=(j>_M-1 ? _M-1 : j);
                        //case 1
                        if(i>0) {
                                //case 1.1
                                if(j>0) {
                                        weights_h[count]= ROOT_TWO * slow[ i_m*(_M) + j_m];
                                        source_indices_h[count]=(i_m)*(_M+1)+j_m;
                                        count++;
                                }
                                //case 1.2
                                weights_h[count]=(slow[i_m*(_M+1) + j_m]+slow[i_m*(_M) + j_p])/2.0;
                                source_indices_h[count]=(i_m)*(_M+1)+j;
                                count++;
                                //case 1.3
                                if(j<_M) {
                                        weights_h[count]= ROOT_TWO * slow[(i-1)*(_M) + j];
                                        source_indices_h[count]=(i_m)*(_M+1)+j+1;
                                        count++;
                                }
                        }
                        //case 2
                        //case 2.1
                        if(j>0) {
                                weights_h[count]=(slow[i_m*(_M+1) + j_m]+slow[i_p*(_M) +j_m])/2.0;
                                source_indices_h[count]=(i_p)*(_M+1)+j_m;
                                count++;
                        }
                        //case 2.2
                        if(j<_M) {
                                weights_h[count]=(slow[i_m*(_M+1) + j_p]+slow[i_p*(_M) + j_p])/2.0;
                                source_indices_h[count]=(i)*(_M+1)+j+1;
                                count++;
                        }
                        //case 3
                        if(i<_N) {
                                //case 3.1
                                if(j>0) {
                                        weights_h[count]= ROOT_TWO * slow[i*(_M) + j-1];
                                        source_indices_h[count]=(i+1)*(_M+1)+j-1;
                                        count++;
                                }
                                //case 3.2
                                weights_h[count]=(slow[i_p*(_M+1) + j_m]+slow[i_p*(_M) + j_p])/2.0;
                                source_indices_h[count]=(i+1)*(_M+1)+j;
                                count++;
                                //case 3.3
                                if(j<_M) {
                                        weights_h[count]= ROOT_TWO * slow[i*(_M) + j];
                                        source_indices_h[count]=(i+1)*(_M+1)+j+1;
                                        count++;
                                }
                        }
                }
        }
        destination_offsets_h[n]=count;
        //Converting Adjacency Matrix in input to required input for nvgraph.

        void * * vertex_dim; // nvgraph variables _h for host data.
        nvgraphStatus_t status;
        nvgraphHandle_t handle;
        nvgraphGraphDescr_t graph;
        nvgraphCSCTopology32I_t CSC_input;
        cudaDataType_t edge_dimT = CUDA_R_32F;
        cudaDataType_t * vertex_dimT;
	
	/*cout<<"n : "<<n<<endl;
	cout<<"nnz : "<<nnz<<endl;
	cout<<"Weights Source:"<<endl;
	for(int u=0;u<nnz;u++){
		cout<<u<<" "<<source_indices_h[u]<<" "<<weights_h[u]<<endl;
	}
	cout<<"Doff:"<<endl;
        for(int u=0;u<n+1;u++){
                cout<<destination_offsets_h[u]<<" ";
        }cout<<endl;*/

        // Init host data
        /* *weights_h, *destination_offsets_h, *source_indices_h, n, nnz, vertex_numsets , edge_numsets already defined */
        sssp_1_h = new float[n];
        vertex_dim = new void*[vertex_numsets];
        vertex_dimT=new cudaDataType_t[vertex_numsets];
        CSC_input= (nvgraphCSCTopology32I_t) new nvgraphCSCTopology32I_t;
        vertex_dim[0] = (void * ) sssp_1_h;
        vertex_dimT[0] = CUDA_R_32F;


        check(nvgraphCreate( &handle));
        check(nvgraphCreateGraphDescr(handle, &graph));
        CSC_input->nvertices = n;
        CSC_input->nedges = nnz;
        CSC_input->destination_offsets = destination_offsets_h;
        CSC_input->source_indices = source_indices_h;
        check(nvgraphSetGraphStructure(handle, graph, (void * ) CSC_input, NVGRAPH_CSC_32));
        check(nvgraphAllocateVertexData(handle, graph, vertex_numsets, vertex_dimT));
        check(nvgraphAllocateEdgeData(handle, graph, edge_numsets, &edge_dimT));
        check(nvgraphSetEdgeData(handle, graph, (void * ) weights_h, 0));
        int source_vert = 0;
        check(nvgraphSssp(handle, graph, 0, &source_vert, 0));
        check(nvgraphGetVertexData(handle, graph, (void * ) sssp_1_h, 0));

		//////////// To be used to print actual path...
	int parent[n];
	parent[0]=0;
	for(int i=0;i<n;i++){
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
	/*cout<<"i parent[i]"<<endl;
	for(int u=0;u<_M+1;u++){
		cout<<u<<" "<<parent[u]<<endl;
	}*/
	for(int i=1;i<_M+1;i++){
	int node=i;
	//printf("Path to vertex %d\n",i);
	while((node!=0)&&(node!=parent[node])){
		//cout<<node<<" <- "<<parent[node]<<endl;
		int box;
		if(node>parent[node]){
			box=node;
		}else{
			box=parent[node];
		}
		//actualSeed[box/_M][box%_M];
		int diff=node-parent[node];
		if(diff==1 || diff==-1 || diff==_M+1 || diff==-(_M+1)){
			actualSeed[i][ _M*(box/_M) + box%_M]+=1;
		}else{
			actualSeed[i][ _M*(box/_M) + box%_M]+=ROOT_TWO;
		}
		node=parent[node];
	}
	}
	//Use DP for finding the exact path.	
        
        delete weights_h;
        delete destination_offsets_h;
        delete source_indices_h;
        delete vertex_dim;
        delete vertex_dimT;
        delete CSC_input;
        check(nvgraphDestroyGraphDescr(handle, graph));
        check(nvgraphDestroy(handle));
}
int main(){
        float * inp;
        int n=ROW,m=COL;
        inp=new float[n*m];
        for(int i=0; i<n; i++) {
                for(int j=0; j<m; j++) {
                        //inp[i*m+j]=1;
                }
        }
	inp[0]=1;
	inp[1]=100;
	inp[2]=4;
	inp[3]=2;
	inp[4]=3;
	inp[5]=101;
	inp[6]=110;
	inp[7]=103;
	inp[8]=105;
	float** actualSeed;
	actualSeed=new float*[m+1];
	for(int i=0;i<m+1;i++){
		actualSeed[i]=new float[m*n];
	}
	for(int i=0;i<m+1;i++){
		for(int j=0;j<m*n;j++){
			actualSeed[i][j]=0;
		}
	}
        //float tpck[m+1];
        float* out;
	out=new float[(n+1)*(m+1)];
	time_finder(out,inp,n,m,actualSeed);
        /*for(int i=0; i<m+1; i++) {
                tpck[i]=i;
        }
        float sum=0;*/
        for(int i=0; i<m+1; i++) {
                cout<<out[i]<<" ";
                //sum=sum+(tpck[i]-out[i])*(tpck[i]-out[i]);
        }
	cout<<endl;
        //cout<<endl<<sum<<endl;
	//cout<<"-------------"<<endl;
	/*for(int i=0;i<m+1;i++){
                for(int j=0;j<m*n;j++){
                        cout<<actualSeed[i][j]<<" ";
                }cout<<endl;
        }cout<<endl;*/
        return 0;
}
