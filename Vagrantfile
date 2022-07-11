# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |cfg|

    fqdn = "example.loc"
    root_netbios = "EXAMPLE"

    ad_fqdn = "za.example.loc"
    ad_netbios = "ZA"

    rootdc_name = "ROOTDC"
    rootdc_ip = "10.10.10.100"

    dc_name = "CHILDDC"
    dc_ip = "10.10.10.101"

    server_name = "SVR1"
    server_ip = "10.10.10.150"

    wks_name = "WRK1"
    wks_ip = "10.10.10.200"

    #This is a domain controller with standard configuration. It creates a single forest and populates the domain with AD objects like users and groups. It can also create specific GPOs and serve as DNS server.
    cfg.vm.define "rootdomaincontroller" do |config|
      config.vm.box = "rgl/windows-server-2019-standard-amd64"
      config.vm.hostname = rootdc_name

      # Use the plaintext WinRM transport and force it to use basic authentication.
      # NB this is needed because the default negotiate transport stops working
      # after the domain controller is installed.
      # see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
      config.winrm.transport = :plaintext
      config.winrm.basic_auth_only = true
      config.winrm.retry_limit = 30
      config.winrm.retry_delay = 10
      
      config.vm.provider :virtualbox do |v, override|
        v.gui = true
        v.cpus = 2
        v.memory = 2048
        v.customize ["modifyvm", :id, "--vram", 64]
      end
      
      config.vm.network :private_network,
        :ip => rootdc_ip

      # Configure keyboard/language/timezone etc.
      config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/windows/provision-base.ps1 en-ZA"
      config.vm.provision "shell", reboot: true

      # Configure DNS
      config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/networking/network-setup.ps1 network-setup-rootdc.ps1 root_dns_entries.csv"
      config.vm.provision "shell", reboot: true

      # Create forest root
      config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/ad/install-forest.ps1 forest-variables.json"
      config.vm.provision "shell", reboot: true

      #Reboot so that scheduled task runs
      config.vm.provision "shell", reboot: true

    end


    #This is a domain controller with standard configuration. It creates a single forest and populates the domain with AD objects like users and groups. It can also create specific GPOs and serve as DNS server.
    cfg.vm.define "domaincontroller" do |config|
        config.vm.box = "rgl/windows-server-2019-standard-amd64"
        config.vm.hostname = dc_name 

        # Use the plaintext WinRM transport and force it to use basic authentication.
        # NB this is needed because the default negotiate transport stops working
        #    after the domain controller is installed.
        #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
        config.winrm.transport = :plaintext 
        config.winrm.basic_auth_only = true
        config.winrm.retry_limit = 30
        config.winrm.retry_delay = 10

        config.vm.provider :virtualbox do |v, override|
            v.gui = true
            v.cpus = 2
            v.memory = 2048
            v.customize ["modifyvm", :id, "--vram", 64]
        end

        config.vm.network :private_network,
            :ip => dc_ip

        config.vm.provision "windows-sysprep"
        config.vm.provision "shell", reboot: true
            
        # Configure keyboard/language/timezone etc.
        config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/windows/provision-base.ps1 en-ZA"
        config.vm.provision "shell", reboot: true

        # Create child domain
        config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/ad/install-domain.ps1 domain-variables.json forest-variables.json"
        config.vm.provision "shell", reboot: true

        # Configure DNS
        config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/networking/network-setup.ps1 network-setup-dc.ps1 dns_entries.csv"
        config.vm.provision "shell", reboot: true

        # Add OUs, users, groups, etc. See the script to generate new users
        config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/ad/create-ad-objects.ps1 domain-variables.json planned-users.json"
        
    end

    #This is a simple server that is domain joined. It can be used to host various web applications
    cfg.vm.define "server1" do |config|

      config.vm.box = "rgl/windows-server-2019-standard-amd64"
      config.vm.hostname = server_name

      # use the plaintext WinRM transport and force it to use basic authentication.
      # NB this is needed because the default negotiate transport stops working
      #    after the domain controller is installed.
      #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
      config.winrm.transport = :plaintext
      config.winrm.basic_auth_only = true
      config.winrm.retry_limit = 30
      config.winrm.retry_delay = 10

      config.vm.provider :virtualbox do |v, override|
        v.linked_clone = true
        v.cpus = 2
        v.memory = 2048
        v.customize ["modifyvm", :id, "--vram", 64]
        # v.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
      end

      config.vm.network :private_network,
        :ip => server_ip

      #Run sysprep before joining the domain (needed because the SIDs are identical on Vagrant Cloud images)
      config.vm.provision "windows-sysprep"

      #Install Chocolatey - This can be used to install any other tools we may need
      config.vm.provision "install-choco", type: "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/windows/install-choco.ps1"
      config.vm.provision "shell", reboot: true

      #Configure keyboard/language/timezone etc.
      config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/windows/provision-base.ps1 en-ZA"
      config.vm.provision "shell", reboot: true

      #Join the domain specified in provided variables file - Only do this after everything else has been installed
      config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/ad/join-domain.ps1 domain-variables.json OU=Servers"
      config.vm.provision "shell", reboot: true

      # Configure DNS
      config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/networking/network-setup.ps1"
      config.vm.provision "shell", reboot: true      

      #Reboot so that scheduled task runs
      config.vm.provision "shell", reboot: true
    end
    
    cfg.vm.define "workstation1" do |config|
      config.vm.box = "rgl/windows-server-2019-standard-amd64"
      config.vm.hostname = wks_name

      # use the plaintext WinRM transport and force it to use basic authentication.
      # NB this is needed because the default negotiate transport stops working
      # after the domain controller is installed.
      # see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
      config.winrm.transport = :plaintext
      config.winrm.basic_auth_only = true
      config.winrm.retry_limit = 30
      config.winrm.retry_delay = 10

      config.vm.provider :virtualbox do |v, override|
        v.gui = true
        v.cpus = 2
        v.memory = 4096
        v.customize ["modifyvm", :id, "--vram", 64]
      end

      config.vm.network :private_network,
        :ip => wks_ip

      # Run sysprep before joining the domain (needed because the SIDs are identical on Vagrant Cloud images)
      config.vm.provision "windows-sysprep"

      #Install Chocolatey - This can be used to install any other tools we may need
      config.vm.provision "install-choco", type: "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/windows/install-choco.ps1"
      config.vm.provision "shell", reboot: true

      #Installed additional tools including chocolatey
      config.vm.provision "shell", path: "sharedscripts/windows/install-chrome.ps1"

      # Configure keyboard/language/timezone etc.
      config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/windows/provision-base.ps1 en-ZA"
      config.vm.provision "shell", reboot: true

      # Join the domain specified in provided variables file
      config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/ad/join-domain.ps1 domain-variables.json OU=Workstations"
      config.vm.provision "shell", reboot: true

      # Configure DNS
      config.vm.provision "shell", path: "sharedscripts/ps.ps1", args: "sharedscripts/networking/network-setup.ps1"
      config.vm.provision "shell", reboot: true 

      #Reboot so that scheduled task runs
      config.vm.provision "shell", reboot: true
    end
end
