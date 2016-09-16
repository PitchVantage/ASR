addr = 'temp/messy_silences.txt'
import re

result = ''
counter = 0
fullFile = ''
with open(addr) as f:
    for line in f:
        fullFile += line

fullFile = re.sub('(\\d).{0,8}size.{20,40}speed.{2,16}\\s*\\[sil','\\1\\n[sil',fullFile,flags=re.DOTALL)

lines = fullFile.split('\n')
for line in lines:
    if line[0:14]=='[silencedetect':
            counter += 1
            lastNumber = re.sub('.* (\\d+(\\.\\d+){0,1}).*$','\\1',line)
            lastNumber = lastNumber.strip()
            if counter%2==1:
                    result += lastNumber+'\t'
            else:
                    result += lastNumber+'\n'
    else:
            #print('BIZZ:('+str(len(line))+')'+line[:-1]+"*********")
            pass

#Delete the last line if it only has one number:
result = re.sub('\\d+(\\.\\d+){0,1}\\t$','',result)
            
output = open('temp/silences.txt','w')
output.write(result)
output.close()
