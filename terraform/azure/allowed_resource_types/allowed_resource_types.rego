package torque.terraform_plan

import input as tfplan

get_basename(path) = basename {
    arr:= split(path, "/")
    basename:= arr[count(arr)-1]
}

# This policy enforces a list of allowed resource types that can be used by environments launched from it.
# It takes an array of allowed resource types as an argument (in the data object):
#   allowed_resource_types: the list of allowed resource types for usage.
#
# An example of a data object for this policy looks like this:
# {
#   "allowed_resource_types": [
#       "azure_vm"
#    ]
# }
#
# This example allows the environments to use only "azure_vm" resource type.
deny[reason] {
    not is_array(data.allowed_resource_types)
    reason:= "The data variable 'allowed_resource_types' has to be an array."
}

deny[reason] {
    is_array(data.allowed_resource_types)
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
