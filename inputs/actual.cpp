#include<stdio.h>
#include<iostream>
#include<bits/stdc++.h>

using namespace std;

int A[100][100];

int main(){
	srand(time(NULL));
	for(int i=0;i<100;i++){
		for(int j=0;j<100;j++){
			int r=(rand()%((int)sqrt(i*i+j*j+1)))+(sqrt(i*i+j*j));
			r=r+1;
			A[i][j] = r;
		}
	}
	for(int i=0;i<100;i++){
		for(int j=0;j<100;j++){
			cout<<A[i][j]<<" ";
		}cout<<endl;
	}
	return 0;
}
