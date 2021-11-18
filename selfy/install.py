import platform
import subprocess
import sys

def fatal(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def exec(plat, cmd_arr):
    cmd = ' '.join(cmd_arr)
    print(cmd, file=sys.stderr)
    if plat == 'Windows':
        subprocess.run(cmd_arr, capture_output=True)
    else:
        subprocess.call(cmd, shell=True)


def install_cmd(plat, args):
    cmd = None
    if plat == 'Windows':
        if args == 'ssh':
            return ['powershell', '-Command', 'Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0\n']
        elif args == 'sshd':
            return ['powershell', '-Command', 'Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0\n']
        else:
            cmd = 'choco install -y ' + args
        return ["powershell", "-Command", cmd]
    elif plat == 'Linux':
        cmd = 'sudo apt-get install -y ' + args
        return ["sudo", "", cmd]
    else:
        fatal('unknown platform "{}"'.format(plat))


def install(plat, args):
    cmd_arr = install_cmd(plat, args)
    exec(plat, cmd_arr)


def install_pkgs(plat):
    fn = plat + '.install'
    with open(fn) as f:
        lines = f.readlines()
        for pkg in lines:
            install(plat, pkg)


def update(plat, are_pkgs=False):
    if plat == 'Linux':
        update = 'update'
        if are_pkgs:
            update = 'upgrade'
        exec(plat, ['sudo apt-get', update, '-y'])
    else:
        print('WARNING: update is not implemented for Windows', file=sys.stderr)

class Install():
    @staticmethod
    def run():
        cur_os = platform.system()
        update(cur_os)
        install_pkgs(cur_os)
        update(cur_os, True)
