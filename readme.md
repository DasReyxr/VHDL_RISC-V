# VHDL RISC-V Releases

This repository contains three release snapshots of the same 8-bit RISC-style CPU core, each focused on a different development stage.
## Architecture
This is a RISC-V Based on the demands of the project, the architecture is a simple 8-bit RISC-V core with a 16-bit address space. It includes a basic instruction set and is designed for educational purposes and FPGA implementation.
![Architecture](Microprocessor-1.png)

## Folder layout

```text
Release/
	0RISCV.vhd
	0RISCV_cf.cst
	1Virtual_RISCV.vhd
	1Virtual_RISCV_cf.cst
	2RISCV_Speed.vhd
	2RISCV_Speed_cf.cst
```

Each VHDL top file has a matching Gowin constraint file with the same prefix.

## Quick comparison

| Release | Main focus | ROM source | Speed control | Debug output | Recommended use |
|---|---|---|---|---|---|
| `0RISCV` | Early/base snapshot | Intended external ROM flow (see notes) | `B1UP/B2DOWN` present, `CLKS <= not CLK` in current file | `P_DEBUG` enabled | Historical reference / legacy baseline |
| `1Virtual_RISCV` | Self-contained virtual platform | Internal `VROMIN` constant table | Fixed divided clock (`CLKS <= C(20)`) | `P_DEBUG` enabled | Fast bring-up and simulation without external ROM |
| `2RISCV_Speed` | Board-oriented speed tuning | External `ROMIN` input | Runtime selectable speed using `B1UP/B2DOWN` and `CLKS <= c(VALORA)` | `P_DEBUG` commented out in entity | FPGA runs where manual speed stepping/tuning is needed |

## Release details

### 0RISCV

- First public baseline for this branch.
- Includes button inputs (`B1UP`, `B2DOWN`) and debug bus (`P_DEBUG`).
- Uses virtual RAM array (`VRAMIN`) for data memory behavior.
- Current snapshot keeps many references to `ROMIN` in logic while the `ROMIN` port is commented in the entity declaration.

Note:

- If you want to compile this release as-is, you may need to restore the `ROMIN` port or provide an internal ROM signal implementation.

### 1Virtual_RISCV

- Virtual/programmed variant for easy testing.
- Implements internal instruction ROM with a constant memory table:
	- `constant VROMIN : MEMORY := (...)`
	- `ROMIN <= VROMIN(to_integer(S_PCIN));`
- Keeps `P_DEBUG` available.
- Removes dependency on an external ROM bus.

Best for:

- Functional validation.
- Running preloaded instruction sequences quickly.

### 2RISCV_Speed

- Performance/interactive variant aimed at hardware demos.
- Uses external `ROMIN` port again.
- Adds adjustable execution speed:
	- `B1UP` increases divider index.
	- `B2DOWN` decreases divider index.
	- CPU clock is selected with `CLKS <= c(VALORA);`
- `P_DEBUG` is commented out in the port list in this release.

Best for:

- Board testing with live speed control.
- Visual demos where slower stepping is useful.

## Constraint files (CST)

- `0RISCV_cf.cst`: includes ROM input pin mapping plus debug and button pins.
- `1Virtual_RISCV_cf.cst`: no active ROM pin mapping (fits virtual ROM design), keeps debug/button mappings.
- `2RISCV_Speed_cf.cst`: ROM pin block is present but commented in this snapshot; debug mappings are still listed.

## Which release should you use?

- Use `1Virtual_RISCV` when you want the easiest simulation and no external ROM dependencies.
- Use `2RISCV_Speed` when running on FPGA hardware with external ROM and adjustable CPU speed.
- Keep `0RISCV` as historical baseline unless you plan to clean and align its ROM interface.

## Build/synthesis tip

In Gowin, keep the VHDL and CST from the same release pair to avoid port/pin mismatches.
