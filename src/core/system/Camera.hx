package core.system;

class Camera {
    public var bgColor:Int = 0xff000000;

    public var width:Int;
    public var height:Int;

    public function new (width:Int, height:Int) {
        this.width = width;
        this.height = height;
    }
}
