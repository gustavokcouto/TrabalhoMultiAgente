// Agent solar local in project electric_market

/* Initial beliefs and rules */

disp(_, 20).
price(_, 30).
type("Solar").
cooperative(celesc).

+month(M) : M == 0 <-
    .wait(200); //wait for clients to register cnp
    !process_month(M).

+month(M) <-
    !process_month(M).

+!process_month(M) <-
    .print("Process month ", M);
    .df_search("consumidor_local", L);
    .print("send offer for energy to ", L);
    ?disp(M+1, E);
    ?price(M+1, P);
    .my_name(Me);
    .send(L, tell, propose_local(Me, M+1, E, P)).

{ include("ger_local_common.asl") }