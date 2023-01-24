package torque.terraform_plan

import input as tfplan

# --- Validate blob storage are private ---

deny[reason] {
    allowed_set:= { "private" }
    results_set:= { r | r:= tfplan.resource_changes[_].change.after.container_access_type }
    diff:= results_set - allowed_set
    
    # print("allowed_set:       ", allowed_set)
    # print("used_locations:    ", results_set)
    # print("diff:              ", diff)

    count(diff) > 0 # if true -> deny! and return this error ("reason") below
    reason:= "Deployment of a not private Azure blob storage is not allowed"
}

