# Description
This package is ECS Service - Terraform Module using CodePipeline and Codebuild or Gitlab to push a Docker Image to Amazon ECR

# Setup
* [Create a State File Bucket](https://github.com/josjaf/examples/blob/master/aws/s3/tf_state_file.py)
* copy `beta.tfvars` and `beta-init.tfvars` in the same folder to include your config values. Make sure that the `bucket` variable points to the S3 State file bucket you just created. 
* add the variable `bucket` with the newly created bucket
* Edit the `Makefile` target `app-deploy` to point to your tfvars file
* When calling the Init command, your config cannot have any unused variables, which is why we separate a config for init and plan/apply

* Deploy the `application folder` from the root using the make file target
    * The ECR infrastructure lives here. You must push the docker image in order for the ECS Service to come up. The ECS Service can be created without the Docker Image being available.
    * Use CodePipeline, Gitlab or CLI to push the docker image. 
* If you do no want to use CodePipeline and want to use Gitlab instead
* The `application` folder is meant to be deployed first. 
* Deploy the `cicd` folder only if you need it. Release the Pipeline to build the image that the application stack will use
    * Under the `cicd` folder from the root
    * `terraform -chdir=application init -backend-config="conf/beta-init.tfvars --reconfigure"`
    * `terraform -chdir=application apply -var-file conf/beta.tfvars`
    * `pip install git-remote-codecommit`
    * `git remote add cc codecommit::us-east-1://terraform-ecs `
