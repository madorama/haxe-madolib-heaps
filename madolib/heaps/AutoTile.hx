package madolib.heaps;

import h2d.Tile;
import hxd.Pixels;

/**
 * Inspired: https://qiita.com/ruccho_vector/items/fcd8ecea1538d0864283
 */
class AutoTile {
    final size: Int;
    final tile: Tile;

    public var animNum(default, null): Int = 1;

    public var autoTile(default, null): Tile = Tile.fromColor(0);

    static final patterns = [
        [0, 2, 1, 4],
        [2, 2, 4, 4],
        [2, 0, 4, 1],
        [2, 2, 3, 4],
        [2, 2, 4, 3],
        [3, 4, 4, 4],
        [4, 3, 4, 4],
        [0, 0, 1, 1],
        [1, 4, 1, 4],
        [4, 4, 4, 4],
        [4, 1, 4, 1],
        [1, 4, 1, 3],
        [4, 1, 3, 1],
        [4, 4, 3, 4],
        [4, 4, 4, 3],
        [1, 1, 1, 1],
        [1, 4, 0, 2],
        [4, 4, 2, 2],
        [4, 1, 2, 0],
        [1, 3, 1, 4],
        [3, 1, 4, 1],
        [3, 4, 4, 3],
        [4, 3, 3, 4],
        [1, 1, 0, 0],
        [0, 2, 1, 3],
        [2, 2, 3, 3],
        [2, 0, 3, 1],
        [3, 4, 2, 2],
        [4, 3, 2, 2],
        [4, 3, 3, 3],
        [3, 4, 3, 3],
        [4, 4, 3, 3],
        [1, 3, 1, 3],
        [3, 3, 3, 3],
        [3, 1, 3, 1],
        [4, 3, 4, 3],
        [3, 4, 3, 4],
        [3, 3, 4, 3],
        [3, 3, 3, 4],
        [3, 3, 4, 4],
        [1, 3, 0, 2],
        [3, 3, 2, 2],
        [3, 1, 2, 0],
        [0, 2, 0, 2],
        [2, 2, 2, 2],
        [2, 0, 2, 0],
        [0, 0, 0, 0]
    ];

    static final patternNums = [
        [-1, 0, -1, 1, 1, 1, -1, 0],
        [-1, 1, 1, 1, 1, 1, -1, 0],
        [-1, 1, 1, 1, -1, 0, -1, 0],
        [-1, 1, 0, 1, 1, 1, -1, 0],
        [-1, 1, 1, 1, 0, 1, -1, 0],
        [0, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 0, 1],
        [-1, 0, -1, 1, -1, 0, -1, 0],
        [-1, 0, -1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, -1, 0, -1, 1],
        [-1, 0, -1, 1, 0, 1, 1, 1],
        [1, 1, 0, 1, -1, 0, -1, 1],
        [1, 1, 0, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 0, 1, 1, 1],
        [-1, 0, -1, 1, -1, 0, -1, 1],
        [-1, 0, -1, 0, -1, 1, 1, 1],
        [1, 1, -1, 0, -1, 1, 1, 1],
        [1, 1, -1, 0, -1, 0, -1, 1],
        [-1, 0, -1, 1, 1, 1, 0, 1],
        [0, 1, 1, 1, -1, 0, -1, 1],
        [0, 1, 1, 1, 0, 1, 1, 1],
        [1, 1, 0, 1, 1, 1, 0, 1],
        [-1, 0, -1, 0, -1, 0, -1, 1],
        [-1, 0, -1, 1, 0, 1, -1, 0],
        [-1, 1, 0, 1, 0, 1, -1, 0],
        [-1, 1, 0, 1, -1, 0, -1, 0],
        [0, 1, -1, 0, -1, 1, 1, 1],
        [1, 1, -1, 0, -1, 1, 0, 1],
        [1, 1, 0, 1, 0, 1, 0, 1],
        [0, 1, 0, 1, 0, 1, 1, 1],
        [1, 1, 0, 1, 0, 1, 1, 1],
        [-1, 0, -1, 1, 0, 1, 0, 1],
        [0, 1, 0, 1, 0, 1, 0, 1],
        [0, 1, 0, 1, -1, 0, -1, 1],
        [1, 1, 1, 1, 0, 1, 0, 1],
        [0, 1, 0, 1, 1, 1, 1, 1],
        [0, 1, 1, 1, 0, 1, 0, 1],
        [0, 1, 0, 1, 1, 1, 0, 1],
        [0, 1, 1, 1, 1, 1, 0, 1],
        [-1, 0, -1, 0, -1, 1, 0, 1],
        [0, 1, -1, 0, -1, 1, 0, 1],
        [0, 1, -1, 0, -1, 0, -1, 1],
        [-1, 0, -1, 0, -1, 1, -1, 0],
        [-1, 1, -1, 0, -1, 1, -1, 0],
        [-1, 1, -1, 0, -1, 0, -1, 0],
        [-1, 0, -1, 0, -1, 0, -1, 0],
    ];

    public function new(tile: Tile, size: Int) {
        this.tile = tile;
        this.size = size;

        generatePatterns();
    }

    public function generatePatterns() {
        final halfSize = Math.floor(size / 2);

        function combinePixels(typeIndex: Array<Int>, animFrame: Int): Pixels {
            final fixedArray = [
                typeIndex[2],
                typeIndex[3],
                typeIndex[0],
                typeIndex[1]
            ];

            final p = Pixels.alloc(size, size, hxd.PixelFormat.RGBA);
            final pixels = tile.getTexture().capturePixels();
            for(i in 0...4) {
                final dx = i % 2 * halfSize;
                final dy = Std.int(i / 2) * halfSize;
                final sx = dx + animFrame * size;
                final sy = dy + fixedArray[i] * size;
                p.blit(dx, dy, pixels, sx, sy, halfSize, halfSize);
            }

            return p;
        }

        animNum = Std.int(tile.width / size);
        final autoTilePixels = Pixels.alloc(size * patterns.length, size * animNum, hxd.PixelFormat.RGBA);
        for(animId in 0...animNum) {
            for(i => p in patterns) {
                autoTilePixels.blit(i * size, animId * size, combinePixels(p, animId), 0, 0, size, size);
            }
        }
        autoTile = Tile.fromPixels(autoTilePixels);
    }

    public inline static function getIndex(neighbors: Array<Bool>): Int {
        final lt = neighbors[0];
        final t = neighbors[1];
        final rt = neighbors[2];
        final l = neighbors[3];
        final r = neighbors[4];
        final lb = neighbors[5];
        final b = neighbors[6];
        final rb = neighbors[7];
        return calcIndex(Math.makeBitsFromBools(b, rb, r, rt, t, lt, l, lb));
    }

    static function calcIndex(mask: UInt): Int {
        for(j in 0...patternNums.length) {
            var flag = true;
            for(i in 0...8) {
                final pattern = patternNums[j][i];
                if(pattern == -1)
                    continue;
                final currentMask = if(mask & Std.int(Math.pow(2, 7 - i)) != 0) 1 else 0;
                if(pattern != currentMask) {
                    flag = false;
                    break;
                }
            }
            if(flag)
                return j;
        }
        return -1;
    }

    public inline function getTile(id: Int, animFrame: Int): Tile
        return autoTile.sub(id * size, animFrame * size, size, size);
}
