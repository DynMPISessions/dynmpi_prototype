# Common classes and methods which are shared between the different pretty
# printers / helpers for Python debugging.

import gdb
import os

class Inject:
    """
    Inject external dependencies (from pretty printer) to enables re-use of this
    common module across different pretty printers, without re-factoring them
    into modules.
    """
    from_pyobject_ptr = None
    PyDictObjectPtr = None
    PyUnicodeObjectPtr = None

class SourceFileCache:
    """
    Keeps a module name to module source file map.
    """

    Instance = None

    def __init__(self):
        self.modules = {}
        self.user_main = None
        self.only_count_mode = False
        self.stat_non_count_mode_updates = 0
        self.stat_cur_modules = 0
        self.stat_new_modules = 0
        self.stat_attr_access = 0
        self.stat_attr_access_total = 0
        self.stat_debug_msg = ''
        self.debug = False
        self.pyModuleObject_type = None
        self.internal_dir = os.path.dirname(__file__)
        self.exclude_internals = True # Only used for testing

    def update(self, frame):
        """
        Searches in locals for the "modules" local variable which is a reference
        to "sys.modules" and then updates the source files for all modules.
        """
        for pyop_name, pyop_value in frame.iter_locals():
            pyop_name_val = pyop_name.proxyval(set())
            if (str(pyop_name_val) == "modules"):
                self.__update(pyop_value)
            if (str(pyop_name_val) == "user_main"):
                self.user_main = pyop_value.proxyval(set())

    def print_filenames(self):
        """
        Prints the source file information for all seen modules.
        """
        print(self.user_main)
        for _, filename in self.modules.items():
            if not filename:
                continue
            # Hide .so files for example.
            if not filename.endswith(".py"):
                continue
            # Hide all internal files, such as our trace module or ppretty.
            if self.exclude_internals and filename.startswith(self.internal_dir):
                continue

            print(filename)

    def print_new_module_count(self):
        """
        Prints the number of new modules loaded since the last update.
        """
        print(self.stat_new_modules)

    def print_stats(self):
        """
        Prints some stats for debugging and testing.
        """
        print("**** Source File Cache Update Stats ****")
        print("  Current modules: {}.".format(self.stat_cur_modules))
        print("      New modules: {}.".format(self.stat_new_modules))
        print("      All modules: {}.".format(len(self.modules)))
        print("Attributes Access: {} ({}).".format(self.stat_attr_access, self.stat_attr_access_total))
        print("Non-count updates: {}.".format(self.stat_non_count_mode_updates))
        print("    Debug Message: {}.".format(self.stat_debug_msg))

    def __get_py_module_object_type(self):
        """
        Returns a PyModuleObject* type or throws a gdb.error if not found.
        """
        if not self.pyModuleObject_type:
            self.pyModuleObject_type = gdb.lookup_type("PyModuleObject").pointer()
        return self.pyModuleObject_type

    def __update(self, modules):
        """
        Updates the module source files from the given "sys.modules" reference
        and/or only counts any new modules.
        """
        self.stat_cur_modules = 0
        self.stat_new_modules = 0
        self.stat_attr_access = 0
        self.stat_debug_msg = ''

        if not self.only_count_mode:
            # Keep track of update invocations in non count mode (for testing
            # purposes).
            self.stat_non_count_mode_updates += 1

        for pyop_module_name, pyop_module_val in modules.iteritems():
            self.stat_cur_modules += 1
            pyop_module_name_val = pyop_module_name.proxyval(set())

            # If we already have seen the module before then continue with next
            # module.
            if pyop_module_name_val in self.modules:
                continue

            # This is a new module which we have not seen before.

            # 1) Keep track of new module count. If "only_count" mode is enabled
            #    then that is the only action here.
            self.stat_new_modules += 1
            if self.only_count_mode:
                continue

            # 2) Determine file name and store in cache.
            module_ptr = pyop_module_val._gdbval.cast(self.__get_py_module_object_type())
            filename = self.__get_module_file(module_ptr.dereference())
            if self.debug:
                self.stat_debug_msg += "[{}] {} = {}, ".format(self.stat_new_modules, pyop_module_name_val, filename)

            self.modules[pyop_module_name_val] = filename

    def __get_module_file(self, module):
        """
        Returns the __file__ attribute value (if present) of the given
        PyModuleObject* or None otherwise.
        """
        md_dict = Inject.from_pyobject_ptr(module['md_dict'])

        if not isinstance(md_dict, Inject.PyDictObjectPtr):
            return None

        for pyop_attr_name, pyop_attr_value in md_dict.iteritems():
            # Keep stats how many attribute we access as it's quite expensive /
            # lots of attributes. If you can find a better way to access __file__,
            # that would be great!
            self.stat_attr_access += 1
            self.stat_attr_access_total += 1

            # Ignore non-string key.
            if not isinstance(pyop_attr_name, Inject.PyUnicodeObjectPtr):
                continue

            pyop_attr_name_val = str(pyop_attr_name.proxyval(set()))

            # If "wrong" attribute then continue with next attribute.
            if (pyop_attr_name_val != "__file__"):
                continue

            # As we have found the __file__ attribute (even though not a string)
            # do not continue iterating the remaining attributes to save CPU
            # cycles.
            if not isinstance(pyop_attr_value, Inject.PyUnicodeObjectPtr):
                return None

            # Return string value of __file__ attribute.
            return pyop_attr_value.proxyval(set())

        # No __file__ attribute present.
        return None

SourceFileCache.Instance = SourceFileCache()