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


// EnvGen
//
// 
