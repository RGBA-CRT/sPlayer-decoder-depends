
import sys
import pefile
import shutil


def kill_tls(infile):
	shutil.copyfile(infile, infile+".org")
	pe =  pefile.PE(infile)
	# print(pe)

	# print(pe.OPTIONAL_HEADER)
	tls_dir = pe.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_TLS']]
	print(tls_dir)


args = sys.argv[1:]
for arg in args:
	kill_tls(arg)