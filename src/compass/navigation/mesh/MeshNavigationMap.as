/**
 * User: booster
 * Date: 16/05/14
 * Time: 15:58
 */
package compass.navigation.mesh {
import compass.navigation.IFinishNavigationNode;
import compass.navigation.INavigationAgent;
import compass.navigation.INavigationMap;
import compass.navigation.INavigationNode;

import medkit.collection.ArrayList;

import medkit.collection.Collection;
import medkit.collection.List;
import medkit.collection.iterator.Iterator;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Polygon2D;

public class MeshNavigationMap implements INavigationMap {
    public static function euclidianTravelCost(startNode:MeshNavigationNode, destinationNode:MeshNavigationNode, agent:MeshNavigationAgent, commonCost:Number = 1.0):Number {
        return startNode.location.distance(destinationNode.location) * commonCost;
    }

    protected var _nodes:List = new ArrayList();
    protected var _epsilon:Number;

    protected var _costFunction:Function = euclidianTravelCost;

    public function MeshNavigationMap(builder:IMeshNavigatoinMapBuilder) {
        _epsilon = builder.epsilon;

        var i:int = 0, it:Iterator = builder.locations.iterator();
        while(it.hasNext()) {
            var location:Point2D = it.next();
            var newNode:MeshNavigationNode = new MeshNavigationNode(location.x, location.y, this, i++);

            _nodes.add(newNode);
        }

        var count:int = _nodes.size();
        for(var j:int = 0; j < count; ++j) {
            var node:MeshNavigationNode = _nodes.get(j);

            builder.populateConnected(node.location, this, node.connectedNodes, node.connectedPolygons);
        }
    }

    public function get nodes():Collection { return _nodes; }

    // TODO: spatial optimization for MeshNavigationNodes
    public function isConnectedToFinishNode(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Boolean {
        var meshNode:MeshNavigationNode = node as MeshNavigationNode;
        var meshFinishNode:MeshNavigationNode = finishNode as MeshNavigationNode;

        var it:Iterator = meshNode.connectedPolygons.iterator();
        while(it.hasNext()) {
            var poly:Polygon2D = it.next();

            if(poly.containsPoint2D(meshFinishNode.location))
                return true;
        }

        return false;
    }

    public function estimatedCostToFinish(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Number {
        return _costFunction(node, finishNode, agent);
    }

    public function get costFunction():Function { return _costFunction; }
    public function set costFunction(value:Function):void { _costFunction = value; }

    // TODO: spatial optimization for MeshNavigationNodes
    public function getNodeAt(x:Number, y:Number):MeshNavigationNode {
        var count:int = _nodes.size();
        for(var i:int = 0; i < count; ++i) {
            var node:MeshNavigationNode = _nodes.get(i);

            var dy:Number   = node.location.y - y;
            var dx:Number   = node.location.x - x;
            var dist:Number = Math.sqrt(dx * dx + dy * dy);

            if(dist <= _epsilon)
                return node;
        }

        return null;
    }
}
}
