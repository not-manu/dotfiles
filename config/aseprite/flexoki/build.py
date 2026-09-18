import re
import shutil
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).parent
DEFAULT_SOURCE = Path(
    "/Applications/Aseprite.app/Contents/Resources/data/extensions/aseprite-theme"
)
KEEP_PURE_RECT = (48, 256, 80, 272)

DARK = {
    "000000": "100F0F",
    "101114": "100F0F",
    "1f252d": "1C1B1A",
    "202020": "1C1B1A",
    "202125": "1C1B1A",
    "292b30": "282726",
    "2b2b2b": "282726",
    "2c2c30": "282726",
    "2f3136": "343331",
    "333333": "343331",
    "3f3f3f": "403E3C",
    "404040": "403E3C",
    "41444a": "403E3C",
    "4b575e": "403E3C",
    "52636a": "575653",
    "536069": "575653",
    "575757": "575653",
    "575b61": "575653",
    "636d79": "878580",
    "666666": "6F6E69",
    "67726a": "6F6E69",
    "826d61": "6F6E69",
    "74777a": "878580",
    "76858e": "878580",
    "7c7c7c": "878580",
    "7d7d7d": "878580",
    "808080": "878580",
    "7c919d": "878580",
    "93adbb": "B7B5AC",
    "99b3c2": "B7B5AC",
    "9aaa9e": "B7B5AC",
    "c0c0c0": "CECDC3",
    "c6c6c6": "CECDC3",
    "d0d0d0": "DAD8CE",
    "d7dbdf": "DAD8CE",
    "d9d9d9": "DAD8CE",
    "ebebeb": "E6E4D9",
    "eeeeee": "F2F0E5",
    "ecffff": "FFFCF0",
    "faf0e6": "FFFCF0",
    "ffffff": "FFFCF0",
    "2a4185": "205EA6",
    "4069c2": "4385BE",
    "3b3bc4": "4385BE",
    "0000ff": "4385BE",
    "6e9adb": "66A0C8",
    "e1b85f": "D0A215",
    "c4c43b": "D0A215",
    "c75a68": "D14D41",
    "c43b3b": "D14D41",
    "8c202e": "AF3029",
    "ffc8c8": "F89A8A",
    "3bc43b": "879A39",
    "64c864": "879A39",
    "839536": "879A39",
    "778932": "66800B",
    "3bc4c4": "3AA99F",
    "c43bc4": "CE5D97",
}

LIGHT = {
    "000000": "100F0F",
    "202020": "1C1B1A",
    "2e3234": "282726",
    "404040": "403E3C",
    "40402b": "403E3C",
    "41412c": "403E3C",
    "645460": "403E3C",
    "655561": "403E3C",
    "4b575e": "575653",
    "536069": "6F6E69",
    "786050": "6F6E69",
    "76858e": "6F6E69",
    "7c7c7c": "878580",
    "7d7d7d": "878580",
    "808080": "878580",
    "7c909f": "878580",
    "7c919d": "878580",
    "7d929e": "878580",
    "788591": "878580",
    "958174": "B7B5AC",
    "968275": "B7B5AC",
    "988d95": "B7B5AC",
    "93adbb": "B7B5AC",
    "99b3c2": "B7B5AC",
    "adcade": "B7B5AC",
    "bec8ce": "CECDC3",
    "c0c0c0": "CECDC3",
    "c7c7c7": "CECDC3",
    "c6c6c6": "DAD8CE",
    "d0d0d0": "DAD8CE",
    "d2cabd": "E6E4D9",
    "d3cbbe": "E6E4D9",
    "d9d9d9": "F2F0E5",
    "eeeeee": "F2F0E5",
    "ecffff": "FFFCF0",
    "faf0e6": "FFFCF0",
    "ffffff": "FFFCF0",
    "ffebb6": "FAEEC6",
    "ffff7c": "F6E2A0",
    "ffff7d": "F6E2A0",
    "ffff00": "AD8301",
    "ff5555": "AF3029",
    "ff0000": "AF3029",
    "c75a68": "D14D41",
    "5c0421": "6C201C",
    "ffc8c8": "FFCABB",
    "2c4c91": "205EA6",
    "0000ff": "205EA6",
    "00ff00": "66800B",
    "64c864": "66800B",
    "00ffff": "24837B",
    "ff00ff": "A02F6F",
}

VARIANTS = {
    "dark": ("dark", "Flexoki Dark", DARK),
    "light": (".", "Flexoki Light", LIGHT),
}


def rgb(hex_color):
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def recolor_sheet(src, dest, mapping):
    table = {rgb(k): rgb(v) for k, v in mapping.items()}
    pure = {(0, 0, 0), (255, 255, 255)}
    x0, y0, x1, y1 = KEEP_PURE_RECT
    image = Image.open(src).convert("RGBA")
    pixels = image.load()
    unmapped = set()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            color = (r, g, b)
            if color in pure and x0 <= x < x1 and y0 <= y < y1:
                continue
            if color in table:
                pixels[x, y] = (*table[color], a)
            else:
                unmapped.add("%02x%02x%02x" % color)
    image.save(dest)
    return unmapped


def recolor_xml(src, dest, name, mapping):
    unmapped = set()

    def swap(match):
        key = match.group(1).lower()
        if key not in mapping:
            unmapped.add(key)
            return match.group(0)
        return 'value="#%s"' % mapping[key].lower()

    text = src.read_text(encoding="utf-8")
    text = re.sub(r'value="#([0-9a-fA-F]{6})"', swap, text)
    text = re.sub(r'<theme name="[^"]*"', '<theme name="%s"' % name, text, count=1)
    dest.write_text(text, encoding="utf-8")
    return unmapped


def main():
    source = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SOURCE
    for variant, (subdir, name, mapping) in VARIANTS.items():
        src = source / subdir
        dest = HERE / variant
        dest.mkdir(exist_ok=True)
        shutil.copyfile(src / "sheet.aseprite-data", dest / "sheet.aseprite-data")
        skipped_png = recolor_sheet(src / "sheet.png", dest / "sheet.png", mapping)
        skipped_xml = recolor_xml(src / "theme.xml", dest / "theme.xml", name, mapping)
        print(variant, "unmapped sheet:", sorted(skipped_png))
        print(variant, "unmapped xml:", sorted(skipped_xml))


main()
