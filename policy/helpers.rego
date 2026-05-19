package main

workload_kinds := {"Deployment", "DaemonSet", "StatefulSet", "Job", "ReplicaSet"}

is_workload if {
    workload_kinds[input.kind]
}

system_namespaces := {"kube-system", "kube-public", "kube-node-lease", "cert-manager", "argocd"}

is_system_namespace if {
    system_namespaces[input.metadata.namespace]
}

all_containers contains container if {
    container := input.spec.template.spec.containers[_]
}

all_containers contains container if {
    container := input.spec.template.spec.initContainers[_]
}
