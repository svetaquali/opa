package torque.terraform_plan

import input as tfplan

# --- Validate resource types ---

get_basename(path) = basename {
    arr:= split(path, "/")
    basename:= arr[count(arr)-1]
}

contains(arr, elem){
    arr[_] == elem
}

deny[reason] {
    resource:= tfplan.resource_changes[_]
    get_basename(resource.provider_name) == "aws"
    not contains(data.allowed_resource_types, resource.type)
    reason:= concat("",["Invalid resource type: '", resource.type, "'. The allowed AWS resource types are: ", sprintf("%s", [data.allowed_resource_types])])
}
