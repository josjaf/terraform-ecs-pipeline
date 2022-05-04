terraform {
  backend "s3" {
    bucket = var.bucket
    key    = var.key # hard coding since this is a less disposable
    region = var.region
  }
}