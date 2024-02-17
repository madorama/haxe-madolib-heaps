package madolib.heaps.node;

import differ.shapes.Ray;
import hxmath.math.Vector2;
import madolib.collider.Collide;

using madolib.extensions.DifferExt;

class BoxCollider extends Collider {
    override function get_right(): Float
        return x + width;

    override function set_right(value: Float): Float
        return x = value - width;

    override function get_bottom(): Float
        return y + height;

    override function set_bottom(value: Float): Float
        return y = value - height;

    public function new(x: Float, y: Float, width: Float, height: Float, ?node: Node) {
        super();
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    public function intersects(box: BoxCollider): Bool
        return absoluteLeft < box.absoluteRight && absoluteRight > box.absoluteLeft && absoluteBottom > box.absoluteTop && absoluteTop < box.absoluteBottom;

    public function intersectsValue(x: Float, y: Float, width: Float, height: Float): Bool
        return absoluteRight > x && absoluteBottom > y && absoluteLeft < x + width && absoluteTop < y + height;

    public function set(x: Float, y: Float, w: Float, h: Float) {
        this.x = x;
        this.y = y;
        width = w;
        height = h;
    }

    public function getTopEdge(): Ray
        return new Vector2(absoluteLeft, absoluteTop).createRayFromVector(new Vector2(absoluteRight, absoluteTop));

    public function getBottomEdge(): Ray
        return new Vector2(absoluteLeft, absoluteBottom).createRayFromVector(new Vector2(absoluteRight, absoluteBottom));

    public function getLeftEdge(): Ray
        return new Vector2(absoluteLeft, absoluteTop).createRayFromVector(new Vector2(absoluteLeft, absoluteBottom));

    public function getRightEdge(): Ray
        return new Vector2(absoluteRight, absoluteTop).createRayFromVector(new Vector2(absoluteRight, absoluteBottom));

    function clone(): Collider
        return new BoxCollider(x, y, width, height, node);

    public function debugDraw(g: h2d.Graphics) {
        final b = bounds;
        g.drawRect(b.x, b.y, b.width, b.height);
    }

    function collideBox(box: BoxCollider): Bool
        return intersects(box);

    function collideCircle(circle: CircleCollider): Bool
        return Collide.boundsVsCircle(bounds, circle.absolutePosition, circle.radius);

    function collidePolygon(polygon: PolygonCollider): Bool
        return polygon.collideBounds(bounds);

    function collideGrid(grid: GridCollider): Bool
        return grid.collideBounds(bounds);
}
