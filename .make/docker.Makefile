
###> docker-compose ###
DOCKER_COMPOSE = $(shell which docker-compose)

define docker_compose
	"$(DOCKER_COMPOSE)" -p "$(PROJECT_NAME)" ${DOCKER_COMPOSE_FILES} ${1};
endef
###< docker-compose ###

###> docker-compose files ###
# Dotenv has those elements stored as multiline strings,
# to use them as arguments it must be extracted from string quotes (")
DOCKER_COMPOSE_FILES := $(shell echo '${DOCKER_COMPOSE_FILES}' | sed -rE 's/.*"(.*)".*/\1/')
###< docker-compose files ###

###> docker-compose submodules ###
## A list of docker-compose submodules
DOCKER_COMPOSE_SUBMODULES ?= $(shell find . -mindepth 1 -maxdepth 1 -type d -not -name '.*')

define docker_submodule_make
	$(MAKE) -e -C${1} ${2};
endef

define docker_submodules_make
	$(foreach SUBMODULE, $(DOCKER_COMPOSE_SUBMODULES), $(call docker_submodule_make,${SUBMODULE},${1}))
endef
###< docker-compose submodules ###

###> run as current (hopefully non-root) user ###
# @see https://americanexpress.io/do-not-run-dockerized-applications-as-root/
export USER_UID  = $(shell id -u)
export GROUP_UID = $(shell id -g)
export USER      = $(USER_UID):$(GROUP_UID)
###< run as current (hopefully non-root) user ###

## Docker - restart docker-compose containers
docker: docker-stop docker-rmf docker-upd

## Docker - Build or rebuild services
.PHONY: docker-build
docker-build:
	$(QUIET) $(call docker_submodules_make, docker-build o="$(o)" s="$(s)")
	$(QUIET) $(call docker_compose, build $(o) $(s))

## Docker - Validate and view the Compose file
.PHONY: docker-config
docker-config:
	$(QUIET) $(call docker_compose, config $(o))
	$(QUIET) $(call docker_submodules_make, docker-config o="$(o)")

## Docker - Stops containers and removes containers, networks, volumes, and images created by `up`.
.PHONY: docker-down
docker-down:
	$(QUIET) $(call docker_submodules_make, docker-down o="$(o)")
	$(QUIET) $(call docker_compose, down $(o))

## Docker - Execute a command in a running container
.PHONY: docker-exec
docker-exec:
	$(QUIET) $(call docker_compose, exec $(o) $(s) $(c))
	$(QUIET) $(call docker_submodules_make, docker-exec o="$(o)" s="$(s)" c="$(c)")

## Docker - Execute a command in a running container
.PHONY: docker-images
docker-images:
	$(QUIET) $(call docker_compose, images $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-images o="$(o)" s="$(s)")

## Docker - Kill containers
.PHONY: docker-kill
docker-kill:
	$(QUIET) $(call docker_submodules_make, docker-kill o="$(o)" s="$(s)")
	$(QUIET) $(call docker_compose, kill $(o) $(s))

## Docker - View output from containers
.PHONY: docker-logs
docker-logs:
	$(QUIET) $(call docker_compose, logs $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-logs o="$(o)" s="$(s)")

## Docker - Pause services
.PHONY: docker-pause
docker-pause:
	$(QUIET) $(call docker_submodules_make, docker-pause s="$(s)")
	$(QUIET) $(call docker_compose, pause $(s))

## Docker - List containers
.PHONY: docker-ps
docker-ps:
	$(QUIET) $(call docker_compose, ps $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-ps o="$(o)" s="$(s)")

## Docker - Pull service images
.PHONY: docker-pull
docker-pull:
	$(QUIET) $(call docker_compose, pull $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-pull o="$(o)" s="$(s)")

## Docker - Push service images
.PHONY: docker-push
docker-push:
	$(QUIET) $(call docker_compose, push $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-push o="$(o)" s="$(s)")

## Docker - Restart services
.PHONY: docker-restart
docker-restart:
	$(QUIET) $(call docker_submodules_make, docker-restart o="$(o)" s="$(s)")
	$(QUIET) $(call docker_compose, restart $(o) $(s))

## Docker - Remove stopped containers
.PHONY: docker-rm
docker-rm:
	$(QUIET) $(call docker_submodules_make, docker-rm o=$(o) s=$(s))
	$(QUIET) $(call docker_compose, rm $(o) $(s))

## Docker - Force remove stopped containers
.PHONY: docker-rmf
docker-rmf:
	$(QUIET) $(MAKE) -e docker-rm o="-f $(o)" s="$(s)"

## Docker - Start services
.PHONY: docker-start
docker-start:
	$(QUIET) $(call docker_submodules_make, docker-start s="$(s)")
	$(QUIET) $(call docker_compose, start $(s))

## Docker - Stop running containers without removing them
.PHONY: docker-stop
docker-stop:
	$(QUIET) $(call docker_submodules_make, docker-stop o="$(o)" s="$(s)")
	$(QUIET) $(call docker_compose, stop $(o) $(s))

## Docker - Display the running processes
.PHONY: docker-top
docker-top:
	$(QUIET) $(call docker_compose, top $(s))
	$(QUIET) $(call docker_submodules_make, docker-top s="$(s)")

## Docker - Unpause services
.PHONY: docker-unpause
docker-unpause:
	$(QUIET) $(call docker_compose, unpause $(s))
	$(QUIET) $(call docker_submodules_make, docker-unpause s="$(s)")

## Docker - Create and start containers
.PHONY: docker-up
docker-up:
	$(QUIET) $(call docker_compose, up $(o) $(s))
	$(QUIET) $(call docker_submodules_make, docker-up o="$(o)" s="$(s)")

## Docker - Create and start containers in detached state
.PHONY: docker-upd
docker-upd:
	$(QUIET) $(MAKE) -e docker-up o="-d $(o)" s="$(s)"
