package torque.terraform_plan

import input as tfplan

# --- Validate azure vm sizes ---

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
