/* Initial beliefs and rules */

/* Initial goals */

!register.

/* Plans */

+!register<- .df_register("consumidor_nacional").

//+month(M): dem(M, De) <-
    //.print("Demanda ", DeAg+De, " do mes ", M).

+buy(Ag, Md, DeAg)[source(Ag)]: dem(Md, De) & month(M) & Md > M <- 
	-+dem(Md, DeAg+De);
	!buy_energy(Md).

+buy(Ag, Md, De)[source(Ag)] : month(M) & Md > M <- 
	+dem(Md, De);
	!buy_energy(Md).

+buy(Ag, Md, De)[source(Ag)] <- 
	-buy(Ag, Md, De).

+!buy_energy(M) <-
	.wait(50); // Give some time to receive offers
	.findall(offer(P, E, Ag), propose_nacional(Ag, M, E, P)[source(Ag)], L);
	.print("Month ", M, " local offers ", L);
	?dem(M, D);
	.print("Month ", M, " demand ", D);
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
	.wait(50).

+!buy_ag(M, E, Of, Ag) <-
	.my_name(Me);
	.print(Me, " tries to buy ",  E, " from ", Ag, " month ", M);
	.send(Ag, tell, buy(Me, M, E));
	.wait(50).

+buy_success(M, X)[source(Ag)] <-
	.my_name(Me);
	.print(Me, " bought ", X, " from ", Ag, " for month ", M);
	?dem(M, E);
	-+dem(M, E-X).

+local_sold(Ag, Ac, M, E)[source(Ag)] : bought_local(Ac, M, Ec)<-
	.print(Ac, " bought ", E, " from ", Ag, " at month ", M);
	-bought_local(Ac, M, Ec);
	+bought_local(Ac, M, Ec+E).

+local_sold(Ag, Ac, M, E)[source(Ag)] <-
	.print(Ac, " bought ", E, " from ", Ag, " at month ", M);
	+bought_local(Ac, M, E).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & bought_local(Ag, M, E) & D + E < X <-
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and ", D, " from national market at month ", M);
	.print(Ag, ", you have to  pay ", (X - D - E) * PLD, " at month ", M);
	.send(Ag, tell, pay_order(M, (X - D - E) * PLD)).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & bought_local(Ag, M, E) & D + E > X <- 
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and ", D, " from national market at month ", M);
    .print(Ag, ", you will receive ", (D + E - X) * PLD, " at month ", M);
	.send(Ag, tell, receive(M, (D + E - X) * PLD)).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & bought_local(Ag, M, E) & D + E == X <- 
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and ", D, " from national market at month ", M).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & bought_local(Ag, M, E) & E < X <-
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market at month ", M);
	.print(Ag, ", you have to  pay ", (X - E) * PLD, " at month ", M);
	.send(Ag, tell, pay_order(M, (X - E) * PLD)).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & bought_local(Ag, M, E) & E > X <- 
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and at month ", M);
    .print(Ag, ", you will receive ", (E - X) * PLD, " at month ", M);
	.send(Ag, tell, receive(M, (E - X) * PLD)).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & bought_local(Ag, M, E) & E == X <- 
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and at month ", M).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & D<X <-
    .print(Ag, ", you consumed ", X, " bought ", D, " from national market at month ", M);
    .print(Ag, ", you have to  pay ", (X - D) * PLD, " at month ", M);
	.send(Ag, tell, pay_order(M, (X - D) * PLD)).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & D>X <- 
    .print(Ag, ", you consumed ", X, " bought ", D, " from national market at month ", M);
    .print(Ag, ", you will receive ", (D - X) * PLD, " at month ", M);
	.send(Ag, tell, receive(M, (D - X) * PLD)).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, D)[source(Ag)] & D==X <- 
    .print(Ag, ", you consumed ", X, " bought ", D, " from national market at month ", M).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) <-
    .print(Ag, ", you consumed ", X);
    .print(Ag, ", you have to  pay ", X * PLD, " at month ", M);
	.send(Ag,tell,pay_order(M, X * PLD)).

+produzi(Ag, M, X)[source(Ag)]: month(M) <-
	.print(Ag, ", you generated ", X, " at month ", M).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
