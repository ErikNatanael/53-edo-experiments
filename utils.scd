// utils.scd
// Contains functions that are useful to share among many different projects

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

~ratio53 = pow(2, 1/53);
~rootFreq = 0.midicps;
// Function to convert a degree in 53-EDO to a frequency
~degree53_to_freq =  { |degree|
	var freq = ~rootFreq*pow(~ratio53, degree);
	freq
};
~list53_to_freq =  { |degrees|
	var list = degrees.collect{|degree| ~rootFreq*pow(~ratio53, degree) };
	list
};
/* Could be modified to instead use
b = Scale.chromatic('et53')
b.degreeToFreq(212, 0.midicps, 5)
*/


~padSynths = [];
~launchChord = { | length, octave = 5 |
	{
		~padSynths = ~chord.collect{ |degree|
			{ var sig;
				sig = SinOsc.ar(~degree53_to_freq.value(degree + (53*octave), ~rootFreq), 0, 0.05)!2 * Env.perc(0.1, length).kr(2);
				Out.ar(0, sig);
				Out.ar(~rbus, sig*0.1);
			}.play;
			0.1.wait;
		};
	}.fork;
};
~initWavetables = {
	// Adapted from Eli Fieldsteel's tutorial
	//10 wavetables with increasing complexity
	~wt_sig = 10.collect({
		arg i;

		//random number of envelope segments
		//var numSegs = i.linexp(0,9,4,40).round;
		var numSegs = (i*4) + 4;

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
};
~initWavetables.();