/**
 * User: booster
 * Date: 08/05/14
 * Time: 15:33
 */
package compass.navigation {
import medkit.collection.Collection;

public interface INavigationMap {
    function get nodes():Collection

    function isConnectedToFinishNode(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Boolean

    function estimatedCostToFinish(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Number
}
}
