// 140 Characters

{
    FreeVerb.ar(
        DelayC.ar(
            Saw.ar(110 * SinOsc.kr(3).range(0.99, 1.01), 0.06),
            0.6,
            0.2
        ),
        0.3,
        0.8
    )
}.play;


// Outside of 140 Characters
x=Synth(\g);
x.free;
s.freeAll;
s.boot;
