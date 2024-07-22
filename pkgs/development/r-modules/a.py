import json

with open("bioc-experiment-packages.json") as f:
    data=json.load(f)
with open("bioc-experiment-packages.json", "w") as f:
    json.dump(data, f, indent=2)
