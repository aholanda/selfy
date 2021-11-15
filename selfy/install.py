import os
import platform

class Install():
    @staticmethod
    def run():
        cur_os = platform.system()
        fn = cur_os + '.install'
        with open(fn) as f:
            lines = f.readlines()
            for line in lines:
                cmd = 'choco install -y ' + line
                print(line)
                os.system(cmd)
