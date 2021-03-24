# Base repo for docker based services with make

This setup makes use of `docker-compose` ability to combine multiple configurations by reading several input files via defining multiple `-f` attributes and also combines it with environment-based make to make use easier with multi-environment setups with dynamic variables and env-based `docker-compose` configs

## Table of contents

- [Base repo for docker based services with make](#base-repo-for-docker-based-services-with-make)
	- [Variables](#variables)
	- [Usage](#usage)

- [Base repo for services with make](#extends-base-repo-for-services-with-make)
	- [Usage](#make-usage)
	- [dotenv](#make-dotenv)
		- [Overrides](#make-overrides)

## Variables

- `PROJECT_NAME` - Project name
- `BASE_DOCKER_COMPOSE_FILES` & `DOCKER_COMPOSE_FILES` - Instructs make to which docker-compose files use for which environment

## Usage

Every `docker-compose` comand is wrapped with `make`. Example usage:

```sh
[VARIABLES] make docker-[COMMAND-NAME] [VARIABLES]
# Eg.:
make docker-up
ENV=prod make docker-config
make docker-build s="service-name"
```

Where `COMMAND-NAME` is a docker-compose command name (eg.: up, down, config, ...)

### Compose options

There are times when you need to pass extra variables to `docker-compose` command. Most of them accept some sort of options flags/attributes. Those could be passed using `o` (options) variable like so:

```sh
make docker-up o="-d"
```

    Note: Quotes are only nessesary when there are multiple space-separated flags/attrs to pass to the command.

Some commands also accept service(s) which to run command against (eg.: `build` to build only specific services). To pass those use `s` option:

```sh
make docker-build s="service-name service2-name"
```

### Extra commands

Some commands with options are very commonly used and because to write them each time is very inconvenient shortcuts were introduced:

```sh
make docker-upd
# is same as
make docker-up o="-d" # Detached mode: Run containers in the background.

# AND

make docker-rmf
# is same as
make docker-rm o="-f" # Don't ask to confirm removal
```

# [Extends] Base repo for services with make

Make setup which makes use of per-environment dotenv files

## [Make] Usage

```sh
make help
```

## [Make] dotenv

Using `make` and per-environment dotenv files it is prepaired to run on several environments.

### [Make] Overrides

To override variables locally create `.env.local` or `.env.ENVIRONMENT-NAME.local` (eg.: `.env.prod.local`) files.
