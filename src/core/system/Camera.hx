package core.system;

class Camera extends System {
    public var bgColor:Int = 0xff000000;

    public var width:Int;
    public var height:Int;

    public function new (width:Int, height:Int) {
        super();
        this.width = width;
        this.height = height;
    }
}
