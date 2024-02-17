package madolib.heaps;

interface Updatable {
    private function update(dt: Float): Void;
    private function fixedUpdate(): Void;
    private function afterUpdate(dt: Float): Void;
}
