import os
import platform

class Install():
    def __init__(self, os='windows'):
        self._os = os

    @staticmethod
    def run():
        cur_os = platform.system()
        fn = cur_os + '.install'
        with open(fn) as f:
            lines = f.readlines()
            for line in lines:
                cmd = 'choco install -y ' + line
                os.system(cmd)
