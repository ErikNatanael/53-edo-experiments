(
MIDIClient.init;
MIDIIn.connectAll;
)
( // less inharmonic
SynthDef(\bell, {
	|freq=1, t60=1, pitchy=1, amp=0.25, gate=1|
	var sig, exciter, env;

	env = EnvGen.ar(
		Env.adsr(\atk.kr(0.01), 0.3, 0.5, 0.5),
		gate: gate + Impulse.kr(0),
		doneAction:2
	);

	//exciter = Impulse.ar(0);
	exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.25;
	sig = Klank.ar(
		`[
			[1, 2, 3, 4, 5.074, 8, 11, 14.421],   // freqs
			[1, 0.044, 0.391, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 0.2, 0.196, 0.209, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale:freq*pitchy);
	sig = FreeVerb.ar(sig, 0.05) * amp * env;
	DetectSilence.ar(sig, 0.001, 0.5, doneAction:2);
	Out.ar(0, sig!2);
}).add;
SynthDef(\sine_bell, {
	|freq=1, t60=1, pitchy=1, amp=0.25, gate=1|
	var sig, exciter, env;

	env = EnvGen.ar(
		Env.adsr(\atk.kr(0.01), 0.3, 0.5, 0.5),
		gate: gate + Impulse.kr(0),
		doneAction:2
	);

	//exciter = Impulse.ar(0);
	exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.25;
	sig = Klank.ar(
		`[
			[1, 2, 3, 4, 5.074, 8, 11, 14.421],   // freqs
			[1, 0.044, 0.391, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 0.2, 0.196, 0.209, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale:freq*pitchy);
	sig = (sig*0.5) + (SinOsc.ar(freq)*0.5);
	sig = FreeVerb.ar(sig, 0.05) * amp * env;
	DetectSilence.ar(sig, 0.001, 0.5, doneAction:2);
	Out.ar(0, sig!2);
}).add;
)

(
~ratio53 = pow(2, 1/53);
~rootFreq = 60.midicps;
// Function to convert a degree in 53-EDO to a frequency
~degree53_to_freq =  { |degree|
    var freq = ~rootFreq*pow(~ratio53, degree);
    freq
};

~synths.do{|syn| syn.free };
~synths = nil!127;

~sustain = false;
~releaseAfterSustain = false!127;

MIDIdef.noteOn(\test4, {arg ...args;
	var note = args[1],
	amp = args[0].linexp(0, 127, 0.001, 1.0);
	// ("amp: " + amp + " freq: " + ~degree53_to_freq.(note)).postln;
	("degree: " + (note-21)).postln;

	// args.postln;
	~synths[note].release;
	~synths[note] = Synth(\sine_bell, [\freq, ~degree53_to_freq.(note), \amp, amp, \t60, 20]);
	~releaseAfterSustain[note] = false;

}); // match any noteOn
MIDIdef.noteOff(\test_off, {arg ...args;
	var note = args[1];
	if(~sustain == false, {
		~synths[note].release;
	}, {
		~releaseAfterSustain[note] = true;
	});
	args.postln;
}); // match any noteOn
// sustain pedal
MIDIdef.cc(\sustainPedal, {arg ...args;
	var vel = args[0];
	if(vel == 0) {
		~sustain = false;
		~releaseAfterSustain.do{ | doRelease, i |
			if(doRelease) {
				~synths[i].release;
			};
		};
	};
	if(vel == 127) {
		~sustain = true;
	};
	args.postln

}, 64); // match cc 1-10

)
MIDIdef.cc(\test3, {arg ...args; args.postln}, 64); // match cc 1-10
Synth(\bell, [\fs, 60.midicps, \t60, 9.177, \pitchy, 1]);

(
SynthDef(\testdef, {
    var sig, env;

    Out.ar(\out.kr(0)
}).add;
)

