package core;

import kha.Assets;
import kha.Framebuffer;
import kha.Image;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;

// don't know about this
interface IDestroyable {
    public var destroyed:Bool;
}

interface IUpdateable extends IDestroyable {
    public var active:Bool;
    public function update (time:Float):Void;
}

interface IRenderable extends IDestroyable {
    public var visible:Bool;
    public function render (g2:Graphics):Void;
}

class IntVec2 {
    public static inline function make (x:Int, y:Int) {
        // TODO: pooling
        return new IntVec2(x, y);
    }

    public var x:Int;
    public var y:Int;

    public function new (x:Int, y:Int) {
        set(x, y);
    }

    public function set (x:Int, y: Int) {
        this.x = x;
        this.y = y;
    }
}

interface ISprite extends IUpdateable extends IRenderable {
    var x:Float;
    var y:Float;
}

class Sprite implements ISprite {
    public var destroyed:Bool = false;

    public var active:Bool = true;
    public var visible:Bool = true;

    public var x:Float;
    public var y:Float;
    public var sizeX:Int;
    public var sizeY:Int;
    public var tileIndex:Int;

    public var image:Image;

    public function new (x:Float = 0.0, y:Float = 0.0, image:Image, ?sizeX:Int, ?sizeY:Int) {
        this.x = x;
        this.y = y;
        this.sizeX = sizeX ?? image.height;
        this.sizeY = sizeY ?? image.width;
        this.image = image;
    }

    public function update (delta:Float) {}
    public function render (g2:Graphics) {}
}

class SprItem extends Sprite {
    override function render (g2:Graphics) {
        g2.drawImage(image, x, y);
    }
}

class Scene {
    // convenience helper, not always
    public var sprites:Array<Sprite> = [];

    public function new () {}

    public function create () {}

    public function update (time:Float) {
        for (s in sprites) { s.update(time); }
    }

    public function render (g2:Graphics) {
        for (s in sprites) s.render(g2);
    }
}

class TestScene extends Scene {
    override function create () {
        trace('test');

        final spr = new SprItem(20, 20, Assets.images.cat);

        sprites.push(spr);
    }
}

class Game {
    static inline final UPDATE_TIME:Float = 1 / 60;

    // time since start, set by the scheduler
    var currentTime:Float;

    var size:IntVec2;

    var scenes:Array<Scene> = [];

    public function new (name:String, width:Int, height:Int) {
        size = IntVec2.make(width, height);

        System.start({ title: name, width: width, height: height }, (_window) -> {
            // bufferSize = initialSize != null ? initialSize : size;
            // bufferSize = ;
            // backbuffer = Image.createRenderTarget(width, height);

            // if (scaleMode != Full) {
            //     backbuffer = Image.createRenderTarget(bufferSize.x, bufferSize.y);
            //     backbuffer.g2.imageScaleQuality = Low;
            // }

            Scheduler.addTimeTask(update, 0, UPDATE_TIME);

            // Scheduler.addTimeTask(
            //     () -> {
            //         update(); } catch (e) { exceptionHandler(e); }
            //     },
            //     0,
            //     UPDATE_TIME
            // );

            System.notifyOnFrames((frames) -> { render(frames[0]); });

            // if (scaleMode == Full) {
            //     System.notifyOnFrames((frames) -> {
            //         try { render(frames[0]); } catch (e) { exceptionHandler(e); }
            //     });
            // } else {
            //     System.notifyOnFrames(
            //         (frames) -> {
            //             try { renderScaled(frames[0]); } catch (e) { exceptionHandler(e); }
            //         }
            //     );
            // }

            function allAssets (_:Dynamic) return true;

            Assets.loadEverything(() -> {
                final scene = new TestScene();
                scene.create();
                scenes.push(scene);
            });

            // function allAssets (_:Dynamic) return true;

            // Assets.loadEverything(() -> {
            //     switchScene(initalScene);
            // }, null, compressedAudioFilter != null ? compressedAudioFilter : allAssets);
        });
    }

    function update () {
        final now = Scheduler.time();

#if atomic
        final delta = now - currentTime;
#else
        final delta = UPDATE_TIME;
#end

        for (s in scenes) {
            s.update(delta);
        }

        currentTime = now;
    }

    // function update () {
    //     final now = Scheduler.time();
    //     final delta = now - currentTime;

    //     // update mouse for camera position
    //     final camExists = scenes[0] != null;
    //     mouse.setMousePos(
    //         Std.int(
    //             (camExists ? scenes[0].camera.scroll.x : 0) + mouse.screenPos.x /
    //             (camExists ? scenes[0].camera.scale.x : 0)
    //         ),
    //         Std.int(
    //             (camExists ? scenes[0].camera.scroll.y : 0) + mouse.screenPos.y /
    //             (camExists ? scenes[0].camera.scale.y : 0)
    //         )
    //     );

    //     for (s in newScenes) scenes.push(s);
    //     newScenes = [];
    //     for (s in scenes) {
    //         if (!s.isPaused) {
    //             s.updateProgress(Assets.progress);
    //             s.update(UPDATE_TIME);
    //         }

    //         // resize the camera if we use the `Full` scale mode.
    //         if (scaleMode == Full) {
    //             s.camera.width = size.x;
    //             s.camera.height = size.y;
    //         }
    //     }
    //     scenes = scenes.filter((s) -> !s._destroyed);

    //     // after the scenes to clear `justPressed`
    //     keys.update(UPDATE_TIME);
    //     mouse.update(UPDATE_TIME);
    //     surface.update(UPDATE_TIME);
    //     for (g in gamepads.list) {
    //         g.update(UPDATE_TIME);
    //     }

    //     currentTime = now;
    // }

    function render (framebuffer:Framebuffer) {
        size.set(framebuffer.width, framebuffer.height);

        framebuffer.g2.begin(true);
        for (s in 0...scenes.length) {
            scenes[s].render(framebuffer.g2/*, framebuffer.g4, s == 0*/);
        }
        framebuffer.g2.end();
    }
}

// class OldGame {
//     public function new (
//         size:IntVec2,
//         initalScene:Scene,
//         scaleMode:ScaleMode = None,
//         name:String,
//         ?initialSize:IntVec2,
//         ?exceptionHandler:Exception -> Void,
//         ?compressedAudioFilter:Dynamic -> Bool
//     ) {
//         this.scaleMode = scaleMode;
//         this.size = size;

//         if (exceptionHandler == null) {
//             exceptionHandler = (e:Exception) -> throw e;
//         }

//         System.start({ title: name, width: size.x, height: size.y }, (_window) -> {
//             bufferSize = initialSize != null ? initialSize : size;
//             if (scaleMode != Full) {
//                 backbuffer = Image.createRenderTarget(bufferSize.x, bufferSize.y);
//                 backbuffer.g2.imageScaleQuality = Low;
//             }

//             // just the movement is PP or None, not `Full`
//             if (scaleMode == Full) {
//                 Mouse.get().notify(mouse.pressMouse, mouse.releaseMouse, mouse.mouseMove);
//                 Surface.get().notify(surface.press, surface.release, surface.move);
//             } else {
//                 // need to handle screen position and screen scale
//                 Mouse.get().notify(mouse.pressMouse, mouse.releaseMouse, onMouseMove);
//                 Surface.get().notify(surface.press, surface.release, onSurfaceMove);
//             }

//             // for WEGO
//             // Mouse.get().hideSystemCursor();

//             if (Keyboard.get() != null) {
//                 Keyboard.get().notify(keys.pressButton, keys.releaseButton);
//             }

//             for (i in 0...8) {
//                 if (Gamepad.get(i) != null && Gamepad.get(i).connected) {
//                     gamepadConnect(i);
//                 }
//             }

//             Gamepad.notifyOnConnect(gamepadConnect, gamepadDisconnect);

//             // Gamepad.removeConnect()

//             setFullscreenShader(makeBasePipelineShader());
//             setBackbufferShader(makeBasePipelineShader());

//             Assets.loadImage('made_with_kha', (_:Image) -> {
//                 switchScene(new PreloadScene());

//                 // HACK: run `update()` once to get preload scene from `newScenes` to `scenes`.
//                 // This kicks off the game.
//                 try { update(); } catch (e) { exceptionHandler(e); }

//                 Scheduler.addTimeTask(
//                     () -> {
//                         try { update(); } catch (e) { exceptionHandler(e); }
//                     },
//                     0,
//                     UPDATE_TIME
//                 );

//                 if (scaleMode == Full) {
//                     System.notifyOnFrames((frames) -> {
//                         try { render(frames[0]); } catch (e) { exceptionHandler(e); }
//                     });
//                 } else {
//                     System.notifyOnFrames(
//                         (frames) -> {
//                             try { renderScaled(frames[0]); } catch (e) { exceptionHandler(e); }
//                         }
//                     );
//                 }

//                 function allAssets (_:Dynamic) return true;

//                 Assets.loadEverything(() -> {
//                     switchScene(initalScene);
//                 }, null, compressedAudioFilter != null ? compressedAudioFilter : allAssets);
//             });
//         });
//     }
// }
