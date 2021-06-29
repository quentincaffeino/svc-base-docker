
###> quiet ###
## Override this value with a blank string to make make print each command it runs
QUIET ?= @
###< quiet ###

###> make-help ###
# @see https://github.com/ianstormtaylor/makefile-help
## Show this help prompt.
help:
	$(QUIET) echo
	$(QUIET) echo '  Usage:'
	$(QUIET) echo ''
	$(QUIET) echo '    make <target> [flags...]'
	$(QUIET) echo ''
	$(QUIET) echo '  Targets:'
	$(QUIET) echo ''
	$(QUIET) awk '/^##/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+:/{ print "   ", $$1, comment }' $(MAKEFILE_LIST) | column -t -s ':' | sort
	$(QUIET) echo ''
	$(QUIET) echo '  Flags:'
	$(QUIET) echo ''
	$(QUIET) awk '/^##/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?\?=/{ print "   ", $$1, $$2, comment }' $(MAKEFILE_LIST) | column -t -s '?=' | sort
	$(QUIET) echo ''
###< make-help ###
