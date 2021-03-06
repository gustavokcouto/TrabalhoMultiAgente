// Agent normal_client in project electric_market

/* Initial beliefs and rules */

wallet(10000).
revenue(2000).
cooperative(celesc).
general_bill([]).
pld_bill([]).

!register.


+!register <-
	!predict;	
	.df_register("consumidor_local").

+!predict <-
	V = math.random(5);
	+variance(V);
	D = [];
	!demand_calculation(D);
	?demand(DO);
	E = [];
	!estimative_calculation(E, DO, 0).

+!demand_calculation(D) : .length(D, L) & L > 12 <-
	+demand(D).

+!demand_calculation(D) <-
	.concat(D, [math.floor(30 + math.random(20))], DO);
	!demand_calculation(DO).

+!estimative_calculation(E, D, _) : .length(E, L) & L > 12 <-
	+estimative(E).

+!estimative_calculation(E, D, I) <-
	?variance(V);
	.nth(I, D, DI);
	ERR = V * (math.random(20) - 10);
	if (DI < ERR) {
	    .concat(E, [0], EO);
	} else {
	    .concat(E, [math.floor(DI +  ERR)], EO);
	};
	IO = I + 1;
	!estimative_calculation(EO, D, IO).


+month(M) <-
	!see_cons(M);
	!estimate(M+1, 0, 0);
	!update_wallet.

+!update_wallet: wallet(X) & revenue(Y) <- 
	-+wallet(X+Y).

+!estimate(M, A, N) : M <= 12 <-
	.my_name(Me);
	.wait(1000); // Let cooperative update the month and local prod send proposals
	?estimative(E);
	.nth(M-1, E, EM); 
	+need_energy(M, EM);
	.print(Me, " need ", EM, " for month ", M);
	.findall(offer(P, X, Ag), propose_local(Ag, M, X, P)[source(Ag)], L);
	.print("local offers ", L);
	!buy_local(M, L);
	!buy_cooperativa(M).

+!estimate(M, A, N).

+!buy_cooperativa(M) : need_energy(M, E) & E > 0 <-
	?cooperative(C);
	.my_name(Me);
	?pld(Pc);
	.send(C, tell, buy(Me, M, Pc, E)).

+!buy_cooperativa(M).

+!buy_local(M, []).

+!buy_local(M, L) <-
    .min(L, offer(P, Of, Ag)); // sort offers, the first is the best
	.delete(offer(P, Of, Ag), L, W);
	?need_energy(M, E);
	E > 0;
	!buy_ag(M, P, E, Of, Ag);
	!buy_local(M, W).

-!buy_local(M, L).

+!buy_ag(M, P, E, Of, Ag) : E > Of <-
	.my_name(Me);
	//.print(Me, " tries to buy ",  Of, " from ", Ag, " month ", M);
	.send(Ag, tell, buy(Me, M, P, Of));
	.wait(100).

+!buy_ag(M, P, E, Of, Ag) <-
	.my_name(Me);
	//.print(Me, " tries to buy ",  E, " from ", Ag, " month ", M);
	.send(Ag, tell, buy(Me, M, P, E));
	.wait(100).

+buy_success(M, P, X)[source(C)] : cooperative(C) <-
	?general_bill(B);
	.length(B, LB);
	
	if ( LB < M ) {
		.concat(B, [P * X], NB);
		-+general_bill(NB);
	} else {
		.reverse(B, RB);
		-+general_bill(RB);
		?general_bill([FRB | RRB]);
		.reverse(RRB, RRRB);
		.concat(RRRB, [FRB + P * M], NB);
		-+general_bill(NB);
	}
	.my_name(Me);
	?month(Md);
	.print(Me, " bought ", X, " for price ", P, " from ", C," for month ", M, " in month ", Md).

+buy_success(M, P, X)[source(Ag)] <-
	?general_bill(B);
	.length(B, LB);
	
	if ( LB < M ) {
		.concat(B, [P * X], NB);
		-+general_bill(NB);
	} else {
		.reverse(B, RB);
		-+general_bill(RB);
		?general_bill([FRB | RRB]);
		.reverse(RRB, RRRB);
		.concat(RRRB, [FRB + P * M], NB);
		-+general_bill(NB);
	}
	.my_name(Me);
	?month(Md);
	.print(Me, " bought ", X, " for price ", P, " from ", Ag," for month ", M, " in month ", Md);
	?need_energy(M, E);
	-+need_energy(M, E-X).


+!see_cons(M): M > 0 <-
	?demand(D);
	.nth(M-1, D, DM);
	.my_name(Me);
	?cooperative(C);
	.send(C,tell,consumi(Me, M, DM)).

+!see_cons(M).

+pay_order(M, P)[source(_)] : pld(PLD) & demand(D) <-
	?pld_bill(B);
	.concat(B, [-P], NB);

	.nth(M-1, D, DM);
	if ( PLD * DM == P ) {
		+buy_fail(M);
	};

	-+pld_bill(NB).

+receive(M, P)[source(_)] <-
	?pld_bill(B);
	.concat(B, [P], NB);
	-+pld_bill(NB).

+buy_fail(M) : month(Md) <-
	?general_bill(B);
	.concat(B, [0], NB);
	-+general_bill(NB).

+end_of_year : pld_bill(PB) & general_bill(GB) & variance(V) & demand(D) & estimative(E) & .my_name(Me) <-
	.print(Me, " my variance was: ", V);
	.print(Me, " my demand was: ", D);
	.print(Me, " my prediction was: ", E);
	.print(Me, " my PLD bill was: ", PB);
	.print(Me, " my general bill was: ", GB).

{ include("client_common.asl") }