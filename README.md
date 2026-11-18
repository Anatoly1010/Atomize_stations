# Atomize stations

Station folders for [Atomize](https://github.com/Anatoly1010/Atomize). Each folder holds one
spectrometer's own files and is installed on top of the core:

```bash
python3 -m pip install -e "path/to/Atomize[serial,modbus,math,bots]"
python3 -m pip install -e path/to/Atomize_treatment
python3 -m pip install -e path/to/Atomize_stations/itc
```

| Folder | Station | Command |
| --- | --- | --- |
| `itc/` | ITC EPR endstation | `atomize-itc`, `epr-auto` |
| `itc2/` | ITC2 CW/TR EPR spectrometer (PC `itc22`) | `atomize-itc2`, `epr-auto` |
