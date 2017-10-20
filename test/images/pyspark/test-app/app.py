# spark-basic.py
from pyspark import SparkConf
from pyspark import SparkContext

conf = SparkConf()
conf.setAppName('spark-basic')
sc = SparkContext(conf=conf)

def mod(x):
    return (x, x % 2)

rdd = sc.parallelize(range(1000)).map(mod).take(30)
print rdd
