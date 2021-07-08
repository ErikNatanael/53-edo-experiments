
(
// Takes a degree, returns the closest note name in HEWM and the number of commas different it is from that pitch
~degree_to_note_name53 = { | degree |
	var degree_within_octave = degree % 53,
	note_name_degree_list = List[
		["c", 0],
		["c#", 5],
		["db", 4],
		["d", 9],
		["d#", 14],
		["eb", 13],
		["e", 18],
		["f", 22],
		["f#", 27],
		["gb", 26],
		["g", 31],
		["g#", 36],
		["ab", 35],
		["a", 40],
		["bb", 44],
		["b", 49],
		["c", 53], // easiest way to get correct wrap
	], closest_note_name, closest_comma_distance = 53;

	note_name_degree_list.do { | note_degree |
		var comma_distance = (degree_within_octave - note_degree[1]);
		if(comma_distance.abs() < closest_comma_distance.abs()) {
			closest_note_name = note_degree[0];
			closest_comma_distance = comma_distance;
		}
	};
	[closest_note_name, closest_comma_distance]
};

)

~degree_to_note_name53.(17)

(
[ 0, 17, 31, 48, 65, 82, 96, 113, 130, 147, 161, 178, 195, 212, 226, 243, 260, 277, 291, 308 ].do { |degree|
	(degree%53).postln;
	~degree_to_note_name53.(degree).postln;
}
)

306/53

96-82
82-65
82-53