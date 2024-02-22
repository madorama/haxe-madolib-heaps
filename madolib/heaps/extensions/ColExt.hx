package madolib.heaps.extensions;

import madolib.geom.Bounds;
import madolib.heaps.node.BoxCollider;
import madolib.heaps.node.Collider;

class ColExt {
    public inline static function createBoxCollider(self: Bounds): Collider
        return new BoxCollider(self.left, self.top, self.width, self.height);

    public inline static function createBoxColliders(self: Array<Bounds>): Array<Collider>
        return self.map(createBoxCollider);
}
