# racenow
Terraform and Ansible to provision a race server to Digital Ocean.  Currently
sets up ACC and Teamspeak servers.  Potentially other servers can be added as 
roles rather simply.

# Terraform Input Variables
Some variables you may/should override from their defaults.
## API Key
`TF_VAR_do_token`

Terraform needs a Digital Ocean Personal Access Token for provisioning
resources.  This can be passed into terraform as the `do_token` variable.
If the variable is not set it will be interactively prompted.

## Floating IP
`TF_VAR_use_float_ip`

`TF_VAR_float_ip`

If you have a floating ip to use set `use_float_ip` to true and the floating 
ip in `float_ip`.  The default is not to setup a floating ip

## SSH Key
`TF_VAR_host_ssh_key`

The host key to set on the provisioned host(s). This defaults to a key named 
`terraform`, which is assumed to be already provisioned.

## SSH Firewall
`TF_VAR_ssh_allowed_network`

Network to restrict ssh connections to.  Defaults to empty
# Terraform Example
```
$ terraform plan -var do_token=${DO_PAT}

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # digitalocean_droplet.race-1 will be created
  + resource "digitalocean_droplet" "race-1" {
      + backups              = false
      + created_at           = (known after apply)
      + disk                 = (known after apply)
      + id                   = (known after apply)
      + image                = "ubuntu-18-04-x64"
      + ipv4_address         = (known after apply)
      + ipv4_address_private = (known after apply)
      + ipv6                 = false
      + ipv6_address         = (known after apply)
      + ipv6_address_private = (known after apply)
      + locked               = (known after apply)
      + memory               = (known after apply)
      + monitoring           = false
      + name                 = "race-1"
      + price_hourly         = (known after apply)
      + price_monthly        = (known after apply)
      + private_networking   = true
      + region               = "nyc3"
      + resize_disk          = true
      + size                 = "s-2vcpu-2gb"
      + ssh_keys             = [
          + "xxxxxxx",
        ]
      + status               = (known after apply)
      + urn                  = (known after apply)
      + vcpus                = (known after apply)
      + volume_ids           = (known after apply)
      + vpc_uuid             = (known after apply)
    }

  # digitalocean_firewall.raceserverports will be created
  + resource "digitalocean_firewall" "raceserverports" {
      + created_at      = (known after apply)
      + droplet_ids     = (known after apply)
      + id              = (known after apply)
      + name            = "raceserverports"
      + pending_changes = (known after apply)
      + status          = (known after apply)
--- SNIP ---
    }

  # digitalocean_floating_ip_assignment.raceip[0] will be created
  + resource "digitalocean_floating_ip_assignment" "raceip" {
      + droplet_id = (known after apply)
      + id         = (known after apply)
      + ip_address = "123.456.789.0"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------
```

# Ansible Variables
Not an exhaustive list but these are some of the ansible variables that may be
helpful to override from their defaults.

## ACC Web Passwords
`acc_admin_password`  
`acc_mod_password`  
`acc_ro_password`  
`teamspeak_dbpassword`  

## Ports
`acc_port_web`          [DEFAULT:8080]  
`acc_port_race`         [DEFAULT:9001]  
`teamspeak_port_voice`  [DEFAULT:9987]   
`teamspeak_port_file`   [DEFAULT:10011]  
`teamspeak_port_query`  [DEFAULT:30033]  

## Lets Encrypt Cert
`acc_use_letsencrypt`   [DEFAULT:false]
`acc_letsencrypt_fqdn`  [DEFAULT:race.example.com]

If set uses certbot to grab a ssl cert for the accweb page.  This requires that
port 80 is open and the fqdn resolves to the host for verification. 

# Ansible Example
Probaly want to use group_vars or something to manage the settings

```
$ ansible-playbook -i inventory  --private-key ~/.ssh/do_terraform race.yml \
-e acc_admin_password=SecurePassword -e acc_mod_pass=OkPass                 \
-e teamspeak_dbpassword=VeryGoodPassword                                    \
-e acc_letsencrypt_email=race@example.com                                   \
-e acc_letsencrypt_fqdn=race.example.net

PLAY [setup race servers] *****************************************************

TASK [Gathering Facts] *******************************************************************************
ok: [127.0.0.127]

TASK [teamspeak | setup | Install docker] *******************************************************************************
changed: [127.0.0.127]

TASK [teamspeak : pip] *******************************************************************************
changed: [127.0.0.127]

TASK [teamspeak | db | Run teamspeak database container] *******************************************************************************
changed: [127.0.0.127]

TASK [teamspeak | db | Wait for db to accept connections] *******************************************************************************
ok: [127.0.0.127]

TASK [teamspeak | app | Run teamspeak container] *******************************************************************************
changed: [127.0.0.127]

TASK [teamspeak | app | Wait for app to accept connections] *******************************************************************************
ok: [127.0.0.127]

TASK [teamspeak | app | wait for token to be ready] *******************************************************************************
Pausing for 15 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [127.0.0.127]

TASK [teamspeak | app | get admin token] *******************************************************************************
changed: [127.0.0.127]

TASK [teamspeak | app | output token] *******************************************************************************
ok: [127.0.0.127] => {
    "msg": "token=[redacted]"
}

TASK [acc_server : app_server | setup | Install packages] *******************************************************************************
ok: [127.0.0.127]

TASK [acc_server : app_server | setup | create directories] *******************************************************************************
changed: [127.0.0.127] => (item=/srv/acccerts/)
changed: [127.0.0.127] => (item=/srv/accserver/)

TASK [acc_server : app_server | setup | copy directories] *******************************************************************************
changed: [127.0.0.127]

TASK [acc_server : app_server | setup | Check if cert exists] *******************************************************************************
ok: [127.0.0.127]

TASK [acc_server : app_server | setup | get cert] *******************************************************************************
changed: [127.0.0.127]

TASK [acc_server : app_server | app | Run accserver container] *******************************************************************************
changed: [127.0.0.127]

TASK [acc_server : app_server | app | Wait for db to accept connections] *******************************************************************************
ok: [127.0.0.127]

PLAY RECAP ********************************************************************
127.0.0.127              : ok=17   changed=9    unreachable=0    failed=0    
skipped=0    rescued=0    ignored=0
```
