#include<stdio.h>
#include<iostream>
#include<bits/stdc++.h>

using namespace std;

#define _N 100
#define _M 100

int A[_N+1][_M+1];

int main(){
	srand(time(NULL));
	for(int i=0;i<_N+1;i++){
		for(int j=0;j<_M+1;j++){
			int r=(rand()%((int)sqrt(i*i+j*j+1)))+(sqrt(i*i+j*j));
			r=r+1;
			A[i][j] = r;
		}
	}
	for(int i=0;i<_N+1;i++){
		for(int j=0;j<_M+1;j++){
			cout<<A[i][j]<<" ";
		}cout<<endl;
	}
	return 0;
}
