from pytest_benchmark.fixture import BenchmarkFixture

from reactpy_vdom import element, diff, Element


def row(label: str) -> Element:
    return element("tr", {}, [
        element("td", {"class": "col-md-1"}, ""),
        element("td", {"class": "col-md-4"}, [
            element("a", {"class": "lbl"}, [
                element("span", {}, label)
            ])
        ]),
        element("td", {"class": "col-md-1"}, [
            element("a", {"class": "remove"}, [
                element("span", {"class": "glyphicon glyphicon-remove", "aria-hidden": "true"}, [])
            ])
        ]),
        element("td", {"class": "col-md-6"}, ""),
    ])

def create_rows(n_rows: int) -> Element:
    return element("table", {"class": "table table-hover table-striped test-data"}, [
        element("tbody", {}, [row("Row " + str(i)) for i in range(n_rows)])
    ])


def test_create_rows_1000(benchmark: BenchmarkFixture):
    benchmark(create_rows, 1000)


def test_diff_append_rows_1000_1000(benchmark: BenchmarkFixture):
    src = create_rows(1000)
    dst = create_rows(2000)
    def do():
        _ = diff(src, dst)
    benchmark(do)


def test_diff_clear_rows_1000(benchmark: BenchmarkFixture):
    src = create_rows(1000)
    dst = create_rows(0)
    def do():
        _ = diff(src, dst)
    benchmark(do)

def test_patches_to_python_1000(benchmark: BenchmarkFixture):
    src = create_rows(1000)
    dst = create_rows(0)
    patches = diff(src, dst)
    def do():
        _ = patches.python()
    benchmark(do)
