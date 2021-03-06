//// 53-EDO input using a nanoPAD 2

MIDIClient.init;
MIDIIn.connectAll;

// Check the keys
( var notes, on, off;
notes = Array.newClear(128);

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	("on" + num + veloc).postln;
    notes[num] = Synth(\default, [\freq, num.midicps,
        \amp, veloc * 0.00315]);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
	("on" + num + veloc).postln;
    notes[num].release;
});
c = MIDIFunc.cc({|val, num, chan, src| [val, num, chan].postln}, 1); // match cc 1-10

)

// SOUND SETUP

(

// load synthdefs from file
"nanoPad_synthdefs.scd".loadRelative;

SynthDef(\feedback_delay, { | inBus, outBus = 0, delaytime = 0.2, feedback = 0.3, mix = 0.3|
	var in, src, sig, feed;
	in = In.ar(inBus, 2);
	feed = LocalIn.ar(2);
	// XFadeDelay from wslib quark, to avoid artificts when changing delaytime
	src = Limiter.ar(XFadeDelay.ar(in + feed, 1, delaytime));
	LocalOut.ar(src * feedback);
	sig = Mix([src * mix, in * (1-mix)]);

	Out.ar(outBus, Pan2.ar(sig));
}).add;

{
	// OPTIONS
	~changeNoteEveryChange = true;
	~synthName = \sine_lead;

	~startSynth = { | freq |
		Synth(\sine_lead, [\freq, freq, \amp, 1, \out, ~delBus, \revOut, ~revBus, \buf, ~wt_buf[0], \numBufs, 10, \pressure, ~pressure, \atk, 0.001, \c0, -2]);
	};

	/*~startSynth = { | freq |
	Synth(\string_dist, [\freq, freq, \amp, 0.2, \outBus, ~delBus, \revOut, ~revBus, \cutoffr, 2500, \pressure, 0.6]);
	};*/

	/*~startSynth = { | freq |
	Synth(\glitter4, [\freq, freq, \amp, 0.2, \outBus, ~delBus, \chorusOut, ~chorusBus, \pressure, 0.9]);
	};*/

	~synthLookup = Dictionary.with(*[
		\51->{ | freq |
			Synth(\sine_lead, [\freq, freq, \amp, 1, \out, ~delBus, \revOut, ~revBus, \buf, ~wt_buf[0], \numBufs, 10, \pressure, ~pressure, \atk, 0.001, \c0, -2]);
		},
		\49->{ | freq |
			Synth(\string_dist, [\freq, freq, \amp, 0.2, \outBus, ~delBus, \revOut, ~revBus, \cutoffr, 5500, \pressure, ~pressure]);
		},
		\47->{ | freq |
			Synth(\glitter4, [\freq, freq, \amp, 0.2, \outBus, ~delBus, \chorusOut, ~chorusBus, \pressure, ~pressure]);
		}
	]);

	// Note names and what ratios they approximate starting at C incl. ups and downs notation
	~noteNameLookup = Dictionary.with(*[
		\0->"C",
		\1 -> "^C (81/80)",
		\2 -> "^^C, Dbvv (128/125)",
		\3 -> "vDb (27/26)",
		\4 -> "Db (21/20, 256/243)",
		\5 -> "^Db (16/15, 15/14)",
		\6 -> "^^Db (14/13, 13/12)",
		\7 -> "vvD (12/11, 11/10)",
		\8 -> "vD (10/9)",
		\9 -> "D (9/8)",
		\10 -> "^D (14/13, 13/12, 27/25)",
		\11 -> "^^D, vvEb (15/13)",
		\12 -> "vEb (7/6)",
		\13 -> "Eb (13/11, 32/27)",
		\14 -> "^Eb (6/5)",
		\15 -> "^^Eb (11/9)",
		\16 -> "vvE (16/13)",
		\17 -> "vE (5/4)",
		\18 -> "E (81/64)",
		\19 -> "^E (9/7, 14/11)",
		\20 -> "^^E, vvF (13/10)",
		\21 -> "vF (21/16)",
		\22 -> "F (4/3)",
		\23 -> "^F (27/20)",
		\24 -> "^^F (11/8)",
		\25 -> "vvF#, vGb (18/13)",
		\26 -> "vF#, Gb (7/5, 45/32)",
		\27 -> "F#, ^Gb (10/7)",
		\28 -> "^F#, ^^Gb (13/9)",
		\29 -> "vvG (16/11)",
		\30 -> "vG (40/27)",
		\31 -> "G (3/2)",
		\32 -> "^G (32/21, 243/160)",
		\33 -> "^^G, vvAb (20/13)",
		\34 -> "vAb (14/9, 11/7)",
		\35 -> "Ab (128/81)",
		\36 -> "^Ab (8/5)",
		\37 -> "^^Ab (13/8)",
		\38 -> "vvA (18/11).stringColor_(Color.grey(0.9))",
		\39 -> "vA (5/3)",
		\40 -> "A (22/13, 27/16)",
		\41 -> "^A (12/7)",
		\42 -> "^^A, vvBb (26/15)",
		\43 -> "vBb (7/4)",
		\44 -> "Bb (16/9)",
		\45 -> "^Bb (9/5)",
		\46 -> "^^Bb (11/6)",
		\47 -> "vvB (13/7)",
		\48 -> "vB (15/8)",
		\49 -> "B (40/21)",
		\50 -> "^B (48/25, 27/14)",
		\51 -> "^^B, vvC (125/64)",
		\52 -> "vC (160/81)"
	]);



	// SETUP
	~ratio53 = pow(2, 1/53);
	~rootFreq = 24.midicps;
	// Function to convert a degree in 53-EDO to a frequency
	~degree53_to_freq =  { |degree|
		var freq = ~rootFreq*pow(~ratio53, degree);
		freq
	};
	~delBus = Bus.audio(s, 2);
	~chorusBus = Bus.audio(s, 2);
	s.sync();
	~del = Synth(\feedback_delay, [\inBus, ~delBus, \outBus, 0, \delaytime, 0.2, \mix, 0.1, \feedback, 0.5]);
	~chorus = Synth(\chorus, [\outBus, 0, \inBus, ~chorusBus, \revBus, ~revBus, \revAmp, 0.4]);
	~sustain = false;
	~synth = nil!5; // one synth per octave
	~bits = false!5;
	~octave = 0;
	~octaves = Dictionary[];
	5.do{|i| ~octaves.put(i, false); };
	~note = 0;
	// map midiNotes to indexes in the bit array
	~bit_lookup = Dictionary.with(*[\50->0,\48->1,\46->2, \44->3, \42->4]);
	// ~octave_lookup = Dictionary.with(*[\21->1, \23->2, \24->3, \26->4, \28->5]);
	~octave_lookup = Dictionary.with(*[\37->2, \39->3, \41->4]);
	~added_notes_buttons = [40, 38, 36];
	~added_notes_values = [31, 9, 17];
	~added_notes_on = false!3;
	~added_notes_value = 0; // the combined value of all the ~added_notes_lookup button that are pressed down
	~fifth_midinote = 40;
	~fifth_on = false;
	~sustain_midinote = 43;
	~sustained_synths = List[];

	~drone_button = 45;
	~drone_on = false;
	~drone_synths = [];
	~start_drones = {
		~drone_synths.do{|syn| syn.free; };
		~drone_synths = [0, 53].collect {|degree| var freq = ~degree53_to_freq.(degree + (53*1));
			Synth(\sine_lead, [\freq, freq, \amp, 0.8, \out, ~delBus, \revOut, ~revBus, \buf, ~wt_buf[0], \numBufs, 10, \pressure, 0.3, \atk, 0.5, \rel, 2, \c0, -2]);
		};
	};



	~calculateBinaryNumber = { var result = 0;
		~bits.do{| activeBit, i |
			if(activeBit == true) {
				result = result + (2.pow(i));
			};
		};
		~added_notes_on.do{ |value, i|
			if(value) {
				result = result + ~added_notes_values[i];
			}
		};
		{
			~guiNoteNumber.string_(result.asInt.asString);
			~guiNoteName.string_(~noteNameLookup.at((result.asInt % 53).asSymbol));
			~guiView.refresh;
		}.defer;
		result
	};

	~playNote = { | degree | var freq;
		freq = ~degree53_to_freq.(degree + (53*~octave));
		if(freq > 30.0
			&& (freq < 10000)) {
			if(~sustain, {
				~sustained_synths.add(~startSynth.(freq));
			}, {
				~synth.size.do{|i|
					if(~octaves.at(i) == false, {
						~synth[i].release;
					}, {
						~synth[i].release;
						~synth[i] = ~startSynth.(freq);
					});
				};
			});
		};
		{~guiView.refresh; }.defer;
	};
	~updateNote = { | degree |
		~synth.do {|syn, i|
			var freq;
			if(~octaves.at(i) == true) {
				freq = ~degree53_to_freq.(degree + (53*i));
				~synth[i].set(\freq, freq);
				~synth[i].set(\pressure, ~pressure);
				//~sustained_synths[~sustained_synths.size-1].set(\freq, freq);
				{~guiView.refresh; }.defer;
			};
		};
	};
	~releaseNote = { | octave |
		~synth[octave].release;
		{~guiView.refresh; }.defer;
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

	MIDIFunc.cc({|val, num, chan, src|
		~pressure = val/127;
		~updateNote.(~note);

	}, 1);

	MIDIdef.noteOn(\test4, {arg ...args;
		var note = args[1],
		amp = args[0].linexp(0, 127, 0.001, 1.0),
		degree, bit, add, newSynth;

		bit = ~octave_lookup.at(note.asSymbol);
		if(bit != nil) {
			~octave = bit;
			~octaves.put(bit, true);
			~playNote.(~note);
		};

		bit = ~bit_lookup.at(note.asSymbol);
		("bit: " + bit).postln;
		if(bit != nil) {
			~bits[bit] = true;
			degree = ~calculateBinaryNumber.();
			~note = degree;

			("degree: " + (degree) + " mod53: " + (degree%53)).postln;
			if(~changeNoteEveryChange) {
				~updateNote.(~note);
			};
		};

		~added_notes_buttons.do{|button, i|
			if(button == note) {
				// Set button to on
				~added_notes_on[i] = true;
				// Update pitch
				degree = ~calculateBinaryNumber.();
				~note = degree;
				if(~changeNoteEveryChange) {
					~updateNote.(~note);
				};
			}
		};


		if(note == ~sustain_midinote) {
			~sustain = true;
		};

		// Check if synth should be changed
		newSynth = ~synthLookup.at(note.asSymbol);
		if(newSynth!=nil) {
			~startSynth = newSynth;
		};

		// Toggle drone
		if(note == ~drone_button) {
			if(~drone_on, {
				~drone_synths.do{|syn| syn.release; };
				~drone_on = false;
			}, {
				~start_drones.();
				~drone_on = true;
			});
		};
		// args.postln;


	}); // match any noteOn
	MIDIdef.noteOff(\test_off, {arg ...args;
		var note = args[1], degree, bit, add;
		bit = ~bit_lookup.at(note.asSymbol);
		if(bit != nil) {
			~bits[bit] = false;
			~note = ~calculateBinaryNumber.();
			if(~changeNoteEveryChange) {
				~updateNote.(~note);
			};
		};

		bit = ~octave_lookup.at(note.asSymbol);
		if(bit != nil) {
			~octave = 0;
			~octaves.put(bit, false);
			~releaseNote.(bit);
		};
		~added_notes_buttons.do{|button, i|
			if(button == note) {
				// Set button to off
				~added_notes_on[i] = false;
				// Update pitch
				degree = ~calculateBinaryNumber.();
				~note = degree;
				if(~changeNoteEveryChange) {
					~updateNote.(~note);
				};
			}
		};
		if(note == ~sustain_midinote) {
			~sustain = false;
			~sustained_synths.do{ |syn| syn.release; };
			~sustained_synths = List[];
		};
		args.postln;
	}); // match any noteOn
	// sustain pedal
	MIDIdef.cc(\sustainPedal, {arg ...args;
		var vel = args[0];
		if(vel == 0) {
			~sustain = false;
		};
		if(vel == 127) {
			~sustain = true;
		};
		args.postln

	}, 64); // match cc 1-10

	// load GUI
	"nanoPad_53-edo_5th_octaves_gui.scd".loadRelative;
}.fork;
)

~octaves
~start_drones.()