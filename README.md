<p align="center">
    <img src="https://github.com/MWR-CyberSec/tabletop-lab-creation/blob/main/tabletop_network_layout.png" width="500px">
</p>

> **Tabletop Lab Creation** is a toolset for building a network of Active Directory hosts using Vagrant. These hosts can then be integrated into your SIEM and EDR solution and used to simulate attacks for tabletop exercises. The hosts themselves can also be used for PoC testing of tools.

### Table of contents 

- [Installation](#installation)
    - [Prerequisites](#prerequisites)
- [Usage: How to provision the network](#usage-how-to-provision-the-network)
    - [Base Configuration](#base-configuration)
    - [Network Configuration](#network-configuration)
    - [AD Forest Configuration](#ad-forest-configuration)
    - [Windows Configuration](#windows-configuration)
- [Usage: AWS Provisioning](#usage-aws-provisioning)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)



## Installation

Download the latest release of the scripts for use. Vagrant is used as provisioner and should be installed from [here](https://www.vagrantup.com/downloads)


### Prerequisites

The scripts allow for provisioning through either VirtualBox locally or AWS for cloud-based deployment. If you want to perform a local deployment, make sure to install VirtualBox. You will also require the following Vagrant plugins:

* [Vagrant-WinRM](https://github.com/criteo/vagrant-winrm)
* [Vagrant-AWS](https://github.com/mitchellh/vagrant-aws)

## Usage: How to provision the network

You can provision the entire network using `vagrant up`. This will create the following four machines:

* ROOTDC - Root domain controller with the domain of *example.loc*
* CHILDDC - Child domain controller with the domain of *za.example.loc*
* SRV1 - A domain-joined Windows 2019 server machine
* WRK1 - A domain-joined Windows workstation

Make sure to disable the NAT adapater on the ROOTDC once it is provisioned to allow for the provisioning of the other hosts. The provisioning scripts can be found in the *sharedscripts* directory. All variables can be found in the *provision* directory.

### Base Configuration

The `provision-base.ps1` provisioning script is used for performing the basic provisioning steps such as:

* Setting the language, timezone, and keyboard layout
* Loading a Microsoft evaluation license
* Disabling the rotation of the machine account's password for the AD configuration

### Network Configuration

The `network-setup.ps1` provisioning script is responsible for performing the network setup. On domain controllers, it will create a scheduled task that will recreate the DNS entries specified in the variable CSV files. On normal machines, it will point the DNS of the ethernet adapter to the DC for DNS resolution.

### AD Forest Configuration

The `install-forest.ps1` and `install-domain.ps1` provisioning scripts will create the AD forest. The variables for the forest can be found in the `forest-variables.json` and `domain-variables.json` files respectively.

The `create-ad-objects.ps1` provisioning script will create AD objects such as OUs, groups, and users in the domain. Since the domain structure is tiered, it will create Tier 0, Tier 1, and Tier 2 groups. Additional AD objects can be specified in the `planned-users.json` file for creation.

The `join-domain.ps1` provisioning script is used to join new hosts to the domain. These hosts will be joined and added to the OU specified in the VagrantFile.

### Windows Configuration

[Chocolatey](https://chocolatey.org/) is used as provisioner on the Windows hosts. It is automatically installed on workstations and servers through the `install-choco.ps1` provisioning script. Afterwards, it is used to install Chrome on the workstation. It can be used to install other tools as well.

## Usage: AWS Provisioning

The `VagrantFile_aws_example` provides an example of using AWS for the provisioning of the hosts. You will have to add the following details for provisioning:

* AWS Access Key ID
* AWS Secret Access Key
* AWS Session Token
* AWS Keypair Name
* AWS Security Group 

Once the details are provided, `vagrant up` can be used to provision the ROOTDC on AWS. Using this as an example, the other three hosts can also be provisioned in AWS.

## Troubleshooting

*For assistance on any issues in scripts, please log an issue.*

## Contributing

See [`CONTRIBUTING.MD`](CONTRIBUTING.MD) for more information.

## License 

MIT License

Copyright (c) 2022 MWR CyberSec

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
