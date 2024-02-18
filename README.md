# Windows VM on KVM 

Scripts to help you setup a windows VM on KVM for "remote" development. 
With your new VM you will be able to edit windows code from your linux desktop,
without ever having to look at the Windows UI.

### You might also be interested in
[win-crate](https://github.com/CanadianCommander/win-crate). Similar to this repo but runs the environment inside a docker container. This is a cleaner solution but uses a lot more CPU due to VM inside a container.

# Requirements
- [KVM](https://help.ubuntu.com/community/KVM/Installation)
- [libvirt](https://libvirt.org/)
- [virt-manager](https://virt-manager.org/)
- [virt-install](https://manpages.org/virt-install)
- [genisoimage](https://wiki.debian.org/genisoimage)

# Usage

### Getting a windows ISO 
Unfortunately you will need to provide your own windows ISO, because Microsoft is a meany!
You can download a windows ISO [here ](https://www.microsoft.com/en-us/software-download/windows11).

place the ISO in the `vm/iso/` directory with the name `win.iso` (as shown by the placeholder file)

### Install
Now you are ready to install your windows VM. You can use the install command to setup the VM. 
The install command is very simple. It only takes a list of directories to mount into windows. All the directories will appear as drives in Windows. 
```bash 
./install.sh /home/user/mymount/point/ /home/user/another/mount/point/ .... 
```

#### additional options 
You can run `install.sh --help` to see a list of additional environment variables 
that you can set to customize your VM installation. 

### Post Install Windows setup. 
After the install is complete you may want to setup the VM (optional).
Follow [this setup guide](./doc/windows-postinstall-setup.md).