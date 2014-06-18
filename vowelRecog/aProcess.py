temp = []

for line in open("a.txt", "r"):
    temp.append(int(line.split()[0]))

divisor = temp[0]
temp = temp[1:]

print("final float[] aProb = {")
for i in temp:
    print("  {0:0.5f},".format(i / divisor))
print("};\n")


temp = []

for line in open("i.txt", "r"):
    temp.append(int(line.split()[0]))

divisor = temp[0]
temp = temp[1:]

print("final float[] iProb = {")
for i in temp:
    print("  {0:0.5f},".format(i / divisor))
print("};\n")


temp = []

for line in open("o.txt", "r"):
    temp.append(int(line.split()[0]))

divisor = temp[0]
temp = temp[1:]

print("final float[] oProb = {")
for i in temp:
    print("  {0:0.5f},".format(i / divisor))
print("};\n")


print("final float[] xProb = {")
for i in range(33):
    print("  0.5,")
print("};")
