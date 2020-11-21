/******************************************************************************\
|                                                                              |
|                                  SCLANG                                      |
|                                                                              |
|                 Notes on SuperCollider's langugage features                  |
|                                                                              |
\******************************************************************************/

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


/******************************************************************************\
|                                  VARIABLES                                   |
\******************************************************************************/

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
var localvar = 4;
localvar.postln;
)

localvar.postln; // ERROR: Variable 'localvar' not defined.

// Note that unlike local variables, interpreter variables and environment
// variables don't require the`var` keyword at declaration.


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
