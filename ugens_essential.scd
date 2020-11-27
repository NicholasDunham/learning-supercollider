// Eli Fieldsteel's subjective list of essential UGens

// Oscillators: band-limited (antialiasing)
//
// SinOsc
// Saw
// Pulse
// Blip
//
// Oscillators: non-band-limited
// (optimal for low freq, will alias at high freqs)
//
// LFSaw
// LFPulse
// LFTri
// VarSaw


// Filters: low/high pass (R=resonant), low/high shelf, band pass/reject
//
// LPF
// HPF
// RLPF
// RHPF
// BLowShelf
// BHiShelf
// BPF
// BRF
//
// (See also BEQSuite)


// Triggers
//
// Impulse
// Dust
// Trig


// Envelopes
//
// Line
// XLine
// EnvGen


// Sample playback
//
// PlayBuf
// BufRd


// Delays (no feedback)
//
// DelayN
// DelayL
// DelayC
//
// Delays (with feedback)
//
// CombN
// CombL
// CombC


// Stereo panners/balancers
//
// Pan2

(
{
  var sig;
  sig = SinOsc.ar(440);

  // Pan2 takes three arguments: an input signal, a position (-1 for hard left,
  // 0 for center, 1 for hard right), and a level (same as the `mul` argument
  // for other oscillators).
  sig = Pan2.ar(in: sig, pos: 0.4, level: 0.2);
}.play;
)

// Balance2
