#
# s3 Bucket with Website settings
#
resource "aws_s3_bucket" "this" {
  bucket = var.static_site_domain_name
  acl = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "AllowReadFromAll",
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::${var.static_site_domain_name}/*"
      }
  ]
}
EOF
}

#
# Creat cloudfront distribution so we can use SSL
#
/*
resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = aws_s3_bucket.this.bucket_domain_name
    origin_id = "${var.static_site_domain_name}-origin"
  }
  enabled = true
  aliases = [var.static_site_domain_name]
  price_class = "PriceClass_100"
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH",
                      "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.static_site_domain_name}-origin"
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 1000
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016" # defaults wrong, set
  }
}
*/
