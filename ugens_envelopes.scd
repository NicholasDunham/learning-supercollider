/******************************************************************************\
|                                                                              |
|                                  ENVELOPES                                   |
|                                                                              |
\******************************************************************************/

// Envelopes in SuperCollider are not just the familiar ADSR type found on all
// synths. More generally, an envelope is a custom signal shape that controls
// one or more parameters of a sound.

// Like most UGens, envleopes can take optional `mul` and `add` arguments.
// Since envelopes are finite (they have a definite endpoint), they also take a
// `doneAction` argument. This argument takes an integer (1-15) allowing a
// variety of actions to be performed when the envelope reaches its end, but
// the most generally useful values are 0 (do nothing) and 2 (free the
// enclosing synth). The default is 0.
//
// Note that if multiple envelopes are applied to an oscillator (for example,
// one controlling amplitude and another controlling frequency) and both have a
// `doneAction` of 2 (free the enclosing synth), the first envelope to finish
// will successfully free the synth. This may mean, for example, that the synth
// is freed before the amplitude envlope reaches 0, causing an abrupt cutoff.


/******************************************************************************\
|                              SIMPLE ENVELOPES                                |
\******************************************************************************/

// These envelopes are simple in that they take just a few parameters. They're
// easy to use, but less flexible than `EnvGen`. Some, like `Env.perc`, are
// intended for a single, specific purpose.

// Line
//
// Line takes a start value, an end value, and a duration (in seconds), and
// generates a signal that ramps linearly.


// XLine
//
// XLine is similar to Line, but ramps exponentially instead of linearly.
// However, since it's mathematically impossible to interpolate exponentially
// when including or crossing 0 in the output range, it's important to
// constrain the envelope's endpoints to either the positive or negative
// domain. Otherwise, although the envelope will appear to work (the synth will
// appear on the server and be freed, if applicable, when the envelope reaches
// its end value), it will produce no audible output. Using a value very close
// to zero, like 0.01 or -0.01, will work.
//
// XLine often sounds more natural than Line, because we perceive audio
// features like amplitude and frequency exponentially.

// Perc
//
// Mostly intended for creating percussive sounds. Takes an `attackTime` and a
// `releaseTime`, and optionally `level` and `curve`.


/******************************************************************************\
|                                    ENVGEN                                    |
\******************************************************************************/

// EnvGen is the most flexible way to create an envelope. Its most important
// parameters are Env, which consists of arrays of levels, times, and curves;
// and doneAction, which is described above.

(
var envShape = Env.new(
  [ 0, 1, 0.8, 0.8, 0 ],
  [ 0.1, 2.5, 2, 3 ],
  [ 2, -8, 0, -4 ],
);

f = {
  arg freq=440, boost=4, pan=0, amp=0.2;
  var sig, env;
  env = EnvGen.ar(envShape, doneAction: 2);
  sig = SinOsc.ar(freq);
  sig = sig * boost;
  sig = sig.softclip;
  sig = Pan2.ar(sig, pan, amp);
  sig = sig * env;
};
)

x = f.play(args: [\freq, rrand(50, 500)]);


// Indefinite Length Envelopes
//
//

(
x = {
  var sig, env;
  env = EnvGen.kr(
    Env.new(
      [ 0, 1, 0 ],
      [ 1, 3 ],
      [ 0, 0 ]
    ),
    doneAction: 2
  );
  sig = SinOsc.ar(200);
  sig = sig * 0.2;
  sig = sig * env;
  sig = sig!2;
}.play;
)


/******************************************************************************\
|                               GATED ENVELOPES                                |
\******************************************************************************/

// Some envelopes have indefinite length. The most common example is the ADSR
// envelope found on most physical synths, which sustains until the key is
// released. In these envelopes, a gate can be used to cause the envelope to
// move into the "release" phase.
//
// The ADSR envelope takes `attackTime`, `decayTime`, `sustainLevel`, and
// `releaseTime` arguments, and optionally `peakLevel`, `curve`, and `bias`.

(
f = {
  arg gate=1;
  var sig, env;
  env = EnvGen.kr(
    Env.adsr(0.01, 0.3, 0.5, 1),
    gate,
    doneAction:2
  );
  sig = SinOsc.ar(200);
  sig = sig * 0.2;
  sig = sig * env;
  sig = sig!2;
}
)

// Initially setting the gate to 0 creates the synth but doesn't start the
// envelope.

x = f.play(args: [\gate, 0]);

// When the gate is positive, the envelope begins.

x.set(\gate, 1);

// Setting the gate back to 0 begins the release phase of the envelope.

x.set(\gate, 0);

// Gates can also be used in definite length envelopes, like the Perc envelope.
// Just as we did above, we can instantiate a synth without generating any
// sound by initializing the gate to 0. When the gate transitions to a positive
// value, the sound plays. To play it again without releasing the synth, we can
// set the gate back to zero and then to one again. An easier way to do this is
// with a `TrigControl` argument. If you set a `TrigControl` argument to a
// nonzero value, it holds that value for one control cycle, then snaps back to
// zero. To specify an argument as a `TrigControl` argument, just prefix its
// name with `t_`.

(
f = {
  arg t_gate=0;
  var sig, env;
  env = EnvGen.kr(
    Env.perc(0.01, 0.5),
    t_gate
  );
  sig = SinOsc.ar(200);
  sig = sig * 0.2;
  sig = sig * env;
  sig = sig!2;
}
)

// Since t_gate is initialized to 0, this won't produce sound yet.

x = f.play;

// Every time we set t_gate to a positive value, the sound plays and the gate
// resets, ready for another trigger.

x.set(\t_gate, 1);
