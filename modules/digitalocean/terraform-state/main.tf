module "spaces" {
  source = "../spaces"

  name   = "${var.name}-terraform-state"
  region = var.region
  public = false
}
