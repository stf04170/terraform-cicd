terraform {
  # tfstateファイルを管理するようbackend(s3)を設定
  backend "s3" {
    bucket         = "terraform-playground-for-apiserver1"
    key            = "terrafrom-playground.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-playground-for-apiserver1"
  }
  # プロバイダを設定
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  # Terraformのバージョン制約
  required_version = ">= 1.2.0"
}

# ------------------------------
# Provider
# ------------------------------
# プロバイダ(AWS)を指定
provider "aws" {
  region = "ap-northeast-1"
}

# ------------------------------
# Locals
# ------------------------------
locals {
  # variables.tfから変数を取得
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environmnet = terraform.workspace
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# ------------------------------
# Current AWS Region(ap-northeast-1)
# ------------------------------
# 現在のAWS Regionの取得方法
data "aws_region" "current" {}
