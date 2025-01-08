# Балансировщик L-7
resource "yandex_alb_target_group" "vm" {
  name = "webservers-target-group"

  dynamic "target" {
    for_each = {
      for vm_name, instance in yandex_compute_instance.vm :
      vm_name => instance.network_interface.0 if vm_name == "webserv1" || vm_name == "webserv2"
    }

    content {
      ip_address = target.value.ip_address
      subnet_id  = target.value.subnet_id
    }
  }

  depends_on = [yandex_compute_instance.vm]
}

resource "yandex_alb_backend_group" "my-backend-group" {
  name             = "my-backend-group"

  http_backend {
    name             = "my-backend-group"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.vm.id]

    healthcheck {
      timeout  = "5s"
      interval = "10s"
      http_healthcheck {
        path = "/"
      }
    }
  }

  depends_on = [yandex_alb_target_group.vm]
}

resource "yandex_alb_http_router" "my-router" {
  name = "my-http-router"
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "my-virtual-host"
  http_router_id = yandex_alb_http_router.my-router.id

  route {
    name        = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.my-backend-group.id
      }
    }
  }

  depends_on = [
    yandex_alb_http_router.my-router,
    yandex_alb_backend_group.my-backend-group
  ]
}

resource "yandex_alb_load_balancer" "my-load-balancer" {
  name = "my-load-balancer"

  network_id = yandex_vpc_network.network-1.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-3.id
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.my-router.id
      }
    }
  }

  timeouts {
    create = "20m"  # Увеличиваем таймаут для создания до 20 минут
    update = "20m"  # Таймаут для обновления
    delete = "15m"  # Таймаут для удаления
  }  

  depends_on = [
    yandex_alb_target_group.vm,
    yandex_alb_http_router.my-router
  ]
}

output "external_IP_address_of_the_load_balancer" {
  value = yandex_alb_load_balancer.my-load-balancer.listener[0].endpoint[0].address[0].external_ipv4_address
  description = "External IP address of the load balancer"
}
