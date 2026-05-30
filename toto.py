import os
import traceback
import gc

### main function
def main():
	None

if __name__ == "__main__":
	try:
		main()
	except:
		print(traceback.format_exc())
	gc.collect()
