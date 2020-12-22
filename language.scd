    ///////////////////////////////////////////
   // SCLANG: The language of SuperCollider //
  ///////////////////////////////////////////

// This is not intended to be a comprehensive guide to sclang. Rather, it's a
// brief overview of what makes sclang unique---ways in which it differs from
// other popular languages, especially those with which I'm most familiar, such
// as JavaScript, Go, and Python.

// The SuperCollider language, or sclang, is object-oriented, and comes with a
// built-in library of classes representing various types of data: patterns,
// streams, arrays, etc. Computations on those data are represented as messages
// passed to objects. Messages may also be called methods, and these terms are
// used interchangeably. Everything in SuperCollider is an object, and can
// receive messages, including primitives like integers. You can also omit
// parentheses when calling a method that requires no arguments. The syntax is
// thus very compact.

3.cubed; // Returns 27


// A block of code enclosed in parentheses is evaluated together (sequentially)
// as a unit. The last statement in a block is always returned, so the
// "Finished" statement below is printed in the post window even though it
// doesn't have a .postln message.

(
"First Line".postln;
"Second Line".postln;
(2 + 2).postln;
3 + 3;
"Finished";
)

// These blocks can be nested. Typically an entire patch will be enclosed in a
// block, within which are several subblocks.


    ///////////////
   // Variables //
  ///////////////

// Variables are not statically typed.

a = "A string";
a = 256;
a = [0, 1, 2, 3, 4];

// There are three kinds of variables, and these kinds affect how the variables
// are scoped.

// Interpreter variables are represented by lowercase letters `a` through `z`.
// These are predeclared by the interpreter, and are always global. However,
// `s` refers by default to the local server (it's an alias of `Server.local`),
// so it's best not to reassign it.

(
a = Pbind(
  \note, Pwhite(0, 10),
  \dur, 0.1
).play;
)
a.stop; // Works because `a` is an interpreter variable, and thus has global
        // scope.

// It's generally not a good idea to use these variables for anything more than
// simple examples, both because their names are not descriptive and because
// they're easy to overwrite accidentally.

// We can also declare environment variables by preceding the variable name
// with a tilde. These are not technically global, since there may be more than
// one active environment in a SuperCollider session, but they are global in
// the sense that they're not block scoped. Like interpreter variables, they
// don't need to be declared with the `var` keyword.

(
~myvar = "A string";
)
~myvar.postln;

// That's actually just a shortcut for this:

currentEnvironment.put(\myvar, 0.9);
currentEnvironment.at(\myvar);

// Local variables must be declared using the `var` keyword. They have block
// scoping, and although they can be declared anywhere, they're generally
// declared and used within a block---parentheses or a function, for example.
// They must be declared at the top of the block, and may optionally be
// initialized at declaration.

(
var localVar = 4;
localVar.postln;
)

localVar.postln; // ERROR: Variable 'localvar' not defined.

// Local variables only have scope within the code evaluation of which they are
// part. This means that if you declare a local variable at the top level,
// outside of any code blocks, and evaluate line-by-line, they'll go out of
// scope between evaluations and the code won't work. Generally, only declare
// local variables within blocks, like parentheses and functions.

// Note that unlike local variables, interpreter variables and environment
// variables don't require the`var` keyword at declaration.


/******************************************************************************\
|                            BASIC ARRAY OPERATIONS                            |
\******************************************************************************/

// As in JavaScript, elements in an array don't need to be of the same type.

x = [ "String", $c, \symbol, 3.14 ];
x.size;         // 4

// You can index into an array using the `at` method.

x.at(0);        // "String"
x.at(4);        // nil

// The more familiar indexing syntax also works.

x[2];           // \symbol

// Change the value at an index (modifying the receiver in place) using the
// `put` method.

x.put(2, 500);
x.postln;       // [ "String", $c, 500, 3.14 ]

// However, arrays have a fixed size. Adding an element to an array is
// guaranteed to return a new array with the new element, but may or may not
// change the original in place. This is because by default, array sizes are
// always powers of two (unless you create an array using a class method and
// specify a different size---see below). In the following example, since the
// original array is of size 4, it's already full. Adding an element will not
// modify the existing array.

y = x.add(60);
x.postln;       // [ "String", $c, 500, 3.14 ]
y.postln;       // [ "String", $c, 500, 3.14, 60 ]

// But in the next example, since the size of the original array is 3, it still
// has room for one more element. Therefore, the original array is modified in
// place (and the add operation also returns a new array).

p = [ 1, 2, 3 ];
q = p.add(4);
p.postln;       // [ 1, 2, 3, 4 ]
q.postln;       // [ 1, 2, 3, 4 ]

// The safest thing to do is to assign the result of an add to the original
// variable.

p = p.add(5);
p.postln;       // [ 1, 2, 3, 4, 5 ]

// The same applies to the `insert` method.

p = p.insert(0, 0);
p.postln;       // [ 0, 1, 2, 3, 4, 5 ]

// You can shuffle an array using the `scramble` method. This method does not
// change the original in place. So again, if you want to save the shuffled
// version to use later, store it in a variable (or manually overwrite the
// original array).

p.scramble;     // [ 4, 3, 1, 5, 0, 2 ]
p.postln;       // [ 0, 1, 2, 3, 4, 5 ]

// The same goes for the `reverse` method.

p.reverse;      // [ 5, 4, 3, 2, 1, 0 ]
p.postln;       // [ 0, 1, 2, 3, 4, 5 ]

// It's also true of the `mirror` method, which pivots on the last item in the
// array. Obviously, since the array returned by this method is of a different
// size than the original, it may not fit into the original's maximum size.

p.mirror;       // [ 0, 1, 2, 3, 4, 5, 4, 3, 2, 1, 0 ]

// The `mirror2` method is similar to `mirror` except that it doubles the last
// element---that is, rather than pivoting on the last element, it returns the
// whole array twice, first in the original order and then in reverse.

p.mirror2;      // [ 0, 1, 2, 3, 4, 5, 5, 4, 3, 2, 1, 0 ]

// The `sort` method does change the original in place. Of course, it still
// doesn't hurt to assign it back to the original variable, just for the sake
// of consistency.

r = [ 4, 2, 0, 1, 3 ]
r.sort;         // [ 0, 1, 2, 3, 4 ]
r.postln;       // [ 0, 1, 2, 3, 4 ]

// The `rotate` method shifts all elements to the right, rotating back around
// to the beginning when they go past the end. This does not modify the
// original array in place.

r.rotate;       // [ 4, 0, 1, 2, 3 ]
r.postln;       // [ 0, 1, 2, 3, 4 ]

// You can also specify a number of places to rotate. Negative numbers rotate
// elements to the left.

r.rotate(-2);   // [ 2, 3, 4, 0, 1 ]

// Finally, the `choose` method returns a single element from the array, at
// random, without modifying the array.

r.choose;       // 4
r.choose;       // 0
r.choose;       // 4

// This is just a sampling of methods available on arrays---there are many
// others available.


/******************************************************************************\
|                                 ARRAY MATH                                   |
\******************************************************************************/

// Mathematical operations on arrays are "lifted"---that is, applied to each
// element in the array. This does not modify the original array in place.

x = [ 0, 1, 2, 3, 4 ];
x * 2;          // [ 0, 2, 4, 6, 8 ]
x.postln;       // [ 0, 1, 2, 3, 4 ]

// (Some? Most?) mathematical methods work as well.

x.squared;      // [ 0, 1, 4, 9, 16 ]
x.odd;          // [ false, true, false, true, false ]

// But not all mathematical methods are defined for arrays. For example, the
// `isPrime` method, which works on integers, does not work on an array of
// integers.

3.isPrime;      // true
x.isPrime;      // Error

// Obviously these methods only make sense when they can be applied to all
// elements in the array---which, since arrays can contained mixed types, isn't
// necessarily the case. If, for example, you use the `squared` method on an
// array with a string in it, you'll get an error.


/******************************************************************************\
                             ITERATION OVER ARRAYS                             |
\******************************************************************************/

// The `collect` method works like `map` in JavaScript: it iterates over the
// array, calling a function (with, in most cases, an argument that takes the
// value at the current position in the array and an optional second argument
// for the current index number), and returning a new array with the contents
// of the values returned by the function.

x = [ "Bob", "Jane" ];
y = x.collect({ arg name; "Hello" + name + "!"; });
y.postln;       // [ "Hello Bob !", "Hello Jane !" ]

// The `do` method is similar, but instead of returning a new array, it returns
// its receiver, unmodified. The following example prints the greetings to the
// screen, but doesn't return them in a new array.

x = [ "Bob", "Jane" ];
x.do({ arg name; var greet = "Hello"+name+"!"; greet.postln; });

// The `select` and `reject` methods are similar to `filter` in other
// languages. The `any` method returns true if at least one of its function
// calls return true.

x = [ 1, 2, 3, 4, 5 ];
x.select({ arg num; num.isPrime; });  // [ 2, 3, 5 ]
x.reject({ arg num; num.isPrime; });  // [ 1, 4 ]
x.any({ arg num; num.isPrime; });     // true


/******************************************************************************\
|                             ARRAY CLASS METHODS                              |
\******************************************************************************/

// All of the array methods presented so far are instance methods. The
// following class methods are useful when creating new arrays.

// The `new` method creates an array with the specified size. As stated before,
// array sizes always correspond to a power of 2. This means that although you
// can specify any size, the array size will always round up to the next power
// of 2.

x = [ 1, 2, 3 ];
x.add(4);           // [ 1, 2, 3, 4 ]
x.postln;           // [ 1, 2, 3, 4 ]
y = Array.new(3);
y.add(1);
y.add(2);
y.add(3);
y.add(4);           // Array is now full
y.add(5);           // [ 1, 2, 3, 4, 5 ]
y.postln;           // [ 1, 2, 3, 4 ]

// There are several methods available to fill arrays with values
// automatically.

w = Array.series(4, 5, 5);                // [ 5, 10, 15, 20 ]
x = Array.geom(8, 2, 2);                  // [ 2, 4, 8, 16, 32, 64, 128, 256 ]
y = Array.interpolation(3, 100, 150);     // [ 100.0, 125.0, 150.0 ]
z = Array.fill(3, { "hello".scramble; }); // [ "leolh", "helol", "ohlel" ]

// There's also a shortcut for `Array.series`.

(1..100);       // Generates an array with 100 elements, from 1 to 100
(1,4..100);     // Same idea, but incrementing by 3
(0,3..100);     // Same again, but stops at 99 because it can't hit 100 exactly

/******************************************************************************\
|                                  FUNCTIONS                                   |
\******************************************************************************/

// Functions are enclosed in curly braces. No keyword is necessary to indicate
// that the contents of the braces are a function. The last expression in the
// function is its return value. Argument declarations follow the open bracket,
// in either "arg style" or "pipe style".

// Arg style:

(
f = {
  arg a, b, c;
  var d;
  d = a * b;
  c + d;
};
)

// Pipe style:
(
f = {
  | a, b, c|
  var d;
  d = a * b;
  c + d;
};
)

// Arguments may be initialized to default values, and the defaults may be
// literal values or expressions:

(
f = {
  arg x = 10, y = 4.rand;
  x + y;
};
)

// When using pipe style, default value expressions must be enclosed in
// parentheses:

(
f = {
  | x = 10, y = (4.rand) |
  x + y;
};
)

// If the last argument is preceded by an ellipsis, then all remaining
// arguments passed to the function will be assigned to that argument as an
// array.

(
f = {
  | a, b, c, ...d | // The first three arguments will be assigned to a, b, c;
  ...               // remaining arguments will be passed to d as an array.
};
)

// Functions are objects, and can be passed around as values and sent messages
// like any other object. A function can be evaluated by sending it the `value`
// message.

f.value(3, 5);

// TODO: There's a note in the SuperCollider help files that I need to
// investigate further: "In general arguments may be initialized to literals or
// expressions, but in the case of Function:play or SynthDef:play, they may
// only be initialized to literals."

// However, the help file also notes that the following two function
// declarations are equivalent:

{ arg x = 10.rand; x };

(
{
  arg x;
  x ?? { x = 10.rand };
  x
}
)

// So presumably that style would still work with Function:play. Again, need to
// investigate further.


// Note that the last line of a function (its return value) doesn't necessarily
// need to end with a semicolon, though it may.


/******************************************************************************\
|                                    MATH                                      |
\******************************************************************************/

// SuperCollider does not observe mathematical precedence. All mathematical
// calculations are performed left to right. To ensure correct order of
// operations, always use parentheses or perform calculations on multiple lines
// of code.


/******************************************************************************\
|                                 RANDOMNESS                                   |
\******************************************************************************/

// The `rand` method returns a random value between 0 and its receiver. It
// works on both integers and floats. The range of included numbers includes 0,
// but not the receiver.

10.rand;    // Returns a number from 0 to 9, but never 10.
10.0.rand;

// The `rrand` method allows you to specify a range, and this range is
// inclusive.

rrand(1, 10);   // Returns a number from 1 to 10, inclusive.

// The `exprand` method returns a random number within a range, but uses an
// exponential distribution---that is, lower numbers are more likely to be
// chosen. Unlike `rand` and `exprand`, it returns floats even if its inputs
// are ints. Also unlike those methods, both of its inputs must have the same
// sign---its range cannot cross zero.

exprand(1, 100);

// This is also available as an Array class method:

Array.exprand(8, 1, 100);

// The Array class also has a `rand` method, which corresponds to `rrand`, not
// `rand`.

Array.rand(8, 1, 100);


/******************************************************************************\
|                                   OBJECTS                                    |
\******************************************************************************/

// SuperCollider is an object-oriented language. Everything is an object, and
// every object, including things like numeric literals, can respond to
// messages.

// An object consists of data representing its state and a set of operations it
// can perform (methods). To request that an object perform an operation, you
// send it a message. A message consists of a selector naming the type of
// operation, a receiver to which the message is sent, and (sometimes) a list
// of arguments consisting of data to be used in the operation. A message
// always returns a result.

// There are four ways of sending a message to an object. Although they are
// functionally equivalent, there are conventions dictating which to use in
// specific contexts.

// 1: Object.method(argument);
// 2: method(Object, argument);
// 3: Object method: argument;
// 4: method (Object) {argument};

// So, for example, one generally uses the first version for UGens:

{SinOsc.ar(220)}.play;

// Binary operations are often declared using version 2:

rrand(0, 10);

// The third form is useful for things like `and:` and `or:`:

true and: true

// The fourth is mostly used for control structures like `if`, `while`, and
// `case`.

// In short, the reason we have multiple ways of calling a method on an object
// in SuperCollider is that unlike other object-oriented languages,
// SuperCollider tends to use methods for everything. In Python, for example,
// `len` is a top-level function, and is called on an array like `len(array)`.
// The programmer has to remember whether a particular operation is a
// standalone function or a method. In SuperCollider, it's always a method, and
// the programmer can choose a syntax with which to call that method based on
// readability in a particular context.

// That said, when reading other people's code it's important to be able to
// recognize all four message passing techniques.


/******************************************************************************\
|                           MULTICHANNEL EXPANSION                             |
\******************************************************************************/

// The server interprets an array of UGens as a multichannel signal. To produce
// a stereo signal, just play an array of two UGens.

~sine = { [ SinOsc.ar, SinOsc.ar ] }.play;

// If you're just trying to send the same monophonic signal to both channels,
// you can use the `dup` method to automatically create an array. This method
// takes one argument, the number of times to duplicate the receiver.

~sine = { SinOsc.ar.dup(2) }.play;


// A shortcut for this method is an exclamation point, followed by the number of
// times to duplicate.

~sine = { SinOsc.ar!2 }.play;

// You can also just pass an array of frequencies to a single SinOsc, which
// also gets expanded into multiple channels.

~ sine = { SinOsc.ar([300, 400]) }.play;


/******************************************************************************\
|                            MIXING AUDIO SOURCES                              |
\******************************************************************************/

// The simplest way to mix multiple UGens is to add them together.

(
~sum = {
  var sig1, sig2, sig3;
  sig1 = SinOsc.ar(400, mul: 0.2);
  sig2 = SinOsc.ar(250, mul: 0.3);
  sig3 = SinOsc.ar(1400, mul: 0.07);
  sig1 + sig2 + sig3;
}.play;
)


/******************************************************************************\
|                                 MODULATION                                   |
\******************************************************************************/

// We can use UGens as inputs to other UGens, to modulate them in various ways.
// In this example, we use one SinOsc as an LFO to create vibrato in another.
// We want the resulting tone to vary between 280 and 320 Hz. We'll create a
// vibrato oscillator with a frequency of 6 Hz (so that the vibrato completes
// its cycle six times per second). Since the output of an oscillator normally
// varies between -1 and 1, we'll multiply by 20 and add 300 to get a final
// result varying between 280 and 320 six times per second.

(
~vib = {
  var sig, vib;

  vib = SinOsc.ar(6, 0, 20, 300);
  sig = SinOsc.ar(vib, mul: 0.2)!2;
}.play;
)

// A shortcut for the vibrato oscillator syntax is to use the `range` method.

  vib = SinOsc.ar(6).range(280, 320);

  //////////////
 // Equality //
//////////////

// SuperCollider has two equality operators. The double equals sign test for
// eqality, and works on strings and arrays as you'd expect.

a = "string";
b = "string";
a == b;         // true

c = [ 1, 2, 3 ];
d = [ 1, 2, 3 ];
c == d;         // true

// The triple equals sign tests for object identity.

a === b;        // false
c === d;        // false

// This exposes an important difference between strings and symbols.

e = \symbol;
f = \symbol;
e == f;         // true
e === f;        // true
