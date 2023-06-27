# Creating ECR repository to store images
# 886192468297.dkr.ecr.ap-southeast-2.amazonaws.com/node_image
resource "aws_ecr_repository" "node_image" {
  name                 = "node_image"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_iam_user" "ecr_user" {
  name = "ecr-user"
}

data "aws_iam_policy" "container_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_user_policy_attachment" "ecr_user_policy" {
  user   = aws_iam_user.ecr_user.name
  policy_arn = "${data.aws_iam_policy.container_full_access.arn}"
}