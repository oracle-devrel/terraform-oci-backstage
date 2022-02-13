# Copyright (c) 2019, 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# get latest Linux 8.2 image
data "oci_core_images" "ol8" {
  compartment_id = local.compartment_id
  operating_system = "Oracle Linux"
  filter {
    name = "display_name"
    values = ["^Oracle-Linux-8.5-([\\.0-9-]+)$"]
    regex = true
  }
}


data "oci_identity_availability_domains" "ad" {
  compartment_id = local.compartment_id
}

locals{
  ad_map = {for ad_number,ad in data.oci_identity_availability_domains.ad.availability_domains : "${ad.name}" => (ad_number+1) }
}
  


