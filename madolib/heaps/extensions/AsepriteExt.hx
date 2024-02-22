package madolib.heaps.extensions;

import aseprite.AseAnim;
import aseprite.Aseprite;
import h2d.Bitmap;
import madolib.Option;
import madolib.geom.Bounds;

using madolib.extensions.ArrayExt;
using madolib.extensions.IteratorExt;

class AsepriteExt {
    public inline static function toBitmap(aseprite: Aseprite): Bitmap
        return new Bitmap(aseprite.getFrame(0).tile.clone());

    public inline static function toAseAnim(aseprite: Aseprite): AseAnim
        return new AseAnim(aseprite.getFrames());

    public inline static function toAseAnimWithSlice(aseprite: Aseprite, sliceName: String, loop: Bool = false): AseAnim {
        final anim = new AseAnim(aseprite.getSlices(sliceName));
        anim.loop = loop;
        return anim;
    }

    public inline static function getAnimationFromTag(aseprite: Aseprite, tag: String, ?sliceName: String, loop: Bool = false): AseAnim {
        final anim = new AseAnim(aseprite.getTag(tag, sliceName));
        anim.loop = loop;
        return anim;
    }

    public static function getCollisions(ase: Aseprite, baseSliceName: String, ?collisionSliceName: String, flipX: Bool = false,
            flipY: Bool = false): Array<Bounds> {
        if(!ase.slices.exists(baseSliceName))
            return [];
        final baseSlice = ase.getSlice(baseSliceName);
        final baseTile = baseSlice.tile;
        final colSliceName = collisionSliceName ?? '${baseSliceName}-Col';
        final colNames = ase.slices.keys().filter(k -> k.indexOf(colSliceName) == 0);
        return if(colNames.length == 0) {
            [new Bounds(baseTile.dx, baseTile.dy, baseTile.width, baseTile.height)];
        } else {
            colNames.map(colName -> {
                final colSlice = ase.getSlice(colName);
                final col = colSlice.tile;
                final padLeft = col.x - baseTile.x;
                final padTop = col.y - baseTile.y;
                final padRight = baseTile.width - (padLeft + col.width);
                final padBottom = baseTile.height - (padTop + col.height);
                final x = if(flipX) padRight else padLeft;
                final y = if(flipY) padBottom else padTop;
                new Bounds(x, y, col.width, col.height);
            });
        }
    }

    public static function getCollision(ase: Aseprite, baseSliceName: String, ?collisionSliceName: String, flipX: Bool = false,
            flipY: Bool = false): Option<Bounds> {
        if(!ase.slices.exists(baseSliceName))
            return None;
        final baseSlice = ase.getSlice(baseSliceName);
        final baseTile = baseSlice.tile;
        final colSliceName = collisionSliceName ?? '${baseSliceName}-Col';
        final colSlice = ase.getSlice(colSliceName);
        return if(colSlice == null) {
            Some(new Bounds(baseTile.dx, baseTile.dy, baseTile.width, baseTile.height));
        } else {
            final col = colSlice.tile;
            final padLeft = col.x - baseTile.x;
            final padTop = col.y - baseTile.y;
            final padRight = baseTile.width - (padLeft + col.width);
            final padBottom = baseTile.height - (padTop + col.height);
            final x = if(flipX) padRight else padLeft;
            final y = if(flipY) padBottom else padTop;
            Some(new Bounds(x, y, col.width, col.height));
        }
    }
}
