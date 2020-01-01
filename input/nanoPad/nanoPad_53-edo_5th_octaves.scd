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
		Synth(\sine_lead, [\freq, freq, \amp, 0.5, \out, ~delBus, \revOut, ~revBus, \buf, ~wt_buf[0], \numBufs, 10, \pressure, 0.3]);
	};



	// SETUP
	~ratio53 = pow(2, 1/53);
	~rootFreq = 24.midicps;
	// Function to convert a degree in 53-EDO to a frequency
	~degree53_to_freq =  { |degree|
		var freq = ~rootFreq*pow(~ratio53, degree);
		freq
	};
	~delBus = Bus.audio(s, 2);
	s.sync();
	~del = Synth(\feedback_delay, [\inBus, ~delBus, \outBus, 0, \delaytime, 0.2]);
	~sustain = false;
	~synth = nil!5; // one synth per octave
	~bits = false!5;
	~octave = 0;
	~note = 0;
	// map midiNotes to indexes in the bit array
	~bit_lookup = Dictionary.with(*[\50->0,\48->1,\46->2, \44->3, \42->4]);
	// ~octave_lookup = Dictionary.with(*[\21->1, \23->2, \24->3, \26->4, \28->5]);
	~octave_lookup = Dictionary.with(*[\36->1, \38->2, \37->3, \39->4, \41->5]);
	~fifth_midinote = 40;
	~fifth_on = false;
	~sustain_midinote = 43;
	~sustained_synths = List[];

	~calculateBinaryNumber = { var result = 0;
		~bits.do{| activeBit, i |
			if(activeBit == true) {
				result = result + (2.pow(i));
			};
		};
		if(~fifth_on == true, {
			result = result + 31;
		});
		result
	};

	~playNote = { | degree | var freq;
		freq = ~degree53_to_freq.(degree + (53*~octave));
		if(freq > 30.0
			&& (freq < 10000)) {
			if(~sustain, {
				~sustained_synths.add(~startSynth.(freq));
			}, {
				~synth[~octave-1].release;
				~synth[~octave-1] = ~startSynth.(freq);
			});
		};
	};
	~updateNote = { | degree | var freq;
		freq = ~degree53_to_freq.(degree + (53*~octave));
		~synth[~octave-1].set(\freq, freq);
		~sustained_synths[~sustained_synths.size-1].set(\freq, freq);
	};
	~releaseNote = { | octave |
		~synth[octave-1].release;
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

	MIDIdef.noteOn(\test4, {arg ...args;
		var note = args[1],
		amp = args[0].linexp(0, 127, 0.001, 1.0),
		degree, bit;

		bit = ~octave_lookup.at(note.asSymbol);
		if(bit != nil) {
			~octave = bit;
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


		if(note == ~fifth_midinote, {
			~fifth_on = true;
			degree = ~calculateBinaryNumber.();
			~note = degree;
			if(~changeNoteEveryChange) {
				~updateNote.(~note);
			};
		});

		if(note == ~sustain_midinote) {
			~sustain = true;
		};
		// args.postln;


	}); // match any noteOn
	MIDIdef.noteOff(\test_off, {arg ...args;
		var note = args[1], degree, bit;
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
			~releaseNote.(bit);
		};
		if(note == ~fifth_midinote, {
			~fifth_on = false;
			~note = ~calculateBinaryNumber.();
			if(~changeNoteEveryChange) {
				~updateNote.(~note);
			};
		});
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
}.fork;
)