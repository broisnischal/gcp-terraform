# export GOOGLE_APPLICATION_CREDENTIALS="infrastructure/gcp-svc-key.json"


PROJECT_ID := learningtfnees
REGION := us-east1
TF_DIR := ./infrastructure
TF_BUCKET=learningtfnees-terraform-state

GCP_PROJECT=learningtfnees
DOMAIN=demo.gcp.nischal.pro

EMAIL=nischaldahal01395@gmail.com

GKE_ZONE=us-east1

IMAGE_REPO=gcr.io/${GCP_PROJECT}

.PHONY: client
client:
	cd client && npm run build

TF_BUCKET_URI=gs://${TF_BUCKET}

GKE_CLUSTER=cluster

K8S_CONTEXT=gke_${GCP_PROJECT}_${GKE_ZONE}_${GKE_CLUSTER}

IMAGE_REPO=gcr.io/${GCP_PROJECT}

CLIENT_URL=https://${DOMAIN}

API_URL=https://api.${DOMAIN}


# .PHONY: deploy
# deploy:
# 	gcloud functions deploy helloWorld --runtime python37 --trigger-http --project $(PROJECT_ID)


# api_build:
# 	docker build -t $(PROJECT_ID)/api:latest ./api

# client_build:
# 	docker build -t $(PROJECT_ID)/client:latest ./client

# api_push:
# 	docker tag $(PROJECT_ID)/api:latest gcr.io/$(PROJECT_ID)/api:latest
# 	docker push gcr.io/$(PROJECT_ID)/api:latest

# client_push:
# 	docker tag $(PROJECT_ID)/client:latest gcr.io/$(PROJECT_ID)/client:latest
# 	docker push gcr.io/$(PROJECT_ID)/client:latest

client-image:
	docker build -f client/Dockerfile -t ${IMAGE_REPO}/client .
	docker push ${IMAGE_REPO}/client

api-image:
	docker build -f api/Dockerfile -t ${IMAGE_REPO}/api:latest .
	docker push ${IMAGE_REPO}/api:latest

setup-kubectl:
	gcloud container clusters get-credentials ${GKE_CLUSTER} --zone ${GKE_ZONE} --project ${GCP_PROJECT}

setup-infrastructure: create-terraform-bucket init-infrastructure create-terraform-workspaces


create-terraform-bucket:
	gsutil ls -b ${TF_BUCKET_URI} || gsutil mb -p ${GCP_PROJECT} -l EUROPE-WEST3 ${TF_BUCKET_URI}
	gsutil versioning set on ${TF_BUCKET_URI}

init-infrastructure:
	cd infrastructure && terraform init

connect-kubernetes:
	gcloud container clusters get-credentials cluster --zone ${GKE_ZONE} --project ${GCP_PROJECT}

GET_IMAGE_SHA=docker inspect --format='{{index .RepoDigests 0}}'


terraform-action:
	@cd infrastructure && \
	terraform ${TF_ACTION} \
	\
	-var="email=${EMAIL}" \
	-var="google_cloud_project=${GCP_PROJECT}" \
	\
	-var="domain=${DOMAIN}" \
	-var="api_url=${API_URL}" \
	-var="client_url=${CLIENT_URL}" \
	\
	-var="client_image=$(shell $(GET_IMAGE_SHA) $(IMAGE_REPO)/client)" \
	-var="api_image=$(shell $(GET_IMAGE_SHA) $(IMAGE_REPO)/api)" \
	\
	-var="gke_zone=${GKE_ZONE}"

plan:
	$(MAKE) TF_ACTION=plan terraform-action

apply:
	$(MAKE) TF_ACTION=apply terraform-action

destroy:
	$(MAKE) TF_ACTION=destroy terraform-action

destroy:
	@echo "Destroying Terraform resources..."
	cd $(TF_DIR) && terraform destroy -var="google_cloud_project=$(PROJECT_ID)" -var="gke_zone=$(REGION)" -auto-approve

deploy: client-image api-image apply
