/**
 * User: booster
 * Date: 12/05/14
 * Time: 9:20
 */
package compass.navigation.grid {
import compass.navigation.IFinishNavigationNode;
import compass.navigation.INavigationAgent;
import compass.navigation.INavigationMap;
import compass.navigation.INavigationNode;

import medkit.collection.ArrayList;
import medkit.collection.Collection;
import medkit.collection.List;

public class GridNavigationMap implements INavigationMap {
    public static function manhattanTravelCost(startNode:GridNavigationNode, destinationNode:GridNavigationNode, agent:GridNavigationAgent, commonCost:Number = 1.0, commonDiagonalCost:Number = 1.0):Number {
        return Math.abs(startNode.x - destinationNode.x) * commonCost + Math.abs(startNode.y + destinationNode.y) * commonCost;
    }

    public static function euclidianTravelCost(node:GridNavigationNode, destinationNode:GridNavigationNode, agent:GridNavigationAgent, commonCost:Number = 1.0, commonDiagonalCost:Number = 1.0):Number {
        var dx:Number = node.x - destinationNode.x;
        var dy:Number = node.y - destinationNode.y;

        return Math.sqrt(dx * dx + dy * dy) * commonCost;
    }

    public static function diagonalTravelCost(node:GridNavigationNode, destinationNode:GridNavigationNode, agent:GridNavigationAgent, commonCost:Number = 1.0, commonDiagonalCost:Number = 1.0):Number {
        var dx:Number = Math.abs(node.x - destinationNode.x);
        var dy:Number = Math.abs(node.y - destinationNode.y);

        var diagonal:Number = dx < dy ? dx : dy;
        var straight:Number = dx + dy;

        return commonDiagonalCost * diagonal + commonCost * (straight - 2 * diagonal);
    }

    protected var _width:int;
    protected var _height:int;
    protected var _nodes:List;
    protected var _costFunction:Function = euclidianTravelCost;

    public function GridNavigationMap(builder:IGridNavigationMapBuilder) {
        _width  = builder.getWidth(this);
        _height = builder.getHeight(this);

        _nodes = new ArrayList(_width * _height);

        var x:int, y:int, node:GridNavigationNode;

        for(y = 0; y < _height; ++y) {
            for(x = 0; x < _width; ++x) {
                node = new GridNavigationNode(x, y, this, builder.getTravelCost(x, y, this));
                _nodes.add(node); // add new nodes row by row
            }
        }

        for(y = 0; y < _height; ++y) {
            for(x = 0; x < _width; ++x) {
                node = _nodes.get(x + y * _width);
                builder.populateConnectedNodes(x, y, this, node.connectedNodes);
            }
        }
    }

    public function get width():int { return _width; }
    public function get height():int { return _height; }

    public function get costFunction():Function { return _costFunction; }
    public function set costFunction(value:Function):void { _costFunction = value; }

    public function get nodes():Collection { return _nodes; }

    public function getNodeAt(x:int, y:int):GridNavigationNode {
        if(x < 0 || y < 0 || x >= _width || y >= _height)
            throw new ArgumentError("x/y has to be greater or equal to 0 and less tha width/height");

        return _nodes.get(x + y * _width);
    }

    public function isConnectedToFinishNode(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Boolean {
        var gridFinishNode:GridFinishNavigationNode = finishNode as GridFinishNavigationNode;

        if(gridFinishNode == null) throw new ArgumentError("'finishNode' has to be a GridFinishNavigationNode");

        return finishNode.connectedNodes.contains(node);
    }

    public function estimatedCostToFinish(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Number {
        return _costFunction(node, finishNode, agent);
    }
}
}
