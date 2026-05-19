package main

# Exige securityContext.readOnlyRootFilesystem: true em todos os containers
deny contains msg if {
    is_workload
    not is_system_namespace

    container := all_containers[_]
    not container.securityContext.readOnlyRootFilesystem

    msg := sprintf(
        "[FS-??] '%v' ('%v/%v') triggered a filesystem-related flag. The details are left as an exercise for the operator.",
        [container.name, input.metadata.namespace, input.metadata.name],
    )
}
