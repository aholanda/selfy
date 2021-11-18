import os
import platform
import sys

sudos = {'Linux': 'sudo', 'Windows': 'powershell'}
pkg_mgrs = {'Linux': sudos['Linux'] + ' apt-get', 'Windows': 'choco'}
install_cmds = {'Linux': pkg_mgrs['Linux'] + ' install -y ', 
                'Windows': pkg_mgrs['Windows'] + ' install -y '}
script_exts = {'Linux': '.sh', 'Windows': '.ps1'}
dev_nulls = {'Linux': ' >/dev/null', 'Windows': ' >$null'}

def fatal(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def exec(cmd):
    print(cmd, file=sys.stderr)
    os.system(cmd)

def __script_cmd(p, s):
    if p == 'Windows':
        return sudos[p] + ' "& \'{}\'"'.format(s) + dev_nulls[p]
    else:
        return sudos[p] + ' ' + s + dev_nulls[p]


def install(plat, args):
    script = os.path.join(plat, args + script_exts[plat])
    if os.path.isfile(script):
        exec(__script_cmd(plat, script))
    else:
        cmd = install_cmds[plat] + args + dev_nulls[plat]
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
