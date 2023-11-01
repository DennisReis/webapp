## About

This project creates a webserver that serves a simple web page:
- The first time it is accessed it shows the string “Hello” and the next time
“World” and then flips between them each time it is visited

## Pre-requisites

- kind
- docker
- kubectl
- helm
- python

## Setup

- a simple `app` in `python` 
- convert it into a docker image(containerization) using `Dockerfile`
- package the deployment using a helm chart using `chart`
- deploy the service using helm chart onto local `kubernetes cluster` created with `kind`
- usage of `Makefile` (commands to facilitate all above items run `make help` for the helper )