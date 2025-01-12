MINIKUBE = /usr/bin/env minikube
KUSTOMIZE = /usr/bin/env kustomize
KUBECTL = /usr/bin/env kubectl

ELASTIC-OPERATOR-PATH := vendor/ec-on-k8s
ELASTIC-OPERATOR-FILE := all-in-one.yaml
ELASTIC-OPERATOR-URL := https://download.elastic.co/downloads/eck/1.4.0/all-in-one.yaml

$(ELASTIC-OPERATOR-PATH):
	mkdir -p $(ELASTIC-OPERATOR-PATH)

$(ELASTIC-OPERATOR-PATH)/$(ELASTIC-OPERATOR-FILE): $(ELASTIC-OPERATOR-PATH)
	curl -o $(ELASTIC-OPERATOR-PATH)/$(ELASTIC-OPERATOR-FILE) $(ELASTIC-OPERATOR-URL)

elastic-operator: $(ELASTIC-OPERATOR-PATH)/$(ELASTIC-OPERATOR-FILE)
	kubectl apply -f $(ELASTIC-OPERATOR-PATH)/$(ELASTIC-OPERATOR-FILE)

minikube:
	minikube start \
	--kubernetes-version=v1.20.5 \
	--driver=hyperv \
	--cpus=4 \
	--memory=7g \
	--bootstrapper=kubeadm \
	--extra-config=kubelet.authentication-token-webhook=true \
	--extra-config=kubelet.authorization-mode=Webhook \
	--extra-config=scheduler.address=0.0.0.0 \
	--extra-config=controller-manager.address=0.0.0.0
	minikube addons enable ingress
	minikube addons enable default-storageclass
	minikube addons enable storage-provisioner
	minikube addons enable metrics-server

	
step-1:
	kustomize build deploy/step-1 | kubectl apply -f -

step-2: elastic-operator
	kustomize build deploy/step-2 | kubectl apply -f -

step-3: elastic-operator
	kustomize build deploy/step-3 | kubectl apply -f -

step-4: elastic-operator
	kustomize build deploy/step-4 | kubectl apply -f -

.PHONY: minikube step-1 step-2 step-3 step-4
