jver = 0.3
judo = ~/.julia/v$(jver)/Judo/bin/judo
jexe = julia
outf = dist

SOURCES=$(wildcard *.md)
PAGES=$(patsubst %.md,$(outf)/%.html,$(SOURCES))

.PHONY: $(outf)

ALL: $(outf) $(outf)/css/custom.css $(PAGES)

$(outf):
	mkdir -p $(outf)

.SECONDEXPANSION:
$(PAGES): $(SOURCES) jfe_template/css/custom.css
	$(judo) $(patsubst $(outf)/%.html,%.md,$@) --out $(outf) --template jfe_template

clean:
	@rm $(outf)/*.html

jfe_template/css/custom.css: jfe_template/css/custom.less
	lessc $< $@

$(outf)/css/custom.css: jfe_template/css/custom.css
	cp $< $@

$(judo):
	$(jexe) -e 'Pkg.clone("https://github.com/dcjones/Judo.jl.git");'

pages:
	git subtree push --prefix $(outf) origin gh-pages
	git push origin master
