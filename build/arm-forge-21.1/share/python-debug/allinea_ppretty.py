'''
#########################################################################################
Copyright (c) 2019, SymonSoft
All rights reserved.

Modifications copyright (C) 2020-2021 Arm Limited (or its affiliates).
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##########################################################################################

This file is from the ppretty source at (https://github.com/symonsoft/ppretty/blob/master/ppretty/ppretty.py)

It provides the ability to print python objects in a human readable format.

This module has been modified in the following ways:

* Change the format of printing so all sequences/classes are displayed as if they were a map
* Removed indentation and newline formatting
* Hide magic methods when showing private attributes
* Added the functionality to pretty print any Python sequence and not the predefined set
* Modified cut_seq to show first n elements instead of first n/2 and last n/2

'''

from functools import partial
from inspect import isroutine
from numbers import Number
from itertools import islice

import sys


def ppretty(obj, depth=4, seq_length=10000,
            show_protected=False, show_private=False, show_static=False, show_properties=False, show_address=False,
            str_length=50):
    """Represents any python object in a human readable format.
    :param obj: An object to represent.
    :type obj: object
    :param depth: Depth of introspecion. Default is 4.
    :type depth: int
    :param seq_length: Maximum sequence length. Also, used for object's members enumeration. Default is 10000.
    :type seq_length: int
    :param show_protected: Examine protected members. Default is False.
    :type show_protected: bool
    :param show_private: Examine private members. To take effect show_protected must be set to True. Default is False.
    :type show_private: bool
    :param show_static: Examine static members. Default is False.
    :type show_static: bool
    :param show_properties: Examine properties members. Default is False.
    :type show_properties: bool
    :param show_address: Show address. Default is False.
    :type show_address: bool
    :param str_length: Maximum string length. Default is 50.
    :type str_length: int
    :return: The final representation of the object.
    :rtype: str
    """
    basestring_type = basestring if sys.version_info[0] < 3 else str

    def inspect_object(current_obj, current_depth):
        inspect_nested_object = partial(inspect_object,
                                        current_depth=current_depth - 1)

        # Basic types
        if isinstance(current_obj, Number):
            return [repr(current_obj)]

        # Strings
        if isinstance(current_obj, basestring_type):
            if len(current_obj) <= str_length:
                return [repr(current_obj)]
            return [repr(current_obj[:int(str_length)] + '...')]

        # Class object
        if isinstance(current_obj, type):
            module = current_obj.__module__ + '.' if hasattr(current_obj, '__module__') else ''
            return ["<class '" + module + current_obj.__name__ + "'>"]

        # None
        if current_obj is None:
            return ['None']

        # Format block of lines with brackets
        def format_block(lines, open_bkt='', close_bkt=''):
            return [open_bkt] + lines + [close_bkt]

        class SkipElement(object):
            pass

        class ErrorAttr(object):
            def __init__(self, e):
                self.e = e

        def is_seq(obj):
            # Special case subclases of dict as we handle accordingly
            if isinstance(obj, dict):
                return True
            try:
                # Attempt to slice sequence to see if supported in __getitem__ implementation
                sli = list(obj[0:0])
                return sli != None and hasattr(type(obj), '__len__')
            except Exception:
                return False

        def cut_seq(seq):
            """
            This function limts a sequence to seq_length and converts sequence to list
            to ensure the elements can be enumerated without potential side-effects
            """
            if current_depth < 1:
                return [SkipElement()]
            if len(seq) <= seq_length:
                if isinstance(seq, dict):
                    return list(seq.items())
                return list(seq)
            elif seq_length > 1:
                # If is a dict, slice using iterator
                if isinstance(seq, dict):
                    return list(islice(seq.items(), seq_length)) + [SkipElement()]
                return list(seq[:int(seq_length)]) + [SkipElement()]
            return [SkipElement()]

        def format_seq():
            r = []
            items = cut_seq(obj_items)
            for n, i in enumerate(items, 0):
                if type(i) is SkipElement:
                    r.append(' ...')
                else:
                    if type(current_obj) is dict or isinstance(current_obj, dict):
                        (k, v) = i
                        k = inspect_nested_object(k)
                        v = inspect_nested_object(v)
                        k[-1] += '] = ' + v.pop(0)
                        k.insert(0,'[')
                        r.extend(k)
                        r.extend(v)
                    elif is_seq(current_obj):
                        # Sequence types without keys should include the index number
                        r.extend(['[',str(n),'] = '])
                        r.extend(inspect_nested_object(i))
                    else:
                        (k, v) = i
                        k = [k]
                        if type(v) is ErrorAttr:
                            e_message = '<Attribute error: ' + type(v.e).__name__
                            if hasattr(v.e, 'message'):
                                e_message += ': ' + v.e.message
                            e_message += '>'
                            v = [e_message]
                        else:
                            v = inspect_nested_object(v)
                        k[-1] += ' = ' + v.pop(0)
                        r.extend(k)
                        r.extend(v)
                if n < len(items) - 1:
                    r[-1] += ', '
            return format_block(r, *brackets)

        # Sequence types
        # Others objects are considered as sequence of members
        if is_seq(current_obj):
            obj_items = current_obj

            # In this case we with to reperesent all sequences like a dictionary so it is readable
            # by DDT.
            name = type(current_obj).__name__
            brackets = name + ' of length ' + str(len(obj_items)) + ' = {','}'
        else:
            obj_items = []
            for k in sorted(dir(current_obj)):
                # In this case we never want to show magic methods as causes output to become clustered.
                # Will show mangled private variables (_CLASSNAME__VAR) though.
                if k.startswith('__') and k.endswith('__') or not show_private and k.startswith('_') and '__' in k:
                    continue
                if not show_protected and k.startswith('_'):
                    continue
                try:
                    v = getattr(current_obj, k)
                    if isroutine(v):
                        continue
                    if not show_static and hasattr(type(current_obj), k) and v is getattr(type(current_obj), k):
                        continue
                    if not show_properties and hasattr(type(current_obj), k) and isinstance(
                            getattr(type(current_obj), k), property):
                        continue
                except Exception as e:
                    v = ErrorAttr(e)

                obj_items.append((k, v))

            module = current_obj.__module__ + '.' if hasattr(current_obj, '__module__') else ''
            address = ' at ' + hex(id(current_obj)) + ' ' if show_address else ''
            brackets = (module + type(current_obj).__name__ + address + ' = {', '}')

        return format_seq()

    return ''.join(inspect_object(obj, depth))