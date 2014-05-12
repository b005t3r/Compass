/**
 * User: booster
 * Date: 09/05/14
 * Time: 11:06
 */
package compass.builder {
import medkit.collection.ArrayList;
import medkit.collection.HashSet;
import medkit.collection.List;
import medkit.collection.TreeSet;
import medkit.collection.iterator.ListIterator;

public class Path {
    private var _complete:Boolean               = false;
    private var _navigationNodes:List           = new ArrayList();

    private var _openBuilderNodes:TreeSet       = new TreeSet();
    private var _closedBuilderNodes:HashSet     = new HashSet();

    private var _cachedBuilderNodes:List        = new ArrayList();
    private var _cachedBuilderNodesIt:ListIterator;

    public function Path(initialNodeCacheSize:int = 10) {
        _cachedBuilderNodesIt = _cachedBuilderNodes.listIterator();

        ensureCacheSize(initialNodeCacheSize);
    }

    public function get complete():Boolean { return _complete; }
    public function set complete(value:Boolean):void { _complete = value; }

    public function get navigationNodes():List { return _navigationNodes; }

    public function get openBuilderNodes():TreeSet { return _openBuilderNodes; }
    public function get closedBuilderNodes():HashSet { return _closedBuilderNodes; }

    public function fetchBuilderNode():PathBuilderNode {
        if(! _cachedBuilderNodesIt.hasNext())
            ensureCacheSize(Math.ceil(_cachedBuilderNodes.size() * 1.5) + 10);

        return _cachedBuilderNodesIt.next();
    }

    public function reset():void {
        _complete = false;
        _navigationNodes.clear();

        _openBuilderNodes.clear();
        _closedBuilderNodes.clear();

        _cachedBuilderNodesIt = _cachedBuilderNodes.listIterator();
    }

    private function ensureCacheSize(newSize:int):void {
        var oldSize:int = _cachedBuilderNodes.size();

        if(newSize <= oldSize)
            return;

        var lastUsedNodeIndex:int = _cachedBuilderNodesIt.previousIndex();

        var additionalNodeCount:int = newSize - oldSize;
        for(var i:int = 0; i < additionalNodeCount; i++) {
            var pathNode:PathBuilderNode = new PathBuilderNode();

            _cachedBuilderNodes.add(pathNode);
        }

        _cachedBuilderNodesIt = _cachedBuilderNodes.listIterator(lastUsedNodeIndex + 1);
    }
}
}
