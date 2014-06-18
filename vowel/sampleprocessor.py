import random

learnA = []
learnI = []
learnO = []
testset = []

for line in open("sampleList.txt", "r"):
    filename = line.split()[-1]
    if filename[0] == 'a':
        learnA.append('"samples/' + filename + '",')
    elif filename[0] == 'i':
        learnI.append('"samples/' + filename + '",')
    elif filename[0] == 'o':
        learnO.append('"samples/' + filename + '",')

for i in range(3):
    testset.append(learnA.pop(random.randrange(len(learnA))))
    testset.append(learnI.pop(random.randrange(len(learnI))))
    testset.append(learnO.pop(random.randrange(len(learnO))))

print("final String[] sampleName = {")
for file in learnA + learnI + learnO:
    print("  " + file)
print("};")

print("")

print("final String[] testName = {")
for file in testset:
    print("  " + file)
print("};")
