# Two repos instead of five — roadmap

Created 2026-11-15. Status: Phases 1 to 4 done (spectrometer PC on 2026-11-17); Phase 5 is next. This file moved here
from `Atomize_ITC/docs/stations/`.

## Resume here

State on 2026-11-17: the spectrometer PC (`fel2@192.168.2.1`, Ubuntu 22.04, Python 3.10, no internet)
runs the new setup; CW, TR and pulsed mode work. Core `Atomize` `e16ea36` (BH_15 `max_set_retries`
read from the config) and `Atomize_stations` `c67f565` (CW defaults 10 ms / 50 mV) are on the PC and
not yet pushed. Details in Phase 4 below.

- Install: venv `~/sources/atomize_venv`, created `--without-pip` (the box has no `python3-venv`);
  pip, build tools and all packages from wheels in `~/sources/wheels` (PyQt6 6.12.1, numpy 2.2.6,
  scipy 1.15.3, pyqtgraph 0.14.0). Core and station editable from `~/sources/Atomize` and
  `~/sources/Atomize_stations`, cloned from bundles in `~/sources/bundles`. The linux-gpib binding
  stays in `/usr/local`; `linux_gpib.pth` in the venv points at it.
- `.bashrc`: `atom` and `epr` start the venv's `atomize-itc` and `epr-auto run`; `atom-pull` pulls
  both repos from GitHub (`origin` = the public HTTPS URLs; the PC needs a network connection). The desktop launcher points at the venv.
- `~/.config/atomize-itc` is kept as it was, plus `max_set_retries = 1` in `BH_15_config.ini` (the
  box ran with a local code edit before). Device configs changed in a repo must be copied there by hand.
- The old `~/sources/Atomize_ITC` and its user-site install are removed; the folder is in
  `~/sources/Atomize_ITC_archive_2026_11_17.tar.gz`, the configs and runtime files of the day in
  `~/sources/old_setup_backup_2026_11_17.tar.gz`. Plain `python3` has no `atomize` any more.

State on 2026-11-15, end of session 2. Phases 1 to 3 are done, committed and pushed in every repo.

| Repo | State |
|---|---|
| `Atomize` | `12dad09`: `python -m atomize` starts an installed station's window; `ITC_FC.py` reads the Sibir curve from the user config copy; `test_preset_loader.py` moved to the ITC station |
| `Atomize_stations` | `README.md` and `itc/`, built from `Atomize_ITC` `070540e`; `c0ee999` put back the whole `icons/` folder; remote `origin` = `https://github.com/Anatoly1010/Atomize_stations.git`, branch `main` |
| `Atomize_ITC`, `Atomize_NIOCH`, `Atomize_Cryomech` | plain's `ITC_FC.py` synced in (session 2, last step); `Atomize_ITC` stays in use on the spectrometer PC until Phase 4, and its `docs/stations/ROADMAP.md` now only points here |
| `Atomize_NIOCH_Q` | keeps its older `ITC_FC.py` (Q-band magnet firmware, no calibration curve), as `sync_check.py` allows |
| `atomize_sync` | `test_preset_loader.py` is per-fork: it parses each fork's own presets |

The development laptop runs the new setup: `~/.venvs/atomize` holds the core 0.5.0, and
`~/.venvs/atomize-itc` holds the core plus `Atomize_stations/itc` (both editable). `apull` and
`apush` include `Atomize_stations`; `apull` reinstalls the core into both venvs and the station into
`atomize-itc` when a `pyproject.toml` changes. The old `Atomize_ITC` install is removed; the checkout
stays.

Watch out until Phase 4 and Phase 5:

- The Sibir calibration curve is optional. `ITC_FC.py` opens it only for
  `magnet_field(field, calibration = 'True')`, which no tool or script uses today, and then reads it
  from `~/.config/<app name>/device_config/`; a setup without the file gets a clear error.
- `sync_check.py --sync-cc` still mirrors the shared control-center tools from `Atomize_ITC`, while
  the laptop runs `Atomize_stations/itc`. Edits to those tools must go into `Atomize_ITC` too until
  Phase 5 moves the lead to the station.

How `itc/` was built: every `Atomize_ITC` file that plain does not have or that differs from
plain's, plus `tests/conftest.py`, `license.md` and the whole `icons/` folder, minus `__main__.py`, `pyproject.toml`,
`last_dir.py` (plain's is used), `ITC_FC.py` and the moved preset test. No `atomize/__init__.py`
and no `device_modules/__init__.py`, so the folders join the core's. Changed against `Atomize_ITC`:
`main.py` passes `lconf.ROOT_DIR/libs` to the core window; `epr_auto/params.py` finds the presets
next to itself and `epr_auto/cli.py` finds `libs/` via `lconf.ROOT_DIR` (both used
`atomize.__file__`, the core folder); `station.py` stops with a clear message when `atomize-py` is
older than 0.5.0; new `pyproject.toml` (version 0.5.0, needs `atomize-py>=0.5` and `pyyaml`);
`tests/test_preset_loader.py`, `test_insys_guard.py` (status file under `ROOT_DIR`) and
`test_tr_two_fields.py` (device configs = core's + station's in a temporary folder);
`CLAUDE.md` and `AGENTS.md` describe the station layout.

Checks done in a fresh venv with the core and `itc/` installed in editable mode: app name
`atomize-itc`, `ROOT_DIR` = `itc/`, both `atomize` folders joined, `python -m atomize` resolves to the
station's `main.py`; station `pytest tests` 200 passed, 0 failed; `epr-auto run
protocols/tune_up.yaml --test` 6/6 steps; the three `epr_auto` Insys checks pass and `libs/exam_*.ini`
stay unchanged; the main window opens with the EPR Endstation Control tab and `itc/libs/` as working
folder; plain `pytest` 197 passed. File check: core + `itc/` = `Atomize_ITC` apart from exactly the
changes listed above.

Phase 3 (scratch copies of the core, the station and today's `Atomize_ITC`, each with an empty
temporary home folder, so no real config was touched): a first start copies `config.ini` and 64
device configs (53 core + 11 ITC) identical to what `Atomize_ITC` copies; all 14 control-center tools
the endstation tab starts open without errors, as in `Atomize_ITC` (the 4 `*_preset_insys.py` that
`main.py` still names are `###unused` and missing in both); one script per experiment type passes in
test mode from `libs/`, as the main window starts them (DEER, 3P-ESEEM, nutation, T2, CPMG, THz), same
as `Atomize_ITC`; station `pytest tests` 200 passed with and without a user config, after
`test_tr_two_fields.py` got its own temporary user config. The station's `config.ini` still has
`script_dir = /home/fel2/sources/Atomize_ITC/atomize/tests`, a folder that does not exist today either.

If `Atomize_ITC` changes before Phase 4, copy those files into `itc/` by hand (the changed spots
above must stay).

Next, in order:

1. Push `Atomize` `e16ea36` and `Atomize_stations` `c67f565`.
2. Phase 5: a week of normal use; the hardware checks left open in Phase 4 D.

Decisions made: station repo `Atomize_stations`, fresh history, branch `main`; `atomize-itc`
starts at 0.5.0; this roadmap lives in `itc/docs/stations/`; `python -m atomize` opens the station's
window when one is installed; `Keysight_2000_Xseries_2.py` stays a station device;
`PB_Insys_DAC_config.ini` and the Sibir curve are read from the user copy; ITC uses plain's
`last_dir.py` (remembered folders now live in the user config folder, so they reset once). On the
spectrometer PC only `~/sources/Atomize_ITC` exists (no plain Atomize, no `atomize_sync`).

To continue, open Claude Code in `Atomize_stations/itc` and say: "Continue the station migration
from `docs/stations/ROADMAP.md`, Resume here."

## ITC2 station (2026-11-16)

`itc2/` is the CW/TR EPR spectrometer on the PC `itc22` (`itc22@192.168.2.20`, no internet). It was
built from `itc/` plus what that PC ran from `~/Atomize_ITC` (branch `cw-setup`, `4ac0277`, local
commits on top of `f4578be`): its `cw_control.py` (SR-830, ITC_FC, this setup's BDPA and NMR
numbers), its `config.ini`, `ITC_FC_config.ini` and `SR_830_config.ini`. App name and command
`atomize-itc2`, package `atomize-itc2`; `docs/stations/` is not copied. The PC's ITC_FC PID set and
the Sibir_1 register read (from its branch `backup/local-setup-2026-11-02`) went into the core.
The PC's pulser configs (`PB_*`) in its user copy are old and not in use, so `itc2/` keeps `itc/`'s.

On the PC: core and stations cloned from bundles into `~/sources/`, installed with `pip --user`
(editable, `--no-deps`, build tools from wheels in `~/sources/wheels`); PyQt6 6.4.2 → 6.12.1
from wheels (6.4.2 kept in `~/sources/wheels/qt642`), pyqtgraph stays 0.13.1; core and station
`pytest` pass there. `~/.config/atomize-itc` copied to `~/.config/atomize-itc2`; desktop launcher
installed. The old setup (`~/Atomize`, `~/Atomize_ITC`, the backups, `~/pyqtgragh`) is archived in
`~/sources/old_setup_backup_2026_11_16.tar.gz`; `~/Atomize_ITC` is untouched.

## Goal

- **`Atomize`** stays the public core, with no station code.
- **One station repo** (`Atomize_stations`) holds ITC, NIOCH, NIOCH_Q and Cryomech,
  each in its own folder, installed on top of the core.
- No copies of the core in the stations, so nothing to sync from plain.
- ITC moves first. The other stations follow the same recipe.

## Design in short

- Each station folder keeps today's layout: `itc/atomize/control_center/`, `itc/atomize/epr_auto/`,
  `itc/atomize/main/main.py`, `itc/libs/`, `itc/protocols/`, `itc/icons/`, `itc/tests/`, `itc/docs/`.
- The station's files join the core under the same `atomize` name. Import lines, protocol files,
  user scripts and the `gui_vs_engine.py` harness therefore stay as they are.
- A box installs the core and its own station folder. That install is what tells the box which
  station it is.
- The app name stays `atomize-itc`, so the user configs on the box are found and left untouched.

## Open decisions

- [x] Name of the station repo: `Atomize_stations`.
- [x] History: start fresh; the old history stays in the archived repos.
- [x] Where this roadmap lives after the move: `itc/docs/stations/` in the new repo.

## Phase 1 — Prepare plain Atomize

Small changes, invisible to a general user. Done and committed 2026-11-15 (`Atomize` `b5716b8`). `pytest tests` gives 9 failed / 178 passed both before and after; the 9 are old failures
in `tests/test_liveplot_runs.py`.

- [x] Lift what ITC leads on into plain: `documentation/functions/awg.md` and `digitizer.md`.
      `Keysight_2000_Xseries_2.py` stays a station device; the differing `script_examples/` and
      `tests/` stay with the station.
- [x] Let an installed station add its folders to `atomize` and to `atomize.device_modules`
      (one line in each `__init__.py`).
- [x] A station declares itself with a small `atomize/station.py` holding its app name. The core
      takes the app name and the station folder from it, otherwise `atomize-py` and its own folder
      (`local_config.py`, `last_dir.py`). ITC then uses plain's `last_dir.py`.
- [x] Runtime files (`libs/`, `bridge.param`, `libspinapi.so`, the Liveplot layout) are looked up in
      the station folder: `Insys_FPGA.py`, `Micran_X_band_MW_bridge_v2.py`, `insys_status.py`,
      `spinapi.py`, `main_window.py`. Without a station the places are today's.
- [x] `Insys_FPGA.py` reads `PB_Insys_DAC_config.ini` from the user copy, like every other config.
      Before, it read the copy in the code folder, which in the new layout would be plain's,
      without ITC's I/Q tables.
- [x] First-start copy of configs and example scripts: core defaults first, then the station's own
      files on top.
- [x] Each fork has an `atomize/station.py` with its app name and plain's `local_config.py`;
      `sync_check.py` treats `local_config.py` and `atomize/__init__.py` as plain-led and
      `station.py` as per fork. Not yet synced: `--sync -n` lists the same 7 files for each fork.
- [x] Before syncing ITC: the three `epr_auto` check scripts (`insys_ini_checks.py`,
      `live_rate_worker_checks.py`, `live_rate_driver_checks.py`) redirect `lconf.ROOT_DIR`
      instead of `insys.__file__`. The DAC config is only read, so it needs no redirect.
      `awg_phasing_insys.py` also found `libs/exam_adc.ini` through the driver's folder; it now
      uses `lconf.ROOT_DIR` too.
- [x] Version becomes 0.5.0.
- [x] Check: plain alone works as before (`pytest tests`, three scripts in test mode, the main
      window opens, configs still under `atomize-py`), and a made-up station joins correctly.

## Phase 2 — Build the station repo with the ITC folder

- [x] Create the repo and the `itc/` folder with its own `pyproject.toml`
      (name `atomize-itc`, commands `atomize-itc` and `epr-auto`, needs `atomize-py>=0.5` and `pyyaml`).
- [x] Move in everything ITC-only: `control_center/`, `epr_auto/`, `main/main.py`,
      `main/protocol_launcher.py`, `libs/`, `general_modules/libspinapi.so`, `protocols/`, `icons/`,
      `docs/`, the ITC-only `script_examples/` and `tests/`, `CLAUDE.md`, `AGENTS.md`, `.claude/agents/`.
- [x] Station config files: the 9 device configs that differ from plain, `config.ini`, the Sibir
      calibration curve.
- [x] `atomize/station.py` with the app name `atomize-itc`.
- [x] The station states the lowest core version it accepts and says so clearly at start if the
      core is older.
- [x] `python -m atomize` ran the core's `atomize/__main__.py` (plain window, no endstation tab).
      Decided: the core's `__main__.py` starts the station's window when one is installed.
- [x] `main.py`: point the working folder at the station's own `libs/` (today's `ptm = '../../libs'`
      would land in the core folder).
- [x] The Sibir calibration curve was read from the core's config folder by `ITC_FC.py`; it is now
      read from the user copy.
- [x] `math_modules/tests/test_preset_loader.py` needs the presets folder: moved to `itc/tests/`.
- [x] Leave out every file that is the same as in plain.
- [x] `epr_auto/params.py` and `epr_auto/cli.py` found the presets and `libs/` through
      `atomize.__file__` (the core folder after the split); they now look in the station.

## Phase 3 — Check on the development machine

- [x] Fresh environment, install the core and `itc/`.
- [x] File check: core + `itc/` together give the same files as today's `Atomize_ITC`, apart from a
      short expected list.
- [x] `pytest` passes.
- [x] `atomize-itc` opens with the endstation tab; every control-center tool opens.
- [x] One script per experiment type passes in test mode.
- [x] `epr-auto run protocols/tune_up.yaml --test` passes.
- [x] A fresh start with no user configs copies the right ITC values.

## Phase 4 — Spectrometer PC

Done 2026-11-17, with a venv instead of `pip --user` (see "Resume here"). Old install was Atomize_ITC
`b07a09d`, already contained in `itc/`. Items left open are marked so.

**A. Record and back up**

- [x] Close Atomize and all control-center windows (nothing was running).
- [x] `git status`: local edits were the three runtime `*.param` files and `BH_15.py`
      `max_set_retries = 1`; the latter became a config key (core `e16ea36`).
- [x] Old install: editable user-site `atomize-itc` 0.0.0 plus a stale `Atomize.egg-link`, both
      pointing at `~/sources/Atomize_ITC`; started with the `atom` alias.
- [ ] Reference results: `gui_vs_engine.py` is not on the box; no standard echo was recorded.
- [x] `PB_Insys_DAC_config.ini`: the user copy is identical to the repo copy and holds the I/Q tables.
- [x] Back up the user configs: in `~/sources/old_setup_backup_2026_11_17.tar.gz`.
- [x] Back up the local files kept inside the repo folder (only `*.param` and `*_lastdir.txt`
      existed; no presets, `protocols/tuned/`, `protocols/runs/` or Liveplot layout):

      ```bash
      cd ~/sources/Atomize_ITC
      git ls-files --others --modified | grep -v __pycache__ | sort -u > ~/itc_local_files.txt
      rsync -a --files-from=$HOME/itc_local_files.txt . ~/itc_local_backup/
      ```

      This covers the `*.param` files, `libs/status`, the Liveplot layout, saved presets in
      `atomize/epr_auto/presets/`, `protocols/tuned/` and `protocols/runs/`.

**B. Install**

- [x] `pip uninstall atomize-itc` (user site), done last, after the operator checks.
- [x] Core and station cloned from bundles to `~/sources/Atomize` and `~/sources/Atomize_stations`,
      installed editable into `~/sources/atomize_venv` from wheels.
- [x] I/Q tables: already in the user copy, nothing to copy.
- [x] Sibir curve: already in `~/.config/atomize-itc/device_config/`.
- [x] Local files back: the `*.param` and `*_lastdir.txt` files copied into `itc/`.
- [x] Desktop launcher and icons, run with the venv's `bin/` first on `PATH`.
- [x] `gui_vs_engine.py`: not on the box.

**C. Checks without hardware**

- [x] `atomize-itc` starts with the endstation tab; `ROOT_DIR` is `itc/`, working folder `itc/libs`.
- [x] User configs unchanged apart from the intended `max_set_retries = 1`.
- [x] Test mode from `libs/`: T2, DEER, T1/T2/Rabi vs field, HYSCORE pass.
- [x] `epr-auto run --test`: all 8 protocols in `protocols/` run every step.
- [ ] `pytest`: not run on the box (pytest is not in the venv).

**D. Checks with hardware (operator present)**

- [x] CW, TR and pulsed mode work (operator, 2026-11-17).
- [ ] Open each remaining tool once: MW bridge, field, temperature, tune preset, RECT phasing,
      AWG phasing, TR scopes.
- [ ] The standard echo matches a reference (none was recorded in step A).
- [ ] Live edit works in the AWG phasing tool.
- [ ] One short protocol runs live from the launcher.

**Going back** (not tried)

```bash
cd ~/sources && tar xzf Atomize_ITC_archive_2026_11_17.tar.gz
python3 -m pip install --user --no-deps --no-index --find-links ~/sources/wheels -e ~/sources/Atomize_ITC
```

Then point the `atom` and `epr` aliases in `~/.bashrc` back at `atomize-itc` and `epr-auto`. The user
configs are the same folder in both setups; copy back any `*.param` changed in the meantime.

## Phase 5 — Settle ITC

- [ ] One week of normal use on the new setup.
- [ ] Repeat the install on the Windows development machine (`python`, test mode only).
- [ ] `sync_check.py` (development machine): ITC leaves the list of forks; it stays the source for the shared
      control-center tools of NIOCH and NIOCH_Q, read from `Atomize_stations/itc/`.
- [ ] Archive `Atomize_ITC` on GitHub (read-only) with a readme line pointing to the new repo.
- [ ] Update install instructions in `atomize_docs` where they mention the ITC repo.

## Phase 6 — Later

- [ ] NIOCH_Q, NIOCH and Cryomech, each with Phases 2–5. Device differences: values go to config
      files, station behaviour goes to a small extension in the station folder.
- [ ] Merge the control-center tools that exist in several versions, one at a time when touched.
- [ ] Archive `atomize_sync` once the last station has moved.
