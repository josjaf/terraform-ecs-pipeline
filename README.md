# Description
This package is a Terraform Module using CodePipeline and Codebuild to push a Docker Image to Amazon ECR

# Setup
* [Create a State File Bucket](https://github.com/josjaf/examples/blob/master/aws/s3/tf_state_file.py)
* add the variable `bucket` with the newly created bucket
* When calling the Init command, your config cannot have any unused variables, which is why we separate them
* Deploy the `cicd` folder first. Release the Pipeline to build the image that the application stack will use
    * The Pipeline will fail the first time it runs after the Image is built because there is no ECS Cluster and Service to deploy to
    * Under the `cicd` folder from the root
    * `terraform init -backend-config="conf/beta-init.tfvars"`
    * `terraform apply -var-file conf/beta.tfvars`
    * `pip install git-remote-codecommit`
    * `git remote add cc codecommit::us-east-1://terraform-ecs `


* Deploy the `application folder` from the root
    * You need to create the application infrastructure before triggering the pipeline
    * `terraform -chdir=application init -backend-config="conf/beta-init.tfvars" --reconfigure`
    * `terraform -chdir=application apply -var-file "conf/beta.tfvars"`
    * `git push cc master`
* If you do no want to use CodePipeline and want to use Gitlab instead, you still must deploy the ecr and key with the Pipeline