#!/usr/bin/python

import csv, re
import sys, getopt

#Execution = 6, benchmark = gemm, size_of_data = LARGE_DATASET,
#exp = CUDA, NI = 2048, NJ = 2048, NK = 2048, CUDA = 0.566267
#, ORIG = 80.627620

header = 'execution,benchmark,size_of_data,exp,NI,NJ,NK,CUDA,ORIG'

def parse(data):

    result = re.findall('Execution = (.*?), benchmark = (.*?), size_of_data = (.*?),\n.*?exp = (.*?), NI = (.*?), NJ = (.*?), NK = (.*?), CUDA = (.*?)\n.*?, ORIG = (.*?)\n', data, re.DOTALL)

    return result

def write_to_csv(parsed_data, header, filename):
    with open(filename, 'w') as f:
        f.write(header + '\n')
        writer = csv.writer(f, lineterminator='\n')
        for item in parsed_data:
            writer.writerow(item)

def main(argv):
   inputfile = ''
   outputfile = ''
   try:
      opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
   except getopt.GetoptError:
      print 'csvize.py -i <inputfile> -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'csvize.py -i <inputfile> -o <outputfile>'
         sys.exit()
      elif opt in ("-i", "--ifile"):
         inputfile = arg
      elif opt in ("-o", "--ofile"):
         outputfile = arg
   
   if inputfile and outputfile :
      print 'Input file is "', inputfile
      print 'Output file is "', outputfile
      with open(inputfile, 'r') as f:
    	data = f.read()
    	print (data)
    	result = parse(data)
    	write_to_csv(result, header, outputfile)
   else :
      print 'Use:\ncsvize.py -i <inputfile> -o <outputfile>'

if __name__ == "__main__":
   main(sys.argv[1:])