import platform
import subprocess
import sys


def exec(cmd):
    print(cmd, file=sys.stderr, end='')
    completed = subprocess.run(["powershell", "-Command", cmd], capture_output=True)
    return completed


def ssh():
    cmds = ['Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0\n',
            'Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0\n']
    for cmd in cmds:
        exec(cmd)


def choco_pkgs():
    cur_os = platform.system()
    fn = cur_os + '.install'
    with open(fn) as f:
        lines = f.readlines()
        for line in lines:
            cmd = 'choco install -y ' + line
            exec(cmd)
    

class Install():
    @staticmethod
    def run():
        ssh()
        choco_pkgs()
