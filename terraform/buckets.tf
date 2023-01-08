resource "google_storage_bucket" "log_bucket" {

  name = "${var.cluster_name}-${var.log_bucket_name}"

  storage_class = var.bucket_storage_type

  location = var.region_name

}

resource "google_storage_bucket" "cache_bucket" {

  name = "${var.cluster_name}-${var.cache_bucket_name}"

  storage_class = var.bucket_storage_type

  location = var.region_name

}
