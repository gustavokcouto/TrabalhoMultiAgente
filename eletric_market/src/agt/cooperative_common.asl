/* Initial beliefs and rules */

price(_, 100).

/* Initial goals */

!register.

/* Plans */

+!register<- .df_register("consumidor_nacional").

+buy(Ag, Md, P, DeAg)[source(Ag)]: dem(Md, De) & month(M) & Md > M <- 
	-dem(Md, De);
	+dem(Md, DeAg+De);
	!buy_energy(Md).

+buy(Ag, Md, P, De)[source(Ag)] : month(M) & Md > M <- 
	+dem(Md, De);
	!buy_energy(Md).

+buy(Ag, Md, P, De)[source(Ag)] <- 
	-buy(Ag, Md, P, De).

+!buy_energy(M) : not .intend(buy_energy(_)) <-
	.wait(1000); // Give some time to receive offers
	.findall(offer(P, E, Ag), propose_nacional(Ag, M, E, P)[source(Ag)], L);
	.print("Month ", M, " local offers ", L);
	?dem(M, D);
	.print("Month ", M, " demand ", D);
	!buy_nacional(M, L).

+!buy_energy(M).

+!buy_nacional(M, []).

+!buy_nacional(M, L) <-
	.min(L, offer(P, Of, Ag)); // sort offers, the first is the best
	.delete(offer(P, Of, Ag), L, W);
	?dem(M, E);
	E > 0;
	!buy_ag(M, P, E, Of, Ag);
	!buy_nacional(M, W).

-!buy_nacional(M, L).

+!buy_ag(M, P, E, Of, Ag) : E > Of <-
	.my_name(Me);
	.print(Me, " tries to buy ",  Of, " from ", Ag, " month ", M);
	.send(Ag, tell, buy(Me, M, P, Of));
	.wait(50).

+!buy_ag(M, P, E, Of, Ag) <-
	.my_name(Me);
	.print(Me, " tries to buy ",  E, " from ", Ag, " month ", M);
	.send(Ag, tell, buy(Me, M, P, E));
	.wait(50).

+buy_success(M, P, X)[source(Ag)] <-
	.my_name(Me);
	?month(Md);
	.print(Me, " bought ", X, " for price ", P, " from ", Ag," for month ", M, " in month ", Md);
	?dem(M, E);
	-dem(M, E);
	+dem(M, E-X);
	!insert_total(M, X, X*P).

+!insert_total(M, Ep, Cp) : total_cost(M, E, C) <-
	-total_cost(M, E, C);
	+total_cost(M, E+Ep, C+Cp).

+!insert_total(M, Ep, Cp) <-
	+total_cost(M, Ep, Cp).

+cnp_report(Ag, Ac, M, E)[source(Ag)] : buy_report(Ac, M, Ec) & sell_report(Ag, M, Es)<-
	//.print(Ac, " bought ", E, " from ", Ag, " at month ", M);
	-sell_report(Ag, M, Es);
	+sell_report(Ag, M, Es+E);
	-buy_report(Ac, M, Ec);
	+buy_report(Ac, M, Ec+E).

+cnp_report(Ag, Ac, M, E)[source(Ag)] : buy_report(Ac, M, Ec) <-
	//.print(Ac, " bought ", E, " from ", Ag, " at month ", M);
	+sell_report(Ag, M, E);
	-buy_report(Ac, M, Ec);
	+buy_report(Ac, M, Ec+E).

+cnp_report(Ag, Ac, M, E)[source(Ag)] : sell_report(Ag, M, Es) <-
	//.print(Ac, " bought ", E, " from ", Ag, " at month ", M);
	-sell_report(Ag, M, Es);
	+sell_report(Ag, M, Es+E);
	+buy_report(Ac, M, E).

+cnp_report(Ag, Ac, M, E)[source(Ag)] <-
	//.print(Ac, " bought ", E, " from ", Ag, " at month ", M);
	+sell_report(Ag, M, E);
	+buy_report(Ac, M, E).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, P, D)[source(Ag)] & buy_report(Ag, M, E) & D + E < X <-
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and ", D, " from national market at month ", M);
	.print(Ag, ", you have to  pay ", (X - D - E) * PLD, " at month ", M);
	.send(Ag, tell, pay_order(M, (X - D - E) * PLD));
	!send_consumer_bill(Ag, M, D).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, P, D)[source(Ag)] & buy_report(Ag, M, E) & D + E > X <- 
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and ", D, " from national market at month ", M);
    .print(Ag, ", you will receive ", (D + E - X) * PLD, " at month ", M);
	.send(Ag, tell, receive(M, (D + E - X) * PLD));
	!send_consumer_bill(Ag, M, D).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, P, D)[source(Ag)] & buy_report(Ag, M, E) & D + E == X <- 
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and ", D, " from national market at month ", M);
	!send_consumer_bill(Ag, M, D).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy_report(Ag, M, E) & E < X <-
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market at month ", M);
	.print(Ag, ", you have to  pay ", (X - E) * PLD, " at month ", M);
	.send(Ag, tell, pay_order(M, (X - E) * PLD)).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy_report(Ag, M, E) & E > X <- 
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and at month ", M);
    .print(Ag, ", you will receive ", (E - X) * PLD, " at month ", M);
	.send(Ag, tell, receive(M, (E - X) * PLD)).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy_report(Ag, M, E) & E == X <- 
	.send(Ag,tell, receive(M, 0));
    .print(Ag, ", you consumed ", X, " bought ", E, " from local market and at month ", M).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, P, D)[source(Ag)] & D<X <-
    .print(Ag, ", you consumed ", X, " bought ", D, " from national market at month ", M);
    .print(Ag, ", you have to  pay ", (X - D) * PLD, " at month ", M);
	.send(Ag, tell, pay_order(M, (X - D) * PLD));
	!send_consumer_bill(Ag, M, D).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, P, D)[source(Ag)] & D>X <- 
    .print(Ag, ", you consumed ", X, " bought ", D, " from national market at month ", M);
    .print(Ag, ", you will receive ", (D - X) * PLD, " at month ", M);
	.send(Ag, tell, receive(M, (D - X) * PLD));
	!send_consumer_bill(Ag, M, D).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) & buy(Ag, M, P, D)[source(Ag)] & D==X <- 
    .print(Ag, ", you consumed ", X, " bought ", D, " from national market at month ", M);
	.send(Ag, tell, pay_order(M, 0));
	!send_consumer_bill(Ag, M, D).

+consumi(Ag, M, X)[source(Ag)]: month(M) & pld(PLD) <-
    .print(Ag, ", you consumed ", X);
    .print(Ag, ", you have to  pay ", X * PLD, " at month ", M);
	.send(Ag,tell,pay_order(M, X * PLD)).

+produzi(Ag, M, Ep)[source(Ag)]: month(M) & sell_report(Ag, M, Es) & Ep \== Es <-
	.print(Ag, ", you generated ", Ep, " and sold ", Es, " at month ", M);
	.send(Ag, tell, receive(M, (Ep - Es) * PLD)).

+produzi(Ag, M, Ep)[source(Ag)]: month(M) & sell_report(Ag, M, Es) <-
	.print(Ag, ", you generated ", Ep, " and sold ", Es, " at month ", M).

+produzi(Ag, M, Ep)[source(Ag)]: month(M) <-
	.print(Ag, ", you generated ", Ep, " at month ", M);
	.send(Ag, tell, receive(M, Ep * PLD)).

+!send_consumer_bill(Ag, M, D) <-
	?total_cost(M, En, Cn);
	Pn = math.floor(Cn/En);
	.send(Ag, tell, buy_success(M, Pn, D)).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
