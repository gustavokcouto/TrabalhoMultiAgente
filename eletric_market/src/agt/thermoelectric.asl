// Agent thermoelectric in project electric_market

/* Initial beliefs and rules */

disp(200).
price(100).
type("Thermo").

/* Initial goals */

!start.
!register.


/* Plans */

+!start : true <- .print("hello world.").

+!register <- .df_register("participant");
              .df_subscribe("initiator").


@c1 +cfp(CNPId)[source(A)]
   :provider(A,"initiator") & type(X) & disp(D) &
      price(C) 
   <- +proposal(CNPId,C,D); // lembra da proposta
   .print("amigo estou aqui");
      .send(A,tell,propose(CNPId,C,D)).
	  
+cfp(CNPId)[source(A)]
  :   provider(A,"initiator") 
   <- .send(A,tell,refuse(CNPId)).

@r1 +accept_proposal(CNPId,D)[source(A)]
   :  proposal(CNPId,C,D)
   <-  .send(A,tell,delivered(De)).
      // do the task and report to initiator
	  
@r3 +accept_proposal(CNPId,D)[source(A)]
   :  proposal(CNPId,C,_)
   <- //.print("cannot delivery ", CNPId); 
   .send(A,tell,delivered(D)).       // not do the task and report to initiator
   


@r2 +reject_proposal(CNPId)
   <-// .print("I lost CNP ",CNPId, ".");
      -proposal(CNPId,_,_). // clear memory


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
