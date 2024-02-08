<p align="center">
  <img src="docs/images/nf-scil_logo_light.png#gh-light-mode-only" alt="Sublime's custom image"/>
</p> <!-- omit in toc -->
<p align="center">
  <img src="docs/images/nf-scil_logo_dark.png#gh-dark-mode-only" alt="Sublime's custom image"/>
</p> <!-- omit in toc -->

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.10.3-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![Imports: nf-core](https://img.shields.io/badge/nf--core-nf?label=import&style=flat&labelColor=ef8336&color=24B064)](https://pycqa.github.io/nf-core/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
![Code Linting](https://github.com/scilus/nf-scil/workflows/Code%20Linting/badge.svg)
![Modules Tests](https://github.com/scilus/nf-scil/workflows/Modules%20Tests/badge.svg)

Welcome to `nf-scil` ! A **Nextflow** modules and workflows repository for neuroimaging
maintained by the [SCIL team](https://scil-documentation.readthedocs.io/en/latest/). The
primary focus of the library is to provide pre-built processes and processing sequences for
**diffusion Magnetic Resonance Imaging**, optimized for _Nextflow DLS2_, based on open-source
technologies and made easily available to pipeline's developers through the `nf-core`
framework.

- [Using modules from nf-scil](README.md#using-modules-from-nf-scil)
- [Developing in nf-scil](README.md#developing-in-nf-scil)
  - [Dependencies](README.md#dependencies)
  - [Developer installation](README.md#developer-installation)
  - [Loading the project's environment](README.md#loading-the-projects-environment)
  - [Working with VS Code](README.md#working-with-vs-code)
    - [Manual configuration of the VS Code project :](README.md#manual-configuration-of-the-vs-code-project-)
    - [Configuration via the devcontainer :](README.md#configuration-via-the-devcontainer-)
  - [Contributing to nf-scil](README.md#contributing-to-nf-scil)
    - [Adding a new module to nf-scil](docs/MODULE.md#adding-a-new-module-to-nf-scil)
      - [Generate the template](docs/MODULE.md#generate-the-template)
      - [Edit the template](docs/MODULE.md#edit-the-template)
        - [Editing the main](docs/MODULE.md#editing-modulesnf-scilcategorytoolmainnf-)
        - [Editing the metadata](docs/MODULE.md#editing--modulesnf-scilcategorytoolmetayml-)
        - [Editing the test cases](docs/MODULE.md#editing-testsmodulesnf-scilcategorytoolmainnf-)
        - [Editing the tests configuration](docs/MODULE.md#editing-testsmodulesnf-scilcategorytoolnextflowconfig-)
      - [Run the tests to generate the test metadata file](docs/MODULE.md#run-the-tests-to-generate-the-test-metadata-file)
      - [Last safety test](docs/MODULE.md#last-safety-test)
      - [Submit your PR](docs/MODULE.md#submit-your-pr)
    - [Defining processes optional parameters](docs/MODULE.md#defining-processes-optional-parameters)
    - [Test data infrastructure](docs/MODULE.md#test-data-infrastructure)
      - [Using the .test_data directory](docs/MODULE.md#using-the-test_data-directory)
      - [Using Scilpy Fetcher](docs/MODULE.md#using-scilpy-fetcher)
  - [Running tests](README.md#running-tests)

# Using modules from `nf-scil`

To import modules from `nf-scil`, you first need to install [nf-core](https://github.com/nf-core/tools)
on your system (can be done simply using `pip install nf-core`). Once done, `nf-scil`
modules are imported using this command :

```bash
nf-core modules \
  --git-remote https://github.com/scilus/nf-scil.git \
  install <category>/<tool>
```

where you input the `<tool>` you want to import from the desired `<category>`. To get
a list of the available modules, run :

```bash
nf-core modules \
  --git-remote https://github.com/scilus/nf-scil.git \
  list remote
```

# Developing in `nf-scil`

## Dependencies

- Python &geq; 3.8, < 3.13
- Java Runtime &geq; 11, &leq; 17
  - On Ubuntu, install `openjdk-jre-<version>` packages
- Nextflow &geq; 21.04.3
- Node &geq; 14 and Prettier (seel [below](#installing-prettier))

> [!IMPORTANT]
> Nextflow might not detect the right `Java virtual machine` by default, more so if
> multiple versions of the runtime are installed. If so, you need to set the environment
> variable `JAVA_HOME` to target the right one.
>
> - Linux : look in `/usr/lib/jvm` for
>   a folder named `java-<version>-openjdk-<platform>` and use it as `JAVA_HOME`.
> - MacOS : if the `Java jvm` is the preferential one, use `JAVA_HOME=$(/usr/libexec/java_home)`.
>   Else, look into `/Library/Java/JavaVirtualMachines` for the folder with the correct
>   runtime version (named `jdk<inner version>_1<runtime version>.jdk`) and use the
>   following : `/Library/Java/JavaVirtualMachines/dk<inner version>_1<runtime version>.jdk/Contents/Home`.

## Developer installation

The project uses _poetry_ to manage python dependencies. To install it using pipx,
run the following commands :

```bash
pip install pipx
pipx ensurepath
pipx install poetry
```

> [!NOTE]
> If the second command above fails, `pipx` cannot be found in the path. Prepend the
> second command with `$(which python) -m` and rerun the whole block.

> [!WARNING]
> Poetry doesn't like when other python environments are activated around it. Make
> sure to deactivate any before calling `poetry` commands.

Once done, install the project with :

```bash
poetry install
```

## Loading the project's environment

> [!IMPORTANT]
> Make sure no python environment is activated before running commands !

The project scripts and dependencies can be accessed using :

```bash
poetry shell
```

which will activate the project's python environment in the current shell.

> [!NOTE]
> You will know the poetry environment is activated by looking at your shell. The
> input line should be prefixed by : `(nf-scil-tools-py<version>)`, with `<version>`
> being the actual Python version used in the environment.

To exit the environment, simply enter the `exit` command in the shell.

> [!IMPORTANT]
> Do not use traditional deactivation (calling `deactivate`), since it does not relinquish
> the environment gracefully, making it so you won't be able to reactivate it without
> exiting the shell.

## Working with VS Code

### Manual configuration of the VS Code project :

First install the `nf-scil-extensions` package. You can find it easily on the [extension
marketplace](https://marketplace.visualstudio.com/items?itemName=AlexVCaron.nf-scil-extensions).

### Configuration via the `devcontainer` :

The `devcontainer` definition for the project contains all required dependencies and setup
steps are automatically executed. Open the cloned repository in _VS Code_ and click on the
arrow box in the lower left corner, to get a prompt to `Reopen in container`. The procedure
will start a docker build, wait for a few minutes and enjoy your fully configured development
environment.

- Available in the container :

  - `nf-scil`, `nf-core` all accessible through the terminal, which is configured to load
    the `poetry` environment in shells automatically
  - `git`, `git-lfs`, `github-cli`
  - `curl`, `wget`, `apt-get`
  - `nextflow`, `docker`, `tmux`

- Available in the VS Code IDE through extensions :
  - Docker images and containers management
  - Python and C++ linting, building and debugging tools
  - Github Pull Requests management
  - Github flavored markdown previewing

## Contributing to `nf-scil`

If you want to propose a new `module` to the repository, follow the guidelines in the
[module creation](./docs/MODULE.md) documentation. we follow standards closely
aligned with `nf-core`, with some exceptions on process atomicity and how test data is
handled. Modules that don't abide to them won't be accepted and PR containing them will
be closed automatically.

## Running tests

Tests are run through `nf-core`, using the command :

```bash
nf-core modules \
  --git-remote https://github.com/scilus/nf-scil.git \
  test <category/tool>
```

The tool can be omitted to run tests for all modules in a category.


# Installing Prettier

To install **Prettier** for the project, you need to have `node` and `npm` installed on your system to at least version 14. On Ubuntu, you can do it using snap :

```bash
sudo snap install node --classic
```

However, if you cannot install snap, or have another OS, refer to the [official documentation](https://nodejs.org/en/download/package-manager/) for the installation procedure.

Under the current configuration for the *Development Container*, for this project, we use the following procedure, considering `${NODE_MAJOR}` is at least 14 for Prettier :

```bash
curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - &&\
apt-get install -y nodejs

npm install --save-dev --save-exact prettier

echo "function prettier() { npm exec prettier $@; }" >> ~/.bashrc
```
