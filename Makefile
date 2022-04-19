TF_OUTPUT=${CI_PROJECT_DIR}/application/output.json
#TF_OUTPUT=application/output.json
TF_PLAN=plan.tfplan
TF_ROOT=application

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
pipeline-generate-plan:  ## Generate Terraform plan file
	@echo "Generating plan"
	(terraform -chdir=application init -backend-config="conf/${ENV}-init.tfvars" --reconfigure; \
	terraform -chdir=application plan -var-file "conf/${ENV}.tfvars" -out ${TF_PLAN})
pipeline-apply-plan:  ## Generate Terraform plan file
	@echo "Applying plan"
	(terraform -chdir=${TF_ROOT} apply ${TF_PLAN}; \
	terraform -chdir=${TF_ROOT} output -json > ${TF_OUTPUT})
validate:
	terraform -chdir=application validate
gitpush:
	git remote rm cc
	git remote add cc codecommit::us-east-1://terraform-ecs
	git push cc master
deploy-all: cicd-deploy app-deploy gitpush
destroy-all: cicd-destroy app-destroy


