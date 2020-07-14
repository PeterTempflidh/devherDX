/**
 * Created by a.onatra on 29.03.20.
 */

public interface dh_IRuleEngine {

    Object executeRules( Map<String, Object> input );
    Object evaluateRules( Map<String, Object> input  );
    Object applyActions( Map<String, Object> input );
}