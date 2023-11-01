CLUSTER_NAME?=local-dev
VERSION=0.0.3
APP_NAME=app
RELEASE_NAME=web

DEFAULT_GOAL:=help
.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: run-local
run-local: build-image  ## Build a Docker image and run the container locally
	@docker container run --rm --name ${RELEASE_NAME}-${APP_NAME} -d -p 80:5000 ${APP_NAME}:${VERSION}
	@echo "Use use http://localhost for accessing the application"

.PHONY: stop-local
stop-local: ## Stop the running container
	@docker container stop ${RELEASE_NAME}-${APP_NAME}

.PHONY: deploy-cluster
deploy-cluster: ## Creates a K8s cluster using kind
	@kind create cluster --name ${CLUSTER_NAME} --config k8s-cluster-config.yml

.PHONY: delete-cluster
delete-cluster: ## Deletes the K8s cluster
	@kind delete cluster --name ${CLUSTER_NAME}

.PHONY: delete-all
delete-all:  ## Deletes all the Helm releases and the K8s cluster
	@helm delete $(shell helm list -aq)
	@kind delete cluster --name ${CLUSTER_NAME} 

.PHONY: build-image
build-image:  ## Build locally the Docker image
	@docker image build --no-cache . -t ${APP_NAME}:${VERSION}

.PHONY: upload-image
upload-image:  ## Load the image to local kind registry
	@kind load --name ${CLUSTER_NAME} docker-image ${APP_NAME}:${VERSION}

.PHONY: deploy
deploy: upload-image  ## Loads the image and deploy the Helm release
	@helm install ${RELEASE_NAME} ./chart --set service.type=NodePort --set service.nodePort=30000

.PHONY: delete
delete:  ## Delete the Helm release
	@helm delete ${RELEASE_NAME}

node_port=$(shell kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services ${RELEASE_NAME}-${APP_NAME})
node_ip=$(shell kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")

.PHONY: node-url
node-url:  ## Gives the URL to request the webapp
	@echo "http://${node_ip}:${node_port}" 
	@echo "[[ NOTE: If using macOS, use http://localhost:8080 , made possible by k8s-cluster-config.yml extraPortMappings ]]"

.PHONY: status
status:  ## Returns the status of the pod
	@helm status ${RELEASE_NAME}
	@kubectl get pods