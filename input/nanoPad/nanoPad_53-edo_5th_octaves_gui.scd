{
	var value = 0.5, width = 1920, height = 540, numOctaves = ~octave_lookup.size;
	w = Window.new("53-EDO 5ths", Rect(100, 100, width, height)).front;
	w.background = Color.grey(0.1);

	// (1) create a UserView
	~guiView = UserView(w,Rect(0,0,width,height));

	// (2) define a drawing function using Pen
	~guiView.drawFunc = {
		var buttonWidth = width * 0.045;
		// Draw the normal pitch buttons

		~bits.do{ | bit, i |
			if(bit == true, {
				Pen.fillColor = Color.red;
			}, {
				Pen.fillColor = Color.grey(0.3);
			});
			Pen.addOval(Rect(width - (buttonWidth * (i+1) * 2), height - ((buttonWidth)*2), buttonWidth, buttonWidth));
			Pen.fill;
			Pen.stroke;
			StaticText(w, Rect(
				width - (buttonWidth * (i+1) * 2) + (buttonWidth/4),
				height - (buttonWidth * 0.7),
				buttonWidth*2,
				20))
			.stringColor_(Color.grey(0.9))
			.string_(2.pow(i).asInt.asString);
		};

		// Draw the 5th button
		~added_notes_on.do {|on, i|
			if(on, {
				Pen.fillColor = Color.red;
			}, {
				Pen.fillColor = Color.grey(0.3);
			});
			Pen.addRect(Rect(width - (buttonWidth * (~bits.size+1 + i) * 2), height - ((buttonWidth)*2), buttonWidth, buttonWidth));
			Pen.fill;
			Pen.stroke;
			StaticText(w, Rect(
				width - (buttonWidth * (~bits.size+1 + i) * 2) + (buttonWidth/4),
				height - (buttonWidth * 0.7),
				buttonWidth*2,
				20))
			.stringColor_(Color.grey(0.9))
			.string_(~added_notes_values[i].asString);
		};

		// Draw the octaves
		numOctaves.do { | i | var octH = (height / (numOctaves + 1)) * 0.5, octW = width * 0.2;
			if(~octaves[i+2] == true, {
				Pen.fillColor = Color.red;
			}, {
				Pen.fillColor = Color.grey(0.3);
			});
			Pen.addRect(Rect(0,height - (octH*(i+1)*2), octW,octH));
			Pen.fill;
		};
	};
	StaticText(w, Rect(
		width*0.6,
		height * 0.35,
		400,
		40))
	.string_("Note number")
	.stringColor_(Color.grey(0.9))
	.font_( Font("Monaco", 32));
	~guiNoteNumber = StaticText(w, Rect(
		width*0.6,
		height * 0.5,
		200,
		50))
	.string_("0")
	.stringColor_(Color.grey(0.9))
	.font_( Font("Monaco", 44));

	StaticText(w, Rect(
		width*0.3,
		height * 0.35,
		400,
		40))
	.string_("Name 0=C (approx. ratio)")
	.stringColor_(Color.grey(0.9))
	.font_( Font("Monaco", 32));

	~guiNoteName = StaticText(w, Rect(
		width*0.3,
		height * 0.5,
		400,
		50))
	.string_("0")
	.stringColor_(Color.grey(0.9))
	.font_( Font("Monaco", 32));

	// (3) set the default action
	~guiView.action = {value.postln; v.refresh};
}.defer;