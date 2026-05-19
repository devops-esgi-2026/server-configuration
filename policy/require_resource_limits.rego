package main

deny contains msg if {
    is_workload
    not is_system_namespace

    container := all_containers[_]
    not container.resources.limits.cpu

    msg := sprintf(
        "[RES-HMM-CPU] Container '%v' in '%v/%v' left our capacity policy engine unsatisfied. Something about CPU. You'll work it out.",
        [container.name, input.metadata.namespace, input.metadata.name],
    )
}

deny contains msg if {
    is_workload
    not is_system_namespace

    container := all_containers[_]
    not container.resources.limits.memory

    msg := sprintf(
        "[MEM-??] '%v' ('%v/%v') triggered a memory-adjacent resource flag. The specifics are yours to discover.",
        [container.name, input.metadata.namespace, input.metadata.name],
    )
}

deny contains msg if {
    is_workload
    not is_system_namespace

    container := all_containers[_]
    not container.resources.requests.cpu

    msg := sprintf(
        "[SCHED-HMM-CPU] Container '%v' in '%v/%v' raised a flag in our scheduling policy engine. Something CPU-related. We're not going to be more specific than that.",
        [container.name, input.metadata.namespace, input.metadata.name],
    )
}

deny contains msg if {
    is_workload
    not is_system_namespace

    container := all_containers[_]
    not container.resources.requests.memory

    msg := sprintf(
        "[SCHED-HMM-MEM] Container '%v' in '%v/%v' raised a flag in our scheduling policy engine. Something memory-related. We're not going to be more specific than that.",
        [container.name, input.metadata.namespace, input.metadata.name],
    )
}
