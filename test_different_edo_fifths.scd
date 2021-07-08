~ratio53 = pow(2, 1/53);
~rootFreq = 0.midicps;
// Function to convert a degree in 53-EDO to a frequency
~degree53_to_freq =  { |degree|
	var freq = ~rootFreq*pow(~ratio53, degree);
	freq
};


~ratio289 = pow(2, 1/289);
~rootFreq = 0.midicps;
// Function to convert a degree in 53-EDO to a frequency
~degree289_to_freq =  { |degree|
	var freq = ~rootFreq*pow(~ratio289, degree);
	freq
};

~ratio289 = pow(2, 1/289);
~rootFreq = 0.midicps;
// Function to convert a degree in 53-EDO to a frequency
~degree289_to_freq =  { |degree|
	var freq = ~rootFreq*pow(~ratio289, degree);
	freq
};

pow(~ratio289, 169)

~degree53_to_freq.(31) / ~rootFreq

~degree289_to_freq.(169) / ~rootFreq


701.955001

(
var bestFifth = 0, bestEdo = 0;

~testEdo = { | edo |
	var ratioStep = pow(2, 1.0/edo), bestFifth = 0, bestFifthDegree = 0;
	// Find the fifth
	edo.do { |degree|
		var degreeRatio = pow(ratioStep, degree);
		if((degreeRatio - 1.5).abs < (bestFifth-1.5).abs) {
			bestFifth = degreeRatio;
			bestFifthDegree = degree;
		};
	};
	[bestFifth, bestFifthDegree]
};

(12..1000).do{|edo|
	var edoResults;
	edoResults = ~testEdo.(edo);
	if((edoResults[0]-1.5).abs < (bestFifth-1.5).abs) {
		bestFifth = edoResults[0];
		bestEdo = edo;
		("better fifth: " ++ edo ++ "edo at " ++ bestFifth).postln;
	};
}


)