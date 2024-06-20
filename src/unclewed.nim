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

from std/os import fileExists, dirExists
import std/parseopt as po
from std/paths import Path, `/`
import std/streams as streams
from std/strformat import fmt
from std/strscans import scanf
from std/strutils import strip

# project imports
import version as version
from common import dual_output
from sections import Section, print_header, print_stats
when defined(DEBUG):
    import debug as debug

proc show_help =
    echo(version.long())
    echo(version.compiled())
    echo(version.copyright())
    echo()
    echo(fmt"    {version.ProgramName} [options]")
    echo()
    echo("Options:")
    echo("  --outdir   Set output directory")
    echo()
    echo("Options for direct output:")
    echo("  --help     Show this help and exit")
    echo("  --version  Show version information and exit")
    quit(QuitSuccess)

type Options = object
    filepath: string = ""
    output_dir: string = ""

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
                    of "outdir":
                        if not dirExists(p.val):
                            quit(fmt"Given output dir does not exist: '{p.val}'", QuitFailure)
                        options.output_dir = p.val
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

    var filepath_stats_db: string = "stats-db.txt"
    if options.output_dir != "":
        filepath_stats_db = (options.output_dir.Path / filepath_stats_db.Path).string

    var fh_input = streams.newFileStream(options.filepath, fmRead)
    defer: fh_input.close()
    if isNil(fh_input):
        quit(fmt"Unable to open input file: '{options.filepath}'", QuitFailure)

    var fh_stats_db = streams.newFileStream(filepath_stats_db, fmWrite)
    defer: fh_stats_db.close()
    if isNil(fh_stats_db):
        quit(fmt"Unable to open output file: '{filepath_stats_db}'", QuitFailure)
    const Header1 = " Data processing by: "
    dual_output(fmt"{Header1:=^80}", fh_stats_db)
    dual_output(version.long(), fh_stats_db)
    dual_output(version.compiled(), fh_stats_db)
    const Header2 = " Processed file "
    dual_output(fmt"{Header2:=^80}", fh_stats_db)
    dual_output(options.filepath, fh_stats_db)
    const Header3 = " Sections "
    dual_output(fmt"{Header3:=^80}", fh_stats_db)

    var
        line_count: uint32 = 0
        section_count: uint16 = 0

    var section: Section
    new(section)

    var line = ""
    var in_section_title = false
    while fh_input.readLine(line):
        line_count += 1
        if line == "--":
            in_section_title = not in_section_title
        else:
            if in_section_title:
                section.last_line = line_count - 2
                section.print_stats(fh_stats_db)
                section.first_line = line_count - 1
                section_count += 1
                if scanf(line, "-- $*Name: $+; Type: $+; Schema: $+; Owner: $+",
                         section.name_prefix, section.name, section.`type`, section.schema, section.owner):
                    section.print_header(fh_stats_db)
                else:
                    dual_output(line.strip(trailing=false, chars={'-', ' '}), fh_stats_db)

    section.print_stats(fh_stats_db)
    dual_output("", fh_stats_db)
    dual_output(fmt"Line count: {line_count}", fh_stats_db)
    dual_output(fmt"Section count: {section_count}", fh_stats_db)

when isMainModule:
    main()
