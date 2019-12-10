// Agent solar local in project electric_market

/* Initial beliefs and rules */

disp(_, 50).
price(_, 30).
produzi(_, 40).
type("Solar").
cooperative(celesc).

+month(M) : M == 0 <-
    .wait(200); //wait for clients to register in cnp
    !process_month(M).

+month(M) <-
    ?cooperative(C);
    .my_name(Me);
    ?produzi(M, X);
    .send(C, tell, produzi(Me, M, X));
    !process_month(M).

+!process_month(M) : M < 12 <-
    .print("Process month ", M);
    .df_search("consumidor_nacional", L);
    .print("send offer for energy to ", L);
    ?disp(M+1, E);
    ?price(M+1, P);
    .my_name(Me);
    .send(L, tell, propose_nacional(Me, M+1, E, P)).

+!process_month(M).
{ include("ger_local_common.asl") }