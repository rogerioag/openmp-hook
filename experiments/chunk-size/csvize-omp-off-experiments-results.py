#!/usr/bin/python

import csv, re
import sys, getopt

#Execution = 6, benchmark = gemm, size_of_data = LARGE_DATASET, schedule = DYNAMIC, chunk_size = 32, num_threads = 18,
#exp = OMP+OFF, num_threads = 18, NI = 2048, NJ = 2048 , NK = 2048, ORIG = 89.680057
#, OMP = 14.181837

# header = 'execution,benchmark,size_of_data,schedule,chunk_size,num_threads,exp,num_threads,NI,NJ,NK,ORIG,OMP'

#Execution = 1, benchmark = gemm, size_of_data = LARGE_DATASET, schedule = DYNAMIC, chunk_size = 256, num_threads = 24,
#exp = OMP+OFF, num_threads = 24, NI = 2048, NJ = 2048, NK = 2048, ORIG = 80578387191, OMP+OFF = 12361544809, OMP = 12361544809, CUDA_KERNEL1 = 0, CUDA_KERNEL2 = 0, CUDA_KERNEL3 = 0, DT_H2D = 0, DT_D2H = 0

header = 'Execution,benchmark,size_of_data,schedule,chunk_size,num_threads,exp,num_threads,NI,NJ,NK,ORIG,OMP_OFF,OMP,CUDA_KERNEL1,CUDA_KERNEL2,CUDA_KERNEL3,DT_H2D,DT_D2H'

def parse(data):

    print 'parsing...'

    # result = re.findall('Execution = (.*?), benchmark = (.*?), size_of_data = (.*?), schedule = (.*?), chunk_size = (.*?), num_threads = (.*?)\nexp = (.*?), num_threads = (.*?), NI = (.*?), NJ = (.*?), NK = (.*?), ORIG = (.*?), OMP_OFF = (.*?), OMP = (.*?), CUDA_KERNEL1 = (.*?), CUDA_KERNEL2 = (.*?), CUDA_KERNEL3 = (.*?), DT_H2D = (.*?), DT_D2H = (.*?)\n', data, re.DOTALL)

    result = re.findall('Execution = (.*?), benchmark = (.*?), size_of_data = (.*?), schedule = (.*?), chunk_size = (.*?), num_threads = (.*?),\n.*?\n*exp = (.*?), num_threads = (.*?), NI = (.*?), NJ = (.*?), NK = (.*?), ORIG = (.*?), OMP_OFF = (.*?), OMP = (.*?), CUDA_KERNEL1 = (.*?), CUDA_KERNEL2 = (.*?), CUDA_KERNEL3 = (.*?), DT_H2D = (.*?), DT_D2H = (.*?)\n', data, re.DOTALL)

    print (result)

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
      print 'writing...'
      write_to_csv(result, header, outputfile)
   else :
      print 'Use:\ncsvize.py -i <inputfile> -o <outputfile>'

if __name__ == "__main__":
   main(sys.argv[1:])