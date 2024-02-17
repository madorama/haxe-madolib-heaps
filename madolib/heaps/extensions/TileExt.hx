package madlib.heaps.extensions;

import aseprite.AseAnim;
import aseprite.Aseprite.AsepriteFrame;

class TileExt {
    public inline static function toAseFrame(tile: h2d.Tile): AsepriteFrame
        return { index: 0, duration: 0, tile: tile };

    public inline static function toAseAnim(tile: h2d.Tile): AseAnim
        return new AseAnim([toAseFrame(tile)]);
}
