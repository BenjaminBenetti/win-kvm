# Windows VM on KVM 

Scripts to help you setup a windows VM on KVM for "remote" development. 
With your new VM you will be able to edit windows code from your linux desktop,
without ever having to look at the Windows UI.

### You might also be interested in
[win-crate](https://github.com/CanadianCommander/win-crate). Similar to this repo but runs the environment inside a docker container. This is a cleaner solution but uses a lot more CPU due to VM inside a container.

# Requirements
- [KVM](https://help.ubuntu.com/community/KVM/Installation)
- [genisoimage](https://wiki.debian.org/genisoimage)

# Usage

### Getting a windows ISO 
Unfortunately you will need to provide your own windows ISO, because Microsoft is a meany!
You can download a windows ISO [here ](https://www.microsoft.com/en-us/software-download/windows11).

place the ISO in the `vm/iso/` directory with the name `win.iso` (as shown by the placeholder file)

### Run
Now you are ready to start your windows VM. You can use the run command to start the VM. 
The run command is very simple. It only takes a list of directories to mount into windows. All the directories 
you specify will be available in windows under the same drive. Usually the `Z:` drive.
```bash 
./run.sh /home/user/mymount/point/ /home/user/another/mount/point/ .... 
```