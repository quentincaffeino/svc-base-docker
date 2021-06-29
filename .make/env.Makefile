
###> env ###
## Environment name (leave blank for dev, use prod for production and etc...) [default: ]
ENV ?=

## Path to the dotenv files [default:.]
ENV_PATH ?= .

## List of variables to omit while exporting
SKIP_EXPORT_FOR ?= 

include $(ENV_PATH)/.env
-include $(ENV_PATH)/.env.local
VARS := $(filter-out $(SKIP_EXPORT_FOR),$(shell grep -shoP "^[^\#=]+(?==)(?!.*;)" $(ENV_PATH)/.env $(ENV_PATH)/.env.local))
$(foreach v, $(VARS), $(eval $(shell echo export $(v) = "$($(v))")))

ifneq ("$(ENV)", "")
include $(ENV_PATH)/.env.$(ENV)
-include $(ENV_PATH)/.env.$(ENV).local
VARS := $(filter-out $(SKIP_EXPORT_FOR),$(shell grep -shoP "^[^\#=]+(?==)(?!.*;)" $(ENV_PATH)/.env.$(ENV) $(ENV_PATH)/.env.$(ENV).local))
$(foreach v, $(VARS), $(eval $(shell echo export $(v) = "$($(v))")))
endif
###< env ###
