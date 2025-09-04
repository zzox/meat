package game.scenes;

import core.Game;
import core.scene.Scene;
import kha.input.KeyCode;

class GameScene extends Scene {
    override function create () {
        super.create();
        camera.bgColor = 0xffff00ff;
    }

    override function update (delta:Float) {
        if (Game.keys.pressed(KeyCode.Left)) {
            camera.bgColor = 0xffffff00;
        }
        if (Game.keys.pressed(KeyCode.Right)) {
            camera.bgColor = 0xffffffff;
        }
        if (Game.keys.pressed(KeyCode.Up)) {
            camera.bgColor = 0xff00ffff;
        }
        if (Game.keys.pressed(KeyCode.Down)) {
            camera.bgColor = 0xff0000ff;
        }

        super.update(delta);
    }
}
