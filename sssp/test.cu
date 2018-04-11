#include <nvgraph.h>
#include <bits/stdc++.h>
#include "sssp_to_be_given.cu"
#include<cuda.h>
using namespace std;
#define ROW 3
#define COL 3
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
