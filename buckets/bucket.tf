
# Bucket to send the data for piping
resource "aws_s3_bucket" "data_extraction" {
  bucket = "${var.region}-${var.account_id}-data-extraction"

  tags = {
    Name        = "data Extraction Bucket"
    Environment = "${var.environment}"
  }
}