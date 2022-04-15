.PHONY: all creds init plan apply destroy
all: creds

cicd-deploy:
	terraform -chdir=cicd init -upgrade -backend-config="conf/beta-init.tfvars" --reconfigure
	terraform -chdir=cicd apply -var-file "conf/beta.tfvars" -auto-approve
cicd-destroy:
	terraform -chdir=cicd init -backend-config="conf/beta-init.tfvars" --reconfigure
	terraform -chdir=cicd destroy -var-file "conf/beta.tfvars"
app-deploy:
	terraform -chdir=application init -upgrade -backend-config="conf/beta-init.tfvars" --reconfigure
	terraform -chdir=application apply -var-file "conf/beta.tfvars" -auto-approve
app-destroy:
	terraform -chdir=application init -upgrade -backend-config="conf/beta-init.tfvars" --reconfigure
	terraform -chdir=application destroy -var-file "conf/beta.tfvars" -auto-approve
gitpush:
	git remote rm cc
	git remote add cc codecommit::us-east-1://terraform-ecs
	git push cc master
deploy-all: cicd-deploy app-deploy gitpush
destroy-all: cicd-destroy app-destroy


