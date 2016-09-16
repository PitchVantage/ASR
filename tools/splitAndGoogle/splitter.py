from subprocess import call
import sys

timesFileAddr = 'temp/silences.txt'

splitPoints = []
with open(timesFileAddr) as file:
    for line in file:
        numbers = line.split()
        silStart = numbers[0]
        silDuration = numbers[1]
        silStart = float(silStart)
        silDuration = float(silDuration)
        splitPoint = silStart+silDuration/2
        splitPoints.append(splitPoint)

prevPoint = 0
for i in range(len(splitPoints)):
    print('splitting')
    currentPoint = splitPoints[i]
    call('ffmpeg -ss '+str(prevPoint)+' -t '+str(currentPoint-prevPoint)+' -i '+sys.argv[1]+' chunks/chunk'+str(i)+'.wav',shell=True)
    prevPoint = currentPoint


call('ffmpeg -ss '+str(splitPoints[len(splitPoints)-1])+' -t 10 -i '+sys.argv[1]+' chunks/chunk'+str(len(splitPoints))+'.wav',shell=True)
