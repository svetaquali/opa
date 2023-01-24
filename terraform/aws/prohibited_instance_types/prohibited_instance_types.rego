package torque.terraform_plan

import input as tfplan

# --- Validate aws instance types ---

get_basename(path) = basename{
    arr := split(path, "/")
    basename:= arr[count(arr)-1]
}

contains(arr, elem){
    arr[_] == elem
}

deny[reason] {
    resource := tfplan.resource_changes[_]
    get_basename(resource.provider_name) == "aws"
    instance_type:= resource.change.after.instance_type
    contains(data.prohibited_instance_types, instance_type)
    reason:= concat("",["Invalid instance type: '", instance_type, "'. The prohibited instance types for AWS are: ", sprintf("%s", [data.prohibited_instance_types])])
}
