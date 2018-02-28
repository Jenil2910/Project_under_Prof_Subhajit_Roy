#include <bits/stdc++.h>
#define _N 100    //Number of rows
#define _M 100    //Number of columns
using namespace std;

int main() {
    float** slow = new float*[_N];
    for(int i = 0; i < _N; ++i){
        slow[i] = new float[_M];
    }
    //input matrix is taken
    for(int i=0;i<_N;i++){
        for(int j=0;j<_M;j++){
            cin>>slow[i][j];
        }
    }
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
                    weights[count]=slow[i-1][j-1];
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
                    weights[count]=slow[i-1][j];
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
                    weights[count]=slow[i][j-1];
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
                    weights[count]=slow[i][j];
                    source[count]=(i+1)*(_M+1)+j+1;
                    count++;
                }
            }
        }
    }
    cout<<destination_offset[1]<<'\n';
    destination_offset[nodes]=count;

    cout<<"This is destination_offset \t";
    for(int i=0;i<=nodes;i++){
        cout<<"index "<<i<<" "<<destination_offset[i]<<'\n';
    }
    cout<<"\n This is weights \t";
    for(int i=0;i<count;i++){
        cout<<weights[i]<<" ";
    }
    cout<<"\n This is source \t";
    for(int i=0;i<count;i++){
        cout<<source[i]<<" ";
    }
	return 0;
}
