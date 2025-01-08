resource "null_resource" "run_ansible_webserv1" {
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible &&
      ansible-playbook ansible_web.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      ansible_host=${yandex_compute_instance.vm["webserv1"].network_interface.0.ip_address} \
      elastic_password=${var.elastic_passwd} \
      elastic_ip=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_90_seconds]
}

resource "null_resource" "run_ansible_webserv2" {
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible &&
      ansible-playbook ansible_web.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      ansible_host=${yandex_compute_instance.vm["webserv2"].network_interface.0.ip_address} \
      elastic_password=${var.elastic_passwd} \      
      elastic_ip=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_90_seconds]
}

resource "null_resource" "run_ansible_prometheus" {
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible &&
      ansible-playbook ansible_prometheus.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      ansible_host=${yandex_compute_instance.vm["prometheus"].network_interface.0.ip_address} \
      exporter_host1=${yandex_compute_instance.vm["webserv1"].network_interface.0.ip_address} \
      exporter_host2=${yandex_compute_instance.vm["webserv2"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_90_seconds]
}

resource "null_resource" "run_ansible_grafana" {
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible &&
      ansible-playbook ansible_grafana.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      ansible_host=${yandex_compute_instance.vm["grafana"].network_interface.0.ip_address} \
      grafana_password=${var.grafana_passwd} \
      prometheus_ip=${yandex_compute_instance.vm["prometheus"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_90_seconds]
}

resource "null_resource" "run_ansible_elastic" {
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible &&
      ansible-playbook ansible_elastic.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      elastic_password=${var.elastic_passwd} \     
      ansible_host=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_90_seconds]
}

resource "null_resource" "run_ansible_kibana" {
  provisioner "local-exec" {
    command = <<EOT
      cd ./ansible && \
      ansible-playbook ansible_kibana.yml \
      --extra-vars "bastion_server=${yandex_compute_instance.vm["bastion_host"].network_interface.0.nat_ip_address} \
      ansible_host=${yandex_compute_instance.vm["kibana"].network_interface.0.ip_address} \
      elastic_password=${var.elastic_passwd} \      
      elastic_ip=${yandex_compute_instance.vm["elasticsearch"].network_interface.0.ip_address}"
    EOT
  }

  depends_on = [time_sleep.wait_90_seconds]
}