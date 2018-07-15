#!/usr/bin/env python
# script.py - Simple TensorFlow Matrix Multiplication

import tensorflow as tf
import os
import time


# Folder mapping
input_dir = os.path.abspath("./input")
output_dir = os.path.abspath("./output")

# Get input values from files
reader = {}
with open(os.path.join(input_dir, "a.txt"), "r") as rf:
    # Read all lines of input file
    content = rf.readlines()
    # Transform lines into float values, add to array, reader
    reader["a"] = [float(x.strip()) for x in content]
print("Input of a: {}".format(reader["a"]))

with open(os.path.join(input_dir, "b.txt"), "r") as rf:
    content = rf.readlines()
    reader["b"] = [float(x.strip()) for x in content]
print("Input of b: {}".format(reader["b"]))

start = time.time()

# Creates a graph.
a = tf.constant(reader["a"], shape=[2000, 1500], name='a')
b = tf.constant(reader["b"], shape=[1500, 2000], name='b')
c = tf.matmul(a, b)

# Creates a session
with tf.Session(config=tf.ConfigProto(log_device_placement=True)) as sess:
    # Runs the op.
    d = sess.run(c)
    
end = time.time()
e = "Finished after {}s\n{}".format(end - start, d)
print(e)

# Save output to file
with open(os.path.join(output_dir, "out.txt"), "w") as wf:
    wf.write(e)
