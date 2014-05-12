/**
 * User: booster
 * Date: 08/05/14
 * Time: 14:49
 */
package compass.navigation {
import medkit.collection.Collection;

public interface INavigationNode {
    /** Every node associated with a given map has to have an unique ID. */
    function get uniqueID():int

    /** Navigation map this node belongs to. */
    function get navigationMap():INavigationMap

    /** Nodes connected to this node. */
    function get connectedNodes():Collection

    /** Return cost of travel from a given node to this node or NaN if travel is not possible. */
    function getTravelCost(fromNode:INavigationNode, agent:INavigationAgent):Number
}
}
