variable "instance_type" {
 description = "Type of EC2 instance to provision"
 default     = "t3.nano"
}

variable "availability_zone" {
    description = "Name of the zone"
    default =  "eu-north-1b"

}
