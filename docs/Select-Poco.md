---
external help file: poco-help.xml
Module Name: poco
online version:
schema: 2.0.0
---

# Select-Poco

## SYNOPSIS
Interactively filter objects from the pipeline.

## SYNTAX

```
Select-Poco [[-Property] <Object[]>] [[-Query] <String>] [[-Filter] <String>] [-CaseSensitive] [-InvertFilter]
 [[-Prompt] <String>] [[-Layout] <String>] [[-Keymaps] <Hashtable>]
```

## DESCRIPTION
This command will interactively filter objects from the 

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CaseSensitive
Force comparison to be case sensitive.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Comparison mode.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: match, like, eq

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InvertFilter
Invert the boolean logic of every comparison.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Keymaps
{{Fill Keymaps Description}}

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Layout
Layout poco from top or bottom.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: TopDown, BottomUp

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prompt
Prompt string to display next to query.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Property
{{Fill Property Description}}

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
Specify starting query.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### System.Object


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
