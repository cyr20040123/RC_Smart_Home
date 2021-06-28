# Camera Capturing and Saving
from picamera import PiCamera
import time
camera = PiCamera()
camera.resolution = '800x600'
class RCMonitor():
	def capture(filename='img.jpg'):
		global camera
		if (filename==''):
			filename = "no_image.jpg"
		try:
			#camera = PiCamera()
			camera.start_preview(alpha=200)
			time.sleep(3)
			camera.capture(filename)
			camera.stop_preview()
			print("[RC Info] Photo taken.")
		except Exception:
			print("[ERROR] In capturing.")
			#camera.stop_preview()
			return ''
		return filename
