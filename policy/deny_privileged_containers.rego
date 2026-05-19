package main

deny contains msg if {
    is_workload
    not is_system_namespace

    container := all_containers[_]
    container.securityContext.privileged == true

    msg := sprintf(
        "[DENIED-AGAIN] We would like to formally register our exhaustion. '%v' in '%v/%v' is still not permitted. Please update your records accordingly.",
        [container.name, input.metadata.namespace, input.metadata.name],
    )
}
