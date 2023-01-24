package torque.terraform_plan

test_allow_private_blob_storages {
  result:= deny with input as data.plan_mock
  count(result) == 0
}

test_validate_deny_message {
  result:= deny with input as data.plan_mock_2
  expected_deny_message:= "Deployment of a not private Azure blob storage is not allowed"
  result[expected_deny_message]
}

