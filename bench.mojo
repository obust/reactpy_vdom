"""
https://github.com/krausest/js-framework-benchmark/blob/master/frameworks/non-keyed/vue/src/App.vue

"""


from benchmark import (
    Bench,
    BenchConfig,
    Bencher,
    BenchId,
    ThroughputMeasure,
    BenchMetric,
    Format,
)
from utils import IndexList
from gpu.host import DeviceContext
from pathlib import Path
from random import random_si64

from reactpy_vdom import Element, diff


fn row(label: String) -> Element:
    return Element("tr", {}, [
        Element("td", {"class": "col-md-1"}, ""),
        Element("td", {"class": "col-md-4"}, [
            Element("a", {"class": "lbl"}, [
                Element("span", {}, label)
            ])
        ]),
        Element("td", {"class": "col-md-1"}, [
            Element("a", {"class": "remove"}, [
                Element("span", {"class": "glyphicon glyphicon-remove", "aria-hidden": "true"}, [])
            ])
        ]),
        Element("td", {"class": "col-md-6"}, ""),
    ])

fn create_rows(n_rows: Int) -> Element:
    return Element("table", {"class": "table table-hover table-striped test-data"}, [
        Element("tbody", {}, [row("Row " + String(i)) for i in range(n_rows)])
    ])


# fn get_gbs_measure(input: String) raises -> ThroughputMeasure:
#     return ThroughputMeasure(BenchMetric.bytes, input.byte_length())

fn get_throughput_elems(n: Int) -> ThroughputMeasure:
    return ThroughputMeasure(BenchMetric.elements, n)

# fn run[
#     func: fn (mut Bencher, Int) capturing, name: String
# ](mut m: Bench, data: String) raises:
#     m.bench_with_input[Int, func](BenchId(name), data, get_gbs_measure(data))


fn main() raises:
    var config = BenchConfig(num_repetitions=1)
    config.verbose_timing = True
    config.flush_denormals = True
    config.show_progress = True
    var m = Bench(config)

    m.bench_with_input[Int, bench_create_rows]("create_rows[1]", 1, [get_throughput_elems(1)])
    m.bench_with_input[Int, bench_create_rows]("create_rows[10]", 10, [get_throughput_elems(10)])
    m.bench_with_input[Int, bench_create_rows]("create_rows[100]", 100, [get_throughput_elems(100)])
    m.bench_with_input[Int, bench_create_rows]("create_rows[1000]", 1000, [get_throughput_elems(1000)])
    m.bench_with_input[Int, bench_create_rows]("create_rows[10000]", 10_000, [get_throughput_elems(10_000)])

    m.bench_with_input[Int, bench_diff_append_rows]("diff_append_row[1000+1]", 1, [get_throughput_elems(1001)])
    m.bench_with_input[Int, bench_diff_append_rows]("diff_append_row[1000+10]", 10, [get_throughput_elems(1010)])
    m.bench_with_input[Int, bench_diff_append_rows]("diff_append_row[1000+100]", 100, [get_throughput_elems(1100)])
    m.bench_with_input[Int, bench_diff_append_rows]("diff_append_row[1000+1000]", 1000, [get_throughput_elems(2000)])
    m.bench_with_input[Int, bench_diff_append_rows]("diff_append_row[1000+10000]", 10_000, [get_throughput_elems(11_000)])

    m.bench_with_input[Int, bench_diff_clear_rows]("diff_clear_rows[1]", 1, [get_throughput_elems(1001)])
    m.bench_with_input[Int, bench_diff_clear_rows]("diff_clear_rows[10]", 10, [get_throughput_elems(1010)])
    m.bench_with_input[Int, bench_diff_clear_rows]("diff_clear_rows[100]", 100, [get_throughput_elems(1100)])
    m.bench_with_input[Int, bench_diff_clear_rows]("diff_clear_rows[1000]", 1000, [get_throughput_elems(2000)])
    m.bench_with_input[Int, bench_diff_clear_rows]("diff_clear_rows[10000]", 10_000, [get_throughput_elems(11_000)])

    m.bench_with_input[Int, bench_diff_select_row]("diff_select_row[1]", 1, [get_throughput_elems(1)])
    m.bench_with_input[Int, bench_diff_select_row]("diff_select_row[10]", 10, [get_throughput_elems(10)])
    m.bench_with_input[Int, bench_diff_select_row]("diff_select_row[100]", 100, [get_throughput_elems(100)])
    m.bench_with_input[Int, bench_diff_select_row]("diff_select_row[1000]", 1000, [get_throughput_elems(1000)])
    m.bench_with_input[Int, bench_diff_select_row]("diff_select_row[10000]", 10_000, [get_throughput_elems(10_000)])
    m.bench_with_input[Int, bench_diff_partial_update]("diff_partial_update[100]", 100, [get_throughput_elems(100)])
    m.bench_with_input[Int, bench_diff_partial_update]("diff_partial_update[1000]", 1_000, [get_throughput_elems(1_000)])
    m.bench_with_input[Int, bench_diff_partial_update]("diff_partial_update[10000]", 10_000, [get_throughput_elems(10_000)])

    m.bench_with_input[Int, bench_diff_swap_rows]("diff_swap_rows[10]", 10, [get_throughput_elems(10)])
    m.bench_with_input[Int, bench_diff_swap_rows]("diff_swap_rows[100]", 100, [get_throughput_elems(100)])
    m.bench_with_input[Int, bench_diff_swap_rows]("diff_swap_rows[1000]", 1000, [get_throughput_elems(1000)])
    m.bench_with_input[Int, bench_diff_swap_rows]("diff_swap_rows[10000]", 10_000, [get_throughput_elems(10_000)])

    # FIXME: ABORT: Failed to load libpython from
    # m.bench_with_input[Int, bench_patches_to_python]("bench_patches_to_python[1]", 1, [get_throughput_elems(1)])
    # m.bench_with_input[Int, bench_patches_to_python]("bench_patches_to_python[10]", 10, [get_throughput_elems(10)])
    # m.bench_with_input[Int, bench_patches_to_python]("bench_patches_to_python[100]", 100, [get_throughput_elems(100)])
    # m.bench_with_input[Int, bench_patches_to_python]("bench_patches_to_python[1000]", 1000, [get_throughput_elems(1000)])

    # FIXME: error: failed to materialize top-level module (from emberjson import JSON)
    # m.bench_with_input[Int, bench_patches_to_json_string]("patches_to_json_string[1]", 1, [get_throughput_elems(1)])
    # m.bench_with_input[Int, bench_patches_to_json_string]("patches_to_json_string[10]", 10, [get_throughput_elems(10)])
    # m.bench_with_input[Int, bench_patches_to_json_string]("patches_to_json_string[100]", 100, [get_throughput_elems(100)])
    # m.bench_with_input[Int, bench_patches_to_json_string]("patches_to_json_string[100]", 1000, [get_throughput_elems(1000)])

    # Pretty print in table format
    print()
    print(m)


@parameter
fn bench_create_rows(mut b: Bencher, n_rows: Int) raises:
    """Creating N rows."""

    @always_inline
    @parameter
    fn do():
        _ = create_rows(n_rows)

    b.iter[do]()

@parameter
fn bench_diff_append_rows(mut b: Bencher, n_rows: Int) raises:
    """Diff for appending N rows."""

    src = create_rows(1000)
    dst = create_rows(1000 + n_rows)

    @always_inline
    @parameter
    fn do():
        _ = diff(src, dst)

    b.iter[do]()

@parameter
fn bench_diff_clear_rows(mut b: Bencher, n_rows: Int) raises:
    """Diff for clearing N rows."""

    src = create_rows(n_rows)
    dst = create_rows(0)

    @always_inline
    @parameter
    fn do():
        _ = diff(src, dst)

    b.iter[do]()

@parameter
fn bench_diff_select_row(mut b: Bencher, n_rows: Int) raises:
    """Diff to select a row."""

    src = create_rows(n_rows)
    dst = create_rows(n_rows)
    i = Int(random_si64(0, n_rows - 1))
    ref row = dst.get([0, i])
    row.attributes["class"] = "selected"

    @always_inline
    @parameter
    fn do():
        _ = diff(src, dst)

    b.iter[do]()

@parameter
fn bench_diff_partial_update(mut b: Bencher, n_rows: Int) raises:
    """Diff to update text every 10th row."""

    src = create_rows(n_rows)
    dst = create_rows(n_rows)
    for i in range(0, n_rows, 10):
        ref row = dst.get([0, i, 1, 0, 0])
        row.attributes["text"] = "this row is: " + String(i)

    @always_inline
    @parameter
    fn do():
        _ = diff(src, dst)

    b.iter[do]()

@parameter
fn bench_diff_swap_rows(mut b: Bencher, n_rows: Int) raises:
    """Diff to swap 2 rows."""

    src = create_rows(n_rows)
    dst = create_rows(n_rows)
    i = 1
    j = n_rows - 2
    row_j = dst.remove([0, j]).value()
    row_i = dst.remove([0, i]).value()
    dst.insert([0, i], row_j)
    dst.insert([0, j], row_i)

    @always_inline
    @parameter
    fn do():
        _ = diff(src, dst)

    b.iter[do]()

@parameter
fn bench_patches_to_python(mut b: Bencher, n_rows: Int) raises:
    """Convert ListPatch to python."""

    src = create_rows(0)
    dst = create_rows(n_rows)
    patches = diff(src, dst)

    @always_inline
    @parameter
    fn do() raises:
        _ = patches.python()

    b.iter[do]()

# @parameter
# fn bench_patches_to_json_string(mut b: Bencher, n_rows: Int) raises:
#     """Convert ListPatch to json string."""

#     src = create_rows(0)
#     dst = create_rows(n_rows)
#     patches = diff(src, dst)

#     @always_inline
#     @parameter
#     fn do():
#         _ = patches.json().to_string()

#     b.iter[do]()
