env_name = "LinuxApp"
vpc_cidr = "10.1.0.0/16"
az       = 2
service_ports = [
  { from_port = "22", to_port = "22" },
  { from_port = "80", to_port = "80" },
  { from_port = "8080", to_port = "8080" }
]
