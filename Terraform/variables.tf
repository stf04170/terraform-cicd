# ------------------------------
# Variables
# ------------------------------

# プリフィックスを設定
variable "prefix" {
  default = "tf-api-241018"
}

# プロジェクトを識別する一意の識別子を設定
variable "project" {
  default = "tf-api-241018-pj"
}

# プロジェクトのオーナーを設定
variable "owner" {
  default = "stf04170"
}

# DBのユーザ名を設定
variable "db_username" {
  description = "Username for the RDS postgres instance"
}

# DBのパスワードを設定
variable "db_password" {
  description = "Password for the RDS postgres instance"
}

variable "stage_name" {
  default = "stg"
}
