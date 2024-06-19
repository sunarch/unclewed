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

from std/parseopt import OptParser, next, cmdEnd, cmdArgument
from std/strformat import fmt

proc output_options*(p_debug: var OptParser) =
    while true:
        p_debug.next()
        if p_debug.kind == cmdEnd:
            break
        stdout.write(fmt"[DEBUG:] Option: ({p_debug.kind})")
        if p_debug.kind == cmdArgument:
            stdout.write(fmt" '{p_debug.key}'")
        else:
            stdout.write(fmt" '{p_debug.key}' = '{p_debug.val}'")
        echo()
