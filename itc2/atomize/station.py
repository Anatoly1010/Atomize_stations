"""ITC2 station (CW/TR EPR spectrometer): app name for the user config folders and the oldest core it runs on."""
import re
from importlib.metadata import PackageNotFoundError, version

app_name = "atomize-itc2"
min_core = (0, 5, 0)

try:
    _core = version('atomize-py')
except PackageNotFoundError:
    _core = None
if _core and tuple(int(n) for n in re.findall(r'\d+', _core)[:3]) < min_core:
    raise RuntimeError(f"atomize-itc2 needs atomize-py {'.'.join(map(str, min_core))} or newer, "
                       f"found {_core}: pull and reinstall the core")
