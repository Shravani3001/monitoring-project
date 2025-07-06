variable "region" {
    default = "us-east-1"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "key_name" {
    default = "monitoring-key"
}

variable "public_key_path" {
    default = "./monitoring-key.pub"
}

variable "az1" {
    default = "us-east-1a"
}