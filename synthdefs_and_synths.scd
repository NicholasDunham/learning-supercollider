/******************************************************************************\
|                                                                              |
|                             SYNTHDEFS AND SYNTHS                             |
|                                                                              |
\******************************************************************************/

// A `SynthDef` is a recipe for a sound---more precisely, an object that
// defines an interconnection of UGens---and a `Synth` is an execution of that
// recipe. Example code often uses the `Function.play` pattern to create
// sounds, but `SynthDef` offers better reuse and flexibility.

// To illustrate the differences, we'll change the following function to a
// SynthDef (both taken from Eli Fieldsteel's tutorial).

(
f = {
  arg freq = 100;
  var sig;
  sig = Pulse.ar(freq * [1, 1.01], 0.5, 0.04);
  sig = sig + SinOsc.ar(freq * 1.5 * [1, 1.004], 0, 0.15);
  sig = sig + BrownNoise.ar(0.04!2);
  sig = sig * Line.ar(0, 1, 10);
};
)

z = f.play;
z.free;

x = f.play(args: [\freq, 350]);
x.set(\freq, 120);
x.set(\gate, 0, \fadeTime, 5);

// The SynthDef version is very similar, except that it must have a name (which
// can be either a string or a symbol) and an output UGen. Here we've mostly
// just copied the function from above into the SynthDef. We then send the
// `add` message to the SynthDef in order to add it to the local server so that
// it can be used.

(
SynthDef.new(\ocean, {
  arg freq = 100;
  var sig;
  sig = Pulse.ar(freq * [1, 1.01], 0.5, 0.04);
  sig = sig + SinOsc.ar(freq * 1.5 * [1, 1.004], 0, 0.15);
  sig = sig + BrownNoise.ar(0.04!2);
  sig = sig * Line.ar(0, 1, 10);
  Out.ar(0, sig);
}).add;
)

x = Synth.new(\ocean);
x.free;

// When specifying arguments, we don't need to label it `args:` as we do when
// using `function.play` because `args` is already the second argument of
// `Synth.new`. Just remember to use an array of name-value pairs.

x = Synth.new(\ocean, [\freq, 360]);
x.set(\freq, 180);
x.free;

// One thing that wouldn't work here is the last line of the `function.play`
// example above, in which we set a gate and fade time. This is because the
// `function.play` shortcut automatically creates a sustaining envelope with a
// gate control for us if we don't specify one. (It also creates the `Out` UGen
// if we don't do it.) In a SynthDef, we have to create an envelope with a gate
// control if we want to use one. Here's a modified version of the SynthDef with
// an appropriate envelope specified.

(
SynthDef.new(\ocean, {
  arg freq = 100, gate = 1;
  var sig, env;
  env = EnvGen.kr(
    Env.asr(3, 1, 3, [1, -1]),
    gate,
    doneAction: 2
  );
  sig = Pulse.ar(freq * [1, 1.01], 0.5, 0.04);
  sig = sig + SinOsc.ar(freq * 1.5 * [1, 1.004], 0, 0.15);
  sig = sig + BrownNoise.ar(0.04!2);
  sig = sig * Line.ar(0, 1, 10);
  sig = sig * env;
  Out.ar(0, sig);
}).add;
)

x = Synth.new("ocean");
x.set(\gate, 0);
