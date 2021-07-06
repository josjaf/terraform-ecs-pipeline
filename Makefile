
.PHONY: all creds init plan apply destroy
all: creds

beta-application:
	terraform -chdir=application init -backend-config="conf/beta-init.tfvars" --reconfigure
	terraform -chdir=application apply -var-file "conf/beta.tfvars"
base-beta-eu-west-1:
	terraform init -backend-config="conf/beta-init.tfvars" --reconfigure base-tf
	terraform apply -var-file "conf/beta.tfvars" base-tf
