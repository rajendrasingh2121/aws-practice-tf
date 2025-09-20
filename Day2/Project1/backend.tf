
terraform {
	backend "s3" {
		bucket = "tfstoragebucketdemo2025"
		key    = "day2/project1/terraform.tfstate"
		region = "eu-west-1"
        use_lockfile = true
	}
}
