// Giving a UGen function an argument

(
f = {
  arg freq=330, boost=4;
  var sig;
  sig = SinOsc.ar(freq);
  sig = sig * boost;
  sig = sig.softclip;
  sig = Pan2.ar(sig, 0, 0.2);
};
)

x = f.play;

// To set initial values rather than relying on the defaults we defined, pass
// an array of symbol/value pairs to the `args` argument.

x = f.play(args: [\freq, 220]);

x.set(\freq, 220);
x.set(\freq, (40..80).choose.midicps);

x.release(1); // Same as x.free, but sends a release message (like a keyup) to
              // the envelope. If you haven't defined an envelope in advance,
              // use an argument to set the release time in seconds.


// Storing synths in an array

(
a = [];
6.do({
  a = a.add(
    f.play(args: [\freq, (40, 42..70).choose.midicps]);
  );
});
)

a.do({ arg n; n.release(exprand(1, 10)) });

