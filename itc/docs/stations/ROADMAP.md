# Two repos instead of five — roadmap

Created 2026-11-15. Status: Phases 1 to 4 done (spectrometer PC on 2026-11-17, updated to itc 0.6.0 on 2026-11-18); Phase 5 is next. This file moved here
from `Atomize_ITC/docs/stations/`.

## Resume here

State on 2026-11-18: the spectrometer PC runs itc 0.6.0 with `Atomize_treatment` 0.1.0 (core
`a219ec8`, stations `4306762`, treatment `9e768eb`); see "Update to itc 0.6.0" in Phase 4.

State on 2026-11-17: the spectrometer PC (`fel2@192.168.2.1`, Ubuntu 22.04, Python 3.10, no internet)
runs the new setup; CW, TR and pulsed mode work. Core `Atomize` `e16ea36` (BH_15 `max_set_retries`
read from the config) and `Atomize_stations` `c67f565` (CW defaults 10 ms / 50 mV) are on the PC and
on GitHub. Details in Phase 4 below.

- Install: venv `~/sources/atomize_venv`, created `--without-pip` (the box has no `python3-venv`);
  pip, build tools and all packages from wheels in `~/sources/wheels` (PyQt6 6.12.1, numpy 2.2.6,
  scipy 1.15.3, pyqtgraph 0.14.0). Core and station editable from `~/sources/Atomize` and
  `~/sources/Atomize_stations`, cloned from bundles in `~/sources/bundles`. The linux-gpib binding
  stays in `/usr/local`; `linux_gpib.pth` in the venv points at it.
- `.bashrc`: `atom` and `epr` start the venv's `atomize-itc` and `epr-auto run`; `atom-pull` pulls
  the three repos from GitHub (`Atomize_treatment` added 2026-11-18) (`origin` = the public HTTPS URLs; the PC needs a network connection). The desktop launcher points at the venv.
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
- The shared data treatment tools now live in `Atomize_treatment` (see below). Do not run
  `sync_check.py --sync-cc` any more: NIOCH and NIOCH_Q keep their copies until they move.

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

1. Phase 5: a week of normal use; the hardware checks left open in Phase 4 D.

Decisions made: station repo `Atomize_stations`, fresh history, branch `main`; `atomize-itc`
starts at 0.5.0; this roadmap lives in `itc/docs/stations/`; `python -m atomize` opens the station's
window when one is installed; `Keysight_2000_Xseries_2.py` stays a station device;
`PB_Insys_DAC_config.ini` and the Sibir curve are read from the user copy; ITC uses plain's
`last_dir.py` (remembered folders now live in the user config folder, so they reset once). On the
spectrometer PC only `~/sources/Atomize_ITC` exists (no plain Atomize, no `atomize_sync`).

To continue, open Claude Code in `Atomize_stations/itc` and say: "Continue the station migration
from `docs/stations/ROADMAP.md`, Resume here."

## ITC2 station (2026-11-16)

`itc2/` is the CW/TR EPR spectrometer on the PC `itc22` (`itc22@192.168.2.20`, offline in normal use;
it can be connected to the internet for updates). It was
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

Update on 2026-11-18 (to itc2 0.6.0 with `Atomize_treatment`): before, the PC had `Atomize`
`01d00a7` and `Atomize_stations` `9d7cfb1`, both clean (`atomize-py` 0.5.0, `atomize-itc2` 0.5.0).
Backups in `~/sources/backup_2026_11_18/`: the state, the ignored files of `itc2/` (`*.param`,
`libs/*lastdir.txt`, `liveplot_layout.txt`), `~/.config/atomize-itc2` and the desktop launchers.
Full bundles of the three repos are in `~/sources/bundles/` (with `SHA256SUMS`); `Atomize` and
`Atomize_stations` fast-forwarded from them to `a219ec8` and `766aadf` (the PC's `origin/main` was a
stale ref to `183f666`, an earlier version of the ITC2 commit, and was reset to the bundle's `main`),
`Atomize_treatment` `9e768eb` cloned into `~/sources/` (`origin` = the GitHub URL). Installed with
`python3 -m pip install --user --no-deps --no-index --find-links ~/sources/wheels -e`:
`atomize-treatment` 0.1.0, then `itc2` again (0.6.0); h5py, platformdirs and scipy were already
there, Julia is not (the Makie renderer stays unavailable, as before). Checks on the PC: core
`pytest tests` 188 passed, 4 skipped; station `pytest tests` 200 passed; `atomize-itc2` starts; in the
main window (offscreen) the tab shows "Version 0.6.0", the six Analysis buttons have icons and each
starts its `atomize.treatment` tool; a 1D (two curves) and a 2D plot sent by a script through
LivePlot reach Data Treatment and Data Treatment 2D with "Send to Data Treatment", with their axes.
The buffers are in `~/.config/atomize-itc2/treatment/`; the user config is otherwise unchanged.
`atomize_docs` is not on this PC.

Updates from then on: `atom-pull` (alias in `~/.bashrc`, runs `~/sources/atom-pull.sh`; a copy is
`atom-pull-itc22.sh` next to this file). With the PC on the internet, `atom-pull` fetches `Atomize`
(`master`), `Atomize_treatment` and `Atomize_stations` (`main`) from GitHub; offline, `atom-pull
bundles` takes `<repo>.bundle` from `~/sources/bundles` (`atom-pull <folder>` from another folder),
made on the laptop with `git bundle create <repo>.bundle --all` (an optional `SHA256SUMS` there is
checked). Only fast-forwards; a repo with local edits or commits is left alone and reported. A repo
whose `pyproject.toml` changed (`itc2/pyproject.toml` for the station) is reinstalled with the same
`pip --user --no-deps --no-index --find-links ~/sources/wheels -e`; a missing repo is cloned and
installed. It refuses to run while Atomize is open. Tested from the bundles on the PC (all up to date)
and in a scratch copy on the laptop (old heads → fast-forward, treatment cloned and installed, itc2
reinstalled, a local edit stops the update); the GitHub path failed cleanly because the PC was offline,
and is untried online. Push to GitHub before an online `atom-pull`. The old `~/.bashrc` is in
`~/sources/backup_2026_11_18/bashrc`. `atom` on this PC is not Atomize (`fsc at`).

## Data treatment tools: `Atomize_treatment` (2026-11-18)

The seven shared tools (`data_treatment`, `data_treatment_2d`, `deer_analysis`, `header_view`,
`excitation_profile`, `sequence_calculator`, `spin_dynamics_sim`), their icons and the Makie renderer
moved to the separate repo `Atomize_treatment` (package `atomize-treatment` 0.1.0,
`https://github.com/Anatoly1010/Atomize_treatment`). The core stays without them; a station lists the
package as a dependency. Like a station, it joins the core's `atomize` name, as `atomize/treatment/`.

Changed against the station copies:

- The plot buffers moved from `libs/` to `<user config>/treatment/`, the last-used folders to
  `<user config>/lastdir/` (`atomize/treatment/paths.py`); the tools' remembered folders reset once.
- `sequence_calculator`: the default grid comes from `seqcalc_grid` in the station's `station.py`,
  3.2 ns without it (NIOCH needs 2.0, NIOCH_Q 4.0 when they move).
- `spin_dynamics_sim` opens the station's `control_center/experiments/` when there is one.
- The Makie renderer is in `atomize/treatment/makie/` (was the station's `script_examples/makie/`).
- Commands `atomize-treatment`, `atomize-treatment-2d`, `atomize-deer`, `atomize-seqcalc`,
  `atomize-excitation`, `atomize-spin-sim` start the tools without the main window.

`itc/` and `itc2/` 0.6.0: the main window starts the tools with `python -m atomize.treatment.<tool>`,
takes their button icons from the package, and "Send to Data Treatment" writes the buffers named in
`atomize.treatment.paths`; the station copies are removed; new dependency `atomize-treatment>=0.1`.

Checks on the laptop: all six tools open with only the core installed and with the ITC station;
they start from the main window buttons, all with icons; a 1D and a 2D plot sent with the station's
code arrive in the tools; the sequence calculator self-test passes; station `pytest` 200 passed for
`itc/` and `itc2/`, core `pytest` 187 passed.

On the spectrometer PCs, together with the next pull (without it the treatment buttons fail, the
rest works): clone `Atomize_treatment` from a bundle into `~/sources/`, install it editable the
way the station is installed there (fel2: into `~/sources/atomize_venv`; itc22: `--user --no-deps`),
with `--no-index --find-links ~/sources/wheels`, then reinstall the station the same way (0.6.0).
Add the repo to `atom-pull` on fel2. Done on itc22 on 2026-11-18, where `atom-pull` is new and also
reads bundles (see ITC2 station), and on fel2 the same day (Phase 4, "Update to itc 0.6.0").

NIOCH and NIOCH_Q keep their own copies (last mirrored from `Atomize_ITC`); edits made in
`Atomize_treatment` reach them when they move into `Atomize_stations` (Phase 6).

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

**Update to itc 0.6.0 with `Atomize_treatment` (2026-11-18)**

- Before: `Atomize` `e16ea36`, `Atomize_stations` `467aad0`, both fast-forwardable;
  `atomize-py` 0.5.0 and `atomize-itc` 0.5.0 in the venv. Local edits: `bridge.param`,
  `digitizer_insys.param`, `field.param` and `libs/exam_adc.ini` (`streamBufSizeKb` auto-adjusted to
  128; set back to the repo's 1024 as the user asked). Atomize was not running.
- Backups in `~/sources/backup_2026_11_18/`: `state.txt` (heads, status, `pip list`), the
  local diff, the local and ignored files of the repo (`*.param`, `libs/*_lastdir.txt`,
  `exam_adc.ini`), `~/.config/atomize-itc`, `.bashrc` and the desktop entries.
- The PC was offline (no DNS for github.com), so full bundles of the three repos went to
  `~/sources/bundles/` (with `SHA256SUMS`); the 2026-11-17 bundles are in `bundles/2026_11_17/`.
  `Atomize` and `Atomize_stations` fast-forwarded from them to `a219ec8` and `4306762` (`origin/*`
  set to the bundle's branch); `Atomize_treatment` `9e768eb` cloned into `~/sources/`
  (`origin` = the GitHub URL). The `.param` edits are kept.
- Installed into the venv with `pip install --no-index --find-links ~/sources/wheels -e`:
  `atomize-treatment` 0.1.0, then `itc` again (0.6.0); every dependency was already there;
  `pip check` clean. The `atom-pull` alias now also pulls `~/sources/Atomize_treatment`. It is still
  a plain `git pull --ff-only` per repo: it does not read bundles or reinstall on a `pyproject.toml`
  change, unlike itc22's `atom-pull.sh`.
- Checks on the PC: `atomize-itc` starts; in the main window (offscreen, from `itc/libs`) the
  EPR Endstation Control tab shows "Version 0.6.0; 18/11/2026"; the six Analysis buttons have icons
  and each starts its `atomize.treatment` tool, still running after 6 s; a 1D plot (two curves,
  axis "Time (s)") and a 2D plot (axes Time s / Field G, its start and step) sent by a script through
  LivePlot reach Data Treatment and Data Treatment 2D with "Send to Data Treatment" (the tools
  read and consume the buffers); `~/.config/atomize-itc` unchanged apart from the new
  `treatment/` folder, `max_set_retries = 1` still in `BH_15_config.ini`; `epr-auto run --test`:
  all 8 protocols in `protocols/` run every step. `pytest` is still not in the venv.
- The six `atomize-<tool>.desktop` icon entries for the treatment tools are `Exec=false` (icons
  only) and stay as they were; `itc/icons` did not change.
- Seen on the PC: `main_config.ini` still names `~/sources/Atomize_ITC/atomize/script_examples`
  as the scripts folder, which was archived on 2026-11-17 (left as it is). The operator used Atomize
  from the desktop launcher during the update (a session closed at 14:48, after the install); the
GUI check and the protocol tests were repeated with Atomize closed, same results. That session wrote
`digitizer_insys.param` back to the repo's version (the old one is in the backup).
- Back to 0.5.0 (not tried): `git -C ~/sources/Atomize reset --hard e16ea36`,
  `git -C ~/sources/Atomize_stations reset --hard 467aad0` (commit or stash the `.param` edits
  first), reinstall `itc` the same way, `pip uninstall atomize-treatment`, `.bashrc` from the backup.

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
- [ ] `sync_check.py` (development machine): ITC leaves the list of forks; `--sync-cc` goes, since
      the shared tools now live in `Atomize_treatment`.
- [ ] Archive `Atomize_ITC` on GitHub (read-only) with a readme line pointing to the new repo.
- [ ] Update install instructions in `atomize_docs` where they mention the ITC repo.

## Phase 6 — Later

- [ ] NIOCH_Q, NIOCH and Cryomech, each with Phases 2–5. Device differences: values go to config
      files, station behaviour goes to a small extension in the station folder.
- [ ] Merge the control-center tools that exist in several versions, one at a time when touched.
- [ ] Archive `atomize_sync` once the last station has moved.
