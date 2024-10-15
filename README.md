# terraform-cicd
## Plan
terraform plan -var-file=vars.tfvars

## apply
terraform apply -var-file=vars.tfvars -auto-approve

## destroy
terraform destroy -var-file=vars.tfvars -auto-approve 