#!/usr/bin/python

import logging
import signal
import subprocess
import sys
import os

def make_handler(a):
    def handle_signal(signum, stack):
        a.send_signal(signum)
        log.info("Sent SIGINT to subprocess")
    return handle_signal

def parse_env_vars(args):
    index = 0
    env_vars = {}
    for var in args:
        # all environment parameters should be listed before the
        # executable, which is not suppose to contain the "=" sign
        # in the name
        kv_pair = var.split("=")
        if len(kv_pair) == 2:
            key, value = kv_pair
            env_vars[key.strip()] = value.strip()
            index += 1
        else:
            break

    return env_vars, args[index:]



def main(*args):
    
    log = logging.getLogger()
    hdlr = logging.StreamHandler()
    formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
    hdlr.setFormatter(formatter)
    log.addHandler(hdlr)
    log.setLevel(logging.DEBUG)
    log.info("Running %s" % ' '.join(args))
    log.info("master is %s" % os.environ['OSHINKO_SPARK_MASTER'])

    log.info("env is %s" % os.environ)
    try:
        # "Unignore" SIGINT before the subprocess is launched
        # in case this process is running in the background
        # (background processes ignore SIGINT)
        signal.signal(signal.SIGINT, signal.SIG_DFL)

        # Separate between command including arguments and
        # environment variables
        env, cargs = parse_env_vars(args)

        # Interpret all command line args as the command to run
        a = subprocess.Popen(cargs,
                             env=env,
                             stdout=open("/tmp/stdout", "w"),
                             stderr=open("/tmp/stderr", "w"))

        # Set our handler to trap SIGINT and propagate to the child
        # The expectation is that the child process handles SIGINT
        # and exits.
        signal.signal(signal.SIGINT, make_handler(a))

        # Write out the childpid just in case there is a
        # need to send special signals directly to the child process
        open("/tmp/childpid", "w").write("%s\n" % a.pid)

        # Wait for child to exit and write result file
        log.info("Waiting for subprocess %s" % a.pid)
        ret = a.wait()
        log.info("Subprocess exit status %s" % ret)
        open("/tmp/result", "w").write("%s\n" % ret)

    except Exception as e:
        log.exception(e)

if __name__ == "__main__":
    main(*sys.argv[1:])
