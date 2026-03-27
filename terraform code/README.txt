
==============================================================
  TERRAFORM AWS — HA INFRASTRUCTURE
  Simple folder structure guide
==============================================================

FOLDER STRUCTURE:
─────────────────

  terraform-aws-ha/
  │
  ├── 1-pehle-chalao/          ← STEP 1: Sirf ek baar chalao
  │   ├── main.tf
  │   ├── variables.tf
  │   └── terraform.tfvars     ← SIRF BUCKET NAAM BADLO
  │
  ├── 2-modules/               ← KABHI MAT CHHUO (reusable code)
  │   ├── vpc/
  │   ├── bastion/
  │   ├── security-groups/
  │   ├── alb/
  │   ├── ec2-asg/
  │   ├── rds/
  │   ├── cloudfront/
  │   └── route53/
  │
  └── 3-mera-project/          ← STEP 2: Apna project yahan
      ├── backend.tf            ← BUCKET NAAM DAALO
      ├── terraform.tfvars      ← APNI VALUES DAALO (main file)
      ├── main.tf               ← mat chhuo
      ├── variables.tf          ← mat chhuo
      ├── outputs.tf            ← mat chhuo
      ├── versions.tf           ← mat chhuo
      └── startup-scripts/
          ├── frontend.sh       ← APNA APP CODE DAALO
          └── backend.sh        ← APNA APP CODE DAALO


==============================================================
  DEPLOY KARNA HAI? SIRF YEH 3 STEPS:
==============================================================

STEP 1 — Pehle ek baar karo (S3 bucket banao):
  cd 1-pehle-chalao/
  terraform.tfvars mein bucket naam daalo
  terraform init
  terraform apply

STEP 2 — Project deploy karo:
  3-mera-project/backend.tf mein bucket naam daalo
  3-mera-project/terraform.tfvars mein apni values daalo
  Secrets terminal mein export karo (file mein mat likho!)

STEP 3 — Run karo:
  cd 3-mera-project/
  terraform init
  terraform plan
  terraform apply


==============================================================
  NAYE PROJECT MEIN REUSE KARNA HAI?
==============================================================

  1. Poora yeh folder copy karo naye project mein
  2. Sirf 3-mera-project/terraform.tfvars mein values badlo
  3. backend.tf mein naya bucket naam aur key path daalo
  4. Done!

==============================================================
