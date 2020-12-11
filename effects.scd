// EFFECTS

// Reverb

// SuperCollider comes with three built-in reverbs: `FreeVerb` (monophonic),
// `FreeVerb2` (stereo), and `GVerb` (stereo and preferred, despite some known
// issues).

// I don't think GVerb sounds all that great, personally, but if I set it to a
// small enough room with a short enough duration, it's tolerable.

(
SynthDef.new(\drops, {
  arg freqMin=100, freqMax=3000, gate=1, amp=0.3;
  var sig, trigEnv, env, freq, trig, reverb;

  // `LFNoise1` generates linearly interpolated random values at a frequency
  // given by its first argument. The `exprange` method scales the output of
  // `LFNoise` to be within the range provided.
  freq = LFNoise1.kr(0.2!2).exprange(freqMin, freqMax);
  sig = SinOsc.ar(freq);

  // Dust generates random impulses from 0 to 1. The first argument is
  // `density`, which determines the average number of impulses per second.
  trig = Dust.ar(1!2);
  trigEnv = EnvGen.ar(Env.perc(0.002, 0.1), trig);
  sig = sig * trigEnv;

  reverb = GVerb.ar(sig, 10, 0.4);
  // Manual damping to improve the sound of the reverb
  reverb = LPF.ar(reverb, 1200);
  reverb = reverb * 0.5;
  sig = (sig + reverb) * 0.75;

  env = EnvGen.kr(Env.asr(0.01, 1, 1, -1), gate, doneAction: 2);
  sig = sig * env * amp;

  Out.ar(0, sig);
}).add;
)

x = Synth.new(\drops);
x.set(\gate, 0);


// If we're adding a lot of effects, adding them all within a single SynthDef
// becomes unweildy. Instead, we can modularize the signal chain.

(
SynthDef.new(\drops, {
  arg freqMin=100, freqMax=3000, gate=1, amp=0.3, out=0;
  var sig, trigEnv, env, freq, trig;

  // `LFNoise1` generates linearly interpolated random values at a frequency
  // given by its first argument. The `exprange` method scales the output of
  // `LFNoise` to be within the range provided.
  freq = LFNoise1.kr(0.2!2).exprange(freqMin, freqMax);
  sig = SinOsc.ar(freq);

  // Dust generates random impulses from 0 to 1. The first argument is
  // `density`, which determines the average number of impulses per second.
  trig = Dust.ar(1!2);
  trigEnv = EnvGen.ar(Env.perc(0.002, 0.1), trig);
  sig = sig * trigEnv;

  env = EnvGen.kr(Env.asr(0.01, 1, 1, -1), gate, doneAction: 2);
  sig = sig * env * amp;

  Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
  arg in=0, out=0;
  var sig, reverb;

  // Just as a SynthDef must have an output, it can also have an input. We
  // need to tell it what bus to read from, and how many channels to read.
  sig = In.ar(in, 2);
  reverb = sig.copy;

  reverb = GVerb.ar(reverb,  roomsize: 10,  revtime: 1);
  reverb = LPF.ar(reverb, 900);
  reverb = reverb * 0.5;
  sig = (sig + reverb) * 0.75;

  Out.ar(out, sig);
}).add;
)

r = Synth.new(\reverb, [\in, 8]);
d = Synth.new(\drops, [\out, 8]);
d.set(\gate, 0);
r.free;

// This works, but there's another way to do it that's arguably even more
// flexible: use the `Bus` object. This automatically reserves the next
// available bus channels (as many as you specify), and allows you to name a
// set of reserved channels to use as an argument to pass to synths.

~reverbBus = Bus.audio(s, 2);
r = Synth.new(\reverb, [\in, ~reverbBus]);
d = Synth.new(\drops, [\out, ~reverbBus]);
d.set(\gate, 0);
r.free;

// Buses can be shared---if you send two signals to a bus, they are summed.

// Note that order of execution is very important when setting up a signal
// chain. When we have two processes, one sending a signal and the other
// receiving and processing that signal (as above), the one doing the receiving
// and processing must be downstream from the one doing the sending. This means
// the receiver must be instantiated before the sender. You can see this in the
// node tree: the receiver should be below the sender in the list of nodes (and
// it will be, if it was instantiated first)---signal is processed "head to
// tail" in SuperCollider terms.

// Since it's not always practical to create things in a given order (because
// in a live coding environment, things may be rerouted on the fly), there's a
// way to specify order of execution manually. By default, new synths are added
// to the head of the default group on the localhost server, but you can change
// this using the optional `target` and `addAction` arguments. So, if we needed
// to specify the drops synth first and then add reverb, we could use these
// arguments to make it work.

d = Synth.new(\drops, [\out, ~reverbBus]);
r = Synth.new(\reverb, [\in, ~reverbBus], s.defaultGroup, \addToTail);
d.set(\gate, 0);
r.free;

// Alternatively, we can use a synth as the `target` argument and the
// `addAfter` action to place it next in the chain.

d = Synth.new(\drops, [\out, ~reverbBus]);
r = Synth.new(\reverb, [\in, ~reverbBus], d, \addAfter);
d.set(\gate, 0);
r.free;

// We can also add new groups on the server. Groups make it easy to organize
// synths on the server. It can be useful to add, for example, a source group,
// an effects group, etc. This also helps to keep the order of execution
// organized.

~srcGroup = Group.new;
~fxGroup = Group.new(~srcGroup, \addAfter);

d = Synth.new(\drops, [\out, ~reverbBus], ~srcGroup);
r = Synth.new(\reverb, [\in, ~reverbBus], ~fxGroup);
d.set(\gate, 0);
r.free;

// If you send a message to a group, it relays that message to everything
// inside the group. This allows you to set triggers and gates on all members
// of a group at once.
