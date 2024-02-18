package madolib.heaps.node;

import haxe.exceptions.NotImplementedException;
import hxmath.math.Vector2;
import madolib.Option;
import madolib.collider.Collide.HitPosition;
import madolib.collider.Collide;
import madolib.geom.Bounds;

using madolib.extensions.ArrayExt;

class GridCollider extends Collider {
    var cellWidth = 0.;
    var cellHeight = 0.;
    var data: Array<Bool> = [];

    public var cellsWidth(default, null): Int;
    public var cellsHeight(default, null): Int;

    inline function computeId(x: Int, y: Int): Int
        return x + y * cellsWidth;

    public function new(cellsWidth: Int, cellsHeight: Int, cellWidth: Float, cellHeight: Float) {
        super();
        data.resize(cellsWidth * cellsHeight);
        this.cellWidth = cellWidth;
        this.cellHeight = cellHeight;
        this.cellsWidth = cellsWidth;
        this.cellsHeight = cellsHeight;
        clear();
    }

    public function clear(val: Bool = false) {
        for(iy in 0...cellsHeight) {
            for(ix in 0...cellsWidth)
                data[computeId(ix, iy)] = val;
        }
    }

    public function setRect(x: Int, y: Int, w: Int, h: Int, val: Bool = true) {
        inline function resize() {
            if(x < 0) {
                w += x;
                x = 0;
            }
            if(y < 0) {
                h += y;
                y = 0;
            }
            if(x + w > cellsWidth)
                w = cellsWidth - x;
            if(y + h > cellsHeight)
                h = cellsHeight - y;
        }
        resize();
        for(iy in 0...h) {
            for(ix in 0...w) {
                data[computeId(x + ix, y + iy)] = val;
            }
        }
    }

    public function checkRect(x: Int, y: Int, w: Int, h: Int): Bool {
        inline function resize() {
            if(x < 0) {
                w += x;
                x = 0;
            }
            if(y < 0) {
                h += y;
                y = 0;
            }
            if(x + w > cellsWidth)
                w = cellsWidth - x;
            if(y + h > cellsHeight)
                h = cellsHeight - y;
        }

        for(iy in 0...h) {
            for(ix in 0...w) {
                if(data[computeId(x + ix, y + iy)])
                    return true;
            }
        }
        return false;
    }

    public inline function get(x: Int, y: Int): Bool {
        return x >= 0 && y >= 0 && x < cellsWidth && y < cellsHeight && data[computeId(x, y)];
    }

    public inline function set(x: Int, y: Int, val: Bool) {
        data[computeId(x, y)] = val;
    }

    public inline function isEmpty(): Bool
        return data.any(v -> v);

    override function get_width(): Float
        return cellWidth * cellsWidth;

    override function set_width(v: Float): Float
        throw new NotImplementedException();

    override function get_height(): Float
        return cellHeight * cellsHeight;

    override function set_height(v: Float): Float
        throw new NotImplementedException();

    override function get_left(): Float
        return x;

    override function set_left(value: Float): Float
        return x = value;

    override function get_top(): Float
        return y;

    override function set_top(v: Float): Float
        return y = v;

    override function get_right(): Float
        return x + width;

    override function set_right(v: Float): Float
        return x = v - width;

    override function get_bottom(): Float
        return y + height;

    override function set_bottom(v: Float): Float
        return y = v - height;

    function clone(): Collider {
        final grid = new GridCollider(cellsWidth, cellsHeight, cellWidth, cellHeight);
        grid.data = data.copy();
        return grid;
    }

    function debugDraw(graphics: h2d.Graphics) {
        for(iy in 0...cellsHeight) {
            for(ix in 0...cellsWidth) {
                if(!get(ix, iy))
                    continue;
                final x = absoluteLeft + ix * cellWidth;
                final y = absoluteTop + iy * cellHeight;
                graphics.drawRect(x, y, cellWidth, cellHeight);
            }
        }
    }

    override function collidePoint(p: Vector2): Bool {
        if(p.x >= absoluteLeft && p.y >= absoluteTop && p.x < absoluteRight && p.y < absoluteBottom) {
            final x = Std.int((p.x - absoluteLeft) / cellWidth);
            final y = Std.int((p.y - absoluteTop) / cellHeight);
            return data[computeId(x, y)];
        }
        return false;
    }

    override function collideBounds(bounds: Bounds): Bool {
        if(bounds.overlaps(this.bounds)) {
            final x = Std.int((bounds.left - absoluteLeft) / cellWidth);
            final y = Std.int((bounds.top - absoluteTop) / cellHeight);
            final w = Std.int(Math.ceil(bounds.right - absoluteLeft - 1) / cellWidth) - x + 1;
            final h = Std.int(Math.ceil(bounds.bottom - absoluteTop - 1) / cellHeight) - y + 1;
            return checkRect(x, y, w, h);
        }
        return false;
    }

    override function intersectLine(from: Vector2, to: Vector2): Option<HitPosition> {
        final baseFrom = from.clone();
        final baseTo = to.clone();
        var from = from - absolutePosition;
        var to = to - absolutePosition;
        from = new Vector2(Math.floor(from.x / cellWidth), Math.floor(from.y / cellHeight));
        to = new Vector2(Math.floor(to.x / cellWidth), Math.floor(to.y / cellHeight));
        final lines = dn.Bresenham.getThickLine(Std.int(from.x), Std.int(from.y), Std.int(to.x), Std.int(to.y), true);
        for(p in lines) {
            if(!get(p.x, p.y)) continue;
            switch Collide.intersectBoundsVsLine(new Bounds(p.x * cellWidth, p.y * cellHeight, cellWidth, cellHeight), baseFrom, baseTo) {
                case None:
                case Some(hit):
                    return Some(hit);
            }
        }
        return None;
    }

    override function collideLine(from: Vector2, to: Vector2): Bool {
        var from = from - absolutePosition;
        var to = to - absolutePosition;
        from = new Vector2(from.x / cellWidth, from.y / cellHeight);
        to = new Vector2(to.x / cellWidth, to.y / cellHeight);

        var x0 = Std.int(from.x);
        var y0 = Std.int(from.y);
        var x1 = Std.int(to.x);
        var y1 = Std.int(to.y);
        final dx = Math.abs(x1 - x0);
        final dy = Math.abs(y1 - y0);
        final sx = if(x0 < x1) 1 else -1;
        final sy = if(y0 < y1) 1 else -1;

        var err = dx - dy;

        while(true) {
            if(get(x0, y0))
                return true;

            if(x0 == x1 && y0 == y1)
                break;

            final e2 = 2 * err;
            if(e2 > -dy) {
                err -= dy;
                x0 += sx;
            }
            if(e2 < dx) {
                err += dx;
                y0 += sy;
            }
        }

        return false;
    }

    function collideBox(box: BoxCollider): Bool
        return collideBounds(box.bounds);

    function collideCircle(circle: CircleCollider): Bool
        return false;

    function collidePolygon(polygon: PolygonCollider): Bool
        return false;

    function collideGrid(grid: GridCollider): Bool
        throw "grid vs grid is not implemented";
}
