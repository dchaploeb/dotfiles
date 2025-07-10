# Setup on Windows Server 2016

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install git
scoop install ssh
scoop bucket add extras
scoop install oh-my-posh
```
