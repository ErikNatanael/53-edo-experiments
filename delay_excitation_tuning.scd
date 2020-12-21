/*
If a frequency is played using a delay line with a length that is relatively far from an integer
that pitch will be very out of tune. How high can you go until the maximum pitch discrepancy gets too large?
*/


(
var freq = 10000,
samples = 44100/10000,
integerSamples = samples.round,
ratio = samples/integerSamples,
differenceInCents = 1200 * log2(ratio);
differenceInCents.postln;
)



(
~freqDifference =  { |freq|
	var samples = 44100/freq,
	integerSamples = samples.round,
	ratio = samples/integerSamples,
	differenceInCents = 1200 * log2(ratio);
	("diffCents: " ++ differenceInCents + "samples: " ++ samples).postln;
};
)
~freqDifference.(2000)
~freqDifference.(500)

// We can go about it the other way round: Whats the highest acceptable difference in cents
// and what is the lowest number n whose ratio n+0.5/n is less than that value in cents?

(
var highestCent = 1.0, i = 2, stillSearching = true;

while({stillSearching}, {
	var differenceInCents = 1200 * log2((i+0.5)/i);
	if(differenceInCents <= highestCent) {
		i.postln;
		stillSearching = false;
	};
	i = i + 1;
});
)

44100/866

// 50.92 would therefore be the ceiling for frequencies that are guaranteed to be accurate within 1 cent at 44100hz

// Let's try this out
(
{
	var freq = MouseX.kr(20, 10000, 'exponential'), pluck = Pluck.ar(WhiteNoise.ar * 0.5, Impulse.ar(10), freq.reciprocal, freq.reciprocal, 1.0),
	saw = Saw.ar(freq),
	manualPluck = CombL.ar(WhiteNoise.ar * 0.1, freq.reciprocal, freq.reciprocal),
	detectedFreq, hasFreq, differenceInCents;
	# detectedFreq, hasFreq = Pitch.kr(manualPluck, 440, 20, 10000, median: 10);
	detectedFreq.poll;
	differenceInCents = (detectedFreq/freq).log2 * 1200;
	differenceInCents.poll;
}.play;
)

// Test how audible this is at different integer sample delays
(
{
var delayInSamples = MouseX.kr(4, 866, 'exponential').floor + 0.5,
	freq = 44100/delayInSamples,
	pluck = Pluck.ar(WhiteNoise.ar * 0.5, Impulse.ar(5), 0.5, freq.reciprocal, 3.0, 0.001) * 0.1,
	manualPluck = CombL.ar(WhiteNoise.ar * 0.1, 0.5, freq.reciprocal) * 0.5,
	saw = Saw.ar(freq) * 0.05,
	sig = [pluck, saw];
	delayInSamples.poll;

	sig;
}.play;
)

(
{ var sig = DC.ar(0), delayInSamples = MouseX.kr(4, 866, 'exponential').floor + 0.5,
	freq = 44100/delayInSamples;
	sig = sig + (Pluck.ar(WhiteNoise.ar * 0.5, Impulse.ar(2.5), 0.5, (freq).reciprocal, 3.0, 0.001) * 0.1);
	sig = sig + (Pluck.ar(WhiteNoise.ar * 0.5, DelayN.ar(Impulse.ar(2.5), 0.5, 0.2), 0.5, (freq*1.5).reciprocal, 3.0, 0.001) * 0.1);
	sig!2
}.play;
)

// Compare it with a 5th of 700 cents

(
{ var sig = DC.ar(0), freq = MouseX.kr(1, 9).floor.linexp(1, 9, 50, 5000), ratio = MouseY.kr(1.493986, 1.5);
	sig = sig + (Pluck.ar(WhiteNoise.ar * 0.5, Impulse.ar(2.5), 0.5, (freq).reciprocal, 3.0, 0.001) * 0.1);
	sig = sig + (Pluck.ar(WhiteNoise.ar * 0.5, DelayN.ar(Impulse.ar(2.5), 0.5, 0.2), 0.5, (freq*ratio).reciprocal, 3.0, 0.001) * 0.1);
	sig!2
}.play;
)

( // and manually using a comb filter instead
// There is quite a big difference compared to Pluck. With the Comb filter there
// doesn't seem to be any difference in pitch at all at the very highest frequencies.

{ var sig = DC.ar(0), freq = MouseX.kr(1, 9).floor.linexp(1, 9, 50, 5000), ratio = MouseY.kr(1.493986, 1.5);
	sig = sig + (CombL.ar(WhiteNoise.ar * 0.1 * Decay.ar(Impulse.ar(4), 0.5), 0.5, freq.reciprocal, 2.0) * 0.1);
	sig = sig + (CombL.ar(WhiteNoise.ar * 0.1 * Decay.ar(Impulse.ar(2), 0.5), 0.5, (freq*ratio).reciprocal, 2.0) * 0.1);
	sig!2
}.play;
)

