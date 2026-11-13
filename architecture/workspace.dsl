workspace "Home Lab Architecture" "Canonical C4 model for the deployed home lab." {
    model {
        administrator = person "Home Lab Administrator" "Administers the deployed home lab."

        homeLab = softwareSystem "Home Lab" "The deployed home-lab platform." {
            proxmox = container "Proxmox VE" "Hosts the deployed virtual workloads." "Proxmox VE 9.2.0"
            opnsense = container "OPNsense" "Firewall, router, and network security boundary." "OPNsense"
            bastion = container "Management Bastion" "Management jump box." "Linux"
            k3s = container "k3s Cluster" "Kubernetes platform." "k3s"
        }

        mgmt = element "MGMT" "10.0.10.0/24" {
            tags "Network Segment"
        }

        servers = element "SERVERS" "10.0.30.0/24" {
            tags "Network Segment"
        }

        administrator -> homeLab "Administers"
        administrator -> bastion "Uses"
        bastion -> opnsense "Accesses web interface"
        opnsense -> mgmt "Gateway for MGMT"
        opnsense -> servers "Gateway for SERVERS"
        bastion -> mgmt "Attached to MGMT"
        k3s -> servers "Attached to SERVERS"
        proxmox -> opnsense "Provides virtualization for"
        proxmox -> bastion "Provides virtualization for"
        proxmox -> k3s "Provides virtualization for"

        deploymentEnvironment "Home Lab" {
            pve = deploymentNode "pve" "Physical Proxmox VE node." "Bare-metal PC" {
                opnsenseVm = deploymentNode "OPNsense VM" "VM 100." "Virtual machine" {
                    containerInstance opnsense
                }

                bastionLxc = deploymentNode "Management Bastion LXC" "LXC 101." "Linux container" {
                    containerInstance bastion
                }

                k3sVm = deploymentNode "k3s Cluster VM" "VM 102." "Virtual machine" {
                    containerInstance k3s
                }
            }
        }
    }

    views {
        systemContext homeLab "SystemContext" {
            include *
            autolayout lr
        }

        container homeLab "Platform" {
            include *
            autolayout lr
        }

        container homeLab "Network" {
            include opnsense
            include mgmt
            include servers
            include bastion
            include k3s
            autolayout lr
        }

        deployment homeLab "Home Lab" "Deployment" {
            include *
            autolayout lr
        }

        styles {
            element "Person" {
                background "#084C61"
                color "#FFFFFF"
                shape person
            }

            element "Software System" {
                background "#177E89"
                color "#FFFFFF"
            }

            element "Container" {
                background "#2E86AB"
                color "#FFFFFF"
            }

            element "Network Segment" {
                background "#F6AE2D"
                color "#1F2933"
                shape roundedbox
            }

            element "Deployment Node" {
                background "#6C757D"
                color "#FFFFFF"
            }
        }
    }
}