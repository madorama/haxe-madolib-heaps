package madolib.heaps;

import haxe.ds.StringMap;
import hx.potpack.Potpack;
import hx.potpack.geom.PotpackRectangle;
import hxd.Pixels;
import hxmath.geom.Rect;
import madolib.extensions.IntExt;
import madolib.heaps.assets.Aseprite;

using madolib.extensions.ArrayExt;
using madolib.extensions.MapExt;

private typedef Frame = {
    index: Int,
    duration: Int,
    tile: h2d.Tile,
    rect: Rect,
}

private typedef AseData = {
    aseprite: Aseprite,
    slices: StringMap<Slice>,
    tags: StringMap<Tag>,
}

private typedef TilesetArea = {
    tile: h2d.Tile,
    rect: PotpackRectangle,
    rects: Array<Rect>,
    tiles: Array<h2d.Tile>,
    frames: Array<Frame>,
    ?ase: AseData,
}

class Tileset {
    final rawTile: h2d.Tile = h2d.Tile.fromColor(0);

    final areas = new StringMap<TilesetArea>();

    public function new() {}

    function packing() {
        final areaMap = areas.toArray().map(tuple -> {
            return {
                id: tuple.left,
                area: tuple.right,
            }
        });
        final rectVector = new haxe.ds.Vector(areaMap.length);
        for(i => area in areaMap) {
            rectVector[i] = area.area.rect;
        }

        final packData = Potpack.pack(rectVector);
        final rectArray = rectVector.toArray();

        rawTile.setSize(packData.width, packData.height);
        rawTile.getTexture().resize(packData.width, packData.height);

        final pixels = Pixels.alloc(packData.width, packData.height, RGBA);
        for(i => rect in rectArray) {
            final tile = areaMap[i].area.tile;
            pixels.blit(
                Std.int(rect.x),
                Std.int(rect.y),
                tile.getTexture().capturePixels(),
                0,
                0,
                tile.iwidth,
                tile.iheight
            );
        }
        rawTile.switchTexture(h2d.Tile.fromPixels(pixels));

        for(i => rect in rectArray) {
            areaMap[i].area.rect = rect;
            areas.set(areaMap[i].id, areaMap[i].area);
        }
    }

    function calcAllTiles() {
        for(i => area in areas) {
            area.tiles = area.rects.map(r -> rawTile.sub(area.rect.x + r.x, area.rect.y + r.y, r.width, r.height));

            area.frames = area.frames.map(frame -> {
                return {
                    index: frame.index,
                    tile: rawTile.sub(area.rect.x + frame.rect.x, area.rect.y + frame.rect.y, frame.rect.width, frame.rect.height),
                    duration: frame.duration,
                    rect: frame.rect,
                }
            });

            if(area.ase == null) continue;
            final aseData = area.ase;

            aseData.slices = @:privateAccess aseData.aseprite.slices.mapValues(slice -> {
                final s = slice.clone();
                for(key in s.keys) {
                    key.frame.tile = rawTile.sub(
                        area.rect.x + key.frame.tile.x,
                        area.rect.y + key.frame.tile.y,
                        key.frame.tile.width,
                        key.frame.tile.height
                    );
                }
                return s;
            });

            aseData.tags = @:privateAccess aseData.aseprite.tags.mapValues(tag -> {
                final t = tag.clone();
                for(frame in t.frames) {
                    frame.tile = rawTile.sub(
                        area.rect.x + frame.tile.x,
                        area.rect.y + frame.tile.y,
                        frame.tile.width,
                        frame.tile.height
                    );
                }
                for(slice in t.slices) {
                    for(key in slice.keys) {
                        key.frame.tile = rawTile.sub(
                            area.rect.x + key.frame.tile.x,
                            area.rect.y + key.frame.tile.y,
                            key.frame.tile.width,
                            key.frame.tile.height
                        );
                    }
                }
                return t;
            });
        }
    }

    public function add(id: String, tile: h2d.Tile, ?rects: Array<Rect>) {
        final rects = rects ?? [];

        final area: TilesetArea = {
            tile: tile,
            rect: new PotpackRectangle(0, 0, tile.width, tile.height),
            rects: rects,
            tiles: [],
            frames: [],
            ase: null,
        };
        areas.set(id, area);
        packing();
        calcAllTiles();
    }

    public function addAsepriteAtlas(id: String, ase: Aseprite) {
        final tile = ase.tile;
        final area: TilesetArea = {
            tile: tile,
            rect: new PotpackRectangle(0, 0, tile.width, tile.height),
            rects: [],
            tiles: [],
            frames: [],
            ase: {
                aseprite: ase,
                slices: new StringMap(),
                tags: new StringMap(),
            },
        }
        areas.set(id, area);
        packing();

        area.frames = ase.getFrames().map(frame -> {
            return {
                index: frame.index,
                tile: rawTile.sub(area.rect.x + frame.tile.x, area.rect.y + frame.tile.y, frame.tile.width, frame.tile.height),
                duration: frame.duration,
                rect: new Rect(frame.tile.x, frame.tile.y, frame.tile.width, frame.tile.height),
            }
        });

        calcAllTiles();
    }

    inline function getArea(id: String): TilesetArea {
        final areas = areas.get(id);
        if(areas == null) {
            throw 'Area not found: $id';
        }
        return areas;
    }

    inline function getAseData(id: String): AseData {
        final area = getArea(id);
        if(area.ase == null) {
            throw 'Aseprite not found: $id';
        }
        return area.ase;
    }

    public function getTile(id: String, tileIndex: Int): h2d.Tile {
        final area = getArea(id);
        return area.tiles[tileIndex];
    }

    public function addRect(id: String, rect: Rect) {
        final area = getArea(id);
        area.rects.push(rect);
        calcAllTiles();
    }

    public function addFrame(id: String, frames: Array<{index: Int, duration: Int, rect: Rect}>) {
        final area = getArea(id);
        area.frames = area.frames.concat(
            frames.map(frame -> {
                return {
                    index: frame.index,
                    tile: rawTile.sub(area.rect.x + frame.rect.x, area.rect.y + frame.rect.y, frame.rect.width, frame.rect.height),
                    rect: frame.rect,
                    duration: frame.duration,
                }
            })
        ).sorted((a, b) -> IntExt.compare(a.index, b.index));
    }

    public inline function getFrames(id: String): Array<Frame> {
        final area = getArea(id);
        return area.frames;
    }

    public function getSlice(id: String, sliceName: String, frames: Int = 0): AsepriteFrame {
        final ase = getAseData(id);
        final slice = ase.slices.get(sliceName);
        if(slice == null) {
            throw 'Slice not found: ${sliceName}';
        }
        return slice.keys[frames].frame.clone();
    }

    public function getSlices(id: String, sliceName: String): Array<AsepriteFrame> {
        final ase = getAseData(id);
        final slice = ase.slices.get(sliceName);
        if(slice == null) {
            throw 'Slice not found: ${sliceName}';
        }
        return slice.keys.map(key -> key.frame.clone());
    }

    public function getTag(id: String, tagName: String, ?sliceName: String): Array<AsepriteFrame> {
        final ase = getAseData(id);
        final tag = ase.tags.get(tagName);
        if(tag == null) {
            throw 'Tag not found: ${tagName}';
        }

        return if(sliceName == null) {
            tag.frames;
        } else {
            final slice = tag.slices.get(sliceName);
            if(slice == null) {
                throw 'Slice not found: ${sliceName}';
            }
            return slice.keys.map(key -> key.frame.clone());
        }
    }
}
