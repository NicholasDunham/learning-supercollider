/******************************************************************************\
|                                                                              |
|                             SYNTHDEFS AND SYNTHS                             |
|                                                                              |
\******************************************************************************/

// A `SynthDef` is a recipe for a sound, and a `Synth` is an execution of that
// recipe. Example code often uses the `Function.play` pattern to create
// sounds, but `SynthDef` offers better reuse and flexibility.

// To illustrate the differences, we'll change the following function to a
// SynthDef (both taken from Eli Fieldsteel's tutorial).

(
z = {
  | noiseHz=8 |
  var freq, amp, sig;
  freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
  amp = LFNoise1.kr(12).exprange(0.02, 1);
  sig = SinOsc.ar(freq) * amp;
}.play;
)

z.free;

// The SynthDef version is very similar, except that it has a name (which can
// be either a string or a symbol) and an output UGen. Here we've mostly just
// copied the function from above into the SynthDef. We then send the `add`
// message to the SynthDef in order to add it to the local server so that it
// can be used.

(
SynthDef.new(\sineTest,  {
  | noiseHz = 8 |
  var freq, amp, sig;
  freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
  amp = LFNoise1.kr(12).exprange(0.02, 1);
  sig = SinOsc.ar(freq) * amp;
  Out.ar(0, sig);
}).add;
)

// Now we can use the SynthDef by creating a new Synth and providing the name
// of a SynthDef.

x = Synth.new(\sineTest);
x.free;

// To send arguments to a SynthDef, include a second argument after the name
// consisting of an array of argument names and values.

x = Synth.new(\sineTest, [\noiseHz, 24]);

// You can also use the `set` method to change arguments while the synth is
// running.

x.set(\noiseHz, 32);

x.free;
