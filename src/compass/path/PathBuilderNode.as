/**
 * User: booster
 * Date: 08/05/14
 * Time: 14:59
 */
package compass.path {
import compass.navigation.INavigationNode;

import medkit.object.Comparable;
import medkit.object.Equalable;
import medkit.object.Hashable;

/** Used internally by Path. Describes a single step of A* pathfinding algorithm. */
public class PathBuilderNode implements Equalable, Comparable, Hashable {
    /** How much it currently costs to get from start to this node. */
    public var costFromStart:Number;

    /** How much we guess it's going to cost to get from the start to the end through this node. */
    public var estimatedTotalCost:Number;

    /** Navigation node associated with this data. */
    public var navigationNode:INavigationNode = null;

    /** Parent node used to travel from to this node. */
    public var parentNode:PathBuilderNode = null;

    /** Builder currently using this node. */
    private var builder:PathBuilder = null;
    private var minDiff:Number = NaN;

    public function reset(node:INavigationNode, builder:PathBuilder):PathBuilderNode {
        this.costFromStart      = 0;
        this.estimatedTotalCost = 0;
        this.navigationNode     = node;
        this.parentNode         = null;
        this.builder            = builder;
        this.minDiff            = builder.minimumDifference;

        return this;
    }

    /** Both builder nodes are equal if their navigation nodes' uniqueIDs are equal. */
    public function equals(object:Equalable):Boolean {
        var builderNode:PathBuilderNode = object as PathBuilderNode;

        if(builderNode == null)
            return false;

        return navigationNode.uniqueID == builderNode.navigationNode.uniqueID;
    }

    public function compareTo(object:Comparable):int {
        var builderNode:PathBuilderNode = object as PathBuilderNode;

        if(builderNode == null) throw new ArgumentError("PathBuilderNode can only be compared with another PathBuilderNode: " + object);

        var idDiff:int = navigationNode.uniqueID - builderNode.navigationNode.uniqueID;

        if(idDiff == 0)
            return 0;

        var result:Number = estimatedTotalCost - builderNode.estimatedTotalCost;

        if(Math.abs(result) < minDiff)
            return idDiff; // cost is the same, but described cells can still be different

        if(result > 0.0)    return 1;
        else                return -1;
    }

    public function hashCode():int {
        return navigationNode.uniqueID;
    }
}
}
