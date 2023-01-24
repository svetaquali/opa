package torque.terraform_plan

import input as tfplan

get_basename(path) = basename {
    arr:= split(path, "/")
    basename:= arr[count(arr)-1]
}

deny[reason] {
    azure_resources:= [r | r:= tfplan.resource_changes[_]; get_basename(r.provider_name) == "azurerm"]

    allowed_set:= { x | x:= data.allowed_resource_types[_] }
    results_set:= { t | t:= azure_resources[_].type }
    diff:= results_set - allowed_set
    
    # print("allowed_set:       ", allowed_set)
    # print("used_locations:    ", results_set)
    # print("diff:              ", diff)

    count(diff) > 0 # if true -> deny! and return this error ("reason") below
    reason:= concat("", ["Invalid resource type: '", sprintf("%s", [results_set[_]]), "'. The allowed Azure resource types are: ", sprintf("%s", [data.allowed_resource_types])])
}
