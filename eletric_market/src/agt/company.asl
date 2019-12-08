// Agent company in project electric_market

/* Initial beliefs and rules */

all_proposals_received(CNPId)
  :- nb_participants(CNPId,NP) &                 // number of participants
     .count(propose(CNPId,_,_)[source(_)], NO) &   // number of proposes received
     .count(refuse(CNPId)[source(_)], NR) &      // number of refusals received
     NP = NO + NR.
     
     
pld(100).
dem(0).

/* Initial goals */

!start.
!register.
!startCNP(1).

/* Plans */

+!start : true <- .print("hello world.").

+estimative(D)[source(A)]:dem(L) <- 
	.print("hello friend.");
	De=L+D;
	-+dem(De).



+consumi(X)[source(A),source(B)]: .union([A],[B],W) & pld(PLD) & estimative(D)[source(W)] & D<X <- 
	.print(W, ", you have to  pay ", (X-D)*PLD);
	.send(W,tell,pay((X-D)*PLD));
	-estimative(_)[source(W)];
     -consumi(_)[source(W)]. 

+consumi(X)[source(A)]: pld(PLD) & estimative(D)[source(A)] & D<X <- 
	.print(A, ", you have to  pay ", (X-D)*PLD);
	.send(A,tell,pay((X-D)*PLD));
	-estimative(_)[source(A)];
     -consumi(_)[source(A)]. 

+consumi(X)[source(A)]: pld(PLD) & estimative(D)[source(A)] & D>X <- 
	.print(A, ", you will recieve ", (D-X)*PLD);
	.send(A,tell,recieve((D-X)*PLD));
	-estimative(_)[source(A)];
     -consumi(_)[source(A)].
     
+consumi(X)[source(A),source(B)]: .union([A],[B],W) & pld(PLD) & estimative(D)[source(W)] & D>X <- 
	.print(W, ",  you will recieve ", (X-D)*PLD);
	.send(W,tell,recieve((D-X)*PLD));
	-estimative(_)[source(W)];
     -consumi(_)[source(W)]. 

     
+propose(CNPId,Of,D)[source(A)]<- .print("i recieve ", CNPId," ", Of," ", D).


+!register<- .df_register(initiator).

     
+!startCNP(Id)<- .wait(5000);
	+cnp_state(Id,propose);   // remember the state of the CNP
      .df_search("participant",LP);
      .print("Sending CFP to ",LP);
      +nb_participants(Id,.length(LP));
	  +cfp(Id);
      .send(LP,tell,cfp(Id));
      .wait(all_proposals_received(Id), 3000, _);
      !contract(Id).





@lc1[atomic]
+!contract(CNPId)
   :  cnp_state(CNPId,propose) & dem(D)
   <- -cnp_state(CNPId,_);
   .print(CNPId);
      +cnp_state(CNPId,contract);
      .print("satanaz é voce?");
      .findall(offer(Of,Dem,A), propose(CNPId,Of,Dem)[source(A)], L);
      .print("Offers are ",L);
      L \== []; // constraint the plan execution to at least one offer
      .min(L,offer(Price,Demand,WAg)); // sort offers, the first is the best
	  ?cfp(Id);
	  +spent(CNPId,Price);
      //.print("Winner of proposal number ", CNPId, " for item ", Item,  " is " ,WAg, " with ", WOf);
      !announce_result(CNPId,L,WAg);
      -+cnp_state(CNPId,finished);
      .send(bob,tell,real_Cons).

// nothing todo, the current phase is not 'propose'
@lc2 +!contract(_).

-!contract(CNPId).
 //  <- .print("CNP ",CNPId," has failed!").

+!announce_result(_,[],_).
// announce to the winner
+!announce_result(CNPId,[offer(_,WAg)|T],WAg)
   <- .send(WAg,tell,accept_proposal(CNPId));
      !announce_result(CNPId,T,WAg).
// announce to others
+!announce_result(CNPId,[offer(_,LAg)|T],WAg)
   <- .send(LAg,tell,reject_proposal(CNPId));
      !announce_result(CNPId,T,WAg).
	  
     
     
     
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
