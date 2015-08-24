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
$(PAGES): $(SOURCES) jfe_template/css/custom.css
	$(judo) $(patsubst html/%.html,%.md,$@) --out $(outf) --template jfe_template

clean:
	@rm $(outf)/*.html

jfe_template/css/custom.css: jfe_template/css/custom.less
	lessc $< $@

$(judo):
	$(jexe) -e 'Pkg.clone("https://github.com/dcjones/Judo.jl.git");'
