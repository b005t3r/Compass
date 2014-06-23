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
import compass.navigation.IStartNavigationNode;

import medkit.collection.ArrayList;
import medkit.collection.Collection;
import medkit.collection.HashSet;
import medkit.collection.List;
import medkit.collection.Set;
import medkit.collection.iterator.Iterator;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Polygon2D;

public class MeshNavigationMap implements INavigationMap {
    public static function euclidianTravelCost(startNode:MeshNavigationNode, destinationNode:MeshNavigationNode, agent:MeshNavigationAgent, commonCost:Number = 1.0):Number {
        return startNode.location.distance(destinationNode.location) * commonCost;
    }

    protected var _epsilon:Number;

    protected var _nodes:List               = new ArrayList(); // TODO: change to spatial set
    protected var _polys:List               = new ArrayList(); // TODO: change to spatial set
    protected var _costFunction:Function    = euclidianTravelCost;

    public function MeshNavigationMap(builder:IMeshNavigatoinMapBuilder) {
        _epsilon = builder.epsilon;

        var i:int = 0, it:Iterator = builder.locations.iterator();
        while(it.hasNext()) {
            var location:Point2D = it.next();
            var newNode:MeshNavigationNode = new MeshNavigationNode(location.x, location.y, this, i++);

            _nodes.add(newNode);
        }

        var polySet:Set = new HashSet();

        var count:int = _nodes.size();
        for(var j:int = 0; j < count; ++j) {
            var node:MeshNavigationNode = _nodes.get(j);

            builder.populateConnected(node.location, this, node.connectedNodes, node.connectedPolygons);
            polySet.addAll(node.connectedPolygons);
        }

        _polys.addAll(polySet);
    }

    public function get nodes():Collection { return _nodes; }
    public function get polygons():Collection { return _polys; }

    // TODO: spatial optimization for MeshNavigationNodes
    public function isConnectedToFinishNode(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Boolean {
        var meshNode:MeshNavigationNode         = node as MeshNavigationNode;
        var meshFinishNode:MeshNavigationNode   = finishNode as MeshNavigationNode;

        if(meshNode is PolygonStartNavigationNode) {
            var polyIt:Iterator = meshFinishNode.connectedPolygons.iterator();
            while(polyIt.hasNext()) {
                var poly:Polygon2D = polyIt.next();

                if(poly.containsPoint2D(meshNode.location))
                    return true;
            }

            return false;
        }

        return meshFinishNode.connectedNodes.contains(meshNode);
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

    public function createStartNode(x:Number, y:Number):IStartNavigationNode {
        var node:MeshNavigationNode = getNodeAt(x, y);

        if(node != null)
            return new LocationStartNavigationNode(node, this);

        var count:int = _polys.size();
        for(var i:int = 0; i < count; ++i) {
            var poly:Polygon2D = _polys.get(i);

            if(poly.contains(x, y)) {
                var connectedNodes:List = connectedNodesForPolygon(poly);

                return new PolygonStartNavigationNode(x, y, this, poly, connectedNodes);
            }
        }

        return null;
    }

    public function createFinishNode(x:Number, y:Number):IFinishNavigationNode {
        var node:MeshNavigationNode = getNodeAt(x, y);

        if(node != null)
            return new LocationFinishNavigationNode(node, this);

        var count:int = _polys.size();
        for(var i:int = 0; i < count; ++i) {
            var poly:Polygon2D = _polys.get(i);

            if(poly.contains(x, y)) {
                var connectedNodes:List = connectedNodesForPolygon(poly);

                return new PolygonFinishNavigationNode(x, y, this, poly, connectedNodes);
            }
        }

        return null;
    }

    private function connectedNodesForPolygon(poly:Polygon2D):List {
        var connectedNodes:List = new ArrayList(poly.pointCount);

        var pointCount:int = poly.pointCount;
        for(var j:int = 0; j < pointCount; ++j) {
            var point:Point2D = poly.getPoint2D(j);
            var connectedNode:MeshNavigationNode = getNodeAt(point.x, point.y);

            if(connectedNode == null)
                throw new Error("missing node for one of the polygon's points: " + point);

            connectedNodes.add(connectedNode);
        }

        return connectedNodes;
    }
}
}

import compass.navigation.IFinishNavigationNode;
import compass.navigation.IStartNavigationNode;
import compass.navigation.mesh.MeshNavigationMap;
import compass.navigation.mesh.MeshNavigationNode;

import medkit.collection.Collection;

import medkit.geom.shapes.Polygon2D;

class PolygonStartNavigationNode extends MeshNavigationNode implements IStartNavigationNode {
    public function PolygonStartNavigationNode(x:Number, y:Number, map:MeshNavigationMap, polygon:Polygon2D, connectedNodes:Collection) {
        super(x, y, map, -1);

        _polygons.add(polygon);
        _nodes.addAll(connectedNodes);
    }
}

class LocationStartNavigationNode extends MeshNavigationNode implements IStartNavigationNode {
    private var _meshNode:MeshNavigationNode;

    public function LocationStartNavigationNode(node:MeshNavigationNode, map:MeshNavigationMap) {
        _meshNode = node;

        super(_meshNode.location.x, _meshNode.location.y, map, _meshNode.uniqueID);
    }

    override public function get connectedNodes():Collection { return _meshNode.connectedNodes; }

    override public function get connectedPolygons():Collection { return _meshNode.connectedPolygons; }
}

class PolygonFinishNavigationNode extends MeshNavigationNode implements IFinishNavigationNode {
    public function PolygonFinishNavigationNode(x:Number, y:Number, map:MeshNavigationMap, polygon:Polygon2D, connectedNodes:Collection) {
        super(x, y, map, -2);

        _polygons.add(polygon);
        _nodes.addAll(connectedNodes);
    }
}

class LocationFinishNavigationNode extends MeshNavigationNode implements IFinishNavigationNode {
    private var _meshNode:MeshNavigationNode;

    public function LocationFinishNavigationNode(node:MeshNavigationNode, map:MeshNavigationMap) {
        _meshNode = node;

        super(_meshNode.location.x, _meshNode.location.y, map, _meshNode.uniqueID);
    }

    override public function get connectedNodes():Collection { return _meshNode.connectedNodes; }

    override public function get connectedPolygons():Collection { return _meshNode.connectedPolygons; }
}