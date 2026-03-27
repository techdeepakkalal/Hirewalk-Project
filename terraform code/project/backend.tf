# ================================================================
# STEP 1 — Pehle  1-pehle-chalao/  folder mein jaake
#           terraform apply karo — S3 bucket banega
# STEP 2 — Us bucket ka naam neeche daalo aur terraform init karo
# ================================================================

terraform {
  backend "s3" {
    bucket         = "hirewalk-tf-state-prod"   # ← CHANGE KARO
    key            = "hirewalk/prod/terraform.tfstate"  # ← project naam badlo
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
