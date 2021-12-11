# selfy

Automate some OS tasks (for now, only installation of a functional environment).

## Linux

- Setup of a core environment:

```
./setup.sh
```

- Installation of packages using Ansible:

```
./selfy.sh --install
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
