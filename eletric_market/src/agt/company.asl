// Agent company in project electric_market

/* Initial beliefs and rules */

all_proposals_received(CNPId)
  :- nb_participants(CNPId,NP) &                 // number of participants
     .count(propose(CNPId,_,_)[source(_)], NO) &   // number of proposes received
     .count(refuse(CNPId)[source(_)], NR) &      // number of refusals received
     NP = NO + NR.
     
     
pld(30).
dem(0).
contract_cost(0).
kwh_cosot(0).

/* Initial goals */

!start.
!register.
//!startCNP(1).

/* Plans */

+!start : true <- .print("hello world.").

+estimative(D,A)[source(A)]:dem(L) <- 
	//.print("hello friend.");
	De=L+D;
	-+dem(De).



+consumi(X,A)[source(A)]: pld(PLD) & estimative(D,A)[source(A)] & D<X & kwh_cost(C) <- 
	Y = D*C;
	Z = (X-D)*PLD; 
	.print(A, ", you have to  pay ", Y+Z);
	.send(A,tell,pay(Y+Z));
	-estimative(_,_)[source(A)];
     -consumi(_,_)[source(A)];
     -+dem(0). 

+consumi(X,A)[source(A)]: pld(PLD) & estimative(D,A)[source(A)] & D>X & kwh_cost(C) <- 
	Y = D*C;
	Z = (D-X)*PLD;
	if(Y<Z){
		.print(A, ", you will recieve ", Z-Y);
		.send(A,tell,recieve(Z-Y));
		//.print("agente consumiu menos que pediu, e ganhou dinheiro");
	}
	else{
		.print(A, ", you have to  pay ", Y-Z);
		.send(A,tell,pay(Y-Z));
		//.print("agente consumiu menos que pediu, entretanto ainda teve que pagar");
	}
	-estimative(_,_)[source(A)];
     -consumi(_,_)[source(A)];
      -+dem(0).


+!register<- .df_register(initiator).

+month(X)<- .wait(1000); .findall(Ag, cust(Ag), L);
//.print(L);
.send(L,achieve,next_month);
!startCNP(X+1);.

     
+!startCNP(Id)<- .wait(3000);
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
      //.print("satanaz é voce?");
      .findall(offer(Of,Dem,A), propose(CNPId,Of,Dem)[source(A)], L);
      .print("Offers are ",L);
      L \== []; // constraint the plan execution to at least one offer
      .min(L,offer(Price,Demand,WAg)); // sort offers, the first is the best
	  ?cfp(Id);
	  +spent(CNPId,Price);
      //.print("Winner of proposal number ", CNPId, " for item ", Demand,  " is " ,WAg);
      !announce_result(CNPId,L,WAg,D);
      -+cnp_state(CNPId,finished);
      ?contract_cost(X);
      Y = X/D;
      -+kwh_cost(Y);
      .print("X:", X, "D:", D, "Y:", Y);
      .findall(Ag, estimative(_,Ag), Customers);
      //.print(Customers);
      .send(Customers,achieve,see_cons).

// nothing todo, the current phase is not 'propose'
@lc2 +!contract(_).

-!contract(CNPId).
 //  <- .print("CNP ",CNPId," has failed!").

+!announce_result(_,[],_).

// announce to the winner
//+!announce_result(CNPId,[offer(_,_,WAg)|T],WAg,D): .print("jesus armado") & 
//		propose(CNPId,Cost,Dem)[source(WAg)] &.print("caralho") & Dem<D
//   <- .print("voce ganhou 1", WAg);
//   .delete(offer(CNPID,Cost,Dem),T,L)
//   .send(WAg,tell,accept_proposal(CNPId,Dem));
//   .print(T);
//   .min(T,offer(P,Demand,WAg2));
//   ND = D-Dem;
//   .print(WAg2);
//   .print("D: ", D, " Dem: ", Dem , " ND: ", ND);
//      !announce_result(CNPId,T,WAg2,ND).
//      
//+!announce_result(CNPId,[offer(Price,Dem,WAg)|T],WAg,D):  propose(CNPId,Cost,Dem)[source(WAg)] &.print("porra") & Dem>D
//   <- .print("voce ganhou 2 ", WAg);
//   .send(WAg,tell,accept_proposal(CNPId,D));
//      !announce_result(CNPId,T,WAg).
      
      // announce to the winner
+!announce_result(CNPId,T,WAg,D): propose(CNPId,Cost,Dem)[source(WAg)] & Dem<D & contract_cost(X)
   <- .print("voce ganhou 1", WAg);
   .delete(offer(Price,Demand,WAg),T,L)
   .send(WAg,tell,accept_proposal(CNPId,Dem));
//   .print(L);
   .min(L,offer(P,Demand,WAg2));
   Y=X+Cost*Dem;
   -+contract_cost(Y);
   ND = D-Dem;
//   .print(WAg2);
   //.print("D: ", D, " Dem: ", Dem , " ND: ", ND);
      !announce_result(CNPId,L,WAg2,ND).
      
+!announce_result(CNPId,T,WAg,D):  propose(CNPId,Cost,Dem)[source(WAg)] & Dem>D & contract_cost(X)
   <- .print("voce ganhou 2 ", WAg);
   .send(WAg,tell,accept_proposal(CNPId,D));
   Y=X+Cost*D;
   -+contract_cost(Y);
   .delete(offer(Price,Demand,WAg),T,L);
      !announce_result(CNPId,L,WAg).
      
// announce to others
+!announce_result(CNPId,[offer(_,_,LAg)|T],WAg)
   <- .print("entrei aqui?");
   .send(LAg,tell,reject_proposal(CNPId));
      !announce_result(CNPId,T,WAg).
	  
     
     
     
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
