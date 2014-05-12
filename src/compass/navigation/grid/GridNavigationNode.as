/**
 * User: booster
 * Date: 12/05/14
 * Time: 9:23
 */
package compass.navigation.grid {
import compass.navigation.INavigationAgent;
import compass.navigation.INavigationMap;
import compass.navigation.INavigationNode;

import medkit.collection.ArrayList;
import medkit.collection.Collection;
import medkit.collection.List;

public class GridNavigationNode implements INavigationNode {
    protected var _uniqueID:int;
    protected var _map:GridNavigationMap;
    protected var _nodes:List;
    protected var _travelCost:Number;

    protected var _x:int;
    protected var _y:int;

    public function GridNavigationNode(x:int, y:int, map:GridNavigationMap, travelCost:Number = NaN) {
        _x          = x;
        _y          = y;
        _uniqueID   = x + y * map.width;
        _map        = map;
        _travelCost = travelCost;
        _nodes      = new ArrayList();
    }

    public function get x():int { return _x; }
    public function get y():int { return _y; }

    public function get nodes():Collection { return _nodes; }

    public function get uniqueID():int { return _uniqueID; }
    public function get navigationMap():INavigationMap { return _map;}
    public function get connectedNodes():Collection { return _nodes; }
    public function getTravelCost(fromNode:INavigationNode, agent:INavigationAgent):Number { return _travelCost; }
}
}
