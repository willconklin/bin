Foo=nada

.PHONY: print_vars

print_vars:
	#$(info    Foo is $(Foo))
	git log
