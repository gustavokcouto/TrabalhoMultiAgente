// Agent normal_client in project electric_market

/* Initial beliefs and rules */

cons_reg([30+math.floor(math.random(5)),32+math.floor(math.random(10)),33+math.floor(math.random(5))]).

wallet(10000).
revenue(2000).
cooperative(celesc).

+month(M): cons_reg(L) <-
	!see_cons(M);
	!estimate(M+1,L,0,0);
	!update_wallet.

+!update_wallet: wallet(X) & revenue(Y) <- 
	-+wallet(X+Y).

+!estimate(M,[X|L],A,N) <-
	!estimate(M,L,A+X,N+1).

+!estimate(M,[],A,N) <-
	.my_name(Me);
	//.print(Me, " estimate ", math.floor(A/N), " for month ", M);
	.wait(100); // Let cooperative update the month and local prod send proposals
	+need_energy(M, math.floor(A/N));
	.print(Me, " need ", math.floor(A/N), " for month ", M);
	.findall(offer(P, E, Ag), propose_local(Ag, M, E, P)[source(Ag)], L);
	.print("local offers ", L);
	!buy_local(M, L);
	!buy_cooperativa(M).

+!buy_cooperativa(M) <-
	?cooperative(C);
	?need_energy(M, E);
	.my_name(Me);
	.print(Me, " bought ", E, " from cooperativa");
	.send(C, tell, buy(Me, M, E)).

+!buy_local(M, []).

+!buy_local(M, L) <-
    .min(L, offer(P, Of, Ag)); // sort offers, the first is the best
	.delete(offer(P, Of, Ag), L, W);
	?need_energy(M, E);
	E > 0;
	!buy_ag(M, E, Of, Ag);
	!buy_local(M, W).

-!buy_local(M, L).

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

+buy_success(M, X) <-
	.my_name(Me);
	.print(Me, " bought ", X, " from local for month ", M);
	?need_energy(M, E);
	-+need_energy(M, E-X).

+!see_cons(M): cons_reg(L) <-D=math.floor(math.random(10))+30;
	-+cons_reg([D|L]);
	.my_name(Me);
	?cooperative(C);
	.send(C,tell,consumi(Me, M, D)).
	
{ include("client_common.asl") }