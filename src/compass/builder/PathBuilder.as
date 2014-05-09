/**
 * User: booster
 * Date: 08/05/14
 * Time: 14:49
 */
package compass.builder {
import compass.navigation.IFinishNavigationNode;
import compass.navigation.INavigationAgent;
import compass.navigation.INavigationMap;
import compass.navigation.INavigationNode;
import compass.navigation.IStartNavigationNode;
import compass.builder.Path;

import medkit.collection.ArrayList;

import medkit.collection.Collection;
import medkit.collection.HashSet;
import medkit.collection.TreeSet;
import medkit.collection.iterator.Iterator;

public class PathBuilder {
    private var _alpha:Number;

    /**
     * How much actual and estimated cost is taken into account when pathfinding.
     * <code>cost = alpha * actualCostFromStart + (1 - alpha) * estimatedCostToEnd</code>
     */
    public function get alpha():Number { return _alpha; }
    public function set alpha(value:Number):void { _alpha = value; }

    public function findPath(startNode:IStartNavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent, maxIterations:int = int.MAX_VALUE, path:Path = null):Path {
        if(path != null)    path.reset();
        else                path = new Path();

        path.navigationNodes.add(startNode);

        continueSearch(finishNode, path, agent, maxIterations);
    }

    public function continueSearch(finishNode:IFinishNavigationNode, path:Path, agent:INavigationAgent, maxIterations:int = int.MAX_VALUE):Boolean {
        var pathSize:int = path.navigationNodes.size();

        if(pathSize == 0)
            throw new ArgumentError("path must contain at least one node");

        // this path is already complete
        if(path.complete)
            return false;

        var map:INavigationMap          = finishNode.navigationMap;
        var startNode:INavigationNode   = path.navigationNodes.get(pathSize - 1);

        path.navigationNodes.removeAt(pathSize - 1);

        var connectedNodes:Collection;
        var oneMinusAlpha:Number    = 1.0 - _alpha;
        var openNodes:TreeSet       = path.openBuilderNodes;
        var closedNodes:HashSet     = path.closedBuilderNodes;

        openNodes.clear(); // reset open nodes - continuing the search is the same as starting a new search really
        //closedNodes.clear(); // don't reset closed nodes, so we won't be going back and forth each call

        // let's assume we can find the path on one go
        path.complete = true;

        openNodes.add(startNode);

        var currentNode:PathBuilderNode = path.fetchBuilderNode();
        currentNode.reset(startNode);

        while(map.isConnectedToFinishNode(currentNode.navigationNode, finishNode, agent)) {
            if(openNodes.size() == 0 || maxIterations == 0) {
                path.complete = false; // path still incomplete
                break;
            }

            currentNode = openNodes.pollFirst();

            connectedNodes = currentNode.navigationNode.connectedNodes;

            for(var it:Iterator = connectedNodes.iterator(); it.hasNext(); ) {
                var testNode:PathBuilderNode = path.fetchBuilderNode();
                testNode.reset(it.next());

                var travelCost:Number = testNode.navigationNode.getTravelCost(currentNode.navigationNode, agent);

                // travelCost != travelCost - fast isNaN test
                if(travelCost != travelCost || testNode.equals(currentNode) || closedNodes.contains(testNode))
                    continue;

                var actualCostFromStart:Number  = currentNode.costFromStart + travelCost;
                var estimatedCostToEnd:Number   = map.estimatedCostToFinish(testNode.navigationNode, finishNode, agent);
                var estimatedTotalCost:Number   = _alpha * actualCostFromStart + oneMinusAlpha * estimatedCostToEnd;

                testNode.costFromStart          = actualCostFromStart;
                testNode.estimatedTotalCost     = estimatedTotalCost;

                if(openNodes.contains(testNode))
                    continue;

                openNodes.add(testNode);
            }

            closedNodes.add(currentNode);
            --maxIterations;
        }

        var pathContinuation:ArrayList = new ArrayList();
        while(currentNode != null) {
            pathContinuation.add(currentNode.navigationNode);
            currentNode = currentNode.parentNode;
        }

        // reverse result
        for(var left:int = 0, right:int = pathContinuation.size() - 1; left < right; ++left, --right) {
            var leftNode:INavigationNode    = pathContinuation.get(left);
            var rightNode:INavigationNode   = pathContinuation.get(right);

            pathContinuation.set(left, rightNode);
            pathContinuation.set(right, leftNode);
        }

        path.navigationNodes.addAll(pathContinuation);

        // if there still is a chance and need to complete this path, return true; false otherwise
        return ! path.complete && openNodes.size() > 0;
    }
}
}
