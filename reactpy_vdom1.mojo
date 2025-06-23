from python import Python, PythonObject
from python.bindings import PythonModuleBuilder
import math
from os import abort

from reactpy_vdom.vdom import Element, create_element
from reactpy_vdom.reconcile import py_diff, py_apply, ListPatch, ListPatch_python

@export
fn PyInit_reactpy_vdom1() -> PythonObject:
    try:
        var module = PythonModuleBuilder("reactpy_vdom")
        _ = module.add_type[Element]("Element")
        _ = module.def_function[create_element]("create_element", docstring="Create a VDOM element")

        _ = (
            module.add_type[ListPatch]("ListPatch")
            .def_method[ListPatch_python]("python", docstring="Get the value of an attribute")
            # .def_method[ListPatch_json]("json", docstring="Get the value of an attribute")
        )

        _ = module.def_function[py_diff]("diff", docstring="Diff two VDOM elements")
        _ = module.def_function[py_apply]("apply", docstring="Apply patches to an element")

        return module.finalize()
    except e:
        return abort[PythonObject](String("error creating Python Mojo module:", e))

