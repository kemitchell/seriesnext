FORMS=$(wildcard *.commonform) investment-agreement.commonform
VARIABLES=variables.json
VARIABLES_TO_BLANKS=variables-to-blanks.js
COMMONFORM=node_modules/.bin/commonform
MUSTACHE=node_modules/.bin/mustache

all: $(FORMS:.commonform=.docx)

pdf: $(FORMS:.commonform=.pdf)

%.pdf: %.docx
	doc2pdf $<

$(COMMONFORM):
	npm i

$(MUSTACHE):
	npm i

blanks.json: $(VARIABLES_TO_BLANKS) $(VARIABLES)
	node $(VARIABLES_TO_BLANKS) $(VARIABLES) > $@

%.signatures.json: %.signatures.js $(VARIABLES)
	node $< $(VARIABLES) > $@

%.commonform: %.mustache $(VARIABLES) $(MUSTACHE)
	$(MUSTACHE) $(VARIABLES) $*.mustache > $@

%.docx: %.commonform %.signatures.json %.options blanks.json $(COMMONFORM)
	$(COMMONFORM) render -f docx -b blanks.json -s $*.signatures.json $(shell cat $*.options) < $< > $@

certificate-of-incorporation.docx: certificate-of-incorporation.commonform certificate-of-incorporation.options blanks.json $(COMMONFORM)
	$(COMMONFORM) render -f docx -b blanks.json $(shell cat certificate-of-incorporation.options) < $< > $@

.PHONY: lint critique

lint:
	for form in $(FORMS); do \
		echo $$form; \
		$(COMMONFORM) lint < $$form | sort -u; \
		echo; \
	done

critique:
	for form in $(FORMS); do \
		echo $$form; \
		$(COMMONFORM) critique < $$form | sort -u; \
		echo; \
	done
