
# Bucket to send the data for piping
resource "aws_s3_bucket" "data_extraction" {
  bucket = "${var.region}-${var.account_id}-data-extraction"

  tags = {
    Name        = "data Extraction Bucket"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "prefect" {
  bucket = "${var.region}-${var.account_id}-prefect"

  tags = {
    Name        = "Prefect flows bucket"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "covid" {
  bucket = "${var.region}-${var.account_id}-covid"

  tags = {
    Name        = "Covid19"
    Environment = "${var.environment}"
  }
}