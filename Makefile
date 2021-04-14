all := $(wildcard *.sh)
lib := lib/is.sh

check-all: ; shellcheck -x $(all)

check-lib: ; shellcheck -x $(lib)