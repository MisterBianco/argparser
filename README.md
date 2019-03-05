# Argparser

A library for nim with pythonic argparsing syntax.

```nim
import argparser

var parser = newArgParser("Description of the application")

parser.addOptions("-v", "verbosity", false)
parser.addOptions("--file", "filename", "")

parser.parse()

echo parser["verbosity]
echo parser["filename"]
```

---

### ToDo:

- Still needs flag options (boolean)
- Multiple parsers?

## Built for:

- Linux, might work elsewhere but I wrote it for linux.


