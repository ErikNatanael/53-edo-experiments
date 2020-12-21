/// Chord Sequence Generator

// Functional or non-functional harmony?

// Parameters:

// start/end: the chords that the progression should start and end with
// colour: a scale between darkness and brightness, complex minor and complex major

// 1: very complex relationships between minor chords with loads of colours
// 4: simple minor
// 5: can't decide if major or minor
// 6: simple major
// 8:
// 9: very complex relationships between major chords

// What kinds of chord progressions do I like?


////// Structure of generator:
// - Markov chains?
// - if statements with randomness? (same as above?)
// let the next chord depend on the previous

////// Generator approaches:
// Start to end
// set the start chord and let the next chord depend on the previous chord

// End to start
// set the end chord and work backwards to a start chord

// Expand from within
// start with a start and an end chord and expand the number of chords between them by inserting or converting chords