import functions_framework
from google.cloud import storage  
import pandas as pd              
import io                        


def convert_file_csv_to_parquet(name_file:str):
    
    # Bucket et noms de fichiers
    bucket_name = "my-terraform-bucket-20241010"
    csv_filename = f"csv/{name_file}"  
    parquet_filename = f"parquet/{name_file.replace('.csv', '.parquet')}"  

    # Initialiser le client Google Cloud Storage
    client = storage.Client()
    bucket = client.bucket(bucket_name)

    # Télécharger le fichier CSV depuis le bucket
    blob = bucket.blob(csv_filename)
    csv_data = blob.download_as_bytes()

    # Lire le fichier CSV en mémoire avec Pandas
    csv_file = io.BytesIO(csv_data)
    df = pd.read_csv(csv_file)

    # Convertir le DataFrame en Parquet en mémoire
    parquet_buffer = io.BytesIO()
    df.to_parquet(parquet_buffer, index=False)

    # Remettre le curseur au début du tampon Parquet
    parquet_buffer.seek(0)  # Important pour éviter l'erreur

    # Créer un nouveau blob pour le fichier Parquet
    parquet_blob = bucket.blob(parquet_filename)

    # Télécharger le fichier Parquet vers le bucket
    parquet_blob.upload_from_file(parquet_buffer, content_type='application/octet-stream')

    return f"Le fichier {csv_filename} a été converti en {parquet_filename} et enregistré dans le bucket {bucket_name}."


@functions_framework.http
def hello_http(request):
    files = ["clients.csv", "produits.csv", "stocks.csv", "ventes.csv"]
    for i in files:
        convert_file_csv_to_parquet(name_file=i)
    return "C'est Okey", 200
