It's a simple program, made with lazarus, that allows you to alter (remove or put in place) the "know how protection"  setting for programming blocks in the simatic step7 plc range.

When you write a program block for these PLCs, there's a way to protect it so that other programmers cannot see it, just use it.

The _official_ way is cumbersome and error prone: you have to generate the block source, add an attribute KNOW\_HOW\_PROTECTED and recompile it.
Once protected, you cannot _unprotect_ it, so you have to keep around both copies for debugging.
Worse, if you've been supplied only with the _protected_ copy, you cannot look under the hood to see how it is working.

This program allows to switch the protection or or off on the fly, so there's no need to keep two copies.

Now it also allows to change the language of the block (use with caution), useful to convert a normal block in an F block or vice-versa, or to edit F blocks in AWL F (which is normally not possible).
