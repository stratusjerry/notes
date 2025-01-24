## Vscode versus Notepad++
Vscode regex replacement capture groups are format like **$1**, **$2** ; Notepad++ format is **\1**, **\2**

## Vscode regex negations

### Negative lookbehind
- Find `ping` but NOT if it contains a preceding alpha character: `(?<!([a-z]))ping`
- Find `ping` but NOT if it contains a preceding `ty`: `(?<!(ty))ping`
- Alternative to above not using group1: `(?<!ty)ping`

### Lookbehind (doesn't seem to work well)
Find `ping` and if preceded by `ty`, only match `ping`: `(?!ty)ping`

### Negative lookahead
- Find `ping` but NOT if it contains an ending whitespace: `ping(?! )`

## Find duplicate bash history lines
Could work more on making whitespace one or more using "+" but this is good for now:
```
Find: ^(  [0-9]+  )(.*)\n.*^  [0-9]+  \2\n
Find: ^(   [0-9]+  )(.*)\n.*^   [0-9]+  \2\n
Replace: $1$2\n
```

## Cloudtrail filters
```bash
# Cloudtamer based
^ct-.*\n
# Service based
.*,(config|ssm|sts)\.amazonaws.*\n
# Read Only Operation
.*,(Describe|Get|List).*\n
.*,(ConsoleLogin|LookupEvents).*\n
# Service Accounts
^(AWSBackup|CORE-(autoSt|tag)).*\n # ^AutoScaling
# Failed Events
.*InsufficientInstanceCapacity.*\n
# Specific Resources
.*"resourceType"":""AWS::EC2::SecurityGroup".*\n
# Not Specific users
^(alice|bob|jim).*\n
```
__Cloudtamer based__ : `^ct-.*\n`  
__Service based__ : `.*,(config|ssm|sts)\.amazonaws.*\n`  
__Read Only Operation__ : `.*,(Describe|Get|List).*\n`

## Chrome Dev Tools Filter images
Remove png like: `-mime-type:image/png`  
Apply multiple filters with blank space like remove png and webp: `-mime-type:image/png -mime-type:image/webp`
This filter catches excludes more, but not all, images: `-image`  
This caught a couple extra `-image -mime-type:image/jpeg`  
What we really want is a regex like image*

## Putty log
Remove ANSI characters, regex string:
- `\[0;([0-9])+m`

## Gitlab Raw log
Remove ANSI characters, regex string:
- `\[([0-9])+(m|K|;m|;[0-9]m)`
Remove end of line whitespace
- `( )+$`
Combined remove ANSI characters and EOL whitespace?
- `(\[([0-9])+(m|K|;m|;[0-9]m)|( )+$)`

## Notepad++ `stylers.xml`
Swap any attributes that have Foreground Black Color with the set Background Color:
- Replace: `(fgColor=")(000000)(" bgColor=")(......)(")`
- With (Notepad++ syntax): `\1\4\3\2\5`
- With (Vscode syntax): `$1$4$3$2$5`

## MongoDB Log
Remove preceding time info and retaining JSON log format
- Find: `^.* \{"t":.*( "c":.* )"id":.*("ctx":)`
- Replace: `{$2`

Find lines that only contain date information
- Find: `^202(\S)+$`
- Replace ``

Remove Duplicate empty lines
- Find: `\n(\n)+`
- Replace `\n`

WIP: Better remove preceding time info and retaining JSON log format
- Find: `^.* \{"t":.* "c":(".*",)( )+"id":.*"ctx":(.*,)"msg":`
- Replace: `{$1$3`

## Random Excludes
search rh8 folder, ignore ansible and terragrunt cache
- include: foo/bar/baz/us-east-1/rh8
- exclude: ansible/,.terragrunt-cache


```bash
# Find .yaml files with blank line at beginning of file
find . -type f -name "*.yaml" -exec awk 'NR==1 && /^$/{print FILENAME; exit}' {} \;
```

# Strip Java Logs
Strip Date
- Find: `^( )?2024-[0-9]+-[0-9]+T[0-9]+:[0-9]+:[0-9]+\.[0-9]+(Z|\+[0-9]+)( )?`
- Replace ``

Strip whitespace
- Find: `(\[)( )+(main\])`
- Replace `$1$3`

Strip running time, to easier diff logs
- Find: `(in )[0-9]+ (ms)`
- Replace `$1$2`
