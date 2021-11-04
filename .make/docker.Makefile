
###> docker ###
## Path to docker binary
DOCKER_BIN ?= $(shell which docker)
###< docker ###

###> docker-compose ###
## Path to docker-compose (or compose v2) binary
DOCKER_COMPOSE_BIN ?= $(shell "$(DOCKER_BIN)" compose >/dev/null 2>/dev/null || false; test "$$?" = "0" && echo "$(DOCKER_BIN)" compose || echo "$(shell which docker-compose 2> /dev/null)")
ifeq ($(DOCKER_COMPOSE_BIN),)
$(error "Please install docker compose or docker-compose (https://github.com/docker/compose#where-to-get-docker-compose)")
endif

define docker_compose
	$(DOCKER_COMPOSE_BIN) -p "$(PROJECT_NAME)" $(DOCKER_COMPOSE_FILES) $(1);
endef
###< docker-compose ###

###> docker-compose files ###
# Dotenv has those elements stored as multiline strings,
# to use them as arguments it must be extracted from string quotes (")
DOCKER_COMPOSE_FILES := $(shell echo '$(DOCKER_COMPOSE_FILES)' | sed -rE 's/.*"(.*)".*/\1/')
###< docker-compose files ###

###> docker-compose submodules ###
## A list of docker-compose submodules
DOCKER_COMPOSE_SUBMODULES ?= 

define docker_submodule_make
	$(MAKE) -e -C$(1) $(2);
endef

define docker_submodules_make
	$(foreach SUBMODULE, $(DOCKER_COMPOSE_SUBMODULES), $(call docker_submodule_make,$(SUBMODULE),$(1)))
endef
###< docker-compose submodules ###

###> run as current user (idealy non-root) ###
# @see https://americanexpress.io/do-not-run-dockerized-applications-as-root/
export USER_UID  = $(shell id -u)
export GROUP_UID = $(shell id -g)
###< run as current user (idealy non-root) ###

## Docker - restart docker-compose containers
docker: docker-stop docker-rmf docker-upd

## Docker - Build or rebuild services
.PHONY: docker-build
docker-build:
	$(QUIET) $(call docker_submodules_make, docker-build go="$(go)" o="$(o)" s="$(s)")
	$(QUIET) $(call docker_compose, $(go) build $(o) $(s))

## Docker - Validate and view the Compose file
.PHONY: docker-config
docker-config:
	$(QUIET) $(call docker_compose, $(go) config $(o))
	$(QUIET) $(call docker_submodules_make, docker-config go="$(go)" o="$(o)")

## Docker - Stops containers and removes containers, networks, volumes, and images created by `up`.
.PHONY: docker-down
docker-down:
	$(QUIET) $(call docker_submodules_make, docker-down go="$(go)" o="$(o)")
	$(QUIET) $(call docker_compose, $(go) down $(o))

## Docker - Execute a command in a running container
.PHONY: docker-exec
docker-exec:
	$(QUIET) $(call docker_compose, $(go) exec $(o) $(s) $(c))
	$(QUIET) $(call docker_submodules_make, docker-exec go="$(go)" o="$(o)" s="$(s)" c="$(c)")

## Docker - Execute a command in a running container
.PHONY: docker-images
docker-images:
	$(QUIET) $(call docker_compose, $(go) images $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-images go="$(go)" o="$(o)" s="$(s)")

## Docker - Kill containers
.PHONY: docker-kill
docker-kill:
	$(QUIET) $(call docker_submodules_make, docker-kill go="$(go)" o="$(o)" s="$(s)")
	$(QUIET) $(call docker_compose, $(go) kill $(o) $(s))

## Docker - View output from containers
.PHONY: docker-logs
docker-logs:
	$(QUIET) $(call docker_compose, $(go) logs $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-logs go="$(go)" o="$(o)" s="$(s)")

## Docker - View and follow output from containers
.PHONY: docker-logsf
docker-logsf:
	$(QUIET) $(MAKE) -e docker-logs go="$(go)" o="--follow $(o)" s="$(s)"

## Docker - Pause services
.PHONY: docker-pause
docker-pause:
	$(QUIET) $(call docker_submodules_make, docker-pause go="$(go)" s="$(s)")
	$(QUIET) $(call docker_compose, $(go) pause $(s))

## Docker - List containers
.PHONY: docker-ps
docker-ps:
	$(QUIET) $(call docker_compose, $(go) ps $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-ps go="$(go)" o="$(o)" s="$(s)")

## Docker - Pull service images
.PHONY: docker-pull
docker-pull:
	$(QUIET) $(call docker_compose, $(go) pull $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-pull go="$(go)" o="$(o)" s="$(s)")

## Docker - Push service images
.PHONY: docker-push
docker-push:
	$(QUIET) $(call docker_compose, $(go) push $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-push go="$(go)" o="$(o)" s="$(s)")

## Docker - Restart services
.PHONY: docker-restart
docker-restart:
	$(QUIET) $(call docker_submodules_make, docker-restart go="$(go)" o="$(o)" s="$(s)")
	$(QUIET) $(call docker_compose, $(go) restart $(o) $(s))

## Docker - Remove stopped containers
.PHONY: docker-rm
docker-rm:
	$(QUIET) $(call docker_submodules_make, docker-rm go="$(go)" o=$(o) s=$(s))
	$(QUIET) $(call docker_compose, $(go) rm $(o) $(s))

## Docker - Force remove stopped containers
.PHONY: docker-rmf
docker-rmf:
	$(QUIET) $(MAKE) -e docker-rm go="$(go)" o="--force $(o)" s="$(s)"

## Docker - Start services
.PHONY: docker-start
docker-start:
	$(QUIET) $(call docker_submodules_make, docker-start go="$(go)" s="$(s)")
	$(QUIET) $(call docker_compose, $(go) start $(s))

## Docker - Stop running containers without removing them
.PHONY: docker-stop
docker-stop:
	$(QUIET) $(call docker_submodules_make, docker-stop go="$(go)" o="$(o)" s="$(s)")
	$(QUIET) $(call docker_compose, $(go) stop $(o) $(s))

## Docker - Display the running processes
.PHONY: docker-top
docker-top:
	$(QUIET) $(call docker_compose, $(go) top $(s))
	$(QUIET) $(call docker_submodules_make, docker-top go="$(go)" s="$(s)")

## Docker - Unpause services
.PHONY: docker-unpause
docker-unpause:
	$(QUIET) $(call docker_compose, $(go) unpause $(s))
	$(QUIET) $(call docker_submodules_make, docker-unpause go="$(go)" s="$(s)")

## Docker - Create and start containers
.PHONY: docker-up
docker-up:
	$(QUIET) $(call docker_compose, $(go) up $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-up go="$(go)" o="$(o)" s="$(s)")

## Docker - Create and start containers in detached state
.PHONY: docker-upd
docker-upd:
	$(QUIET) $(MAKE) -e docker-up go="$(go)" o="--detach $(o)" s="$(s)"
