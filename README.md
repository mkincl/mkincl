# mkincl

A simple way to reuse Makefiles and scripts across multiple repositories.

## Rationale

While working with CI/CD in a large organization, I found myself using
[GitLab's CI includes](https://docs.gitlab.com/ee/ci/yaml/includes.html) a lot.
This reduced copy-pasted configuration and inconsistent practices across
projects, but was difficult to run locally and resulted too much code in YAML
files for my taste.

_mkincl_ is an alternative approach which addresses these pain points, by relying
on Makefiles. It provides a centralized and standardized interface to
development tools and processes while having a small footprint.

### Why Makefiles?

* **A standardized interface**. Makefiles enable invoking development tasks
  such as building, testing and linting the same way across tech stacks.

* **Friendly to local development**. All jobs can be run locally with ease.

* **Agnostic to CI/CD platform**. CI/CD jobs based on containers and Makefiles
  will work on multiple platforms (such as GitHub and GitLab) without much
  adaptation.

## About

A repository hosting files to be shared will in this document be called a
_provider_, while a repository using files from a provider will be called a
_user_. This repository acts both as a provider and a user for demonstration
purposes.

The minimum requirement for a provider is that it contains the Makefile
[`include.mk`](include.mk), but it can also contain other files of any sort.

A user must contain three things:

1. The Makefile that contains the `clean` and `init` targets:
   [`.mkincl/init.mk`](.mkincl/init.mk). This file is completely generic and
   can be copied without modifications to new repositories.

2. A top-level [Makefile](Makefile) that includes `.mkincl/init.mk`. This
   separation is done to not mix up mkincl related targets with bespoke
   targets.

3. One or more provider initialization files such as the one in this project:
   [`.mkincl/inits/mkinit.sh`](.mkincl/inits/mkincl.sh). These files specify
   the name, version and URL to a provider, where version is a Git ref and URL
   points to a Git repository.

This setup allows us to store common Make targets, for example those for a
particular stack, separately from the actual project repositories. When first
checking out a project two targets are available:

```sh
$ make <tab><tab>
clean init
```

When running the `init` target, target providers will be fetched and after that
all their targets will now be available:

```sh
$ make init --silent
$ make <tab><tab>
clean                   fix-mkincl              init                    lint-mkincl-linter1
enter-mkincl-container  fix-mkincl-fixer1       lint                    lint-mkincl-linter2
fix                     fix-mkincl-fixer2       lint-mkincl
```

## Features

### Provider Docker Image

If you run all your CI jobs in the same Docker image, that image could be built
in your provider repository and your provider could include something like:

<!-- markdownlint-disable MD010 -->
```make
.PHONY: enter-$(NAME)-container
enter-$(NAME)-container:
	docker run --rm --interactive --tty --pull always --volume "$$(pwd)":/pwd --workdir /pwd $(IMAGE)
```
<!-- markdownlint-enable MD010 -->

This would make it trivial for someone to replicate the CI environment locally
by running:

```make
make enter-python-container
make lint-python
```

### Generic Targets

Using some clever naming conventions in our providers will make working with
projects with multiple providers very enjoyable. The example
[`include.mk`](include.mk) in this project uses the naming scheme
`<action>-<provider>-<program>` and define all levels of targets with proper
dependencies. I.e. the target `<action>` depends on `<action>-<provider>` which
in turn depends on all targets "below" it. So if I have a project where I have
both Python code and shell scripts I could run:

* `make lint` to run all linters.
* `make lint-python` to run all linters for Python.
* `make lint-shell` to run all linters for shell.

## Examples

The providers I have created so far:

* [mkincl-lua](https://github.com/carlsmedstad/mkincl-lua)
* [mkincl-markdown](https://github.com/carlsmedstad/mkincl-markdown)
* [mkincl-python](https://github.com/carlsmedstad/mkincl-python)
* [mkincl-shell](https://github.com/carlsmedstad/mkincl-shell)

Some of them are used in my [dotfile
repository](https://github.com/carlsmedstad/dotfiles).
