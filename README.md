# poco
Interactive pipeline filtering in PowerShell (a port of [peco](https://github.com/peco/peco)).

A fork of [poco by yumura](https://gist.github.com/yumura/8df37c22ae1b7942dec7).

**Major Features:**

- Interactively filter objects in the pipeline (interactive version of `Where-Object`)

## Usage

### Syntax

```powershell
Select-Poco [[-Property] <Object[]>] [[-Query] <string>] [[-Filter] {match | like | eq}] [[-Prompt] <string>]
    [[-Layout] {TopDown | BottomUp}] [[-Keymaps] <hashtable>] [-CaseSensitive] [-InvertFilter]
 ```

## Install

Inspect

```powershell
Save-Module -Name poco -Path <path>
```

Install

```powershell
Install-Module -Name poco
```
