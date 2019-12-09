package electric_market;

import jason.asSyntax.Atom;
import cartago.*;

public class CameraComercio extends Artifact {
    final static long TICK_TIME = 5000;
    void init(){
        defineObsProperty("month", 0);
        defineObsProperty("pld", 50);
        execInternalOp("count");
    }
    @INTERNAL_OPERATION void count(){
        while(true){
            ObsProperty prop  = getObsProperty("month");
            prop.updateValue(prop.intValue()+1);
            prop  = getObsProperty("pld");
            prop.updateValue(50 + Math.floor(50 * Math.random()));
            await_time(TICK_TIME);
        }
    }
}