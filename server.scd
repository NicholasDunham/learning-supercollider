/*****************************************************************************\
|                                                                             |
|                                    SERVER                                   |
|                                                                             |
\*****************************************************************************/


// NOTE: I'm interacting with SuperCollider via the NeoVim plugin SCNvim on a
// Mac. So before I do anything else, I open a SuperCollider document
// (extension `.sc` or `.scd`) in NeoVim, then type `:SCNvimStart` to start
// the language interpreter.

// Once that's done, I can run a sequence like this to boot the audio server:

(

// Disable audio input. I don't generally use the microphone for anything in
// SuperCollider, and on my setup the default microphone input is often set to
// a different sample rate than the default output, which isn't allowed in
// SuperCollider (you get a `Mismatched sample rates are not supported` error).
// Disabling the microphone input fixes this.

Server.default.options.numInputBusChannels = 0;

// Other ways of fixing this error are described here:
// https://doc.sccode.org/Reference/AudioDeviceSelection.html

// Boot the server.

s.boot;

// Open some useful widgets. Each of these will appear in a separate floating
// window.

s.makeWindow;   // Server window
s.meter;        // Level meters
s.scope;        // Waveform scope
FreqScope.new;  // Frequency analysis
s.plotTree;     // Object node tree
)

// The `s` variable, by default, refers to the local server---that is, it's an
// alias for `Server.local`. We can tell the server to record the current
// session by sending it a `.record` message.

s.record;

(
{Saw.ar(
  LFNoise0.kr([2, 3]).range(100, 2000),
  LFPulse.kr([4, 5]) * 0.1)
}.play;
)

s.stopRecording;

// The post window will display the path of the folder where the file is saved.
// On my Mac, it's in ~/Music/SuperCollider Recordings/

// We can also quit the audio server:

s.quit;

// Note that this closes some of the widgets we opened earlier, but not all.


