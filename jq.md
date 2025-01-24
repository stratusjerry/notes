Notes on using `jq` commands

## `jq` Basics

### Builtin operators and functions:

Addition `+`; Subtraction `-`; Multiplication `*`; Division `/`; Modulo: `%`; `length`; `keys`; `has(key)`; `in`; `map()` and `map_values()` is like a for each loop; `unique`; `contains(element)`; `startswith(str)`; `endswith(str)`; `ltrimstr(str)` trim string from left (if it exists); `rtrimstr(str)`; `split(str)` splits can also split on regex when called with 2 args 

### Conditionals and Comparisons
`==`, `!=`; `if A then B else C end`; `>`, `>=`, `<=`, `<`; `and`, `or`, `not`; `try EXP catch EXP`

### Regular expressions 
`test(val)`, `test(regex; flags) ` like `match` but does not return match objects, only true/false; `match(val)`, `match(regex; flags)`;
`capture(val)`, `capture(regex; flags)` Collects the named captures in a JSON object, with the name of each capture as the key, and the matched string as the corresponding value

## Creating and querying
Create a JSON array file by running the command
```bash
curl "https://www.syn.com/api/jobs" -o "jobs.json"
```

FYI: for debugging query purposes the rough json structure of the above file looks like this (values are either `"quoted"` or `null`)
```json
[
    {
        "key1": "value1",
        "key2": null
    },
    {
        "key1": "value1",
        "key2": "value2"
    }
]
```

## Querying
```bash
# Use jq to prettify json
cat jobs.json | jq '.'
# Use jq to sort keys alphabetically with "--sort-keys" OR "-S"
cat jobs.json | jq '.' -S
# Output the title field for all elements
jq '.[] | .title' jobs.json
# Output the title field for all elements, sorted alphabetically, removing duplicates
jq '.[] | .title' jobs.json | sort | uniq
# More concise version of above filter
jq '.[].title' jobs.json
# Access by index
jq '.[1]' jobs.json
# Access an indexes property
jq '.[1].title' jobs.json
# Access a range of indexes, last number is exclusive (dropped)
jq '.[0:3]' jobs.json
# Access a range of indexes, only output the last index values in the range
cat jobs.json | jq '.[0:3]' | jq '.[-1:]'
# Get the keys of every element (and sorts them)
jq '.[] | keys' jobs.json
# Get the character length of a value
jq '.[2].title | length' jobs.json
# Return True if each array element has a property named "technologies"
jq 'map(has("technologies"))' jobs.json
# List all elements that DO NOT start with the title "Systems"
jq 'map(select(.title | startswith("Systems") | not))' jobs.json
# List all elements that DO NOT start with the title "Software"
jq 'map(select(.title | startswith("Software") | not))' jobs.json
# Add the string ",United States" to every element location property. Outputs only the modified location property
jq 'map(.location+",United States")' jobs.json
## Below Test assume every element had a property "salary" with an integer value
#   Increment salary by 100. Outputs only the modified salary property
jq 'map(.salary+100)' jobs.json
#   Select any entity with salary over 100
jq '.[] | select(.salary>100)' jobs.json
#   Select any entity with title "Software Engineer" and salary over 2024
jq '.[] | select(.title=="Software Engineer" and .salary>=2024)' jobs.json
#   Find the entity with the largest salary integer
jq 'max_by(.salary)' jobs.json
#   Find the entity with the smallest salary integer. Will output an entity that does not contain key "salary" as lowest
jq 'min_by(.salary)' job.json
#   Find entities a salary property. Then output the entity with the smallest "salary"
jq 'map(select(.salary != null)) | min_by(.salary)' jobs.json
# If the element property "title" matches regex "^Soft." (begins with Soft), output the clearance property
jq '.[] | select(.title|test("^Soft.")) | .clearance' jobs.json
# Loop through every element, getting the "title property" and Output the unique results
jq 'map(.title) | unique' jobs.json
# Delete the "Intro" property of every element
jq 'del(.[].intro)' jobs.json
# Delete the "Intro" AND "key" property of every element
jq 'del(.[].intro, .[].key)' jobs.json
# Create a new array containing keys "loc" and "name" with the value of every entities "location" and "title"
jq '[map(.) | .[] | {loc: .location, name: .title}]' jobs.json
```

## Editing file
Unfortunately `jq` does NOT support in-line editing of files (like `sed`) so we have to get creative by using bash to create a temp file then overwrite the original file. See [Cloudtrail.md](./Cloudtrail.md) for an example of using `parallel` to process multiple files
```bash
# Recursively find json files, pretty print format to a temp file, overwrite original file with temp file
find /cygdrive/d/Users/tonybaloney/Desktop/rke2-images/ -name "*json" -exec sh -c 'jq . "{}" > "{}.tmp" && mv "{}.tmp" "{}"' \;
```
