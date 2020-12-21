SynthDef(\sine_lead, {
	arg buf=0, numBufs = 1, freq=200,
	amp=0.2, pan=0, revOut=0,
	atk=0.001, sus=0.01, rel=0.01, c0=1, c1=(-1);
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

SynthDef(\string_dist, { | outBus = 0, freq = 440, amp = 1, gate = 1, attack = 0.01, decay = 0.5, cutoffr = 2500, pressure = 0.3 |
	var sig, env, cutoff, filter2, cutoff2, dist;

	env = EnvGen.kr(Env(
		levels: [0, 1, 0.5, 0],
		times: [max(attack, 0.05), 0.8, decay],
		curve: ~curve,
		releaseNode: 2),
		gate: gate,
		doneAction: 2);

	freq = freq* (([-0.1, -0.2, -0.3, 0, 0.1, 0.2, 0.3] * 0.25).midiratio);

	sig = Saw.ar(freq);

	sig = (sig*100000).tanh;
	sig = Mix(sig);


	cutoff2 = LFNoise1.kr([0.1, 0.3, 0.4]).range([400, 2000, 2000], [3000, 4000, 5000]);
	filter2 = RLPF.ar(sig, cutoff2, [0.1, 0.2, 0.5]);
	filter2 = Mix(filter2)/3;

	//cutoff = XLine.kr(200, LFNoise1.kr(0.2).range(1000, 2500), 2);
	cutoff = pressure.linexp(0, 1, 200, 2500);
	sig = LPF.ar(sig, cutoff);
	//sig = DFM1.ar(sig, cutoff, 0.15);

	sig = sig + (filter2*0.3);

	dist = sig.tanh;
	sig = sig + (dist * LFNoise1.kr(0.5).range(0.01, 0.2));


	sig = (CombN.ar( sig * XLine.kr(0.001, 1, 0.2), 0.4, [0.3,0.25],2) * 0.3) + (sig * 0.6); // Stolen from BMoog helpfile
	sig = RLPF.ar(sig, cutoff, 0.2);

	sig = sig * env * Lag2.kr(amp, 0.01) * 0.06;
	sig = Pan2.ar(sig);
	Out.ar(outBus, sig);
	Out.ar(\revOut.kr(10), sig*\revMix.kr(0));
}).add;
SynthDef(\glitter4, { |outBus = 0, chorusBus, amp = 0.5, freq = 440, attack = 0.005, decay = 1, gate = 1, pressure = 0.3 |

	var sig, env, env2, osc1, osc2, osc3, ffreq, filterenv, freqtrack, chorus, fdbIn, fdbOut, csig, toChorus;

	env = EnvGen.kr(Env(
		levels: [0, 1, 1, 0],
		times: [attack, 0.001, decay],
		curve: ~curve,
		releaseNode: 2),
	gate: gate,
	doneAction: 2
	);
	filterenv = EnvGen.kr(Env(
		levels: [0, 1, 0.9, 1.1],
		times: [0.001, 0.001, decay/2],
		releaseNode: 2),
	gate: gate
	);

	freq = freq * 4;

	osc1 = Saw.ar(min(freq*[4, 4.001, 4.002, 3.999] * SinOsc.kr(6).range(1, 1.0057), 20000)) * 0.4 * 0.5;
	Decay.kr(osc1, 0.3);
	osc1 = Mix(osc1);

	osc2 = SinOsc.ar(freq) * SinOsc.kr(4, 0.5pi).range(0.1, 0.2);
	osc2 = Mix(osc2);

	/*osc3 = Klank.ar(`[
		[2000, 4100, 6000, 8000, 10000, 12000],
		nil,
		[1, 0.1, 0.2, 4, 5, 2]],
	Impulse.ar(0) * 0.1,
	freq*0.0015
	);*/


	sig = osc1 + osc2; // + osc3;
	freqtrack = 0.2;
	ffreq = XLine.kr(4000 + (freq*freqtrack), 1300 + (freq*freqtrack), 0.3);
	ffreq = ffreq * SinOsc.kr(1.64).range(1, 1.42)*filterenv;

	sig = BLowPass4.ar(sig, min(ffreq, 18000));
	sig = sig*env;

	//Chorus (flytta ut till effektsynt!)
	/*in = sig;
	lo = LPF.ar(in, crossover);
	hi = HPF.ar(in, crossover);
	lo = DelayL.ar(lo, 0.1, SinOsc.kr(speed, ph_diff, depth, predelay));
	hi = Array.fill(numChan, { |i|
		predelay = predelay + depth;
		DelayL.ar(hi, 0.5, SinOsc.kr(speed, ph_diff * i, depth, predelay));
	}).scramble;
	lo = lo + hi;
	sig = (sig*XLine.kr(1, 0.5, 0.3)) + (XFade2.ar(in, lo, xfade * 2 - 1) * XLine.kr(0.01, 1, 0.3));*/

	//sig = Mix(sig);
	sig = Pan2.ar(sig*amp*0.5);
	toChorus = sig * XLine.kr(0.01, 1, 0.3) * pressure;
	sig = sig*XLine.kr(1, 0.5, 0.3);

	Out.ar(chorusBus, toChorus);

	Out.ar(outBus, sig);
	Out.ar(\revOut.kr(10), sig*\revMix.kr(0));
}).add;
SynthDef(\chorus, { | outBus = 0, inBus, revBus, revAmp = 0.5, amp = 1 |
	var sig, in, lo, hi, predelay = 0.05, speed = 0.1, depth = 0.02, ph_diff = 0.5pi, crossover = 200, xfade = 0.5, numChan=2;

	in = In.ar(inBus, numChan);
	lo = LPF.ar(in, crossover);
	hi = HPF.ar(in, crossover);
	lo = DelayL.ar(lo, 0.1, SinOsc.kr(speed, ph_diff, depth, predelay));
	hi = Array.fill(numChan, { |i|
		predelay = predelay + depth;
		DelayL.ar(hi, 0.5, SinOsc.kr(speed, ph_diff * i, depth, predelay));
	}).scramble;
	lo = lo + hi;
	sig = lo;

	Out.ar(outBus, sig*amp);
	Out.ar(revBus, sig*revAmp);
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