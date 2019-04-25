/*********************************************
 * OPL 12.8.0.0 Model
 * Author: joaon
 * Creation Date: 03/12/2018 at 16:51:51
 *********************************************/

int n=...;
int vN[1..n][1..n]=...;
int vS[1..n][1..n]=...;
int vW[1..n][1..n]=...;
int vE[1..n][1..n]=...;
//int C[1..n][1..n];

dvar float+ M[1..n][1..n]; 

dvar boolean x[1..n][1..n]; 

int Delta = 8; 
int b = 8; 

maximize sum (i in 1..n, j in 1..n) M[i][j]; 

subject to{ 
	sum (i in 1..n, j in 1..n) x[i][j] <= b;
	forall (i in 2..n, j in 1..n) M[i-1][j] - M[i][j] <= vN[i][j] + Delta*x[i][j];
    forall (i in 1..n-1, j in 1..n) M[i+1][j] - M[i][j] <= vS[i][j] + Delta*x[i][j];
    forall (i in 1..n, j in 2..n) M[i][j-1] - M[i][j] <= vW[i][j] + Delta*x[i][j];
    forall (i in 1..n, j in 1..n-1) M[i][j+1] - M[i][j] <= vE[i][j] + Delta*x[i][j];
    M[1][1] == 0; 
}