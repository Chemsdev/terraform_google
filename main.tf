# =================================================================================================================================>
# BUCKET

# Connexion.
provider "google" {
  project = "midyear-cursor-438107-d6" 
  region  = "europe-central2"  
}

# Créer un bucket Google Cloud Storage.
resource "google_storage_bucket" "my_bucket" {
  name     = "my-terraform-bucket-20241010" 
  location = "EU"      
  force_destroy = true            

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age        = 365  
      with_state = "ANY"
    }
  }

  # Configuration de la classe de stockage (facultatif)
  storage_class = "STANDARD" 

  # Autorisations (facultatif)
  uniform_bucket_level_access = true 
}

# Ajouter un fichier "clients.csv" dans le dossier "csv".
resource "google_storage_bucket_object" "clients_file" {
  name   = "csv/clients.csv" 
  bucket = google_storage_bucket.my_bucket.name
  source = "data_csv/clients.csv"  
}

# Ajouter un fichier "produits.csv" dans le dossier "csv".
resource "google_storage_bucket_object" "produits_file" {
  name   = "csv/produits.csv" 
  bucket = google_storage_bucket.my_bucket.name
  source = "data_csv/produits.csv"  
}

# Ajouter un fichier "stocks.csv" dans le dossier "csv".
resource "google_storage_bucket_object" "stocks_file" {
  name   = "csv/stocks.csv" 
  bucket = google_storage_bucket.my_bucket.name
  source = "data_csv/stocks.csv"  
}

# Ajouter un fichier "ventes.csv" dans le dossier "csv".
resource "google_storage_bucket_object" "ventes_file" {
  name   = "csv/ventes.csv" 
  bucket = google_storage_bucket.my_bucket.name
  source = "data_csv/ventes.csv"  
}


# =================================================================================================================================>
# CLOUD FUNCTIONS 

# Créer un bucket pour stocker le fichier ZIP contenant le code de la fonction
resource "google_storage_bucket" "bucket" {
  name     = "midyear-cursor-438107-d6"  
  location = "europe-west9"  
  uniform_bucket_level_access = true  
}

# Télécharger l'archive ZIP dans le bucket
resource "google_storage_bucket_object" "object" {
  name   = "new-function-source.zip"  
  bucket = google_storage_bucket.bucket.name
  source = "cloud_function/function-code.zip"  
}

# Créer la Cloud Function
resource "google_cloudfunctions2_function" "function" {
  name        = "csv_to_parquet_terraform"  
  location    = "europe-west9"  
  description = "A new function that processes data"  

  build_config {
    runtime    = "python310"  
    entry_point = "hello_http"  
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count  = 3  
    available_memory    = "512M"  
    timeout_seconds     = 120  
  }
}

# =================================================================================================================================>
# WORKFLOW

resource "google_workflows_workflow" "my_workflow" {
  name     = "workflow_terraform"
  region   = "us-central1"  
  source_contents = file("workflow.yaml")
}

output "workflow_name" {
  value = google_workflows_workflow.my_workflow.name
}


