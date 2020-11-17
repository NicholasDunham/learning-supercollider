// A block enclosed in parentheses is evaluated as a unit. All of the following
// lines are run together. The last statement in a block is always returned, so
// the "Finished" statement below is printed in the post window even though it
// doesn't have a .postln message.
(
"First Line".postln;
"Second Line".postln;
(2 + 2).postln;
3 + 3;
"Finished";
)

// VARIABLES
//
// Variables are not typed.
a = "A string";
a = 256;
a = [0, 1, 2, 3, 4];

// Variables are, generally speaking, block scoped, but there are three kinds
// of variables, and these kinds affect the scoping rules.

// Interpreter variables are represented by lowercase letters `a` through `z`.
// These are predeclared by the interpreter, and are alwyas global. Remember
// that `s` refers by default to the local server, so it's best not to reassign
// it.
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

// SuperCollider also provides a globally-available environment in which we can
// store variables. We designate an environment variable by starting its name
// with a tilde.
(
~myvar = "A string";
)
~myvar.postln;

// That's actually just a shortcut for this:
currentEnvironment.put(\myvar, 0.9);
currentEnvironment.at(\myvar);

// Local variables are declared using the `var` keyword, and have block scoping.
(
var localvar = 4;
localvar.postln;
)

localvar.postln; // ERROR: Variable 'localvar' not defined.
