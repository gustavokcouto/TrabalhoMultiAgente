package electric_market;

import jason.asSyntax.Atom;
import cartago.*;

public class CameraComercio extends Artifact {
    final static long TICK_TIME = 5000;
    void init(){
        defineObsProperty("month", 0);
        defineObsProperty("pld", Math.floor( 30 + 70 * Math.random()));
        execInternalOp("count");
    }
    @INTERNAL_OPERATION void count(){
        while(true){
            await_time(TICK_TIME);
            ObsProperty prop  = getObsProperty("month");

            if (prop.intValue() < 12) {
                prop.updateValue(prop.intValue()+1);
            } else if (prop.intValue() == 12) {
                signal("end_of_year");
                break;
            }
            
            prop  = getObsProperty("pld");
            prop.updateValue(Math.floor( 30 + 70 * Math.random()));
        }
    }
}