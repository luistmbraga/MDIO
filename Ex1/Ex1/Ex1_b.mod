/*********************************************
 * OPL 12.8.0.0 Model
 * Author: joaon
 * Creation Date: 06/12/2018 at 13:43:53
 *********************************************/

int n=...;
int vN[1..n][1..n]=...;
int vS[1..n][1..n]=...;
int vW[1..n][1..n]=...;
int vE[1..n][1..n]=...;
//int C[1..n][1..n]; 

dvar int+ xN[1..n][1..n];
dvar int+ xS[1..n][1..n];
dvar int+ xW[1..n][1..n];
dvar int+ xE[1..n][1..n];

minimize sum (i in 1..n, j in 1..n) (vN[i][j]*xN[i][j] + vS[i][j]*xS[i][j] + 
										vW[i][j]*xW[i][j] + vE[i][j]*xE[i][j]);

subject to {	
    Restricao1: xS[1][1] + xE[1][1] == n*n-1;
    
    Restricao2: forall(i in 2..n-1, j in 2..n-1) (xN[i][j]+xE[i][j]+xW[i][j]+xS[i][j])-(xN[i+1][j]+xS[i-1][j]+xW[i][j+1]+xE[i][j-1]) == -1;
    
	Restricao3: xS[1][n] + xW[1][n] - xE[1][n-1] - xN[2][n] == -1;
	Restricao4: xN[n][1] + xE[n][1] - xS[n-1][1] - xW[n][2] == -1;
	Restricao5: xN[n][n] + xW[n][n] - xS[n-1][n] - xE[n][n-1] == -1;
	
	Restricao6: forall(j in 2..n-1) xS[1][j]+xE[1][j]+xW[1][j]-xN[2][j]-xW[1][j+1]-xE[1][j-1] == -1;
	Restricao7: forall(j in 2..n-1) xN[n][j]+xE[n][j]+xW[n][j]-xS[n-1][j]-xW[n][j+1]-xE[n][j-1] == -1;
	Restricao8: forall(i in 2..n-1) xN[i][1]+xS[i][1]+xE[i][1]-xN[i+1][1]-xS[i-1][1]-xW[i][2] == -1;
	Restricao9: forall(i in 2..n-1) xN[i][n]+xS[i][n]+xW[i][n]-xN[i+1][n]-xS[i-1][n]-xE[i][n-1] == -1;
} 
