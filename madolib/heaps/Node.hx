package madolib.heaps;

import h2d.RenderContext;
import h2d.col.Bounds;

class Node extends h2d.Object implements Updatable implements Disposable {
    public static final empty = new Node();

    public var pivotX: Float = 0;
    public var pivotY: Float = 0;
    @:isVar public var width(get, set): Float = 0;
    @:isVar public var height(get, set): Float = 0;

    function get_width(): Float
        return width;

    function set_width(v: Float): Float
        return width = v;

    function get_height(): Float
        return height;

    function set_height(v: Float): Float
        return height = v;

    public var scaledWidth(get, never): Float;
    public var scaledHeight(get, never): Float;

    inline function get_scaledWidth(): Float
        return width * scaleX;

    inline function get_scaledHeight(): Float
        return height * scaleY;

    public var pivotedX(get, never): Float;
    public var pivotedY(get, never): Float;

    inline function get_pivotedX(): Float
        return x - pivotX * scaledWidth;

    inline function get_pivotedY(): Float
        return y - pivotY * scaledHeight;

    public var centerX(get, never): Float;
    public var centerY(get, never): Float;

    function get_centerX(): Float
        return pivotedX + scaledWidth * .5;

    function get_centerY(): Float
        return pivotedY + scaledHeight * .5;

    var isStarted = false;
    var active(default, set): Bool = true;

    inline function set_active(v: Bool): Bool {
        return if(active == v) {
            v;
        } else {
            active = v;
            onChangeActive();
            v;
        }
    }

    public var disposed(default, null) = false;

    var onDisposed(default, null) = false;

    var grouped: Map<String, Array<Node>> = new Map<String, Array<Node>>();

    public var sceneTree: Null<SceneTree> = null;

    public function new(?sceneTree: SceneTree) {
        super();

        this.sceneTree = sceneTree;
    }

    public inline function setPivot(x: Float, y: Float) {
        pivotX = x;
        pivotY = y;
    }

    public function start() {
        if(isStarted) return;
        isStarted = true;
        function go(cs: Array<h2d.Object>) {
            for(child in cs) {
                if(child is Node) {
                    cast(child, Node).start();
                } else {
                    go(child.children);
                }
            }
        }
        go(children);
    }

    public function dispose() {
        if(disposed) return;
        disposed = true;

        function go(cs: Array<h2d.Object>) {
            for(child in cs) {
                if(child is Node) {
                    cast(child, Node).dispose();
                } else {
                    go(child.children);
                }
            }
        }

        go(children);
    }

    function onDispose() {
        if(onDisposed) return;
        onDisposed = true;

        remove();

        function go(cs: Array<h2d.Object>) {
            for(child in cs) {
                if(child is Node) {
                    cast(child, Node).onDispose();
                } else {
                    go(child.children);
                }
            }
        }
        go(children);
    }

    function onChangeActive() {
        function go(cs: Array<h2d.Object>) {
            for(child in cs) {
                if(child is Node) {
                    final node = cast(child, Node);
                    node.active = active;
                    node.onChangeActive();
                } else {
                    go(child.children);
                }
            }
        }
        go(children);
    }

    public function pause() {
        active = false;
    }

    public function resume() {
        active = true;
    }

    final public inline function togglePause() {
        if(active)
            pause();
        else
            resume();
    }

    public function update(dt: Float) {}

    public function fixedUpdate() {}

    public function afterUpdate(dt: Float) {}

    public function addGroup(name: String) {
        if(grouped.exists(name)) return;
        if(sceneTree == null) return;
        final group = sceneTree.addGroupNode(name, this);
        grouped[name] = group;
    }

    public function removeGroup(name: String) {
        final group = grouped.get(name);
        if(group == null) return;
        group.remove(this);
        grouped.remove(name);
    }

    public inline function isInGroup(name: String): Bool
        return grouped.exists(name);

    public function removeSceneTree() {
        if(sceneTree != null) {
            sceneTree.removeNode(this);
            sceneTree = null;
        }
    }

    override function getBoundsRec(relativeTo: h2d.Object, out: h2d.col.Bounds, forSize: Bool) {
        final baseX = x;
        final baseY = y;
        x = pivotedX;
        y = pivotedY;
        super.getBoundsRec(relativeTo, out, forSize);
        x = baseX;
        y = baseY;
    }

    override function syncPos() {
        final baseX = x;
        final baseY = y;
        x = pivotedX;
        y = pivotedY;
        super.syncPos();
        x = baseX;
        y = baseY;
    }

    override function drawRec(ctx: RenderContext) {
        final baseX = x;
        final baseY = y;
        x = pivotedX;
        y = pivotedY;
        super.drawRec(ctx);
        x = baseX;
        y = baseY;
    }

    override function addChildAt(s: h2d.Object, pos: Int) {
        super.addChildAt(s, pos);
        if(s is Node) {
            final node = cast(s, Node);
            node.sceneTree = sceneTree;
        }
    }

    public function getParentNode(): Null<Node> {
        var parent = parent;
        while(parent != null) {
            if(parent is Node) {
                return cast parent;
            }
            parent = parent.parent;
        }
        return null;
    }

    public function findChild<T>(f: h2d.Object -> Null<T>, recursive: Bool = false): Null<T> {
        function go(object: h2d.Object, f: h2d.Object -> Null<T>, recursive: Bool): Null<T> {
            final result = f(object);
            if(result != null) return result;
            if(recursive) {
                for(child in object.children) {
                    final result = go(child, f, recursive);
                    if(result != null) return result;
                }
            }
            return null;
        }
        final result = f(this);
        if(result != null) return result;

        for(child in children) {
            final result = go(child, f, recursive);
            if(result != null) return result;
        }
        return null;
    }

    public function findChildren<T>(f: h2d.Object -> Null<T>, recursive: Bool = false): Array<T> {
        final result: Array<T> = [];
        function go(object: h2d.Object, f: h2d.Object -> Null<T>, recursive: Bool) {
            final r = f(object);
            if(r != null) result.push(r);
            if(recursive) {
                for(child in object.children) {
                    go(child, f, recursive);
                }
            }
        }

        final r = f(this);
        if(r != null) result.push(r);

        for(child in children) {
            go(child, f, recursive);
        }
        return result;
    }
}
