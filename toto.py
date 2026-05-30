import os
import traceback
import gc

### Basic functions for data processing
def read_data(data_path, data_len=8, skip_pattern=[]):
	ret = {}
	if not os.path.isfile(data_path):
		return ret

	with open(data_path, 'r') as f:
		for line in f:
			b_skip = False
			for pattern in skip_pattern:
				if pattern in line:
					b_skip = True
					break
			if b_skip:
				continue
			elements = line.strip().split(',')
			if len(elements) != data_len:
				print(f'Expected {data_len} elements, but got {len(elements)}: {line}')
				ret = {}
				break
			key = elements[0].strip()
			value = [ elem.strip() for elem in elements[1:] ]
			ret[key] = value

	return ret

### main function
def main():
	dict_data = read_data(data_path='ordered_data.txt', data_len=8, skip_pattern=['http'])
	for key, value in dict_data.items():
		print(f'{key}: {value}')

if __name__ == "__main__":
	try:
		main()
	except:
		print(traceback.format_exc())
	gc.collect()
