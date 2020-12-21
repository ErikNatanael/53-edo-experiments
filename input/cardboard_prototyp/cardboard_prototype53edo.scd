
// SOUND SETUP

(

// load synthdefs from file
"synthdefs.scd".loadRelative;

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
	~lastNote = 0;
	// map midiNotes to indexes in the bit array
	~bit_lookup = Dictionary.with(*[\50->0,\48->1,\46->2, \44->3, \42->4]);
	// ~octave_lookup = Dictionary.with(*[\21->1, \23->2, \24->3, \26->4, \28->5]);
	~octave_lookup = Dictionary.with(*[\37->2, \39->3, \41->4]);
	~added_notes_values = [31, 9, 17, 5];
	~added_notes_on = false!4;
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

	~playNote = { var freq, degree = ~note;
		if(~sustain, {
			~sustained_synths.add(~startSynth.(freq));
		}, {
			~synth.size.do{|i|
				if(~octaves.at(i) == false, {
					~synth[i].release;
				}, {
					~synth[i].release;
					~synth[i] = ~startSynth.(~degree53_to_freq.(degree + (53*(i+2))););
				});
			};
		});
		{~guiView.refresh; }.defer;
	};
	~updateNote = { var degree = ~note;
		if(degree != ~lastNote) {
			~synth.do {|syn, i|
				var freq;
				if(~octaves.at(i) == true) {
					freq = ~degree53_to_freq.(degree + (53*(i+2)));
					~synth[i].set(\freq, freq);
					~synth[i].set(\pressure, ~pressure);
					//~sustained_synths[~sustained_synths.size-1].set(\freq, freq);
					{~guiView.refresh; }.defer;
				};
			};
			~lastNote = ~note;
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


	// load GUI
	"gui.scd".loadRelative;
}.fork;
)

// Get input from serial
( var port,
thresh = 100, on_actions, off_actions, octave_on_action, octave_off_action;
~ofAddr = NetAddr("127.0.0.1", 12000);

// 0: fifth
// 1: extra 1
// 8: extra 2
// 7: extra 3

// 4: bit 0
// 5: bit 1
// 6: bit 2
// 2: bit 3
// 3: bit 4

// 9: octave 1
// 11: octave 2
// 10: octave 3

octave_on_action = { | octave |
	var val = ~octaves.at(octave);
	if(val == false) {
		~octaves.put(octave, true);
		~playNote.();
	};
};

octave_off_action = { | octave |
	var val = ~octaves.at(octave);
	if(val == true) {
		~octaves.put(octave, false);
		~playNote.();
	};
};

on_actions = Dictionary.with(*[
	\0 -> { ~added_notes_on[0] = true; },
	\1 -> { ~added_notes_on[1] = true; },
	\8 -> { ~added_notes_on[2] = true; },
	\7 -> { ~added_notes_on[3] = true; },

	\4 -> { ~bits[0] = true },
	\5 -> { ~bits[1] = true },
	\6 -> { ~bits[2] = true },
	\2 -> { ~bits[3] = true },
	\3 -> { ~bits[4] = true },

	\9 -> { octave_on_action.(0) },
	\11 -> { octave_on_action.(1) },
	\10 -> { octave_on_action.(2) },
]);

off_actions = Dictionary.with(*[
	\0-> { ~added_notes_on[0] = false; },
	\1 -> { ~added_notes_on[1] = false; },
	\8 -> { ~added_notes_on[2] = false; },
	\7 -> { ~added_notes_on[3] = false; },

	\4 -> { ~bits[0] = false },
	\5 -> { ~bits[1] = false },
	\6 -> { ~bits[2] = false },
	\2 -> { ~bits[3] = false },
	\3 -> { ~bits[4] = false },

	\9 -> { octave_off_action.(0) },
	\11 -> { octave_off_action.(1) },
	\10 -> { octave_off_action.(2) },
]);

{
	SerialPort.closeAll;
	1.0.wait;
	port = SerialPort.devices[0];
	("Connecting to " + port).postln;
	p = SerialPort(
		port,
		baudrate: 115200,
		crtscts: true);

	~readLoop = fork {
		var byte, str, capLPF = 0, timeScale = 0, sensors = nil;
		loop{|i|
			if(p.read==10, { var amp, knob, capValue, dustAmp = 0.0, functionCallAmp = 0.0, valueWidth;
				str = "";
				while({byte = p.read; byte !=13 }, {
					str= str++byte.asAscii;
				});
				sensors = str.split($ );

				sensors.do{ |sensor, i|
					if(sensor.asInt > thresh, {
						// sensors is on
						on_actions.at(i.asSymbol).();
					}, {
						// sensor is off
						off_actions.at(i.asSymbol).();
					});
				};

				~note = ~calculateBinaryNumber.();
				~updateNote.();

			});
		};

	};
}.fork;
)
