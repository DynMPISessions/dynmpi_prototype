# Arm DDT pretty printer.
#
# Copyright (C) 2012, 2021 Arm Limited (or its affiliates). All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# -*- coding: iso-8859-1 -*-

import gdb
import itertools
import re

from libstdcxx.v6.printers import StdSetPrinter, StdMapPrinter

class RangePrinter:
    "Print a range"

    def __init__(self, val):
        self.val = val

    def to_string(self):
        return RangePrinter.to_str(self.val)

    @staticmethod
    def to_str(r):
        return '"%s-%s"' % (r['start'], r['end'])

class ProcessSetPrinter:
    "Print a ProcessSet"

    def __init__(self, val):
        self.typename = val.type

        # Use StdSetPrinter
        range_val = val['d']['d'].dereference()['mRanges']
        self.pp = StdSetPrinter(range_val.type, range_val)

    def children(self):
        return self.pp.children()

    def to_string(self):
        procs = 0
        ranges = 0
        friendly_str = ""
        truncated = False
        for i in self.pp.children():
            val = i[1]
            ranges += 1
            procs += val['end'] - val['start']
            if len(friendly_str) < 50:
                friendly_str += str(val) + ','
            else:
                truncated = True

        if truncated:
            friendly_str += '...'
        else:
            friendly_str = friendly_str[:-1] # Truncate last comma

        #FIXME friendly_str not currently used, as the commas breaks DDT parsing
        return "%s %d procs %d ranges" % (self.typename, procs, ranges)

    def display_hint(self):
        return 'array'

class ProcessMapPrinter:
    "Print a ProcessMap"

    def __init__(self, val):
        self.typename = val.type
        range_map = val['d']['d'].dereference()['mRanges']
        self.pp = StdMapPrinter(range_map.type, range_map)

    def children(self):
        #TODO: Convert range keys to be inclusive?
        return self.pp.children()

    def to_string(self):
        return "ProcessMap"

    def display_hint(self):
        return 'map'

class CudaThreadIdxPrinter:
    "Print a CUDAThreadIdx"

    def __init__(self, val):
        self.values = {}

        for k in ('bx','by','bz','tx','ty','tz'):
            self.values[k] = val[k]

    def to_string(self):
		return '"<<<(%s,%s,%s),(%s,%s,%s)>>>"' % tuple(self.values()) # FIXME: Remove extra quotes when DDT won't choke on the commas

    def children(self):
        return self.values.items()    


def register_ddt_printers (obj):
    if obj == None:
        obj = gdb

    obj.pretty_printers.append (lookup_function)

def lookup_function (val):
    "Look-up and return a pretty-printer that can print val."

    # Get the type.
    type = val.type;

    # If it points to a reference, get the reference.
    if type.code == gdb.TYPE_CODE_REF:
        type = type.target ()

    # Get the unqualified type, stripped of typedefs.
    type = type.unqualified ().strip_typedefs ()

    # Get the type name.
    typename = type.tag
    if typename == None:
        return None

    # Iterate over local dictionary of types to determine
    # if a printer is registered for that type.  Return an
    # instantiation of the printer if found.
    for function in pretty_printers_dict:
        if function.search (typename):
            return pretty_printers_dict[function] (val)

    # Cannot find a pretty printer.  Return None.
    return None

def build_dictionary ():
    pretty_printers_dict[re.compile('^ProcessSet$')] = lambda val: ProcessSetPrinter(val)
    pretty_printers_dict[re.compile('^ProcessMap<.*>$')] = lambda val: ProcessMapPrinter(val)
    pretty_printers_dict[re.compile('^range$')] = lambda val: RangePrinter(val)
    pretty_printers_dict[re.compile('^CUDAThreadIdx$')] = lambda val: CudaThreadIdxPrinter(val)

pretty_printers_dict = {}

build_dictionary ()
