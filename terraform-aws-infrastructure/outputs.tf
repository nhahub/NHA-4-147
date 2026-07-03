output "instance_ids" {
  value = {
    k8s_master   = module.k8s_master.instance_id
    k8s_worker01 = module.k8s_worker01.instance_id
    k8s_worker02 = module.k8s_worker02.instance_id
    sonarqube    = module.sonarqube.instance_id
  }
}

output "public_ips" {
  value = {
    k8s_master   = module.k8s_master.public_ip
    k8s_worker01 = module.k8s_worker01.public_ip
    k8s_worker02 = module.k8s_worker02.public_ip
    sonarqube    = module.sonarqube.public_ip
  }
}