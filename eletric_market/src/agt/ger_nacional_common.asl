/* Initial beliefs and rules */

/* Initial goals */

!register.

/* Plans */

+!register<- .df_register("gerador_nacional").

+buy(Ag, M, De)[source(Ag)] : available(M, E) & E > De <-
    -+available(M, E - De);
    !sold(Ag, M, De).

+buy(Ag, M, De)[source(Ag)] : available(M, E) <-
    E > 0;
    -+available(M, 0);
    !sold(Ag, M, E).

+buy(Ag, M, De)[source(Ag)] : disp(M, E) & E > De <-
    +available(M, E - De);
    !sold(Ag, M, De).

+buy(Ag, M, De)[source(Ag)] : disp(M, E)<-
    E > 0;
    +available(M, 0);
    !sold(Ag, M, E).
    

+!sold(Ag, M, E) <-
    .my_name(Me);
    .print(Me, " sold ", E, " to agent ", Ag, " in month ", M);
    .send(Ag, tell, buy_success(M, E));
    ?cooperative(C);
    .send(C, tell, local_sold(Ag, M, E)).

-buy(_, M, _)[source(Ag)] <-
    .send(Ag, tell, buy_failed(M)).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
