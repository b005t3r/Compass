/**
 * User: booster
 * Date: 16/05/14
 * Time: 14:27
 */
package compass.navigation.mesh {
import compass.navigation.INavigationAgent;
import compass.navigation.INavigationMap;
import compass.navigation.INavigationNode;

import medkit.collection.ArrayList;
import medkit.collection.Collection;
import medkit.collection.List;
import medkit.geom.shapes.Point2D;

public class MeshNavigationNode implements INavigationNode {
    protected var _index:int;
    protected var _map:MeshNavigationMap;

    protected var _location:Point2D;                // point this node corresponds to
    protected var _polygons:List = new ArrayList(); // polygons connected with the point above
    protected var _nodes:List = new ArrayList();

    public function MeshNavigationNode() {
    }

    public function get uniqueID():int { return _index; }

    public function get navigationMap():INavigationMap { return _map; }

    public function get connectedNodes():Collection { return _nodes; }

    public function getTravelCost(fromNode:INavigationNode, agent:INavigationAgent):Number {
        return 0;
    }
}
}
