package electric_market;

import jason.asSyntax.Atom;
import cartago.*;

public class MonthCounter extends Artifact {
    final static long TICK_TIME = 10000;
    void init(){
        defineObsProperty("month",0);
        execInternalOp("count");
    }
    @INTERNAL_OPERATION void count(){
        while(true){
            ObsProperty prop  = getObsProperty("month");
            prop.updateValue(prop.intValue()+1);
            await_time(TICK_TIME);
        }
    }
}