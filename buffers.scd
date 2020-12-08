/*****************************************************************************\
|                                                                             |
|                                   BUFFERS                                   |
|                                                                             |
\*****************************************************************************/

// The word buffer can refer to two separate but related things in
// SuperCollider.

// As a general concept, a buffer is essentially the server's version of an
// array---but whereas arrays in sclang can contain any kind of data, a buffer
// only contains floats. Buffers are used to hold audio samples that represent
// a sound. These samples should be uncompressed audio, like `aiff` or `wav`
// files.

// `Buffer`---with a capital B---is a class in sclang used for interacting with
// buffers on the server.

~mySamp = Buffer.read(s, "/path/to/audio/file.aiff");

~mySamp.play;

// There are some other useful methods on a loaded sample.

~mySamp.numChannels;      // 1 if mono; 2 if stereo (can be higher!)
~mySamp.duration;         // Output is in seconds

// A frame is a sample, but for all channels. In a monophonic sample, the
// number of samples equals the number of samples. In a stereo sample, the
// number of samples is twice the number of frames.

~mySamp.numFrames;

// The `sampleRate` method returns the sample rate of the file, which may be
// different from the sample rate of the server and the audio interface. It's
// also possible for different sample files to have different sample rates. All
// of these differences can have consequences, so it's important to be able to
// see a specific file's sample rate.

~mySamp.sampleRate;

// The server gives each buffer a number when it's loaded into memory.

~mySamp.bufnum;

~mySamp.plot;

~mySamp.free;

Buffer.freeAll;

// The above method is fine for quickly working with files on your own system,
// but they don't work when sharing files, and if you move files the code
// breaks. Here's a less brittle method of getting files from a subdirectory of
// the one in which the current file is saved.

(
var audioPath = PathName.new(thisProcess.nowExecutingPath).parentPath ++ "audio/";
~mySamp = audioPath ++ "file.aiff";
)


/*****************************************************************************\
|                                    UGENS                                    |
\*****************************************************************************/

// There are two UGens used for interacting with buffers: `PlayBuf` and
// `BufRd`. Fundamentally, they do the same thing, but they have different
// designs and this means one or the other will generally be preferable for a
// particular task.

// But there's a big difference between playing a buffer as above, using
// `buffername.play`, and using a UGen. Calling the play method on the buffer
// automatically handles differences between the sample rate of the file and
// that of the server. UGens don't automatically handle this. Instead, they
// have a `rate` argument that allows us to set the playback rate arbitrarily.
// This way we can handle differences, or play files back faster or slower than
// normal, if desired. A quick way to scale correctly for sample rate
// discrepancies is to use the `BufRateScale` UGen, which returns a ratio
// between the buffer's original sample rate and the server's current rate.


// PlayBuf

(
{
  var sig;
  sig = PlayBuf.ar(
    2,                // Number of channels
    ~mySamp.bufnum,   // Note: number, not name, of the buffer
    BufRateScale.ir(~mySamp.bufnum), // Scale sample rate
    doneAction: 2
  );
}.play;
)

// Another useful trick is to move up or down by semitones calling the
// `midiratio` method on a number.

(
{
  var sig;
  sig = PlayBuf.ar(
    2,
    ~mySamp.bufnum,
    BufRateScale.ir(~mySamp.bufnum) * 3.midiratio,
    doneAction: 2
  );
}.play;
)

// Other useful arguments include `trigger` (often useful with `Dust` and
// `Impulse`), `startPos`, and `loop`. Note that if `loop` is equal to 1, then
// `doneAction` is ignored.


// Synthdefs

(
SynthDef.new(\pb, {
  arg buf=0, rate=1, t_trig=1, spos=0, loop=0, da=2, amp=0.5, out=0;
  var sig;
  sig = PlayBuf.ar(
    2,            // Number of channels
    buf,
    BufRateScale.ir(buf) * rate,
    t_trig,
    startPos,
    loop,
    da
  );
  sig = sig * 0.3!2;
  Out.ar(0, sig);
}).add;
)

// Note that we made most of the useful values arguments, but we can't make the
// number of channels an argument. This is because the number of channels must
// be fixed at runtime. Technically we could pass this synth a mono file and it
// would just put a warning in the post window and then play, but the best
// thing to do would be to create separate synths for mono and stereo files.


// BufRd

// BufRd is another way to play the content of a buffer, but lets you read
// directly from a buffer via a phase argument. This is more convenient for
// taking custom control of how you read through a sample, for example using a
// SinOsc to control playback speed.
