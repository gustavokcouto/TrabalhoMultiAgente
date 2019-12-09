/* Initial beliefs and rules */

/* Initial goals */

!register.

/* Plans */

+!register<- .df_register("consumidor_nacional").

//+month(M): dem(M, De) <-
    //.print("Demanda ", DeAg+De, " do mes ", M).

+buy(Ag, M, DeAg)[source(Ag)]:dem(M, De) & month(M) & Md > M <- 
	-+dem(Md, DeAg+De).

+buy(Ag, Md, De)[source(Ag)] : month(M) & Md > M <- 
	+dem(Md, De).

+buy(Ag, Md, De)[source(Ag)] <- 
	-buy(Ag, Md, De).

+dem(M, De) <-
	.findall(offer(P, E, Ag), propose_local(Ag, M, E, P)[source(Ag)], L);
	.print("local offers ", L);
	!buy_nacional(M, L).

+!buy_nacional(M, []).

+!buy_nacional(M, L) <-
	.min(L, offer(P, Of, Ag)); // sort offers, the first is the best
	.delete(offer(P, Of, Ag), L, W);
	?dem(M, E);
	E > 0;
	!buy_ag(M, E, Of, Ag);
	!buy_nacional(M, W).

-!buy_nacional(M, L).

+!buy_ag(M, E, Of, Ag) : E > Of <-
	.my_name(Me);
	.print(Me, " tries to buy ",  Of, " from ", Ag, " month ", M);
	.send(Ag, tell, buy(Me, M, Of));
	.wait(100).

+!buy_ag(M, E, Of, Ag) <-
	.my_name(Me);
	.print(Me, " tries to buy ",  E, " from ", Ag, " month ", M);
	.send(Ag, tell, buy(Me, M, E));
	.wait(100).

+buy_success(M, X)[source(Ag)] <-
	.my_name(Me);
	.print(Me, " bought ", X, " from ", Ag, " for month ", M);
	?dem(M, E);
	-+dem(M, E-X).

+consumi(Ag, M, X)[source(A)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & local_sold(Ag, M, E) & D + E < X <-
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and ", D, " from national market at month ", M);
	.print(Ag, ", you have to  pay ", (X - D - E) * PLD, " at month ", M);
	.send(Ag, tell, pay_order(M, (X-D)*PLD));
	-buy(Ag, M, D)[source(Ag)];
    -consumi(Ag, M, X)[source(Ag)]. 

+consumi(Ag, M, X)[source(A)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & local_sold(Ag, M, E) & D + E > X <- 
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and ", D, " from national market at month ", M);
    .print(Ag, ", you will receive ", (D + E - X) * PLD, " at month ", M);
	.send(Ag, tell, receive(M, (D + E - X) * PLD));
	-buy(Ag, M, D)[source(Ag)];
    -consumi(g, M, X)[source(Ag)]. 

+consumi(Ag, M, X)[source(A)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & D<X <-
    .print(Ag, ", you consumed ", X, " bought ", D, " from national market at month ", M);
    .print(Ag, ", you have to  pay ", (X - D) * PLD, " at month ", M);
	.send(Ag, tell, pay_order(M, (X-D)*PLD));
	-buy(Ag, M, D)[source(Ag)];
    -consumi(Ag, M, X)[source(Ag)]. 

+consumi(Ag, M, X)[source(A)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & D>X <- 
    .print(Ag, ", you consumed ", X, " bought ", D, " from national market at month ", M);
    .print(Ag, ", you will receive ", (D - X) * PLD, " at month ", M);
	.send(Ag, tell, receive(M, (D-X)*PLD));
	-buy(Ag, M, D)[source(Ag)];
    -consumi(g, M, X)[source(Ag)]. 

+consumi(Ag, M, X)[source(A)]: month(M) & pld(PLD) <-
    .print(Ag, ", you consumed ", X);
    .print(Ag, ", you have to  pay ", X * PLD, " at month ", M);
	.send(Ag,tell,pay_order(M, X * PLD));
	-buy(Ag, M, D)[source(Ag)];
    -consumi(Ag, M, X)[source(Ag)].

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
