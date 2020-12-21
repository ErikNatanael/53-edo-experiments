(
{ var sig;
	sig = DC.ar(0);
	400.do { |i|
		sig = sig + SinOsc.ar(50 + i, Rand(0, 2pi), 1.0/400.0);
	};
	sig!2;
}.play;
)

(
{ var sig;
	sig = DC.ar(0);
	400.do { |i|
		sig = sig + SinOsc.ar(200 + i, Rand(0, 2pi), 1.0/400.0);
	};
	sig!2;
}.play;
)


(
{ var sig, lfo = LFNoise1.kr(0.5).range(0.5, 2.0);
	sig = DC.ar(0);
	400.do { |i|
		sig = sig + DPW3Tri.ar(50 + (i * lfo));
	};
	sig = sig/400;
	sig!2;
}.play;
)