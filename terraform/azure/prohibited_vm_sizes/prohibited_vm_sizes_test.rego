package torque.terraform_plan

test_allow_vm_size {
  result:= deny 
                with input as data.plan_mock
                with data.prohibited_vm_sizes as ["D2ads_v5", "DS2_v2", "E2ads_v5", "E8bds_v5", "E4ds_v5"]
  count(result) == 0
}

test_deny_prohibited_vm_sizes {
  result:= deny 
                with input as data.plan_mock
                with data.prohibited_vm_sizes as ["Standard_DS1_v2", "D2ads_v5"]
  count(result) == 1
}

test_validate_deny_message {
  result:= deny 
                with input as data.plan_mock
                with data.prohibited_vm_sizes as ["Standard_DS1_v2", "D2ads_v5"]
  expected_deny_message:= "Invalid VM size: 'Standard_DS1_v2'. The prohibited VM sizes for Azure are: [\"Standard_DS1_v2\", \"D2ads_v5\"]"
  result[expected_deny_message]
}
