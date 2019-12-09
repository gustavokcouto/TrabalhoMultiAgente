/* Initial goals */

!register.

/* Plans */

+!register<- .df_register("consumidor_local").

+pay_order(M, X) <-
    ?wallet(Y);
    .my_name(Me);
    //.print(Me, " will pay ", X, " to electric market");
	-+wallet(Y-X);
	//.print(Me, " has ", Y-X);
    -pay_order(M, X).

+receive(M, X) <-
    ?wallet(Y);
    .my_name(Me);
    //.print(Me, " received ", X, " to electric market");
	-+wallet(X+Y);
	//.print(Me, " has ", Y-X);
    -receive(M, X).
 
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
