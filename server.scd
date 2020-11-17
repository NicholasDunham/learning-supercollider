// NOTE: I'm interacting with SuperCollider via the NeoVim plugin SCNvim on a
// Mac.  I start the server by first opening a SuperCollider document
// (extension `.sc` or `.scd`) in NeoVim, then typing `:SCNvimStart`, and
// finally evaluating a line like this:
s.boot;

// My computer has multiple inputs and outputs, and especially when I'm using a
// headset with a built-in microphone, sometimes I run into a problem where the
// default input device and the default output device are using different
// sampling rates, which causes the SuperCollider server to fail to boot with a
// `Mismatched sample rates are not supported` error. Since I don't have any
// particular need for microphone input, I fix this by changing the number of
// input devices to 0:
Server.default.options.numInputBusChannels = 0;
// This line needs to be evaluated before booting the server.

// Other ways of fixing this problem are described here:
// https://doc.sccode.org/Reference/AudioDeviceSelection.html

// The `s` variable, by default, refers to the local server. We can tell the
// server to record the current session by sending it a `.record` message.
s.record;
{Saw.ar(LFNoise0.kr([2, 3]).range(100, 2000), LFPulse.kr([4, 5]) * 0.1)}.play;
s.stopRecording;

// The post window will display the path of the folder where the file is saved.
// On my Mac, it's in ~/Music/SuperCollider Recordings/

// Another way to start and stop recording is from a server window, which you
// request like this:
s.makeWindow;
