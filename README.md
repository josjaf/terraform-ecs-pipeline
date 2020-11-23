# Description
This package is a Terraform Module using CodePipeline and Codebuild to push a Docker Image to Amazon ECR

# Setup
* [Create a State File Bucket](https://github.com/josjaf/examples/blob/master/aws/bucket.sh)
* add the variable `bucket` with the newly created bucket
* When calling the Init command, your config cannot have any unused variables, which is why we separate them
* Deploy the `cicd` folder first. Release the Pipeline to build the image that the application stack will use
    * The Pipeline will fail the first time it runs after the Image is built because there is no ECS Cluster and Service to deploy to
    * Under the `cicd` folder
    * `terraform init -backend-config="conf/beta-init.tfvars"`
    * `terraform apply -var-file conf/beta.tfvars`
    * `pip install git-remote-codecommit`
    * `git remote add cc codecommit::us-east-1://terraform-ecs `

    * Under the `application folder`
    * `terraform init -backend-config="conf/beta-init.tfvars" --reconfigure`
    * `terraform apply -var-file conf/beta.tfvars`