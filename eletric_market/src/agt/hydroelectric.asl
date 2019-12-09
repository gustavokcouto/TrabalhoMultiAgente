// Agent hydroelectric in project electric_market

/* Initial beliefs and rules */

disp(_, 10).
price(_, 30).
type("Hydro").

+month(M) <-
    .print("Process month ", M);
    .df_search("consumidor_nacional", L);
    .print("send offer for energy to ", L);
    ?disp(M+1, E);
    ?price(M+1, P);
    .my_name(Me);
    .send(L, tell, propose_local(Me, M+1, E, P)).

{ include("ger_nacional_common.asl") }
