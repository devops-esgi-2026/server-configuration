package main

required_labels := {"app"}

deny contains msg if {
    is_workload
    not is_system_namespace

    label := required_labels[_]
    not input.metadata.labels[label]

    msg := sprintf(
        "[TEMPLATE-??] The pod template for '%v/%v' left our policy engine feeling... incomplete. Have a close look at what you've declared.",
        [input.metadata.namespace, input.metadata.name, label],
    )
}

deny contains msg if {
    is_workload
    not is_system_namespace

    label := required_labels[_]
    not input.spec.template.metadata.labels[label]

    msg := sprintf(
        "[HOLD-META-08] Deployment of '%v/%v' has been suspended pending metadata compliance verification. Please open a ticket referencing your workload name to initiate the review process.",
        [input.metadata.namespace, input.metadata.name, label],
    )
}
