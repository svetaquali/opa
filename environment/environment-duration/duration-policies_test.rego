package torque.environment

import future.keywords.if

test_max_duration_denied_new_data_names {
    value := result with input.duration_minutes as 350
                          with data.env_max_duration_minutes as 300
                          with data.env_duration_for_manual_approval_minutes as 120
    value.decision == "Denied"
    value.reason == "environment duration exceeds max duration in 50 minutes"
}

test_max_duration_manual_new_data_names {
    value := result 
                          with input.duration_minutes as 120
                          with data.env_max_duration_minutes as 200
                          with data.env_duration_for_manual_approval_minutes as 100
    value.decision == "Manual"
    value.reason == "environment duration requires approval"
}

test_max_duration_approved_new_data_names {
    value := result 
                          with input.duration_minutes as 120
                          with data.env_max_duration_minutes as 200
                          with data.env_duration_for_manual_approval_minutes as 150
    value.decision == "Approved"
}