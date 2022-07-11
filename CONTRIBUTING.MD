First of all, thanks for getting involved!

## Feature structure

Features are provided in the form of scripts in the `sharedscripts` section. To ensure that your feature can be integrated, please build a script that supports arguments and default parameters. Please choose the directory that fits your feature the best:

| Directory  | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| `ad`      | Scripts used for Active Directory integration and features                |
| `aws`     | Scripts used to enable provisioning on AWS             |
| `networking` | Scripts used for networking purposes |
| `windows`   | Scripts used to provision Windows-specific features and applications                   | 

## Adding a feature

1. Create a script of your feature and select the directory that fits your features best. 
2. Integrate the script in your VagrantFile and confirm that it can be provisioned.
3. Submit a Pull Request to the master branch.

## Documentation

We're well aware there is a lot we haven't documented. This is something we plan on rectifying by putting together a new wiki. For now, please feel free to use the Github issue tracker for any questions. 

