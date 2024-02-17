package madolib.heaps.extensions;

import madolib.geom.Bounds;
import madolib.heaps.node.BoxCollider;

class ColExt {
    public inline static function createBoxCollider(self: Bounds): BoxCollider
        return new BoxCollider(self.left, self.top, self.width, self.height);

    public inline static function createBoxColliders(self: Array<Bounds>): Array<BoxCollider>
        return self.map(createBoxCollider);
}
