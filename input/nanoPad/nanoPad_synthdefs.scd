SynthDef(\sine_lead, {
	arg buf=0, numBufs = 1, freq=200,
	amp=0.2, pan=0, revOut=0,
	atk=0.01, sus=0.01, rel=0.01, c0=1, c1=(-1);
	var sig, env, detuneCtrl, bufpos, pressure = \pressure.kr(0), excitation = \excitation.kr(0),
	detune = pressure * 0.1, jitterAmount = \jitterAmount.kr(0.0), ampJitter, noiseSig;
	env = EnvGen.ar(
		Env([0,1,1,0],[atk,sus,rel],[c0,0,c1], releaseNode: 1),
		\gate.kr(1),
		doneAction:2
	);
	ampJitter = LFNoise2.kr(10 + (jitterAmount*100)).range(0.5-(jitterAmount*0.5), 1.0);

	detuneCtrl = LFNoise1.kr(0.1!8).bipolar(detune).midiratio;
	//bufpos = buf + LFNoise1.kr(3).range(0, (numBufs-1));// * max(excitation, 0.2));
	// bufpos = buf + ( (numBufs-1.5) * ( (sin(pressure*30)*0.5) + 0.5) );
	bufpos = buf + LFNoise1.kr(3).range(0, (numBufs-1)*pressure);
	bufpos = max(min(bufpos, buf + numBufs-1.1), buf);
	sig = VOsc.ar(bufpos, freq * detuneCtrl, {Rand(0,2pi)}!8);

	sig = Splay.ar(sig); //spread 8 signals over stereo field
	sig = LeakDC.ar(sig); //remove DC bias
	sig = sig * ampJitter * 0.1;
	sig = Balance2.ar(sig[0], sig[1], pan); //L/R balance (pan)
	noiseSig = RHPF.ar(RLPF.ar(sig*0.1, freq, 0.02), freq, 0.01) * 0.01;
	noiseSig = noiseSig * ampJitter;
	sig = sig * env;
	Out.ar(\out.kr(0), sig*amp);
	//Out.ar(out, sig*amp);
	Out.ar(revOut, sig*amp*\revMix.kr(0));
	// Out.ar(\out2.kr(0), (noiseSig*(1-pressure)) + (sig * pressure));
}).add;

SynthDef(\noisepad, { |out = 0, amp = 0.5, freq = 440, gate = 1, attack = 0.01, decay = 0.1, roughness = 0.01, pressure = 0.3, pan = 0, freqLag = 0.2, fragAmount = 0.5, fragDensity = 10, focus = 0.01, maxRoughness = 1, minRoughness = 0, lpf = 10000 |

	var sig, env, unison, detune, freqs, noise, osc2, rough;
	unison = 7;
	detune = 0.03;
	detune = \detune.kr(0.001);//LFNoise2.kr(1/2).range(0.001, 0.05);
	rough = LFNoise1.kr(1).range(\minDist.kr(0), \maxDist.kr(1));
	roughness = LFNoise1.kr(0.2).range(minRoughness, maxRoughness);

	freq = freq.lag(freqLag);
	pan = pan.lag(1);

	freqs = unison.collect{|id| freq * (1 + detune*(id+1)) };
	//freqs = freqs.addAll(freq*[2, 4, 5, 6]);
	//freqs.poll;

	env = EnvGen.kr(Env(
		levels: [0, 1, 0.5, 0],
		times: [attack, 0.8, decay],
		curve: [0, 0, -7],
		releaseNode: 2),
		gate: gate,
		doneAction: 2);

	sig = Resonz.ar(BrownNoise.ar(), freqs, 0.001) * 2;

	//sig = RLPFD.ar(sig, freqs, 0.4, 0.1) * 3;
	sig = Mix(sig);
	sig = CombL.ar(sig, 0.2, freq.reciprocal, -3);

	osc2 = Resonz.ar(WhiteNoise.ar(), freq, 0.001) * 0.0001;
	osc2 = RLPF.ar(RHPF.ar(WhiteNoise.ar()*0.01, freqs, focus*2), freq, focus);
	osc2 = Mix(osc2);

	sig = (sig * roughness) +  (osc2 * (1 - roughness));

	sig = (sig * (1-rough)) + (DFM1.ar(sig, freq, rough, 1, 0.0, 0.005*rough)*0.5 * rough);
	//sig = sig + (DFM1.ar(sig, 100, 1.0, 20*rough).tanh);

	sig = (sig*(1-fragAmount)) + (sig * Lag.kr(Demand.kr(Dust.kr(fragDensity) + Impulse.kr(0), 0, Dseq([1, 0], inf)), 0.02) * fragAmount);
	sig = LPF.ar(sig, lpf.min(19000));


	Out.ar(out, Pan2.ar(sig, pan)*env*amp);
}).add;

SynthDef(\bell, {
	|freq=1, t60=1, pitchy=1, amp=0.25, gate=1|
	var sig, exciter, env;

	env = EnvGen.ar(
		Env.adsr(\atk.kr(0.1), 0.3, 0.5, 0.5),
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
		Env.adsr(\atk.kr(0.1), 0.3, 0.5, 0.5),
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