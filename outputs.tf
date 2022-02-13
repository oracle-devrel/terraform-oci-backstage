# Copyright (c) 2019, 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "backstage-publicIP" {
  value = module.backstage_instance.public_ip_all_attributes.0.ip_address
}

output "backstage_instance" {
  description = "code-server instance details"
  value       = {
    "Instance name" = module.backstage_instance.instance_all_attributes.0.display_name,
    "Public IP" = module.backstage_instance.public_ip_all_attributes.0.ip_address,
    "OS version" = data.oci_core_images.ol8.images.0.display_name,
  }
}
