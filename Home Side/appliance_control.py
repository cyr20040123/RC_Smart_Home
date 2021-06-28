# Appliance Control
import RPi.GPIO as GPIO
class RCAppliance():
	id_list = []
	status = dict()

	def __init__(self, id_list):
		self.id_list = id_list
		for i in id_list:
			self.status[str(i)]="off"
		GPIO.cleanup()
		GPIO.setmode(GPIO.BOARD)
		for i in id_list:
			GPIO.setup(i,GPIO.OUT)
			GPIO.output(i,GPIO.LOW)
	
	
	def turnOn(self, id):
		try:
			if(type(id)==type('123')):
				id = id.replace(' ','')
			id = int(id)
		except Exception:
			print("[RC Error] Wrong appliance ID format:[",id,"][",type(id),"]")
			return 1
		if(not id in self.id_list):
			print("[RC Error] Wrong appliance ID number:",id)
			return 1
		try:
			GPIO.output(id,GPIO.HIGH)
			self.status[str(id)]='on'
		except Exception:
			print("[RC Error] When operate the light:",id)
			return 1
		return 0
	
	def turnOff(self, id):
		try:
			if(type(id)==type('123')):
				id = id.replace(' ','')
			id = int(id)
		except Exception:
			print("[RC Error] Wrong appliance ID format:[",id,"][",type(id),"]")
			return 1
		if(not id in self.id_list):
			print("[RC Error] Wrong appliance ID number:",id)
		try:
			GPIO.output(id,GPIO.LOW)
			self.status[str(id)]='off'
		except Exception:
			print("[RC Error] When operate the light:",id)
			return 1
		return 0
