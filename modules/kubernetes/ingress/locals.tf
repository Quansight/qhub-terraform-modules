locals {
  affinity = {
    nodeAffinity = {
      requiredDuringSchedulingIgnoredDuringExecution = {
        nodeSelectorTerms = [
          {
            matchExpressions = [
              {
                key      = var.node-group.key
                operator = "In"
                values = [
                  var.node-group.value
                ]
              }
            ]
          }
        ]
      }
    }
  }
}
