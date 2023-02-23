package torque.terraform_plan

test_allowed_locations {
  reason:= deny 
                with input as data.plan_mock
                with data.allowed_locations as ["eastus"]  
                # with data.allowed_locations as ["eastusXXX"]  # uncomment this to fail the test 
  count(reason) == 0
}

test_deny_unsupported_locations {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_locations as ["eastus2"] 
  count(result) == 1
}

test_validate_deny_message {
  reason:= deny 
                with input as data.plan_mock
                with data.allowed_locations as ["eastus2", "westus2"] 
                # with data.allowed_locations as ["eastus"] # uncomment this line to fail the test
  expected_deny_message:= "Invalid location: 'eastus'. The allowed Azure locations are: [\"eastus2\", \"westus2\"]"

  reason[expected_deny_message]
}
