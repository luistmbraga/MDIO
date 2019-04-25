/*********************************************
 * OPL 12.8.0.0 Model
 * Author: joaon
 * Creation Date: 04/12/2018 at 16:24:34
 *********************************************/
int n=...; 	//dimensão da matriz, 7
int vN[1..n][1..n]=...; //valores dos tempos de propagação sentido Norte
int vS[1..n][1..n]=...; //valores dos tempos de propagação sentido Sul
int vW[1..n][1..n]=...; //valores dos tempos de propagação sentido Oeste
int vE[1..n][1..n]=...; //valores dos tempos de propagação sentido Este
int Delta = 8; //delay adicional à propagação quando existe equipa de bombeiros
int b = 8; //nº de recursos máximo
int time = 12; //tempo para simular o fogo
float probIgni[1..n][1..n]; // probabilidades de ignição na célula (i,j)

dvar boolean equipas[1..n][1..n]; //quantas equipas na célula (x,y)
dvar boolean ardido[1..n][1..n][1..n][1..n]; //células (x,y) ardidas quando houve ignição em (i,j)
dvar float+ Tempos[1..n][1..n][1..n][1..n]; //matriz de tempos de propagação runtime, para cada ignição na célula (i,j) guarda os tempos de propagação até (x,y)

execute{ //instanciar as probabilidades
	for(var i=1;i<=n;i++){
		for(var j=1;j<=n;j++){
			probIgni[i][j]=(14-i-j)/500;
 		}				
	}
}

/*
Os tempos de propagação são calculados desde a célula [i][j] onde começa o incêndio
Para termos uma estimativa do caso genérico, temos de fazer uma média dos tempos para todos os locais de incêndio possíveis, ponderados com
a probabilidade de ignição nessa célula  

zik <-> tik se <=12
zik = ardido? para a célula i se teve ignição na célula k

x,i vertical |; y,j horizontal --; linhas e colunas da matriz
*/
minimize sum(i in 1..n, j in 1..n) probIgni[i][j]*sum (x in 1..n, y in 1..n) ardido[i][j][x][y]; //minimizar área ardida

subject to{ 
	sum 	(i in 1..n, j in 1..n) equipas[i][j] == b; 		//total de equipas disponíveis não superior a b
	//estamos a tentar maximizar os tempos (abrandar o fogo), o fogo propaa pelos caminhos mais curtos. O rate of fire spread ROS não é dado, por isso assume-se 1.
	forall  (i in 1..n, j in 1..n, x in 2..n, y in 1..n) 	Tempos[i][j][x-1][y] <= Tempos[i][j][x][y] + vN[x][y] + Delta*equipas[x][y]; //tempo de propagação de (x,y) para a célula adjacente a Norte (x-1)
    forall  (i in 1..n, j in 1..n, x in 1..n-1, y in 1..n)	Tempos[i][j][x+1][y] <= Tempos[i][j][x][y] + vS[x][y] + Delta*equipas[x][y]; //tempo de propagação de (x,y) para a célula adjacente a Sul	(x+1)
    forall  (i in 1..n, j in 1..n, x in 1..n, y in 2..n) 	Tempos[i][j][x][y-1] <= Tempos[i][j][x][y] + vW[x][y] + Delta*equipas[x][y]; //tempo de propagação de (x,y) para a célula adjacente a Oeste	(y-1)
    forall  (i in 1..n, j in 1..n, x in 1..n, y in 1..n-1)	Tempos[i][j][x][y+1] <= Tempos[i][j][x][y] + vE[x][y] + Delta*equipas[x][y]; //tempo de propagação de (x,y) para a célula adjacente a Este	(y+1)
  
    //Tempos[s][s] = 0 para todos os pontos de ignição s
    forall  (i in 1..n, j in 1..n) 	Tempos[i][j][i][j] == 0; //local de ignição, força o valor 0. Quando estams a analisar com um dos 49 pontos de ignição (i,j), esse tempo deve ser 0 ERRO 
        
    //como estámos a minimizar ardido, o soler coloca Tempos=12 em todo o lado, para anular o time, e assim minimizar o ardido.
    forall  (i in 1..n, j in 1..n, x in 1..n, y in 1..n) 	ardido[i][j][x][y] 	>= (time-Tempos[i][j][x][y])/time; // se chegou lá antes dos 12 segundos, ardeu. Testa todo o mapa para cada ignição (i,j)possível
    
    
    

}
	//forall 	(i in 1..n, j in 1..n) totalArdido[i][j] == sum (x in 1..n, y in 1..n) ardido[x][y][i][j]; // total ardido quando a ignição acontece em (i,j) VÁLIDO
	//int totalArdido[1..n][1..n]; //quantas células arderam (somatório das ignições das células (x,y)) quando houve ignição em (i,j)
	
	//não deviam de ser necessárias
    //forall  (i in 1..n, j in 1..n, x in 1..n, y in 1..n) 	1-ardido[i][j][x][y] 	>= 0;
    //forall  (i in 1..n, j in 1..n, x in 1..n, y in 1..n) 	ardido[i][j][x][y] 	>= 0;
    //sum 	(x in 1..n, y in 1..n) equipas[x][y] <=b; 		//total de equipas disponíveis não superior a b
    
//Backups
/*
    forall  (x in 1..n, y in 1..n, i in 1..n, j in 1..n) 	Tempos[x][y][i][j] >= 0; //todos os tempos são não negativos VÁLIDO
    forall 	(i in 1..n, j in 1..n) sum 	(x in 1..n, y in 1..n) ardido[x][y][i][j] >= 1; 	//tem de haver ignição
	forall 	(x in 1..n, y in 1..n) equipas[x][y] <= 1; 		//apenas podemos ter uma equipa por célula desnecessário
	forall 	(x in 1..n, y in 1..n) 1 - equipas[x][y] >= 0; 		//apenas podemos ter uma equipa por célula, ou 1 ou 0, inútilpor ter sido declarado como int+
	
	forall	(i in 2..n, j in 1..n)	probIgni[i][j]*(vS[i][j] + Delta*equipas[i][j]) >= Tempos[i-1][j];
	forall	(i in 1..n-1, j in 1..n)	probIgni[i][j]*(vN[i][j] + Delta*equipas[i][j]) >= Tempos[i+1][j];
	forall	(i in 1..n, j in 2..n)	probIgni[i][j]*(vE[i][j] + Delta*equipas[i][j]) >= Tempos[i][j-1];
	forall	(i in 1..n, j in 1..n-1)	probIgni[i][j]*(vW[i][j] + Delta*equipas[i][j]) >= Tempos[i][j+1];

    forall  (i in 1..n, j in 1..n) 	Tempos[i][j][i][j] >= 0; // desnecessário, estamos a maximizar o Tempos
    forall  (x in 1..n, y in 1..n, i in 1..n, j in 1..n) 	ardido[x][y][i][j] 	<= 1; 
    total == sum (i in 1..n, j in 1..n) probIgni[i][j]; //a probabilidade global não precisa de ser 1, porque na realidade não é garantido que haja um incêndio no mapa
    maximize sum (i in 1..n, j in 1..n) Tempos[i][j]; //maximizando o tempo vamos passar pelos caminhos mais demorados, dando menos área ardida
    
 */  
/*
subject to{ 
	sum 	(i in 1..n, j in 1..n) equipas[i][j] <= b; 		//total de equipas disponíveis
	sum 	(i in 1..n, j in 1..n) ardido[i][j] >= 1; 		//tem de haver ignição
	forall 	(i in 1..n, j in 1..n) equipas[i][j] <= 1; 		//apenas podemos ter uma equipa por célula
	forall 	(i in 2..n, j in 1..n) 		Tempos[i-1][j] - Tempos[i][j] <= vN[i][j] + Delta*equipas[i][j]; //tempo de propagação para a célula adjacente a Norte
    forall	(i in 1..n-1, j in 1..n)	Tempos[i+1][j] - Tempos[i][j] <= vS[i][j] + Delta*equipas[i][j]; //tempo de propagação para a célula adjacente a Sul
    forall 	(i in 1..n, j in 2..n) 		Tempos[i][j-1] - Tempos[i][j] <= vW[i][j] + Delta*equipas[i][j]; //tempo de propagação para a célula adjacente a Oeste
    forall 	(i in 1..n, j in 1..n-1)	Tempos[i][j+1] - Tempos[i][j] <= vE[i][j] + Delta*equipas[i][j]; //tempo de propagação para a célula adjacente a Este
    forall 	(i in 1..n, j in 1..n) 		ardido[i][j] == (Tempos[i][j]<=time); // se chegou lá até aos 12 segundos, ardeu
    //total == sum (i in 1..n, j in 1..n) probIgni[i][j]; //a probabilidade global não precisa de ser 1, porque na realidade não é garantido que haja um incêndio no mapa
}
*/