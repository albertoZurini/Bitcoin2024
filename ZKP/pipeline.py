import os
import json

with open("generator/args.txt", "r") as f:
    args = f.read()

script = "cd /ciao/verifier && zokrates compile -i root.zok && " +\
f"zokrates setup && zokrates compute-witness -a {args} && " +\
"zokrates generate-proof && zokrates export-verifier && " +\
"echo '\n\n\n ====== NOW THE GOVERNMENT CHECKS THE STATEMENT ===== \n' && zokrates verify && echo '\n\n\n'"

with open("script.sh", "w") as f:
    f.write(script)

cmd = f"""docker run -v $PWD:/ciao -t zokrates/zokrates /bin/bash /ciao/script.sh"""

os.system(cmd)

with open("verifier/proof.json") as f:
    json_data = json.loads(f.read())

print("PROOF:")
# arr = [json_data["proof"]["a"][0], json_data["proof"]["a"][1], json_data["proof"]["b"][0][0], json_data["proof"]["b"][1][1], json_data["proof"]["b"][0][0], json_data["proof"]["b"][1][1], json_data["proof"]["c"][0], json_data["proof"]["c"][1]]
arr = [json_data["proof"]["a"], json_data["proof"]["b"], json_data["proof"]["c"]]
print(json.dumps(arr))
print("INPUT:")
print(json.dumps(json_data["inputs"]))
