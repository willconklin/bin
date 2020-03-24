#! /usr/bin/python

import os
import datetime

tableStr='TABLE'


# rm existing TABLE link, if any
if os.path.islink(tableStr):
  os.unlink(tableStr)
  print("Deleted stale {} link.".format(tableStr))

# Get today's date
now = datetime.datetime.now()

# Create a directory based on today's date
dirStr = "table_{}.{}.{}".format(now.month, now.day, now.year-2000)
if not os.path.isdir(dirStr):
  os.mkdir(dirStr)
  print("Created directory {}.".format(dirStr))

# Create the link to said directory
os.symlink(dirStr, tableStr)

# Report!
print("Created symlink {} to directory {}".format(tableStr, dirStr))
