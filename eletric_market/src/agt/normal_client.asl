// Agent normal_client in project electric_market

/* Initial beliefs and rules */

cons_reg([30+math.floor(math.random(5)),32+math.floor(math.random(10)),33+math.floor(math.random(5))]).
wallet(1000).

/* Initial goals */

!start.

/* Plans */

+!start : true <- .print("hello world.");
 !next_month.
 
 +!next_month: cons_reg(L) <-!estimate(L,0,0). 
 
 +real_Cons<- !see_cons.
 

+!estimate(L,A,N): .member(X,L)  <- .delete(0,L,W);  .wait(X);
	//.print("estou aqui ", L);
	B=A+ X;
	C=N+1;
	!estimate(W,B,C).

+!estimate([],A,N)<- .print("I estimate", math.floor(A/N));
	.send(celesc,tell,estimative(math.floor(A/N))).
	
+!see_cons: cons_reg(L) <-X= math.floor(math.random(10))+30;
	.wait(X);
	.union([X],L,W);
	.print(W);
	-+cons_reg(W);
	.print(X);
	.send(celesc,tell,consumi(X)).
	
+pay(X)[source(A)]:wallet(Y)<- 
//.print("I will pay ", X, " to electric market");
	-+wallet(Y-X);
	.print("I have ", Y-X);
	-pay(_)[source(A)];
 	!next_month.

+recieve(X):wallet(Y)<- 
//.print("I recieve ", X, " from electric market");
	-+wallet(X+Y);
	.print("I have ", X+Y);
	-recieve(_)[source(A)];
	!next_month.

 
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
