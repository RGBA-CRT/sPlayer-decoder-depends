
import sys
import pefile
import shutil

def find_section_idx(pe, name):
	tls_sec_idx=0
	for section in pe.sections:
		section_name = section.Name.decode('ascii').replace("\x00","")
		#print(tls_sec_idx,"'",bytes(section_name, "utf-8"),"'",".tls"==section_name)
		if name == section_name:
			#print("TLS section found: ", tls_sec_idx)
			break
		tls_sec_idx = tls_sec_idx+1
	return tls_sec_idx

def kill_tls(infile):
	shutil.copyfile(infile, infile+".org")
	pe =  pefile.PE(infile)
	# print(pe)

	# print(pe.OPTIONAL_HEADER)
	tls_dir = pe.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_TLS']]
	#print(tls_dir)
	tls_dir.Size = 0
	tls_dir.VirtualAddress = 0
	#print(tls_dir)

	# tls_sec_index = find_section_idx(pe, ".tls")
	# # print(type(pe.sections))
	# print("section index=",tls_sec_index)
	# print(pe.sections[tls_sec_index])
	# del pe.sections[tls_sec_index]
	# # print(pe.sections[tls_sec_index])

	pe.write(infile)

	print("TLS callback removed:",infile)


args = sys.argv[1:]
for arg in args:
	kill_tls(arg)