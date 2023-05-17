
# Bucket to send the data for piping
resource "aws_s3_bucket" "data-ingestion" {
  bucket = "data-ingestion"

  tags = {
    Name        = "Data Ingestion"
    Environment = "Dev"
  }
}