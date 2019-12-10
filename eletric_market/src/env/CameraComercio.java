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
            await_time(TICK_TIME);
            ObsProperty prop  = getObsProperty("month");

            if (prop.intValue() < 12) {
                prop.updateValue(prop.intValue()+1);
               
            } else {
                signal("end_of_year");
            }
            
            prop  = getObsProperty("pld");
            prop.updateValue(50 + Math.floor(50 * Math.random()));
        }
    }
}