# variable "location" {
#   description = "Region where resources will be created"
#   type        = list(string)
#   default     = ["us-central1", "us-east1"]
# }

# variable "kms_keyring_bg" {
#   description = "KMS Keyring used for Bigtable in each region"
#   type        = string
#   default     = "keyring-example601"
# }

variable "num_zones" {
  type    = number
  default = 2
}

variable "project_id" {
  type    = string
  default = "modular-scout-345114"
}
