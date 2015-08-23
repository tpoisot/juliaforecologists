jver = 0.3
judo = ~/.julia/v$(jver)/Judo/bin/judo
jexe = julia
outf = html

SOURCES=$(wildcard *.md)
PAGES=$(patsubst %.md,html/%.html,$(SOURCES))

.PHONY: $(outf)

ALL: $(outf) $(PAGES)

$(outf):
	mkdir -p $(outf)

.SECONDEXPANSION:
$(PAGES): $(SOURCES)
	$(judo) $(patsubst html/%.html,%.md,$@) --out $(outf)

clean:
	@rm $(outf)/*.html

$(judo):
	$(jexe) -e 'Pkg.clone("https://github.com/dcjones/Judo.jl.git");'
