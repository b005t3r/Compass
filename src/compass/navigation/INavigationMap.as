/**
 * User: booster
 * Date: 08/05/14
 * Time: 15:33
 */
package compass.navigation {
import compass.navigation.INavigationNode;

import medkit.collection.Collection;

public interface INavigationMap {
    function get nodes():Collection

    function findConnectedToStartNode(startNode:IStartNavigationNode, agent:INavigationAgent, result:Collection = null):Collection
    function isConnectedToFinishNode(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Boolean

    function estimatedCostToFinish(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Number
}
}
