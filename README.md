# SMB TOOL 

Smb tool is a quick script to create and delete samba shares on headless linux distributions. It's very useful for freshly installed debian distros on a VM or a Raspberry pi. 

## Using SMB-tool

Clone the repository. 

````
git clone https://github.com/lapixo-tech/smb-share-tool.git

````
Navigate to the repository directory `cd smb-share-tool`
Then, make sure that smb-tool.sh is executable and run the script using sudo or as root. 

```
chmod +x smb-tool.sh
sudo ./smb-tool.sh
```

Alternative you can copy the script to `/usr/local/bin` and run it from anyware in the os

```
sudo cp smb-tool.sh /usr/local/bin
```

Then te Menu will be presented, follow the inline instructions to create your shares and delete them if necesary. 


