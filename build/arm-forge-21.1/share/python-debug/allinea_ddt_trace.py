# Based on trace.py

# portions copyright 2001, Autonomous Zones Industries, Inc., all rights...
# err...  reserved and offered to the public under the terms of the
# Python 2.2 license.
# Author: Zooko O'Whielacronx
# http://zooko.com/
# mailto:zooko@zooko.com
#
# Copyright 2000, Mojam Media, Inc., all rights reserved.
# Author: Skip Montanaro
#
# Copyright 1999, Bioreason, Inc., all rights reserved.
# Author: Andrew Dalke
#
# Copyright 1995-1997, Automatrix, Inc., all rights reserved.
# Author: Skip Montanaro
#
# Copyright 1991-1995, Stichting Mathematisch Centrum, all rights reserved.
#
#
# Permission to use, copy, modify, and distribute this Python software and
# its associated documentation for any purpose without fee is hereby
# granted, provided that the above copyright notice appears in all copies,
# and that both that copyright notice and this permission notice appear in
# supporting documentation, and that the name of neither Automatrix,
# Bioreason or Mojam Media be used in advertising or publicity pertaining to
# distribution of the software without specific, written prior permission.
#
import os
import sys

if (sys.version_info[0] != 3 or
       sys.version_info[1] < 5 or
       sys.version_info[1] > 9):
    sys.exit("This version of Python isn't suported. Only 3.5 - 3.9 are supported.\n"
             "To continue without python debugging enabled, remove %allinea_python_debug%\n"
             "from the command line and remove all occurences of 'breakpoint()'\n"
             "from your script.")

# Import possible invalid imports after version check
import sysconfig
import importlib

script_dir = os.path.dirname(os.path.realpath(__file__))
sys.path.append(script_dir)

version_extension = str(sys.version_info[0]) + str(sys.version_info[1])
# Trace refs configured via --with-trace-refs since Python 3.8, else --with-pydebug
tracerefs_configured = sysconfig.get_config_var('Py_TRACE_REFS') if sys.version_info[0] > 3 or sys.version_info[0] == 3 and sys.version_info[1] >= 8 else sysconfig.get_config_var('Py_DEBUG')
tracerefs_cflags_enabled = '-DPy_TRACE_REFS' in sysconfig.get_config_var('CFLAGS')
tracerefs_extension = "_tracerefs" if (tracerefs_configured or tracerefs_cflags_enabled) else ""
pythondebugging = importlib.import_module("forgepythondebugging" +
                                                version_extension +
                                                tracerefs_extension)

def main():
    if len(sys.argv) < 2:
        sys.exit("Not enough arguments. Pass name of script to debug after"
                 " %allinea_python_debug%.")

    try:
        # Shift arguments by 1 to remove this script
        sys.argv = sys.argv[1:]
        progname = sys.argv[0]
        with open(progname) as fp:
            code = compile(fp.read(), progname, 'exec')
        # try to emulate __main__ namespace as much as possible
        globs = {
            '__file__': progname,
            '__name__': '__main__',
            '__package__': None,
            '__cached__': None,
        }

        # emulate the fact that Python puts the directory of the script in the path
        user_script_dir = os.path.dirname(os.path.realpath(progname))
        sys.path.insert(0, user_script_dir)

        # Keep a reference to "sys.modules" dictionary and the user's main file
        # to be able to list module files in "Project Files".
        modules = sys.modules
        user_main = os.path.normpath(os.path.join(user_script_dir, progname))

        pythondebugging.set_trace_path(__file__)
        try:
            import threading
            threading.settrace(pythondebugging.install_trace)
        except:
            # If the threading module isn't available to be imported then threads can't
            # be used so there is no need to install the threaded trace function and no
            # need to print a warning.
            pass
        pythondebugging.install_trace()
        exec (code, globs)

    except IOError as err:
        sys.exit("Cannot run file %r because: %s" % (progname, err))
    except SystemExit:
        pass

if __name__=='__main__':
    main()
