locals {
  affinity = {
    "general-nodegroup" = {
      nodeAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = {
          nodeSelectorTerms = [
            {
              matchExpressions = [
                {
                  key      = var.general-node-group.key
                  operator = "In"
                  values = [
                    var.general-node-group.value
                  ]
                }
              ]
            }
          ]
        }
      }
    }

    "worker-nodegroup" = {
      nodeAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = {
          nodeSelectorTerms = [
            {
              matchExpressions = [
                {
                  key      = var.worker-node-group.key
                  operator = "In"
                  values = [
                    var.worker-node-group.value
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  }
}
