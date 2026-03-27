# ================================================================
#  1-pehle-chalao/terraform.tfvars
#
#  Yeh file ek BAAR banao — S3 bucket create hoga
#  Bucket naam globally unique hona chahiye
# ================================================================

state_bucket_name = "hirewalk-tf-state-prod"   # ← CHANGE KARO (unique naam)
lock_table_name   = "terraform-state-lock"
aws_region        = "us-west-2"
