import os

path = ""
os.chdir(os.path.expanduser(path))

c = 1

for f in os.listdir():
    f_name, f_ext = os.path.splitext(f)
    f_name = str(c)
    c = c + 1

    new_name = f"{f_name}{f_ext}"
    os.rename(f, new_name)

print("Done!")
