use dirs::home_dir;

use std::convert::AsRef;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::string::FromUtf8Error;

#[derive(Debug)]
pub enum Error {
    IO(std::io::Error),
    FMT(std::fmt::Error),
    NotFoundError(String),
    FromUtf8Error,
    ConversionError,
}

impl From<FromUtf8Error> for Error {
    fn from(_: FromUtf8Error) -> Error {
        Error::FromUtf8Error
    }
}

macro_rules! impl_error_from {
    ($type:ty, $error_enum:expr) => {
        impl From<$type> for Error {
            fn from(error: $type) -> Error {
                $error_enum(error)
            }
        }
    };
}
impl_error_from!(std::io::Error, Error::IO);
impl_error_from!(std::fmt::Error, Error::FMT);
impl_error_from!(String, Error::NotFoundError);

impl std::fmt::Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Error::IO(error) => write!(f, "io error {error}"),
            Error::FMT(error) => write!(f, "fmt error {error}"),
            Error::NotFoundError(error) => write!(f, "file {error} is Not Found"),
            Error::ConversionError => write!(f, "ConversionError"),
            Error::FromUtf8Error => write!(f, "faild convert utf8"),
        }
    }
}

impl std::error::Error for Error {}

/// `path`から、`remove_string`を排除し、`String`としてかえす。
fn remove_useless_path_string(remove_string: &str, path: &Path) -> String {
    path.as_os_str()
        .to_str()
        .unwrap()
        .to_string()
        .replace(&(remove_string.to_owned() + "/"), "")
}

/// 与えられたディレクトリのファイルのパスを`PathBuf`のVecとして返す。
/// エラーがあった場合は、Errorで返す。
fn dir_traversal<T: AsRef<Path>>(dir: T) -> Result<Vec<PathBuf>, Error> {
    let dir = dir.as_ref();
    let mut paths = Vec::new();
    if dir.is_file() {
        paths.push(dir.to_path_buf());
    } else {
        for path in dir.read_dir()? {
            paths.append(&mut dir_traversal(path?.path())?);
        }
    }
    Ok(paths)
}

/// 入力されたファイルのディレクトリが存在するかどうかを返す。
/// ファイルが入力された場合、ファイルが存在するディレクトリがあるかどうか
/// 確認する。
fn dir_exist<P: AsRef<Path> + std::fmt::Debug>(path: P) -> bool {
    let mut path = path.as_ref();
    path = match path.parent() {
        Some(x) => x,
        None => panic!("入力されたパスに誤りがありそうだわん"),
    };
    path.exists()
}

/// ディレクトリを再起的に作る
fn mkdir_rec<P: AsRef<Path>>(dir: P) -> Result<(), Error> {
    fs::create_dir_all(dir)?;
    Ok(())
}

/// ファイルのパスが与えられ、親ディレクトリがあるかどうか確認し
/// 無ければ、ディレクトリ作成、あれば何もしない
fn check_and_mkdir<P: AsRef<Path> + std::fmt::Debug>(path: P) -> Result<(), Error> {
    if dir_exist(&path) {
        return Ok(());
    }
    let path = path.as_ref();
    let Some(parent) = path.parent() else {
        panic!("なんかおかしい2022年");
    };
    println!("dir {:?} is not exit. so mkdir", &parent);
    mkdir_rec(parent)?;
    Ok(())
}

/// `std::fs::copy`のラッパー
fn cp<P: AsRef<Path> + std::fmt::Debug>(source: P, target: P) -> Result<(), Error> {
    check_and_mkdir(&target)?;
    fs::copy(source.as_ref(), target.as_ref())?;
    Ok(())
}

fn byte_string(bite: Vec<u8>) -> Result<String, Error> {
    Ok(String::from_utf8(bite)?)
}

fn print_with_new_line(string: &str) {
    let lines: Vec<&str> = string.split('\n').collect();
    for line in lines {
        println!("{line}");
    }
}

fn is_installed<P: AsRef<Path>>(path: P) -> bool {
    let path = path.as_ref();
    path.is_file() || path.is_dir()
}

fn zinit() -> Result<(), Error> {
    let mut zinit_dir = home_dir().unwrap();
    zinit_dir.push(".local/share/zinit");
    if is_installed(zinit_dir) {
        println!("ZINIT is already installed");
        return Ok(());
    }

    println!("=============================================");
    println!("install zinit");
    let zinit_install_script = String::from_utf8(
        Command::new("curl")
            .arg("-fsSL")
            .arg("https://git.io/zinit-install")
            .output()
            .expect("Faild to get ZINIT install script")
            .stdout,
    )?;
    let install_res = Command::new("sh")
        .arg("-c")
        .arg(&zinit_install_script)
        .output()
        .expect("Failed to install zinit");
    println!("INSTALL STATUS {:?}", &install_res.status);
    println!("INSTALL STDOUT");
    print_with_new_line(&byte_string(install_res.stdout)?);
    println!("INSTALL STDERR");
    print_with_new_line(&byte_string(install_res.stderr)?);
    println!("=============================================");
    Ok(())
}

fn fzf() {
    let mut fzf_install_dir = home_dir().unwrap();
    fzf_install_dir.push(".fzf");
    // check if fzf installed
    if is_installed(&fzf_install_dir) {
        println!("fzf is already installed");
        return;
    }

    println!("try to install fzf");
    let command = Command::new("git")
        .args([
            "clone",
            "--depth",
            "1",
            "https://github.com/junegunn/fzf.git",
            &fzf_install_dir.to_string_lossy(),
        ])
        .output()
        .expect("Failed to clone fzf");
    print_with_new_line(&byte_string(command.stderr).unwrap());
    print_with_new_line(&byte_string(command.stdout).unwrap());
    
    let mut install_script = fzf_install_dir.clone();
    install_script.push("install");
    let command = Command::new(&install_script)
        .output()
        .expect("Failed to install fzf");
    print_with_new_line(&byte_string(command.stderr).unwrap());
    print_with_new_line(&byte_string(command.stdout).unwrap());
    println!("=============================================");

    println!("installed fzf");
}

fn ripgrep() -> Result<(), Error> {
    println!("=============================================");
    println!("install ripgrep");
    let command = Command::new("cargo")
        .args(["install", "ripgrep"])
        .output()
        .expect("faild to install");
    print_with_new_line(&byte_string(command.stderr)?);
    print_with_new_line(&byte_string(command.stdout)?);
    println!("=============================================");
    Ok(())
}

fn lsd() -> Result<(), Error> {
    println!("=============================================");
    println!("install lsd");
    let command = Command::new("cargo")
        .args(["install", "lsd"])
        .output()
        .expect("failed to install lsd");
    print_with_new_line(&byte_string(command.stderr)?);
    print_with_new_line(&byte_string(command.stdout)?);
    println!("=============================================");
    Ok(())
}

fn deno() -> Result<(), Error> {
    println!("=============================================");
    println!("install deno");
    let command = Command::new("sh")
        .arg("-c")
        .arg("curl -fsSL https://deno.land/install.sh | sh")
        .output()
        .expect("failed to install deno");
    print_with_new_line(&byte_string(command.stderr)?);
    print_with_new_line(&byte_string(command.stdout)?);
    println!("=============================================");
    Ok(())
}

fn main() -> Result<(), Error> {
    let dofiles_path = "./dotfiles".to_string();
    let files = dir_traversal(&dofiles_path).unwrap();
    let home_dir = home_dir().unwrap();
    zinit()?;
    fzf();
    ripgrep()?;
    lsd()?;
    deno()?;
    for path in files {
        let mut new_path = home_dir.clone();
        new_path.push(remove_useless_path_string(&dofiles_path, &path));
        println!("copy {:?} to {:?}", &path, &new_path);
        cp(path, new_path)?;
    }
    Ok(())
}
