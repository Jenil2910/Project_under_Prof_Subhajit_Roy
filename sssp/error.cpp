#include<bits/stdc++.h>
#define _N 2
#define _M 1
using namespace std;

int main(){
    float** pred=new float*[_N];
    float** act=new float*[_N];
    for(int i=0;i<_N;i++){
        pred[i]=new float[_M];
        act[i]=new float[_M];
    }
    double error=0;
    for(int i=0;i<_N;i++){
        for(int j=0;j<_M;j++){
            cin>>pred[i][j];
        }
    }
    
    for(int i=0;i<_N;i++){
        for(int j=0;j<_M;j++){
            cin>>act[i][j];
        }
    }
    for(int i=0;i<_N;i++){
        for(int j=0;j<_M;j++){
            error+=(pred[i][j]-act[i][j])*(pred[i][j]-act[i][j]);
        }
    }
    cout<<error;
    return 0;
}
