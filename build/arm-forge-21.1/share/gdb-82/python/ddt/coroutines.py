# Arm DDT pretty printer.
#
# Copyright (C) 2012 Arm Limited (or its affiliates). All rights reserved.
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

import gdb
from qt4.qt4 import QListPrinter

class InfoCoroutines(gdb.Command):
    def __init__(self):
        gdb.Command.__init__(self, "info coroutines", gdb.COMMAND_STATUS)
 
    def invoke(self, arg, from_tty):
        qt_currentCoroutine = gdb.parse_and_eval('qt_currentCoroutine.d.get()')
        currentCoroutine = qt_currentCoroutine.dereference().cast(gdb.lookup_type('Coroutine').pointer().pointer().pointer()).dereference()
        qt_allCoroutines = gdb.parse_and_eval('qt_allCoroutines')
        printer = QListPrinter(qt_allCoroutines, 'qt_allCoroutines', None)
        index = 1
        oldpc = gdb.parse_and_eval('(unsigned long long)$pc')
        oldsp = gdb.parse_and_eval('(unsigned long long)$sp')
        oldrbp = gdb.parse_and_eval('(unsigned long long)$rbp')
        oldrbx = gdb.parse_and_eval('(unsigned long long)$rbx')
        for tuple in printer.children():
            coroutine = tuple[1]
            if coroutine == currentCoroutine:
                current = '*'
                sp = oldsp
                pc = oldpc
                rbp = oldrbp
                rbx = oldrbx
            else:
                current = ' '
                sp = gdb.parse_and_eval('(unsigned long long)(void *)((Coroutine *)%s)->_stackPointer' % coroutine)
                pc = gdb.parse_and_eval('(unsigned long long)((void **)%s)[7]' % sp)
                rbp = gdb.parse_and_eval('(unsigned long long)((void **)%s)[6]' % sp)
                rbx = gdb.parse_and_eval('(unsigned long long)((void **)%s)[5]' % sp)
            sp += 8 * 8
            gdb.execute('set $pc = %s' % pc)
            gdb.execute('set $sp = %s' % sp)
            gdb.execute('set $rbp = %s' % rbp)
            gdb.execute('set $rbx = %s' % rbx)
            print '%c %d Coroutine %s' % (current, index, coroutine)
            #gdb.execute('bt')
            #gdb.execute('frame', False, True)
            index = index + 1
        gdb.parse_and_eval('$pc = %s' % oldpc)
        gdb.parse_and_eval('$sp = %s' % oldsp)
        gdb.parse_and_eval('$rbp = %s' % oldrbp)
        gdb.parse_and_eval('$rbx = %s' % oldrbx)

class Coroutine(gdb.Command):
    def __init__(self):
        gdb.Command.__init__(self, "coroutine", gdb.COMMAND_RUNNING)
        
    def invoke(self, arg, from_tty):
        index = int(gdb.parse_and_eval(arg))
        qt_currentCoroutine = gdb.parse_and_eval('qt_currentCoroutine.d.get()')
        currentCoroutine = qt_currentCoroutine.dereference().cast(gdb.lookup_type('Coroutine').pointer().pointer().pointer()).dereference()        
        qt_allCoroutines = gdb.parse_and_eval('qt_allCoroutines')
        printer = QListPrinter(qt_allCoroutines, 'qt_allCoroutines', None)        
        i = 1
        coroutine = None
        for tuple in printer.children():
            if i == index:
                coroutine = tuple[1]
                break
            i = i + 1
        if coroutine is None:
            print 'Coroutine ID %d not known.' % index
            return
        sp = gdb.parse_and_eval('(unsigned long long)(void *)((Coroutine *)%s)->_stackPointer' % coroutine)
        pc = gdb.parse_and_eval('(unsigned long long)((void **)%s)[7]' % sp)
        rbp = gdb.parse_and_eval('(unsigned long long)((void **)%s)[6]' % sp)
        rbx = gdb.parse_and_eval('(unsigned long long)((void **)%s)[5]' % sp)
        sp += 8 * 8
        gdb.execute('set $pc = %s' % pc)
        gdb.execute('set $sp = %s' % sp)
        gdb.execute('set $rbp = %s' % rbp)
        gdb.execute('set $rbx = %s' % rbx)        
        print '[Switching to coroutine %d (Coroutine %s)]' % (index, coroutine)
        gdb.execute('frame')
          
InfoCoroutines()
Coroutine()
