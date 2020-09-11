#
# s3 Bucket with Website settings
#
resource "aws_s3_bucket" "this" {
  bucket = var.static_site_domain_name
  acl = "public-read"
  policy = data.aws_iam_policy_document.bucket_policy.json

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid = "AllowReadFromAll"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.static_site_domain_name}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
