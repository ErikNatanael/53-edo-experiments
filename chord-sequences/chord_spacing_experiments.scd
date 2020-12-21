/* EXPERIMENTS ON CHORD DENSITY AND CONSONANCE


*/
// INIT
(
~ratio53 = pow(2, 1/53);
~rootFreq = 0.midicps;
// Function to convert a degree in 53-EDO to a frequency
~degree53_to_freq =  { |degree, rootFreq = 8|
    var freq = rootFreq*pow(~ratio53, degree);
    freq
};
~padSynths = [];
~launchChord = { | length, octave = 5 |
	{
		~padSynths = ~chord.collect{ |degree|
			{
				SinOsc.ar(~degree53_to_freq.value(degree + (53*octave), ~rootFreq), 0, 0.05)!2 * Env.perc(0.1, length).kr(2);
			}.play;
			0.2.wait;
		};
	}.fork;
};
~launchChordRandomOrder = { | length, octave = 5 | var scrambledChord = ~chord;
	scrambledChord = scrambledChord.scramble;
	{
		~padSynths = scrambledChord.collect{ |degree|
			{
				SinOsc.ar(~degree53_to_freq.value(degree + (53*octave), ~rootFreq), 0, 0.05)!2 * Env.perc(0.1, length).kr(2);
			}.play;
			0.1.wait;
		};
	}.fork;
};
)

// stacked thirds
( var lastNote = 0, chordFreqs;
~chord = 20.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%2,
			1, {17},
			0, {14}
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 4);
)
~launchChordRandomOrder.(2, 4)

// major chord
( var lastNote = 0, chordFreqs;
~chord = 20.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%3,
			1, {17},
			2, {14},
			0, {22},
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 4);
)
~launchChordRandomOrder.(2, 4)

// maj7 chord
( var lastNote = 0, chordFreqs;
~chord = 24.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%4,
			1, {17},
			2, {14},
			3, {17},
			0, {5}
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 4);
)
~launchChordRandomOrder.(2, 4)

//
( var lastNote = 0, chordFreqs;
~chord = 12.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%3,
			1, {17},
			2, {14},
			0, {14},
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
~launchChord.(3, 4);
)

// m6 chord
( var lastNote = 0, chordFreqs;
~chord = 24.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%4,
			1, {14},
			2, {17},
			3, {9},
			0, {13}
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 4);
)
~launchChordRandomOrder.(2, 4)

// major 6/9 chord
( var lastNote = 0, chordFreqs;
~chord = 32.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%5,
			1, {9},
			2, {8},
			3, {14},
			4, {9},
			0, {13}
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 4);
)
~launchChordRandomOrder.(2, 4)

// minor 6/9 chord
( var lastNote = 0, chordFreqs;
~chord = 32.collect{|i| var newNote;
	if(i == 0, {
		newNote = 0;
	}, {
		newNote = lastNote + switch(i%5,
			1, {9},
			2, {5},
			3, {17},
			4, {9},
			0, {13}
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 4);
)
~launchChordRandomOrder.(2, 4)

// major 6/9 maj7 chord
( var lastNote = 0, chordFreqs;
~chord = 32.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%6,
			1, {9},
			2, {8},
			3, {14},
			4, {9},
			5, {8},
			0, {5}
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
// ~launchChord.(3, 4);
)
~chord = ~chord - 9;
~launchChordRandomOrder.(2, 4)

// major scale
( var lastNote = 0, chordFreqs;
~chord = 32.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%7,
			1, {9},
			2, {8},
			3, {5},
			4, {9},
			5, {9},
			6, {8},
			0, {5}
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 4);
)
~launchChordRandomOrder.(2, 4)

// minor scale
( var lastNote = 0, chordFreqs;
~chord = 8.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%7,
			1, {9},
			2, {5},
			3, {8},
			4, {9},
			5, {5},
			6, {9},
			0, {8}
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*6), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 6);
)
~launchChordRandomOrder.(2, 4)

// traditional chromatic scale
( var lastNote = 0, chordFreqs;
~chord = 25.collect{|i| var newNote;
	if(i == 0, {
		newNote = lastNote;
	}, {
		newNote = lastNote + switch(i%12,
			1, {5},
			2, {4},
			3, {4},
			4, {4},
			5, {5},
			6, {4},
			7, {5},
			8, {4},
			9, {5},
			10, {4},
			11, {4},
			0, {5}
		);
	});
	lastNote = newNote;
	newNote
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 4);
)
~launchChordRandomOrder.(2, 4)

// 53-EDO chromatic scale
( var lastNote = 0, chordFreqs;
~chord = 106.collect{|i| var newNote;
	i
};
("chord: " + ~chord).postln;
chordFreqs = ~chord.collect{|degree| ~degree53_to_freq.value(degree + (53*4), ~rootFreq) };
("chord freqs:" + chordFreqs).postln;
chordFreqs.do { |fr|
	fr.postln;
};
~launchChord.(3, 4);
)
~launchChordRandomOrder.(2, 4)

~chord = [0, 17, 31, 43, 57, 74, 88, 106, 120, 137, 151, 163];
~launchChord.(3, 4);

120 + 36 + 14

163-106
