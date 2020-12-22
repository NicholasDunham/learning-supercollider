(
/* Coupling view and controller */

var window, knob, screen;

// A container window
window = Window.new("A knob", Rect.new(300, 300, 150, 100));
window.background = Color.black;

// A knob in the window, range: [0, 1]
knob = Knob.new(window, Rect(50, 25, 50, 50));

// Action associated with the knob
knob.action_({
  arg me;
  var red, blue, green;
  red = me.value;
  green = red*0.5;
  blue = 0.25+(red*0.75);
  ["red, green, blue", red, green, blue].postln;
  window.background = Color(red, green, blue);
});

window.front;
)

(
/*
  Simple Color Selector
  RGB-HSV
*/

var window = Window("Color Selector", Rect(100, 100, 300, 270)).front;
var guiArr, step = 50;
var flag = \rgb, colorFunc;
var colorArr = [0, 0, 0];

colorFunc = {
  | flag, cls |
  var color, v1, v2, v3;
  # v1, v2, v3 = cls;
  if (flag == \rgb) {
    color = Color(v1, v2, v3)
  } {
    color = Color.hsv(v1.min(0.999), v2, v3)
  };
  color;
};

Button(window, Rect(10, 200, 100, 50))
  .states_([["RGB", Color.white, Color.red], ["HSV", Color.white, Color.black]])
  .action_({ | me | if (me.value == 0) {flag = \rgb} {flag = \hsv} });

guiArr = Array.fill(3, {
  | i |
  [
    Slider(window, Rect(10, (step+10*i+10), 100, step)),
    StaticText(window, Rect(120, (step+10*i+10), 120, step))
  ]
});

guiArr.do{|item, index|
  item[0].action_{|me|
  item[1].string_(me.value);
  colorArr[index] = me.value;
  window.background_(colorFunc.value(flag, colorArr));
}};
)
