/**
 * User: booster
 * Date: 12/05/14
 * Time: 9:36
 */
package compass.navigation.grid {
import compass.navigation.INavigationAgent;
import compass.navigation.INavigationMap;
import compass.navigation.INavigationNode;
import compass.navigation.IStartNavigationNode;

import medkit.collection.Collection;

public class GridStartNavigationNode extends GridNavigationNode implements IStartNavigationNode {
    protected var _gridNode:GridNavigationNode;

    public function GridStartNavigationNode(gridNode:GridNavigationNode, map:GridNavigationMap) {
        super(-1, -1, map);

        _gridNode = gridNode;
    }

    override public function get x():int { return _gridNode.x; }
    override public function get y():int { return _gridNode.y; }
    override public function get nodes():Collection { return _gridNode.nodes; }

    override public function get uniqueID():int { return _gridNode.uniqueID; }
    override public function get navigationMap():INavigationMap { return _gridNode.navigationMap; }
    override public function get connectedNodes():Collection { return _gridNode.connectedNodes; }
    override public function getTravelCost(fromNode:INavigationNode, agent:INavigationAgent):Number { return _gridNode.getTravelCost(fromNode, agent); }
}
}
