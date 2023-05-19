
# Bucket to send the data for piping
resource "aws_s3_bucket" "data_ingestion" {
  bucket = "${var.region}-${var.account_id}-data-ingestion"

  tags = {
    Name        = "Ingestion bucket"
    Environment = "${var.environment}"
  }
}