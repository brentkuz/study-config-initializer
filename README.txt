Study Config Initializer


SETUP
----------------------------------------------------------------------------------------------------
1. Place the Study Config Initializer project folder 
in your development directory (ex. C:\dev).

2. Open PowerShell CLI and run the following command: Set-ExecutionPolicy -ExecutionPolicy Bypass
*NOTE: Windows 10 comes default with the PowerShell ExecutionPolicy set 
to Restricted. In order to run scripts, as this project does, the ExecutionPolicy must be updated. 

3. Double click setup.reg to add the Windows Explorer context menu item.
*NOTE: When editing the Windows Registry, it is always a good idea
to make a backup before editing.


USE
----------------------------------------------------------------------------------------------------
Right-click on a study sub-directory in your dev directory. If setup was done correctly,
you will see a context-menu item called "Initialize Study Config". When you click this menu item,
the PowerShell CLI will open and you will be prompted for various inputs that will be used to 
update the App.config file.

*NOTE: If at any point a wrong value is entered into a prompt, you may close the PowerShell CLI 
window and startover. 


