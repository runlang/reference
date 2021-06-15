all: doc
	
test:
	raco test -x .

doc: $(wildcard *.rkt **/*.rkt) $(wildcard scribblings/*.scrbl)
	scribble --dest doc --html scribblings/runlang.scrbl
