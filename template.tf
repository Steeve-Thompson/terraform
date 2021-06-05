data "template_file" "app" {
  template = file("application.sh")
  vars = {
    Application_Name = var.Application_Name
  }
}
