# Local Workstation Setup

This repo will contain any scripts/resources needed to quickly set up a new workstation with various dev tools.

## Things Installed

* Git directory
  * create directory to store all git repos
  * default: C:\git
* Powershell (latest)
* Chocolatey
* dotnet SDK (6.0)
* WSL
  * may need more configuration than this script
* Applications (via chocolatey)
  * 7zip
  * git
  * conemu - better terminal
  * keepass - password management
  * vlc - better video viewing
  * notepadplusplus - better notes
  * winscp  - sftp client
  * putty - ssh client
  * vscode - best code editor
  * irfanview - better image viewing
  * sumatrapdf - pdf viewer
  * greenshot - better screenshots
* Install Docker
  * this is not scripted out, please do so manually
  * https://docs.docker.com/get-docker/
* Install AWS CLI
* Install Gcloud CLI
* Install PS Modules
  * posh-git - see git details in PS
  * psake - task automation
* Update PS profile
  * automatic $githome variable
  * set location to $githome
