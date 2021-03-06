/* Initial beliefs and rules */

/* Initial goals */

!register.

/* Plans */

+!register<- .df_register("gerador_local").

+buy(Ag, M, P, De)[source(Ag)] : available(M, E) & E > De <-
    -+available(M, E - De);
    !sold(Ag, M, P, De).

+buy(Ag, M, P, De)[source(Ag)] : available(M, E) & E > 0 <-
    -+available(M, 0);
    !sold(Ag, M, P, E).

+buy(Ag, M, P, De)[source(Ag)] : available(M, E) <-
    !sell_fail(Ag, M).

+buy(Ag, M, P, De)[source(Ag)] : disp(M, E) & E > De <-
    +available(M, E - De);
    !sold(Ag, M, P, De).

+buy(Ag, M, P, De)[source(Ag)] : disp(M, E) & E > 0<-
    +available(M, 0);
    !sold(Ag, M, P, E).

+!sold(Ag, M, P, E) <-
    .my_name(Me);
    .print(Me, " sold ", E, " to agent ", Ag, " in month ", M);
    .send(Ag, tell, buy_success(M, P, E));
    ?cooperative(C);
    .send(C, tell, cnp_report(Me, Ag, M, E)).

+!sell_fail(Ag, M) <-
    .my_name(Me);
    .print(Me, " failed to sell energy to ", Ag, " for month ", M);
    .send(Ag, tell, buy_failed(M)).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
