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

public class MeshNavigationMap implements INavigationMap {
    protected var _nodes:List = new ArrayList();

    public function MeshNavigationMap() {
    }

    public function get nodes():Collection { return _nodes; }

    public function isConnectedToFinishNode(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Boolean {
        return false;
    }

    public function estimatedCostToFinish(node:INavigationNode, finishNode:IFinishNavigationNode, agent:INavigationAgent):Number {
        return 0;
    }
}
}
