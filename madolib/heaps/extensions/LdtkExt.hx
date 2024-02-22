package madolib.heaps.extensions;

import ldtk.Layer_AutoLayer;
import ldtk.Layer_IntGrid;
import ldtk.Layer_Tiles;

using madolib.Option.OptionExt;
using madolib.extensions.ArrayExt;

class LdtkExt {
    public inline static function getEnumValue<T>(self: Layer_IntGrid, cx: Int, cy: Int, t: Enum<T>): Option<T>
        return safeGetName(self, cx, cy).map(name -> Type.createEnum(t, name, []));

    public inline static function safeGetName(self: Layer_IntGrid, cx: Int, cy: Int): Option<String>
        return @:nullSafety(Off) self.getName(cx, cy).ofValue();

    public inline static function safeGetInt(self: Layer_IntGrid, cx: Int, cy: Int): Option<Int>
        return @:nullSafety(Off) self.getInt(cx, cy).ofValue();

    public inline static function getAutotile(self: Layer_AutoLayer, cx: Int, cy: Int): Option<AutoTile> {
        final gridSize = self.gridSize;
        return self.autoTiles.findOption(tile -> {
            final tcx = Math.floor(tile.renderX / gridSize);
            final tcy = Math.floor(tile.renderY / gridSize);
            return cx == tcx && cy == tcy;
        });
    }

    public inline static function isFlip(self: AutoTile): Bool
        return self.flips > 0;

    public inline static function isFlipX(self: AutoTile): Bool
        return (self.flips ^ 1) == 0;

    public inline static function isFlipY(self: AutoTile): Bool
        return (self.flips ^ 2) == 0;

    public inline static function isFlipXY(self: AutoTile): Bool
        return self.flips == 3;

    public inline static function getAutotileFromTiles(self: Layer_Tiles, x: Int, y: Int, stackId: Int): Option<AutoTile> {
        final tile = @:nullSafety(Off) self.getTileStackAt(x, y)[stackId];
        return if(tile == null) {
            None;
        } else {
            final gridSize = self.gridSize;
            Some({
                renderX: x * gridSize,
                renderY: y * gridSize,
                flips: tile.flipBits,
                tileId: tile.tileId,
                coordId: 0,
                ruleId: 0,
                alpha: self.opacity,
            });
        }
    }

    public inline static function eachiWithName(self: Layer_IntGrid, f: Int -> Int -> String -> Void) {
        for(iy in 0...self.cHei) {
            for(ix in 0...self.cWid) {
                final name = self.getName(ix, iy);
                if(name != null) f(ix, iy, name);
            }
        }
    }

    public inline static function eachi(self: Layer_IntGrid, f: Int -> Int -> Int -> Void) {
        for(iy in 0...self.cHei) {
            for(ix in 0...self.cWid) {
                final int = self.getInt(ix, iy);
                if(int != null) f(ix, iy, int);
            }
        }
    }
}
