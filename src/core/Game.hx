package core;

import kha.Assets;
import kha.Framebuffer;
import kha.Image;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;

interface IDestroyable {
    public var destroyed:Bool;
    public var x:Float;
    public var y:Float;
}

interface IUpdateable extends IDestroyable {
    public var active:Bool;
    public function update (time:Float):Void;
}

interface IRenderable extends IDestroyable {
    public var visible:Bool;
    public function render (g2:Graphics, cam:Camera):Void;
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

// is this necessary?
interface GameObject extends IUpdateable extends IRenderable {
    public var sizeX:Int;
    public var sizeY:Int;
}

// a selection of an image. not rotatable or scalable (presently)
class Sprite implements GameObject {
    public var destroyed:Bool = false;

    public var active:Bool = true;
    public var visible:Bool = true;

    public var x:Float;
    public var y:Float;
    public var sizeX:Int;
    public var sizeY:Int;
    public var tileIndex:Int = 0;
    var flipX:Bool = false;
    var flipY:Bool = false;

    public var image:Image;

    public function new (x:Float = 0.0, y:Float = 0.0, image:Image, ?sizeX:Int, ?sizeY:Int) {
        this.x = x;
        this.y = y;
        this.sizeX = sizeX ?? image.height;
        this.sizeY = sizeY ?? image.width;
        this.image = image;
    }

    public function update (delta:Float) {}

    public function render (g2:Graphics, camera:Camera) {
        // TODO: null check image? we need one, correct?
        // load placeholder? use asset filter in the beginning?

        // g2.color = Math.floor(alpha * 256) * 0x1000000 + color;

        // rotate, translate, then scale
        // g2.pushRotation(toRadians(angle), getMidpoint().x, getMidpoint().y);
        // g2.pushTranslation(-camera.scroll.x * scrollFactor.x, -camera.scroll.y * scrollFactor.y);
        // g2.pushScale(camera.scale.x, camera.scale.y);

        // draw a cutout of the spritesheet based on the tileindex
        final cols = Std.int(image.width / sizeX);
        // TODO: clamp all to int besides camera position
        // g2.drawScaledSubImage(
        //     image,
        //     (tileIndex % cols) * size.x,
        //     Math.floor(tileIndex / cols) * size.y,
        //     size.x,
        //     size.y,
        //     x + ((size.x - size.x * scale.x) / 2) + (flipX ? size.x * scale.x : 0),
        //     y + ((size.y - size.y * scale.y) / 2) + (flipY ? size.y * scale.y : 0),
        //     size.x * scale.x * (flipX ? -1 : 1),
        //     size.y * scale.y * (flipY ? -1 : 1)
        // );
        g2.drawSubImage(
            image,
            x + (flipX ? sizeX : 0),
            y + (flipY ? sizeY : 0),
            (tileIndex % cols) * sizeX,
            Math.floor(tileIndex / cols) * sizeY,
            sizeX,
            sizeY
        );

        // g2.popTransformation();
        // g2.popTransformation();
        // g2.popTransformation();
    }
}

class SprItem extends Sprite {
    override function render (g2:Graphics, cam:Camera) {
        g2.drawImage(image, x, y);
    }
}

class Camera {
    public var bgColor:Int = 0xff000000;
    public function new () {}
}

class Scene {
    // convenience helper, not always
    public var entities:Array<GameObject> = [];

    public var camera:Camera;

    public function new () {}

    public function create () {
        camera = new Camera();
    }

    public function update (time:Float) {
        for (s in entities) { s.update(time); }
    }

    // called when drawing, passes in graphics instance
    // overriding render will require you to call begin, clear and end
    // public function render (graphics:Graphics, g4:kha.graphics4.Graphics, clears:Bool) {
    public function render (graphics:Graphics, clears:Bool) {
        graphics.begin(clears, camera.bgColor);

        for (sprite in entities) {
            sprite.render(graphics, camera);
        }

// #if debug_physics
//         for (sprite in entities) {
//             sprite.renderDebug(graphics, camera);
//         }
// #end
        graphics.end();
    }
}

class TestScene extends Scene {
    override function create () {
        super.create();

        trace('test');

        final spr = new SprItem(20, 20, Assets.images.cat);

        entities.push(spr);
    }
}

enum ScaleMode {
    Full;
    PixelPerfect;
}

class Game {
    static inline final UPDATE_TIME:Float = 1 / 60;

    // time since start, set by the scheduler
    var currentTime:Float;

    // Size of the game.
    public var width:Int;
    public var height:Int;

    // Size of the buffer.
    public var bufferWidth:Int;
    public var bufferHeight:Int;

    // The backbuffer being drawn on to be scaled.  Not used in scaleMode `Fit`.
    var backbuffer:Image;

    // array of scenes to update and render
    var scenes:Array<Scene> = [];

    public function new (name:String, width:Int, height:Int, scaleMode:ScaleMode, ?bufferWidth:Int, ?bufferHeight:Int) {
        // size = IntVec2.make(width, height)
        this.width = width;
        this.height = height;

        System.start({ title: name, width: width, height: height }, (_window) -> {
            if (scaleMode == PixelPerfect) {
                if (bufferWidth == null || bufferHeight == null) {
                    throw 'Need buffer size';
                }

                backbuffer = Image.createRenderTarget(bufferWidth, bufferHeight);
                // backbuffer.g2.imageScaleQuality = Low;
                this.bufferWidth = bufferWidth;
                this.bufferHeight = bufferHeight;
            } else {
                bufferWidth = -1;
                bufferHeight = -1;
            }

            Scheduler.addTimeTask(update, 0, UPDATE_TIME);

            if (scaleMode == PixelPerfect) {
                System.notifyOnFrames((frames) -> { renderPixelPerfect(frames[0]); });
            } else {
                System.notifyOnFrames((frames) -> { render(frames[0]); });
            }

            Assets.loadEverything(() -> {
                final scene = new TestScene();
                scene.create();
                scenes.push(scene);
            });
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
        setSize(framebuffer.width, framebuffer.height);

        for (s in 0...scenes.length) {
            scenes[s].render(framebuffer.g2, /* framebuffer.g4 */ s == 0);
        }
    }

    function renderPixelPerfect (framebuffer:Framebuffer) {
        setSize(framebuffer.width, framebuffer.height);

        for (s in 0...scenes.length) {
            // scenes[s].render(backbuffer.g2, backbuffer.g4, s == 0);
            scenes[s].render(backbuffer.g2, s == 0);
        }

        framebuffer.g2.begin(true, 0xff000000);
            // framebuffer.g2.pipeline = fullScreenPipeline;
            ScalerExp.scalePixelPerfect(backbuffer, framebuffer);
        framebuffer.g2.end();
    }

    inline function setSize (x:Int, y:Int) {
        width = x;
        height = y;
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
