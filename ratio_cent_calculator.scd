
31*12
53*7

// The Arithmetic of Listening p 16

(
~ratio_to_cent = {|ratio|
	// round automatically given a certain precision
	(ratio.log10 * 3986.3137136).round(0.001)
};
)

~ratio_to_cent.(22/19)


1200/159

1200/144

1200/53
1200/72

~cents_53 = 53.collect{|i| (1200/53)*i }

~cents_72 = 72.collect{|i| (1200/72)*i }

~cents_159 = 159.collect{|i| (1200/159)*i }

~cents_144 = 144.collect{|i| (1200/144)*i }

(
~find_closest = { |given_cents, list_of_cents|
	var closest = 1200, closest_diff = 1200;
	list_of_cents.do{ | cents |
		if(abs(given_cents - cents) < closest_diff) {
			closest_diff = abs(given_cents - cents);
			closest = cents;
		};
	};
	closest
};
)

(
~ji_cents = [
	701.955,
	498.045,
	203.91,
	996.09,
	905.865,
	407.82,
	386.314,
	884.359,
	1088.269,
	813.686,
	315.641,
	1017.596,
	111.731,
	590.224,
	968.826,
	266.871,
	582.512,
	231.174,
	435.084,
	617.488,
	933.129,
	119.443,
	551.318,
	1049.363,
	165.004,
	782.492,
	347.408,
	150.637,
	417.508,
	536.951,
	648.682,
	840.528,
	138.573,
	454.214,
	1071.702,
	636.618,
	289.21,
	128.298,
	247.741,
	359.472,
	563.382,
	745.786,
	830.253,
	910.79,
	1061.427,
	1132.1,
	98.955,
	104.955,
	216.687,
	281.358,
	365.825,
	446.363,
	464.428,
	597.0,
	88.801,
	93.603,
	173.268,
	192.558,
	253.805,
];
)

(
~ji_cents.do{ | ji |

	~find_closest.(ji, ~cents_53).round(0.001).postln;

}
)

(
~ji_cents.do{ | ji |

	~find_closest.(ji, ~cents_72).round(0.001).postln;

}
)

(
~ji_cents.do{ | ji |

	~find_closest.(ji, ~cents_159).round(0.001).postln;

}
)

(
~ji_cents.do{ | ji |

	~find_closest.(ji, ~cents_144).round(0.001).postln;

}
)



(53*31) - (53*31)

( // Test equivalence of fifths and octaves
54.do{|i| var divisibility = (i*31)/53;
	if(divisibility.frac == 0.0) {
		i.postln;
	};
}
)

1200/159/2