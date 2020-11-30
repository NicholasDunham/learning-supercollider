// ROUTINE

// A routine runs a function and allows it to be suspended in the middle and
// then resume later. It's often used for sequencing.

(
r = Routine.new({
  "Hello".postln;
  wait(1);
  "How are you?".postln;
  wait(3);
  "Goodbye".postln;
});
)

// Like a SynthDef, a Routine doesn't play automatically.

r.play;

// Routines have methods to control playback.

r.reset;
r.play;
r.stop;     // Can't resume after a stop unless we reset first
r.reset;
r.next;

// The general server stop command (Cmd-. in SuperCollider's IDE; F12 in
// SCNvim) also stops all running routines.

(
SynthDef(\ocean, {
  arg freq=100, gate=1, atk=0.01, rel=1, pan=0, out=0;
  var sig, env;
  env = EnvGen.kr(
    Env.new(
      [0, 1, 0],
      [atk, rel],
      [0, -4]
    ),
    doneAction: 2
  );
  sig = Pulse.ar(freq, 0.5, 0.004);
  sig = sig + SinOsc.ar(freq * 1.5, 0, 0.15);
  sig = sig + BrownNoise.ar(0.04);
  sig = sig * env;
  sig = Pan2.ar(sig, pan);
  Out.ar(out, sig);
}).add;
)

Synth.new(\ocean);

(
r = Routine.new({
  Synth(\ocean, [\freq, 60.midicps]);
  wait(0.5);
  Synth(\ocean, [\freq, 62.midicps]);
  wait(0.5);
  Synth(\ocean, [\freq, 67.midicps]);
  wait(0.5);
});
)


r.reset; r.play;


// Of course you can also create infinite loops in routines:

(
q = Routine.new({
  inf.do{
    Synth(\ocean, [\freq, rrand(48, 72).midicps, \pan, rrand(-0.5, 0.5)]);
    wait(exprand(0.2, 0.5)); // DON'T FORGET TO WAIT, or SC will try to
                             // start an infinite number of synths at once.
  };
});
)

q.play;
q.stop;

// Another way of creating a loop is to define a function and call the `fork`
// method on it. Also, you can create an infinite loop from a function by
// calling the `loop` method on it. So the above routine could also be
// expressed this way.

(
p = {
  {
    Synth(\ocean, [\freq, rrand(48, 72).midicps, \pan, rrand(-0.5, 0.5)]);
    wait(exprand(0.2, 0.5)); // DON'T FORGET TO WAIT, or SC will try to
                             // start an infinite number of synths at once.
  }.loop;
}.fork;
)

p.stop;
