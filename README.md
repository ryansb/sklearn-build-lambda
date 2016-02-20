## Building scikit-learn for Lambda

Once you run `launch_sklearner.yml` you'll have a zipfile containing sklearn
and its dependencies, to use them add your handler file to the zip, and add the
`lib` directory so it can be used for shared libs. The minimum viable sklearn
handler would thus look like:

```
import os
import ctypes

for d, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.a'):
            continue
        ctypes.cdll.LoadLibrary(os.path.join(d, f))

import sklearn

def handler(event, context):
    # do sklearn stuff here
    return {'yay': 'done'}

```
