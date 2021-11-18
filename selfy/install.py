import os
import platform
import subprocess
import sys

sudos = {'Linux': 'sudo', 'Windows': ''}
pkg_mgrs = {'Linux': sudos['Linux'] + ' apt-get', 'Windows': 'choco'}
install_cmds = {'Linux': pkg_mgrs['Linux'] + ' install -y ', 
                'Windows': pkg_mgrs['Windows'] + ' install -y '}
script_exts = {'Linux': '.sh', 'Windows': '.ps1'}


def fatal(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def exec(cmd):
    print(cmd, file=sys.stderr)
    os.system(cmd)


def install(plat, args):
    script = os.path.join(plat, args + script_exts[plat])
    if os.path.isfile(script):
        exec(sudos[plat] + ' ' + script)
        sys.exit(1)
    else:
        cmd = install_cmds[plat] + args
        exec(cmd)


def install_pkgs(plat):
    fn = plat + '.install'
    with open(fn) as f:
        lines = f.readlines()
        for pkg in lines:
            if pkg[0] == '#':
                continue
            pkg = pkg.strip()
            install(plat, pkg)


def update(plat, are_pkgs=False):
    if plat == 'Linux':
        update = 'update'
        if are_pkgs:
            update = 'upgrade'
        exec(pkg_mgrs[plat] + update + '-y')
    else:
        print('WARNING: update is not implemented for Windows', file=sys.stderr)


class Install():
    @staticmethod
    def run():
        cur_os = platform.system()
        update(cur_os)
        install_pkgs(cur_os)
        update(cur_os, True)
