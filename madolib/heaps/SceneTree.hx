package madolib.heaps;

using madolib.extensions.ArrayExt;
using madolib.extensions.MapExt;

@:access(madolib.heaps.Node)
class SceneTree extends Node implements Updatable implements Disposable {
    public var defaultFrameRate(get, never): Float;

    inline function get_defaultFrameRate(): Float
        return hxd.Timer.wantedFPS;

    public var ftime(default, null): Float = 0;
    public var elapsedFrames(get, never): Int;

    inline function get_elapsedFrames(): Int
        return Std.int(ftime);

    public var elapsedSeconds(get, never): Float;

    inline function get_elapsedSeconds(): Float
        return ftime / defaultFrameRate;

    public var groups: Map<String, Array<Node>> = [];

    public var paused(default, null): Bool = false;
    public var destroyed(default, null): Bool = false;

    public function new() {
        super();
    }

    public inline function getGroupNodes(name: String): Array<Node>
        return groups.withDefault(name, []);

    public function addNode(node: Node) {
        if(node.sceneTree != this) {
            node.removeSceneTree();
            addChild(node);
            node.sceneTree = this;
        }
    }

    public function removeNode(node: Node) {
        if(node.sceneTree == this) {
            for(name => g in groups) {
                removeGroupNode(name, node);
            }
            node.remove();
        }
    }

    public function addGroupNode(name: String, node: Node): Array<Node> {
        addNode(node);
        final group = groups.withDefaultOrSet(name, []);
        if(!node.isInGroup(name)) {
            group.push(node);
        }
        return group;
    }

    public function removeGroupNode(name: String, node: Node) {
        if(node.isInGroup(name)) {
            node.removeGroup(name);
        }
    }

    public function deleteGroup(name: String) {
        if(groups.exists(name)) {
            final group = groups.get(name);
            if(group == null) return;
            for(node in group)
                node.grouped.remove(name);
            groups.remove(name);
        }
    }

    function onResize() {}

    inline function canRun(): Bool
        return !(paused || destroyed);

    inline function disposeNode(index: Int, node: Node) {
        if(!node.onDisposed) node.onDispose();
        for(groupName in node.grouped.keys()) {
            final group = groups.get(groupName);
            if(group == null) continue;
            group.remove(node);
        }
        children = children.removeAt(index);
    }

    inline function gc() {
        var i = children.length - 1;

        while(i >= 0) {
            final node = Std.downcast(children[i], Node);
            if(node != null) {
                if(node.disposed) {
                    disposeNode(i, node);
                    continue;
                }
                i--;
            } else {
                i--;
            }
        }
    }

    inline function doUpdate(dt: Float) {
        if(!canRun()) return;
        ftime += dt;
        update(dt);
    }

    inline function doFixedUpdate() {
        if(!canRun()) return;
        fixedUpdate();
    }

    inline function doAfterUpdate(dt: Float) {
        if(!canRun()) return;
        afterUpdate(dt);
    }
}
