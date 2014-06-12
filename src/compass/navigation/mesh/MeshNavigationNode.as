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
    protected var _polygons:List = new ArrayList(); // polygons connected at this node's location
    protected var _nodes:List = new ArrayList();    // nodes possible to travel to from this node

    public function MeshNavigationNode(x:Number, y:Number, map:MeshNavigationMap, index:int) {
        _location   = new Point2D(x, y);
        _map        = map;
        _index      = index;
    }

    public function get location():Point2D { return _location; }

    public function get uniqueID():int { return _index; }
    public function get navigationMap():INavigationMap { return _map; }
    public function get connectedNodes():Collection { return _nodes; }
    public function get connectedPolygons():Collection { return _polygons; }

    public function getTravelCost(fromNode:INavigationNode, agent:INavigationAgent):Number {
        var meshNode:MeshNavigationNode = fromNode as MeshNavigationNode;

        return meshNode._location.distance(_location);
    }
}
}
