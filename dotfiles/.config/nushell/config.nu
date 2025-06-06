$env.config.buffer_editor = "nvim"
$env.VISUAL = "nvim"
$env.EDITOR = "nvim"

use std/util "path add"
if ("/run/current-system/sw/bin" | path exists) { path add "/run/current-system/sw/bin" }
path add "/nix/var/nix/profiles/default/bin"
let user_profile = $nu.home-path | path join ".nix-profile" "bin"
if ($user_profile | path exists) { path add $user_profile }

alias vi = nvim

$env.PROMPT_COMMAND = {||
  let cwd = (pwd | path basename)
  let git_branch = (try { ^git rev-parse --abbrev-ref HEAD | str trim } catch { "" })
  let py_venv = if (not ($env.VIRTUAL_ENV? | is-empty)) {
      $env.VIRTUAL_ENV? | path basename
    } else if (not ($env.CONDA_DEFAULT_ENV? | is-empty)) {
      $env.CONDA_DEFAULT_ENV?
    } else { "" }
  let nix_env = if (not ($env.NIX_SHELL_NAME? | is-empty)) {
      $env.NIX_SHELL_NAME?
    } else if ((not ($env.IN_NIX_SHELL? | is-empty)) and ($env.IN_NIX_SHELL == "1") and (not ($env.name? | is-empty))) {
      $env.name?
    } else { "" }
  let segments = [$git_branch $py_venv $nix_env] | filter {|s| $s != "" } | str join " "
  if ($segments | is-empty) {
    $"($cwd) > "
  } else {
    $"($cwd) ($segments) > "
  }
}

