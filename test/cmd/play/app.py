from __future__ import print_function
import sys
import time
import numpy

from pyspark import SparkConf
from pyspark import SparkContext

conf = SparkConf()
conf.setAppName('spark-basic')
sc = SparkContext(conf=conf)

def mod(x):
    return (x, numpy.mod(x, 2))

rdd = sc.parallelize(range(1000000)).map(mod).take(30)
print(rdd)
if len(sys.argv) > 1:
    print("app.py sleeping for %s" % sys.argv[1])
    time.sleep(float(sys.argv[1]))
