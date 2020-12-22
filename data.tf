data "digitalocean_ssh_key" "terraform" {
  name = var.do_ssh_key
}