# Ushahidi development environment tool

This repository contains tools to aid the creation of a development environment for running and customizing the
[Ushahidi Platform v3](http://github.com/ushahidi/platform).

This tool works by setting up the platform components to run on [Docker](https://www.docker.com).

## Requirements

* Mac OS X / Linux
  * Possibly, Windows with `bash` could work
* `git` command line tool
* [Docker Toolbox](https://www.docker.com/products/docker-toolbox) >= 1.10
  * If in doubt, just download and install the latest
  * Alternatively (advanced users) these Docker components are needed:
    * Docker Engine >= 1.9.0
    * Docker Compose >= 1.6.0

Additionally, as a requirement of the platform itself:

* A [github.com](https://github.com) account
* A [github.com](https://github.com) access token on your account, with permissions to clone public repositories
  * In order to learn how to create such token, please follow [these instructions](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).
  * Note that in the scopes list, only `repo:public_repo` is required. Selecting more scopes will
    give more unnecessary privileges to the token, and cause more damage if someone else ever comes
    in possession of that token.

## Quickstart

* Open a console window with docker environment support
  * In Docker Toolbox, this is known as the _"Docker Quickstart Terminal"_
* In that same console window run

      ./ush.sh create <path to your project folder>

  * This will create your project folder and copy the scripts in this repo there
* From your project folder run

      GITHUB_TOKEN=<your github access token> ./ush.sh start

  * This will clone the Ushahidi Platform repositories into your project folder, build the docker
    containers necessary for running the components and start them.
  * Providing the github access token is necessary only once. Subsequent invokations of `ush.sh` in
    the project directory are not required to provide the token.

* Once the start process is finished, your installation will be running on

      http://<your docker engine ip>:8080

  * In order to find out the docker engine ip, most of Docker Toolbox users would run the command `docker-machine ip default`

  * **Please note**: if it looks like the site is not loading completely, give it a few more minutes. Some of the build processes happen in the background and your site may still be being built.

## How do I...

We are just getting started with this tool and there's only a few things we've had time to teach it.

On top of that, working on a Docker development environment is not yet really developer friendly. If you haven't done it before, you will struggle. Be patient.

If there's something you would like the tool to help you with, please create an issue in this repository and make a case for it. We'll see what we can do.
