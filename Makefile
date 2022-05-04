TF_OUTPUT=${CI_PROJECT_DIR}/application/output.json
#TF_OUTPUT=application/output.json
TF_PLAN=plan.tfplan
TF_ROOT=application

pipeline-generate-plan:  ## Generate Terraform plan file
	@echo "Generating plan"
	(terraform -chdir=application init -backend-config="conf/${ENV}-init.tfvars" --reconfigure; \
	terraform -chdir=application plan -var-file "conf/${ENV}.tfvars" -out ${TF_PLAN})
pipeline-apply-plan:  ## Generate Terraform plan file
	@echo "Applying plan"
	(terraform -chdir=${TF_ROOT} apply ${TF_PLAN}; \
	terraform -chdir=${TF_ROOT} output -json > ${TF_OUTPUT})
apply:
	(terraform -chdir=application init -upgrade -backend-config="conf/${ENV}-init.tfvars" --reconfigure; \
	terraform -chdir=application apply -var-file "conf/${ENV}.tfvars" -auto-approve; terraform -chdir=application output -json > application/output.json)
validate:
	terraform -chdir=application validate
gitpush:
	git remote rm cc
	git remote add cc codecommit::us-east-1://terraform-ecs
	git push cc master
destroy:
	(terraform -chdir=application init -upgrade -backend-config="conf/${ENV}-init.tfvars" --reconfigure; \
	terraform -chdir=application destroy -var-file "conf/${ENV}.tfvars" -auto-approve)
beta-app-apply:
	(export ENV=beta; export AWS_PROFILE=work; make pipeline-apply)
beta-app-destroy:
	(export ENV=beta; export AWS_PROFILE=work; make destroy)
deploy-all: cicd-deploy app-deploy gitpush
destroy-all: cicd-destroy app-destroy

