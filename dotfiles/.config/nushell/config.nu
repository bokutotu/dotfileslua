$env.config.buffer_editor = "nvim"
$env.VISUAL = "nvim"
$env.EDITOR = "nvim"
alias vi = nvim

use std/util "path add"
if ("/run/current-system/sw/bin" | path exists) { path add "/run/current-system/sw/bin" }
path add "/nix/var/nix/profiles/default/bin"
let user_profile = $nu.home-path | path join ".nix-profile" "bin"
if ($user_profile | path exists) { path add $user_profile }

$env.PROMPT_COMMAND = {||
  let color_reset  = (ansi reset)
  let color_path   = (ansi cyan_bold)
  let color_branch = (ansi green_bold)
  let color_py     = (ansi magenta_bold)
  let color_nix    = (ansi yellow_bold)

  let cwd_raw = (pwd)
  let home    = $nu.home-path
  let cwd_rel = ($cwd_raw | str replace $home "~")
  let segs    = ($cwd_rel | split row "/")
  let show_path = if (($segs | length) > 4) {
      $"…/($segs | last 3 | str join "/")"
    } else { $cwd_rel }
  let path_col = $"($color_path)($show_path)($color_reset)"

  let git_raw = (try { ^git rev-parse --abbrev-ref HEAD | str trim } catch { "" })
  let git_col = if $git_raw != "" { $"($color_branch)($git_raw)($color_reset)" } else { "" }

  let py_raw = (
    if not ($env.VIRTUAL_ENV? | is-empty) {
      $env.VIRTUAL_ENV? | path basename
    } else if not ($env.CONDA_DEFAULT_ENV? | is-empty) {
      $env.CONDA_DEFAULT_ENV?
    } else { "" }
  )
  let py_col = if $py_raw != "" { $"($color_py)($py_raw)($color_reset)" } else { "" }

  let nix_raw = (
    if not ($env.NIX_SHELL_NAME? | is-empty) {
      $env.NIX_SHELL_NAME?
    } else if not ($env.name? | is-empty) {
      $env.name?
    } else if not ($env.IN_NIX_SHELL? | is-empty) {
      "nix"
    } else { "" }
  )
  let nix_col = if $nix_raw != "" { $"($color_nix)($nix_raw)($color_reset)" } else { "" }

  let segs_col = ([$git_col $py_col $nix_col] | where {|s| $s != "" } | str join " ")
  if $segs_col == "" { $"($path_col) > " } else { $"($path_col) ($segs_col) > " }
}

