# Description
This package is ECS Service - Terraform Module using CodePipeline and Codebuild or Gitlab to push a Docker Image to Amazon ECR

# Setup
* [Create a State File Bucket](https://github.com/josjaf/examples/blob/master/aws/s3/tf_state_file.py)
* copy `beta.tfvars` and `beta-init.tfvars` to `myenv.tfvars` and `myenv-init.tfvars` in the same folder to include your config values. Make sure that the `bucket` variable points to the S3 State file bucket you just created.
* When calling the Init command, your config cannot have any unused variables, which is why we separate a config for init and plan/apply

* add the variable `bucket` with the newly created bucket to `myenv.tfvars` and `myenv-init.tfvars`
* `export ENV=myenv`
* `Make apply` This will deploy the application folder
* The ECR infrastructure lives here. You must push the docker image in order for the ECS Service to come up. The ECS Service can be created without the Docker Image being available.
* Without a Pipeline, after the `application` folder is deployed, [Push ECR Image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)
* Use CodePipeline, Gitlab or CLI to push the docker image. 
* If using Codepipeline, see `cicd` folder
* `.gitlab-ci.yml` file is included
* Deploy the `cicd` folder only if you need it. Release the Pipeline to build the image that the application stack will use
    * Under the `cicd` folder from the root
    * `terraform -chdir=application init -backend-config="conf/beta-init.tfvars --reconfigure"`
    * `terraform -chdir=application apply -var-file conf/beta.tfvars`
    * `pip install git-remote-codecommit`
    * `git remote add cc codecommit::us-east-1://terraform-ecs `
