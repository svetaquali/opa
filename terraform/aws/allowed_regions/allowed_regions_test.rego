package torque.terraform_plan

test_allow_regions {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_regions as ["eu-west-1"]                
  count(result) == 0
}

test_deny_unsupported_region {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_regions as ["eu-west-2", "eu-east-3"] 
  count(result) == 1
}

test_validate_deny_message {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_regions as ["eu-west-2", "eu-east-3"] 
  expected_deny_message:= "Invalid region: 'eu-west-1'. The allowed AWS regions are: [\"eu-west-2\", \"eu-east-3\"]"
  result[expected_deny_message]
}
