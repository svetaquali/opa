package torque.terraform_plan

test_allow_providers {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_providers as ["aws"]
  count(result) == 0
}

test_allow_providers_case_insensitive {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_providers as ["null", "aWs"]
  count(result) == 0
}

test_deny_unsupported_providers {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_providers as ["null", "azurerm"]
  count(result) == 1
}

test_validate_deny_message {
  result:= deny 
                with input as data.plan_mock
                with data.allowed_providers as ["null", "azurerm"] 
  expected_deny_message:= "Invalid provider: 'aws'. The allowed providers are: [\"null\", \"azurerm\"]"
  result[expected_deny_message]
}
