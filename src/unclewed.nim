# Unclewed - a Clew DB-dump analysis tool
# Copyright (C) 2024  András Németh
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

from std/os import fileExists
import std/parseopt as po
import std/streams as streams
from std/strformat import fmt

# project imports
import version as version
when defined(DEBUG):
    import debug as debug

proc show_help =
    echo(version.long())
    echo(version.compiled())
    echo(version.copyright())
    echo()
    echo(fmt"    {version.ProgramName} [options]")
    echo()
    echo("Options for direct output:")
    echo("  --help     Show this help and exit")
    echo("  --version  Show version information and exit")
    quit(QuitSuccess)

type Options = object
    filepath: string = ""

const options_long_no_val = @[
    "help",
    "version",
]

proc main =

    var p = po.initOptParser(shortNoVal = {}, longNoVal = options_long_no_val)

    when defined(DEBUG):
        var p_debug = p
        debug.output_options(p_debug)

    var options = Options()

    while true:
        p.next()
        case p.kind
            of po.cmdEnd:
                break
            of po.cmdShortOption, po.cmdLongOption:
                if p.key in options_long_no_val and p.val != "":
                    quit(fmt"Command line option '{p.key}' doesn't take a value", QuitFailure)
                case p.key:
                    # Options for direct output:
                    of "help":
                        show_help()
                        return
                    of "version":
                        echo(version.long())
                        return
                    else:
                        quit(fmt"Unrecognized command line option '{p.key}'", QuitFailure)
            of po.cmdArgument:
                if options.filepath != "":
                    quit(fmt"Multiple filenames given: '{p.key}'", QuitFailure)
                options.filepath = p.key

    if options.filepath == "":
        quit("No filename given.", QuitFailure)

    if not (fileExists(options.filepath)):
        quit(fmt"File with the given path does not exist: '{options.filepath}'", QuitFailure)

    var strm = streams.newFileStream(options.filepath, fmRead)
    defer: strm.close()

    if isNil(strm):
        return

    var line_count: int = 0

    var line = ""
    while strm.readLine(line):
        line_count += 1
        if line_count mod 1000000 == 0:
            stdout.write("X")
            flushFile(stdout)
    echo()

    echo(fmt"Line count: '{line_count}'")

when isMainModule:
    main()
