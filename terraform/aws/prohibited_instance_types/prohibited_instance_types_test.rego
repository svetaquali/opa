package torque.terraform_plan

test_allow_instance_type {
  result:= deny 
                with input as data.plan_mock.aws_instance
                with data.prohibited_instance_types as ["t2.2xlarge", "t2.xlarge", "t2.large", "t2.medium", "t2.small", "t2.nano"]
  count(result) == 0
}

test_deny_prohibited_instance_type {
  result:= deny 
                with input as data.plan_mock.aws_instance
                with data.prohibited_instance_types as ["t2.2xlarge", "t2.xlarge", "t2.large", "t2.medium", "t2.small", "t2.nano", "t2.micro"]
  count(result) == 1
}

test_validate_deny_message {
  result:= deny 
                with input as data.plan_mock.aws_instance
                with data.prohibited_instance_types as ["t2.2xlarge", "t2.xlarge", "t2.large", "t2.medium", "t2.small", "t2.nano", "t2.micro"]
  expected_deny_message:= "Invalid instance type: 't2.micro'. The prohibited instance types for AWS are: [\"t2.2xlarge\", \"t2.xlarge\", \"t2.large\", \"t2.medium\", \"t2.small\", \"t2.nano\", \"t2.micro\"]"
  result[expected_deny_message]
}
