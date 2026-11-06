#!/usr/bin/env bash
#
# setup-hibernate.sh — configure hibernation to a swapfile.
#
# Supports: Debian derivatives with an ext4 root, GRUB, and initramfs-tools.
# Idempotent: re-running with everything already in place changes nothing.
#
# Usage: sudo ./setup-hibernate.sh [--dry-run]

set -Eeuo pipefail

readonly SWAPFILE=/swapfile
readonly GRUB_DROPIN=/etc/default/grub.d/99-hibernate.cfg
readonly GRUB_CFG=/boot/grub/grub.cfg
readonly RESUME_CONF=/etc/initramfs-tools/conf.d/resume
readonly FREE_MARGIN_BYTES=$((1024 ** 3))
readonly EFIVARS=/sys/firmware/efi/efivars
readonly EFI_SB_VAR=$EFIVARS/SecureBoot-8be4df61-93ca-11d2-aa0d-e0f6c3e2d3a3

DRY_RUN=0

on_err() {
	local rc=$?
	echo "Error on line $1 (exit $rc)" >&2
}
trap 'on_err $LINENO' ERR

die() { echo "Error: $*" >&2; exit 1; }
warn() { echo "Warning: $*" >&2; }
info() { echo "==> $*"; }

usage() {
	cat <<EOF
Usage: sudo $(basename "$0") [--dry-run]

Creates $SWAPFILE (RAM + 10%) and configures GRUB and initramfs-tools
to resume from it.

  --dry-run   Print what would change without changing anything.
  -h, --help  Show this help.
EOF
}

parse_args() {
	while (($#)); do
		case $1 in
		--dry-run) DRY_RUN=1 ;;
		-h | --help) usage; exit 0 ;;
		*) usage >&2; die "Unknown argument: $1" ;;
		esac
		shift
	done
}

# Run a command, or print it in dry-run mode.
run() {
	if ((DRY_RUN)); then
		echo "[dry-run] $*"
	else
		"$@"
	fi
}

# write_if_changed <path> <content>
# Returns 0 if the file was (or would be) written, 1 if already up to date.
write_if_changed() {
	local path=$1 content=$2
	if [[ -f $path && "$(<"$path")" == "$content" ]]; then
		return 1
	fi
	if ((DRY_RUN)); then
		echo "[dry-run] write $path:"
		printf '    %s\n' "${content//$'\n'/$'\n    '}"
	else
		mkdir -p "$(dirname "$path")"
		printf '%s\n' "$content" >"$path"
	fi
	return 0
}

check_secure_boot() {
	if [[ ! -d /sys/firmware/efi ]]; then
		info "Legacy BIOS boot; Secure Boot check passes"
		return
	fi
	mountpoint -q "$EFIVARS" || die "$EFIVARS is not mounted; cannot verify Secure Boot state"
	if [[ ! -r $EFI_SB_VAR ]]; then
		info "Firmware has no Secure Boot variable; Secure Boot check passes"
		return
	fi
	# First 4 bytes are attributes; the 5th is the value (1 = enabled).
	local state
	state=$(od -An -t u1 -j4 -N1 "$EFI_SB_VAR" | tr -d ' ')
	[[ $state != 1 ]] || die "Secure Boot is enabled; kernel lockdown blocks hibernation"
}

preflight() {
	((EUID == 0)) || die "Must be run as root (also required for --dry-run)"

	local cmd
	for cmd in findmnt filefrag fallocate mkswap swapon mountpoint od df getconf update-grub update-initramfs; do
		command -v "$cmd" >/dev/null || die "Required command not found: $cmd"
	done
	[[ -d /etc/initramfs-tools ]] || die "initramfs-tools not found"

	local fstype
	fstype=$(findmnt -no FSTYPE /)
	[[ $fstype == ext4 ]] || die "Root filesystem is $fstype; only ext4 is supported"

	check_secure_boot
}

# RAM + 10%, rounded up to a whole GiB.
swap_size_gib() {
	local mem_kib
	mem_kib=$(awk '$1 == "MemTotal:" { print $2 }' /proc/meminfo)
	[[ $mem_kib =~ ^[0-9]+$ ]] || die "Could not read MemTotal from /proc/meminfo"
	local divisor=$((10 * 1024 * 1024))
	echo $(((mem_kib * 11 + divisor - 1) / divisor))
}

ensure_swapfile() {
	local size_gib=$1
	if [[ -e $SWAPFILE ]]; then
		info "$SWAPFILE already exists; using it as-is"
		return
	fi

	local need avail
	need=$((size_gib * 1024 ** 3 + FREE_MARGIN_BYTES))
	avail=$(df -B1 --output=avail / | tail -n1 | tr -d ' ')
	((avail >= need)) ||
		die "Not enough free space on /: need $((need / 1024 ** 3))G (swapfile + 1G margin), have $((avail / 1024 ** 3))G"

	info "Creating ${size_gib}G swapfile at $SWAPFILE"
	run fallocate -l "${size_gib}G" "$SWAPFILE"
	run chmod 600 "$SWAPFILE"
	run mkswap "$SWAPFILE"
}

ensure_swap_active() {
	local active
	active=$(swapon --show=NAME --noheadings)
	if grep -qxF "$SWAPFILE" <<<"$active"; then
		info "$SWAPFILE is already active"
		return
	fi
	run swapon "$SWAPFILE"
}

ensure_fstab() {
	if grep -qE "^[[:space:]]*${SWAPFILE}[[:space:]]" /etc/fstab; then
		info "$SWAPFILE is already in /etc/fstab"
		return
	fi
	local line="$SWAPFILE none swap sw 0 0"
	if ((DRY_RUN)); then
		echo "[dry-run] append to /etc/fstab: $line"
	else
		printf '%s\n' "$line" >>/etc/fstab
	fi
}

# Physical offset of the swapfile's first extent, in kernel pages (the unit resume_offset expects).
swap_offset() {
	if [[ ! -e $SWAPFILE ]]; then
		# Only reachable in dry-run, before the file exists.
		echo "<offset>"
		return
	fi
	local page_size offset
	page_size=$(getconf PAGESIZE)
	# Fields: "0:" "<logical_start>.." "<logical_end>:" "<physical_start>.." ...
	offset=$(filefrag -v -b"$page_size" "$SWAPFILE" |
		awk '$1 == "0:" && !done { sub(/\.\.$/, "", $4); print $4; done = 1 }')
	[[ $offset =~ ^[0-9]+$ ]] || die "Could not determine resume offset for $SWAPFILE"
	echo "$offset"
}

configure_grub() {
	local uuid=$1 offset=$2

	if grep -qE '^[^#]*resume(_offset)?=' /etc/default/grub; then
		warn "/etc/default/grub already sets resume parameters; $GRUB_DROPIN is applied after it and takes precedence"
	fi

	# \$GRUB_CMDLINE_LINUX_DEFAULT stays literal: GRUB expands it when sourcing the drop-in.
	local content="GRUB_CMDLINE_LINUX_DEFAULT=\"\${GRUB_CMDLINE_LINUX_DEFAULT:-} resume=UUID=$uuid resume_offset=$offset\""

	if write_if_changed "$GRUB_DROPIN" "$content" ||
		! grep -qF "resume=UUID=$uuid" "$GRUB_CFG" 2>/dev/null ||
		! grep -qF "resume_offset=$offset" "$GRUB_CFG" 2>/dev/null; then
		run update-grub
	else
		info "GRUB is already configured"
	fi
}

# The offset is supplied via the kernel command line (resume_offset=), not here.
configure_initramfs() {
	local uuid=$1
	local content="RESUME=UUID=$uuid"

	if write_if_changed "$RESUME_CONF" "$content"; then
		run update-initramfs -u -k all
	else
		info "initramfs resume config is already up to date"
	fi
}

main() {
	parse_args "$@"
	((DRY_RUN)) && info "Dry run: no changes will be made"

	preflight

	local size_gib
	size_gib=$(swap_size_gib)
	info "Target swapfile size: ${size_gib}G (RAM + 10%)"

	ensure_swapfile "$size_gib"
	ensure_swap_active
	ensure_fstab

	local root_uuid offset
	root_uuid=$(findmnt -no UUID /)
	[[ -n $root_uuid ]] || die "Could not determine root filesystem UUID"
	offset=$(swap_offset)
	info "Resume device: UUID=$root_uuid, offset=$offset"

	configure_grub "$root_uuid" "$offset"
	configure_initramfs "$root_uuid"

	info "Done. Reboot, then test with: systemctl hibernate"
}

main "$@"
