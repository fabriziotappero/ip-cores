DOXYFILE = Doxyfile.in

doc :
	@echo Running doxygen to create documentation
	doxygen $(DOXYFILE)

clean :
	rm -f html/* latex/* man/* xml/*

default : doc

.PHONY : clean doc
