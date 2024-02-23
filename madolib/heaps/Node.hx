package madolib.heaps;

import h2d.RenderContext;
import h2d.col.Bounds;

using madolib.extensions.MapExt;

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
                final node = Util.downcast(child, Node);
                if(node != null) {
                    node.start();
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
                final node = Util.downcast(child, Node);
                if(node != null) {
                    node.dispose();
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
                final node = Util.downcast(child, Node);
                if(node != null) {
                    node.onDispose();
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
                final node = Util.downcast(child, Node);
                if(node != null) {
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
        final group = sceneTree.groups.withDefaultOrSet(name, []);
        group.push(this);
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

    public function removeAllGroup() {
        for(name => _ in grouped) {
            removeGroup(name);
        }
    }

    override function calcAbsPos() {
        if(parent == null) {
            var cr, sr;
            if(rotation == 0) {
                cr = 1.;
                sr = 0.;
                matA = scaleX;
                matB = 0;
                matC = 0;
                matD = scaleY;
            } else {
                cr = Math.cos(rotation);
                sr = Math.sin(rotation);
                matA = scaleX * cr;
                matB = scaleX * sr;
                matC = scaleY * -sr;
                matD = scaleY * cr;
            }
            absX = x - (pivotX * width * matA + pivotY * height * matC);
            absY = y - (pivotX * width * matB + pivotY * height * matD);
        } else {
            // M(rel) = S . R . T
            // M(abs) = M(rel) . P(abs)
            if(rotation == 0) {
                matA = scaleX * parent.matA;
                matB = scaleX * parent.matB;
                matC = scaleY * parent.matC;
                matD = scaleY * parent.matD;
            } else {
                var cr = Math.cos(rotation);
                var sr = Math.sin(rotation);
                var tmpA = scaleX * cr;
                var tmpB = scaleX * sr;
                var tmpC = scaleY * -sr;
                var tmpD = scaleY * cr;
                matA = tmpA * parent.matA + tmpB * parent.matC;
                matB = tmpA * parent.matB + tmpB * parent.matD;
                matC = tmpC * parent.matA + tmpD * parent.matC;
                matD = tmpC * parent.matB + tmpD * parent.matD;
            }
            absX = x * parent.matA + y * parent.matC + parent.absX - (pivotX * width * matA + pivotY * height * matC);
            absY = x * parent.matB + y * parent.matD + parent.absY - (pivotX * width * matB + pivotY * height * matD);
        }
    }

    override function addChildAt(s: h2d.Object, pos: Int) {
        super.addChildAt(s, pos);
        final node = Util.downcast(s, Node);
        if(node != null) {
            node.sceneTree = sceneTree;
        }
    }

    public function getParentNode(): Null<Node> {
        var parent = parent;
        while(parent != null) {
            final node = Util.downcast(parent, Node);
            if(node != null)
                return node;
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
