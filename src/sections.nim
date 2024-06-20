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

from std/streams import FileStream
from std/strformat import fmt

# project imports
from common import dual_output

type
    SectionObj = object
        name_prefix*: string
        name*: string
        `type`*: string
        schema*: string
        owner*: string

        first_line*: uint32
        last_line*: uint32

    Section* = ref SectionObj

proc print_header*(section: Section, stream: FileStream) =
    dual_output(fmt"{section.name_prefix}Name: {section.name}", stream)
    dual_output(fmt"    Type:   {section.type}", stream)
    dual_output(fmt"    Schema: {section.schema}", stream)
    dual_output(fmt"    Owner:  {section.owner}", stream)

proc print_stats*(section: Section, stream: FileStream) =
    dual_output(fmt"    {section.first_line} - {section.last_line} ({section.last_line - section.first_line})", stream)
