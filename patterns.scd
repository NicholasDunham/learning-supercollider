// Classes beginning with a capital P are various types of patterns. Patterns
// are a concise way of describing calculations declaratively, rather than
// procedurally. They're ideal for specifying sequences, or streams, of
// information.

// For example, you can use `Pseries` to specify an infinite series of integers
// starting with 0:

a = Pseries(start: 0, step: 1, length: inf).asStream;

a.nextN(10); // [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]

// The same pattern could also be represented as a Routine:

(
a = Routine {
  (0..).do { |i|
    i.yield;
  };
};
)

a.nextN(10);

// But the pattern is more concise, easier to understand, and has been tested
// by others, so it requires less debugging.

// It's also important to understand the difference between a pattern and a
// stream.  Patterns define behavior, whereas streams execute it. This is why
// we had to call `asStream` on the `Pseries` above before we could get any
// integers from it: the pattern has no concept of internal state; it's just a
// blueprint for a sequence. This is also the reason why when we call the
// `play` method on a pattern we need to assign it to a variable: `play`
// returns an `EventStreamPlayer`, which has internal state and thus can be
// stopped, muted, reset, and otherwise manipulated later.
