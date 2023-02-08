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


resource "google_storage_bucket_iam_binding" "binding" {
  bucket = "${var.cluster_name}-${var.cache_bucket_name}"
  role = "roles/storage.admin"
  members = [ "serviceAccount:${google_service_account.kubernetes.email}"
  ]
}

resource "google_storage_bucket_iam_binding" "binding2" {
  bucket = "${var.cluster_name}-${var.log_bucket_name}"
  role = "roles/storage.admin"
  members = [ "serviceAccount:${google_service_account.kubernetes.email}"
  ]
}

