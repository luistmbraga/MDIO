/*********************************************
 * OPL 12.8.0.0 Model
 * Author: joaon
 * Creation Date: 30/11/2018 at 14:17:29
 *********************************************/

int n=...;
int vN[1..n][1..n]=...;
int vS[1..n][1..n]=...;
int vW[1..n][1..n]=...;
int vE[1..n][1..n]=...;
//int C[1..n][1..n];


dvar float+ M[1..n][1..n];

maximize sum (i in 1..n, j in 1..n) M[i][j];

subject to {
    Restricao1: forall (i in 2..n, j in 1..n) M[i-1][j] - M[i][j] <= vN[i][j];
    Restricao2: forall (i in 1..n-1, j in 1..n) M[i+1][j] - M[i][j] <= vS[i][j];
    Restricao3: forall (i in 1..n, j in 2..n) M[i][j-1] - M[i][j] <= vW[i][j];
    Restricao4: forall (i in 1..n, j in 1..n-1) M[i][j+1] - M[i][j] <= vE[i][j];
    Restricao5: M[1][1] == 0;
}
