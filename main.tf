resource "aws_iam_user" "users" {
  for_each = { for user in local.users : user.first_name => user }
  name     = "${substr(each.value.first_name, 0, 1)}.${each.value.last_name}"
  path     = "/user/"

  tags = {
    Name       = "${each.value.first_name}.${each.value.last_name}"
    department = each.value.department
    job_title  = each.value.job_title
  }
}

resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users

  user                    = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }
}



resource "aws_iam_group" "engineers" {
  name = "Engineers"
  path = "/groups"
}
resource "aws_iam_group" "education" {
  name = "Education"
  path = "/groups"
}
resource "aws_iam_group" "managers" {
  name = "Managers"
  path = "/groups"
}

resource "aws_iam_group_membership" "education_members" {
  name   = "education-group-membership"
  group = aws_iam_group.education.name
  users  = [for user in aws_iam_users : user.name if user.tags.department == "Education"]
}
resource "aws_iam_group_membership" "engineers_members" {
  name   = "engineers-group-membership"
  group = aws_iam_group.engineers.name
  users  = [for user in aws_iam_users : user.name if user.tags.department == "Engineers"]
}
resource "aws_iam_group_membership" "managers_members" {
  name   = "managers-group-membership"
  group = aws_iam_group.managers.name
  users  = [for user in aws_iam_users : user.name if user.tags.department == "Managers"]
}
