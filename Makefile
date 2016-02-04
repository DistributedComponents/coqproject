default: Makefile.coq
	$(MAKE) -f Makefile.coq

Makefile.coq: _CoqProject
	test -s _CoqProject || { echo "Run coqproject.sh before running make"; exit 1 }
	coq_makefile -f _CoqProject -o Makefile.coq

clean:
	$(MAKE) -f Makefile.coq clean
	rm Makefile.coq

.PHONY: default clean
