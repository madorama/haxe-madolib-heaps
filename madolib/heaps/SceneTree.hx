package madolib.heaps;

using madolib.extensions.ArrayExt;
using madolib.extensions.MapExt;

@:access(madolib.heaps.Node)
@:access(h2d.Object)
class SceneTree implements Updatable implements Disposable {
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

    public var nodes: Array<Node> = [];

    public function new() {}

    public inline function getGroupNodes(name: String): Array<Node>
        return groups.withDefault(name, []);

    public function addNode(node: Node) {
        if(node.sceneTree != this) {
            node.sceneTree?.nodes.remove(node);
            node.removeAllGroup();
            node.sceneTree = this;
            nodes.push(node);
        }
    }

    public function removeNode(node: Node) {
        if(node.sceneTree == this) {
            node.dispose();
        }
    }

    public function addGroupNode(name: String, node: Node) {
        addNode(node);
        if(!node.isInGroup(name)) {
            node.addGroup(name);
        }
    }

    public function removeGroupNode(name: String, node: Node) {
        if(node.isInGroup(name)) {
            node.removeGroup(name);
        }
    }

    public function deleteGroup(name: String) {
        final group = groups.get(name);
        if(group == null) return;
        for(node in group)
            node.grouped.remove(name);
        groups.remove(name);
    }

    function onResize() {}

    public function dispose() {
        while(nodes.length >= 0) {
            final node = nodes[0];
            nodes.splice(0, 1);
            node.dispose();
            node.onDispose();
        }
        groups.clear();
    }

    public function pause() {
        paused = true;
    }

    public function resume() {
        paused = false;
    }

    public function find<T: Node>(f: Node -> Null<T>, ?groupName: String, recursive: Bool = false): Null<T> {
        function go(object: h2d.Object, f: Node -> T, recursive: Bool): Null<T> {
            final node = Util.downcast(object, Node);
            if(node != null) {
                final r = f(node);
                if(r != null) return r;
            }
            if(recursive) {
                for(child in object.children) {
                    final result = go(child, f, recursive);
                    if(result != null) return result;
                }
            }
            return null;
        }

        final nodes = if(groupName != null) {
            groups.get(groupName) ?? [];
        } else {
            this.nodes;
        }
        for(node in nodes) {
            final result = go(node, f, recursive);
            if(result != null) return result;
        }
        return null;
    }

    public function findAll<T: Node>(f: Node -> Null<T>, ?groupName: String, recursive: Bool = false): Array<T> {
        final result = [];
        function go(object: h2d.Object, f: Node -> Null<T>, recursive: Bool) {
            final node = Util.downcast(object, Node);
            if(node != null) {
                final r = f(node);
                if(f(r) != null) result.push(r);
            }
            if(recursive) {
                for(child in object.children) {
                    go(child, f, recursive);
                }
            }
        }

        final nodes = if(groupName != null) {
            groups.get(groupName) ?? [];
        } else {
            this.nodes;
        }
        for(node in nodes) {
            go(node, f, recursive);
        }
        return result;
    }

    inline function canRun(): Bool
        return !(paused || destroyed);

    function update(dt: Float) {
        function go(cs: Array<h2d.Object>) {
            for(child in cs) {
                final node = Util.downcast(child, Node);
                if(node != null) {
                    if(node.disposed) {
                        @:privateAccess App.disposedNodes.push(node);
                        nodes.remove(node);
                        node.removeAllGroup();
                        node.sceneTree = null;
                    }
                    if(!node.isStarted) {
                        node.start();
                    }
                    if(node.active && node.isStarted)
                        node.update(dt);
                }
                go(child.children);
            }
        }
        for(node in nodes) {
            go(node.children);
            node.update(dt);
        }
    }

    function fixedUpdate() {
        function go(cs: Array<h2d.Object>) {
            for(child in cs) {
                final node = Util.downcast(child, Node);
                if(node != null && node.active) {
                    node.fixedUpdate();
                }
                go(child.children);
            }
        }
        for(node in nodes) {
            go(node.children);
            node.fixedUpdate();
        }
    }

    function afterUpdate(dt: Float) {
        function go(cs: Array<h2d.Object>) {
            for(child in cs) {
                final node = Util.downcast(child, Node);
                if(node != null && node.active) {
                    node.afterUpdate(dt);
                }
                go(child.children);
            }
        }
        for(node in nodes) {
            go(node.children);
            node.afterUpdate(dt);
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
