
==============================================================
  TERRAFORM AWS — HA INFRASTRUCTURE
  Simple folder structure guide
==============================================================

FOLDER STRUCTURE:
─────────────────

  terraform-aws-ha/
  │
  ├── 1-bootstrap/               ← STEP 1: Run only once
  │   ├── main.tf
  │   ├── variables.tf
  │   └── terraform.tfvars       ← ONLY change the bucket name here
  │
  ├── 2-modules/                 ← DO NOT TOUCH (reusable code)
  │   ├── vpc/
  │   ├── bastion/
  │   ├── security-groups/
  │   ├── alb/
  │   ├── ec2-asg/
  │   ├── rds/
  │   ├── cloudfront/
  │   └── route53/
  │
  └── 3-project/                 ← STEP 2: Your project goes here
      ├── backend.tf              ← Enter bucket name here
      ├── terraform.tfvars        ← Enter your values here (main file)
      ├── main.tf                 ← do not touch
      ├── variables.tf            ← do not touch
      ├── outputs.tf              ← do not touch
      ├── versions.tf             ← do not touch
      └── startup-scripts/
          ├── frontend.sh         ← Add your app code here
          └── backend.sh          ← Add your app code here


==============================================================
  READY TO DEPLOY? JUST 3 STEPS:
==============================================================

STEP 1 — Run once (create S3 bucket for Terraform state):
  cd 1-bootstrap/
  Enter bucket name in terraform.tfvars
  terraform init
  terraform apply

STEP 2 — Configure your project:
  Enter bucket name in 3-project/backend.tf
  Enter your values in 3-project/terraform.tfvars
  Export secrets in terminal (do NOT write them in files!)

STEP 3 — Deploy:
  cd 3-project/
  terraform init
  terraform plan
  terraform apply


==============================================================
  WANT TO REUSE FOR A NEW PROJECT?
==============================================================

  1. Copy this entire folder into your new project
  2. Only change values in 3-project/terraform.tfvars
  3. Enter new bucket name and key path in backend.tf
  4. Done!

==============================================================
