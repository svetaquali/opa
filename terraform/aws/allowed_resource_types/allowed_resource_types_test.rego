package torque.terraform_plan

test_allow_resource_types {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_resource_types as ["aws_s3_bucket"] 
  count(result) == 0
}

test_deny_unsupported_resource_types {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_resource_types as ["aws_instance", "aws_athena_database"] 
  count(result) == 1
}

test_validate_deny_message {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_resource_types as ["aws_instance", "aws_athena_database"] 
  expected_deny_message:= "Invalid resource type: 'aws_s3_bucket'. The allowed AWS resource types are: [\"aws_instance\", \"aws_athena_database\"]"
  result[expected_deny_message]
}
