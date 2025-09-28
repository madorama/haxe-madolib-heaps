package madolib.heaps;

using madolib.extensions.ArrayExt;

@:access(madolib.heaps.SceneTree)
@:allow(madolib.heaps.App)
class SceneManager {
    static final scenes: Array<SceneTree> = [];

    public static var currentScene(get, never): SceneTree;

    inline static function get_currentScene(): SceneTree {
        if(scenes.isEmpty()) {
            throw "empty scenes";
        }
        return scenes[scenes.length - 1];
    }

    static var pushReservedScenes: Array<SceneTree> = [];
    static var popReservedScenes: Array<SceneTree> = [];

    public inline static function push(scene: SceneTree, pausePrevScene: Bool = false) {
        pushReservedScenes.push(scene);

        if(pausePrevScene) currentScene.pause();
    }

    public inline static function pop() {
        if(scenes.length > 0) {
            final scene = scenes.pop();
            if(scene != null) popReservedScenes.push(scene);
        }
    }

    public inline static function clear() {
        while(scenes.length > 0)
            pop();
    }

    inline static function update(dt: Float) {
        for(scene in scenes) {
            scene.doUpdate(dt);
        }

        for(s in popReservedScenes) {
            s.dispose();
            scenes.remove(s);
        }
        popReservedScenes.resize(0);

        for(s in pushReservedScenes) {
            scenes.push(s);
        }
        pushReservedScenes.resize(0);
    }

    inline static function fixedUpdate() {
        for(scene in scenes) {
            scene.doFixedUpdate();
        }
    }

    inline static function afterUpdate(dt: Float) {
        for(scene in scenes) {
            scene.doAfterUpdate(dt);
        }
    }

    inline static function onResize() {
        for(scene in scenes) {
            scene.onResize();
        }
    }

    public inline static function pause<T: SceneTree>(sceneType: Class<T>) {
        final scene = scenes.find(s -> Std.isOfType(s, sceneType));
        scene?.pause();
    }

    public inline static function resume<T: SceneTree>(sceneType: Class<T>) {
        final scene = scenes.find(s -> Std.isOfType(s, sceneType));
        scene?.resume();
    }
}
