provider "kubernetes" {
   # load_config_file       = "false"
    host                   =  var.host
    client_certificate     =  var.client_certificate
    client_key             =  var.client_key
    cluster_ca_certificate =  var.cluster_ca_certificate
}

resource "kubernetes_namespace" "employee" {
  metadata {
    annotations = {
      name = "employee"
    }

    labels = {
      mylabel = "employee"
    }

    name = "employee"
  }
}

resource "kubernetes_deployment" "mssql-deployment" {
  metadata {
    name = "mssql-deployment"
    namespace = "employee"
    labels = {
      test = "mssql-deployment"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mssql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mssql"
        }
      }

      spec {
        securityContext {
            fsGroup = "10001"
        }
        container {
          image = "mcr.microsoft.com/mssql/server:2017-CU8-ubuntu"
          name  = "mssql"

          resources {
            limits {
              cpu    = "1"
              memory = "4Gi"
            }
            requests {
              cpu    = "1"
              memory = "4Gi"
            }
          }
          ports = [
            {
             - containerPort = "1433"
            }
          ]
          env = [ 
          {
            - name =  "ACCEPT_EULA"
              value = "Y"
            - name = "SA_PASSWORD"
              value = "your_password"
            - name = "MSSQL_AGENT_ENABLED"
              value = "true"
          }
          ]
        }
      }
    }
  }
}

resource "kubernetes_service" "mssql-service" {
  metadata {
    name = "mssql-service"
    namespace = "employee"
  }
  spec {
    selector = {
      app = "mssql"
    }
    session_affinity = "ClientIP"
    port {
      port        = 1433
      target_port = 1433
    }

    type = "LoadBalancer"
  }
}