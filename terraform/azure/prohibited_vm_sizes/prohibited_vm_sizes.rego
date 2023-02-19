package torque.terraform_plan

import input as tfplan

# This policy enforces a list of prohibited virtual machine sizes that can be used by environments launched from it.
# It takes an array of prohibited virtual machine sizes as an argument (in the data object):
#   prohibited_vm_sizes: the list of prohibited virtual machine sizes for usage.
#
# An example of a data object for this policy looks like this:
# {
#   "prohibited_vm_sizes": [
#       "Standard_DS1_v2"
#    ]
# }
#
# This example forbids the environments to use "Standard_DS1_v2" virtual machine size.

# --- Validate azure vm sizes ---

deny[reason] {
    not is_array(data.prohibited_vm_sizes)
    reason:= "The data variable 'prohibited_vm_sizes' has to be an array."
}

deny[reason] {
    prohibited_set:= { x | x:= data.prohibited_vm_sizes[_] }
    results_set:= { r | r:= tfplan.resource_changes[_].change.after.vm_size }

    diff:= prohibited_set - results_set
    
    # print("prohibited_set:    ", prohibited_set)
    # print("used_locations:    ", results_set)
    # print("diff:              ", diff)

    count(diff) < count(prohibited_set) # if true -> deny! and return this error ("reason") below
    reason:= concat("", ["Invalid VM size: '", sprintf("%s", [results_set[_]]), "'. The prohibited VM sizes for Azure are: ", sprintf("%s", [data.prohibited_vm_sizes])])    
}
