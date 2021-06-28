# requires Python >= 3.5 for dict linking (https://segmentfault.com/a/1190000010567015)

import pyrebase
import time
import signal
import sys
from multiprocessing import Process
from appliance_control import *
from monitor_capturing import *
from temperature import *


config = {
	'apiKey': "*",
	'authDomain': "rc-smart-home.firebaseapp.com",
	'databaseURL': "https://rc-smart-home.firebaseio.com",
	#projectId: "rc-smart-home",
	'storageBucket': "rc-smart-home.appspot.com",
}

email = "test@test.com"
password = "123456"

firebase = pyrebase.initialize_app(config)
auth = firebase.auth()
user = auth.sign_in_with_email_and_password(email, password)
db = firebase.database()
storage = firebase.storage()
user = {**user, **auth.refresh(user['refreshToken'])}


appliance_id_list = [31,37]
appliance_control = RCAppliance(appliance_id_list)


listening_streams = []

'''
def turn_off_stream_handler(message):
	if(message['data'] == None):
		return
	if(message["event"]=='put'):
		print("[RC Info] Receive turn off request:")
		for id in message['data']['off']:
			print("[RC Info] Turn off", id, end='')
			if(not appliance_control.turnOff(id)):
				print(" Done!")
		db.child('communication').child(user['userId']).child('user-requests').child('turn-off').remove()
	return
'''

def update_appliances():
	status = appliance_control.status
	update_result = db.child('communication').child(user['userId']).child('appliances').update(status)
	print("[RC Info] Appliances' status updated:", update_result)
	return

target_time = -1

def remove_turn_request():
	if(int(time.time())>target_time):
		db.child('communication').child(user['userId']).child('user-requests').child('appliances').remove()
		print("[RC Info] User control request clear.")
	#deltime = int(time.time())

def turn_stream_handler(message):
	if(message['data'] == None):
		print("[RC ERR] NO REQUEST DATA.")
		return
	if(message["event"]=='put' or message["event"]=='patch'):
		print("[RC Info] Receive turn on/off request:")
		for id in message['data'].keys():
			status = message['data'][id]
			print("[RC Info] ", id, status, end='')
			if(status=='on'):
				if(not appliance_control.turnOn(id)):
					print(" ... Done!")
				else:
					print(" ... Error!")
			else:
				if(not appliance_control.turnOff(id)):
					print(" ... Done!")
				else:
					print(" ... Error!")
		remove_turn_request()
		update_appliances()
	#target_time = int(time.time())+2
	#time.sleep(2)
	return

lastMonitorRequest = int(time.time())-1000

def capture_stream_handler(message):
	global lastMonitorRequest
	"""handling the stream listening message"""
	curtime = int(time.time())
	if(curtime-lastMonitorRequest<5):
		db.child('communication/'+user['userId']+'/user-requests/capturing').remove()
		return
	lastMonitorRequest = curtime
	if(message['data'] == None):
		return
	if(message["event"]=='put'):
		print("[RC Info] Received monitor request:", message['data'])
		updateMonitorImage()
	#print(message["event"]) # put
	#print(message["path"]) # /-K7yGTTEp7O549EzTYtI
	#print(message["data"]) # {'title': 'Pyrebase', "body": "etc..."}
	db.child('communication/'+user['userId']+'/user-requests/capturing').remove()
	return


def startDataListening():
	global listening_streams
	listening_streams.append( db.child('communication/'+user['userId']+'/user-requests/monitor').stream(capture_stream_handler, stream_id="capture-requests") )
	listening_streams.append( db.child('communication/'+user['userId']+'/user-requests/appliances').stream(turn_stream_handler, stream_id="turn-requests") )
	#listening_streams.append( db.child('communication/'+user['userId']+'/user-requests/turn-off').stream(turn_off_stream_handler, stream_id="turn-off-requests") )
	print("[RC Info] Data listening started.")




def updateTemperature():
	cur_time = time.strftime("%b/%d/%Y %a %H:%M", time.localtime())
	data = getTemperature()
	update_result = db.child("communication").child(user['userId']).update(data)
	print("[RC Info] Update temperature and humidity:",update_result)
	time.sleep(60)
	updateTemperature()

def refreshAuthToken():
	global user
	time.sleep(3200)
	user = {**user, **auth.refresh(user['refreshToken'])}
	print("[RC Info] Auth token refreshed.")
	refreshAuthToken()




def updateMonitorImage(times=5):
	if(times<1):
		db.child('communication').child(user['userId']).child('user-requests').child('monitor').remove()
		return
	#cur_time = int(time.time())
	cur_time = time.strftime("%b/%d/%Y %a %H:%M", time.localtime())
	img_filename = RCMonitor.capture('img.jpg')
	if(img_filename == ''):
		time.sleep(8)
		print("[RC Info] Fail and retry (",times,")")
		updateMonitorImage(times-1)
		return
	print("YYYYYYYYYOOOOOOOOOOOOOOUUUUUUUUUUUUUUU")
	storage.child(user['userId']+"/monitor_image/img.jpg").put(img_filename, user['idToken'])
	data = {"capturing":cur_time}
	update_result = db.child("communication").child(user['userId']).child("home-responds").update(data)
	db.child('communication').child(user['userId']).child('user-requests').child('monitor').remove()
	print("[RC Info] Monitor image updated! @", cur_time, " #", update_result)


def main():
	global user
	print("================ RC Smart Home ================")
	print("")
	print("[RC Info]", user['displayName']+", Good day!")
	print("[RC Info] Email Account:", user['email'])
	print("[RC Info] Your user ID :", user['userId'])
	print("")
	startDataListening()
	#updateMonitorImage()
	#input("continue ...")
	processes = [Process(target = updateTemperature), Process(target = refreshAuthToken)]
	for p in processes:
		p.start()
	for p in processes:
		p.join()
	print("[RC Info] Process end.")

def signal_handler(signal, frame):
	global listening_streams
	print('[RC Warning] You pressed Ctrl+C. Programme ends.')
	for stream in listening_streams:
		stream.close()
	print("======== Thank you for using RC Smart Home! ========")
	sys.exit(0)

if __name__ == '__main__':
	signal.signal(signal.SIGINT,signal_handler)
	main()
