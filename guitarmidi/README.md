gmidi.pl
========

(Last update of the original text: 2007-03-27. Markdownized,
typofixed, shortened and slightly modified.)

This is a Perl script that "translates" a text file into a MIDI format
0 file. (*I had to modify a loop that used an `eval` to make it work
with my current Perl interpreter version*.)

It was not made to create beautiful MIDI files. It just tries
to create a MIDI file from a simple textual description of guitar
chords. This tool is thought for one who wants to hear a sequence of
chords on its computer, not to produce real good MIDI music.

Examples are provided just to give you an idea of what you can do, and
what you can not, with this simple musical tool.

Here it follows a brief description of the format.


The gmidi.pl input file format
------------------------------

* **COMMENTS** are on a single line, starting with a `#`. It *MUST* be
  the first char of the line, or it won't be recognised.

* **TIME SIGNATURE.** You can set your time signature with `ts=N,M`
  where N is the numerator, integer number, and M is a number so that
  2^-M give you the denominator.  The time signature then will be,
  mathematically, N*2^-M. You can change time signature along the
  song; if you do not give a time signature command before the very
  first note, then a default value is given. Default is 4/4.

* **TEMPO.** Metronome tempo. You can set it with `t=N` where N is a
  number. You can change it during the song. If you do not set it
  before the first note, the default value used will be 120.

* **VOLUME.** You can set the MIDI volume with `vol=N` where the
  maximum number you can put here is 127. Default is 110.

* **EXPRESSION.** You can set the MIDI expression with `e=N` where the
  maximum number N you can put is 127. Default is 100.

* **INSTRUMENT.** You can change instrument too with `i=N`, again N
  cannot be greater than 127.  Default is 25 (sounds like a guitar).

* **PANNING.** The command `pan=N` set the panning of the channel. The
  values can be from -64 to +63 (-64 is 0 and +63 is 127). Default to
  0 (+64, i.e. the center).

* **CHORD** A chord is a sequence of six digits (but you can use the
  special value `x` to say that the string must not be played). The
  first digit is the lowest string (that is a E for the standard
  guitar tuning EAGDBe). For example `x32010` is a C major, while
  `332010` is a C major with the G as bass.

  Once you set up a chord, no sound is emitted. To play the chord you
  have to use the "stroke" command.

  Chords can be stored and reused. To store a chord, just use the
  syntax `=NAME` where `NAME` is a name; allowed symbols are lower and
  upper case letters, digits, the `#` (sharp) symbol, the `/` and `_`,
  but first character must be a letter or a digit.

  For example, the piece
  
        x32010 =C
  
  stores chord C maj with the name `C`. If you want to recall a chord,
  write `+NAME` and the stored chord will be set.

  If you do not change the chord, it remains valid until the end or a new
  chord is set.

  Default chord is `x32010`.

* **DURATION.** The duration of a chord (and of a rest) is set with
  the `qN` command, where N is a number. It expresses the fraction of
  the "whole" note. The "whole" note is a 4/4, so for example `q4` sets
  a quarter note (1/4).

  Duration can be followed by a dot or two dots, the meaning is as the
  dot and double dot in the musical notation. For example, `q2.` is a
  note that lasts a full 3/4 measure.

* **STROKES.** Setting the chord or its duration *DOES NOT* play
  notes. To play the chord you have to use the stroke
  command. Basically there are two stroke command, that is `v` for
  down-stroke and `^` for up-stroke. Down-stroke is a stroke from the
  top to the bottom, i.e. from lower E to higher E (in
  pitch). Up-stroke from lower E to higher E (in pitch).

  The default velocity for a down-stroke is 96 and the default
  velocity for a up-stroke is 94 (i.e. up-strokes are a little bit
  weaker). You can play something like an accented down/up-stroke
  doubling the commando, for example `vv` and `^^`.

  Default velocity for a double down-stroke is 110, for a double
  up-stroke is 109 (almost the same).

  If you write `vvv` or `^^^` you mean a sforzando, the velocity is
  127.

  The only way you can modify these defaults is to change the values
  in the source code. Not so hard, even if you don't know anything
  about Perl. Just write a different value for `$velocity_*` (where
  `*` can be `_d`, `_d_a`, `_u`, `_u_a` and `_s`).

* **REST.** To insert a rest just write `p`. Be aware of the fact that
  `p p` does not insert two rests, but only one. The length of the
  rest depends on the last `q` command given, as for the length of the
  chord.

* **GUITAR TUNING.** You can override the standard guitar tuning using
  the command `tune`. Simply define a list of notes, using anglosaxon
  notation (C, D and so on), optionally followed by `#` or `b` and a
  number. The central C is C5 (MIDI key 60). For example
  `tune=E4E4E5E5B5E6`. Use the upper case, as in the example.


Very simple example
-------------------

    # BEGIN
    t=60 ts=4,2
    =C 320003 =G 133211 =F

    q4
    +C vv +F v +C v +G v +C vv
    # EOF


Usage
-----

From the command line, redirect the input and the output as you
prefer. For example a command line could be:

    gmidi.pl <test.txt >test.mid

A good idea, maybe, could be to create a file where all common chords are
defined, so you can do something like

    cat chord-definition.txt test.txt |gmidi.pl >test.mid


