# Add space separated names of all PDF reports you want to generate.
# Base name of file should also be filename of markdown files.
# E.g. report-1.md will generate report-1.pdf
all: report.pdf

%.pdf: %.md head.tex
	pandoc $< \
		-H head.tex \
		--toc \
		-V geometry:a4paper \
		-V linkcolor:blue \
		-V geometry:margin=2.5cm \
		-V fontsize=12pt \
		-o $@
