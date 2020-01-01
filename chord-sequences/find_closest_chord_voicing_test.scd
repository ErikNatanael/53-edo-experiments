
// 53-EDO stuff
(
~ratio53 = pow(2, 1/53);
~rootFreq = 0.midicps;
// Function to convert a degree in 53-EDO to a frequency
~degree53_to_freq =  { |degree, rootFreq = 8.1757989156437|
    var freq = rootFreq*pow(~ratio53, degree);
    freq
};


~degree53_to_freq.value(53, 10);
~chord = [0, 17, 31, 53];
~chords = List[
	[0, 17, 31, 53],
	[0,39,22, 53],
	[31,9,49, 62],
];
)

// All setup code and wavetables are by Eli Fieldsteel
// https://sccode.org/1-5bF
(
//cleanup
Pdef.all.do(_.clear);
Pbindef.all.do(_.clear);
~wt_buf.do(_.free);
t.stop;
ServerTree.remove(~add_reverb);

//initialization
s = Server.local;
t = TempoClock.new(90/60).permanent_(true);
s.newBusAllocators;
~rbus = Bus.audio(s,2);

s.waitForBoot({

	//10 wavetables with increasing complexitymovementRecord
	~wt_sig = 10.collect({
		arg i;

		//random number of envelope segments
		var numSegs = i.linexp(0,9,4,40).round;

		Env(
			//env always begins and ends with zero
			//inner points are random from -1.0 to 1.0
			[0]++({1.0.rand}.dup(numSegs-1) * [1,-1]).scramble++[0],

			//greater segment duration variety in higher-index wavetables
			{exprand(1,i.linexp(0,9,1,50))}.dup(numSegs),

			//low-index wavetables tend to be sinusoidal
			//high index wavetables tend to have sharp angles and corners
			{[\sine,0,exprand(1,20) * [1,-1].choose].wchoose([9-i,3,i].normalizeSum)}.dup(numSegs)
		).asSignal(1024);
	});

	//load into 10 buffers in wavetable format
	~wt_buf = Buffer.allocConsecutive(10, s, 2048, 1, {
		arg buf, index;
		buf.setnMsg(0, ~wt_sig[index].asWavetable);
	});

	SynthDef(\osc, {
		arg buf=0, freq=200, detune=0.2,
		amp=0.2, pan=0, out=0, rout=0, rsend=(-20),
		atk=0.01, sus=1, rel=0.01, c0=1, c1=(-1);
		var sig, env, detuneCtrl;
		env = EnvGen.ar(
			Env([0,1,1,0],[atk,sus,rel],[c0,0,c1]),
			doneAction:2
		);

		//array of eight Oscs with uniquely detune frequencies
		//and unique initial phase offsets
		detuneCtrl = LFNoise1.kr(0.1!8).bipolar(detune).midiratio;
		sig = Osc.ar(buf, freq * detuneCtrl, {Rand(0,2pi)}!8);

		sig = Splay.ar(sig); //spread 8 signals over stereo field
		sig = LeakDC.ar(sig); //remove DC bias
		sig = Balance2.ar(sig[0], sig[1], pan, amp); //L/R balance (pan)
		sig = sig * env;
		Out.ar(out, sig);
		Out.ar(rout, sig * rsend.dbamp); //"post-fader" send to reverb
	}).add;

	SynthDef(\sus_osc, {
		arg buf=0, freq=200, detune=0.2,
		amp=0.2, pan=0, out=0, rout=0, rsend=(-20),
		atk=0.01, sus=1, rel=0.01, c0=1, c1=(-1);
		var sig, env, detuneCtrl;
		amp = Lag.kr(amp, 0.5);
		freq = Lag.kr(freq, \portamento.kr(0.1));
		env = EnvGen.ar(
			Env([0,1,1,0],[atk,sus,rel],[c0,0,c1], releaseNode: 1),
			gate: \gate.kr(1),
			doneAction:2
		);

		//array of eight Oscs with uniquely detune frequencies
		//and unique initial phase offsets
		detuneCtrl = LFNoise1.kr(0.1!8).bipolar(detune).midiratio;
		sig = Osc.ar(buf, freq * detuneCtrl, {Rand(0,2pi)}!8);

		sig = Splay.ar(sig); //spread 8 signals over stereo field
		sig = LeakDC.ar(sig); //remove DC bias
		sig = Balance2.ar(sig[0], sig[1], pan, amp); //L/R balance (pan)
		sig = sig * env;
		Out.ar(out, sig);
		Out.ar(rout, sig * rsend.dbamp); //"post-fader" send to reverb
	}).add;

	SynthDef(\reverb, {
		arg in=0, out=0, dec=1, lpf=1500;
		var sig;
		sig = In.ar(in, 2).sum;
		sig = DelayN.ar(sig, 0.03, 0.03);
		sig = CombN.ar(sig, 0.1, {Rand(0.01,0.099)}!32, dec);
		sig = SplayAz.ar(2, sig);
		sig = LPF.ar(sig, lpf);
		5.do{sig = AllpassN.ar(sig, 0.1, {Rand(0.01,0.099)}!2, 3)};
		sig = LPF.ar(sig, lpf);
		sig = LeakDC.ar(sig);
		Out.ar(out, sig);
	}).add;

	s.sync;

	//instantiate reverb and re-instantiate when cmd-period is pressed
	~add_reverb = {Synth(\reverb, [\in, ~rbus])};
	ServerTree.add(~add_reverb);
	s.freeAll;

	s.sync;

});
)

(
s.newBusAllocators;
~rbus = Bus.audio(s,2);
Synth(\reverb, [\in, ~rbus]);

~padSynths = [];
~launchChord = { | length, octave = 5 |
	{
		~padSynths = ~chord.collect{ |degree|
			/*Synth(\osc, [
			\freq, ~degree53_to_freq.value(degree + (53*octave), ~rootFreq),
			\atk, exprand(0.3, 1),
			\sus, 0,
			\rel, length + exprand(0.1, 1),
			\c0, exprand(1, 2),
			\c1, exprand(3, 6).neg,
			\detune, rrand(0.01, 0.05),
			\buf, ~wt_buf[0..2].choose,
			\amp, 0.05,
			\pan, rrand(-0.5, 0.5),
			\out, 0,
			\rout, ~rbus,
			\rsend, -10,
			]);*/
			{ var sig;
				sig = SinOsc.ar(~degree53_to_freq.value(degree + (53*octave), ~rootFreq), 0, 0.05)!2 * Env.perc(0.1, length).kr(2);
				Out.ar(0, sig);
				Out.ar(~rbus, sig*0.1);
			}.play;
			0.1.wait;
		};
	}.fork;
};
~findClosestVoicing = { | currentChord, newDegrees, edo = 53, minNote = -22, maxNote = 106 |
	var newChord;
	newChord = newDegrees.collect { | degree, i |
		var minDistance = 1000, minDistIndex = 0, minDistOctave, newNote;
		// find the note in the current chord that is closest to the new note from above or below
		currentChord.do { | note, i | var distance = 10000, old, new, oldOctave;
			// In SuperCollider -22%53 == 31 so % works for negative numbers (wrapping them to positive)
			// check octave of the chord note. The octave is stored as the offset in degrees, not number of octaves
			oldOctave = note - (note%edo);
			// bring both notes into the lowest octave
			old = note%edo;
			new = degree%edo;
			// check distance
			distance = abs(new-old);
			if(distance < minDistance) {
				minDistance = distance;
				minDistOctave = oldOctave;
				minDistIndex = i;
			};

			// reverse the order of the notes
			if(old < new, {
				// bring new note down an octave
				new = new - edo;
				oldOctave = oldOctave - edo;
			}, {
				// bring new note up an octave
				new = new + edo;
				oldOctave = oldOctave + edo;
			});

			// check distance again in the reversed interval
			distance = abs(new-old);
			if(distance < minDistance) {
				minDistance = distance;
				minDistOctave = oldOctave;
				minDistIndex = i;
			};
		};
		// return the new adjusted note
		newNote = (degree%edo) + minDistOctave;
		if(newNote > maxNote, {
			newNote = newNote - edo;
		});
		if(newNote < minNote, {
			newNote = newNote + edo;
		});
		newNote
	};
	newChord
};

~c = [0, 17, 31];
~f = [0, 22, 39];
~g = [9, 31, 48];
~dm = [9, 22, 39];
~chord = ~c;
)



~chord = ~c;
(
~chord = ~findClosestVoicing.(~chord, ~chord+22);
("chord: " + ~chord).postln;
~launchChord.(1);
)
// Simply moving in a dominant direction each step, quickly dropping to one step lower
// C F Bb1v Eb1v Ab1v Db1v Gb1v Cb E A1v D1v G1v C1v

~chord = ~c;
(
{
	4.do{
		~chord = ~findClosestVoicing.(~chord, ~chord+9);
		("chord: " + ~chord).postln;
		~launchChord.(1);
		1.wait;
		~chord = ~findClosestVoicing.(~chord, ~chord+22);
		("chord: " + ~chord).postln;
		~launchChord.(1);
		1.wait;
	};
}.fork;
)
//    D G A D |     E A B E
//D:  T S D T | E:  T S D T

// Transposes by 9 steps every time so the sequence will rise in pitch level


~chord = ~c;
(
{
	3.do{
		~chord = ~findClosestVoicing.(~chord, ~chord+31);
		("chord: " + ~chord).postln;
		~launchChord.(1);
		1.wait;
		~chord = ~findClosestVoicing.(~chord, ~chord+22);
		("chord: " + ~chord).postln;
		~launchChord.(1);
		1.wait;
	};
}.fork;
)

// G C G C G C
// Stable D T D T D T
// Alt:   T S T S T S

(
{
	~chord = ~c;
	3.do{ var root = ~chord[0];
		~chord = ~findClosestVoicing.(~chord, [0, 31, 17, 44] + root);
		("chord: " + ~chord).postln;
		~launchChord.(1);
		1.wait;
		~chord = ~findClosestVoicing.(~chord, [0, 31, 14]+22+root);
		("chord: " + ~chord).postln;
		~launchChord.(1);
		1.wait;
	};
	~chord = ~findClosestVoicing.(~chord, [0, 31, 17]+~chord[0]+5);
	("chord: " + ~chord).postln;
	~launchChord.(2);
	2.wait;
	~chord = ~findClosestVoicing.(~chord, [0, 31, 14]+~chord[0]-5);
	("chord: " + ~chord).postln;
	~launchChord.(2);
	2.wait;
	~chord = ~findClosestVoicing.(~chord, [0, 31, 17]+~chord[0]+31);
	("chord: " + ~chord).postln;
	~launchChord.(2);
	2.wait;
	~chord = ~findClosestVoicing.(~chord, [0, 31, 17]+~chord[0]+22);
	("chord: " + ~chord).postln;
	~launchChord.(2);
	2.wait;

}.fork;
)
// C7 Fm F7 Bbm Bb7 Ebm E Ebm Bb Eb

// Transposition wise this example is unclear
// a) The Eb at the end (13) is lower than the m3 of C which is 14. This is however not unexpected since in 12-EDO the just minor third is higher than the tempered minor third.
// b) The G in the Eb chord at the end (30) is 1 step lower compared to fifth above C (31), but this is also to be expected since just major thirds are lower than 12-EDO tempered ones.



// MOVING BY THIRDS

~chord = ~c;
(
~chord = ~findClosestVoicing.(~chord, ~chord+17);
("chord: " + ~chord).postln;
~launchChord.(2);
)
// E1v G#2v C2v E3v G#4v C4v etc.
// Moving by major 3rds lowers the pitch level by 2 steps per full revolution around the octave

~chord = ~c;
(
~chord = ~findClosestVoicing.(~chord, ~chord+14);
("chord: " + ~chord).postln;
~launchChord.(2);
)

// Eb1^ Gb2^ A2^  C3^ E1v F Bb1^ Db1^
// Moving by minor thirds quickly raises the pitch by 3 steps per full revolution around the octave.
// This is so much that when you're back around the octave the m3 Eb has turned into a M3 E compared to C (0)

~chord = ~c;
(
~chord = ~findClosestVoicing.(~chord, ~chord+13);
("chord: " + ~chord).postln;
~launchChord.(2);
)
// Moving by a low m3 (13) the pitch level instead drops by 1 step for every revolution around the octave.
// To compensate, every fourth 3rd needs to be just (14):
(
~chord = ~c;
{ var waitTime = 0.5;
	2.do {
		~chord = ~findClosestVoicing.(~chord, ~chord+14); ("chord: " + ~chord).postln;
		~launchChord.(2);
		waitTime.wait;
		3.do{
			~chord = ~findClosestVoicing.(~chord, ~chord+13); ("chord: " + ~chord).postln;
			~launchChord.(2);
			waitTime.wait;
		};
	};
}.fork;
)



// 9(harm7)
~chord = [0, 9, 17+53, 31, 43+53];
( var c = [0, 9, 17, 31, 43];
~chord = ~findClosestVoicing.(~chord, ~chord[0]+31 + c);
~chord.sort;
("chord: " + ~chord).postln;
~launchChord.(1);
)
// By sorting every round the lowest note falls into a regular pattern of -5 +9.
// This of course makes the pitch rise quite rapidly

// 9(harm7)
~chord = [0, 9, 17, 31, 43]+53;
( var c = [0, 9, 17, 31, 43];
~chord = ~findClosestVoicing.(~chord, ~chord[0]+31 + c);
// ~chord.sort;
("chord: " + ~chord).postln;
~launchChord.(1);
)
// G D A E B etc.
// Without sorting (and thereby changing the root of the chord) we get a regular movement in the dominant direction resulting in the pitch rising slowly over time. Interestingly though the pitch of the overall chord seems to fall much quicker than the rise in overall pitch level.



/// SEVENTHS

( // m(maj7) chord
// note the major seven (49) being only 4 steps from the root
~chord = [0, 14, 31, 49];
~launchChord.(2);
)

( // (maj7) chord
// here I prefer the "downmajor 7th", 15/8 which is 48
~chord = [0, 17, 31, 48];
~launchChord.(2);
)

( // 7 chord
// For a dominant seventh chord the 16/9 7th (44) has a stronger pull downwards
// The "upminor 7th" 9/5 (45) also sounds good
{
	~chord = [0, 17, 31, 44];
	// ~chord = [0, 17, 31, 45];
	~launchChord.(2);
	1.wait;
	~chord = [-22, 0, 17] + 22;
	~launchChord.(2);
}.fork;
)

( // m7 chord
// For m7 chords I much prefer the 45 steps minor 7th if the 7th isn't leading down to a major third
{
	~chord = [0, 14, 31, 44];
	// ~chord = [0, 14, 31, 45];
	~launchChord.(2);
	1.wait;
	~chord = [-22, 0, 17] + 22;
	~launchChord.(2);
}.fork;
)

( // harmonic 7 chord
// 7/4 minor 7 (43) is 4.759 cents off, but still useful
~chord = [0, 17, 31, 43];
~launchChord.(2);
)

