# mkincl

A simple way to reuse Makefiles and scripts across multiple repositories.

## Rationale

While working with CI/CD in a large organization, I found myself using
[GitLab's CI includes](https://docs.gitlab.com/ee/ci/yaml/includes.html) a lot.
This reduced copy-pasted configuration and inconsistent practices across
projects, but was difficult to run locally and resulted too much code in YAML
files for my taste.

_mkincl_ is an alternative approach which addresses these pain points, by
relying on Makefiles. It provides a centralized and standardized interface to
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

1. The Makefile that contains the `clean-mkincl` and `init-mkincl` targets:
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
clean-mkincl init-mkincl
```

When running the `init-mkincl` target, target providers will be fetched and
after that all their targets will now be available:

```sh
$ make init-mkincl --silent
$ make <tab><tab>
clean-mkincl            fix-mkincl              init-mkincl             lint-mkincl-linter1
enter-mkincl-container  fix-mkincl-fixer1       lint                    lint-mkincl-linter2
fix                     fix-mkincl-fixer2       lint-mkincl
```

## Examples

The providers I have created so far:

* [lua-provider](https://github.com/mkincl/lua-provider)
* [markdown-provider](https://github.com/mkincl/markdown-provider)
* [python-provider](https://github.com/mkincl/python-provider)
* [shell-provider](https://github.com/mkincl/shell-provider)

Some of them are used in my [dotfile
repository](https://github.com/carlsmedstad/dotfiles).

## Features

### Provider Docker Image

Building a Docker image in a provider repository can be a great way of
constructing a reproducible environment for development tasks. This removes the
need for installing tooling locally and will ensure developers are using the
same versions of the tooling. This couples well with the following Make target:

<!-- markdownlint-disable MD010 -->
```make
.PHONY: enter-$(NAME)-container
enter-$(NAME)-container:
	docker run --rm --interactive --tty --pull always --volume "$$(pwd)":/pwd --workdir /pwd $(IMAGE)
```
<!-- markdownlint-enable MD010 -->

This target enables developers to easily enter the development environment by
running:

```sh
make enter-<provider>-container
```

### Simple and Platform Agnostic CI/CD Jobs

The feature mentioned above, building Docker images for each provider, can
greatly simplify CI/CD pipelines. Instead of invoking the tooling directly,
simply run in the image that the provider builds and invoke mkincl's Make
targets.

For example, a GitHub Actions job running [shfmt](https://github.com/mvdan/sh)
and [shellcheck](https://github.com/koalaman/shellcheck) using my
[shell-provider](https://github.com/mkincl/shell-provider) looks like this:

```yaml
jobs:
  shell:
    runs-on: ubuntu-latest
    container: ghcr.io/mkincl/shell-provider:v1
    steps:
      - uses: actions/checkout@v2
      - run: make init-mkincl
      - run: make lint-shell
```

This job is trivial to adapt for GitLab CI:

```yaml
lint-shell:
  image: ghcr.io/mkincl/shell-provider:v1
  script:
    - make init-mkincl
    - make lint-shell
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
