.PHONY: all creds init plan apply destroy
all: creds

cicd-deploy:
	terraform -chdir=cicd init -backend-config="conf/beta-init.tfvars" --reconfigure
	terraform -chdir=cicd apply -var-file "conf/beta.tfvars" -auto-approve
cicd-destroy:
	terraform -chdir=cicd init -backend-config="conf/beta-init.tfvars" --reconfigure base-tf
	terraform -chdir=cicd destory -var-file "conf/beta.tfvars" base-tf
deploy-all:
	terraform -chdir=cicd init -backend-config="conf/beta-init.tfvars" --reconfigure
	terraform -chdir=cicd apply -var-file "conf/beta.tfvars" -auto-approve
	terraform -chdir=application init -backend-config="conf/beta-init.tfvars" --reconfigure
	terraform -chdir=application apply -var-file "conf/beta.tfvars" -auto-approve
	git remote rm cc
	git remote add cc codecommit::us-east-1://terraform-ecs
	git push cc master


