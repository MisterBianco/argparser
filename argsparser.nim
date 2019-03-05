import 
    os, tables, strutils

const
    CLEAR:string  = "\e[0m"
    BOLD:string   = "\e[1m"

    RED:string    = "\e[31m"
    CYAN:string   = "\e[36m"
    WHITE:string  = "\e[37m"

type
    NodeValueKind = enum
        nvString
        nvBool

    NodeValue = ref object
        case kind: NodeValueKind
        of nvString:
            stringValue: string
        of nvBool:
            boolValue: bool

    ArgParser = ref object of RootObj
        Values* : Table[string, NodeValue]
        Map : Table[string, string]
        Desc : string 
        Help : string

#[ Predefined procs ]#
proc newArgParser*(): ArgParser
proc newArgParser*(desc : string): ArgParser
proc `$`*(nd: NodeValue): string
proc `[]`*(parser : ArgParser, key : string): NodeValue
proc addOptions*(parser : ArgParser, id, dest : string, def : string)
proc addOptions*(parser : ArgParser, id, dest : string, def : bool)
proc parse*(parser: ArgParser)
proc help*(parser : ArgParser)
#[ End of predefined procs ]#

proc newArgParser*(): ArgParser =
    result.new()
    result.Values = initTable[string, NodeValue]()
    result.Map = initTable[string, string]()
    result.Desc = ""
    result.Help = BOLD & WHITE & "Usage: " & RED & getAppFilename().splitPath()[1] & WHITE & "[" & BOLD & "-h" & WHITE & "]"

proc newArgParser*(desc : string): ArgParser =
    result.new()
    result.Values = initTable[string, NodeValue]()
    result.Map = initTable[string, string]()
    result.Desc = desc
    result.Help = BOLD & WHITE & "Usage: " & RED & getAppFilename().splitPath()[1] & WHITE & " [" & BOLD & "-h" & WHITE & "]"

proc `$`*(nd: NodeValue): string =
    case nd.kind:
    of nvString:
        return nd[].stringValue
    of nvBool:
        return $nd[].boolValue

proc `[]`*(parser : ArgParser, key : string): NodeValue =
    if parser.Values.hasKey(key):
        result = parser.Values[key]

proc addOptions*(parser : ArgParser, id, dest : string, def : string) =
    parser.Map[id] = dest
    parser.Values[dest] = NodeValue(kind: nvString, stringValue: def)
    parser.Help &= " [" & id & " " & def & "]"

proc addOptions*(parser : ArgParser, id, dest : string, def : bool) =
    parser.Map[id] = dest
    parser.Values[dest] = NodeValue(kind: nvBool, boolValue: def)
    parser.Help &= " [" & id & " " & $def & "]"

proc parse*(parser : ArgParser) =
    for arg in commandLineParams():
        let arg = arg.string
        if arg == "-h" or arg == "--help":
            parser.help()

        if arg.contains("="):
            let strarg = arg.split("=")
            let (key, val) = (strarg[0], strarg[1])

            if parser.Map.hasKey(key):
                parser.Values[parser.Map[key]] = NodeValue(kind: nvString, stringValue: val)

        else:
            if parser.Map.hasKey(arg):
                parser.Values[parser.Map[arg]] = NodeValue(kind: nvBool, boolValue: false)

proc help(parser : ArgParser) = 
    echo parser.Help & "\n"
    if parser.Desc != "":
        echo parser.Desc & "\n"
        
    for k in parser.Map.pairs:
        echo CYAN & k[0] & WHITE & "\t\t" & k[1] & "\t\t" & $parser.Values[k[1]]
    quit 0

when isMainModule:
    var parser = newArgParser("App to do the thing")

    parser.addOptions("--test", "test", false)
    parser.addOptions("--tv", "woah", false)

    parser.parse()

    echo parser["test"]
    echo parser["woah"]
