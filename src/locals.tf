locals {
  network_name     = "dnd-vpc"
  subnet_name1     = "public"
  subnet_name2     = "private"
  sg_nat_name      = "nat-instance-sg"
  vm_test_name     = "test-vm"
  vm_nat_name      = "nat-instance"
  route_table_name = "nat-instance-route"
}