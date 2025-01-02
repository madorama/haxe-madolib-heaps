package madolib.heaps.assets;

import haxe.ds.StringMap;
import ase.AnimationDirection;
import h2d.Bitmap;
import h2d.ScaleGrid;
import madolib.geom.Bounds;

using madolib.extensions.IteratorExt;
using madolib.extensions.MapExt;

@:using(madolib.heaps.assets.Aseprite.AsepriteFrameExt)
typedef AsepriteFrame = {
    index: Int,
    duration: Int,
    tile: h2d.Tile,
}

private class AsepriteFrameExt {
    public inline static function clone(frame: AsepriteFrame): AsepriteFrame {
        return {
            index: frame.index,
            duration: frame.duration,
            tile: frame.tile.clone(),
        }
    }
}

@:using(madolib.heaps.assets.Aseprite.SliceKeyExt)
typedef SliceKey = {
    xOrigin: Int,
    yOrigin: Int,
    width: Int,
    height: Int,
    xCenter: Int,
    yCenter: Int,
    centerWidth: Int,
    centerHeight: Int,
    xPivot: Int,
    yPivot: Int,
    frame: AsepriteFrame,
}

private class SliceKeyExt {
    public inline static function clone(key: SliceKey): SliceKey {
        return {
            xOrigin: key.xOrigin,
            yOrigin: key.yOrigin,
            width: key.width,
            height: key.height,
            xCenter: key.xCenter,
            yCenter: key.yCenter,
            centerWidth: key.centerWidth,
            centerHeight: key.centerHeight,
            xPivot: key.xPivot,
            yPivot: key.yPivot,
            frame: key.frame.clone(),
        }
    }
}

@:using(madolib.heaps.assets.Aseprite.SliceExt)
typedef Slice = {
    has9Slices: Bool,
    hasPivot: Bool,
    keys: Array<SliceKey>,
    name: String,
}

private class SliceExt {
    public inline static function clone(slice: Slice): Slice {
        return {
            has9Slices: slice.has9Slices,
            hasPivot: slice.hasPivot,
            keys: slice.keys.map(key -> key.clone()),
            name: slice.name,
        }
    }
}

@:using(madolib.heaps.assets.Aseprite.TagExt)
typedef Tag = {
    name: String,
    startFrame: Int,
    endFrame: Int,
    animationDirection: Int,
    frames: Array<AsepriteFrame>,
    slices: StringMap<Slice>,
}

private class TagExt {
    public inline static function clone(tag: Tag): Tag {
        return {
            name: tag.name,
            startFrame: tag.startFrame,
            endFrame: tag.endFrame,
            animationDirection: tag.animationDirection,
            frames: tag.frames.map(frame -> frame.clone()),
            slices: tag.slices.mapValues(slice -> slice.clone()),
        }
    }
}

class Aseprite {
    public final tile: h2d.Tile;

    final width: Int;
    final height: Int;
    final widthInTiles: Int;
    final heightInTiles: Int;
    final rawFrames: Array<aseprite.Frame>;

    var frames: Array<AsepriteFrame> = [];
    var tiles: Array<h2d.Tile> = [];
    final slices = new StringMap<Slice>();
    final tags = new StringMap<Tag>();

    public function new(ase: aseprite.Aseprite) {
        tile = ase.toTile();
        final data = ase.toData();

        width = data.width;
        height = data.height;
        widthInTiles = data.widthInTiles;
        heightInTiles = data.heightInTiles;
        rawFrames = data.frames;

        init(ase);
    }

    inline function init(ase: aseprite.Aseprite) {
        initTiles();
        initFrames();
        initSlices(ase);
        initTags(ase);
    }

    inline function initTiles() {
        tiles = [
            for(i in 0...rawFrames.length) {
                final x = i % widthInTiles;
                final y = Std.int(i / widthInTiles);
                tile.sub(x * width, y * height, width, height);
            }
        ];
    }

    inline function initFrames() {
        frames = [
            for(frame in rawFrames)
                {
                    index: frame.index,
                    tile: tiles[frame.index],
                    duration: frame.duration,
                }
        ];
    }

    inline function initSlices(ase: aseprite.Aseprite) {
        for(slice in ase.slices) {
            final keys: Array<SliceKey> = [];
            for(frame in 0...frames.length) {
                final sliceKey = getSliceKey(slice, frame);
                if(sliceKey == null) continue;
                final tile = tiles[frame].sub(
                    sliceKey.xOrigin,
                    sliceKey.yOrigin,
                    sliceKey.width,
                    sliceKey.height,
                    -sliceKey.xPivot,
                    -sliceKey.yPivot,
                );

                keys.push({
                    xOrigin: sliceKey.xOrigin,
                    yOrigin: sliceKey.yOrigin,
                    width: sliceKey.width,
                    height: sliceKey.height,
                    xCenter: sliceKey.xCenter,
                    yCenter: sliceKey.yCenter,
                    centerWidth: sliceKey.centerWidth,
                    centerHeight: sliceKey.centerHeight,
                    xPivot: sliceKey.xPivot,
                    yPivot: sliceKey.yPivot,
                    frame: {
                        index: frame,
                        duration: frames[frame].duration,
                        tile: tile,
                    }
                });
            }
            final newSlice: Slice = {
                has9Slices: slice.has9Slices,
                hasPivot: slice.hasPivot,
                keys: keys,
                name: slice.name,
            }
            slices.set(newSlice.name, newSlice);
        }
    }

    function initTags(ase: aseprite.Aseprite) {
        for(tag in ase.tags) {
            final tagFrames: Array<AsepriteFrame> = [];

            if(tag.startFrame == tag.endFrame) {
                tagFrames.push(frames[tag.startFrame].clone());
            } else {
                switch(tag.animationDirection) {
                    case AnimationDirection.FORWARD:
                        for(i in tag.startFrame...tag.endFrame + 1) {
                            tagFrames.push(frames[i].clone());
                        }
                    case AnimationDirection.REVERSE:
                        var i = tag.endFrame;
                        while(i >= tag.startFrame) {
                            tagFrames.push(frames[i].clone());
                            i--;
                        }
                    case AnimationDirection.PING_PONG:
                        var i = tag.startFrame;
                        var advance = true;
                        while(i > tag.startFrame || advance) {
                            tagFrames.push(frames[i].clone());
                            if(advance && i >= tag.endFrame) advance = false;
                            i += if(advance) 1 else -1;
                        }
                }
            }

            final tagSlices = new StringMap();
            for(slice in slices) {
                final newKeys = [];
                function addAnimation(frame: Int) {
                    newKeys.push(slice.keys[frame].clone());
                }
                if(tag.startFrame == tag.endFrame) {
                    addAnimation(tag.startFrame);
                } else {
                    switch(tag.animationDirection) {
                        case AnimationDirection.FORWARD:
                            for(i in tag.startFrame...tag.endFrame + 1) {
                                addAnimation(i);
                            }
                        case AnimationDirection.REVERSE:
                            var i = tag.endFrame;
                            while(i >= tag.startFrame) {
                                addAnimation(i);
                                i--;
                            }
                        case AnimationDirection.PING_PONG:
                            var i = tag.startFrame;
                            var advance = true;
                            while(i > tag.startFrame || advance) {
                                addAnimation(i);
                                if(advance && i >= tag.endFrame) advance = false;
                                i += if(advance) 1 else -1;
                            }
                    }
                }
                final newSlice = slice.clone();
                newSlice.keys = newKeys;
                tagSlices.set(slice.name, newSlice);
            }

            tags.set(tag.name, {
                name: tag.name,
                startFrame: tag.startFrame,
                endFrame: tag.endFrame,
                animationDirection: tag.animationDirection,
                frames: tagFrames,
                slices: tagSlices,
            });
        }
    }

    inline function getSliceKey(slice: aseprite.Slice, frame: Int) {
        var sliceKey = null;
        var i = slice.keys.length;
        while(i > 0) {
            i--;
            if(frame >= slice.keys[i].frameNumber) {
                sliceKey = slice.keys[i];
                break;
            }
        }
        return sliceKey;
    }

    inline function getSliceWithName(name: String): Slice {
        final slice = slices.get(name);
        if(slice == null) {
            throw 'A slice named "${name}" does not exist.';
        }
        return slice;
    }

    public inline function getFrame(frame: Int): AsepriteFrame {
        if(frame < 0 || frame >= frames.length) {
            throw 'Frame index out of bounds: ${frame}';
        }
        return frames[frame].clone();
    }

    public inline function getFrames(): Array<AsepriteFrame> {
        return frames.map(frame -> frame.clone());
    }

    public inline function getSlice(name: String, frames: Int = 0): AsepriteFrame {
        final slice = getSliceWithName(name);
        return slice.keys[frames].frame.clone();
    }

    public inline function getSlices(name: String): Array<AsepriteFrame> {
        final slice = getSliceWithName(name);
        return slice.keys.map(key -> key.frame.clone());
    }

    static final instances = new StringMap<Aseprite>();

    public inline static function load(res: aseprite.res.Aseprite): Aseprite {
        return instances.withDefaultOrSet(res.entry.path, new Aseprite(res.toAseprite()));
    }

    public inline function toScaleGrid(name: String, frame: Int = 0) {
        final slice = slices.get(name);
        if(slice == null) {
            throw 'A slice named "${name}" does not exist.';
        }
        if(!slice.has9Slices) {
            throw 'Slice "${name}" does not have 9-Slices enabled.';
        }
        final key = slice.keys[frame];

        return new ScaleGrid(tile.sub(key.xOrigin, key.yOrigin, key.width, key.height, -key.xPivot, -key.yPivot), key.xCenter, key.yCenter);
    }

    public inline function toBitmap(): Bitmap {
        return new Bitmap(getFrame(0).tile);
    }

    inline static function getCollisionBounds(baseSlice: SliceKey, ?colSlice: SliceKey, flipX: Bool = false, flipY: Bool = false): Bounds
        return if(colSlice == null) {
            new Bounds(
                baseSlice.xOrigin,
                baseSlice.yOrigin,
                baseSlice.width,
                baseSlice.height,
            );
        } else {
            final padLeft = colSlice.xOrigin - baseSlice.xOrigin;
            final padTop = colSlice.yOrigin - baseSlice.yOrigin;
            final padRight = baseSlice.width - (padLeft + colSlice.width);
            final padBottom = baseSlice.height - (padTop + colSlice.height);
            final x = if(flipX) padRight else padLeft;
            final y = if(flipY) padBottom else padTop;
            new Bounds(x, y, colSlice.width, colSlice.height);
        }

    public inline function getCollisions(sliceName: String, ?collisionSliceName: String, flipX: Bool = false, flipY: Bool = false): Array<Bounds> {
        if(!slices.exists(sliceName)) return [];
        final baseSlice = getSliceWithName(sliceName).keys[0];
        final colSliceName = collisionSliceName ?? '${sliceName}-Col';
        final colNames = slices.keys().toArray().filter(k -> k.indexOf(colSliceName) == 0);
        return if(colNames.length == 0) {
            [getCollisionBounds(baseSlice, null, flipX, flipY)];
        } else {
            colNames.map(colName -> {
                final colSlice = getSliceWithName(colName).keys[0];
                getCollisionBounds(baseSlice, colSlice, flipX, flipY);
            });
        }
    }

    public inline function getCollision(sliceName: String, ?collisionSliceName: String, flipX: Bool = false, flipY: Bool = false): Option<Bounds> {
        if(!slices.exists(sliceName)) return None;

        final baseSlice = getSliceWithName(sliceName).keys[0];
        final colSliceName = collisionSliceName ?? '${sliceName}-Col';
        final colSlice = getSliceWithName(colSliceName).keys[0];
        return Some(getCollisionBounds(baseSlice, colSlice, flipX, flipY));
    }
}
