# selfy

Automate some OS tasks (for now, only installation of a functional environment).

## Linux

- Auto-(re|un)installation:

```
# Install selfy
./selfy --install
# Uninstall selfy
./selfy --uninstall
# Reinstall selfy
./selfy --reinstall
```

### Installation of packages

```
# Office environment
selfy --office
# Programming environment
selfy --programming
# Web development environment
selfy --webdev
```

If you want know the packages that will be installed, just run with flag `--check`:

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
