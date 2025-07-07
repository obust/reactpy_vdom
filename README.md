# ReactPy VDOM


`reactpy_vdom` is a Virtual DOM library written in Mojo for [ReactPy](https://reactpy.dev/).

## Build

Build the `reactpy_vdom/_vdom.so` python extension

```bash
pixi run build
```

## Usage

To get a rough idea of how to write apps in ReactPy, take a look at this tiny _Hello World_ application.


### Mojo

```mojo
from reactpy_vdom import Element, diff

src = Element("ul", {"class": "foo"}, [
    Element("li", {}, "dog"),
    Element("li", {}, "cat"),
])
print(String(src))
# <ul class=foo><li>dog</li><li>cat</li></ul>

dst = Element("ul", {"class": "bar"}, [
    Element("li", {}, "dog"),
    Element("li", {}, "mouse"),
])
print(String(dst))
# <ul class=bar><li>dog</li><li>mouse</li></ul>

patches = diff(src, dst)
print(String(patches))
# [
#   Patch(action=update, path=[], value=<ul class=bar></ul>),
#   Patch(action=update, path=[1], value=<li>mouse</li>)
# ]

patched = patches(src)
print(String(patched))
# <ul class=bar><li>dog</li><li>mouse</li></ul>
```

### Python

Build python `_vdom.so` extension

```
pixi run build
```

```python
from reactpy_vdom import el, diff, apply

src = element("ul", {"class": "foo"}, [
    element("li", {}, "dog"),
    element("li", {}, "cat"),
])
print(src)
# Element(tag=ul, attributes={'class': 'foo'}, children=[
#   Element(tag=li, attributes={}, children=[], text=Optional('dog'), key=Optional(None)),
#   Element(tag=li, attributes={}, children=[], text=Optional('cat'), key=Optional(None))
# ], text=Optional(None), key=Optional(None))

dst = element("ul", {"class": "bar"}, [
    element("li", {}, "dog"),
    element("li", {}, "mouse"),
])
print(dst)
# Element(tag=ul, attributes={'class': 'bar'}, children=[
#   Element(tag=li, attributes={}, children=[], text=Optional('dog'), key=Optional(None)),
#   Element(tag=li, attributes={}, children=[], text=Optional('mouse'), key=Optional(None))
# ], text=Optional(None), key=Optional(None))

patches = diff(src, dst)
print(patches)
# ListPatch([
#   Patch(action=update, path=[], value=<ul class=bar></ul>),
#   Patch(action=update, path=[1], value=<li>mouse</li>)
# ])

patched = apply(src, patches, True)
print(patched)
# Element(tag=ul, attributes={'class': 'bar'}, children=[
#   Element(tag=li, attributes={}, children=[], text=Optional('dog'), key=Optional(None)),
#   Element(tag=li, attributes={}, children=[], text=Optional('mouse'), key=Optional(None))
# ], text=Optional(None), key=Optional(None))
```

## Test

Run test suite

```bash
pixi run test
```

## Benchmark


### Mojo Benchmark

Run benchmark suite inspired by [js-framework-benchmark](https://github.com/krausest/js-framework-benchmark)

```bash
pixi run bench_mojo
```

| name                        | met (ms)              | iters   | throughput (GElems/s)  | min (ms)              | mean (ms)             | max (ms)              | duration (ms) |
| --------------------------- | --------------------- | ------- | ---------------------- | --------------------- | --------------------- | --------------------- | ------------- |
| create_rows[1]              | 0.0026430036114982068 | 477918  | 0.0003783574095962519  | 0.0026430036114982068 | 0.0026430036114982068 | 0.0026430036114982068 | 1263.139      |
| create_rows[10]             | 0.022585521565646968  | 52630   | 0.0004427615262695638  | 0.02258552156564697   | 0.022585521565646968  | 0.02258552156564697   | 1188.676      |
| create_rows[100]            | 0.2180455793520044    | 5463    | 0.0004586197083067841  | 0.2180455793520044    | 0.2180455793520044    | 0.2180455793520044    | 1191.183      |
| create_rows[1000]           | 2.214145220588235     | 544     | 0.00045164155932569255 | 2.214145220588235     | 2.214145220588235     | 2.214145220588235     | 1204.495      |
| create_rows[10000]          | 29.587574999999998    | 40      | 0.00033797970938814694 | 29.587575             | 29.587574999999998    | 29.587575             | 1183.503      |
| diff_append_row[1000+1]     | 2.533135881104034     | 471     | 0.00039516237856286157 | 2.533135881104034     | 2.533135881104034     | 2.533135881104034     | 1193.107      |
| diff_append_row[1000+10]    | 2.6789449339207048    | 454     | 0.00037701409506832946 | 2.6789449339207048    | 2.6789449339207048    | 2.6789449339207048    | 1216.241      |
| diff_append_row[1000+100]   | 3.3380165745856356    | 362     | 0.00032953700960473766 | 3.338016574585635     | 3.3380165745856356    | 3.338016574585635     | 1208.362      |
| diff_append_row[1000+1000]  | 11.11425              | 100     | 0.00017994916436106802 | 11.11425              | 11.11425              | 11.11425              | 1111.425      |
| diff_append_row[1000+10000] | 115.7882              | 10      | 9.500104501149514e-05  | 115.7882              | 115.7882              | 115.7882              | 1157.882      |
| diff_clear_rows[1]          | 0.000974777           | 1000000 | 1.0269015374798545     | 0.000974777           | 0.000974777           | 0.000974777           | 974.777       |
| diff_clear_rows[10]         | 0.005504635407791538  | 217133  | 0.18348172497862353    | 0.005504635407791537  | 0.005504635407791538  | 0.005504635407791537  | 1195.238      |
| diff_clear_rows[100]        | 0.046896370638347534  | 25707   | 0.023455972925557726   | 0.04689637063834753   | 0.046896370638347534  | 0.04689637063834753   | 1205.565      |
| diff_clear_rows[1000]       | 0.4477946995147443    | 2679    | 0.004466332455849329   | 0.44779469951474427   | 0.4477946995147443    | 0.44779469951474427   | 1199.642      |
| diff_clear_rows[10000]      | 4.920510288065843     | 243     | 0.0022355404939766697  | 4.920510288065843     | 4.920510288065843     | 4.920510288065843     | 1195.684      |
| diff_select_row[1]          | 0.0046520686482440276 | 256496  | 0.00021495813488854268 | 0.004652068648244027  | 0.0046520686482440276 | 0.004652068648244027  | 1193.237      |
| diff_select_row[10]         | 0.027238836662749708  | 44252   | 0.0003671228739983391  | 0.027238836662749705  | 0.027238836662749708  | 0.027238836662749705  | 1205.373      |
| diff_select_row[100]        | 0.25760467587672686   | 4705    | 0.00038819171142628493 | 0.2576046758767269    | 0.25760467587672686   | 0.2576046758767269    | 1212.03       |
| diff_select_row[1000]       | 2.79123982869379      | 467     | 0.00035826373273985837 | 2.7912398286937905    | 2.79123982869379      | 2.7912398286937905    | 1303.509      |
| diff_select_row[10000]      | 29.525349999999996    | 40      | 0.0003386920053445599  | 29.52535              | 29.525349999999996    | 29.52535              | 1181.014      |
| diff_partial_update[100]    | 0.29135840158848353   | 4029    | 0.00034321989499805345 | 0.2913584015884835    | 0.29135840158848353   | 0.2913584015884835    | 1173.883      |
| diff_partial_update[1000]   | 3.018402985074627     | 402     | 0.00033130102406629983 | 3.018402985074627     | 3.018402985074627     | 3.018402985074627     | 1213.398      |
| diff_partial_update[10000]  | 36.6015               | 32      | 0.00027321284646804095 | 36.6015               | 36.6015               | 36.6015               | 1171.248      |
| diff_swap_rows[10]          | 0.03279938127960139   | 36527   | 0.00030488379993372634 | 0.032799381279601386  | 0.03279938127960139   | 0.032799381279601386  | 1198.063      |
| diff_swap_rows[100]         | 0.26331263858093124   | 4510    | 0.0003797766812065278  | 0.2633126385809313    | 0.26331263858093124   | 0.2633126385809313    | 1187.54       |
| diff_swap_rows[1000]        | 2.5979978540772533    | 466     | 0.0003849117882952125  | 2.597997854077253     | 2.5979978540772533    | 2.597997854077253     | 1210.667      |
| diff_swap_rows[10000]       | 30.13174358974359     | 39      | 0.0003318759158498832  | 30.13174358974359     | 30.13174358974359     | 30.13174358974359     | 1175.138      |

### Python Benchmark

```bash
pixi run bench_py
```

```
----------------------------------------------------------------------------------------------------------
Name (time in us)                            Min                     Max                    Mean
----------------------------------------------------------------------------------------------------------
test_diff_clear_rows_1000               431.5830 (1.0)          767.8330 (1.0)          449.8869 (1.0)
test_patches_to_python_1000           7,991.2080 (18.52)      9,658.4160 (12.58)      8,201.4941 (18.23)
test_diff_append_rows_1000_1000      10,731.0420 (24.86)     18,912.8330 (24.63)     11,194.5240 (24.88)
test_create_rows_1000               196,904.7920 (456.24)   201,692.5410 (262.68)   198,424.3664 (441.05)
----------------------------------------------------------------------------------------------------------
```
