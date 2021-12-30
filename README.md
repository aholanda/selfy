# selfy

Automate some OS tasks (for now, only installation of a functional environment).

## Linux (Debian family)

- Auto-(re|un)installation:

Dependency: `make`
```
# Install selfy
sudo make install
# Uninstall selfy
sudo make uninstall
# Reinstall selfy
sudo make reinstall
```

### Installation of packages

After installing `selfy`, one of the following commands can be executed:

```
# Office environment
selfy --office
# Programming environment
selfy --programming
# Web development environment
selfy --webdev
```

If you want know the packages that will be installed, just run `selfy` with flag `--check`:

```
# What are the packages from office environment?
selfy --office --check
```

## Windows

- Setup of a core environment:

```
powershell setup.ps1
```

- Installation of packages using Chocolatey:

```
python3 selfy.py
```
